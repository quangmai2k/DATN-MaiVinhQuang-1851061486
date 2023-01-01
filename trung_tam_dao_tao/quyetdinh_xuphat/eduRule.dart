class EduRule {
  int id;
  String name;
  int ? parentId;
  int ? status;

  EduRule({
    required this.id,
    required this.name,
    required this.parentId,
    required this.status,
  });

  factory EduRule.fromJson(Map<dynamic, dynamic> json) {
    return EduRule(
      id: json['id'] ?? 0,
      parentId: json["parentId"] ?? 0,
      name: json["name"],
      status: json["status"] ?? 0,
    );
  }

  get orgId => null;
}