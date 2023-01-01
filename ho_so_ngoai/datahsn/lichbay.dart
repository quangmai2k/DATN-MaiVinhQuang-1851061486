import 'package:gentelella_flutter/widgets/ui/ho_so_ngoai/datahsn/donhang.dart';

class LichXC {
  int? id;
  int? modifiedUser;
  String? modifiedDate;
  int? createdUser;
  String? createdDate;
  bool? deleted;
  String? title;
  DonHang? donhang;
  String? flightDate;
  LichXC({
    this.id,
    this.modifiedUser,
    this.modifiedDate,
    this.createdUser,
    this.createdDate,
    this.deleted,
    this.title,
    this.donhang,
    this.flightDate,
  });
  factory LichXC.fromJson(Map<dynamic, dynamic> json) {
    return LichXC(
      id: json['id'] ?? 0,
      modifiedUser: json['modifiedUser'] ?? null,
      modifiedDate: json['modifiedDate'] ?? "",
      createdUser: json['createdUser'] ?? null,
      createdDate: json['createdDate'] ?? "",
      title: json['title'] ?? "",
      deleted: json['deleted'] ?? false,
      donhang: json['donhang'] != null ? new DonHang.fromJson(json['donhang']) : null,
      flightDate: json['flightDate'] ?? "-----------",
    );
  }
}
