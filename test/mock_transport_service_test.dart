import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:transporte_do_trabalhador/services/mock_transport_service.dart';

void main() {
  group('MockTransportService', () {
    test(
      'provides simulated lines with an active van in each direction',
      () async {
        final lines = MockTransportService.getAllBuses();
        final activeLines = await MockTransportService.getActiveBuses();

        expect(lines, hasLength(3));
        expect(
          activeLines.keys,
          containsAll(lines.map((line) => line['idLinha'])),
        );
        for (final directions in activeLines.values) {
          expect(directions.single['vehicles'], isNotEmpty);
        }
      },
    );

    test('returns a route and moves the simulated van over time', () {
      final route = MockTransportService.getRoutePoints(1, 1);
      final start = MockTransportService.getVehiclePosition(
        1,
        1,
        now: DateTime.fromMillisecondsSinceEpoch(0),
      );
      final later = MockTransportService.getVehiclePosition(
        1,
        1,
        now: DateTime.fromMillisecondsSinceEpoch(30000),
      );

      expect(route, isNotEmpty);
      expect(start, isA<LatLng>());
      expect(later, isA<LatLng>());
      expect(later, isNot(start));
    });

    test('simulated van follows the supplied road geometry', () {
      final roadGeometry = [
        const LatLng(-16.49, -54.64),
        const LatLng(-16.49, -54.63),
        const LatLng(-16.48, -54.63),
      ];

      final position = MockTransportService.getVehiclePosition(
        1,
        1,
        routePoints: roadGeometry,
        now: DateTime.fromMillisecondsSinceEpoch(30000),
      );

      expect(position.latitude, -16.49);
      expect(position.longitude, closeTo(-54.635, 0.000001));
    });
  });
}
