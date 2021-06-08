import 'package:osm_map_surveyor/models/store.dart';

class FloorArea {
  int id;
  String name;
  int floorId;
  bool isRequestDeleted;
  List<Store> stores;

  FloorArea(
    {this.id,
    this.name,
    this.floorId,
    this.isRequestDeleted,
    this.stores}
  );

  FloorArea.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    floorId = json['floorId'];
    isRequestDeleted = json['isRequestDeleted'];
    if (json['stores'] != null) {
      stores = new List<Store>();
      json['stores'].forEach((v) {
        stores.add(new Store.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['floorId'] = this.floorId;
    data['isRequestDeleted'] = this.isRequestDeleted;
    if (this.stores != null) {
      data['stores'] = this.stores.map((v) => v.toJson()).toList();
    }
    return data;
  }
}