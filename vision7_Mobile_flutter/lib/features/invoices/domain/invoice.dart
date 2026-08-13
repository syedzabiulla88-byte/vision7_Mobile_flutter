class Invoice {
  final String id;
  final String invoiceNumber;
  final String userId;
  final String? membershipId;
  final String status; // pending | paid | overdue | cancelled
  final double subtotal;
  final double tax;
  final double total;
  final String currency;
  final String? dueDate;
  final String? paidAt;
  final List<InvoiceLine> items;
  final List<InvoicePayment> payments;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.userId,
    this.membershipId,
    required this.status,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.currency,
    this.dueDate,
    this.paidAt,
    required this.items,
    required this.payments,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final paymentsJson = json['payments'] as List<dynamic>? ?? [];

    return Invoice(
      id: json['id'] as String,
      invoiceNumber: json['invoiceNumber'] as String? ?? json['invoice_number'] as String? ?? '',
      userId: json['userId'] as String? ?? json['user_id'] as String? ?? '',
      membershipId: json['membershipId'] as String? ?? json['membership_id'] as String?,
      status: json['status'] as String? ?? 'pending',
      subtotal: _toDouble(json['subtotal']),
      tax: _toDouble(json['tax']),
      total: _toDouble(json['total']),
      currency: json['currency'] as String? ?? 'SAR',
      dueDate: json['dueDate'] as String? ?? json['due_date'] as String?,
      paidAt: json['paidAt'] as String? ?? json['paid_at'] as String?,
      items: itemsJson
          .map((i) => InvoiceLine.fromJson(i as Map<String, dynamic>))
          .toList(),
      payments: paymentsJson
          .map((p) => InvoicePayment.fromJson(p as Map<String, dynamic>))
          .toList(),
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

class InvoiceLine {
  final String description;
  final int quantity;
  final double unitPrice;
  final double amount;

  InvoiceLine({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
  });

  factory InvoiceLine.fromJson(Map<String, dynamic> json) {
    return InvoiceLine(
      description: json['description'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: Invoice._toDouble(json['unitPrice']),
      amount: Invoice._toDouble(json['amount']),
    );
  }
}

class InvoicePayment {
  final String id;
  final String method;
  final double amount;
  final String? paidAt;

  InvoicePayment({
    required this.id,
    required this.method,
    required this.amount,
    this.paidAt,
  });

  factory InvoicePayment.fromJson(Map<String, dynamic> json) {
    return InvoicePayment(
      id: json['id'] as String,
      method: json['method'] as String? ?? 'card',
      amount: Invoice._toDouble(json['amount']),
      paidAt: json['paidAt'] as String? ?? json['paid_at'] as String?,
    );
  }
}
