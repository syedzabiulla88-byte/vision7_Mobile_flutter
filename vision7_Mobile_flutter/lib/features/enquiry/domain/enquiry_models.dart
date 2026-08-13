class EnquiryResult {
  final String id;
  final String status;

  EnquiryResult({required this.id, required this.status});

  factory EnquiryResult.fromJson(Map<String, dynamic> json) {
    return EnquiryResult(
      id: json['id'] as String? ?? '',
      status: json['status'] as String? ?? 'received',
    );
  }
}
