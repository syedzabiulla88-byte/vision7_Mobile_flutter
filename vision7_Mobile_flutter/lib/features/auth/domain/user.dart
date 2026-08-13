class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? role;
  final String? gender;
  final String? dob;
  final String? language;
  final String? city;
  final String? profilePhoto;
  final String? memberSince;
  final String? status;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role,
    this.gender,
    this.dob,
    this.language,
    this.city,
    this.profilePhoto,
    this.memberSince,
    this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    phone: json['phone'] as String?,
    role: json['role'] as String?,
    gender: json['gender'] as String?,
    dob: json['dob'] as String?,
    language: json['language'] as String?,
    city: json['city'] as String?,
    profilePhoto: json['profilePhoto'] as String?,
    memberSince: json['memberSince'] as String?,
    status: json['status'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'gender': gender,
    'dob': dob,
    'language': language,
    'city': city,
    'profilePhoto': profilePhoto,
    'memberSince': memberSince,
    'status': status,
  };
}
