import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole {
  admin('admin'),
  user('user');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.user,
    );
  }
}

class AdminUser {
  final String? userId;
  final String email;
  final String displayName;
  final UserRole role;
  final bool isActive;
  final Timestamp? createdAt;
  final Timestamp? lastLoginAt;
  final String? createdBy;

  const AdminUser({
    this.userId,
    required this.email,
    required this.displayName,
    required this.role,
    required this.isActive,
    this.createdAt,
    this.lastLoginAt,
    this.createdBy,
  });

  factory AdminUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AdminUser(
      userId: doc.id,
      email: data['email'] ?? '',
      displayName: data['display_name'] ?? '',
      role: UserRole.fromString(data['role'] ?? 'user'),
      isActive: data['is_active'] ?? true,
      createdAt: data['created_at'],
      lastLoginAt: data['last_login_at'],
      createdBy: data['created_by'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'display_name': displayName,
      'role': role.value,
      'is_active': isActive,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
      'last_login_at': lastLoginAt,
      'created_by': createdBy,
    };
  }

  bool get isAdmin => role == UserRole.admin;
  bool get isRegularUser => role == UserRole.user;

  AdminUser copyWith({
    String? userId,
    String? email,
    String? displayName,
    UserRole? role,
    bool? isActive,
    Timestamp? createdAt,
    Timestamp? lastLoginAt,
    String? createdBy,
  }) {
    return AdminUser(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}

class UserDeletionRequest {
  final String? requestId;
  final String? targetUserId;
  final String? targetUserEmail;
  final String? requestedBy;
  final String? requestedByEmail;
  final String? reason;
  final bool isApproved;
  final bool isRejected;
  final Timestamp? createdAt;
  final Timestamp? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;

  const UserDeletionRequest({
    this.requestId,
    this.targetUserId,
    this.targetUserEmail,
    this.requestedBy,
    this.requestedByEmail,
    this.reason,
    required this.isApproved,
    required this.isRejected,
    this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
  });

  factory UserDeletionRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserDeletionRequest(
      requestId: doc.id,
      targetUserId: data['target_user_id'],
      targetUserEmail: data['target_user_email'],
      requestedBy: data['requested_by'],
      requestedByEmail: data['requested_by_email'],
      reason: data['reason'],
      isApproved: data['is_approved'] ?? false,
      isRejected: data['is_rejected'] ?? false,
      createdAt: data['created_at'],
      reviewedAt: data['reviewed_at'],
      reviewedBy: data['reviewed_by'],
      rejectionReason: data['rejection_reason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'target_user_id': targetUserId,
      'target_user_email': targetUserEmail,
      'requested_by': requestedBy,
      'requested_by_email': requestedByEmail,
      'reason': reason,
      'is_approved': isApproved,
      'is_rejected': isRejected,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
      'reviewed_at': reviewedAt,
      'reviewed_by': reviewedBy,
      'rejection_reason': rejectionReason,
    };
  }

  bool get isPending => !isApproved && !isRejected;
}

class MemberDeletionRequest {
  final String? requestId;
  final String? memberDocId;
  final String? memberEmail;
  final String? memberName;
  final String? requestedBy;
  final String? requestedByEmail;
  final String? reason;
  final bool isApproved;
  final bool isRejected;
  final Timestamp? createdAt;
  final Timestamp? reviewedAt;
  final String? reviewedBy;
  final String? rejectionReason;

  const MemberDeletionRequest({
    this.requestId,
    this.memberDocId,
    this.memberEmail,
    this.memberName,
    this.requestedBy,
    this.requestedByEmail,
    this.reason,
    required this.isApproved,
    required this.isRejected,
    this.createdAt,
    this.reviewedAt,
    this.reviewedBy,
    this.rejectionReason,
  });

  factory MemberDeletionRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MemberDeletionRequest(
      requestId: doc.id,
      memberDocId: data['member_doc_id'],
      memberEmail: data['member_email'],
      memberName: data['member_name'],
      requestedBy: data['requested_by'],
      requestedByEmail: data['requested_by_email'],
      reason: data['reason'],
      isApproved: data['is_approved'] ?? false,
      isRejected: data['is_rejected'] ?? false,
      createdAt: data['created_at'],
      reviewedAt: data['reviewed_at'],
      reviewedBy: data['reviewed_by'],
      rejectionReason: data['rejection_reason'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'member_doc_id': memberDocId,
      'member_email': memberEmail,
      'member_name': memberName,
      'requested_by': requestedBy,
      'requested_by_email': requestedByEmail,
      'reason': reason,
      'is_approved': isApproved,
      'is_rejected': isRejected,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
      'reviewed_at': reviewedAt,
      'reviewed_by': reviewedBy,
      'rejection_reason': rejectionReason,
    };
  }

  bool get isPending => !isApproved && !isRejected;
}
