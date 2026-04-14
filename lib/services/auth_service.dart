import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_user.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AdminUser? _currentUser;
  
  // Singleton instance
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  
  AuthService._internal();
  
  AdminUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isAdmin {
    final user = _currentUser;
    if (user == null) {
      print('🔍 isAdmin check: currentUser is null');
      return false;
    }
    print('🔍 isAdmin check: ${user.email}, role: ${user.role.name}');
    return user.isAdmin;
  }

  // Login user with email and password
  Future<AdminUser?> login(String email, String password) async {
    try {
      // For now, we'll use a simple authentication system
      // In production, you should use Firebase Auth
      final userDoc = await _firestore
          .collection('admin_users')
          .where('email', isEqualTo: email.toLowerCase())
          .where('is_active', isEqualTo: true)
          .limit(1)
          .get();

      if (userDoc.docs.isEmpty) {
        return null;
      }

      final user = AdminUser.fromFirestore(userDoc.docs.first);
      
      // Simple password validation (in production, use proper hashing)
      if (_validatePassword(email, password)) {
        // Update last login
        await _firestore.collection('admin_users').doc(user.userId).update({
          'last_login_at': FieldValue.serverTimestamp(),
        });
        
        _currentUser = user.copyWith(lastLoginAt: Timestamp.now());
        return _currentUser;
      }
      
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  // Simple password validation (for demo purposes)
  bool _validatePassword(String email, String password) {
    // For demo: password is email without domain + "123"
    // e.g., user@domain.com -> user123
    final emailPrefix = email.split('@')[0];
    return password == '${emailPrefix}123';
  }

  // Logout user
  void logout() {
    _currentUser = null;
  }

  // Create new user (admin only)
  Future<bool> createUser({
    required String email,
    required String displayName,
    required UserRole role,
    required String createdBy,
  }) async {
    try {
      // Check if user already exists
      final existingUser = await _firestore
          .collection('admin_users')
          .where('email', isEqualTo: email.toLowerCase())
          .get();

      if (existingUser.docs.isNotEmpty) {
        return false; // User already exists
      }

      // Create new user
      await _firestore.collection('admin_users').add({
        'email': email.toLowerCase(),
        'display_name': displayName,
        'role': role.value,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
        'created_by': createdBy,
      });

      return true;
    } catch (e) {
      print('Error creating user: $e');
      return false;
    }
  }

  // Get all users (admin only)
  Stream<List<AdminUser>> getAllUsers() {
    return _firestore
        .collection('admin_users')
        .snapshots()
        .map((snapshot) {
          print('🔍 Admin users query result: ${snapshot.docs.length} documents found');
          return snapshot.docs
              .map((doc) => AdminUser.fromFirestore(doc))
              .toList();
        })
        .map((users) {
          // Sort locally instead of using orderBy to avoid index requirement
          users.sort((a, b) {
            if (a.createdAt == null && b.createdAt == null) return 0;
            if (a.createdAt == null) return 1;
            if (b.createdAt == null) return -1;
            return b.createdAt!.compareTo(a.createdAt!);
          });
          print('👥 Sorted users: ${users.map((u) => u.email).toList()}');
          return users;
        });
  }

  // Update user status (activate/deactivate)
  Future<bool> updateUserStatus(String userId, bool isActive) async {
    try {
      await _firestore.collection('admin_users').doc(userId).update({
        'is_active': isActive,
        'updated_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error updating user status: $e');
      return false;
    }
  }

  // Delete user directly (admin only, for users they created)
  Future<bool> deleteUserDirectly(String userId) async {
    try {
      await _firestore.collection('admin_users').doc(userId).delete();
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }

  // Request user deletion (requires admin approval)
  Future<bool> requestUserDeletion({
    required String targetUserId,
    required String targetUserEmail,
    required String requestedBy,
    required String requestedByEmail,
    String? reason,
  }) async {
    try {
      await _firestore.collection('user_deletion_requests').add({
        'target_user_id': targetUserId,
        'target_user_email': targetUserEmail,
        'requested_by': requestedBy,
        'requested_by_email': requestedByEmail,
        'reason': reason,
        'is_approved': false,
        'is_rejected': false,
        'created_at': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error requesting user deletion: $e');
      return false;
    }
  }

  // Get pending deletion requests (admin only)
  Stream<List<UserDeletionRequest>> getPendingDeletionRequests() {
    return _firestore
        .collection('user_deletion_requests')
        .where('is_approved', isEqualTo: false)
        .where('is_rejected', isEqualTo: false)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => UserDeletionRequest.fromFirestore(doc))
            .toList());
  }

  // Approve user deletion (admin only)
  Future<bool> approveUserDeletion(String requestId, String reviewedBy) async {
    try {
      // Get the request
      final requestDoc = await _firestore
          .collection('user_deletion_requests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) {
        return false;
      }

      final request = UserDeletionRequest.fromFirestore(requestDoc);

      // Update the request
      await _firestore.collection('user_deletion_requests').doc(requestId).update({
        'is_approved': true,
        'reviewed_at': FieldValue.serverTimestamp(),
        'reviewed_by': reviewedBy,
      });

      // Delete the user
      await _firestore.collection('admin_users').doc(request.targetUserId).delete();

      return true;
    } catch (e) {
      print('Error approving user deletion: $e');
      return false;
    }
  }

  // Reject user deletion (admin only)
  Future<bool> rejectUserDeletion(String requestId, String reviewedBy, String reason) async {
    try {
      await _firestore.collection('user_deletion_requests').doc(requestId).update({
        'is_rejected': true,
        'reviewed_at': FieldValue.serverTimestamp(),
        'reviewed_by': reviewedBy,
        'rejection_reason': reason,
      });
      return true;
    } catch (e) {
      print('Error rejecting user deletion: $e');
      return false;
    }
  }

  // Update current user
  void setCurrentUser(AdminUser user) {
    _currentUser = user;
    print('🔐 User logged in: ${user.email}, role: ${user.role.name}');
  }
}
