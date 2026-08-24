import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/spacing.dart';
import '../../../../shared/providers/language_provider.dart';
import '../../domain/me_repository.dart';
import '../../domain/profile_models.dart';

/// The member's current BioStar QR access pass — reached either by tapping
/// the "QR pass is ready" push notification, or manually from Profile.
class AccessPassScreen extends StatefulWidget {
  const AccessPassScreen({super.key});

  @override
  State<AccessPassScreen> createState() => _AccessPassScreenState();
}

class _AccessPassScreenState extends State<AccessPassScreen> {
  bool _isLoading = true;
  String? _error;
  QrPass? _pass;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<MeRepository>();
      final pass = await repo.getQrPass();
      if (mounted) setState(() { _pass = pass; _isLoading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = e.toString(); _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().t;

    return Scaffold(
      backgroundColor: AppColors.dark,
      appBar: AppBar(
        backgroundColor: AppColors.dark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.cream),
        title: Text(
          t('accessPass.title', fallback: 'Access Pass'),
          style: const TextStyle(color: AppColors.cream, fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppColors.gold,
        backgroundColor: AppColors.darkLight,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
            : _error != null
                ? _buildMessage(
                    icon: Icons.error_outline,
                    title: t('common.somethingWentWrong', fallback: 'Something went wrong'),
                    body: _error!,
                  )
                : _pass == null
                    ? _buildMessage(
                        icon: Icons.qr_code_2_outlined,
                        title: t('accessPass.noPass', fallback: 'No active pass'),
                        body: t(
                          'accessPass.noPassBody',
                          fallback: 'A QR access pass will appear here once staff issue one for your membership or booking.',
                        ),
                      )
                    : _buildPass(t, _pass!),
      ),
    );
  }

  Widget _buildMessage({required IconData icon, required String title, required String body}) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 80),
      children: [
        Icon(icon, size: 56, color: AppColors.mutedOnDark),
        const SizedBox(height: AppSpacing.md),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.cream, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          body,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.mutedOnDark, fontSize: 14, height: 1.4),
        ),
      ],
    );
  }

  Widget _buildPass(String Function(String, {String? fallback}) t, QrPass pass) {
    final expired = pass.expiresAt != null && pass.expiresAt!.isBefore(DateTime.now());
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.darkLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              if (pass.planName != null) ...[
                Text(
                  pass.planName!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.gold, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
                child: Opacity(
                  opacity: expired ? 0.3 : 1.0,
                  child: QrImageView(
                    data: pass.cardId,
                    size: 220,
                    backgroundColor: AppColors.white,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                t('accessPass.showAtDoor', fallback: 'Show this code to any Vision7 door reader'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.mutedOnDark, fontSize: 13),
              ),
              if (pass.expiresAt != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: expired ? Colors.red.withValues(alpha: 0.15) : AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    expired
                        ? t('accessPass.expired', fallback: 'Expired')
                        : '${t('accessPass.validUntil', fallback: 'Valid until')} ${_formatDate(pass.expiresAt!)}',
                    style: TextStyle(
                      color: expired ? Colors.redAccent : AppColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime d) {
    final local = d.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year} $hour:$minute $ampm';
  }
}
