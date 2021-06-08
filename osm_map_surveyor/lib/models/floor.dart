import 'package:osm_map_surveyor/models/floorarea.dart';

class Floor {
  int id;
  int floorNumber;
  String name;
  int buildingId;
  bool isRequestDeleted;
  List<FloorArea> floorAreas;

  Floor(
    {this.id,
    this.floorNumber,
    this.name,
    this.isRequestDeleted,
    this.floorAreas,
    this.buildingId,}
  );

  Floor.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    floorNumber = json['floorNumber'];
    name = json['name'];
    buildingId = json['buildingId'];
    isRequestDeleted = json['isRequestDeleted'];
    if (json['floorAreas'] != null) {
      floorAreas = new List<FloorArea>();
      json['floorAreas'].forEach((v) {
        floorAreas.add(new FloorArea.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['floorNumber'] = this.floorNumber;
    data['name'] = this.name;
    data['buildingId'] = this.buildingId;
    data['isRequestDeleted'] = this.isRequestDeleted;
    if (this.floorAreas != null) {
      data['floorAreas'] = this.floorAreas.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
