import 'package:osm_map_surveyor/models/store.dart';

class ListStores {
  int pageNumber;
  int pageSize;
  int totalNumberOfPages;
  int totalNumberOfRecords;
  List<Store> results;

  ListStores(
      {this.pageNumber,
      this.pageSize,
      this.totalNumberOfPages,
      this.totalNumberOfRecords,
      this.results});

  ListStores.fromJson(Map<String, dynamic> json) {
    pageNumber = json['pageNumber'];
    pageSize = json['pageSize'];
    totalNumberOfPages = json['totalNumberOfPages'];
    totalNumberOfRecords = json['totalNumberOfRecords'];
    if (json['results'] != null) {
      results = new List<Store>();
      json['results'].forEach((v) {
        results.add(new Store.fromJson(v));
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