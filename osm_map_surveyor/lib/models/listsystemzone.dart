import 'package:osm_map_surveyor/models/systemzone.dart';

class ListSystemZone {
  int pageNumber;
  int pageSize;
  int totalNumberOfPages;
  int totalNumberOfRecords;
  List<SystemZone> results;

  ListSystemZone(
      {this.pageNumber,
      this.pageSize,
      this.totalNumberOfPages,
      this.totalNumberOfRecords,
      this.results});

  ListSystemZone.fromJson(Map<String, dynamic> json) {
    pageNumber = json['pageNumber'];
    pageSize = json['pageSize'];
    totalNumberOfPages = json['totalNumberOfPages'];
    totalNumberOfRecords = json['totalNumberOfRecords'];
    if (json['results'] != null) {
      results = new List<SystemZone>();
      json['results'].forEach((v) {
        results.add(new SystemZone.fromJson(v));
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