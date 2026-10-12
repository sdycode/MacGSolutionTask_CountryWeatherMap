import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/config/api_config.dart';
import '../../../core/entities/coordinates.dart';
import '../../../core/widgets/section_card.dart';

class LocationMap extends StatefulWidget {
  const LocationMap({
    super.key,
    required this.countryPoint,
    required this.pinnedPoint,
    required this.onPinMoved,
  });

  final Coordinates countryPoint;
  final Coordinates pinnedPoint;
  final ValueChanged<Coordinates> onPinMoved;

  @override
  State<LocationMap> createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  static const _initialZoom = 4.5;

  final _mapController = MapController();

  LatLng _toLatLng(Coordinates point) =>
      LatLng(point.latitude, point.longitude);

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _resetPin() {
    _mapController.move(_toLatLng(widget.countryPoint), _initialZoom);
    widget.onPinMoved(widget.countryPoint);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionCard(
      title: 'Location',
      icon: Icons.map_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 260,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _toLatLng(widget.countryPoint),
                      initialZoom: _initialZoom,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                      onTap: (tapPosition, point) {
                        final longitude = (point.longitude + 180) % 360 - 180;
                        widget.onPinMoved(
                          Coordinates(point.latitude, longitude),
                        );
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: ApiConfig.mapTileUrl,
                        userAgentPackageName: ApiConfig.appPackageName,
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _toLatLng(widget.pinnedPoint),
                            width: 40,
                            height: 40,
                            alignment: Alignment.topCenter,
                            child: Icon(
                              Icons.location_on,
                              size: 40,
                              color: theme.colorScheme.error,
                            ),
                          ),
                        ],
                      ),
                      const SimpleAttributionWidget(
                        source: Text('OpenStreetMap contributors'),
                      ),
                    ],
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: FilledButton.tonalIcon(
                      onPressed: _resetPin,
                      icon: const Icon(Icons.my_location, size: 18),
                      label: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                Icons.touch_app_outlined,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tap anywhere on the map to see the weather there.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
