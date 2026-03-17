import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../core/config/app_breakpoints.dart';
import '../controllers/navigation_controller.dart';
import '../navigation/app_destination.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'theme_mode_menu_button.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    required this.destination,
    required this.title,
    required this.summary,
    required this.child,
    super.key,
  });

  final AppDestination destination;
  final String title;
  final String summary;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final NavigationController navigationController =
        Get.find<NavigationController>();
    navigationController.syncRoute(destination.route);
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool useCompactNavigation =
            constraints.maxWidth < AppBreakpoints.compactNavigation;

        if (useCompactNavigation) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: Text(title),
              actions: const <Widget>[
                ThemeModeMenuButton(),
                SizedBox(width: AppSpacing.sm),
              ],
            ),
            body: _ShellBody(
              title: title,
              summary: summary,
              child: child,
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: AppDestination.values.indexOf(destination),
              destinations: AppDestination.values
                  .map(
                    (AppDestination item) => NavigationDestination(
                      icon: Icon(item.icon),
                      selectedIcon: Icon(item.selectedIcon),
                      label: item.label,
                    ),
                  )
                  .toList(growable: false),
              onDestinationSelected: (int index) {
                navigationController.navigateTo(AppDestination.values[index]);
              },
            ),
          );
        }

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? const <Color>[
                        AppColors.graphite,
                        AppColors.nearBlack,
                      ]
                    : const <Color>[
                        AppColors.lightBackground,
                        AppColors.lightPanel,
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: Row(
                children: <Widget>[
                  Container(
                    width: 288,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.xl,
                      AppSpacing.lg,
                      AppSpacing.xl,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.88),
                      border: Border(
                        right: BorderSide(
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant
                              .withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Day Desk',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Каркас Sprint 0 для персонального ассистента-планировщика.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Expanded(
                          child: NavigationRail(
                            extended: true,
                            minExtendedWidth: 240,
                            selectedIndex: AppDestination.values.indexOf(destination),
                            destinations: AppDestination.values
                                .map(
                                  (AppDestination item) => NavigationRailDestination(
                                    icon: Icon(item.icon),
                                    selectedIcon: Icon(item.selectedIcon),
                                    label: Text(item.label),
                                  ),
                                )
                                .toList(growable: false),
                            onDestinationSelected: (int index) {
                              navigationController.navigateTo(
                                AppDestination.values[index],
                              );
                            },
                          ),
                        ),
                        const Divider(height: AppSpacing.xl),
                        Row(
                          children: <Widget>[
                            const ThemeModeMenuButton(),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                'Тема и shell уже готовы для Sprint 1.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _ShellBody(
                      title: title,
                      summary: summary,
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShellBody extends StatelessWidget {
  const _ShellBody({
    required this.title,
    required this.summary,
    required this.child,
  });

  final String title;
  final String summary;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppBreakpoints.pageMaxWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                summary,
                style: textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
