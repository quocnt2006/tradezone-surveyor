import 'package:osm_map_surveyor/models/liststreetsegments.dart';
import 'package:osm_map_surveyor/provider/liststreetsegment_provider.dart';
import 'package:latlong/latlong.dart';

class ListStreetSegmentRepository {
  ListStreetSegmentProvider _listStreetSegmentProvider = ListStreetSegmentProvider();

  Future<ListStreetSegments> fetchListStreetSegments(List<LatLng> points) async {
    return await _listStreetSegmentProvider.fetchListStreetSegments(points);
  }

  Future<ListStreetSegments> fetchListStreetSegmentsByPoint(LatLng point) async {
    return await _listStreetSegmentProvider.fetchListStreetSegmentsByPoint(point);
  }
}
