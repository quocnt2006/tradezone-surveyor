import 'package:osm_map_surveyor/models/streetsegment.dart';

class ListStreetSegments {
  List<StreetSegment> listStreetSegment;

  ListStreetSegments({this.listStreetSegment});

  ListStreetSegments.fromJson(Map<String, dynamic> json) {
    if (json['listStreetSegment'] != null) {
      listStreetSegment = new List<StreetSegment>();
      json['listStreetSegment'].forEach((v) {
        listStreetSegment.add(new StreetSegment.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.listStreetSegment != null) {
      data['listStreetSegment'] = this.listStreetSegment.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
