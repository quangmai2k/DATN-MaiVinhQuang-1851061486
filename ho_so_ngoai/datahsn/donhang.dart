import 'package:gentelella_flutter/widgets/ui/ho_so_ngoai/datahsn/nghiepdoan.dart';
import 'package:gentelella_flutter/widgets/ui/ho_so_ngoai/datahsn/xinghiep.dart';

class DonHang {
  int? id;
  String? orderName;
  String? orderCode;
  int? orgId;
  NghiepDoan? nghiepdoan;
  int? companyId;
  XiNghiep? xinghiep;

  DonHang({
    this.id,
    this.orderName,
    this.orderCode,
    this.orgId,
    this.nghiepdoan,
    this.companyId,
    this.xinghiep,
  });

  factory DonHang.fromJson(Map<dynamic, dynamic> json) {
    return DonHang(
      id: json['id'] ?? 0,
      orderName: json['orderName'] ?? "",
      orderCode: json['orderCode'] ?? "",
      orgId: json['orgId'] ?? 0,
      nghiepdoan: json['nghiepdoan'] != null ? new NghiepDoan.fromJson(json['nghiepdoan']) : null,
      companyId: json['companyId'] ?? 0,
      xinghiep: json['xinghiep'] != null ? new XiNghiep.fromJson(json['xinghiep']) : null,
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderName': orderName,
      'orderCode': orderCode,
    };
  }
}
