enum MapTileCachePolicy {
  networkOnly('Только сеть'),
  cacheFirst('Сначала кэш'),
  offlineOnly('Только офлайн');

  const MapTileCachePolicy(this.label);

  final String label;
}

class MapTileSourceConfig {
  const MapTileSourceConfig({
    required this.providerId,
    required this.providerLabel,
    required this.urlTemplate,
    required this.userAgentPackageName,
    required this.attributionLabel,
    required this.supportsOfflineCache,
    required this.cachePolicy,
  });

  final String providerId;
  final String providerLabel;
  final String urlTemplate;
  final String userAgentPackageName;
  final String attributionLabel;
  final bool supportsOfflineCache;
  final MapTileCachePolicy cachePolicy;
}

abstract interface class MapTileProvider {
  MapTileSourceConfig get sourceConfig;
}

class OpenStreetMapTileProvider implements MapTileProvider {
  const OpenStreetMapTileProvider({
    this.userAgentPackageName = 'com.example.day_desk',
  });

  final String userAgentPackageName;

  @override
  MapTileSourceConfig get sourceConfig {
    return MapTileSourceConfig(
      providerId: 'open_street_map',
      providerLabel: 'OpenStreetMap',
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: userAgentPackageName,
      attributionLabel: 'OpenStreetMap contributors',
      supportsOfflineCache: false,
      cachePolicy: MapTileCachePolicy.networkOnly,
    );
  }
}
