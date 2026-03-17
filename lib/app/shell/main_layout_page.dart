import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
import 'main_layout_intents.dart';
import 'theme_mode_menu_button.dart';

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
    final bool useCompactNavigation =
        MediaQuery.sizeOf(context).width < AppBreakpoints.compactNavigation;

    return Obx(() {
      final AppDestination destination = _controller.currentDestination;
      if (_lastCompactNavigation != null &&
          _lastCompactNavigation != useCompactNavigation) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) {
            return;
          }

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

                      if (dismissResult == null) {
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
          const NavigateToDestinationIntent(AppDestination.calendar),
      const SingleActivator(LogicalKeyboardKey.digit3, control: true):
          const NavigateToDestinationIntent(AppDestination.tasks),
      const SingleActivator(LogicalKeyboardKey.digit4, control: true):
          const NavigateToDestinationIntent(AppDestination.availability),
      const SingleActivator(LogicalKeyboardKey.digit5, control: true):
          const NavigateToDestinationIntent(AppDestination.settings),
      const SingleActivator(LogicalKeyboardKey.digit1, meta: true):
          const NavigateToDestinationIntent(AppDestination.today),
      const SingleActivator(LogicalKeyboardKey.digit2, meta: true):
          const NavigateToDestinationIntent(AppDestination.calendar),
      const SingleActivator(LogicalKeyboardKey.digit3, meta: true):
          const NavigateToDestinationIntent(AppDestination.tasks),
      const SingleActivator(LogicalKeyboardKey.digit4, meta: true):
          const NavigateToDestinationIntent(AppDestination.availability),
      const SingleActivator(LogicalKeyboardKey.digit5, meta: true):
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
        FocusTraversalOrder(
          order: const NumericFocusOrder(1),
          child: SidebarX(
            controller: controller.sidebarController,
            theme: AppNavigationTheme.sidebar(context),
            extendedTheme: AppNavigationTheme.sidebarExtended(context),
            showToggleButton: true,
            headerBuilder: (BuildContext context, bool extended) {
              return _DesktopSidebarHeader(extended: extended);
            },
            footerBuilder: (BuildContext context, bool extended) {
              return _DesktopSidebarFooter(extended: extended);
            },
            items: AppDestination.values
                .map(
                  (AppDestination destination) => SidebarXItem(
                    label: destination.label,
                    iconBuilder: (bool selected, bool hovered) {
                      return Tooltip(
                        message: destination.label,
                        waitDuration: const Duration(milliseconds: 500),
                        child: Icon(
                          selected
                              ? destination.selectedIcon
                              : destination.icon,
                        ),
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
        ),
        Expanded(
          child: FocusTraversalOrder(
            order: const NumericFocusOrder(2),
            child: _MainLayoutBody(
              controller: controller,
              currentDestination: currentDestination,
              pages: pages,
              swipeEnabled: false,
            ),
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
    return FocusTraversalOrder(
      order: const NumericFocusOrder(2),
      child: _MainLayoutBody(
        controller: controller,
        currentDestination: currentDestination,
        pages: pages,
        swipeEnabled: true,
      ),
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
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final ColorScheme colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final bool useCompactHeader = width < AppBreakpoints.compactHeader;
        final bool useCompactDensity = width < AppBreakpoints.compactDensity;
        final EdgeInsets headerPadding = EdgeInsets.fromLTRB(
          useCompactDensity ? AppSpacing.lg : AppSpacing.xl,
          useCompactDensity ? AppSpacing.lg : AppSpacing.xl,
          useCompactDensity ? AppSpacing.lg : AppSpacing.xl,
          useCompactDensity ? AppSpacing.lg : AppSpacing.xl,
        );
        final TextStyle? titleStyle =
            (useCompactHeader
                    ? textTheme.headlineMedium
                    : textTheme.displaySmall)
                ?.copyWith(fontWeight: FontWeight.w800);

        return FocusTraversalGroup(
          policy: OrderedTraversalPolicy(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: headerPadding,
                child: useCompactHeader
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          _HeaderCopy(
                            currentDestination: currentDestination,
                            titleStyle: titleStyle,
                            colorScheme: colorScheme,
                            compactDensity: useCompactDensity,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          const FocusTraversalOrder(
                            order: NumericFocusOrder(1),
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: ThemeModeMenuButton(),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: _HeaderCopy(
                              currentDestination: currentDestination,
                              titleStyle: titleStyle,
                              colorScheme: colorScheme,
                              compactDensity: useCompactDensity,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          const FocusTraversalOrder(
                            order: NumericFocusOrder(1),
                            child: ThemeModeMenuButton(),
                          ),
                        ],
                      ),
              ),
              Expanded(
                child: FocusTraversalOrder(
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
                ),
              ),
            ],
          ),
        );
      },
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
    final bool useCompactDensity =
        MediaQuery.sizeOf(context).width < AppBreakpoints.compactDensity;
    final double outerHorizontalPadding = useCompactDensity
        ? AppSpacing.md
        : AppSpacing.lg;
    final double outerBottomPadding = useCompactDensity
        ? AppSpacing.md
        : AppSpacing.lg;
    final double iconSize = useCompactDensity ? 22 : 24;
    final EdgeInsets tabPadding = EdgeInsets.symmetric(
      horizontal: useCompactDensity ? AppSpacing.sm : AppSpacing.md,
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
            horizontal: useCompactDensity ? 2 : AppSpacing.xs,
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

class _HeaderCopy extends StatelessWidget {
  const _HeaderCopy({
    required this.currentDestination,
    required this.titleStyle,
    required this.colorScheme,
    required this.compactDensity,
  });

  final AppDestination currentDestination;
  final TextStyle? titleStyle;
  final ColorScheme colorScheme;
  final bool compactDensity;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(currentDestination.title, style: titleStyle),
        const SizedBox(height: AppSpacing.md),
        Text(
          currentDestination.summary,
          maxLines: compactDensity ? 2 : 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
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
