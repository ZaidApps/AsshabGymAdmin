import 'package:cloud_firestore/cloud_firestore.dart';

class Member {
  final String? deviceId;
  final String? memberDocId;
  final String? phoneNumber;
  final String? memberName;
  final String membershipStatus;
  final Timestamp? subscriptionStartDate;
  final Timestamp? subscriptionExpiryDate;
  final double? subscriptionAmount;
  final double? paidAmount;
  final double? remainingBalance;
  final bool isFrozen;
  final Timestamp? frozenAt;
  final int? remainingDaysAtFreeze;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  Member({
    this.deviceId,
    this.memberDocId,
    this.phoneNumber,
    this.memberName,
    required this.membershipStatus,
    this.subscriptionStartDate,
    this.subscriptionExpiryDate,
    this.subscriptionAmount,
    this.paidAmount,
    this.remainingBalance,
    this.isFrozen = false,
    this.frozenAt,
    this.remainingDaysAtFreeze,
    this.createdAt,
    this.updatedAt,
  });

  factory Member.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Member(
      deviceId: data['device_id'],
      memberDocId: doc.id,
      phoneNumber: data['phone_number'],
      memberName: data['member_name'],
      membershipStatus: data['membership_status'] ?? 'pending',
      subscriptionStartDate: data['subscription_start_date'],
      subscriptionExpiryDate: data['subscription_expiry_date'],
      subscriptionAmount: data['subscription_amount']?.toDouble(),
      paidAmount: data['paid_amount']?.toDouble(),
      remainingBalance: data['remaining_balance']?.toDouble(),
      isFrozen: data['is_frozen'] ?? false,
      frozenAt: data['frozen_at'],
      remainingDaysAtFreeze: data['remaining_days_at_freeze'],
      createdAt: data['created_at'],
      updatedAt: data['updated_at'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'device_id': deviceId,
      'member_doc_id': memberDocId,
      'phone_number': phoneNumber,
      'member_name': memberName,
      'membership_status': membershipStatus,
      'subscription_start_date': subscriptionStartDate,
      'subscription_expiry_date': subscriptionExpiryDate,
      'subscription_amount': subscriptionAmount,
      'paid_amount': paidAmount,
      'remaining_balance': remainingBalance,
      'is_frozen': isFrozen,
      'frozen_at': frozenAt,
      'remaining_days_at_freeze': remainingDaysAtFreeze,
      'created_at': createdAt ?? FieldValue.serverTimestamp(),
      'updated_at': updatedAt ?? FieldValue.serverTimestamp(),
    };
  }

  bool get isActive => membershipStatus == 'active';
  bool get isPending => membershipStatus == 'pending';
  bool get isInactive => membershipStatus == 'inactive';
  bool get hasValidSubscription {
    if (!isActive || subscriptionExpiryDate == null) return false;
    return DateTime.now().isBefore(subscriptionExpiryDate!.toDate());
  }
  
  bool get isExpired {
    if (!isActive || subscriptionExpiryDate == null) return false;
    return DateTime.now().isAfter(subscriptionExpiryDate!.toDate());
  }

  // Calculate remaining days in subscription
  int? get remainingDays {
    if (subscriptionExpiryDate == null) return null;
    final now = DateTime.now();
    final expiry = subscriptionExpiryDate!.toDate();
    if (now.isAfter(expiry)) return 0;
    return expiry.difference(now).inDays;
  }

  // Payment-related getters
  bool get hasOutstandingBalance {
    if (remainingBalance == null) return false;
    return remainingBalance! > 0;
  }

  bool get hasOverpaid {
    if (remainingBalance == null) return false;
    return remainingBalance! < 0;
  }

  bool get isFullyPaid {
    if (remainingBalance == null) return true;
    return remainingBalance! <= 0;
  }

  String get formattedRemainingBalance {
    if (remainingBalance == null) return '0.00';
    final balance = remainingBalance!.abs();
    return balance.toStringAsFixed(2);
  }

  // Create a copy with updated fields
  Member copyWith({
    String? deviceId,
    String? memberDocId,
    String? phoneNumber,
    String? memberName,
    String? membershipStatus,
    Timestamp? subscriptionStartDate,
    Timestamp? subscriptionExpiryDate,
    double? subscriptionAmount,
    double? paidAmount,
    double? remainingBalance,
    bool? isFrozen,
    Timestamp? frozenAt,
    int? remainingDaysAtFreeze,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return Member(
      deviceId: deviceId ?? this.deviceId,
      memberDocId: memberDocId ?? this.memberDocId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      memberName: memberName ?? this.memberName,
      membershipStatus: membershipStatus ?? this.membershipStatus,
      subscriptionStartDate: subscriptionStartDate ?? this.subscriptionStartDate,
      subscriptionExpiryDate: subscriptionExpiryDate ?? this.subscriptionExpiryDate,
      subscriptionAmount: subscriptionAmount ?? this.subscriptionAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      isFrozen: isFrozen ?? this.isFrozen,
      frozenAt: frozenAt ?? this.frozenAt,
      remainingDaysAtFreeze: remainingDaysAtFreeze ?? this.remainingDaysAtFreeze,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PendingDeviceRegistration {
  final String? deviceId;
  final String? memberDocId;
  final String platform;
  final bool acknowledged;
  final Timestamp? createdAt;
  final String? docId;

  PendingDeviceRegistration({
    this.deviceId,
    this.memberDocId,
    required this.platform,
    required this.acknowledged,
    this.createdAt,
    this.docId,
  });

  factory PendingDeviceRegistration.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PendingDeviceRegistration(
      deviceId: data['device_id'],
      memberDocId: data['member_doc_id'],
      platform: data['platform'] ?? 'unknown',
      acknowledged: data['acknowledged'] ?? false,
      createdAt: data['created_at'],
      docId: doc.id,
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
  final String? memberName;
  final String checkinDate;
  final String checkinTime;
  final String deviceType;
  final Timestamp timestamp;

  CheckIn({
    this.deviceId,
    this.memberDocId,
    this.phoneNumber,
    this.memberName,
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
      memberName: data['member_name'],
      checkinDate: data['checkin_date'],
      checkinTime: data['checkin_time'],
      deviceType: data['device_type'],
      timestamp: data['timestamp'],
    );
  }

  CheckIn copyWith({
    String? deviceId,
    String? memberDocId,
    String? phoneNumber,
    String? memberName,
    String? checkinDate,
    String? checkinTime,
    String? deviceType,
    Timestamp? timestamp,
  }) {
    return CheckIn(
      deviceId: deviceId ?? this.deviceId,
      memberDocId: memberDocId ?? this.memberDocId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      memberName: memberName ?? this.memberName,
      checkinDate: checkinDate ?? this.checkinDate,
      checkinTime: checkinTime ?? this.checkinTime,
      deviceType: deviceType ?? this.deviceType,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class ExpiredCheckInAttempt {
  final String? deviceId;
  final String? memberDocId;
  final String? phoneNumber;
  final String? memberName;
  final String attemptDate;
  final String attemptTime;
  final Timestamp? subscriptionExpiryDate;
  final Timestamp timestamp;

  ExpiredCheckInAttempt({
    this.deviceId,
    this.memberDocId,
    this.phoneNumber,
    this.memberName,
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
      memberName: data['member_name'],
      attemptDate: data['attempt_date'],
      attemptTime: data['attempt_time'],
      subscriptionExpiryDate: data['subscription_expiry_date'],
      timestamp: data['timestamp'],
    );
  }

  ExpiredCheckInAttempt copyWith({
    String? deviceId,
    String? memberDocId,
    String? phoneNumber,
    String? memberName,
    String? attemptDate,
    String? attemptTime,
    Timestamp? subscriptionExpiryDate,
    Timestamp? timestamp,
  }) {
    return ExpiredCheckInAttempt(
      deviceId: deviceId ?? this.deviceId,
      memberDocId: memberDocId ?? this.memberDocId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      memberName: memberName ?? this.memberName,
      attemptDate: attemptDate ?? this.attemptDate,
      attemptTime: attemptTime ?? this.attemptTime,
      subscriptionExpiryDate: subscriptionExpiryDate ?? this.subscriptionExpiryDate,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
