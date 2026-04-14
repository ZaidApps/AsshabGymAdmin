import 'package:cloud_firestore/cloud_firestore.dart';

class MemberHistory {
  final String id;
  final String memberDocId;
  final String action;
  final String oldValue;
  final String newValue;
  final String? fieldName;
  final String performedBy;
  final String? performedByEmail;
  final String? reason;
  final Timestamp timestamp;

  MemberHistory({
    required this.id,
    required this.memberDocId,
    required this.action,
    required this.oldValue,
    required this.newValue,
    this.fieldName,
    required this.performedBy,
    this.performedByEmail,
    this.reason,
    required this.timestamp,
  });

  factory MemberHistory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MemberHistory(
      id: doc.id,
      memberDocId: data['member_doc_id'] ?? '',
      action: data['action'] ?? '',
      oldValue: data['old_value'] ?? '',
      newValue: data['new_value'] ?? '',
      fieldName: data['field_name'],
      performedBy: data['performed_by'] ?? '',
      performedByEmail: data['performed_by_email'],
      reason: data['reason'],
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }

  // Action types for member history
  static const String ACTION_STATUS_CHANGED = 'status_changed';
  static const String ACTION_MEMBER_EDITED = 'member_edited';
  static const String ACTION_MEMBER_DELETED = 'member_deleted';
  static const String ACTION_SUBSCRIPTION_RENEWED = 'subscription_renewed';
  static const String ACTION_SUBSCRIPTION_EXPIRED = 'subscription_expired';
  static const String ACTION_DEVICE_ADDED = 'device_added';
  static const String ACTION_DEVICE_REMOVED = 'device_removed';
  static const String ACTION_DEVICE_DELETED = 'device_deleted';
}
