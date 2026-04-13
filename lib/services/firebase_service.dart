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
  Future<bool> deleteMemberDirectly(String memberDocId) async {
    try {
      await _membersCollection.doc(memberDocId).delete();
      return true;
    } catch (e) {
      print('Error deleting member directly: $e');
      return false;
    }
  }

  // Activate member
  Future<bool> activateMember({
    required String memberDocId,
    required String phoneNumber,
    required DateTime subscriptionStartDate,
    required DateTime subscriptionExpiryDate,
  }) async {
    try {
      // Check if member document exists
      final memberDoc = await _membersCollection.doc(memberDocId).get();
      if (!memberDoc.exists) {
        print('Member document does not exist: $memberDocId');
        return false;
      }

      // Update member document
      await _membersCollection.doc(memberDocId).update({
        'membership_status': 'active',
        'phone_number': phoneNumber,
        'subscription_start_date': Timestamp.fromDate(subscriptionStartDate),
        'subscription_expiry_date': Timestamp.fromDate(subscriptionExpiryDate),
        'updated_at': FieldValue.serverTimestamp(),
      });

      print('Member updated successfully: $memberDocId');

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
  Future<bool> deactivateMember(String memberDocId) async {
    try {
      await _membersCollection.doc(memberDocId).update({
        'membership_status': 'inactive',
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error deactivating member: $e');
      return false;
    }
  }

  // Update member subscription expiry
  Future<bool> updateSubscriptionExpiry({
    required String memberDocId,
    required DateTime newExpiryDate,
  }) async {
    try {
      await _membersCollection.doc(memberDocId).update({
        'subscription_expiry_date': Timestamp.fromDate(newExpiryDate),
        'updated_at': FieldValue.serverTimestamp(),
        'membership_status': 'active'
      });
      return true;
    } catch (e) {
      print('Error updating subscription expiry: $e');
      return false;
    }
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
        .map((checkins) {
          // Sort locally instead of using orderBy
          checkins.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return checkins;
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
            .toList());
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
      
      for (final doc in membersSnapshot.docs) {
        final member = Member.fromFirestore(doc);
        if (member.isActive) {
          activeCount++;
        } else {
          pendingCount++;
        }
      }

      return {
        'active': activeCount,
        'pending': pendingCount,
        'pending_registrations': pendingSnapshot.docs.length,
      };
    } catch (e) {
      print('Error getting member stats: $e');
      return {
        'active': 0,
        'pending': 0,
        'pending_registrations': 0,
      };
    }
  }

  // Sanitize device ID for Firestore document ID
  String sanitizeDeviceId(String deviceId) {
    return deviceId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
  }
}
