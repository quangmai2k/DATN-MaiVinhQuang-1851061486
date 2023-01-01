import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';
import 'package:provider/provider.dart';

import '../../../../api.dart';
import '../../../../common/format_date.dart';
import '../../../../common/toast.dart';
import '../../../../model/model.dart';
import 'view_detail.dart';

class ModalKetThucThiTuyen extends StatefulWidget {
  final List<doTruot>? listDoTruot;
  final List<dynamic>? listTTT;
  final List<doTruot>? listDoTruotUpdate;
  var resultLTTChiTiet;
  int? idLtt;
  String? examDate;
  ModalKetThucThiTuyen({Key? key, this.listDoTruot, this.listTTT, this.idLtt, this.resultLTTChiTiet, this.listDoTruotUpdate, this.examDate}) : super(key: key);

  @override
  State<ModalKetThucThiTuyen> createState() => _ModalKetThucThiTuyenState();
}

class _ModalKetThucThiTuyenState extends State<ModalKetThucThiTuyen> {
  Future<bool> putTtsLichsuThiTuyen(List<dynamic> listDynamic, context) async {
    try {
      var response = await httpPut(Uri.parse('/api/tts-lichsu-thituyen/put/all'), listDynamic, context); //Tra ve id
      if (jsonDecode(response['body']) == true) {
        return true;
      }
    } catch (_) {
      print("Fail!");
    }
    return false;
  }

  Future<bool> putLichThiTuyen(int id, requestBody, context) async {
    try {
      var response = await httpPut("/api/lichthituyen/put/$id", requestBody, context);
      if (jsonDecode(response['body']) == true) {
        return true;
      }
    } catch (_) {
      print("Fail!");
    }
    return false;
  }

  Future<bool> putNguoiDung(int id, requestBody, context) async {
    try {
      var response = await httpPut("/api/nguoidung/put/$id", requestBody, context);
      var body = jsonDecode(response['body']);
      if (body.containsKey("1")) {
        return true;
      }
    } catch (e) {
      print("Fail! $e");
    }
    return false;
  }

  bool canhBaoTTSDXL = true;
  @override
  void initState() {
    super.initState();
    call();
    setState(() {
      canhBaoTTSDXL = kiemTraTTSDXL(widget.listTTT);
    });
    print(widget.examDate);
    // for (int i = 0; i < widget.listDoTruot!.length; i++) {
    //   print("aaaa" +
    //       getResultName(widget.listDoTruot![i], widget.listTTT![i]['donhang']['orderName'], getDateViewDayAndHour(FormatDate.formatDateInsertDBHHss(DateTime.now()))) +
    //       " \n ");
    // }
  }

  call() async {
    List<dynamic> listTtsLichSuThiTuyen = [];

    listTtsLichSuThiTuyen = await getListLSTC(widget.listDoTruot, widget.listTTT);
    for (var item in listTtsLichSuThiTuyen) {
      print(item['examTimes']);
    }
  }

  banThongBaoChoTts(listUserCodeTTS, order, tinhTrang) async {
    try {
      String condition = "";
      for (int i = 0; i < listUserCodeTTS.length; i++) {
        if (i == 0) {
          condition += listUserCodeTTS[i];
        } else {
          condition += "&" + listUserCodeTTS[i];
        }
      }
      if (condition.isNotEmpty) {
        if (tinhTrang) {
          await httpPost("/api/push/tags/user_code/$condition",
              {"title": "Hệ thống thông báo", "message": "Chúc mừng bạn đã trúng tuyển đơn hàng ${order!['orderCode']}-${order['orderName']} "}, context);
        } else {
          await httpPost(
              "/api/push/tags/user_code/$condition",
              {
                "title": "Hệ thống thông báo",
                "message":
                    " Rất tiếc, bạn đã không trúng tuyển đơn hàng ${order!['orderCode']}-${order['orderName']}. Vui lòng chờ bộ phận tuyển dụng sẽ tiến cử bạn vào đơn hàng khác."
              },
              context);
        }
      }
    } catch (e) {
      print(e);
    }
  }

  bool kiemTraTTSDXL(listTtsLichSuThiTuyen) {
    for (int i = 0; i < listTtsLichSuThiTuyen.length; i++) {
      if (listTtsLichSuThiTuyen[i]["thuctapsinh"]["stopProcessing"] == 1) {
        return true;
      }
    }
    return false;
  }

  bool kiemTraKhongChonKetQua(listTtsLichSuThiTuyen, listDoTruot) {
    int count = 0;
    int countStop = 0;
    for (int i = 0; i < listTtsLichSuThiTuyen.length; i++) {
      if (listTtsLichSuThiTuyen[i]["thuctapsinh"]["stopProcessing"] != 1) {
        if (listDoTruot[i] == doTruot.KhongChon) {
          count++;
        }
      } else {
        countStop++;
      }
    }
    if (countStop == 0) {
      if (listDoTruot.contains(doTruot.KhongChon)) {
        Navigator.pop(context);
        showToast(context: context, msg: "Cập nhật đầy đủ kết quả cho thực tập sinh !", color: Color.fromARGB(255, 241, 228, 109), icon: Icon(Icons.warning));
        return true;
      }
    } else {
      if (count > 0) {
        showToast(context: context, msg: "Cập nhật đầy đủ các kết quả cho các tts không bị dừng xử lý !", color: Colors.yellow, icon: Icon(Icons.warning));
        return true;
      }
    }

    return false;
  }

  getListLSTC(listDoTruot, listTTSLSTT) {
    for (int i = 0; i < listDoTruot!.length; i++) {
      int? examResult;
      switch (listDoTruot[i]) {
        case doTruot.Do:
          examResult = 1;
          break;
        case doTruot.Truot:
          examResult = 2;
          break;
        case doTruot.DuBi:
          examResult = 3;
          break;
        case doTruot.BoThi:
          examResult = 4;
          break;
        default:
      }
      if (listTTSLSTT[i]["thuctapsinh"]['stopProcessing'] == 1) {
        listTTSLSTT[i]["examDate"] = listTTSLSTT[i]["examDate"] != null ? listTTSLSTT[i]["examDate"] : widget.examDate;
        listTTSLSTT[i]["examResult"] = 4;
        listTTSLSTT[i]["thuctapsinh"]['stopProcessing'] = 0;
      } else {
        listTTSLSTT[i]["examResult"] = examResult;
        listTTSLSTT[i]["examDate"] = listTTSLSTT[i]["examDate"] != null ? listTTSLSTT[i]["examDate"] : widget.examDate;
      }
    }
    return listTTSLSTT;
  }

  getTtsStatusId(result) {
    if (result == doTruot.Do) {
      return 7;
    }
    if (result == doTruot.Truot) {
      return 14;
    }
    if (result == doTruot.DuBi) {
      return 14;
    }
    if (result == doTruot.BoThi) {
      return 14;
    }
  }

  getResultName(result, orderName, time) {
    if (result == doTruot.Do) {
      return "Đã trúng tuyển vào đơn hàng $orderName lúc $time";
    }
    if (result == doTruot.Truot) {
      return "Thi trượt đơn hàng $orderName lúc $time";
    }
    if (result == doTruot.DuBi) {
      return "Dự bị đơn hàng $orderName lúc $time";
    }
    if (result == doTruot.BoThi) {
      return "Bỏ thi đơn hàng $orderName lúc $time";
    }
  }

  getOrderId(result, orderId) {
    if (result == doTruot.Do) {
      return orderId;
    }
    if (result == doTruot.Truot) {
      return null;
    }
    if (result == doTruot.DuBi) {
      return null;
    }
    if (result == doTruot.BoThi) {
      return null;
    }
  }

  Future<bool> capNhatLichSuThiTuyen(listTtsLichSuThiTuyen) async {
    //Cập nhật tts-lichsu-thituyen

    bool resultUpdateLichSuTtsThiTuyen = false;
    if (listTtsLichSuThiTuyen.isNotEmpty) {
      resultUpdateLichSuTtsThiTuyen = await putTtsLichsuThiTuyen(listTtsLichSuThiTuyen, context);
      if (!resultUpdateLichSuTtsThiTuyen) {
        showToast(context: context, msg: "Cập nhật không thành công !", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
        Navigator.pop(context);
        Navigator.pop(context);
        return resultUpdateLichSuTtsThiTuyen;
      }
    }
    return true;
  }

  getDsttsTt(listTTSLSTT) async {
    var listTrangThaiThanhToan = [];
    var conditionTts = "";
    var conditionDh = "";

    for (int i = 0; i < listTTSLSTT.length; i++) {
      if (i == 0) {
        conditionTts += listTTSLSTT[i]['ttsId'].toString();
        conditionDh += listTTSLSTT[i]['orderId'].toString();
      } else {
        conditionTts += "," + listTTSLSTT[i]['ttsId'].toString();
        conditionDh += "," + listTTSLSTT[i]['orderId'].toString();
      }
    }
    var response;
    if (conditionTts.isNotEmpty && conditionDh.isNotEmpty) {
      response = await httpGet("/api/tts-thanhtoan/get/page?filter=ttsId in ($conditionTts) and orderId in($conditionDh) AND paidAfterExam:1", context);
    } else {
      return listTrangThaiThanhToan;
    }

    if (response.containsKey("body")) {
      listTrangThaiThanhToan = jsonDecode(response["body"])['content'];
    }
    return listTrangThaiThanhToan;
  }

  bool checkExistInTtsThanhToan(orderId, ttsId, listTTSThanhToan, doTruot1) {
    for (var item in listTTSThanhToan) {
      var a = item["paidAfterExam"];
      var b = doTruot1;
      if (item["orderId"] == orderId && item["ttsId"] == ttsId && (item["paidAfterExam"] == 1 || item["paidAfterExam"] == 2) && doTruot1 == doTruot.Do) {
        return true;
      }
    }
    return false;
  }

  capNhatTrangThaiNguoiDungVaLuuNhatKy(listDoTruot, listTTSLSTT, listDoTruotUpdate) async {
    var listTTSThanhToan = await getDsttsTt(listTTSLSTT);
    int countSucces = 0;
    for (int i = 0; i < listDoTruot.length; i++) {
      if (listTTSLSTT[i]['thuctapsinh']['stopProcessing'] != 1) {
        bool isUpdate = true;
        if (listDoTruot[i] == doTruot.Do) {
          //Chưa đóng tiền sau thi tuyển
          bool result = checkExistInTtsThanhToan(listTTSLSTT[i]['orderId'], listTTSLSTT[i]['ttsId'], listTTSThanhToan, listDoTruot[i]);
          if (!result) {
            var requestUpdateNguoiDung = {
              "orderId": getOrderId(listDoTruot[i], listTTSLSTT[i]['orderId']),
              "ttsStatusId": getTtsStatusId(listDoTruot[i]),
              "isTts": 1,
            };
            bool resultUpdate = await putNguoiDung(listTTSLSTT[i]['thuctapsinh']['id'], requestUpdateNguoiDung, context);
            isUpdate = resultUpdate;
          } else {
            var requestUpdateNguoiDung = {
              "orderId": getOrderId(listDoTruot[i], listTTSLSTT[i]['orderId']),
              "ttsStatusId": 8,
              "isTts": 1,
            };
            bool resultUpdate = await putNguoiDung(listTTSLSTT[i]['thuctapsinh']['id'], requestUpdateNguoiDung, context);
            isUpdate = resultUpdate;
          }
        } else {
          var requestUpdateNguoiDung = {
            "orderId": getOrderId(listDoTruot[i], listTTSLSTT[i]['orderId']),
            "ttsStatusId": getTtsStatusId(listDoTruot[i]),
            "isTts": 1,
          };
          bool resultUpdate = await putNguoiDung(listTTSLSTT[i]['thuctapsinh']['id'], requestUpdateNguoiDung, context);
          isUpdate = resultUpdate;
        }

        if (isUpdate) {
          //Thêm vào nhật ký xử lý của tts
          bool result = checkExistInTtsThanhToan(listTTSLSTT[i]['orderId'], listTTSLSTT[i]['ttsId'], listTTSThanhToan, listDoTruot[i]);
          if (!result) {
            await httpPostDiariStatus(listTTSLSTT[i]['thuctapsinh']['id'], listTTSLSTT[i]['thuctapsinh']['ttsStatusId'], getTtsStatusId(listDoTruot[i]),
                getResultName(listDoTruot[i], listTTSLSTT[i]['donhang']['orderName'], getDateViewDayAndHour(FormatDate.formatDateInsertDBHHss(DateTime.now()))), context);
          } else {
            await httpPostDiariStatus(listTTSLSTT[i]['thuctapsinh']['id'], listTTSLSTT[i]['thuctapsinh']['ttsStatusId'], listTTSLSTT[i]['thuctapsinh']['ttsStatusId'],
                "Chuyển sang chờ đào tạo do đã đóng tiền và trúng tuyển đơn hàng ${listTTSLSTT[i]['donhang']['orderName']}", context);
          }
          countSucces++;
        }
      }
    }
    if (countSucces > 0) {
      return true;
    }
    return false;
  }

  banThongBao(listDoTruot, listTTSLSTT) async {
    List<dynamic> listTtsDo = [];
    List<dynamic> listTtsTruot = [];
    //======Bấn thông báo
    try {
      for (int i = 0; i < listDoTruot.length; i++) {
        //Bắn thông báo theo trường hợp đỗ trượt
        if (listDoTruot[i] == doTruot.Do) {
          listTtsDo.add(listTTSLSTT[i]['thuctapsinh']['userCode']);
          //bắn cho phòng
          await httpPost(
              "/api/push/tags/depart_id/6&7",
              {
                "title": "Hệ thống thông báo",
                "message":
                    "TTS mã ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} đã trúng tuyển đơn hàng ${listTTSLSTT[i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']}"
              },
              context);

          await httpPost(
              "/api/push/tags/user_code/${listTTSLSTT[i]['thuctapsinh']['nhanvientuyendung']['userCode']}",
              {
                "title": "Hệ thống thông báo",
                "message":
                    "TTS mã ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} đã trúng tuyển đơn hàng ${listTTSLSTT[i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']}"
              },
              context);
          print(
              "TTS mã ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} đã trúng tuyển đơn hàng ${listTTSLSTT[i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']}");
        }
        if (listDoTruot[i] == doTruot.DuBi) {
          //bắn cho phòng
          await httpPost(
              "/api/push/tags/depart_id/6&7",
              {
                "title": "Hệ thống thông báo",
                "message":
                    "TTS mã ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} đã dự bị đơn hàng ${listTTSLSTT[i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']}"
              },
              context);

          await httpPost(
              "/api/push/tags/user_code/${listTTSLSTT[i]['thuctapsinh']['nhanvientuyendung']['userCode']}",
              {
                "title": "Hệ thống thông báo",
                "message":
                    "TTS mã ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} đã dự bị đơn hàng ${listTTSLSTT[i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']}"
              },
              context);
          print(
              "TTS mã ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} đã dự bị đơn hàng ${listTTSLSTT[i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']}");
        }
        if (listDoTruot[i] == doTruot.BoThi) {
          //bắn cho phòng
          await httpPost(
              "/api/push/tags/depart_id/6&7",
              {
                "title": "Hệ thống thông báo",
                "message":
                    "TTS mã ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} đã bỏ thi đơn hàng ${listTTSLSTT[i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']}"
              },
              context);

          await httpPost(
              "/api/push/tags/user_code/${listTTSLSTT[i]['thuctapsinh']['nhanvientuyendung']['userCode']}",
              {
                "title": "Hệ thống thông báo",
                "message":
                    "TTS mã ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} đã bỏ thi đơn hàng ${listTTSLSTT[i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']}"
              },
              context);
          print(
              "TTS mã ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} đã bỏ thi đơn hàng ${listTTSLSTT[i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']}");
        }
        if (listDoTruot[i] == doTruot.Truot) {
          listTtsTruot.add(listTTSLSTT[i]['thuctapsinh']['userCode']);
          //bắn cho phòng
          await httpPost(
              "/api/push/tags/depart_id/6&7",
              {
                "title": "Hệ thống thông báo",
                "message":
                    "TTS mã ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} đã trượt đơn hàng ${listTTSLSTT![i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']} . Đề nghị tiến cử vào đơn hàng khác."
              },
              context);
          await httpPost(
              "/api/push/tags/user_code/${listTTSLSTT[i]['thuctapsinh']['nhanvientuyendung']['userCode']}",
              {
                "title": "Hệ thống thông báo",
                "message":
                    "TTS mã ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} đã trượt đơn hàng ${listTTSLSTT![i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']} . Đề nghị tiến cử vào đơn hàng khác."
              },
              context);
          print(
              "TTS mã ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} đã trượt đơn hàng ${listTTSLSTT[i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']}");
        }
      }
      //Xử lí phần bắn thông báo cho tts
      await banThongBaoChoTts(listTtsDo, listTTSLSTT.first['donhang'], true); //Đỗ

      await banThongBaoChoTts(listTtsTruot, listTTSLSTT.first['donhang'], false);
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Image.asset(
            "assets/images/logoAAM.png",
            width: 30,
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Text(
              'Xác nhận kết thúc thi tuyển',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close)),
            ),
          )
        ],
      ),
      content: Container(
        height: 150,
        width: 600,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      canhBaoTTSDXL
                          ? "Đang có TTS tạm dừng xử lý.\nNếu kết thúc thi tuyển sẽ cập nhật TTS dừng xử lý thành bỏ thi .\nBạn vẫn muốn xác nhận?"
                          : "Bạn có chắc chắc muốn xác nhận!",
                      style: TextStyle(fontSize: 17, color: canhBaoTTSDXL ? Colors.red : Colors.black),
                    ),
                  ),
                  SizedBox(
                    width: 100,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Divider(
            thickness: 1,
            color: Colors.grey,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 120,
              height: 40,
              child: OutlinedButton(
                  style: ElevatedButton.styleFrom(
                    onPrimary: Color(0xff42a5f5), // Background color
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Hủy')),
            ),
            Container(
              width: 120,
              height: 40,
              padding: EdgeInsets.only(left: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xff42a5f5),
                  onPrimary: Colors.white, // Background color
                ),
                onPressed: () async {
                  try {
                    onLoading(context);
                    List<dynamic> listTtsLichSuThiTuyen = [];

                    listTtsLichSuThiTuyen = await getListLSTC(widget.listDoTruot, widget.listTTT);
                    // for (var item in listTtsLichSuThiTuyen) {
                    //   try {
                    //     item['examTimes'] = item['examTimes'] + 1;
                    //   } catch (e) {
                    //     print(e);
                    //   }
                    // }

                    if (kiemTraKhongChonKetQua(listTtsLichSuThiTuyen, widget.listDoTruot)) {
                      return;
                    }

                    bool resultUpdateLichSuTtsThiTuyen = await capNhatLichSuThiTuyen(listTtsLichSuThiTuyen);
                    bool resultUpdateNguoiDung = await capNhatTrangThaiNguoiDungVaLuuNhatKy(widget.listDoTruot, widget.listTTT, widget.listDoTruotUpdate);
                    //Cập nhật lịch sử thi tuyển thành
                    // var requestBody = {
                    //   //Trạng thái=0:Chưa thi|1:Đã thi|2:Hủy
                    //   'status': 1,
                    // };
                    widget.resultLTTChiTiet['status'] = 1;
                    bool resultUpdateLichThiTuyen = await putLichThiTuyen(widget.idLtt!, widget.resultLTTChiTiet, context);
                    if (resultUpdateLichSuTtsThiTuyen && resultUpdateNguoiDung && resultUpdateLichThiTuyen) {
                      await banThongBao(widget.listDoTruot, widget.listTTT);
                      showToast(context: context, msg: "Đã hoàn thành thi tuyển !", color: Colors.green, icon: Icon(Icons.done));
                      Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/lich-thi-tuyen"); //trượt
                      Navigator.pop(context);
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      showToast(context: context, msg: "Cập nhật không thành công !", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                },
                child: Text('Xác nhận'),
              ),
            )
          ],
        ),
      ],
    );
  }
}
