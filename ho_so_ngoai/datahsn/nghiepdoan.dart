class NghiepDoan {
  int id;
  String orgName;
  String orgCode;
  int? contractStatus;

  NghiepDoan({
    required this.id,
    required this.orgName,
    required this.orgCode,
    this.contractStatus,
  });

  factory NghiepDoan.fromJson(Map<dynamic, dynamic> json) {
    return NghiepDoan(
      id: json['id'] ?? 0,
      orgName: json['orgName'] ?? "",
      orgCode: json['orgCode'] ?? "",
      contractStatus: json['contractStatus'] ?? "",
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orgName': orgName,
      'orgCode': orgCode,
    };
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["id"] = this.id;
    data["orgName"] = this.orgName;
    data["orgCode"] = this.orgCode;
    return data;
  }
}
