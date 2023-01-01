class NganhNghe {
  int id;
  String jobName;

  NganhNghe({
    required this.id,
    required this.jobName,
  });

  factory NganhNghe.fromJson(Map<dynamic, dynamic> json) {
    return NganhNghe(
      id: json['id'] ?? 0,
      jobName: json['jobName'] ?? "",
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jobName': jobName,
    };
  }
}
