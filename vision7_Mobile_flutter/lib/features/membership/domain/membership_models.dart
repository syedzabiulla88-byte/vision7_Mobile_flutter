class MembershipPlan {
  final String id;
  final String name;
  final String? nameAr;
  final String? description;
  final String? descriptionAr;
  final String category;
  final double price;
  final String currency;
  final int durationDays;
  final int sessionCount;
  final List<String> benefits;
  final bool isActive;
  final int order;

  MembershipPlan({
    required this.id,
    required this.name,
    this.nameAr,
    this.description,
    this.descriptionAr,
    required this.category,
    required this.price,
    required this.currency,
    required this.durationDays,
    required this.sessionCount,
    required this.benefits,
    required this.isActive,
    required this.order,
  });

  factory MembershipPlan.fromJson(Map<String, dynamic> json) {
    return MembershipPlan(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      nameAr: json['nameAr'] as String?,
      description: json['description'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      category: json['category'] as String? ?? 'general',
      price: _toDouble(json['price']),
      currency: json['currency'] as String? ?? 'SAR',
      durationDays: json['durationDays'] as int? ?? json['duration_days'] as int? ?? 30,
      sessionCount: json['sessionCount'] as int? ?? json['session_count'] as int? ?? 0,
      benefits: (json['benefits'] as List<dynamic>?)
              ?.map((b) => b as String)
              .toList() ??
          [],
      isActive: json['isActive'] as bool? ?? json['is_active'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
    );
  }

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }
}

class FamilyMember {
  final String id;
  final String name;
  final String? relation;

  FamilyMember({required this.id, required this.name, this.relation});

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      relation: json['relation'] as String?,
    );
  }
}

class UserMembership {
  final String id;
  final String userId;
  final String planId;
  final String? planName;
  final String? planNameAr;
  final String status; // active | pending | expired | cancelled | frozen
  final String? startDate;
  final String? endDate;
  final int sessionsRemaining;
  final int sessionsTotal;
  final bool isFrozen;
  final String? frozenUntil;
  final List<FamilyMember> familyMembers;

  UserMembership({
    required this.id,
    required this.userId,
    required this.planId,
    this.planName,
    this.planNameAr,
    required this.status,
    this.startDate,
    this.endDate,
    required this.sessionsRemaining,
    required this.sessionsTotal,
    required this.isFrozen,
    this.frozenUntil,
    this.familyMembers = const [],
  });

  factory UserMembership.fromJson(Map<String, dynamic> json) {
    final plan = json['plan'] as Map<String, dynamic>?;
    final familyJson = json['familyMembers'] as List<dynamic>? ?? json['family_members'] as List<dynamic>?;
    return UserMembership(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      planId: json['planId'] as String? ?? json['plan_id'] as String? ?? '',
      planName: plan?['name'] as String?,
      planNameAr: plan?['nameAr'] as String?,
      status: json['status'] as String? ?? 'pending',
      startDate: json['startDate'] as String? ?? json['start_date'] as String?,
      endDate: json['endDate'] as String? ?? json['end_date'] as String?,
      sessionsRemaining: json['sessionsRemaining'] as int? ??
          json['sessions_remaining'] as int? ??
          0,
      sessionsTotal: json['sessionsTotal'] as int? ??
          json['sessions_total'] as int? ??
          0,
      isFrozen: json['isFrozen'] as bool? ?? json['is_frozen'] as bool? ?? false,
      frozenUntil: json['frozenUntil'] as String? ??
          json['frozen_until'] as String?,
      familyMembers: familyJson?.map((m) => FamilyMember.fromJson(m as Map<String, dynamic>)).toList() ?? const [],
    );
  }
}
