import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class MockTransportService {
  static const _routingHost = 'router.project-osrm.org';
  static const _routingTimeout = Duration(seconds: 20);

  static const _routes = <int, List<LatLng>>{
    1: [
      LatLng(-16.4930, -54.6470),
      LatLng(-16.4930, -54.6400),
      LatLng(-16.4870, -54.6400),
      LatLng(-16.4870, -54.6320),
      LatLng(-16.4800, -54.6320),
      LatLng(-16.4800, -54.6240),
      LatLng(-16.4730, -54.6240),
      LatLng(-16.4730, -54.6160),
      LatLng(-16.4670, -54.6160),
      LatLng(-16.4670, -54.6080),
      LatLng(-16.4610, -54.6080),
    ],
    2: [
      LatLng(-16.4520, -54.6440),
      LatLng(-16.4580, -54.6440),
      LatLng(-16.4580, -54.6380),
      LatLng(-16.4640, -54.6380),
      LatLng(-16.4640, -54.6310),
      LatLng(-16.4710, -54.6310),
      LatLng(-16.4710, -54.6240),
      LatLng(-16.4780, -54.6240),
      LatLng(-16.4780, -54.6170),
      LatLng(-16.4840, -54.6170),
      LatLng(-16.4840, -54.6100),
    ],
    3: [
      LatLng(-16.4880, -54.6120),
      LatLng(-16.4820, -54.6120),
      LatLng(-16.4820, -54.6170),
      LatLng(-16.4760, -54.6170),
      LatLng(-16.4760, -54.6230),
      LatLng(-16.4700, -54.6230),
      LatLng(-16.4700, -54.6290),
      LatLng(-16.4640, -54.6290),
      LatLng(-16.4640, -54.6350),
      LatLng(-16.4580, -54.6350),
      LatLng(-16.4580, -54.6410),
    ],
  };

  static const _lines = <Map<String, dynamic>>[
    {
      'idLinha': 1,
      'codigo': 'T1',
      'nome': 'Centro - Vila Operária',
      'direction': 1,
      'directionName': 'VILA OPERÁRIA → CENTRO',
      'idPercurso': 1,
    },
    {
      'idLinha': 2,
      'codigo': 'T2',
      'nome': 'Centro - Parque Universitário',
      'direction': 2,
      'directionName': 'CENTRO → PARQUE UNIVERSITÁRIO',
      'idPercurso': 2,
    },
    {
      'idLinha': 3,
      'codigo': 'T3',
      'nome': 'Centro - Jardim Atlântico',
      'direction': 1,
      'directionName': 'JARDIM ATLÂNTICO → CENTRO',
      'idPercurso': 3,
    },
  ];

  static List<Map<String, dynamic>> getAllBuses() =>
      _lines.map((line) => Map<String, dynamic>.from(line)).toList();

  static Future<Map<int, List<Map<String, dynamic>>>> getActiveBuses() async {
    return {
      for (final line in _lines)
        line['idLinha'] as int: [
          {
            ...line,
            'vehicles': [
              _vehicleFor(line['idLinha'] as int, line['direction'] as int),
            ],
          },
        ],
    };
  }

  static List<LatLng> getRoutePoints(int lineId, int direction) {
    final points = _routes[lineId];
    if (points == null) {
      throw ArgumentError.value(lineId, 'lineId', 'Linha desconhecida');
    }
    return direction == 1 ? points : points.reversed.toList();
  }

  static Future<List<LatLng>> getRoadRoutePoints(
    int lineId,
    int direction,
  ) async {
    final waypoints = _routes[lineId];
    if (waypoints == null) {
      throw ArgumentError.value(lineId, 'lineId', 'Linha desconhecida');
    }

    final origin = direction == 1 ? waypoints.first : waypoints.last;
    final destination = direction == 1 ? waypoints.last : waypoints.first;
    final uri = Uri.https(
      _routingHost,
      '/route/v1/driving/'
      '${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}',
      {'overview': 'full', 'geometries': 'geojson', 'steps': 'false'},
    );
    final response = await http.get(uri).timeout(_routingTimeout);
    if (response.statusCode != 200) {
      throw StateError(
        'O serviço de rotas respondeu com o status ${response.statusCode}.',
      );
    }

    final data = jsonDecode(response.body);
    if (data is! Map<String, dynamic> || data['code'] != 'Ok') {
      throw StateError('O serviço de rotas não encontrou um percurso.');
    }

    final routes = data['routes'];
    if (routes is! List || routes.isEmpty) {
      throw StateError('O serviço de rotas retornou um percurso vazio.');
    }

    final geometry = routes.first['geometry'];
    final coordinates = geometry is Map<String, dynamic>
        ? geometry['coordinates']
        : null;
    if (coordinates is! List || coordinates.length < 2) {
      throw StateError('A geometria retornada para a rota é inválida.');
    }

    return coordinates.map((coordinate) {
      if (coordinate is! List ||
          coordinate.length < 2 ||
          coordinate[0] is! num ||
          coordinate[1] is! num) {
        throw StateError('O serviço de rotas retornou coordenadas inválidas.');
      }
      return LatLng(
        (coordinate[1] as num).toDouble(),
        (coordinate[0] as num).toDouble(),
      );
    }).toList();
  }

  static LatLng getVehiclePosition(
    int lineId,
    int direction, {
    List<LatLng>? routePoints,
    DateTime? now,
  }) {
    final route = routePoints ?? getRoutePoints(lineId, direction);
    if (route.length < 2) return route.first;

    const cycleDuration = Duration(minutes: 2);
    final elapsed = (now ?? DateTime.now()).millisecondsSinceEpoch;
    final progress =
        (elapsed % cycleDuration.inMilliseconds) / cycleDuration.inMilliseconds;
    final routeProgress = progress * (route.length - 1);
    final segment = routeProgress.floor().clamp(0, route.length - 2);
    final fraction = routeProgress - segment;
    final start = route[segment];
    final end = route[segment + 1];

    return LatLng(
      start.latitude + (end.latitude - start.latitude) * fraction,
      start.longitude + (end.longitude - start.longitude) * fraction,
    );
  }

  static Map<String, dynamic> _vehicleFor(int lineId, int direction) {
    final position = getVehiclePosition(lineId, direction);
    return {
      'idVeiculo': 'VAN-$lineId',
      'lat': position.latitude,
      'lon': position.longitude,
    };
  }
}
