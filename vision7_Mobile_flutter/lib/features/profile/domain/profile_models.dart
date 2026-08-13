// Dashboard counts
class DashboardCounts {
  final int bookings;
  final int activeMemberships;
  final int outstandingInvoices;
  final double outstandingTotal;

  DashboardCounts({
    required this.bookings,
    required this.activeMemberships,
    required this.outstandingInvoices,
    required this.outstandingTotal,
  });

  factory DashboardCounts.fromJson(Map<String, dynamic> json) {
    return DashboardCounts(
      bookings: json['bookings'] as int? ?? 0,
      activeMemberships: json['activeMemberships'] as int? ?? 0,
      outstandingInvoices: json['outstandingInvoices'] as int? ?? 0,
      outstandingTotal: _toDouble(json['outstandingTotal']),
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

// Dashboard response
class Dashboard {
  final Map<String, dynamic> profile;
  final DashboardCounts counts;
  final List<dynamic> upcomingBookings;
  final List<dynamic> memberships;
  final List<dynamic> recentInvoices;

  Dashboard({
    required this.profile,
    required this.counts,
    required this.upcomingBookings,
    required this.memberships,
    required this.recentInvoices,
  });

  factory Dashboard.fromJson(Map<String, dynamic> json) {
    final countsJson = json['counts'] as Map<String, dynamic>? ?? {};
    return Dashboard(
      profile: json['profile'] as Map<String, dynamic>? ?? {},
      counts: DashboardCounts.fromJson(countsJson),
      upcomingBookings: (json['upcomingBookings'] as List<dynamic>?) ?? [],
      memberships: (json['memberships'] as List<dynamic>?) ?? [],
      recentInvoices: (json['recentInvoices'] as List<dynamic>?) ?? [],
    );
  }
}

// User profile
class Profile {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? role;
  final String? gender;
  final String? type;
  final String? city;
  final String? profilePhoto;
  final String? memberSince;
  final String? status;

  Profile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role,
    this.gender,
    this.type,
    this.city,
    this.profilePhoto,
    this.memberSince,
    this.status,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      role: json['role'] as String?,
      gender: json['gender'] as String?,
      type: json['type'] as String?,
      city: json['city'] as String?,
      profilePhoto: json['profilePhoto'] as String?,
      memberSince: json['memberSince'] as String?,
      status: json['status'] as String?,
    );
  }
}
