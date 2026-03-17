import 'package:latlong2/latlong.dart';

abstract final class AppMapConfig {
  static const LatLng moscowCenter = LatLng(55.7558, 37.6176);
  static const double initialZoom = 10.8;
  static const double minZoom = 4;
  static const double maxZoom = 18.5;
  static const String seedLocationLabel = 'Москва';
}
