import 'package:osm_map_surveyor/models/segment.dart';
import 'package:osm_map_surveyor/provider/segment_provider.dart';

class SegmentRepository {
  SegmentProvider _segmentProvider = SegmentProvider();

  Future<List<Segment>> fetchListSegments() async {
    return await _segmentProvider.fetchListSegments();
  }
}