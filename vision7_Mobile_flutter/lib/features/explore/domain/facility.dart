import '../../../shared/providers/app_mode.dart';

class Facility {
  final String id;
  final String name;
  final String? nameAr;
  final String description;
  final String category;
  final String image;
  final bool bookable;
  final int slotDuration;
  final List<String> slotVariants;
  final int capacity;
  final double? pricePerSlot;
  final String currency;
  final String? openTime;
  final String? closeTime;
  final int order;
  final bool isActive;
  final List<String> amenities;

  const Facility({
    required this.id,
    required this.name,
    this.nameAr,
    required this.description,
    required this.category,
    required this.image,
    this.bookable = false,
    this.slotDuration = 30,
    this.slotVariants = const [],
    this.capacity = 1,
    this.pricePerSlot,
    this.currency = 'SAR',
    this.openTime,
    this.closeTime,
    this.order = 0,
    this.isActive = true,
    this.amenities = const [],
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    // image can be a string or a JSON array string
    String parseImage(dynamic val) {
      if (val == null) return '';
      if (val is String) return val;
      return val.toString();
    }

    return Facility(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      description: json['description'] as String? ?? '',
      category: json['category'] as String,
      image: parseImage(json['image']),
      bookable: json['bookable'] as bool? ?? false,
      slotDuration: json['slotDuration'] as int? ?? 30,
      slotVariants: json['slotVariants'] != null
          ? List<String>.from(json['slotVariants'])
          : const [],
      capacity: json['capacity'] as int? ?? 1,
      pricePerSlot: json['pricePerSlot'] != null
          ? (json['pricePerSlot'] is String
              ? double.tryParse(json['pricePerSlot']) ?? 0.0
              : (json['pricePerSlot'] as num).toDouble())
          : null,
      currency: json['currency'] as String? ?? 'SAR',
      openTime: json['openTime'] as String?,
      closeTime: json['closeTime'] as String?,
      order: json['order'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'nameAr': nameAr,
    'description': description,
    'category': category,
    'image': image,
    'bookable': bookable,
    'slotDuration': slotDuration,
    'slotVariants': slotVariants,
    'capacity': capacity,
    'pricePerSlot': pricePerSlot,
    'currency': currency,
    'openTime': openTime,
    'closeTime': closeTime,
    'order': order,
    'isActive': isActive,
    'amenities': amenities,
  };

  String getName(AppLanguage lang) =>
      lang == AppLanguage.ar && nameAr != null && nameAr!.isNotEmpty ? nameAr! : name;

  String get pricePerSlotFormatted {
    if (pricePerSlot == null) return '—';
    return '${pricePerSlot!.toStringAsFixed(0)} $currency';
  }
}

enum GenderRule { mixed, maleOnly, femaleOnly }
