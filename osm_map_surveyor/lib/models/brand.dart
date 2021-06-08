class Brand {
  int id;
  String name;
  bool active;
  String iconUrl;
  String imageUrl;
  int segmentId;
  String segmentName;

  Brand(
      {this.id,
      this.name,
      this.active,
      this.iconUrl,
      this.imageUrl,
      this.segmentId,
      this.segmentName});

  Brand.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    active = json['active'];
    iconUrl = json['iconUrl'];
    imageUrl = json['imageUrl'];
    segmentId = json['segmentId'];
    segmentName = json['segmentName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['active'] = this.active;
    data['iconUrl'] = this.iconUrl;
    data['imageUrl'] = this.imageUrl;
    data['segmentId'] = this.segmentId;
    data['segmentName'] = this.segmentName;
    return data;
  }
}
