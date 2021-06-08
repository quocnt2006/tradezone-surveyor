import 'dart:convert';

class StreetSegment {
  int id;
  String name;
  String geom;
  String createDate;
  String modifyDate;
  int wardId;
  int streetId;

  StreetSegment(
      {this.id,
      this.name,
      this.geom,
      this.createDate,
      this.modifyDate,
      this.wardId,
      this.streetId});

  StreetSegment.fromJson(Map<String, dynamic> json) {
    var geomTmp = jsonEncode(json['geom']);
    id = json['id'];
    name = json['name'];
    geom = geomTmp;
    createDate = json['createDate'];
    modifyDate = json['modifyDate'];
    wardId = json['wardId'];
    streetId = json['streetId'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['geom'] = this.geom;
    data['createDate'] = this.createDate;
    data['modifyDate'] = this.modifyDate;
    data['wardId'] = this.wardId;
    data['streetId'] = this.streetId;
    return data;
  }
}
