import 'dart:convert';
import 'package:osm_map_surveyor/models/buildingstreetsegment.dart';
import 'package:osm_map_surveyor/models/floor.dart';

class Building {
  int id;
  String name;
  int osmId;
  String coordinateString;
  String imageUrl;
  String type;
  bool active;
  int numberOfFloor;
  int campusId;
  String address;
  List<BuildingStreetSegments> buildingStreetSegments;
  List<int> streetSegmentIds;
  List<Floor> floors;
  int status;
  int systemZoneId;
  bool isEditable;

  Building(
    {this.id,
    this.name,
    this.osmId,
    this.coordinateString,
    this.imageUrl,
    this.type,
    this.active,
    this.numberOfFloor,
    this.campusId,
    this.address,
    this.buildingStreetSegments,
    this.streetSegmentIds,
    this.floors,
    this.status,
    this.systemZoneId, 
    this.isEditable}
  );

  Building.fromJson(Map<String, dynamic> json) {
    var jsonaddress = json['address'];
    var geom = json['geom'];
    id = json['id'];
    name = json['name'];
    osmId = json['osmId'];
    if (geom != null) {
      coordinateString = jsonEncode(geom['coordinates'][0][0]);
    } else {
      coordinateString = json['coordinateString'];
    }
    imageUrl = json['imageUrl'];
    type = json['type'];
    active = json['active'];
    numberOfFloor = json['numberOfFloor'];
    campusId = json['campusId'];
    address = jsonaddress;
    if (json['buildingStreetSegments'] != null) {
      buildingStreetSegments = new List<BuildingStreetSegments>();
      json['buildingStreetSegments'].forEach((v) {
        buildingStreetSegments.add(new BuildingStreetSegments.fromJson(v));
      });
      streetSegmentIds = new List<int>();
      buildingStreetSegments.forEach((buildingStreetSegment) { 
        streetSegmentIds.add(buildingStreetSegment.streetSegmentId);
      });
    }
    if (json['floors'] != null) {
      floors = new List<Floor>();
      json['floors'].forEach((v) {
        floors.add(new Floor.fromJson(v));
      });
    }
    status = json['status'];
    systemZoneId = json['systemZoneId'];
    isEditable = json['isEditable'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['coordinateString'] = this.coordinateString;
    data['imageUrl'] = this.imageUrl;
    data['type'] = this.type;
    data['active'] = this.active;
    data['numberOfFloor'] = this.numberOfFloor;
    data['campusId'] = this.campusId;
    data['address'] = this.address;
    data['streetSegmentIds'] = this.streetSegmentIds;
    if (this.floors != null) {
      data['floors'] = this.floors.map((v) => v.toJson()).toList();
    }
    if (this.buildingStreetSegments != null) {
      data['buildingStreetSegments'] = this.buildingStreetSegments.map((v) => v.toJson()).toList();
    }
    data['systemZoneId'] = this.systemZoneId;
    data['osmId'] = this.osmId;
    data['isEditable'] = this.isEditable;
    return data;
  }
}
