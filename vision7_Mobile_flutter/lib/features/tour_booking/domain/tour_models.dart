class TourSlot {
  final String time; // "HH:mm"
  final int capacity;
  final int booked;

  TourSlot({
    required this.time,
    required this.capacity,
    required this.booked,
  });

  factory TourSlot.fromJson(Map<String, dynamic> json) {
    return TourSlot(
      time: json['time'] as String? ?? json['slot'] as String? ?? '',
      capacity: json['capacity'] as int? ?? 0,
      booked: json['booked'] as int? ?? json['reserved'] as int? ?? 0,
    );
  }
}

class TourAvailability {
  final String date;
  final List<TourSlot> slots;

  TourAvailability({
    required this.date,
    required this.slots,
  });

  factory TourAvailability.fromJson(Map<String, dynamic> json) {
    final slotsJson = json['slots'] as List<dynamic>? ?? [];
    return TourAvailability(
      date: json['date'] as String? ?? '',
      slots: slotsJson
          .map((s) => TourSlot.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TourWindow {
  final String from;
  final String to;

  TourWindow({required this.from, required this.to});

  factory TourWindow.fromJson(Map<String, dynamic> json) {
    return TourWindow(
      from: json['from'] as String? ?? '',
      to: json['to'] as String? ?? '',
    );
  }
}

class TourBookingResult {
  final String id;
  final String status;
  final String date;
  final String slot;

  TourBookingResult({
    required this.id,
    required this.status,
    required this.date,
    required this.slot,
  });

  factory TourBookingResult.fromJson(Map<String, dynamic> json) {
    return TourBookingResult(
      id: json['id'] as String? ?? json['bookingId'] as String? ?? '',
      status: json['status'] as String? ?? 'confirmed',
      date: json['date'] as String? ?? '',
      slot: json['slot'] as String? ?? json['timeSlot'] as String? ?? '',
    );
  }
}
