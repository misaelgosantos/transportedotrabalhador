import 'dart:math';

abstract final class GeoMathUtils {
  static double fastDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const radiansPerDegree = 0.017453292519943295;
    final haversine =
        0.5 -
        cos((lat2 - lat1) * radiansPerDegree) / 2 +
        cos(lat1 * radiansPerDegree) *
            cos(lat2 * radiansPerDegree) *
            (1 - cos((lon2 - lon1) * radiansPerDegree)) /
            2;
    return 12742 * asin(sqrt(haversine));
  }
}
