import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_mode.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_colors.dart';

class ModeProvider extends ChangeNotifier {
  static const _key = 'vision7-mode';
  final SharedPreferences _prefs;
  AppMode _mode = AppMode.leisure;

  ModeProvider(this._prefs) {
    _loadMode();
  }

  AppMode get mode => _mode;
  bool get isAcademy => _mode == AppMode.academy;
  bool get isLeisure => _mode == AppMode.leisure;

  void _loadMode() {
    final saved = _prefs.getString(_key);
    if (saved == 'academy') {
      _mode = AppMode.academy;
    } else {
      _mode = AppMode.leisure;
    }
    notifyListeners();
  }

  ThemeData buildTheme(AppLanguage language) {
    return AppTheme.buildTheme(_mode, language);
  }

  Future<void> setMode(AppMode mode) async {
    _mode = mode;
    await _prefs.setString(_key, mode == AppMode.academy ? 'academy' : 'leisure');
    notifyListeners();
  }

  Future<void> toggleMode() async {
    _mode = _mode == AppMode.leisure ? AppMode.academy : AppMode.leisure;
    await _prefs.setString(_key, _mode == AppMode.academy ? 'academy' : 'leisure');
    notifyListeners();
  }
}

extension ModeProviderColors on ModeProvider {
  Color get accent =>
      isAcademy ? AppColors.gold : AppColors.black;

  Color get bg =>
      isAcademy ? AppColors.navy : AppColors.cream;

  Color get textPrimary =>
      isAcademy ? AppColors.cream : AppColors.black;

  Color get textMuted =>
      isAcademy
          ? AppColors.cream.withValues(alpha: 0.6)
          : AppColors.black.withValues(alpha: 0.5);

  Color get chipBg =>
      isAcademy
          ? AppColors.cream.withValues(alpha: 0.12)
          : AppColors.black.withValues(alpha: 0.08);

  Color get inputFill =>
      isAcademy
          ? AppColors.cream.withValues(alpha: 0.1)
          : AppColors.black.withValues(alpha: 0.05);

  Color get surface =>
      isAcademy ? AppColors.academySurface : AppColors.cream;

  Color get textOnSurface =>
      isAcademy ? AppColors.cream : AppColors.black;

  Color get inputBorder =>
      isAcademy ? AppColors.gold : AppColors.grayBorder;

  Color get backButton =>
      isAcademy ? AppColors.cream : AppColors.black;

  Color get buttonTextColor =>
      isAcademy ? AppColors.navy : AppColors.cream;
}
