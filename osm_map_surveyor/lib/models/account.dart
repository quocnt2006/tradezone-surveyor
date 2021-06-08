class Account {
  String id;
  String fireBaseUid;
  String fullname;
  String phoneNumber;
  String email;
  int role;
  bool active;
  String fcmToken;
  String createDate;
  int brandId;
  String imageUrl;
  String brandName;
  bool isApproved;

  Account(
    {this.id,
    this.fireBaseUid,
    this.fullname,
    this.phoneNumber,
    this.email,
    this.role,
    this.active,
    this.fcmToken,
    this.createDate,
    this.brandId,
    this.imageUrl,
    this.brandName,
    this.isApproved}
  );

  Account.fromJson(Map<String, dynamic> json) {
    id = json['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'];
    fireBaseUid = json['fireBaseUid'];
    fullname = json['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'];
    phoneNumber = json['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/mobilephone'];
    email = json['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'];
    role = int.parse(json['http://schemas.microsoft.com/ws/2008/06/identity/claims/role']);
    active = true;
    imageUrl = json['ImageUrl'];
    fcmToken = json['FcmToken'];
    brandId= json['BrandId'] == "" ? 0 : int.parse(json['BrandId']);
  }

  Account.fromJsonResponse(Map<String, dynamic> json) {
    id = json['id'];
    fireBaseUid = json['fireBaseUid'];
    fullname = json['fullname'];
    phoneNumber = json['phoneNumber'];
    email = json['email'];
    role = json['role'];
    active = json['active'];
    fcmToken = json['fcmToken'];
    brandId = json['brandId'] == "" || json['brandId'] == null ? 0 : int.parse(json[brandId]);
    imageUrl = json['imageUrl'];
    brandName = json['brandName'];
    isApproved = json['isApproved'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['fireBaseUid'] = this.fireBaseUid;
    data['fullname'] = this.fullname;
    data['phoneNumber'] = this.phoneNumber;
    data['email'] = this.email;
    data['role'] = this.role;
    data['active'] = this.active;
    data['fcmToken'] = this.fcmToken;
    data['createDate'] = this.createDate;
    data['brandId'] = this.brandId;
    data['imageUrl'] = this.imageUrl;
    data['brandName'] = this.brandName;
    data['isApproved'] = this.isApproved;
    return data;
  }
}
