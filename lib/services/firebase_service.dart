import 'package:asshab_gym_web_admin/models/member_history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member.dart';
import '../models/admin_user.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Members collection
  CollectionReference get _membersCollection => _firestore.collection('members');
  CollectionReference get _pendingRegistrationsCollection => _firestore.collection('pending_device_registrations');
  CollectionReference get _checkinsCollection => _firestore.collection('checkins');
  CollectionReference get _expiredAttemptsCollection => _firestore.collection('expired_checkin_attempts');
  CollectionReference get _memberDeletionRequestsCollection => _firestore.collection('member_deletion_requests');
  CollectionReference get _memberHistoryCollection => _firestore.collection('member_history');

  // Get all pending device registrations
  Stream<List<PendingDeviceRegistration>> getPendingRegistrations() {
    return _pendingRegistrationsCollection
        .where('acknowledged', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PendingDeviceRegistration.fromFirestore(doc))
            .toList())
        .map((registrations) {
          // Sort locally instead of using orderBy
          registrations.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return 1;
            if (b.createdAt == null) return -1;
            return b.createdAt!.compareTo(a.createdAt!);
          });
          return registrations;
        });
  }

  // Get all members
  Stream<List<Member>> getAllMembers() {
    return _membersCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Member.fromFirestore(doc))
            .toList());
  }

  // Get member by document ID
  Future<Member?> getMember(String memberDocId) async {
    try {
      final doc = await _membersCollection.doc(memberDocId).get();
      if (doc.exists) {
        return Member.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting member: $e');
      return null;
    }
  }

  // Find member by phone number
  Future<Member?> findMemberByPhone(String phoneNumber) async {
    try {
      final querySnapshot = await _membersCollection
          .where('phone_number', isEqualTo: phoneNumber.trim())
          .limit(1)
          .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        return Member.fromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error finding member by phone: $e');
      return null;
    }
  }

  // Find members by name (partial match)
  Future<List<Member>> findMembersByName(String name) async {
    try {
      // Search for members whose name contains the search term
      final querySnapshot = await _membersCollection
          .where('member_name', isGreaterThanOrEqualTo: name.trim())
          .where('member_name', isLessThanOrEqualTo: name.trim() + '\uf8ff')
          .limit(10)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Member.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error finding members by name: $e');
      return [];
    }
  }

  // Search members by both name and phone
  Future<List<Member>> searchMembers(String query) async {
    try {
      final results = <Member>[];
      
      // First try exact phone match
      final phoneResult = await findMemberByPhone(query);
      if (phoneResult != null) {
        results.add(phoneResult);
      }
      
      // Then try name search
      final nameResults = await findMembersByName(query);
      for (final member in nameResults) {
        if (!results.any((m) => m.memberDocId == member.memberDocId)) {
          results.add(member);
        }
      }
      
      return results;
    } catch (e) {
      print('Error searching members: $e');
      return [];
    }
  }

  // Get member by document ID (alias for getMember)
  Future<Member?> getMemberById(String memberDocId) async {
    return getMember(memberDocId);
  }

  // Request member deletion (requires admin approval)
  Future<bool> requestMemberDeletion({
    required String memberDocId,
    required String memberEmail,
    required String memberName,
    required String requestedBy,
    required String requestedByEmail,
    String? reason,
  }) async {
    try {
      // Check if there's already a pending request for this member
      final existingRequests = await _memberDeletionRequestsCollection
          .where('member_doc_id', isEqualTo: memberDocId)
          .where('is_approved', isEqualTo: false)
          .where('is_rejected', isEqualTo: false)
          .get();

      if (existingRequests.docs.isNotEmpty) {
        print('Member deletion request already exists for member: $memberDocId');
        return false;
      }

      await _memberDeletionRequestsCollection.add({
        'member_doc_id': memberDocId,
        'member_email': memberEmail,
        'member_name': memberName,
        'requested_by': requestedBy,
        'requested_by_email': requestedByEmail,
        'reason': reason,
        'is_approved': false,
        'is_rejected': false,
        'created_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error requesting member deletion: $e');
      return false;
    }
  }

  // Get pending member deletion requests (admin only)
  Stream<List<MemberDeletionRequest>> getPendingMemberDeletionRequests() {
    return _memberDeletionRequestsCollection
        .where('is_approved', isEqualTo: false)
        .where('is_rejected', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MemberDeletionRequest.fromFirestore(doc))
            .toList())
        .map((requests) {
          // Sort locally instead of using orderBy
          requests.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return 1;
            if (b.createdAt == null) return -1;
            return b.createdAt!.compareTo(a.createdAt!);
          });
          return requests;
        });
  }

  // Approve member deletion (admin only)
  Future<bool> approveMemberDeletion(String requestId, String reviewedBy) async {
    try {
      // Get the request
      final requestDoc = await _memberDeletionRequestsCollection.doc(requestId).get();
      if (!requestDoc.exists) {
        return false;
      }

      final request = MemberDeletionRequest.fromFirestore(requestDoc);

      // Update the request
      await _memberDeletionRequestsCollection.doc(requestId).update({
        'is_approved': true,
        'reviewed_at': FieldValue.serverTimestamp(),
        'reviewed_by': reviewedBy,
      });

      // Delete the member
      await _membersCollection.doc(request.memberDocId).delete();

      return true;
    } catch (e) {
      print('Error approving member deletion: $e');
      return false;
    }
  }

  // Reject member deletion (admin only)
  Future<bool> rejectMemberDeletion(String requestId, String reviewedBy, String reason) async {
    try {
      await _memberDeletionRequestsCollection.doc(requestId).update({
        'is_rejected': true,
        'reviewed_at': FieldValue.serverTimestamp(),
        'reviewed_by': reviewedBy,
        'rejection_reason': reason,
      });
      return true;
    } catch (e) {
      print('Error rejecting member deletion: $e');
      return false;
    }
  }

  // Delete member directly (admin only)
  Future<bool> deleteMemberDirectly(String memberDocId, {String? performedBy, String? performedByEmail, String? reason}) async {
    try {
      // Get current member data for history
      final memberDoc = await _membersCollection.doc(memberDocId).get();
      final memberData = memberDoc.data() as Map<String, dynamic>;
      final memberName = memberData['member_name'] as String? ?? 'Unknown';
      final phoneNumber = memberData['phone_number'] as String? ?? 'Unknown';

      await _membersCollection.doc(memberDocId).delete();

      // Add history record
      await addMemberHistory(
        memberDocId: memberDocId,
        action: MemberHistory.ACTION_MEMBER_DELETED,
        oldValue: 'Member existed: $memberName ($phoneNumber)',
        newValue: 'Member deleted',
        performedBy: performedBy ?? 'system',
        performedByEmail: performedByEmail,
        reason: reason ?? 'Member deleted by admin',
      );

      return true;
    } catch (e) {
      print('Error deleting member directly: $e');
      return false;
    }
  }

  // Create sample member history records for testing
  Future<bool> createSampleHistoryRecords(String memberDocId) async {
    try {
      final now = DateTime.now();
      
      // Sample history records
      final records = [
        {
          'action': MemberHistory.ACTION_STATUS_CHANGED,
          'old_value': 'pending',
          'new_value': 'active',
          'field_name': 'membership_status',
          'performed_by': 'admin',
          'performed_by_email': 'admin@gym.com',
          'reason': 'Member activated after registration',
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 30))),
        },
        {
          'action': MemberHistory.ACTION_SUBSCRIPTION_RENEWED,
          'old_value': '2024-01-01',
          'new_value': '2024-04-01',
          'field_name': 'subscription_expiry_date',
          'performed_by': 'admin',
          'performed_by_email': 'admin@gym.com',
          'reason': 'Subscription renewed for 3 months',
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 15))),
        },
        {
          'action': MemberHistory.ACTION_MEMBER_EDITED,
          'old_value': 'Old Name',
          'new_value': 'New Name',
          'field_name': 'member_name',
          'performed_by': 'admin',
          'performed_by_email': 'admin@gym.com',
          'reason': 'Name correction requested',
          'timestamp': Timestamp.fromDate(now.subtract(const Duration(days: 7))),
        },
      ];

      for (final record in records) {
        await _memberHistoryCollection.add({
          'member_doc_id': memberDocId,
          ...record,
        });
      }

      print('Sample history records created for member: $memberDocId');
      return true;
    } catch (e) {
      print('Error creating sample history records: $e');
      return false;
    }
  }

  // Activate member
  Future<bool> activateMember({
    required String memberDocId,
    required String phoneNumber,
    required String memberName,
    required DateTime subscriptionStartDate,
    required DateTime subscriptionExpiryDate,
    String? performedBy,
    String? performedByEmail,
  }) async {
    try {
      // Check if member document exists
      final memberDoc = await _membersCollection.doc(memberDocId).get();
      if (!memberDoc.exists) {
        print('Member document does not exist: $memberDocId');
        return false;
      }

      // Get current member data for history
      final currentData = memberDoc.data() as Map<String, dynamic>;
      final currentStatus = currentData['membership_status'] as String? ?? 'unknown';
      final currentExpiry = currentData['subscription_expiry_date'] as Timestamp?;

      // Update member document
      await _membersCollection.doc(memberDocId).update({
        'membership_status': 'active',
        'phone_number': phoneNumber,
        'member_name': memberName,
        'subscription_start_date': Timestamp.fromDate(subscriptionStartDate),
        'subscription_expiry_date': Timestamp.fromDate(subscriptionExpiryDate),
        'updated_at': FieldValue.serverTimestamp(),
      });

      print('Member updated successfully: $memberDocId');

      // Add history records
      if (currentStatus != 'active') {
        await addMemberHistory(
          memberDocId: memberDocId,
          action: MemberHistory.ACTION_STATUS_CHANGED,
          oldValue: currentStatus,
          newValue: 'active',
          performedBy: performedBy ?? 'system',
          performedByEmail: performedByEmail,
          reason: 'Member activated',
        );
      }

      if (currentExpiry?.toDate() != subscriptionExpiryDate) {
        await addMemberHistory(
          memberDocId: memberDocId,
          action: MemberHistory.ACTION_SUBSCRIPTION_RENEWED,
          oldValue: currentExpiry?.toDate().toString() ?? 'none',
          newValue: subscriptionExpiryDate.toString(),
          fieldName: 'subscription_expiry_date',
          performedBy: performedBy ?? 'system',
          performedByEmail: performedByEmail,
          reason: 'Subscription renewed during activation',
        );
      }

      // Find and acknowledge the pending registration
      final pendingQuery = await _pendingRegistrationsCollection
          .where('member_doc_id', isEqualTo: memberDocId)
          .where('acknowledged', isEqualTo: false)
          .get();

      for (final doc in pendingQuery.docs) {
        await doc.reference.update({'acknowledged': true});
        print('Pending registration acknowledged: ${doc.id}');
      }

      return true;
    } catch (e) {
      print('Error activating member: $e');
      return false;
    }
  }

  // Deactivate member
  Future<bool> deactivateMember(String memberDocId, {String? performedBy, String? performedByEmail, String? reason}) async {
    try {
      // Get current member data for history
      final memberDoc = await _membersCollection.doc(memberDocId).get();
      final currentData = memberDoc.data() as Map<String, dynamic>;
      final currentStatus = currentData['membership_status'] as String? ?? 'unknown';

      await _membersCollection.doc(memberDocId).update({
        'membership_status': 'inactive',
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Add history record
      if (currentStatus != 'inactive') {
        await addMemberHistory(
          memberDocId: memberDocId,
          action: MemberHistory.ACTION_STATUS_CHANGED,
          oldValue: currentStatus,
          newValue: 'inactive',
          performedBy: performedBy ?? 'system',
          performedByEmail: performedByEmail,
          reason: reason ?? 'Member deactivated',
        );
      }

      return true;
    } catch (e) {
      print('Error deactivating member: $e');
      return false;
    }
  }

  // Update member subscription dates (both start and expiry)
  Future<bool> updateSubscriptionDates({
    required String memberDocId,
    DateTime? newStartDate,
    DateTime? newExpiryDate,
    String? performedBy,
    String? performedByEmail,
    String? reason,
  }) async {
    try {
      // Get current member data for history
      final memberDoc = await _membersCollection.doc(memberDocId).get();
      final currentData = memberDoc.data() as Map<String, dynamic>;
      final currentStart = currentData['subscription_start_date'] as Timestamp?;
      final currentExpiry = currentData['subscription_expiry_date'] as Timestamp?;

      // Prepare update data
      final updateData = <String, dynamic>{
        'updated_at': FieldValue.serverTimestamp(),
        'membership_status': 'active'
      };

      if (newStartDate != null) {
        updateData['subscription_start_date'] = Timestamp.fromDate(newStartDate);
      }
      if (newExpiryDate != null) {
        updateData['subscription_expiry_date'] = Timestamp.fromDate(newExpiryDate);
      }

      await _membersCollection.doc(memberDocId).update(updateData);

      // Add history records for changes
      if (newStartDate != null && currentStart?.toDate() != newStartDate) {
        await addMemberHistory(
          memberDocId: memberDocId,
          action: MemberHistory.ACTION_MEMBER_EDITED,
          oldValue: currentStart?.toDate().toString() ?? 'none',
          newValue: newStartDate.toString(),
          fieldName: 'subscription_start_date',
          performedBy: performedBy ?? 'system',
          performedByEmail: performedByEmail,
          reason: reason ?? 'Subscription start date updated',
        );
      }

      if (newExpiryDate != null && currentExpiry?.toDate() != newExpiryDate) {
        await addMemberHistory(
          memberDocId: memberDocId,
          action: MemberHistory.ACTION_SUBSCRIPTION_RENEWED,
          oldValue: currentExpiry?.toDate().toString() ?? 'none',
          newValue: newExpiryDate.toString(),
          fieldName: 'subscription_expiry_date',
          performedBy: performedBy ?? 'system',
          performedByEmail: performedByEmail,
          reason: reason ?? 'Subscription expiry date updated',
        );
      }

      return true;
    } catch (e) {
      print('Error updating subscription dates: $e');
      return false;
    }
  }

  // Update member subscription expiry (legacy method for backward compatibility)
  Future<bool> updateSubscriptionExpiry({
    required String memberDocId,
    required DateTime newExpiryDate,
    String? performedBy,
    String? performedByEmail,
    String? reason,
  }) async {
    return updateSubscriptionDates(
      memberDocId: memberDocId,
      newExpiryDate: newExpiryDate,
      performedBy: performedBy,
      performedByEmail: performedByEmail,
      reason: reason,
    );
  }

  // Get today's check-ins
  Stream<List<CheckIn>> getTodayCheckIns() {
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    
    return _checkinsCollection
        .where('checkin_date', isEqualTo: todayString)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CheckIn.fromFirestore(doc))
            .toList())
        .asyncMap((checkins) async {
          // Populate member names for check-ins that don't have them
          final updatedCheckins = <CheckIn>[];
          for (final checkin in checkins) {
            if (checkin.memberName == null && checkin.memberDocId != null) {
              // Fetch member data to get the name
              final memberDoc = await _membersCollection.doc(checkin.memberDocId!).get();
              if (memberDoc.exists) {
                final memberData = memberDoc.data() as Map<String, dynamic>;
                final memberName = memberData['member_name'] as String?;
                if (memberName != null && memberName.isNotEmpty) {
                  updatedCheckins.add(checkin.copyWith(memberName: memberName));
                  continue;
                }
              }
            }
            updatedCheckins.add(checkin);
          }
          
          // Sort locally instead of using orderBy
          updatedCheckins.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return updatedCheckins;
        });
  }

  // Get check-ins by specific date
  Stream<List<CheckIn>> getCheckInsByDate(DateTime date) {
    final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    return _checkinsCollection
        .where('checkin_date', isEqualTo: dateString)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CheckIn.fromFirestore(doc))
            .toList())
        .asyncMap((checkins) async {
          // Populate member names for check-ins that don't have them
          final updatedCheckins = <CheckIn>[];
          for (final checkin in checkins) {
            if (checkin.memberName == null && checkin.memberDocId != null) {
              // Fetch member data to get the name
              final memberDoc = await _membersCollection.doc(checkin.memberDocId!).get();
              if (memberDoc.exists) {
                final memberData = memberDoc.data() as Map<String, dynamic>;
                final memberName = memberData['member_name'] as String?;
                if (memberName != null && memberName.isNotEmpty) {
                  updatedCheckins.add(checkin.copyWith(memberName: memberName));
                  continue;
                }
              }
            }
            updatedCheckins.add(checkin);
          }
          
          // Sort locally instead of using orderBy
          updatedCheckins.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return updatedCheckins;
        });
  }

  // Get expired check-in attempts
  Stream<List<ExpiredCheckInAttempt>> getExpiredAttempts() {
    return _expiredAttemptsCollection
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ExpiredCheckInAttempt.fromFirestore(doc))
            .toList())
        .asyncMap((expiredAttempts) async {
          // Populate member names for expired attempts that don't have them
          final updatedAttempts = <ExpiredCheckInAttempt>[];
          for (final attempt in expiredAttempts) {
            if (attempt.memberName == null && attempt.memberDocId != null) {
              // Fetch member data to get the name
              final memberDoc = await _membersCollection.doc(attempt.memberDocId!).get();
              if (memberDoc.exists) {
                final memberData = memberDoc.data() as Map<String, dynamic>;
                final memberName = memberData['member_name'] as String?;
                if (memberName != null && memberName.isNotEmpty) {
                  updatedAttempts.add(attempt.copyWith(memberName: memberName));
                  continue;
                }
              }
            }
            updatedAttempts.add(attempt);
          }
          
          // Sort locally instead of using orderBy
          updatedAttempts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return updatedAttempts;
        });
  }

  // Add member history record
  Future<bool> addMemberHistory({
    required String memberDocId,
    required String action,
    required String oldValue,
    required String newValue,
    String? fieldName,
    required String performedBy,
    String? performedByEmail,
    String? reason,
  }) async {
    try {
      await _memberHistoryCollection.add({
        'member_doc_id': memberDocId,
        'action': action,
        'old_value': oldValue,
        'new_value': newValue,
        'field_name': fieldName,
        'performed_by': performedBy,
        'performed_by_email': performedByEmail,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error adding member history: $e');
      return false;
    }
  }

  // Get member history
  Stream<List<MemberHistory>> getMemberHistory(String memberDocId) {
    if (memberDocId.isEmpty) {
      // Return empty stream if memberDocId is invalid
      return Stream.value([]);
    }

    return _memberHistoryCollection
        .where('member_doc_id', isEqualTo: memberDocId)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .handleError((error) {
      print('Error in getMemberHistory stream: $error');
      // Return empty list on error to prevent crashes
    }).map((snapshot) {
      try {
        return snapshot.docs
            .map((doc) => MemberHistory.fromFirestore(doc))
            .toList();
      } catch (e) {
        print('Error parsing member history documents: $e');
        return <MemberHistory>[];
      }
    });
  }

  // Get member statistics
  Future<Map<String, int>> getMemberStats() async {
    try {
      final membersSnapshot = await _membersCollection.get();
      final pendingSnapshot = await _pendingRegistrationsCollection
          .where('acknowledged', isEqualTo: false)
          .get();
      
      int activeCount = 0;
      int pendingCount = 0;
      int inactiveCount = 0;
      int expiredCount = 0;
      
      for (final doc in membersSnapshot.docs) {
        final member = Member.fromFirestore(doc);
        if (member.isActive) {
          activeCount++;
        } else if (member.isPending) {
          pendingCount++;
        } else if (member.isInactive) {
          inactiveCount++;
        }
          // Check if subscription is expired
          if (member.subscriptionExpiryDate != null) {
            final expiryDate = member.subscriptionExpiryDate!.toDate();
            if (expiryDate.isBefore(DateTime.now())) {
              expiredCount++;
            }
          }
        
      }

      return {
        'total': activeCount + pendingCount + inactiveCount,
        'active': activeCount,
        'pending': pendingCount,
        'inactive': inactiveCount,
        'expired': expiredCount,
        'pending_registrations': pendingSnapshot.docs.length,
      };
    } catch (e) {
      print('Error getting member stats: $e');
      return {
        'total': 0,
        'active': 0,
        'pending': 0,
        'inactive': 0,
        'expired': 0,
        'pending_registrations': 0,
      };
    }
  }

  // Update user password
  Future<bool> updateUserPassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // In a real implementation, you would verify current password first
      // For now, we'll just update the password
      await _firestore.collection('admin_users').doc(userId).update({
        'password': newPassword, // In production, this should be hashed
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating user password: $e');
      return false;
    }
  }

  // Update user email
  Future<bool> updateUserEmail({
    required String userId,
    required String newEmail,
    required String password,
  }) async {
    try {
      // In a real implementation, you would verify password first
      // For now, we'll just update the email
      await _firestore.collection('admin_users').doc(userId).update({
        'email': newEmail.toLowerCase(),
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating user email: $e');
      return false;
    }
  }

  // Get current user data
  Future<Map<String, dynamic>?> getCurrentUserData(String userId) async {
    try {
      final doc = await _firestore.collection('admin_users').doc(userId).get();
      return doc.exists ? doc.data() as Map<String, dynamic> : null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  // Sanitize device ID for Firestore document ID
  String sanitizeDeviceId(String deviceId) {
    return deviceId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }
}
