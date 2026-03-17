import '../../features/settings/domain/entities/app_theme_preference.dart';

class AppStartupState {
  const AppStartupState({
    required this.initialThemePreference,
  });

  final AppThemePreference initialThemePreference;
}
