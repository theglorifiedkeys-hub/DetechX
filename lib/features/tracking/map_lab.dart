import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme.dart';
import '../../core/surfaces.dart';
import 'dotted_map.dart';

class MapLab extends StatefulWidget {
  const MapLab({super.key});

  @override
  State<MapLab> createState() => _MapLabState();
}

class _MapLabState extends State<MapLab> with SingleTickerProviderStateMixin {
  static const _home = LatLng(-6.7706, 39.2512);
  static const _route = [
    LatLng(-6.7902, 39.2259),
    LatLng(-6.7869, 39.2323),
    LatLng(-6.7819, 39.2364),
    LatLng(-6.7808, 39.2429),
    LatLng(-6.7751, 39.2458),
    _home,
  ];
  static const _center = LatLng(-6.780, 39.239);
  late final _trip = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 22),
  );
  final _map = MapController();
  bool _street = false, _locating = false, _tileError = false;
  LatLng? _device;
  String? _locationHint;

  @override
  void dispose() {
    _trip.dispose();
    _map.dispose();
    super.dispose();
  }

  void _replay() {
    if (MediaQuery.disableAnimationsOf(context)) {
      _trip.value = 1;
    } else {
      _trip.forward(from: 0);
    }
  }

  Future<void> _locate() async {
    if (_locating) return;
    setState(() {
      _locating = true;
      _locationHint = null;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw StateError('Turn on location services and try again.');
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied)
        permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw StateError(
          'Allow location in your device or browser settings to see your pin.',
        );
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 12),
        ),
      );
      if (!mounted) return;
      final point = LatLng(position.latitude, position.longitude);
      setState(() => _device = point);
      _map.move(point, 14);
    } catch (error) {
      if (mounted)
        setState(
          () => _locationHint = error is StateError
              ? error.message
              : 'Location couldn’t be found. On web, use HTTPS and allow location access.',
        );
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  LatLng _van(double fraction) {
    final progress = fraction * (_route.length - 1);
    final index = progress.floor().clamp(0, _route.length - 2).toInt();
    final t = progress - index;
    final a = _route[index], b = _route[index + 1];
    return LatLng(
      a.latitude + (b.latitude - a.latitude) * t,
      a.longitude + (b.longitude - a.longitude) * t,
    );
  }

  Widget _pin(IconData icon, Color color) => CircleAvatar(
    backgroundColor: color,
    child: Icon(icon, color: Colors.white, size: 18),
  );

  Widget _streetMap() => FlutterMap(
    mapController: _map,
    options: const MapOptions(
      initialCenter: _center,
      initialZoom: 12.8,
      minZoom: 4,
      maxZoom: 19,
    ),
    children: [
      TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.detechx.detechx',
        maxNativeZoom: 19,
        errorTileCallback: (_, _, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _street && !_tileError)
              setState(() => _tileError = true);
          });
        },
      ),
      PolylineLayer(
        polylines: [
          Polyline(
            points: _route,
            color: AppColors.auraCoralDeep,
            strokeWidth: 4,
            borderColor: Colors.white,
            borderStrokeWidth: 1,
          ),
        ],
      ),
      AnimatedBuilder(
        animation: _trip,
        builder: (_, _) => MarkerLayer(
          markers: [
            Marker(
              point: _home,
              width: 34,
              height: 34,
              child: _pin(Icons.home_rounded, AppColors.auraCoralDeep),
            ),
            Marker(
              point: _van(_trip.value),
              width: 34,
              height: 34,
              child: _pin(Icons.local_shipping_rounded, AppColors.inkPrimary),
            ),
            if (_device case final point?)
              Marker(
                point: point,
                width: 30,
                height: 30,
                child: _pin(Icons.my_location, Colors.blue.shade700),
              ),
          ],
        ),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Dar es Salaam map lab')),
    body: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 6, 15, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 7,
              children: [
                ChoiceChip(
                  label: const Text('Illustrated'),
                  selected: !_street,
                  onSelected: (_) => setState(() {
                    _street = false;
                    _locationHint = null;
                  }),
                ),
                ChoiceChip(
                  label: const Text('Street map'),
                  selected: _street,
                  onSelected: (_) => setState(() {
                    _street = true;
                    _tileError = false;
                  }),
                ),
              ],
            ),
            const SizedBox(height: 7),
            const Text(
              'Sinza → Mikocheni · sample route, not live navigation',
              style: AppTypography.caption,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_street)
                      _streetMap()
                    else
                      Stack(
                        fit: StackFit.expand,
                        children: [
                          const AmbientCoralBackdrop(),
                          DottedVectorMapCanvas(
                            route: const AlwaysStoppedAnimation(1.0),
                            trip: _trip,
                          ),
                        ],
                      ),
                    if (_street)
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Material(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            onTap: () => launchUrl(
                              Uri.https('www.openstreetmap.org', '/copyright'),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(6),
                              child: Text(
                                '© OpenStreetMap contributors',
                                style: TextStyle(fontSize: 11),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            if (_street && _tileError)
              const Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  'Some street tiles are unavailable. Try Illustrated for the offline demo.',
                  style: AppTypography.caption,
                ),
              ),
            if (_locationHint case final hint?)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(hint, style: AppTypography.caption),
              ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 7,
              children: [
                PillButton(
                  'Replay van',
                  _replay,
                  icon: Icons.play_arrow_rounded,
                  height: 42,
                ),
                if (_street) ...[
                  PillButton(
                    _locating ? 'Locating…' : 'My location',
                    _locate,
                    icon: Icons.my_location,
                    dark: false,
                    height: 42,
                  ),
                  IconButton(
                    tooltip: 'Center sample route',
                    onPressed: () => _map.move(_center, 12.8),
                    icon: const Icon(Icons.center_focus_strong),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
