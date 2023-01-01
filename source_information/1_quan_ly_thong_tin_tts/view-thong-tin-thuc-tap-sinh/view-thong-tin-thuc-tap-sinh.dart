import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/source_information/1_quan_ly_thong_tin_tts/view-thong-tin-thuc-tap-sinh/payment_confirmation.dart';
import 'package:gentelella_flutter/widgets/ui/source_information/1_quan_ly_thong_tin_tts/view-thong-tin-thuc-tap-sinh/processing-log.dart';
import 'package:gentelella_flutter/widgets/ui/source_information/1_quan_ly_thong_tin_tts/view-thong-tin-thuc-tap-sinh/thong-tin-ca-nhan.dart';
import 'package:gentelella_flutter/widgets/ui/source_information/1_quan_ly_thong_tin_tts/view-thong-tin-thuc-tap-sinh/work%20_progress.dart';
import 'package:gentelella_flutter/widgets/ui/source_information/setting-data/object-tts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../../api.dart';
import '../../../../../common/style.dart';
import '../../../../../common/widgets_form.dart';
import '../../../../../model/model.dart';
import '../../../../forms/ho_so_ngoai_forms/form_quan_ly_ho_so/ho_so_xuat_canh.dart';
import '../../../../forms/nhan_su/setting-data/folk.dart';
import '../../../../forms/nhan_su/setting-data/religion.dart';
import '../../../../forms/nhan_su/setting-data/userAAM.dart';
import '../../../navigation.dart';

import '../../../trung_tam_dao_tao/danh_sach_thuc_tap_sinh/view_thong_tin_dao_tao.dart';

import 'ho-so-ca-nhan.dart';
import 'suc-khoe.dart';
import 'thong-tin-lien-he-khan-cap.dart';
import 'tien-cu-va-lich-su.dart';

// ignore: must_be_immutable
class ViewTTS extends StatefulWidget {
  String? idTTS;
  ViewTTS({Key? key, this.idTTS}) : super(key: key);

  @override
  State<ViewTTS> createState() => _ViewHSNSBodyState();
}

class _ViewHSNSBodyState extends State<ViewTTS> {
  late TTS tTS;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  late Future<TTS> futureTTS;
  Future<TTS> getTTS(TTS tTS) async {
    var response1 = await httpGet("/api/nguoidung/get/info?filter=id:${widget.idTTS}", context);
    if (response1.containsKey("body")) {
      var body = jsonDecode(response1['body']);
      tTS.id = body['id'];
      tTS.userCode = body['userCode'];
      tTS.userName = body['userName'];
      tTS.fullName = body['fullName'];
      tTS.avatar = body['avatar'];
      tTS.birthDate = (body['birthDate'] != null) ? dateFormat.parse(body['birthDate']) : null;
      tTS.ttsStatus = StatusTTS(id: body['ttsStatusId'], statusName: (body['ttsTrangthai'] != null) ? body['ttsTrangthai']['statusName'] : "");
      tTS.gender = body['gender'];
      tTS.phone = body['phone'];
      tTS.mobile = body['mobile'];
      tTS.email = body['email'];
      tTS.address = body['address'];
      tTS.hometown = body['hometown'];
      tTS.residence = body['residence'];
      tTS.maritalStatus = body['maritalStatus'];
      tTS.idCardNo = body['idCardNo'];
      tTS.issuedDate = (body['issuedDate'] != null) ? DateTime.parse(body['issuedDate']) : null;
      tTS.issuedBy = body['issuedBy'];
      tTS.careUser = UserAAM(
        id: body['careUser'],
        userCode: (body['nhanvientuyendung'] != null) ? body['nhanvientuyendung']['userCode'] : "",
        fullName: (body['nhanvientuyendung'] != null) ? body['nhanvientuyendung']['fullName'] : "",
      );
      tTS.recommendUser = UserAAM(
        id: body['recommendUser'],
        userCode: (body['nguoigioithieu'] != null) ? body['nguoigioithieu']['userCode'] : "1",
        fullName: (body['nguoigioithieu'] != null) ? body['nguoigioithieu']['fullName'] : "2",
      );
      // order:Order(id: null, jobs: null),
      tTS.stopProcessing = body['stopProcessing'];
      tTS.departureDate = (body['departureDate'] != null) ? dateFormat.parse(body['departureDate']) : null;
      tTS.contractExpireDate = (body['contractExpireDate'] != null) ? dateFormat.parse(body['contractExpireDate']) : null;
      tTS.resetPasswordToken = body['resetPasswordToken'];
      tTS.ttsForm = TTSForm(
        id: body['formId'],
      );
    }

    return tTS;
  }

  //Dữ liệu từ form chi tiết
  getFormChiTiet(TTS tTS, int? formId) async {
    if (formId != null) {
      var response = await httpGet("/api/tts-form-chitiet/get/page?filter=ttsId:${widget.idTTS} and formId:$formId", context);
      if (response.containsKey("body")) {
        var body = jsonDecode(response["body"]);
        var content = body['content'];
        for (var element in content) {
          tTS.ttsForm!.id = (element['form'] != null) ? element['form']['id'] : null;
          tTS.ttsForm!.formName = (element['form'] != null) ? element['form']['formName'] : null;
          tTS.trinhDoHocVan =
              TrinhdoHocVan(id: element['academicId'] ?? 0, name: (element['trinhdohocvan'] != null) ? element['trinhdohocvan']['name'] : null);
          tTS.dantoc = Folk(id: element['folkId'] ?? 1, folkName: (element['dantoc'] != null) ? element['dantoc']['folkName'] : null);
          tTS.tongiao = Religion(id: element['religionId'], religionName: (element['tongiao'] != null) ? element['tongiao']['religionName'] : null);
          tTS.ttsForm!.formName = (element['form'] != null) ? element['form']['formName'] : null;
          tTS.trinhDoHocVan =
              TrinhdoHocVan(id: element['academicId'] ?? 0, name: (element['trinhdohocvan'] != null) ? element['trinhdohocvan']['name'] : null);
          tTS.dantoc = Folk(id: element['folkId'] ?? 1, folkName: (element['dantoc'] != null) ? element['dantoc']['folkName'] : null);
          tTS.tongiao =
              Religion(id: element['religionId'] ?? 1, religionName: (element['tongiao'] != null) ? element['tongiao']['religionName'] : null);
          tTS.nurtured = element['nurtured'];
          tTS.livedInGroup = element['livedInGroup'];
          tTS.cook = element['cook'];
          tTS.personalityTrength = element['personalityTrength'];
          tTS.personalityWeakness = element['personalityWeakness'];
          tTS.hobby = element['hobby'];
          tTS.personalityAssessment = element['personalityAssessment'];
          tTS.specialize = element['specialize'];
          tTS.reasonGoJapan = element['reasonGoJapan'];
          tTS.japanVisaApplied = element['japanVisaApplied'];
          tTS.personalIncome = element['personalIncome'];
          tTS.familyIncome = element['familyIncome'];
          tTS.abroadEver = element['abroadEver'];
          tTS.abroadCountryId = element['abroadCountryId'];
          tTS.abroadCountryDate = (element['abroadCountryDate'] != null) ? dateFormat.parse(element['abroadCountryDate']) : null;
          tTS.desiredIncome = element['desiredIncome'];
          tTS.desiredIncome3Years = element['desiredIncome3Years'];
          tTS.cumulativePoint = element['cumulativePoint'];
          tTS.iqPoint = element['iqPoint'];
          tTS.workTime = element['workTime'];
          tTS.workAddress = element['workAddress'];
          tTS.desiredProfessionJapanDescription = element['desiredProfessionJapanDescription'];
          tTS.workAfterContractExpired = element['workAfterContractExpired'];
          tTS.familyAgreement = element['familyAgreement'];
          tTS.jobId = element['jobId'];
        }
        setState(() {});
      }
    }
  }

  getSucKhoe(TTS tTS) async {
    var response = await httpGet("/api/tts-suckhoe/get/page?filter=ttsId:${widget.idTTS}", context);
    if (response.containsKey("body")) {
      var body = jsonDecode(response["body"]);
      var content = body['content'];
      // print("content:$body");
      if (content.length > 0) {
        var content = jsonDecode(response["body"])['content'].first;
        tTS.eyeSight = content['eyeSight'];
        tTS.rightHanded = content['rightHanded'];
        tTS.leftHanded = content['leftHanded'];
        tTS.height = content['height'];
        tTS.weight = content['weight'];
        tTS.colorBlind = content['colorBlind'];
        tTS.bloodGroup = content['bloodGroup'];
        tTS.everSurgery = content['everSurgery'];
        tTS.tatoo = content['tatoo'];
        tTS.drinkAlcohol = content['drinkAlcohol'];
        tTS.smoke = content['smoke'];
        tTS.hearing = content['hearing'];
        tTS.healthStatus = content['healthStatus'];
        tTS.pastPathology = content['pastPathology'];
        tTS.currentPathology = content['currentPathology'];
        tTS.familyMedicalHistory = content['familyMedicalHistory'];
        tTS.malformation = content['malformation'];
        tTS.covidInjection = content['covidInjection'];
        tTS.examHealthCertificate = content['examHealthCertificate'];
        tTS.flightHealthCertificate = content['flightHealthCertificate'];
        tTS.examCheckDate = (content['examCheckDate'] != null) ? dateFormat.parse(content['examCheckDate']) : null;
        tTS.flightCheckDate = (content['flightCheckDate'] != null) ? dateFormat.parse(content['flightCheckDate']) : null;
        tTS.examHealthCheckResult = content['examHealthCheckResult'];
        tTS.flightHealthCheckResult = content['flightHealthCheckResult'];
        tTS.pcrTestResult = content['pcrTestResult'];
        tTS.leftEyesight = content['leftEyesight'];
        tTS.rightEyesight = content['rightEyesight'];
        tTS.pcrTestDate = (content['pcrTestDate'] != null) ? dateFormat.parse(content['pcrTestDate']) : null;
        setState(() {});
      }
    }
  }

  getQuaTrinhHocTap(TTS tTS) async {
    var response = await httpGet("/api/tts-quatrinhhoctap/get/page?filter=ttsId:${widget.idTTS}", context);

    if (response.containsKey("body")) {
      tTS.quaTrinhHocTap = [];
      var content = jsonDecode(response["body"])['content'];
      print(content.length);
      if (content.length > 0) {
        for (var element in content) {
          QuaTrinhHocTap item = new QuaTrinhHocTap(
            id: element['id'],
            schoolName: element['schoolName'] ?? "",
            specialized: element['specialized'] ?? "",
            certificate: element['certificate'] ?? "",
            address: element['address'] ?? "",
            dateFrom: (element['dateFrom'] != null) ? dateFormat.parse(element['dateFrom']) : null,
            dateTo: (element['dateTo'] != null) ? dateFormat.parse(element['dateTo']) : null,
          );
          tTS.quaTrinhHocTap!.add(item);
        }
      }
      setState(() {});
    }
  }

  getTinhTrangHocTap(TTS tTS, int? formId) async {
    tTS.tinhTrangHocTap = [];
    if (formId != null) {
      var response = await httpGet("/api/tts-tinhtranghoctap/get/page?filter=ttsId:${widget.idTTS} and formId:$formId", context);
      if (response.containsKey("body")) {
        tTS.tinhTrangHocTap = [];
        var content = jsonDecode(response["body"])['content'];
        if (content.length > 0) {
          for (var element in content) {
            TinhTrangHocTap item = new TinhTrangHocTap(
                id: element['id'],
                lateAdmission: element['lateAdmission'],
                earlyAdmission: element['earlyAdmission'],
                repetitionAdmission: element['repetitionAdmission'],
                yearAdmission: element['yearAdmission']);
            tTS.tinhTrangHocTap!.add(item);
          }
        }
      }
    }
  }

  getKinhNghiemLamViec(TTS tTS) async {
    var response = await httpGet("/api/tts-kinhnghiemlamviec/get/page?filter=ttsId:${widget.idTTS}", context);
    if (response.containsKey("body")) {
      tTS.kinhNghiemLamViec = [];
      var content = jsonDecode(response["body"])['content'];
      if (content.length > 0) {
        for (var element in content) {
          KinhNghiemLamViec item = new KinhNghiemLamViec(
            id: element['id'],
            companyName: element['companyName'],
            workContent: element['workContent'],
            dateFrom: (element['dateFrom'] != null) ? dateFormat.parse(element['dateFrom']) : null,
            dateTo: (element['dateTo'] != null) ? dateFormat.parse(element['dateTo']) : null,
          );
          tTS.kinhNghiemLamViec!.add(item);
        }
      }
    }
  }

  getThanhPHanGiDinh(TTS tTS, int? formId) async {
    tTS.thanhPhanGiaDinh = [];
    if (formId != null) {
      var response = await httpGet("/api/tts-thanhphangiadinh/get/page?filter=ttsId:${widget.idTTS} and formId:$formId", context);

      if (response.containsKey("body")) {
        tTS.thanhPhanGiaDinh = [];
        var content = jsonDecode(response["body"])['content'];
        if (content.length > 0) {
          for (var element in content) {
            ThanhPhanGiaDinh item = new ThanhPhanGiaDinh(
              id: element['id'],
              fullName: element['fullName'],
              relation: element['relation'],
              birthDate: (element['birthDate'] != null) ? dateFormat.parse(element['birthDate']) : null,
              job: element['job'],
              livingTogether: element['livingTogether'],
              japanVisaApplied: element['japanVisaApplied'],
            );
            tTS.thanhPhanGiaDinh!.add(item);
          }
        }
      }
    }
  }

  getNganhNghe(TTS tTS, String listNganhNghe) async {
    tTS.nganhNgheMongMuon = [];
    List<dynamic> list = [];
    if (listNganhNghe != "" && listNganhNghe != "null") {
      list = listNganhNghe.split(",");
    }
    if (list.length > 0) {
      String find = "";
      for (var i = 0; i < list.length; i++) {
        find += "or id:${list[i]} ";
      }
      if (find != "") {
        find = find.substring(3);
        var response = await httpGet("/api/nganhnghe/get/page?filter=$find", context);
        if (response.containsKey("body")) {
          var content = jsonDecode(response["body"])['content'];
          if (content.length > 0) {
            for (var element in content) {
              NganhNghe item = new NganhNghe(
                id: element['id'],
                jobName: element['jobName'],
              );
              tTS.nganhNgheMongMuon!.add(item);
            }
          }
        }
      }
    }
  }

  getLienHeKhanCap(TTS tTS) async {
    var response = await httpGet("/api/tts-lienhe/get/page?filter=ttsId:${widget.idTTS}", context);

    if (response.containsKey("body")) {
      var content = jsonDecode(response["body"])['content'];
      if (content.length > 0) {
        var element = content.first;
        tTS.lienHeKhanCap = new LienHeKhanCap(
          name: element['name'],
          address: element['address'],
          phone: element['phone'],
          relation: element['relation'],
          facebook: element['facebook'],
          skype: element['skype'],
        );
      }
    }
    return 0;
  }

  getTrinhDoHocVan(TTS tTS) async {
    var response = await httpGet("/api/tts-trinhdohocvan/get/page?filter=ttsId:${widget.idTTS}", context);
    if (response.containsKey("body")) {
      tTS.trinhDoHocVanKiSu = [];
      var content = jsonDecode(response["body"])['content'];
      print(content.length);
      if (content.length > 0) {
        for (var element in content) {
          TrinhDoHocVan item = new TrinhDoHocVan(
            id: element['id'],
            ttsId: element['ttsId'] ?? "",
            academy: TrinhdoHocVan(
                id: element['academyId'],
                name: (element['bangcap'] != null) ? element['bangcap']['name'] : "",
                description: (element['bangcap'] != null) ? element['bangcap']['description'] : ""),
            description: element['description'] ?? "",
            issueDate: element['issueDate'] != null ? DateTime.parse(element['issueDate']) : null,
          );
          tTS.trinhDoHocVanKiSu!.add(item);
        }
      }
      setState(() {});
    }
    return 0;
  }

  getTrinhDoMayTinh(TTS tTS) async {
    var response = await httpGet("/api/tts-trinhdomaytinh/get/page?filter=ttsId:${widget.idTTS}", context);
    List<dynamic> list;

    if (response.containsKey("body")) {
      setState(() {
        list = jsonDecode(response["body"])['content'];

        if (list.length > 0) {
          tTS.trinhDoMayTinh = TrinhDoMayTinh();
          tTS.trinhDoMayTinh!.id = list[0]["id"];
          tTS.trinhDoMayTinh!.internetEmail = list[0]["internetEmail"];
          tTS.trinhDoMayTinh!.msWord = list[0]["msWord"];
          tTS.trinhDoMayTinh!.msExcel = list[0]["msExcel"];
          tTS.trinhDoMayTinh!.autoCad = list[0]["autoCad"];
          tTS.trinhDoMayTinh!.cam = list[0]["cam"];
          tTS.trinhDoMayTinh!.catia = list[0]["catia"];
          tTS.trinhDoMayTinh!.otherName = list[0]["otherName"];
          tTS.trinhDoMayTinh!.otherType = list[0]["otherType"];
          tTS.trinhDoMayTinh!.otherLevel = list[0]["otherLevel"];
        }
      });
    }
    return 0;
  }

  getNgoaiNgu(TTS tTS) async {
    var response = await httpGet("/api/tts-trinhdo-ngoaingu/get/page?filter=ttsId:${widget.idTTS}", context);
    List<dynamic> list;

    if (response.containsKey("body")) {
      setState(() {
        list = jsonDecode(response["body"])['content'];

        if (list.length > 0) {
          tTS.trinhDoNgoaiNgu = TrinhDoNgoaiNgu();
          tTS.trinhDoNgoaiNgu!.id = list[0]["id"];
          tTS.trinhDoNgoaiNgu!.english = list[0]["english"];
          tTS.trinhDoNgoaiNgu!.japanese = list[0]["japanese"];
        }
      });
    }
    return 0;
  }

  bool checkAwait = false;

  callApi() async {
    tTS = new TTS();
    await getTTS(tTS);
    await getFormChiTiet(tTS, tTS.ttsForm!.id);
    await getSucKhoe(tTS);
    await getQuaTrinhHocTap(tTS);
    await getTinhTrangHocTap(tTS, tTS.ttsForm!.id);
    await getKinhNghiemLamViec(tTS);
    await getThanhPHanGiDinh(tTS, tTS.ttsForm!.id);
    await getNganhNghe(tTS, "${tTS.jobId}");
    await getLienHeKhanCap(tTS);
    await getTrinhDoHocVan(tTS);
    await getTrinhDoMayTinh(tTS);
    await getNgoaiNgu(tTS);
    print("Đã lấy hết dữ liệu thông tin cá nhân");
    setState(() {
      checkAwait = true;
    });
  }

  @override
  void initState() {
    super.initState();
    callApi();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/view-thong-tin-thuc-tap-sinh', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          var listTab = [];
          var listTitle = [];
          var user = Provider.of<SecurityModel>(context, listen: true).userLoginCurren;
          if (user['departId'] == 1 ||
              user['departId'] == 2 ||
              user['departId'] == 3 ||
              user['departId'] == 30 ||
              user['departId'] == 31 ||
              user['departId'] == 4 ||
              user['departId'] == 5 ||
              user['departId'] == 11 ||
              user['departId'] == 12 ||
              user['departId'] == 6 ||
              user['departId'] == 7 ||
              user['departId'] == 8) {
            listTab.add(ViewTTCN(
              infoTTS: tTS,
            ));
            listTitle.add(Row(
              children: [
                Icon(
                  Icons.person,
                  color: mainColorPage,
                ),
                SizedBox(
                  width: 5,
                ),
                Text(
                  "Thông tin cá nhân",
                  style: titleTabbar,
                ),
              ],
            ));
          }
          if (user['departId'] == 1 ||
              user['departId'] == 2 ||
              user['departId'] == 3 ||
              user['departId'] == 30 ||
              user['departId'] == 31 ||
              user['departId'] == 4 ||
              user['departId'] == 5 ||
              user['departId'] == 11 ||
              user['departId'] == 12 ||
              user['departId'] == 6 ||
              user['departId'] == 7 ||
              user['departId'] == 8) {
            listTab.add(ViewHSCN(ttsId: "${tTS.id}"));
            listTitle.add(
              Row(
                children: [
                  Icon(
                    Icons.folder,
                    color: mainColorPage,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Hồ sơ cá nhân",
                    style: titleTabbar,
                  ),
                ],
              ),
            );
          }
          if (user['departId'] == 1 ||
              user['departId'] == 2 ||
              user['departId'] == 3 ||
              user['departId'] == 30 ||
              user['departId'] == 31 ||
              user['departId'] == 4 ||
              user['departId'] == 5 ||
              user['departId'] == 11 ||
              user['departId'] == 12 ||
              user['departId'] == 6 ||
              user['departId'] == 8) {
            listTab.add(ViewSK(infoTTS: tTS));
            listTitle.add(
              Row(
                children: [
                  Icon(
                    Icons.health_and_safety,
                    color: mainColorPage,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Sức khỏe",
                    style: titleTabbar,
                  ),
                ],
              ),
            );
          }
          if (user['departId'] == 1 ||
              user['departId'] == 2 ||
              user['departId'] == 5 ||
              user['departId'] == 11 ||
              user['departId'] == 12 ||
              user['departId'] == 8) {
            listTab.add(
              HoSoXuatCanh(idTTS: widget.idTTS!),
            );
            listTitle.add(
              Row(
                children: [
                  Icon(Icons.airplane_ticket, color: mainColorPage),
                  SizedBox(width: 5),
                  Text("Hồ sơ xuất cảnh", style: titleTabbar),
                ],
              ),
            );
          }
          if (user['departId'] == 1 ||
              user['departId'] == 2 ||
              user['departId'] == 4 ||
              user['departId'] == 5 ||
              user['departId'] == 11 ||
              user['departId'] == 12 ||
              user['departId'] == 7) {
            listTab.add(ViewThongTinDaoTao(id: widget.idTTS!));
            listTitle.add(
              Row(
                children: [
                  Icon(
                    Icons.school,
                    color: mainColorPage,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Thông tin đào tạo",
                    style: titleTabbar,
                  ),
                ],
              ),
            );
          }
          if (user['departId'] == 1 ||
              user['departId'] == 2 ||
              user['departId'] == 3 ||
              user['departId'] == 30 ||
              user['departId'] == 31 ||
              user['departId'] == 4 ||
              user['departId'] == 5 ||
              user['departId'] == 11 ||
              user['departId'] == 12 ||
              user['departId'] == 6 ||
              user['departId'] == 7 ||
              user['departId'] == 8) {
            listTab.add(ViewTCVLS(idTTS: widget.idTTS));
            listTitle.add(
              Row(
                children: [
                  Icon(
                    Icons.recommend,
                    color: mainColorPage,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Tiến cử và lịch sử",
                    style: titleTabbar,
                  ),
                ],
              ),
            );
          }
          if (user['departId'] == 1 ||
              user['departId'] == 2 ||
              user['departId'] == 3 ||
              user['departId'] == 30 ||
              user['departId'] == 31 ||
              user['departId'] == 4 ||
              user['departId'] == 5 ||
              user['departId'] == 11 ||
              user['departId'] == 12 ||
              user['departId'] == 6 ||
              user['departId'] == 7 ||
              user['departId'] == 8) {
            listTab.add(ViewTTLHKC(infoTTS: tTS));
            listTitle.add(
              Row(
                children: [
                  Icon(
                    Icons.contact_phone,
                    color: mainColorPage,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Thông tin liên hệ",
                    style: titleTabbar,
                  ),
                ],
              ),
            );
          }
          if (user['departId'] == 1 ||
              user['departId'] == 2 ||
              user['departId'] == 3 ||
              user['departId'] == 30 ||
              user['departId'] == 31 ||
              user['departId'] == 4 ||
              user['departId'] == 5) {
            listTab.add(PaymentConfirmation(idTTS: widget.idTTS));
            listTitle.add(
              Row(
                children: [
                  Icon(
                    Icons.credit_score,
                    color: mainColorPage,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Xác nhận thanh toán",
                    style: titleTabbar,
                  ),
                ],
              ),
            );
          }
          if (user['departId'] == 1 ||
              user['departId'] == 2 ||
              user['departId'] == 3 ||
              user['departId'] == 30 ||
              user['departId'] == 31 ||
              user['departId'] == 4 ||
              user['departId'] == 5 ||
              user['departId'] == 11 ||
              user['departId'] == 12 ||
              user['departId'] == 6 ||
              user['departId'] == 7 ||
              user['departId'] == 8) {
            listTab.add(WorkingProcess(idTTS: widget.idTTS));
            listTitle.add(
              Row(
                children: [
                  Icon(
                    Icons.work_history,
                    color: mainColorPage,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Quá trình làm việc",
                    style: titleTabbar,
                  ),
                ],
              ),
            );
          }
          if (user['departId'] == 1 ||
              user['departId'] == 2 ||
              user['departId'] == 3 ||
              user['departId'] == 30 ||
              user['departId'] == 31 ||
              user['departId'] == 4 ||
              user['departId'] == 5 ||
              user['departId'] == 11 ||
              user['departId'] == 12 ||
              user['departId'] == 6 ||
              user['departId'] == 7 ||
              user['departId'] == 8) {
            listTab.add(ProcessingLog(idTTS: widget.idTTS));
            listTitle.add(
              Row(
                children: [
                  Icon(
                    Icons.history,
                    color: mainColorPage,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "Nhật ký xử lý",
                    style: titleTabbar,
                  ),
                ],
              ),
            );
          }
          return HeaderAndNavigation(
            widgetBody: Consumer<NavigationModel>(
              builder: (context, navigationModel, child) => (checkAwait)
                  ? SingleChildScrollView(
                      controller: ScrollController(),
                      child: Column(children: [
                        TitlePage(
                          listPreTitle: [
                            {'url': "/thong-tin-nguon", 'title': 'Dashboard'},
                            {'url': "/quan-ly-thong-tin-thuc-tap-sinh", 'title': 'Quản lý thông tin TTS'},
                          ],
                          content: 'Thông tin thực tập sinh',
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 25, right: 25, top: 10, bottom: 10),
                          margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
                          decoration: BoxDecoration(
                            color: colorWhite,
                            borderRadius: borderRadiusContainer,
                            boxShadow: [boxShadowContainer],
                            border: borderAllContainerBox,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          // flex: 2,
                                          child: Text(
                                            "Trạng thái:",
                                            style: titleWidgetBox,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          // flex: 5,
                                          child: Text(
                                            "${tTS.ttsStatus!.statusName}",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 50,
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          // flex: 2,
                                          child: Text(
                                            "Nhân viên tuyển dụng:",
                                            style: titleWidgetBox,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          // flex: 5,
                                          child: Text(
                                            "${tTS.careUser!.userCode} - ${tTS.careUser!.fullName}",
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        TextButton.icon(
                                          icon: Icon(Icons.arrow_back_ios, size: 14, color: Colors.white),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 15.0,
                                              horizontal: 15.0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                            ),
                                            backgroundColor: colorOrange,
                                            primary: Theme.of(context).iconTheme.color,
                                            textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          label: Text('Trở về', style: textButton),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 1000,
                          child: DefaultTabController(
                            length: listTab.length,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  // color: Colors.red,
                                  constraints: BoxConstraints.expand(height: 25),
                                  padding: EdgeInsets.only(left: 20, right: 20),
                                  child: TabBar(
                                    isScrollable: true,
                                    indicatorColor: mainColorPage,
                                    tabs: [for (var row in listTitle) row],
                                  ),
                                ),
                                Expanded(
                                  child: TabBarView(children: [
                                    for (var row in listTab) row
                                    // ViewTTCN(
                                    //   infoTTS: tTS,
                                    // ),
                                    // ViewHSCN(ttsId: "${tTS.id}"),
                                    // ViewSK(infoTTS: tTS),
                                    // ViewTCVLS(idTTS: widget.idTTS),
                                    // ViewTTLHKC(infoTTS: tTS),
                                    // PaymentConfirmation(idTTS: widget.idTTS),
                                    // WorkingProcess(idTTS: widget.idTTS),
                                    // ProcessingLog(idTTS: widget.idTTS),

                                    // ViewCHSLQ(),
                                    // ViewTTL(),
                                  ]),
                                )
                              ],
                            ),
                          ),
                        )
                      ]),
                    )
                  : Center(child: CircularProgressIndicator()),
            ),
          );

          // Text(listRule.data!.title);
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
