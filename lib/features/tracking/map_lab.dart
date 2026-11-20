import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme.dart';
import '../../core/surfaces.dart';
import '../location/dar_location.dart';

class DarStreetMap extends StatefulWidget {
  const DarStreetMap({
    super.key,
    this.trip,
    this.neighborhood = '',
    this.tracking = false,
  });
  final Animation<double>? trip;
  final String neighborhood;
  final bool tracking;
  @override
  State<DarStreetMap> createState() => _DarStreetMapState();
}

class _DarStreetMapState extends State<DarStreetMap> {
  final _controller = MapController();
  bool _locating = false, _tileError = false, _ready = false;
  int _revision = 0;
  LatLng? _device;
  LatLng get _destination =>
      darAreas[widget.neighborhood] ?? darAreas['Mikocheni']!;
  List<LatLng> get _line {
    final start = widget.neighborhood == 'Sinza'
        ? darAreas['Ubungo']!
        : darAreas['Sinza']!;
    final end = _destination;
    return [
      start,
      LatLng(
        start.latitude * .63 + end.latitude * .37,
        start.longitude * .8 + end.longitude * .2,
      ),
      LatLng(
        start.latitude * .30 + end.latitude * .70,
        start.longitude * .34 + end.longitude * .66,
      ),
      end,
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _locate() async {
    if (_locating || !_ready) return;
    setState(() => _locating = true);
    try {
      final position = await readDevicePosition();
      if (!mounted) return;
      final point = LatLng(position.latitude, position.longitude);
      setState(() => _device = point);
      if (_ready) _controller.move(point, 15);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error is LocationProblem
                  ? error.message
                  : 'Hatukuweza kupata eneo. Jaribu tena ukiwa na GPS na intaneti.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  LatLng _point(List<LatLng> line) {
    final n = (widget.trip?.value ?? 0) * (line.length - 1);
    final index = n.floor().clamp(0, line.length - 2).toInt();
    final t = n - index;
    final a = line[index], b = line[index + 1];
    return LatLng(
      a.latitude + (b.latitude - a.latitude) * t,
      a.longitude + (b.longitude - a.longitude) * t,
    );
  }

  Marker _pin(LatLng point, IconData icon, Color color) => Marker(
    point: point,
    width: 38,
    height: 38,
    child: DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(icon, size: 19, color: Colors.white),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final line = _line;
    return Stack(
      fit: StackFit.expand,
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: _destination,
            initialZoom: widget.tracking ? 12 : 13,
            minZoom: 5,
            maxZoom: 18,
            backgroundColor: const Color(0xffe6ecea),
            onMapReady: () => _ready = true,
          ),
          children: [
            TileLayer(
              key: ValueKey(_revision),
              urlTemplate:
                  'https://server.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer/tile/{z}/{y}/{x}',
              userAgentPackageName: 'com.detechx.detechx',
              maxNativeZoom: 18,
              errorTileCallback: (_, _, _) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && !_tileError) setState(() => _tileError = true);
                });
              },
            ),
            if (widget.trip != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: line,
                    strokeWidth: 4,
                    borderStrokeWidth: 2,
                    borderColor: Colors.white,
                    color: AppColors.auraCoralDeep,
                  ),
                ],
              ),
            AnimatedBuilder(
              animation: widget.trip ?? const AlwaysStoppedAnimation(0.0),
              builder: (_, _) => MarkerLayer(
                markers: [
                  _pin(
                    _destination,
                    Icons.home_rounded,
                    AppColors.auraCoralDeep,
                  ),
                  if (widget.trip != null)
                    _pin(
                      _point(line),
                      Icons.local_shipping_rounded,
                      AppColors.inkPrimary,
                    ),
                  if (_device case final point?)
                    _pin(point, Icons.my_location, Colors.blue.shade700),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          right: 10,
          top: widget.tracking ? 112 : 10,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              RoundAction(
                Icons.my_location,
                _locating ? 'Inatafuta eneo' : 'Eneo langu',
                _locate,
              ),
              const SizedBox(height: 5),
              RoundAction(
                Icons.center_focus_strong,
                'Rudi kwenye ramani ya kazi',
                () {
                  if (_ready) {
                    _controller.move(_destination, widget.tracking ? 12 : 13);
                  }
                },
              ),
            ],
          ),
        ),
        if (_tileError)
          Positioned(
            left: 10,
            top: widget.tracking ? 112 : 10,
            child: PillButton(
              'Pakia ramani tena',
              () => setState(() {
                _tileError = false;
                _revision++;
              }),
              icon: Icons.refresh,
              dark: false,
              height: 39,
            ),
          ),
        Positioned(
          left: 8,
          top: widget.tracking ? 94 : null,
          bottom: widget.tracking ? null : 8,
          child: Material(
            color: const Color(0xeeffffff),
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              onTap: () => launchUrl(
                Uri.https('www.arcgis.com', '/home/item.html', {
                  'id': '6e03e8c26aad4b9c92a87c1063ddb0e3',
                }),
              ),
              child: const Padding(
                padding: EdgeInsets.all(5),
                child: Text(
                  'Basemap © Esri & contributors',
                  style: TextStyle(fontSize: 10, color: AppColors.inkPrimary),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class MapLab extends StatelessWidget {
  const MapLab({super.key, this.neighborhood = ''});
  final String neighborhood;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Ramani ya Dar es Salaam')),
    body: SafeArea(top: false, child: DarStreetMap(neighborhood: neighborhood)),
  );
}
