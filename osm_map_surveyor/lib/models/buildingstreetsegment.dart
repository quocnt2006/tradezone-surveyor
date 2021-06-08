class BuildingStreetSegments {
  int buildingId;
  int streetSegmentId;

  BuildingStreetSegments({this.buildingId, this.streetSegmentId});

  BuildingStreetSegments.fromJson(Map<String, dynamic> json) {
    buildingId = json['buildingId'];
    streetSegmentId = json['streetSegmentId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['buildingId'] = this.buildingId;
    data['streetSegmentId'] = this.streetSegmentId;
    return data;
  }
}