//Quốc gia

class Country {
  int? id;

  int? createdUser;
  String? createdDate;
  bool? deleted;
  String? countryCode;
  String? name;

  Country({this.id, this.createdUser, this.createdDate, this.deleted, this.countryCode, this.name});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      createdUser: json['createdUser'],
      createdDate: json['createdDate'],
      deleted: json['deleted'],
      countryCode: json['countryCode'],
      name: json['name'],
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['createdUser'] = this.createdUser;
    data['createdDate'] = this.createdDate;
    data['deleted'] = this.deleted;
    data['countryCode'] = this.countryCode;
    data['name'] = this.name;
    return data;
  }
}
