import 'package:gentelella_flutter/widgets/ui/ho_so_ngoai/datahsn/lichbay.dart';
import 'package:gentelella_flutter/widgets/ui/ho_so_ngoai/datahsn/tts.dart';

class LBChiTiet {
  int? id;
  int? modifiedUser;
  String? modifiedDate;
  int? createdUser;
  String? createdDate;
  bool? deleted;
  LichXC? lichXC;
  Tts? thuctapsinh;
  int? status;
  String? soHoChieu;
  LBChiTiet({
    this.id,
    this.modifiedUser,
    this.modifiedDate,
    this.createdUser,
    this.createdDate,
    this.deleted,
    this.lichXC,
    this.thuctapsinh,
    this.status,
    this.soHoChieu,
  });
  factory LBChiTiet.fromJson(Map<dynamic, dynamic> json) {
    return LBChiTiet(
      id: json['id'] ?? 0,
      modifiedUser: json['modifiedUser'] ?? null,
      modifiedDate: json['modifiedDate'] ?? "",
      createdUser: json['createdUser'] ?? null,
      createdDate: json['createdDate'] ?? "",
      deleted: json['deleted'] ?? false,
      lichXC: json['lichxuatcanh'] != null ? LichXC.fromJson(json['lichxuatcanh']) : null,
      thuctapsinh: json['thuctapsinh'] != null ? new Tts.fromJson(json['thuctapsinh']) : null,
      status: json['status'] ?? 0,
    );
  }
}
