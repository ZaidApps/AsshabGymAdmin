import 'package:asshab_gym_web_admin/models/member_history.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/member.dart';
import '../models/admin_user.dart';
import '../models/offer.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Members collection
  CollectionReference get _membersCollection => _firestore.collection('members');
  CollectionReference get _pendingRegistrationsCollection => _firestore.collection('pending_device_registrations');
  CollectionReference get _checkinsCollection => _firestore.collection('checkins');
  CollectionReference get _expiredAttemptsCollection => _firestore.collection('expired_checkin_attempts');
  CollectionReference get _memberDeletionRequestsCollection => _firestore.collection('member_deletion_requests');
  CollectionReference get _memberHistoryCollection => _firestore.collection('member_history');
  CollectionReference get _offersCollection => _firestore.collection('offers');

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

  // Find members by name (partial match, case-insensitive)
  Future<List<Member>> findMembersByName(String name) async {
    try {
      // Fetch all members and filter client-side for case-insensitive search
      final querySnapshot = await _membersCollection.limit(50).get();
      final allMembers = querySnapshot.docs
          .map((doc) => Member.fromFirestore(doc))
          .toList();
      
      final searchName = name.trim().toLowerCase();
      final filteredMembers = allMembers.where((member) {
        final memberName = member.memberName?.toLowerCase() ?? '';
        return memberName.contains(searchName);
      }).take(10).toList();
      
      return filteredMembers;
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
    required double subscriptionAmount,
    required double paidAmount,
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

      // Calculate remaining balance
      final remainingBalance = subscriptionAmount - paidAmount;

      // Update member document
      await _membersCollection.doc(memberDocId).update({
        'membership_status': 'active',
        'phone_number': phoneNumber,
        'member_name': memberName,
        'subscription_start_date': Timestamp.fromDate(subscriptionStartDate),
        'subscription_expiry_date': Timestamp.fromDate(subscriptionExpiryDate),
        'subscription_amount': subscriptionAmount,
        'paid_amount': paidAmount,
        'remaining_balance': remainingBalance,
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

      // Add payment history record
      await addMemberHistory(
        memberDocId: memberDocId,
        action: 'payment_received',
        oldValue: 'No payment',
        newValue: 'Payment received: \$${paidAmount.toStringAsFixed(2)}',
        performedBy: performedBy ?? 'system',
        performedByEmail: performedByEmail,
        reason: 'Initial payment during activation',
      );

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
    double? newSubscriptionAmount,
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
      final currentAmount = currentData['subscription_amount'] as double?;

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
      if (newSubscriptionAmount != null) {
        updateData['subscription_amount'] = newSubscriptionAmount;
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

      if (newSubscriptionAmount != null && currentAmount != newSubscriptionAmount) {
        await addMemberHistory(
          memberDocId: memberDocId,
          action: MemberHistory.ACTION_MEMBER_EDITED,
          oldValue: currentAmount?.toString() ?? 'none',
          newValue: newSubscriptionAmount.toString(),
          fieldName: 'subscription_amount',
          performedBy: performedBy ?? 'system',
          performedByEmail: performedByEmail,
          reason: reason ?? 'Subscription amount updated',
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

  // Delete pending device registration (reject device)
  Future<bool> deletePendingDeviceRegistration(String deviceDocId, {String? performedBy, String? performedByEmail, String? reason}) async {
    try {
      // Get the pending device data before deletion for history
      final deviceDoc = await _pendingRegistrationsCollection.doc(deviceDocId).get();
      if (!deviceDoc.exists) {
        print('Pending device registration not found');
        return false;
      }

      final deviceData = deviceDoc.data() as Map<String, dynamic>;
      final deviceId = deviceData['device_id'] as String? ?? 'Unknown';
      final platform = deviceData['platform'] as String? ?? 'Unknown';

      // Delete the pending device registration
      await _pendingRegistrationsCollection.doc(deviceDocId).delete();

      // Add history record for the rejection
      await addMemberHistory(
        memberDocId: deviceDocId,
        action: 'device_registration_rejected',
        oldValue: 'Pending device registration: $deviceId ($platform)',
        newValue: 'Device registration rejected and deleted',
        performedBy: performedBy ?? 'admin',
        performedByEmail: performedByEmail,
        reason: reason ?? 'Device registration rejected by admin',
      );

      print('Pending device registration deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting pending device registration: $e');
      return false;
    }
  }

  // Sanitize device ID for Firestore document ID
  String sanitizeDeviceId(String deviceId) {
    return deviceId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }

  // ==================== MANUAL MEMBER REGISTRATION ====================

  // Generate unique ID for manual registration
  String generateUniqueId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return 'manual_${timestamp}_$random';
  }

  // Register a new member manually
  Future<String?> registerMemberManually({
    required String memberName,
    required String phoneNumber,
    required DateTime subscriptionStartDate,
    required DateTime subscriptionExpiryDate,
    required double subscriptionAmount,
    String? performedBy,
    String? performedByEmail,
  }) async {
    try {
      final uniqueId = generateUniqueId();
      final timestamp = Timestamp.now();

      // Create member document
      final memberDoc = await _membersCollection.add({
        'device_id': uniqueId,
        'phone_number': phoneNumber.trim(),
        'member_name': memberName.trim(),
        'membership_status': 'active',
        'subscription_start_date': Timestamp.fromDate(subscriptionStartDate),
        'subscription_expiry_date': Timestamp.fromDate(subscriptionExpiryDate),
        'subscription_amount': subscriptionAmount,
        'is_frozen': false,
        'created_at': timestamp,
        'updated_at': timestamp,
      });

      final memberDocId = memberDoc.id;

      // Add history record
      await addMemberHistory(
        memberDocId: memberDocId,
        action: MemberHistory.ACTION_MEMBER_CREATED,
        oldValue: 'No member',
        newValue: 'Member created manually: $memberName ($phoneNumber)',
        performedBy: performedBy ?? 'admin',
        performedByEmail: performedByEmail,
        reason: 'Member registered manually by admin',
      );

      print('Member registered manually successfully: $memberDocId');
      return memberDocId;
    } catch (e) {
      print('Error registering member manually: $e');
      return null;
    }
  }

  // ==================== MANUAL CHECK-IN ====================

  // Perform manual check-in for a member
  Future<bool> checkInMemberManually({
    required String memberDocId,
    String? performedBy,
    String? performedByEmail,
  }) async {
    try {
      // Get member details
      final memberDoc = await _membersCollection.doc(memberDocId).get();
      if (!memberDoc.exists) {
        print('Member not found: $memberDocId');
        return false;
      }

      final memberData = memberDoc.data() as Map<String, dynamic>;
      final memberName = memberData['member_name'] as String? ?? 'Unknown';
      final phoneNumber = memberData['phone_number'] as String? ?? 'Unknown';
      final deviceId = memberData['device_id'] as String? ?? 'Unknown';
      final membershipStatus = memberData['membership_status'] as String? ?? 'unknown';

      final now = DateTime.now();
      final todayString = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      final timeString = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      // Create check-in record
      await _checkinsCollection.add({
        'device_id': deviceId,
        'member_doc_id': memberDocId,
        'phone_number': phoneNumber,
        'member_name': memberName,
        'checkin_date': todayString,
        'checkin_time': timeString,
        'device_type': 'manual',
        'timestamp': Timestamp.fromDate(now),
      });

      // Add history record
      await addMemberHistory(
        memberDocId: memberDocId,
        action: 'manual_checkin',
        oldValue: 'No check-in recorded for today',
        newValue: 'Manual check-in at $timeString',
        performedBy: performedBy ?? 'admin',
        performedByEmail: performedByEmail,
        reason: 'Manual check-in performed by admin',
      );

      print('Manual check-in successful for member: $memberDocId');
      return true;
    } catch (e) {
      print('Error performing manual check-in: $e');
      return false;
    }
  }

  // Check if member can be checked in (for warning purposes)
  bool canCheckInMember(Member member) {
    // Allow check-in for any status, but return false for warnings
    return member.isActive;
  }

  // ==================== OFFER MANAGEMENT ====================

  // Get all offers
  Stream<List<Offer>> getAllOffers() {
    return _offersCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Offer.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Get active offers only
  Stream<List<Offer>> getActiveOffers() {
    return _offersCollection
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Offer.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
            .toList());
  }

  // Get offer by ID
  Future<Offer?> getOffer(String offerId) async {
    try {
      final doc = await _offersCollection.doc(offerId).get();
      if (!doc.exists) return null;
      return Offer.fromFirestore(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      print('Error getting offer: $e');
      return null;
    }
  }

  // Create new offer
  Future<String?> createOffer({
    required String name,
    required int baseDurationMonths,
    required int additionalDays,
    required double totalAmount,
    required String description,
    String? createdBy,
    String? createdByEmail,
  }) async {
    try {
      final offer = Offer(
        name: name,
        baseDurationMonths: baseDurationMonths,
        additionalDays: additionalDays,
        totalAmount: totalAmount,
        description: description,
        createdAt: DateTime.now(),
        createdBy: createdBy,
        createdByEmail: createdByEmail,
      );

      final docRef = await _offersCollection.add(offer.toFirestore());
      print('Offer created successfully with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('Error creating offer: $e');
      return null;
    }
  }

  // Update offer
  Future<bool> updateOffer({
    required String offerId,
    String? name,
    int? baseDurationMonths,
    int? additionalDays,
    double? totalAmount,
    String? description,
    bool? isActive,
    String? updatedBy,
    String? updatedByEmail,
  }) async {
    try {
      // Get current offer data
      final currentOffer = await getOffer(offerId);
      if (currentOffer == null) {
        print('Offer not found');
        return false;
      }

      final updatedOffer = currentOffer.copyWith(
        name: name,
        baseDurationMonths: baseDurationMonths,
        additionalDays: additionalDays,
        totalAmount: totalAmount,
        description: description,
        isActive: isActive,
        updatedAt: DateTime.now(),
      );

      await _offersCollection.doc(offerId).update(updatedOffer.toFirestore());
      print('Offer updated successfully');
      return true;
    } catch (e) {
      print('Error updating offer: $e');
      return false;
    }
  }

  // Delete offer
  Future<bool> deleteOffer(String offerId) async {
    try {
      await _offersCollection.doc(offerId).delete();
      print('Offer deleted successfully');
      return true;
    } catch (e) {
      print('Error deleting offer: $e');
      return false;
    }
  }

  // Toggle offer active status
  Future<bool> toggleOfferStatus(String offerId, bool isActive) async {
    return await updateOffer(
      offerId: offerId,
      isActive: isActive,
    );
  }

  // ==================== FREEZE/UNFREEZE MEMBER ====================

  // Freeze member subscription
  Future<bool> freezeMember(String memberDocId, {String? performedBy, String? performedByEmail}) async {
    try {
      // Get current member data
      final memberDoc = await _membersCollection.doc(memberDocId).get();
      if (!memberDoc.exists) {
        print('Member not found');
        return false;
      }

      final member = Member.fromFirestore(memberDoc);
      
      // Calculate remaining days before freezing
      final remainingDays = member.remainingDays ?? 0;
      
      // Update member with freeze status
      final updatedMember = member.copyWith(
        isFrozen: true,
        frozenAt: Timestamp.now(),
        remainingDaysAtFreeze: remainingDays,
        updatedAt: Timestamp.now(),
      );

      await _membersCollection.doc(memberDocId).update(updatedMember.toFirestore());

      // Add history record for freeze
      await addMemberHistory(
        memberDocId: memberDocId,
        action: 'subscription_frozen',
        oldValue: 'Active subscription with $remainingDays days remaining',
        newValue: 'Subscription frozen with $remainingDays days saved',
        performedBy: performedBy ?? 'admin',
        performedByEmail: performedByEmail,
        reason: 'Member subscription frozen by admin',
      );

      print('Member subscription frozen successfully');
      return true;
    } catch (e) {
      print('Error freezing member subscription: $e');
      return false;
    }
  }

  // Unfreeze member subscription
  Future<bool> unfreezeMember(String memberDocId, {String? performedBy, String? performedByEmail}) async {
    try {
      // Get current member data
      final memberDoc = await _membersCollection.doc(memberDocId).get();
      if (!memberDoc.exists) {
        print('Member not found');
        return false;
      }

      final member = Member.fromFirestore(memberDoc);
      
      if (!member.isFrozen) {
        print('Member is not frozen');
        return false;
      }

      final remainingDaysAtFreeze = member.remainingDaysAtFreeze ?? 0;
      final now = DateTime.now();
      
      // Calculate new expiry date by adding remaining days to current date
      final newExpiryDate = now.add(Duration(days: remainingDaysAtFreeze));
      
      // Update member with new subscription dates
      final updatedMember = member.copyWith(
        isFrozen: false,
        frozenAt: null,
        remainingDaysAtFreeze: null,
        subscriptionStartDate: Timestamp.fromDate(now),
        subscriptionExpiryDate: Timestamp.fromDate(newExpiryDate),
        updatedAt: Timestamp.now(),
      );

      await _membersCollection.doc(memberDocId).update(updatedMember.toFirestore());

      // Add history record for unfreeze
      await addMemberHistory(
        memberDocId: memberDocId,
        action: 'subscription_unfrozen',
        oldValue: 'Frozen subscription with $remainingDaysAtFreeze days saved',
        newValue: 'Subscription unfrozen, new expiry: ${newExpiryDate.day}/${newExpiryDate.month}/${newExpiryDate.year}',
        performedBy: performedBy ?? 'admin',
        performedByEmail: performedByEmail,
        reason: 'Member subscription unfrozen by admin',
      );

      print('Member subscription unfrozen successfully');
      return true;
    } catch (e) {
      print('Error unfreezing member subscription: $e');
      return false;
    }
  }

  // Get frozen members
  Stream<List<Member>> getFrozenMembers() {
    return _membersCollection
        .where('is_frozen', isEqualTo: true)
        .orderBy('updated_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Member.fromFirestore(doc))
            .toList());
  }

  // Get all check-ins (not just active ones)
  Stream<List<CheckIn>> getAllCheckIns() {
    return _checkinsCollection
        .orderBy('timestamp', descending: true)
        .limit(500) // Limit to prevent excessive data loading
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
          
          // Sort by timestamp (most recent first)
          updatedCheckins.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return updatedCheckins;
        });
  }

  // Get check-ins by date range
  Stream<List<CheckIn>> getCheckInsByDateRange(DateTime startDate, DateTime endDate) {
    final startDateString = '${startDate.year}-${startDate.month.toString().padLeft(2, '0')}-${startDate.day.toString().padLeft(2, '0')}';
    final endDateString = '${endDate.year}-${endDate.month.toString().padLeft(2, '0')}-${endDate.day.toString().padLeft(2, '0')}';
    
    return _checkinsCollection
        .where('checkin_date', isGreaterThanOrEqualTo: startDateString)
        .where('checkin_date', isLessThanOrEqualTo: endDateString)
        .orderBy('timestamp', descending: true)
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
          
          // Sort by timestamp (most recent first)
          updatedCheckins.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return updatedCheckins;
        });
  }

  // Get member by device ID
  Future<Member?> getMemberByDeviceId(String deviceId) async {
    try {
      final snapshot = await _membersCollection
          .where('device_id', isEqualTo: deviceId)
          .limit(1)
          .get();
      
      if (snapshot.docs.isEmpty) {
        return null;
      }
      
      return Member.fromFirestore(snapshot.docs.first);
    } catch (e) {
      print('Error getting member by device ID: $e');
      return null;
    }
  }

  // Gym Hours Configuration
  Future<Map<String, dynamic>?> getGymHoursConfig() async {
    try {
      final doc = await _firestore.collection('settings').doc('gym_hours').get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error getting gym hours config: $e');
      return null;
    }
  }

  Future<void> saveGymHoursConfig({
    required String openingTime,
    required String closingTime,
  }) async {
    try {
      await _firestore.collection('settings').doc('gym_hours').set({
        'openingTime': openingTime,
        'closingTime': closingTime,
        'updatedAt': DateTime.now(),
        'updatedBy': _auth.currentUser?.uid,
      });
    } catch (e) {
      print('Error saving gym hours config: $e');
      rethrow;
    }
  }

  // Get gym day for a given datetime
  Future<String> getGymDay(DateTime dateTime) async {
    final config = await getGymHoursConfig();
    if (config == null) {
      // Default to calendar day if no config
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }

    final openingTime = _parseTime(config['openingTime']);
    final closingTime = _parseTime(config['closingTime']);
    
    final checkInTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
    
    // If closing time is earlier than opening time, it spans to next day
    if (closingTime.hour < openingTime.hour || 
        (closingTime.hour == openingTime.hour && closingTime.minute < openingTime.minute)) {
      
      // If check-in time is after opening time or before closing time
      if (_timeOfDayCompare(checkInTime, openingTime) >= 0 || 
          _timeOfDayCompare(checkInTime, closingTime) <= 0) {
        
        // If check-in time is before opening time, it belongs to previous day's gym day
        if (_timeOfDayCompare(checkInTime, openingTime) < 0) {
          final previousDay = dateTime.subtract(const Duration(days: 1));
          return '${previousDay.year}-${previousDay.month.toString().padLeft(2, '0')}-${previousDay.day.toString().padLeft(2, '0')}';
        } else {
          return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
        }
      }
    } else {
      // Normal same-day schedule
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }
    
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  TimeOfDay _parseTime(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  int _timeOfDayCompare(TimeOfDay a, TimeOfDay b) {
    final aMinutes = a.hour * 60 + a.minute;
    final bMinutes = b.hour * 60 + b.minute;
    return aMinutes.compareTo(bMinutes);
  }

  // Get today's gym day check-ins
  Stream<List<CheckIn>> getTodayGymDayCheckIns() async* {
    final config = await getGymHoursConfig();
    final now = DateTime.now();
    
    if (config == null) {
      // Default to today's check-ins if no config
      yield* getTodayCheckIns();
      return;
    }

    // Calculate the date range for the current gym day
    final openingTime = _parseTime(config['openingTime']);
    final closingTime = _parseTime(config['closingTime']);
    
    DateTime startDate;
    DateTime endDate;
    
    if (_timeOfDayCompare(openingTime, closingTime) <= 0) {
      // Normal same-day schedule
      startDate = DateTime(now.year, now.month, now.day, openingTime.hour, openingTime.minute);
      endDate = DateTime(now.year, now.month, now.day, closingTime.hour, closingTime.minute);
    } else {
      // Cross-day schedule (e.g., 6 PM to 2 AM next day)
      if (TimeOfDay(hour: now.hour, minute: now.minute).hour >= openingTime.hour) {
        // Current time is after opening time, so gym day started today
        startDate = DateTime(now.year, now.month, now.day, openingTime.hour, openingTime.minute);
        endDate = DateTime(now.year, now.month, now.day + 1, closingTime.hour, closingTime.minute);
      } else {
        // Current time is before opening time, so gym day started yesterday
        startDate = DateTime(now.year, now.month, now.day - 1, openingTime.hour, openingTime.minute);
        endDate = DateTime(now.year, now.month, now.day, closingTime.hour, closingTime.minute);
      }
    }
    
    // Get all check-ins in the date range and filter by gym day logic
    yield* _checkinsCollection
        .where('timestamp', isGreaterThanOrEqualTo: startDate)
        .where('timestamp', isLessThanOrEqualTo: endDate)
        .orderBy('timestamp', descending: true)
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

  // Get check-ins by gym day date range
  Stream<List<CheckIn>> getGymDayCheckInsByDateRange(DateTime startDate, DateTime endDate) async* {
    final config = await getGymHoursConfig();
    
    if (config == null) {
      // Default to regular date range if no config
      yield* getCheckInsByDateRange(startDate, endDate);
      return;
    }

    // For date range with gym day logic, we need to expand the range to include potential cross-day schedules
    // We'll get a wider range and filter by gym day logic client-side
    final openingTime = _parseTime(config['openingTime']);
    final closingTime = _parseTime(config['closingTime']);
    
    // Expand the range by 1 day on each side to handle cross-day schedules
    final expandedStartDate = startDate.subtract(const Duration(days: 1));
    final expandedEndDate = endDate.add(const Duration(days: 1));
    
    yield* _checkinsCollection
        .where('timestamp', isGreaterThanOrEqualTo: expandedStartDate)
        .where('timestamp', isLessThanOrEqualTo: expandedEndDate)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CheckIn.fromFirestore(doc))
            .toList())
        .asyncMap((checkins) async {
          // Filter check-ins by gym day logic
          final filteredCheckins = <CheckIn>[];
          for (final checkin in checkins) {
            final checkInGymDay = await getGymDay(checkin.timestamp.toDate());
            final startGymDay = await getGymDay(startDate);
            final endGymDay = await getGymDay(endDate);
            
            if (checkInGymDay.compareTo(startGymDay) >= 0 && checkInGymDay.compareTo(endGymDay) <= 0) {
              // Populate member name if needed
              if (checkin.memberName == null && checkin.memberDocId != null) {
                final memberDoc = await _membersCollection.doc(checkin.memberDocId!).get();
                if (memberDoc.exists) {
                  final memberData = memberDoc.data() as Map<String, dynamic>;
                  final memberName = memberData['member_name'] as String?;
                  if (memberName != null && memberName.isNotEmpty) {
                    filteredCheckins.add(checkin.copyWith(memberName: memberName));
                    continue;
                  }
                }
              }
              filteredCheckins.add(checkin);
            }
          }
          
          // Sort by timestamp (most recent first)
          filteredCheckins.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return filteredCheckins;
        });
  }
}
