class BuildingAnalysis {
  int buildingId;
  String buildingName;
  int segmentId;
  String segmentName;
  String timeSlot;
  int primaryAge;
  int potentialCustomers;

  BuildingAnalysis(
      {this.buildingId,
      this.buildingName,
      this.segmentId,
      this.segmentName,
      this.timeSlot,
      this.primaryAge,
      this.potentialCustomers});

  BuildingAnalysis.fromJson(Map<String, dynamic> json) {
    buildingId = json['buildingId'];
    buildingName = json['buildingName'];
    segmentId = json['segmentId'];
    segmentName = json['segmentName'];
    timeSlot = json['timeSlot'];
    primaryAge = json['primaryAge'];
    potentialCustomers = json['potentialCustomers'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['buildingId'] = this.buildingId;
    data['buildingName'] = this.buildingName;
    data['segmentId'] = this.segmentId;
    data['segmentName'] = this.segmentName;
    data['timeSlot'] = this.timeSlot;
    data['primaryAge'] = this.primaryAge;
    data['potentialCustomers'] = this.potentialCustomers;
    return data;
  }
}