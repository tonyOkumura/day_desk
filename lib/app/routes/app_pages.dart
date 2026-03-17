import 'package:get/get.dart';

import '../bindings/main_layout_binding.dart';
import '../navigation/app_destination.dart';
import '../shell/main_layout_page.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const String initial = AppRoutes.today;

  static final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    ...AppDestination.values.map(_buildMainLayoutRoute),
  ];

  static GetPage<dynamic> _buildMainLayoutRoute(
    AppDestination destination,
  ) {
    return GetPage<dynamic>(
      name: destination.route,
      page: () => MainLayoutPage(initialDestination: destination),
      binding: MainLayoutBinding(),
      transition: Transition.noTransition,
    );
  }
}
