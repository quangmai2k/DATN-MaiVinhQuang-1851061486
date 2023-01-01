import 'package:gentelella_flutter/widgets/forms/nhan_su/setting-data/userAAM.dart';
import 'package:gentelella_flutter/widgets/ui/kiem_soat/setting-data/quydinh.dart';
import 'package:gentelella_flutter/widgets/ui/kiem_soat/setting-data/tts.dart';
import '../../../forms/nhan_su/setting-data/duty.dart';

class Quyetdinhxuphat{
  int? quyetDinhCha;
  int? option;//0 là TTS, 1 Cán bộ
  TTS? tts;
  UserAAM? userAAM;
  Duty? vatro;
  QuyDinh1? quyDinhcon;
  Quyetdinhxuphat({this.quyetDinhCha,this.option,this.tts,this.vatro,this.quyDinhcon,this.userAAM});
}