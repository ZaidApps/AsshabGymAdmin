import 'package:cloud_firestore/cloud_firestore.dart';

class Member {
  final String? deviceId;
  final String? memberDocId;
  final String? phoneNumber;
  final String membershipStatus;
  final Timestamp? subscriptionStartDate;
  final Timestamp? subscriptionExpiryDate;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  Member({
    this.deviceId,
    this.memberDocId,
    this.phoneNumber,
    required this.membershipStatus,
    this.subscriptionStartDate,
    this.subscriptionExpiryDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Member.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Member(
      memberDocId: doc.id,
      deviceId: data['device_id'],
      phoneNumber: data['phone_number'],
      membershipStatus: data['membership_status'] ?? 'pending',
      subscriptionStartDate: data['subscription_start_date'],
      subscriptionExpiryDate: data['subscription_expiry_date'],
      createdAt: data['created_at'],
      updatedAt: data['updated_at'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'device_id': deviceId,
      'phone_number': phoneNumber,
      'membership_status': membershipStatus,
      'subscription_start_date': subscriptionStartDate,
      'subscription_expiry_date': subscriptionExpiryDate,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }

  bool get isActive => membershipStatus == 'active';
  bool get isPending => membershipStatus == 'pending';
  bool get isInactive => membershipStatus == 'inactive';
  bool get hasValidSubscription {
    if (!isActive || subscriptionExpiryDate == null) return false;
    return DateTime.now().isBefore(subscriptionExpiryDate!.toDate());
  }
}

class PendingDeviceRegistration {
  final String? deviceId;
  final String? memberDocId;
  final String platform;
  final bool acknowledged;
  final Timestamp? createdAt;

  PendingDeviceRegistration({
    this.deviceId,
    this.memberDocId,
    required this.platform,
    required this.acknowledged,
    this.createdAt,
  });

  factory PendingDeviceRegistration.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PendingDeviceRegistration(
      deviceId: data['device_id'],
      memberDocId: data['member_doc_id'],
      platform: data['platform'] ?? 'unknown',
      acknowledged: data['acknowledged'] ?? false,
      createdAt: data['created_at'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'device_id': deviceId,
      'member_doc_id': memberDocId,
      'platform': platform,
      'acknowledged': acknowledged,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}

class CheckIn {
  final String? deviceId;
  final String? memberDocId;
  final String? phoneNumber;
  final String checkinDate;
  final String checkinTime;
  final String deviceType;
  final Timestamp timestamp;

  CheckIn({
    this.deviceId,
    this.memberDocId,
    this.phoneNumber,
    required this.checkinDate,
    required this.checkinTime,
    required this.deviceType,
    required this.timestamp,
  });

  factory CheckIn.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CheckIn(
      deviceId: data['device_id'],
      memberDocId: data['member_doc_id'],
      phoneNumber: data['phone_number'],
      checkinDate: data['checkin_date'],
      checkinTime: data['checkin_time'],
      deviceType: data['device_type'],
      timestamp: data['timestamp'],
    );
  }
}

class ExpiredCheckInAttempt {
  final String? deviceId;
  final String? memberDocId;
  final String? phoneNumber;
  final String attemptDate;
  final String attemptTime;
  final Timestamp? subscriptionExpiryDate;
  final Timestamp timestamp;

  ExpiredCheckInAttempt({
    this.deviceId,
    this.memberDocId,
    this.phoneNumber,
    required this.attemptDate,
    required this.attemptTime,
    this.subscriptionExpiryDate,
    required this.timestamp,
  });

  factory ExpiredCheckInAttempt.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ExpiredCheckInAttempt(
      deviceId: data['device_id'],
      memberDocId: data['member_doc_id'],
      phoneNumber: data['phone_number'],
      attemptDate: data['attempt_date'],
      attemptTime: data['attempt_time'],
      subscriptionExpiryDate: data['subscription_expiry_date'],
      timestamp: data['timestamp'],
    );
  }
}
