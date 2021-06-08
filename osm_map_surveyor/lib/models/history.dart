class History {
  int id;
  int storeId;
  int buildingId;
  String referenceName;
  String accountId;
  String accountName;
  int role;
  int action;
  String createDate;
  String modifyDate;
  String geom;
  String note;
 
  History(
      {this.id,
      this.storeId,
      this.buildingId,
      this.referenceName,
      this.accountId,
      this.accountName,
      this.role,
      this.action,
      this.createDate,
      this.modifyDate,
      this.geom,
      this.note});

  History.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    storeId = json['storeId'];
    buildingId = json['buildingId'];
    referenceName = json['referenceName'];
    accountId = json['accountId'];
    accountName = json['accountName'];
    role = json['role'];
    action = json['action'];
    createDate = json['createDate'];
    modifyDate = json['modifyDate'];
    geom = json['geom'];
    note = json['note'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['storeId'] = this.storeId;
    data['buildingId'] = this.buildingId;
    data['referenceName'] = this.referenceName;
    data['accountId'] = this.accountId;
    data['accountName'] = this.accountName;
    data['role'] = this.role;
    data['action'] = this.action;
    data['createDate'] = this.createDate;
    data['modifyDate'] = this.modifyDate;
    data['geom'] = this.geom;
    data['note'] = this.note;
    return data;
  }
}