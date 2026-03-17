import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:sidebarx/sidebarx.dart';

import '../navigation/app_destination.dart';

class MainLayoutController extends GetxController {
  MainLayoutController();

  final Rx<AppDestination> _currentDestination = AppDestination.today.obs;
  final RxString _currentRoutePath = AppDestination.today.route.obs;
  final PageStorageBucket pageStorageBucket = PageStorageBucket();

  late final PageController pageController;
  late final SidebarXController sidebarController;

  bool _initialized = false;

  AppDestination get currentDestination => _currentDestination.value;
  String get currentRoutePath => _currentRoutePath.value;
  int get currentIndex => currentDestination.index;

  void ensureInitialized(AppDestination initialDestination) {
    if (!_initialized) {
      _currentDestination.value = initialDestination;
      _currentRoutePath.value = initialDestination.route;
      pageController = PageController(
        initialPage: initialDestination.index,
        keepPage: true,
      );
      sidebarController = SidebarXController(
        selectedIndex: initialDestination.index,
        extended: true,
      );
      _initialized = true;
      return;
    }

    syncFromRoute(initialDestination);
  }

  void syncFromRoute(AppDestination destination) {
    _currentRoutePath.value = destination.route;
    _updateSelection(destination);

    if (!pageController.hasClients) {
      return;
    }

    final int pageIndex = pageController.page?.round() ?? currentIndex;
    if (pageIndex != destination.index) {
      pageController.jumpToPage(destination.index);
    }
  }

  Future<void> selectDestination(
    AppDestination destination, {
    required bool animated,
    required bool syncRoute,
  }) async {
    if (destination == currentDestination) {
      if (syncRoute) {
        await _syncRoute(destination);
      }
      return;
    }

    _updateSelection(destination);

    if (pageController.hasClients) {
      if (animated) {
        await pageController.animateToPage(
          destination.index,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      } else {
        pageController.jumpToPage(destination.index);
      }
    }

    if (syncRoute) {
      await _syncRoute(destination);
    }
  }

  Future<void> handlePageChanged(
    int index, {
    required bool syncRoute,
  }) async {
    final AppDestination destination = AppDestination.values[index];
    if (destination != currentDestination) {
      _updateSelection(destination);
    }

    if (syncRoute) {
      await _syncRoute(destination);
    }
  }

  void toggleSidebar() {
    if (!_initialized) {
      return;
    }

    sidebarController.toggleExtended();
  }

  Future<void> _syncRoute(AppDestination destination) async {
    if (_currentRoutePath.value == destination.route) {
      return;
    }

    _currentRoutePath.value = destination.route;
    await SystemNavigator.routeInformationUpdated(
      uri: Uri.parse(destination.route),
      replace: true,
    );
  }

  void _updateSelection(AppDestination destination) {
    _currentDestination.value = destination;

    if (_initialized) {
      sidebarController.selectIndex(destination.index);
    }
  }

  @override
  void onClose() {
    if (_initialized) {
      pageController.dispose();
      sidebarController.dispose();
    }
    super.onClose();
  }
}
