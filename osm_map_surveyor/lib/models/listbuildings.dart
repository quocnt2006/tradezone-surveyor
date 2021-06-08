import 'package:osm_map_surveyor/models/building.dart';

class ListBuildings {
  int pageNumber;
  int pageSize;
  int totalNumberOfPages;
  int totalNumberOfRecords;
  List<Building> results;

  ListBuildings(
      {this.pageNumber,
      this.pageSize,
      this.totalNumberOfPages,
      this.totalNumberOfRecords,
      this.results});

  ListBuildings.fromJson(Map<String, dynamic> json) {
    pageNumber = json['pageNumber'];
    pageSize = json['pageSize'];
    totalNumberOfPages = json['totalNumberOfPages'];
    totalNumberOfRecords = json['totalNumberOfRecords'];
    if (json['results'] != null) {
      results = new List<Building>();
      json['results'].forEach((v) {
        results.add(new Building.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pageNumber'] = this.pageNumber;
    data['pageSize'] = this.pageSize;
    data['totalNumberOfPages'] = this.totalNumberOfPages;
    data['totalNumberOfRecords'] = this.totalNumberOfRecords;
    if (this.results != null) {
      data['results'] = this.results.map((v) => v.toJson()).toList();
    }
    return data;
  }
}