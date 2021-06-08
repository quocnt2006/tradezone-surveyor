import 'package:osm_map_surveyor/models/district.dart';

class City {
  int id;
  String name;
  List<District> districts;

  City({this.id, this.name, this.districts});

  City.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['districts'] != null) {
      districts = new List<District>();
      json['districts'].forEach((v) {
        districts.add(new District.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    if (this.districts != null) {
      data['districts'] = this.districts.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
