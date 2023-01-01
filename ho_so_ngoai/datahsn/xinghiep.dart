class XiNghiep {
  int id;
  String companyName;
  String companyCode;
  int? status;

  XiNghiep({
    required this.id,
    required this.companyName,
    required this.companyCode,
    this.status,
  });

  factory XiNghiep.fromJson(Map<dynamic, dynamic> json) {
    return XiNghiep(
      id: json['id'] ?? 0,
      companyName: json['companyName'] ?? "",
      companyCode: json['companyCode'] ?? "",
      status: json['status'] ?? "",
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'companyName': companyName,
      'companyCode': companyCode,
    };
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["companyName"] = this.companyName;
    data["companyCode"] = this.companyCode;
    return data;
  }
}
