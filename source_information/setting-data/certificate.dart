//Bằng cấp chứng chỉ
class Certificate {
  int? id;
  int? createdUser;
  String? createdDate;
  bool? deleted;
  String? name;
  String? description;

  Certificate({this.id, this.createdUser, this.createdDate, this.deleted, this.name, this.description});

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'] ?? 1,
      createdUser: json['createdUser'],
      createdDate: json['createdDate'],
      deleted: json['deleted'],
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['createdUser'] = this.createdUser;
    data['createdDate'] = this.createdDate;
    data['deleted'] = this.deleted;
    data['name'] = this.name;
    data['description'] = this.description;
    return data;
  }
}
