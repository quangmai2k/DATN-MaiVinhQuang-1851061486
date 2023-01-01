class OrderN {
  int id;
  String orderCode;
  String orderName;

  OrderN({
    required this.id,
    required this.orderCode,
    required this.orderName,
  });

  factory OrderN.fromJson(Map<dynamic, dynamic> json) {
    return OrderN(
      id: json['id'] ?? 0,
      orderCode : json['orderCode'] ?? "No data !",
      orderName: json['orderName'] ?? "No data!",
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderCode': orderCode,
      'orderName': orderName,
    };
  }
}


