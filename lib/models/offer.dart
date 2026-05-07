import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

class Offer {
  final String? id;
  final String name;
  final int baseDurationMonths; // 1, 2, 3, or 4 months
  final int additionalDays; // extra days to add
  final double totalAmount;
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? createdBy;
  final String? createdByEmail;

  Offer({
    this.id,
    required this.name,
    required this.baseDurationMonths,
    required this.additionalDays,
    required this.totalAmount,
    required this.description,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.createdByEmail,
  });

  // Calculate total days including additional days
  int get totalDays {
    return (baseDurationMonths * 30) + additionalDays;
  }

  // Calculate expiry date from start date
  DateTime calculateExpiryDate(DateTime startDate) {
    return startDate.add(Duration(days: totalDays));
  }

  // Factory constructor from Firestore document
  factory Offer.fromFirestore(Map<String, dynamic> data, String? documentId) {
    return Offer(
      id: documentId,
      name: data['name'] ?? '',
      baseDurationMonths: data['baseDurationMonths'] ?? 1,
      additionalDays: data['additionalDays'] ?? 0,
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      createdBy: data['createdBy'],
      createdByEmail: data['createdByEmail'],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'baseDurationMonths': baseDurationMonths,
      'additionalDays': additionalDays,
      'totalAmount': totalAmount,
      'description': description,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'createdBy': createdBy,
      'createdByEmail': createdByEmail,
    };
  }

  // Create a copy with updated fields
  Offer copyWith({
    String? id,
    String? name,
    int? baseDurationMonths,
    int? additionalDays,
    double? totalAmount,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? createdByEmail,
  }) {
    return Offer(
      id: id ?? this.id,
      name: name ?? this.name,
      baseDurationMonths: baseDurationMonths ?? this.baseDurationMonths,
      additionalDays: additionalDays ?? this.additionalDays,
      totalAmount: totalAmount ?? this.totalAmount,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      createdByEmail: createdByEmail ?? this.createdByEmail,
    );
  }

  @override
  String toString() {
    return 'Offer(id: $id, name: $name, baseDurationMonths: $baseDurationMonths, additionalDays: $additionalDays, totalAmount: $totalAmount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Offer &&
        other.id == id &&
        other.name == name &&
        other.baseDurationMonths == baseDurationMonths &&
        other.additionalDays == additionalDays &&
        other.totalAmount == totalAmount &&
        other.description == description &&
        other.isActive == isActive &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt &&
        other.createdBy == createdBy &&
        other.createdByEmail == createdByEmail;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      baseDurationMonths,
      additionalDays,
      totalAmount,
      description,
      isActive,
      createdAt,
      updatedAt,
      createdBy,
      createdByEmail,
    );
  }
}
