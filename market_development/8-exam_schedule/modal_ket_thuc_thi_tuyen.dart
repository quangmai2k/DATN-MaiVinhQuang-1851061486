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
              {"title": "H??? th???ng th??ng b??o", "message": "Ch??c m???ng b???n ???? tr??ng tuy???n ????n h??ng ${order!['orderCode']}-${order['orderName']} "}, context);
        } else {
          await httpPost(
              "/api/push/tags/user_code/$condition",
              {
                "title": "H??? th???ng th??ng b??o",
                "message":
                    " R???t ti???c, b???n ???? kh??ng tr??ng tuy???n ????n h??ng ${order!['orderCode']}-${order['orderName']}. Vui l??ng ch??? b??? ph???n tuy???n d???ng s??? ti???n c??? b???n v??o ????n h??ng kh??c."
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
        showToast(context: context, msg: "C???p nh???t ?????y ????? k???t qu??? cho th???c t???p sinh !", color: Color.fromARGB(255, 241, 228, 109), icon: Icon(Icons.warning));
        return true;
      }
    } else {
      if (count > 0) {
        showToast(context: context, msg: "C???p nh???t ?????y ????? c??c k???t qu??? cho c??c tts kh??ng b??? d???ng x??? l?? !", color: Colors.yellow, icon: Icon(Icons.warning));
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
      return "???? tr??ng tuy???n v??o ????n h??ng $orderName l??c $time";
    }
    if (result == doTruot.Truot) {
      return "Thi tr?????t ????n h??ng $orderName l??c $time";
    }
    if (result == doTruot.DuBi) {
      return "D??? b??? ????n h??ng $orderName l??c $time";
    }
    if (result == doTruot.BoThi) {
      return "B??? thi ????n h??ng $orderName l??c $time";
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
    //C???p nh???t tts-lichsu-thituyen

    bool resultUpdateLichSuTtsThiTuyen = false;
    if (listTtsLichSuThiTuyen.isNotEmpty) {
      resultUpdateLichSuTtsThiTuyen = await putTtsLichsuThiTuyen(listTtsLichSuThiTuyen, context);
      if (!resultUpdateLichSuTtsThiTuyen) {
        showToast(context: context, msg: "C???p nh???t kh??ng th??nh c??ng !", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
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
          //Ch??a ????ng ti???n sau thi tuy???n
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
          //Th??m v??o nh???t k?? x??? l?? c???a tts
          bool result = checkExistInTtsThanhToan(listTTSLSTT[i]['orderId'], listTTSLSTT[i]['ttsId'], listTTSThanhToan, listDoTruot[i]);
          if (!result) {
            await httpPostDiariStatus(listTTSLSTT[i]['thuctapsinh']['id'], listTTSLSTT[i]['thuctapsinh']['ttsStatusId'], getTtsStatusId(listDoTruot[i]),
                getResultName(listDoTruot[i], listTTSLSTT[i]['donhang']['orderName'], getDateViewDayAndHour(FormatDate.formatDateInsertDBHHss(DateTime.now()))), context);
          } else {
            await httpPostDiariStatus(listTTSLSTT[i]['thuctapsinh']['id'], listTTSLSTT[i]['thuctapsinh']['ttsStatusId'], listTTSLSTT[i]['thuctapsinh']['ttsStatusId'],
                "Chuy???n sang ch??? ????o t???o do ???? ????ng ti???n v?? tr??ng tuy???n ????n h??ng ${listTTSLSTT[i]['donhang']['orderName']}", context);
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
    //======B???n th??ng b??o
    try {
      for (int i = 0; i < listDoTruot.length; i++) {
        //B???n th??ng b??o theo tr?????ng h???p ????? tr?????t
        if (listDoTruot[i] == doTruot.Do) {
          listTtsDo.add(listTTSLSTT[i]['thuctapsinh']['userCode']);
          //b???n cho ph??ng
          await httpPost(
              "/api/push/tags/depart_id/6&7",
              {
                "title": "H??? th???ng th??ng b??o",
                "message":
                    "TTS m?? ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} ???? tr??ng tuy???n ????n h??ng ${listTTSLSTT[i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']}"
              },
              context);

          await httpPost(
              "/api/push/tags/user_code/${listTTSLSTT[i]['thuctapsinh']['nhanvientuyendung']['userCode']}",
              {
                "title": "H??? th???ng th??ng b??o",
                "message":
                    "TTS m?? ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} ???? tr??ng tuy???n ????n h??ng ${listTTSLSTT[i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']}"
              },
              context);
          print(
              "TTS m?? ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} ???? tr??ng tuy???n ????n h??ng ${listTTSLSTT[i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']}");
        }
        if (listDoTruot[i] == doTruot.DuBi) {
          //b???n cho ph??ng
          await httpPost(
              "/api/push/tags/depart_id/6&7",
              {
                "title": "H??? th???ng th??ng b??o",
                "message":
                    "TTS m?? ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} ???? d??? b??? ????n h??ng ${listTTSLSTT[i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']}"
              },
              context);

          await httpPost(
              "/api/push/tags/user_code/${listTTSLSTT[i]['thuctapsinh']['nhanvientuyendung']['userCode']}",
              {
                "title": "H??? th???ng th??ng b??o",
                "message":
                    "TTS m?? ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} ???? d??? b??? ????n h??ng ${listTTSLSTT[i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']}"
              },
              context);
          print(
              "TTS m?? ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} ???? d??? b??? ????n h??ng ${listTTSLSTT[i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']}");
        }
        if (listDoTruot[i] == doTruot.BoThi) {
          //b???n cho ph??ng
          await httpPost(
              "/api/push/tags/depart_id/6&7",
              {
                "title": "H??? th???ng th??ng b??o",
                "message":
                    "TTS m?? ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} ???? b??? thi ????n h??ng ${listTTSLSTT[i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']}"
              },
              context);

          await httpPost(
              "/api/push/tags/user_code/${listTTSLSTT[i]['thuctapsinh']['nhanvientuyendung']['userCode']}",
              {
                "title": "H??? th???ng th??ng b??o",
                "message":
                    "TTS m?? ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} ???? b??? thi ????n h??ng ${listTTSLSTT[i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']}"
              },
              context);
          print(
              "TTS m?? ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} ???? b??? thi ????n h??ng ${listTTSLSTT[i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']}");
        }
        if (listDoTruot[i] == doTruot.Truot) {
          listTtsTruot.add(listTTSLSTT[i]['thuctapsinh']['userCode']);
          //b???n cho ph??ng
          await httpPost(
              "/api/push/tags/depart_id/6&7",
              {
                "title": "H??? th???ng th??ng b??o",
                "message":
                    "TTS m?? ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} ???? tr?????t ????n h??ng ${listTTSLSTT![i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']} . ????? ngh??? ti???n c??? v??o ????n h??ng kh??c."
              },
              context);
          await httpPost(
              "/api/push/tags/user_code/${listTTSLSTT[i]['thuctapsinh']['nhanvientuyendung']['userCode']}",
              {
                "title": "H??? th???ng th??ng b??o",
                "message":
                    "TTS m?? ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} ???? tr?????t ????n h??ng ${listTTSLSTT![i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']} . ????? ngh??? ti???n c??? v??o ????n h??ng kh??c."
              },
              context);
          print(
              "TTS m?? ${listTTSLSTT[i]['thuctapsinh']['userCode']}-${listTTSLSTT[i]['thuctapsinh']['fullName']} ???? tr?????t ????n h??ng ${listTTSLSTT[i]['donhang']['orderCode']}-${listTTSLSTT[i]['donhang']['orderName']}");
        }
      }
      //X??? l?? ph???n b???n th??ng b??o cho tts
      await banThongBaoChoTts(listTtsDo, listTTSLSTT.first['donhang'], true); //?????

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
              'X??c nh???n k???t th??c thi tuy???n',
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
                          ? "??ang c?? TTS t???m d???ng x??? l??.\nN???u k???t th??c thi tuy???n s??? c???p nh???t TTS d???ng x??? l?? th??nh b??? thi .\nB???n v???n mu???n x??c nh???n?"
                          : "B???n c?? ch???c ch???c mu???n x??c nh???n!",
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
                  child: Text('H???y')),
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
                    //C???p nh???t l???ch s??? thi tuy???n th??nh
                    // var requestBody = {
                    //   //Tr???ng th??i=0:Ch??a thi|1:???? thi|2:H???y
                    //   'status': 1,
                    // };
                    widget.resultLTTChiTiet['status'] = 1;
                    bool resultUpdateLichThiTuyen = await putLichThiTuyen(widget.idLtt!, widget.resultLTTChiTiet, context);
                    if (resultUpdateLichSuTtsThiTuyen && resultUpdateNguoiDung && resultUpdateLichThiTuyen) {
                      await banThongBao(widget.listDoTruot, widget.listTTT);
                      showToast(context: context, msg: "???? ho??n th??nh thi tuy???n !", color: Colors.green, icon: Icon(Icons.done));
                      Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/lich-thi-tuyen"); //tr?????t
                      Navigator.pop(context);
                      Navigator.pop(context);
                    } else {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      showToast(context: context, msg: "C???p nh???t kh??ng th??nh c??ng !", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                },
                child: Text('X??c nh???n'),
              ),
            )
          ],
        ),
      ],
    );
  }
}
