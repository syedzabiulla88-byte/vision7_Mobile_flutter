import '../../../shared/providers/app_mode.dart';

class Booking {
  final String id;
  final String facilityId;
  final String facilityName;
  final String? facilityNameAr;
  final String? facilityImage;
  final String date;
  final String startTime;
  final String endTime;
  final int partySize;
  final double totalPrice;
  final String currency;
  final String status;
  final String? customerName;
  final String? customerPhone;
  final String? customerEmail;
  final String? customerGender;
  final String? notes;
  final String? qrCode;
  final int slotDurationMin;
  final String source;
  final String bookingType;

  const Booking({
    required this.id,
    required this.facilityId,
    required this.facilityName,
    this.facilityNameAr,
    this.facilityImage,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.partySize,
    required this.totalPrice,
    this.currency = 'SAR',
    required this.status,
    this.customerName,
    this.customerPhone,
    this.customerEmail,
    this.customerGender,
    this.notes,
    this.qrCode,
    this.slotDurationMin = 60,
    this.source = 'app',
    this.bookingType = 'FACILITY',
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    final facility = json['facility'] as Map<String, dynamic>?;

    // Price can come as string from Postgres
    double parsePrice(dynamic val) {
      if (val == null) return 0.0;
      if (val is String) return double.tryParse(val) ?? 0.0;
      if (val is num) return val.toDouble();
      return 0.0;
    }

    return Booking(
      id: json['id'] as String,
      facilityId: (json['facilityId'] as String?) ?? '',
      facilityName: facility?['name'] as String? ?? json['facilityName'] as String? ?? '',
      facilityNameAr: facility?['nameAr'] as String?,
      facilityImage: facility?['image'] as String?,
      date: json['date'] != null
          ? (json['date'] is String ? json['date'] : DateTime.parse(json['date'].toString()).toIso8601String().split('T')[0])
          : '',
      startTime: json['startTime'] as String? ?? '',
      endTime: json['endTime'] as String? ?? '',
      partySize: json['partySize'] as int? ?? 1,
      totalPrice: parsePrice(json['totalPrice']),
      currency: json['currency'] as String? ?? 'SAR',
      status: json['status'] as String? ?? 'PENDING',
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      customerEmail: json['customerEmail'] as String?,
      customerGender: json['customerGender'] as String?,
      notes: json['notes'] as String?,
      qrCode: json['qrCode'] as String?,
      slotDurationMin: json['slotDurationMin'] as int? ?? 60,
      source: json['source'] as String? ?? 'app',
      bookingType: json['bookingType'] as String? ?? 'FACILITY',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'facilityId': facilityId,
    'facilityName': facilityName,
    'facilityNameAr': facilityNameAr,
    'facilityImage': facilityImage,
    'date': date,
    'startTime': startTime,
    'endTime': endTime,
    'partySize': partySize,
    'totalPrice': totalPrice,
    'currency': currency,
    'status': status,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'customerEmail': customerEmail,
    'customerGender': customerGender,
    'notes': notes,
    'qrCode': qrCode,
    'slotDurationMin': slotDurationMin,
    'source': source,
    'bookingType': bookingType,
  };

  String getName(AppLanguage lang) =>
      lang == AppLanguage.ar && facilityNameAr != null && facilityNameAr!.isNotEmpty
          ? facilityNameAr!
          : facilityName;

  String get timeSlot => '$startTime – $endTime';
  String get formattedTotal => '$currency ${totalPrice.toStringAsFixed(2)}';
}
