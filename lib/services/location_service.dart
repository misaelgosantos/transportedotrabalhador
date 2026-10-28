import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum LocationPermissionState {
  granted,
  denied,
  deniedForever,
  serviceDisabled
}

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() {
    return _instance;
  }

  LocationService._internal();

  /// Apenas verifica o estado atual da permissão (Não solicita)
  Future<LocationPermissionState> checkPermissionState() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationPermissionState.serviceDisabled;

    LocationPermission permission = await Geolocator.checkPermission();
    return _mapPermission(permission);
  }

  /// Verifica e, se necessário, solicita permissões geográficas
  Future<LocationPermissionState> requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationPermissionState.serviceDisabled;

    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return _mapPermission(permission);
  }

  LocationPermissionState _mapPermission(LocationPermission permission) {
    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionState.deniedForever;
    }
    if (permission == LocationPermission.denied) {
      return LocationPermissionState.denied;
    }
    return LocationPermissionState.granted;
  }

  /// Abre as configurações do app para o usuário ativar manualmente
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
  
  /// Abre as configurações de localização do dispositivo
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Busca a posição imediata do usuário (One-Shot)
  Future<LatLng?> getCurrentLocation({bool requestPermission = true}) async {
    final state = requestPermission 
      ? await requestLocationPermission() 
      : await checkPermissionState();
      
    if (state != LocationPermissionState.granted) {
      throw Exception(_getErrorMessage(state));
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      throw Exception('Erro ao obter localização: $e');
    }
  }

  String _getErrorMessage(LocationPermissionState state) {
    switch (state) {
      case LocationPermissionState.serviceDisabled:
        return 'GPS desativado. Ative o GPS para continuar.';
      case LocationPermissionState.denied:
        return 'Permissão de localização negada.';
      case LocationPermissionState.deniedForever:
        return 'Permissão de localização negada permanentemente.';
      default:
        return 'Erro desconhecido de localização.';
    }
  }

  /// Abre um Stream de escuta de posições respeitando economia de bateria
  StreamSubscription<Position> startLocationStream({
    required Function(LatLng) onLocationUpdated,
    required Function(Exception) onError,
  }) {
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Atualiza se houver movimento de 10 metros
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        onLocationUpdated(LatLng(position.latitude, position.longitude));
      },
      onError: (e) {
        onError(Exception(e.toString()));
      },
    );
  }
}
