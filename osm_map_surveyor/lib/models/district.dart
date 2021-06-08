import 'package:osm_map_surveyor/models/ward.dart';

class District {
  int id;
  String name;
  List<Ward> wards;

  District({this.id, this.name, this.wards});

  District.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['wards'] != null) {
      wards = new List<Ward>();
      json['wards'].forEach((v) {
        wards.add(new Ward.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    if (this.wards != null) {
      data['wards'] = this.wards.map((v) => v.toJson()).toList();
    }
    return data;
  }
}