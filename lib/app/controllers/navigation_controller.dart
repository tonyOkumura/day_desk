import 'package:get/get.dart';

import '../navigation/app_destination.dart';

class NavigationController extends GetxController {
  final RxString _currentRoute = AppDestination.today.route.obs;

  String get currentRoute => _currentRoute.value;

  void syncRoute(String route) {
    if (_currentRoute.value == route) {
      return;
    }

    _currentRoute.value = route;
  }

  Future<void> navigateTo(AppDestination destination) async {
    if (_currentRoute.value == destination.route) {
      return;
    }

    _currentRoute.value = destination.route;
    await Get.offNamed<dynamic>(destination.route);
  }
}
