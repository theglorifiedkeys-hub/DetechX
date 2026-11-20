import 'package:detechx/features/location/dar_location.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  test('suggests the nearest covered area but does not invent an address', () {
    expect(suggestDarArea(darAreas['Sinza']!, 25), 'Sinza');
    expect(suggestDarArea(darAreas['Masaki']!, 3500), isNull);
    expect(suggestDarArea(const LatLng(-6.163, 35.752), 20), isNull);
  });
}
