import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:sidebarx/sidebarx.dart';

import '../../core/config/app_breakpoints.dart';
import '../../features/availability/presentation/pages/availability_content_page.dart';
import '../../features/calendar/presentation/pages/calendar_content_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_content_page.dart';
import '../../features/map/presentation/controllers/places_map_controller.dart';
import '../../features/map/presentation/pages/map_content_page.dart';
import '../../features/settings/presentation/pages/settings_content_page.dart';
import '../../features/tasks/presentation/pages/tasks_content_page.dart';
import '../../features/tasks/presentation/widgets/tasks_page_header.dart';
import '../controllers/main_layout_controller.dart';
import '../navigation/app_destination.dart';
import '../theme/app_navigation_theme.dart';
import '../theme/app_spacing.dart';
import 'main_layout_intents.dart';
import 'shell_page_header_config.dart';
import 'widgets/app_top_bar.dart';

class MainLayoutPage extends StatefulWidget {
  const MainLayoutPage({required this.initialDestination, super.key});

  final AppDestination initialDestination;

  @override
  State<MainLayoutPage> createState() => _MainLayoutPageState();
}

class _MainLayoutPageState extends State<MainLayoutPage> {
  late final MainLayoutController _controller;
  late final FocusNode _shellFocusNode;
  late final List<Widget> _pages;
  bool? _lastCompactNavigation;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<MainLayoutController>();
    _shellFocusNode = FocusNode(debugLabel: 'main-layout-shell');
    _controller.ensureInitialized(widget.initialDestination);
    _pages = <Widget>[
      _PageFocusScope(
        destination: AppDestination.today,
        focusNode: _controller.pageFocusNodeFor(AppDestination.today),
        child: const _KeepAliveTab(child: DashboardContentPage()),
      ),
      _PageFocusScope(
        destination: AppDestination.map,
        focusNode: _controller.pageFocusNodeFor(AppDestination.map),
        child: const _KeepAliveTab(child: MapContentPage()),
      ),
      _PageFocusScope(
        destination: AppDestination.calendar,
        focusNode: _controller.pageFocusNodeFor(AppDestination.calendar),
        child: const _KeepAliveTab(child: CalendarContentPage()),
      ),
      _PageFocusScope(
        destination: AppDestination.tasks,
        focusNode: _controller.pageFocusNodeFor(AppDestination.tasks),
        child: const _KeepAliveTab(child: TasksContentPage()),
      ),
      _PageFocusScope(
        destination: AppDestination.availability,
        focusNode: _controller.pageFocusNodeFor(AppDestination.availability),
        child: const _KeepAliveTab(child: AvailabilityContentPage()),
      ),
      _PageFocusScope(
        destination: AppDestination.settings,
        focusNode: _controller.pageFocusNodeFor(AppDestination.settings),
        child: const _KeepAliveTab(child: SettingsContentPage()),
      ),
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
  void dispose() {
    _shellFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool useCompactNavigation = AppBreakpoints.usesCompactNavigation(
      MediaQuery.sizeOf(context).width,
    );

    return Obx(() {
      final AppDestination destination = _controller.currentDestination;
      if (_lastCompactNavigation != null &&
          _lastCompactNavigation != useCompactNavigation) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }

          _controller.syncViewportToCurrentDestination();
          _controller.requestPageFocus(destination);
        });
      }
      _lastCompactNavigation = useCompactNavigation;

      return FocusTraversalGroup(
        policy: OrderedTraversalPolicy(),
        child: Shortcuts(
          shortcuts: _shortcutBindings,
          child: Actions(
            actions: <Type, Action<Intent>>{
              NavigateToDestinationIntent:
                  CallbackAction<NavigateToDestinationIntent>(
                    onInvoke: (NavigateToDestinationIntent intent) {
                      _controller.selectDestination(
                        intent.destination,
                        animated: true,
                        syncRoute: true,
                        moveFocusToPage: true,
                      );
                      return null;
                    },
                  ),
              ToggleSidebarIntent: CallbackAction<ToggleSidebarIntent>(
                onInvoke: (ToggleSidebarIntent intent) {
                  _controller.toggleSidebarForLayout(
                    isExpandedLayout: !useCompactNavigation,
                  );
                  return null;
                },
              ),
              DismissTransientUiIntent:
                  CallbackAction<DismissTransientUiIntent>(
                    onInvoke: (DismissTransientUiIntent intent) {
                      final BuildContext dismissContext =
                          FocusManager.instance.primaryFocus?.context ??
                          context;
                      final Object? dismissResult = Actions.maybeInvoke(
                        dismissContext,
                        const DismissIntent(),
                      );

                      if (dismissResult != null) {
                        return null;
                      }

                      final bool handledByMap =
                          destination == AppDestination.map &&
                          Get.isRegistered<PlacesMapController>() &&
                          Get.find<PlacesMapController>().dismissOverlays(
                            isCompactLayout: useCompactNavigation,
                          );

                      if (!handledByMap) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      }
                      return null;
                    },
                  ),
            },
            child: Focus(
              autofocus: true,
              skipTraversal: true,
              focusNode: _shellFocusNode,
              child: Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                body: ColoredBox(
                  color: AppNavigationTheme.shellBackgroundColor(context),
                  child: SafeArea(
                    child: Row(
                      children: <Widget>[
                        if (!useCompactNavigation)
                          FocusTraversalOrder(
                            order: const NumericFocusOrder(1),
                            child: SidebarX(
                              controller: _controller.sidebarController,
                              theme: AppNavigationTheme.sidebar(context),
                              extendedTheme: AppNavigationTheme.sidebarExtended(
                                context,
                              ),
                              showToggleButton: true,
                              headerBuilder:
                                  (BuildContext context, bool extended) {
                                    return _DesktopSidebarHeader(
                                      extended: extended,
                                    );
                                  },
                              footerBuilder:
                                  (BuildContext context, bool extended) {
                                    return _DesktopSidebarFooter(
                                      extended: extended,
                                    );
                                  },
                              items: AppDestination.values
                                  .map(
                                    (
                                      AppDestination destination,
                                    ) => SidebarXItem(
                                      label: destination.label,
                                      iconBuilder:
                                          (bool selected, bool hovered) {
                                            return Tooltip(
                                              message: destination.label,
                                              waitDuration: const Duration(
                                                milliseconds: 500,
                                              ),
                                              child: Icon(
                                                selected
                                                    ? destination.selectedIcon
                                                    : destination.icon,
                                              ),
                                            );
                                          },
                                      onTap: () {
                                        _controller.selectDestination(
                                          destination,
                                          animated: false,
                                          syncRoute: true,
                                        );
                                      },
                                    ),
                                  )
                                  .toList(growable: false),
                            ),
                          ),
                        Expanded(
                          child: FocusTraversalOrder(
                            order: const NumericFocusOrder(2),
                            child: _MainLayoutBody(
                              controller: _controller,
                              currentDestination: destination,
                              pages: _pages,
                              swipeEnabled:
                                  useCompactNavigation &&
                                  destination != AppDestination.map,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                bottomNavigationBar: useCompactNavigation
                    ? FocusTraversalOrder(
                        order: const NumericFocusOrder(1),
                        child: _CompactNavigationBar(
                          controller: _controller,
                          currentDestination: destination,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
      );
    });
  }

  Map<ShortcutActivator, Intent> get _shortcutBindings {
    return <ShortcutActivator, Intent>{
      const SingleActivator(LogicalKeyboardKey.digit1, control: true):
          const NavigateToDestinationIntent(AppDestination.today),
      const SingleActivator(LogicalKeyboardKey.digit2, control: true):
          const NavigateToDestinationIntent(AppDestination.map),
      const SingleActivator(LogicalKeyboardKey.digit3, control: true):
          const NavigateToDestinationIntent(AppDestination.calendar),
      const SingleActivator(LogicalKeyboardKey.digit4, control: true):
          const NavigateToDestinationIntent(AppDestination.tasks),
      const SingleActivator(LogicalKeyboardKey.digit5, control: true):
          const NavigateToDestinationIntent(AppDestination.availability),
      const SingleActivator(LogicalKeyboardKey.digit6, control: true):
          const NavigateToDestinationIntent(AppDestination.settings),
      const SingleActivator(LogicalKeyboardKey.digit1, meta: true):
          const NavigateToDestinationIntent(AppDestination.today),
      const SingleActivator(LogicalKeyboardKey.digit2, meta: true):
          const NavigateToDestinationIntent(AppDestination.map),
      const SingleActivator(LogicalKeyboardKey.digit3, meta: true):
          const NavigateToDestinationIntent(AppDestination.calendar),
      const SingleActivator(LogicalKeyboardKey.digit4, meta: true):
          const NavigateToDestinationIntent(AppDestination.tasks),
      const SingleActivator(LogicalKeyboardKey.digit5, meta: true):
          const NavigateToDestinationIntent(AppDestination.availability),
      const SingleActivator(LogicalKeyboardKey.digit6, meta: true):
          const NavigateToDestinationIntent(AppDestination.settings),
      const SingleActivator(LogicalKeyboardKey.keyB, control: true):
          const ToggleSidebarIntent(),
      const SingleActivator(LogicalKeyboardKey.keyB, meta: true):
          const ToggleSidebarIntent(),
      const SingleActivator(LogicalKeyboardKey.escape):
          const DismissTransientUiIntent(),
    };
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
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final AppLayoutTier layoutTier = AppBreakpoints.layoutTierForWidth(
          constraints.maxWidth,
        );
        final ShellPageHeaderConfig headerConfig = _headerConfigFor(
          currentDestination,
        );

        return FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: AppTopBar(
                  key: ValueKey<String>(
                    'page-header-${currentDestination.name}',
                  ),
                  pageKey: Key('page-app-bar-${currentDestination.name}'),
                  config: headerConfig,
                  layoutTier: layoutTier,
                ),
              ),
              Expanded(child: _buildPageViewport()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPageViewport() {
    return FocusTraversalOrder(
      order: const NumericFocusOrder(2),
      child: PageStorage(
        bucket: controller.pageStorageBucket,
        child: PageView(
          controller: controller.pageController,
          physics: swipeEnabled
              ? const PageScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          onPageChanged: (int index) {
            controller.handlePageChanged(index, syncRoute: true);
          },
          children: pages,
        ),
      ),
    );
  }

  ShellPageHeaderConfig _headerConfigFor(AppDestination destination) {
    return switch (destination) {
      AppDestination.tasks => ShellPageHeaderConfig(
        title: '',
        bottom: const TasksPageHeader(),
      ),
      _ => ShellPageHeaderConfig(title: destination.title),
    };
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
    final bool useDenseTabLayout = AppDestination.values.length > 5;
    final bool useCompactDensity =
        MediaQuery.sizeOf(context).width < AppBreakpoints.compactDensity;
    final double outerHorizontalPadding = useCompactDensity
        ? (useDenseTabLayout ? AppSpacing.sm : AppSpacing.md)
        : AppSpacing.lg;
    final double outerBottomPadding = useCompactDensity
        ? AppSpacing.md
        : AppSpacing.lg;
    final double iconSize = useCompactDensity
        ? (useDenseTabLayout ? 20 : 22)
        : 24;
    final EdgeInsets tabPadding = EdgeInsets.symmetric(
      horizontal: useCompactDensity
          ? (useDenseTabLayout ? 6 : AppSpacing.sm)
          : AppSpacing.md,
      vertical: useCompactDensity ? AppSpacing.sm : AppSpacing.md,
    );

    return Container(
      padding: EdgeInsets.fromLTRB(
        outerHorizontalPadding,
        AppSpacing.sm,
        outerHorizontalPadding,
        outerBottomPadding,
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
          iconSize: iconSize,
          padding: tabPadding,
          tabMargin: EdgeInsets.symmetric(
            horizontal: useCompactDensity
                ? (useDenseTabLayout ? 1 : 2)
                : AppSpacing.xs,
          ),
          backgroundColor: Colors.transparent,
          tabBackgroundColor: AppNavigationTheme.gNavTabBackground(context),
          activeColor: AppNavigationTheme.gNavActiveColor(context),
          color: AppNavigationTheme.gNavInactiveColor(context),
          rippleColor: AppNavigationTheme.gNavRippleColor(context),
          hoverColor: AppNavigationTheme.gNavHoverColor(context),
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          tabs: AppDestination.values
              .map((AppDestination destination) {
                final bool isSelected = currentDestination == destination;
                return GButton(
                  key: Key('compact-nav-${destination.name}'),
                  icon: destination.icon,
                  leading: Tooltip(
                    message: destination.label,
                    waitDuration: const Duration(milliseconds: 500),
                    child: Icon(
                      isSelected ? destination.selectedIcon : destination.icon,
                      size: iconSize,
                      color: isSelected
                          ? AppNavigationTheme.gNavActiveColor(context)
                          : AppNavigationTheme.gNavInactiveColor(context),
                    ),
                  ),
                  text: '',
                  semanticLabel: destination.label,
                );
              })
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
  const _DesktopSidebarHeader({required this.extended});

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
        mainAxisAlignment: extended
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
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
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PageFocusScope extends StatelessWidget {
  const _PageFocusScope({
    required this.destination,
    required this.focusNode,
    required this.child,
  });

  final AppDestination destination;
  final FocusNode focusNode;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Focus(
      key: Key('page-focus-${destination.name}'),
      focusNode: focusNode,
      child: child,
    );
  }
}

class _DesktopSidebarFooter extends StatelessWidget {
  const _DesktopSidebarFooter({required this.extended});

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
        extended ? 'Главная навигация Day Desk' : 'DD',
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
  const _KeepAliveTab({required this.child});

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
