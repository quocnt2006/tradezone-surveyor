import 'dart:convert';
import 'package:osm_map_surveyor/models/history.dart';
import 'package:osm_map_surveyor/models/storestreetsegments.dart';

class StorePost {
  int id;
  String name;
  String coordinateString;
  String createDate;
  int brandId;
  String address;
  int floorAreaId;
  String floorAreaName;
  String brandName;
  String type;
  int status;
  List<StoreStreetSegments> storeStreetSegments;
  String imageUrl;
  int referenceId;
  int abilityToServe;
  int systemZoneId;
  String timeSlot;
  History history;
  List<int> streetSegmentIds;

  StorePost({this.id,
    this.name,
    this.coordinateString,
    this.createDate,
    this.brandId,
    this.address,
    this.floorAreaId,
    this.floorAreaName,
    this.brandName,
    this.type,
    this.status,
    this.storeStreetSegments,
    this.imageUrl,
    this.referenceId,
    this.abilityToServe,
    this.systemZoneId,
    this.timeSlot,
    this.history,
    this.streetSegmentIds,}
  );

  StorePost.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    var geom = json['geom'];
    if (geom != null) {
      coordinateString = jsonEncode(geom['coordinates'][0][0]);
    } else {
      coordinateString = json['coordinateString'];
    }
    createDate = json['createDate'];
    timeSlot = json['timeSlot'];
    abilityToServe = json['abilityToServe'];
    brandId = json['brandId'];
    address = json['address'];
    floorAreaId = json['floorAreaId'];
    floorAreaName = json['floorAreaName'];
    brandName = json['brandName'];
    type = json['type'];
    status = json['status'];
    if (json['storeStreetSegments'] != null) {
      storeStreetSegments = new List<StoreStreetSegments>();
      json['storeStreetSegments'].forEach((v) {
        storeStreetSegments.add(new StoreStreetSegments.fromJson(v));
      });
      streetSegmentIds = new List<int>();
      storeStreetSegments.forEach((streetsegment) {
        streetSegmentIds.add(streetsegment.storeId);
      });
    }
    imageUrl = json['imageUrl'];
    referenceId = json['referenceId'];
    history = json['history'] != null ? new History.fromJson(json['history']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['coordinateString'] = this.coordinateString;
    data['createDate'] = this.createDate;
    data['timeSlot'] = this.timeSlot;
    data['abilityToServe'] = this.abilityToServe;
    data['brandId'] = this.brandId;
    data['address'] = this.address;
    data['floorAreaId'] = this.floorAreaId;
    data['floorAreaName'] = this.floorAreaName;
    data['brandName'] = this.brandName;
    data['type'] = this.type;
    data['status'] = this.status;
    if (this.storeStreetSegments != null) {
      data['storeStreetSegments'] = this.storeStreetSegments.map((v) => v.toJson()).toList();
    }
    data['streetSegmentIds'] = this.streetSegmentIds;
    data['imageUrl'] = this.imageUrl;
    data['referenceId'] = this.referenceId;
    if (this.history != null) {
      data['history'] = this.history.toJson();
    }
    return data;
  }
}
