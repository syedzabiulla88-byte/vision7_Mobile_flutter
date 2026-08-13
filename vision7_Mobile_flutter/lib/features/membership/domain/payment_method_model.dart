import 'package:flutter/material.dart';

enum PaymentMethod {
  applePay('apple_pay', 'Apple Pay', Icons.apple),
  mada('mada', 'Mada', Icons.payment),
  creditCard('credit_card', 'Credit Card', Icons.credit_card),
  cash('cash', 'Pay at Facility', Icons.store);

  final String value;
  final String label;
  final IconData icon;
  const PaymentMethod(this.value, this.label, this.icon);
}
