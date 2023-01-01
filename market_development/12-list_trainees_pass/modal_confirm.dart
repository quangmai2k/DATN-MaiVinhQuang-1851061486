import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';
import 'package:gentelella_flutter/widgets/ui/market_development/12-list_trainees_pass/service.dart';

import '../../../../api.dart';
import '../../../../common/toast.dart';
import '../../../../model/market_development/user.dart';

class ModelConfirm12 extends StatefulWidget {
  final String? url;
  final String? label;
  final List<User>? listTts;
  final Function? func;
  final int? orderId;

  ModelConfirm12({Key? key, this.url, this.label, this.listTts, this.func, this.orderId}) : super(key: key);
  @override
  State<ModelConfirm12> createState() => _ModelConfirm12State();
}

class _ModelConfirm12State extends State<ModelConfirm12> {
  //update api trang thai thực tập sinh đã hoàn thành sau khi đã xuất cảnh

  List<User> listCheckTTSDonHangAllThuocDonHang = [];

  Future<bool> updateTTSStatus12(var requestBody, int id) async {
    try {
      //var finalRequestBody = jsonEncode(ttsDonHangUpdate);
      var response = await httpPut(Uri.parse('/api/nguoidung/put/$id'), requestBody, context);
      var body = jsonDecode(response['body']);
      if (body.containsKey("1")) {
        return true;
      } //Tra ve id
    } catch (_) {
      print("Fail!");
    }
    return false;
  }

  Future getListAllTtsTheoDonHang(idSelectedDonHang) async {
    var response1 = await httpGet(
        "/api/nguoidung/get/page?filter=orderId:$idSelectedDonHang and isTts:1 and (ttsStatusId:11 or ttsStatusId:12 or ttsStatusId:10) and (stopProcessing:0 or stopProcessing is null )",
        context);
    var body = jsonDecode(response1['body']);
    var content = [];
    if (response1.containsKey("body")) {
      setState(() {
        content = body['content'];
        listCheckTTSDonHangAllThuocDonHang = content.map((e) {
          return User.fromJson(e);
        }).toList();

        print(listCheckTTSDonHangAllThuocDonHang);
      });
    }
  }

  checkTtsDaHoanThanhHet(List<User> listTtsAll) {
    List<User> listTtsXuatCanh = [];
    for (int i = 0; i < listTtsAll.length; i++) {
      if (listTtsAll[i].ttsStatusId == 12) {
        //Đã hoàn thành
        listTtsXuatCanh.add(listTtsAll[i]);
      }
    }
    if (listTtsXuatCanh.length == listTtsAll.length) {
      return true;
    }
    return false;
  }
  // Future<int> httpPostDiari(userId, statusUserId, statusUserIdAfter) async {
  //   try {
  //     var response = await httpPostDiariStatus(userId, statusUserId, statusUserIdAfter, 'Xác nhận xuất cảnh', context);
  //     var body = jsonDecode(response['body']);
  //     if (isNumber(body.toString())) {
  //       return body;
  //     }
  //   } catch (e) {
  //     print("Lỗi $e");
  //   }
  //   return -1;
  // }

  Future<bool> updateTrangThaiDonHang(var resquestBody, int id) async {
    //Cập nhật lại trạng thái đơn hàng là đã hoàn thành
    try {
      //var finalRequestBody = jsonEncode(ttsDonHangUpdate);
      var response = await httpPut(Uri.parse('/api/donhang/put/$id'), resquestBody, context); //Tra ve id

      if (jsonDecode(response['body']) == true) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      print("Lỗi $e");
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
  }

  callApi() async {
    await getListAllTtsTheoDonHang(widget.orderId);
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
            child: Text('Confirm'),
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
        height: 90,
        width: 500,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 30),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Text(
                      widget.label != null ? widget.label! : "Bạn có chắc chắn muốn hủy chức năng này?",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
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
                    onPrimary: Color(0xffF77919), // Background color
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Từ chối')),
            ),
            Container(
              width: 120,
              height: 40,
              padding: EdgeInsets.only(left: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xffF77919),
                  onPrimary: Colors.white, // Background color
                ),
                onPressed: () async {
                  try {
                    int countUpdateTTS = 0;
                    int countAddNhatKyXuLySuccess = 0;
                    if (widget.listTts != null) {
                      for (var tts in widget.listTts!) {
                        var requestTts = {"ttsStatusId": 12, "isTts": 1, "orderId": widget.orderId};
                        bool reuslt = await updateTTSStatus12(requestTts, tts.id);
                        int idAddNhatKyXuLy = await httpPostDiari(tts.id, tts.status!.id!, 12, "Xác nhận xuất cảnh", context);
                        if (idAddNhatKyXuLy != -1) {
                          countAddNhatKyXuLySuccess++;
                        }
                        if (reuslt) {
                          countUpdateTTS++;
                        }
                      }
                    }
                    if (countUpdateTTS == widget.listTts!.length) {
                      await callApi();
                      if (checkTtsDaHoanThanhHet(listCheckTTSDonHangAllThuocDonHang)) {
                        bool resultUpdateDonHang = false;
                        if (widget.orderId != null) {
                          var requestDonHang = {"orderStatusId": 4};
                          resultUpdateDonHang = await updateTrangThaiDonHang(requestDonHang, widget.orderId!);
                        }

                        if (countUpdateTTS == widget.listTts!.length && resultUpdateDonHang && countAddNhatKyXuLySuccess == widget.listTts!.length) {
                          showToast(context: context, msg: "Lưu thành công", color: Colors.green, icon: Icon(Icons.supervised_user_circle));
                          widget.func!();
                          Navigator.pop(context);
                        } else {
                          showToast(context: context, msg: "Cập nhật không thành công", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
                          widget.func!();
                          Navigator.pop(context);
                        }
                      }
                    } else {
                      showToast(context: context, msg: "Cập nhật không thành công", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
                      widget.func!();
                      Navigator.pop(context);
                    }
                  } catch (e) {
                    print(e);
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
