import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../core/theme/custom_text_theme.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../../../shared/providers/mode_provider.dart';
import '../../../../core/theme/app_colors.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final String id;

  const InvoiceDetailScreen({super.key, required this.id});

  static const _invoices = [
    {'id': 'INV-001', 'date': '2026-08-01', 'amount': 399.0, 'status': 'Paid', 'payment': 'Visa **** 4242', 'desc': 'Gold Membership - August 2026'},
    {'id': 'INV-002', 'date': '2026-07-01', 'amount': 399.0, 'status': 'Paid', 'payment': 'Visa **** 4242', 'desc': 'Gold Membership - July 2026'},
    {'id': 'INV-003', 'date': '2026-06-15', 'amount': 120.0, 'status': 'Paid', 'payment': 'Apple Pay', 'desc': 'Padel Court 1 - Booking'},
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().t;
    final mode = context.watch<ModeProvider>();
    final isAcademy = mode.isAcademy;
    final cardBg = isAcademy ? AppColors.cream.withValues(alpha: 0.1) : AppColors.white;
    final textColor = isAcademy ? AppColors.cream : AppColors.text;

    return Scaffold(
      backgroundColor: isAcademy ? AppColors.academyNavy : AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.arrow_back_ios, color: textColor),
                  ),
                  Expanded(
                    child: Text(
                      id.isEmpty
                          ? t('invoices.title', fallback: 'Invoices')
                          : t('invoices.detail', fallback: 'Invoice Details'),
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              if (id.isEmpty) ...[
                _buildInvoiceList(context, isAcademy, cardBg),
              ] else ...[
                _buildInvoiceDetail(context, id, isAcademy, cardBg),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceList(BuildContext context, bool isAcademy, Color cardBg) {
    final t = context.read<LanguageProvider>().t;
    final invoices = _invoices;

    if (invoices.isEmpty) {
      return Expanded(
        child: Center(
          child: Text(
            t('invoices.none', fallback: 'No invoices yet'),
            style: TextStyle(color: isAcademy ? AppColors.cream.withValues(alpha: 0.6) : AppColors.muted),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        itemCount: invoices.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, index) {
          final inv = invoices[index];
          return InkWell(
            onTap: () => context.push('/membership/${inv['id']}'),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long, color: AppColors.gold, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(inv['id'] as String, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 2),
                        Text(inv['desc'] as String, style: Theme.of(context).textTheme.caption),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('SAR ${(inv['amount'] as double).toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(inv['status'] as String,
                          style: const TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInvoiceDetail(BuildContext context, String invoiceId, bool isAcademy, Color cardBg) {
    final t = context.read<LanguageProvider>().t;
    final invoice = _invoices.firstWhere(
      (inv) => inv['id'] == invoiceId,
      orElse: () => {'id': invoiceId, 'date': '-', 'amount': 0.0, 'status': '-', 'payment': '-', 'desc': '-'},
    );

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _InvoiceRow(label: t('invoices.number', fallback: 'Invoice'), value: invoice['id'] as String),
                  const SizedBox(height: AppSpacing.sm),
                  _InvoiceRow(label: t('booking.date', fallback: 'Date'), value: invoice['date'] as String),
                  const SizedBox(height: AppSpacing.sm),
                  _InvoiceRow(label: t('booking.total', fallback: 'Amount'), value: 'SAR ${(invoice['amount'] as double).toStringAsFixed(0)}'),
                  const SizedBox(height: AppSpacing.sm),
                  _InvoiceRow(label: t('booking.status', fallback: 'Status'), value: invoice['status'] as String, valueColor: AppColors.success),
                  const SizedBox(height: AppSpacing.sm),
                  _InvoiceRow(label: t('invoices.payment', fallback: 'Payment'), value: invoice['payment'] as String),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                t('invoices.lineItems', fallback: 'Line Items'),
                style: Theme.of(context).textTheme.h4,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            InvoiceSummaryCard(
              description: invoice['desc'] as String,
              amount: 'SAR ${(invoice['amount'] as double).toStringAsFixed(0)}',
              isAcademy: isAcademy,
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InvoiceRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class InvoiceSummaryCard extends StatelessWidget {
  final String description;
  final String amount;
  final bool isAcademy;

  const InvoiceSummaryCard({super.key, required this.description, required this.amount, this.isAcademy = false});

  @override
  Widget build(BuildContext context) {
    final cardBg = isAcademy ? AppColors.cream.withValues(alpha: 0.1) : AppColors.white;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: Text(description, style: Theme.of(context).textTheme.bodySmall)),
          Text(amount, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
