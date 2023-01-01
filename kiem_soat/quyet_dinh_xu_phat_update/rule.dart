class Rule {
  int id;
  String ruleName;
  int ? parentId;
  int ? times;
  int ? status;

  Rule({
    required this.id,
    required this.ruleName,
    required this.times,
    required this.parentId,
    required this.status,
  });

  factory Rule.fromJson(Map<dynamic, dynamic> json) {
    return Rule(
      id: json['id'] ?? 0,
      parentId: json["parentId"] ?? 0,
      ruleName: json["ruleName"],
      status: json["status"] ?? 0,
      times: json["times"] ?? 0,
    );
  }

  get orgId => null;
}
