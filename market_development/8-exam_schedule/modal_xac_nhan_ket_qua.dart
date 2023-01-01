import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../api.dart';
import '../../../../common/toast.dart';
import '../../../../model/model.dart';
import 'view_detail.dart';

class ShowNotification extends StatefulWidget {
  final List<doTruot>? listDoTruot;
  final List<doTruot>? listDoTruotUpdate;
  final List<dynamic>? listTTSLSTT;
  final int? idLtt;
  final String? examDate;
  ShowNotification({Key? key, this.listDoTruot, this.listDoTruotUpdate, this.listTTSLSTT, this.idLtt, this.examDate}) : super(key: key);

  @override
  State<ShowNotification> createState() => _ShowNotificationState();
}

class _ShowNotificationState extends State<ShowNotification> {
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

  @override
  void initState() {
    super.initState();
    print("aaaaaaaaaaaaaaa" + widget.listDoTruotUpdate.toString());
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

  bool kiemTraKhongChonKetQua(listTtsLichSuThiTuyen, listDoTruot) {
    if (listDoTruot.contains(doTruot.KhongChon)) {
      Navigator.pop(context);
      showToast(context: context, msg: "Cập nhật đầy đủ kết quả cho thực tập sinh !", color: Color.fromARGB(255, 241, 228, 109), icon: Icon(Icons.warning));
      return true;
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
          examResult = 0;
      }
      listTTSLSTT[i]["examDate"] = listTTSLSTT[i]["examDate"] != null ? listTTSLSTT[i]["examDate"] : widget.examDate;
      listTTSLSTT[i]["examResult"] = examResult;
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
      return 15;
    }
    if (result == doTruot.BoThi) {
      return 14;
    }
  }

  getResultName(result) {
    if (result == doTruot.Do) {
      return "Đã trúng tuyển";
    }
    if (result == doTruot.Truot) {
      return "Thi trượt";
    }
    if (result == doTruot.DuBi) {
      return "Dự bị";
    }
    if (result == doTruot.BoThi) {
      return "Bỏ thi";
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
      return orderId;
    }
    if (result == doTruot.BoThi) {
      return null;
    }
  }

  Future<bool> capNhatLichSuThiTuyen(listTtsLichSuThiTuyen) async {
    bool resultUpdateLichSuTtsThiTuyen = false;
    if (listTtsLichSuThiTuyen.isNotEmpty) {
      List<dynamic> listUpdate = [];
      for (var element in listTtsLichSuThiTuyen) {
        if (element['thuctapsinh']['stopProcessing'] != 1) {
          listUpdate.add(element);
        }
      }

      resultUpdateLichSuTtsThiTuyen = await putTtsLichsuThiTuyen(listUpdate, context);
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

  checkExistInTtsThanhToan(orderId, ttsId, listTTSThanhToan, doTruot1) {
    for (var item in listTTSThanhToan) {
      if (item["orderId"] == orderId && item["ttsId"] == ttsId && (item["paidAfterExam"] == 1 || item["paidAfterExam"] == 2) && doTruot1 == doTruot.Do) {
        return true;
      }
    }
    return false;
  }

  capNhatTrangThaiNguoiDungVaLuuNhatKy(listDoTruot, listTTSLSTT, listDoTruotUpdate) async {
    int countSuccessUpdateNguoiDung = 0;
    List<dynamic> listNotStopProccess = [];
    var listTTSThanhToan = await getDsttsTt(listTTSLSTT);
    int countSucces = 0;
    for (int i = 0; i < listDoTruot.length; i++) {
      if (listTTSLSTT[i]['thuctapsinh']['stopProcessing'] != 1) {
        bool isUpdate = false;
        //Tồn tại tts đã thu tiền sau thi tuyển
        if (checkExistInTtsThanhToan(listTTSLSTT[i]['orderId'], listTTSLSTT[i]['ttsId'], listTTSThanhToan, listDoTruot[i])) {
          var requestUpdateNguoiDung = {
            "orderId": getOrderId(listDoTruot[i], listTTSLSTT[i]['orderId']),
            "ttsStatusId": 8, //Chờ đào tạo
            "isTts": 1,
          };
          bool resultUpdate = await putNguoiDung(listTTSLSTT[i]['thuctapsinh']['id'], requestUpdateNguoiDung, context);
          isUpdate = resultUpdate;
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
          if (listDoTruot[i] != listDoTruotUpdate[i]) {
            await httpPostDiariStatus(
                listTTSLSTT[i]['thuctapsinh']['id'], listTTSLSTT[i]['thuctapsinh']['ttsStatusId'], getTtsStatusId(listDoTruot[i]), getResultName(listDoTruot[i]), context);
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
    return Consumer<NavigationModel>(
        builder: (context, navigationModel, child) => AlertDialog(
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
                      'Xác nhận cập nhập kết quả thi tuyển',
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
                height: 100,
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
                              "Bạn có chắc chắc muốn xác nhận!",
                              style: TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 100,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
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
                          List<dynamic> listTtsLichSuThiTuyen = [];
                          int count = 0;
                          for (int i = 0; i < widget.listTTSLSTT!.length; i++) {
                            if (widget.listTTSLSTT![i]["thuctapsinh"]["stopProcessing"] != 1) {
                              if (widget.listDoTruot![i] == doTruot.KhongChon) {
                                count++;
                              }
                            }
                          }
                          if (count > 0) {
                            showToast(context: context, msg: "Cập nhật đầy đủ các kết quả cho các tts không bị dừng xử lý !", color: Colors.yellow, icon: Icon(Icons.warning));
                            return;
                          }
                          listTtsLichSuThiTuyen = await getListLSTC(widget.listDoTruot, widget.listTTSLSTT);

                          print(listTtsLichSuThiTuyen);
                          bool resultUpdateLichSuTtsThiTuyen = await capNhatLichSuThiTuyen(listTtsLichSuThiTuyen);
                          //bool resultUpdateNguoiDung = await capNhatTrangThaiNguoiDungVaLuuNhatKy(widget.listDoTruot, widget.listTTSLSTT, widget.listDoTruotUpdate);

                          if (resultUpdateLichSuTtsThiTuyen) {
                            showToast(context: context, msg: "Đã cập nhật thi tuyển !", color: Colors.green, icon: Icon(Icons.done));
                            await banThongBao(widget.listDoTruot, widget.listTTSLSTT);

                            navigationModel.add(pageUrl: '/lich-thi-tuyen');
                            Navigator.pop(context);
                          } else {
                            Navigator.pop(context);

                            showToast(context: context, msg: "Cập nhật không thành công !", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
                          }
                        },
                        child: Text('Xác nhận'),
                      ),
                    )
                  ],
                ),
              ],
            ));
  }
}
