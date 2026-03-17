import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../core/config/app_breakpoints.dart';
import '../../features/availability/presentation/pages/availability_content_page.dart';
import '../../features/calendar/presentation/pages/calendar_content_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_content_page.dart';
import '../../features/settings/presentation/pages/settings_content_page.dart';
import '../../features/tasks/presentation/pages/tasks_content_page.dart';
import '../controllers/main_layout_controller.dart';
import '../navigation/app_destination.dart';
import '../theme/app_navigation_theme.dart';
import '../theme/app_spacing.dart';
import 'theme_mode_menu_button.dart';

class MainLayoutPage extends StatefulWidget {
  const MainLayoutPage({
    required this.initialDestination,
    super.key,
  });

  final AppDestination initialDestination;

  @override
  State<MainLayoutPage> createState() => _MainLayoutPageState();
}

class _MainLayoutPageState extends State<MainLayoutPage> {
  late final MainLayoutController _controller;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<MainLayoutController>();
    _controller.ensureInitialized(widget.initialDestination);
    _pages = <Widget>[
      const _KeepAliveTab(child: DashboardContentPage()),
      const _KeepAliveTab(child: CalendarContentPage()),
      const _KeepAliveTab(child: TasksContentPage()),
      const _KeepAliveTab(child: AvailabilityContentPage()),
      const _KeepAliveTab(child: SettingsContentPage()),
    ];
  }

  @override
  void didUpdateWidget(covariant MainLayoutPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialDestination != widget.initialDestination) {
      _controller.syncFromRoute(widget.initialDestination);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool useCompactNavigation =
        MediaQuery.sizeOf(context).width < AppBreakpoints.compactNavigation;

    return Obx(
      () {
        final AppDestination destination = _controller.currentDestination;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: ColoredBox(
            color: AppNavigationTheme.shellBackgroundColor(context),
            child: SafeArea(
              child: useCompactNavigation
                  ? _CompactMainLayout(
                      controller: _controller,
                      currentDestination: destination,
                      pages: _pages,
                    )
                  : _ExpandedMainLayout(
                      controller: _controller,
                      currentDestination: destination,
                      pages: _pages,
                    ),
            ),
          ),
          bottomNavigationBar: useCompactNavigation
              ? _CompactNavigationBar(
                  controller: _controller,
                  currentDestination: destination,
                )
              : null,
        );
      },
    );
  }
}

class _ExpandedMainLayout extends StatelessWidget {
  const _ExpandedMainLayout({
    required this.controller,
    required this.currentDestination,
    required this.pages,
  });

  final MainLayoutController controller;
  final AppDestination currentDestination;
  final List<Widget> pages;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SidebarX(
          controller: controller.sidebarController,
          theme: AppNavigationTheme.sidebar(context),
          extendedTheme: AppNavigationTheme.sidebarExtended(context),
          showToggleButton: true,
          headerBuilder: (BuildContext context, bool extended) {
            return _DesktopSidebarHeader(
              extended: extended,
            );
          },
          footerBuilder: (BuildContext context, bool extended) {
            return _DesktopSidebarFooter(
              extended: extended,
            );
          },
          items: AppDestination.values
              .map(
                (AppDestination destination) => SidebarXItem(
                  label: destination.label,
                  iconBuilder: (bool selected, bool hovered) {
                    return Icon(
                      selected ? destination.selectedIcon : destination.icon,
                    );
                  },
                  onTap: () {
                    controller.selectDestination(
                      destination,
                      animated: false,
                      syncRoute: true,
                    );
                  },
                ),
              )
              .toList(growable: false),
        ),
        Expanded(
          child: _MainLayoutBody(
            controller: controller,
            currentDestination: currentDestination,
            pages: pages,
            swipeEnabled: false,
          ),
        ),
      ],
    );
  }
}

class _CompactMainLayout extends StatelessWidget {
  const _CompactMainLayout({
    required this.controller,
    required this.currentDestination,
    required this.pages,
  });

  final MainLayoutController controller;
  final AppDestination currentDestination;
  final List<Widget> pages;

  @override
  Widget build(BuildContext context) {
    return _MainLayoutBody(
      controller: controller,
      currentDestination: currentDestination,
      pages: pages,
      swipeEnabled: true,
    );
  }
}

class _MainLayoutBody extends StatelessWidget {
  const _MainLayoutBody({
    required this.controller,
    required this.currentDestination,
    required this.pages,
    required this.swipeEnabled,
  });

  final MainLayoutController controller;
  final AppDestination currentDestination;
  final List<Widget> pages;
  final bool swipeEnabled;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      currentDestination.title,
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      currentDestination.summary,
                      style: textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              const ThemeModeMenuButton(),
            ],
          ),
        ),
        Expanded(
          child: PageStorage(
            bucket: controller.pageStorageBucket,
            child: PageView(
              controller: controller.pageController,
              physics: swipeEnabled
                  ? const PageScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              onPageChanged: (int index) {
                controller.handlePageChanged(
                  index,
                  syncRoute: true,
                );
              },
              children: pages,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactNavigationBar extends StatelessWidget {
  const _CompactNavigationBar({
    required this.controller,
    required this.currentDestination,
  });

  final MainLayoutController controller;
  final AppDestination currentDestination;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: AppNavigationTheme.gNavBackground(context),
        boxShadow: AppNavigationTheme.gNavShadow(context),
      ),
      child: SafeArea(
        top: false,
        child: GNav(
          selectedIndex: currentDestination.index,
          gap: 0,
          iconSize: 24,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          tabMargin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          backgroundColor: Colors.transparent,
          tabBackgroundColor: AppNavigationTheme.gNavTabBackground(context),
          activeColor: AppNavigationTheme.gNavActiveColor(context),
          color: AppNavigationTheme.gNavInactiveColor(context),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          tabs: AppDestination.values
              .map(
                (AppDestination destination) => GButton(
                  icon: destination.icon,
                  text: '',
                  semanticLabel: destination.label,
                ),
              )
              .toList(growable: false),
          onTabChange: (int index) {
            controller.selectDestination(
              AppDestination.values[index],
              animated: true,
              syncRoute: true,
            );
          },
        ),
      ),
    );
  }
}

class _DesktopSidebarHeader extends StatelessWidget {
  const _DesktopSidebarHeader({
    required this.extended,
  });

  final bool extended;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Row(
        mainAxisAlignment:
            extended ? MainAxisAlignment.start : MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.edit_calendar_rounded,
            color: Theme.of(context).colorScheme.primary,
          ),
          if (extended) ...<Widget>[
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                'Day Desk',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DesktopSidebarFooter extends StatelessWidget {
  const _DesktopSidebarFooter({
    required this.extended,
  });

  final bool extended;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: Text(
        extended
            ? 'Главная навигация Day Desk'
            : 'DD',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
        textAlign: extended ? TextAlign.start : TextAlign.center,
      ),
    );
  }
}

class _KeepAliveTab extends StatefulWidget {
  const _KeepAliveTab({
    required this.child,
  });

  final Widget child;

  @override
  State<_KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<_KeepAliveTab>
    with AutomaticKeepAliveClientMixin<_KeepAliveTab> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
