class FormId {
  int id;
  int? modifiedUser;
  String? modifiedDate;
  int? createdUser;
  String? createdDate;
  bool? deleted;
  String? formName;
  int? status;
  String? description;

  FormId(
      {required this.id,
      this.modifiedUser,
      this.modifiedDate,
      this.createdUser,
      this.createdDate,
      this.deleted,
      this.formName,
      this.status,
      this.description});

  factory FormId.fromJson(Map<String, dynamic> json) {
    return FormId(
      id: json['id'] ?? null,
      modifiedUser: json['modifiedUser'] ?? null,
      modifiedDate: json['modifiedDate'] ?? "",
      createdUser: json['createdUser'] ?? null,
      createdDate: json['createdDate'] ?? null,
      deleted: json['deleted'] ?? false,
      formName: json['formName'] ?? "",
      status: json['status'] ?? null,
      description: json['description'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['modifiedUser'] = this.modifiedUser;
    data['modifiedDate'] = this.modifiedDate;
    data['createdUser'] = this.createdUser;
    data['createdDate'] = this.createdDate;
    data['deleted'] = this.deleted;
    data['formName'] = this.formName;
    data['status'] = this.status;
    data['description'] = this.description;
    return data;
  }
}
