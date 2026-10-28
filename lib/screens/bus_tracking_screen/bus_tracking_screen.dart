import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../services/location_service.dart';
import '../../services/mock_transport_service.dart';
import '../../utils/geo_math_utils.dart';

class BusTrackingScreen extends StatefulWidget {
  const BusTrackingScreen({super.key, required this.linhaData});

  final Map<String, dynamic> linhaData;

  @override
  State<BusTrackingScreen> createState() => _BusTrackingScreenState();
}

class _BusTrackingScreenState extends State<BusTrackingScreen> {
  static const _tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const _mapAttribution = '© OpenStreetMap contributors';

  final _mapController = MapController();
  final _locationService = LocationService();
  Timer? _vanTimer;
  StreamSubscription<Position>? _locationSubscription;

  late final int _lineId;
  late final int _direction;
  late final String _lineCode;
  late final String _lineName;
  late final String _directionName;
  late final LatLng _initialMapCenter;
  List<LatLng> _routePoints = [];
  LatLng? _vanLocation;

  LatLng? _userLocation;
  bool _mapReady = false;
  bool _routeLoading = true;
  bool _locationLoading = false;
  bool _showAppSettingsButton = false;
  bool _showLocationSettingsButton = false;
  String? _routeError;
  String? _locationError;

  Color get _lineColor =>
      _direction == 1 ? const Color(0xFF16A34A) : const Color(0xFF0284C7);

  @override
  void initState() {
    super.initState();
    _lineId = widget.linhaData['idLinha'] as int? ?? 1;
    _direction = widget.linhaData['direction'] as int? ?? 1;
    _lineCode = widget.linhaData['codigo']?.toString() ?? 'T1';
    _lineName = widget.linhaData['nome']?.toString() ?? 'Linha de transporte';
    _directionName =
        widget.linhaData['directionName']?.toString() ?? 'Rota simulada';
    _initialMapCenter = MockTransportService.getRoutePoints(
      _lineId,
      _direction,
    ).first;
    _vanTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || _routePoints.isEmpty) return;
      setState(() {
        _vanLocation = MockTransportService.getVehiclePosition(
          _lineId,
          _direction,
          routePoints: _routePoints,
        );
      });
    });
    _loadRoadRoute();
    _loadPreviouslyAllowedLocation();
  }

  Future<void> _loadRoadRoute() async {
    setState(() {
      _routeLoading = true;
      _routeError = null;
      _routePoints = [];
      _vanLocation = null;
    });

    try {
      final points = await MockTransportService.getRoadRoutePoints(
        _lineId,
        _direction,
      );
      if (!mounted) return;
      setState(() {
        _routePoints = points;
        _vanLocation = MockTransportService.getVehiclePosition(
          _lineId,
          _direction,
          routePoints: points,
        );
        _routeLoading = false;
      });
      _fitRoute();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _routeLoading = false;
        _routeError = error.toString();
      });
    }
  }

  void _fitRoute() {
    if (!_mapReady || _routePoints.isEmpty) return;
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(_routePoints),
        padding: const EdgeInsets.fromLTRB(32, 120, 32, 240),
        maxZoom: 14.5,
      ),
    );
  }

  Future<void> _loadPreviouslyAllowedLocation() async {
    final permission = await _locationService.checkPermissionState();
    if (!mounted || permission != LocationPermissionState.granted) return;

    try {
      _userLocation = await _locationService.getCurrentLocation(
        requestPermission: false,
      );
      await _startLocationStream();
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) setState(() => _locationError = error.toString());
    }
  }

  Future<void> _requestLocation() async {
    setState(() {
      _locationLoading = true;
      _locationError = null;
      _showAppSettingsButton = false;
      _showLocationSettingsButton = false;
    });

    try {
      final permissionState = await _locationService
          .requestLocationPermission();
      if (permissionState != LocationPermissionState.granted) {
        switch (permissionState) {
          case LocationPermissionState.denied:
            _locationError = kIsWeb
                ? 'Permita a localização nas configurações do navegador e tente novamente.'
                : 'A permissão de localização foi negada. Permita o acesso e tente novamente.';
          case LocationPermissionState.deniedForever:
            _locationError = kIsWeb
                ? 'A localização está bloqueada no navegador. Altere a permissão do site para permitir.'
                : 'A localização está bloqueada para este app. Ative a permissão nas configurações.';
            _showAppSettingsButton = !kIsWeb;
          case LocationPermissionState.serviceDisabled:
            _locationError =
                'Ative o serviço de localização do dispositivo e tente novamente.';
            _showLocationSettingsButton = !kIsWeb;
          case LocationPermissionState.granted:
            break;
        }
        return;
      }

      final location = await _locationService.getCurrentLocation(
        requestPermission: false,
      );
      if (location != null) {
        _userLocation = location;
        await _startLocationStream();
        _centerMap(location);
      }
    } catch (error) {
      _locationError = error.toString();
    } finally {
      if (mounted) setState(() => _locationLoading = false);
    }
  }

  Future<void> _startLocationStream() async {
    await _locationSubscription?.cancel();
    _locationSubscription = _locationService.startLocationStream(
      onLocationUpdated: (location) {
        if (mounted) setState(() => _userLocation = location);
      },
      onError: (error) {
        if (mounted) setState(() => _locationError = error.toString());
      },
    );
  }

  void _centerMap(LatLng location) {
    if (!_mapReady) return;
    _mapController.move(location, 15);
  }

  @override
  void dispose() {
    _vanTimer?.cancel();
    _locationSubscription?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_routeLoading) {
      return _buildRouteStatus(
        context,
        icon: const CircularProgressIndicator(),
        title: 'Carregando o mapa',
        message:
            'Buscando o trajeto pelas ruas. Isso pode levar alguns segundos.',
      );
    }

    final distanceKm = _userLocation == null || _vanLocation == null
        ? null
        : GeoMathUtils.fastDistance(
            _userLocation!.latitude,
            _userLocation!.longitude,
            _vanLocation!.latitude,
            _vanLocation!.longitude,
          );
    final walkingMinutes = distanceKm == null
        ? null
        : (distanceKm / 4.5 * 60).round();

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialMapCenter,
              interactionOptions: InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              initialZoom: 14.5,
              minZoom: 10,
              maxZoom: 19,
              onMapReady: () {
                _mapReady = true;
                _fitRoute();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _tileUrl,
                userAgentPackageName: 'transporte_do_trabalhador',
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    color: _lineColor.withValues(alpha: 0.8),
                    strokeWidth: 5,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  if (_vanLocation case final vanLocation?)
                    Marker(
                      point: vanLocation,
                      width: 54,
                      height: 66,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _lineColor,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _lineCode,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Image.asset(
                            'assets/images/icon_bus.png',
                            width: 38,
                            height: 38,
                          ),
                        ],
                      ),
                    ),
                  if (_userLocation case final location?)
                    Marker(
                      point: location,
                      width: 48,
                      height: 58,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Você',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Image.asset(
                            'assets/images/icon_user.png',
                            width: 36,
                            height: 36,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              RichAttributionWidget(
                attributions: [TextSourceAttribution(_mapAttribution)],
              ),
            ],
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Card(
                    child: ListTile(
                      leading: IconButton(
                        tooltip: 'Voltar para as linhas',
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      title: Text('Linha $_lineCode'),
                      subtitle: Text(
                        '$_lineName\n$_directionName · localização simulada',
                      ),
                      isThreeLine: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_routeError != null) ...[
                            Text(
                              'Não foi possível carregar o trajeto pelas ruas. '
                              'Você ainda pode usar o mapa e sua localização.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _loadRoadRoute,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Tentar carregar o trajeto'),
                            ),
                          ],
                          if (distanceKm == null)
                            const Text(
                              'Toque em "Minha localização" e permita o acesso '
                              'para mostrar sua posição no mapa.',
                              textAlign: TextAlign.center,
                            )
                          else
                            Text(
                              '${distanceKm.toStringAsFixed(1)} km da van'
                              '${walkingMinutes == null ? '' : ' · cerca de $walkingMinutes min a pé'}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          if (_locationError != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _locationError!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ],
                          if (_showAppSettingsButton ||
                              _showLocationSettingsButton) ...[
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: _showAppSettingsButton
                                  ? _locationService.openAppSettings
                                  : _locationService.openLocationSettings,
                              icon: const Icon(Icons.settings),
                              label: Text(
                                _showAppSettingsButton
                                    ? 'Abrir configurações do app'
                                    : 'Ativar localização do dispositivo',
                              ),
                            ),
                          ],
                          if (_locationError != null && kIsWeb) ...[
                            const SizedBox(height: 6),
                            Text(
                              'No navegador, use o ícone ao lado do endereço do site para permitir a localização. Ela só funciona em HTTPS ou localhost.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: _locationLoading
                                      ? null
                                      : _requestLocation,
                                  icon: _locationLoading
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Icon(Icons.my_location),
                                  label: const Text('Minha localização'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filledTonal(
                                tooltip: 'Centralizar na van',
                                onPressed: _vanLocation == null
                                    ? null
                                    : () => _centerMap(_vanLocation!),
                                icon: const Icon(Icons.directions_bus),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Demonstração: posição da van simulada',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteStatus(
    BuildContext context, {
    required Widget icon,
    required String title,
    required String message,
    Widget? action,
  }) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Voltar para as linhas',
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text('Linha $_lineCode'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                if (action != null) ...[const SizedBox(height: 20), action],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
