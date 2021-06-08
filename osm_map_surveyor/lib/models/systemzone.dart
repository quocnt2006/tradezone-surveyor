class SystemZone {
  int id;
  String name;
  String geom;
  int wardId;
  String createDate;
  String modifyDate;
  int weight;
  bool isMySystemZone;

  SystemZone(
      {this.id,
      this.name,
      this.geom,
      this.wardId,
      this.createDate,
      this.modifyDate,
      this.weight,
      this.isMySystemZone});

  SystemZone.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    geom = json['geom']['coordinates'].toString();
    wardId = json['wardId'];
    createDate = json['createDate'];
    modifyDate = json['modifyDate'];
    weight = json['weight'];
    isMySystemZone = json['isMySystemZone'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['geom'] = this.geom;
    data['wardId'] = this.wardId;
    data['createDate'] = this.createDate;
    data['modifyDate'] = this.modifyDate;
    data['weight'] = this.weight;
    data['isMySystemZone'] = this.isMySystemZone;
    return data;
  }
}