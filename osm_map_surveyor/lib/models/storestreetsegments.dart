class StoreStreetSegments {
  int storeId;
  int streetSegmentId;

  StoreStreetSegments({this.storeId, this.streetSegmentId});

  StoreStreetSegments.fromJson(Map<String, dynamic> json) {
    storeId = json['storeId'];
    streetSegmentId = json['streetSegmentId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['storeId'] = this.storeId;
    data['streetSegmentId'] = this.streetSegmentId;
    return data;
  }
}