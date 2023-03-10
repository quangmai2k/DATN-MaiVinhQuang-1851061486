import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/model/market_development/tss_don_hang.dart';
import 'package:gentelella_flutter/model/market_development/user.dart';

import '../../../../api.dart';
import '../../../../common/format_date.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../model/market_development/order.dart';
import '../../../forms/market_development/utils/funciton.dart';
import '../../source_information/common_ource_information/constant.dart';

class ModalPerformOrder extends StatefulWidget {
  final List<Order>? listOrderSelected;
  final Function? func;
  ModalPerformOrder({Key? key, this.listOrderSelected, this.func}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ModalPerformOrderState();
  }
}

class _ModalPerformOrderState extends State<ModalPerformOrder> {
  TextEditingController _reasonController = TextEditingController();
  String? er;
  bool _isSetLoanding = true;
  Future<bool> updateStatusOrder(var requestBody, int id) async {
    try {
      var response = await httpPut(Uri.parse('/api/donhang/put/${id}'), requestBody, context); //Tra ve id
      if (jsonDecode(response['body']) == true) {
        return true;
      } else {
        return false;
      }
    } catch (_) {
      print("Fail!");
    }
    return false;
  }

  Future<bool> saveTtsDonHang(var requestBody) async {
    try {
      var response = await httpPost(Uri.parse('/api/tts-donhang-dungxuly/post/save'), requestBody, context);
      if (isNumber(jsonDecode(response['body']).toString())) {
        return true;
      } //Tra ve id
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

  Future<int> postTtsDonhangDungxuly(dynamic requestBody) async {
    try {
      var response = await httpPost('/api/tts-donhang-dungxuly/post/save', requestBody, context); //Tra ve id
      if (isNumber(jsonDecode(response['body']).toString())) {
        return jsonDecode(response['body']);
      }
    } catch (_) {
      print("Fail!");
    }
    return -1;
  }

  handleButtonStartProcessing() async {
    try {
      var requestBody = {
        "stopProcessing": 1, //T???m d???ng x??? l??=0:Kh??ng|1:C??
      };
      int countSucces = 0;
      int countstopProcessing = 0;
      String conditon = "";

      List<User> listTtsStopProcessing = [];
      for (var item in widget.listOrderSelected!) {
        if (item.stopProcessing != 1) {
          bool result = await updateStatusOrder(requestBody, item.id);
          var requestBodyTTSDonHang = {"orderId": item.id, "causeContent": _reasonController.text, "causeType": 2, "approvalType": 1, "itemType": 1};

          bool resultSave = await saveTtsDonHang(
            requestBodyTTSDonHang,
          );

          if (result && resultSave) {
            if (countSucces == 0) {
              conditon += "${item.id}";
            } else {
              conditon += "&${item.id}";
            }
            countSucces++;
          }
          countstopProcessing++;
        }
      }
      if (countstopProcessing == 0) {
        showToast(context: context, msg: "C??c ????n h??ng n??y ??ang ch??? x??? l?? d??ng th???c hi???n", color: Color.fromARGB(135, 247, 217, 179), icon: Icon(Icons.supervised_user_circle));
        widget.func!(true);
      }
      if (countSucces > 0) {
        //Th??ng b??o
        showToast(context: context, msg: "???? t???m d???ng x??? l?? ????n h??ng", color: Colors.green, icon: Icon(Icons.supervised_user_circle));
        //C???p nh???t l???i tr???ng th??i ng?????i d??ng thaah stopprocessing = 1
        try {
          if (conditon.isNotEmpty) {
            int countUpdateTts = 0;
            int countResultAddTtsDonHangDungXuLy = 0;

            listTtsStopProcessing = await getListTtsInOrder(conditonOrderId: conditon);
            for (var tts in listTtsStopProcessing) {
              var requestBodyUser = {"stopProcessing": 1, "isTts": 1, "orderId": tts.order!.id};
              bool result = await putNguoiDung(tts.id, requestBodyUser, context);

              //Th??m m???i v??o b???ng tts-donhangdungxuly
              var dataTtsDonHangDungXuLy = {
                "ttsId": tts.id,
                "itemType": 0,
                "causeType": 2, //Nguy??n nh??n d???ng x??? l??=0:C?? nh??n|1:Nghi???p ??o??n|2:Kh??c
                "causeContent": _reasonController.text,
                "approvalType": 0 /*Lo???i ?????i t?????ng: 0:TTS | 1: ????n h??ng*/
              };

              int resultAdd = await postTtsDonhangDungxuly(dataTtsDonHangDungXuLy);
              if (resultAdd != -1) {
                countResultAddTtsDonHangDungXuLy++;
              }
              if (result) {
                countUpdateTts++;
              }

              //Th??m m???i v??o nh???t k??
              await httpPostDiariStatus(tts.id, tts.ttsStatusId, tts.ttsStatusId, 'T???m d???ng x??? l??', context);
            }
            if (countUpdateTts == listTtsStopProcessing.length && countResultAddTtsDonHangDungXuLy == listTtsStopProcessing.length) {
              print("Th??nh c??ng");
            } else {
              print("Kh??ng c???p nh???p ???????c h???t");
            }
          }
        } catch (e) {
          print("Ngo???i l??? trong qu?? tr??nh c???p nh???t ng?????i d??ng" + e.toString());
        }

        //B???n th??ng b??o c
        widget.func!(true);
        for (var item in widget.listOrderSelected!) {
          if (item.stopProcessing != 1) {
            try {
              //Th??ng b??o cho pttt
              await httpPost(
                  "/api/push/tags/user_type/aam",
                  {
                    "title": "H??? th???ng th??ng b??o",
                    "message": "????n h??ng c?? m?? ${item.orderCode} ??ang t???m d???ng x??? l?? l??c ${getDateViewDayAndHour(FormatDate.formatDateInsertDBHHss(DateTime.now()))}"
                  },
                  context);
            } catch (e) {
              print("Ex " + e.toString());
            }
          }
        }

        //B???n th??ng b??o cho tts trong ????n h??ng
        if (listTtsStopProcessing.isNotEmpty) {
          for (var tts in listTtsStopProcessing) {
            try {
              await httpPost(
                  API_THONG_BAO_PHONG_BAN_POST + "3&4&5&6&7&8&9&10",
                  {
                    "title": TIEU_DE_THONG_BAO,
                    "message": "T???m d???ng x??? l?? TTS c?? m?? ${tts.userCode} l??c ${getDateViewDayAndHour(FormatDate.formatDateInsertDBHHss(DateTime.now()))}",
                  },
                  context);
            } catch (e) {
              print(e);
            }
          }
        }
        //B???n th??ng b??o cho tts trong ????n h??ng end
      } else {
        showToast(context: context, msg: "C???p nh???t kh??ng th??nh c??ng", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
      }
    } catch (e) {
      print("Ngo???i l??? to??n b???" + e.toString());
    }
  }

  Future<List<User>> getListTtsInOrder({conditonOrderId}) async {
    List<User> listTtsDonHangTienCu = [];

    try {
      var response = await httpGet("/api/nguoidung/get/page?filter=orderId in ($conditonOrderId)", context);

      var body = jsonDecode(response['body']);
      var content = [];
      if (response.containsKey("body")) {
        setState(() {
          content = body['content'];
          listTtsDonHangTienCu = content.map((e) {
            return User.fromJson(e);
          }).toList();
        });
      }
    } catch (e) {
      print(e);
    }

    return listTtsDonHangTienCu;
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
              'X??c nh???n d???ng th???c hi???n ????n h??ng',
              style: TextStyle(fontWeight: FontWeight.w800),
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
        height: 260,
        width: 600,
        child: _isSetLoanding
            ? Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    child: Column(
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Text(
                                  "L?? do",
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 10, bottom: 10),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 9,
                                child: Container(
                                  child: TextFormField(
                                    decoration: InputDecoration(
                                        isDense: true,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(Radius.circular(0)),
                                        ),
                                        errorText: er),
                                    minLines: 6, // any number you need (It works as the rows for the textarea)
                                    maxLines: 6,
                                    keyboardType: TextInputType.multiline,
                                    controller: _reasonController,
                                    onChanged: (value) {
                                      if (value.isNotEmpty) {
                                        setState(() {
                                          er = null;
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ),
                ],
              )
            : Center(
                child: Container(
                  child: Column(
                    children: [Text("??ang x??? l??. Vui l??ng ?????i ch??t..."), CircularProgressIndicator()],
                  ),
                ),
              ),
      ),
      actions: <Widget>[
        ElevatedButton(
          // textColor: Color(0xFF6200EE),
          onPressed: () => Navigator.pop(context),
          child: Text(
            'H???y',
            style: TextStyle(color: Colors.black),
          ),

          style: ElevatedButton.styleFrom(
            primary: Colors.white,
            onPrimary: Colors.white,
            // shadowColor: Colors.greenAccent,
            side: const BorderSide(
                width: 2, // the thickness
                color: Colors.grey // the color of the border
                ),
            elevation: 3,
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(32.0)),
            minimumSize: Size(140, 50), //////// HERE
          ),
        ),
        ElevatedButton(
          // textColor: Color(0xFF6200EE),
          onPressed: () async {
            if (_reasonController.text.isEmpty) {
              setState(() {
                er = "B???n ch??a nh???p l?? do";
              });
              return;
            }
            setState(() {
              _isSetLoanding = false;
            });
            await handleButtonStartProcessing();

            Navigator.pop(context);
          },
          child: Text(
            'X??c nh???n',
            style: TextStyle(),
          ),
          style: ElevatedButton.styleFrom(
            primary: colorBlueBtnDialog,
            onPrimary: colorWhite,
            // shadowColor: Colors.greenAccent,
            elevation: 3,
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(32.0)),
            minimumSize: Size(140, 50), //////// HERE
          ),
        ),
      ],
    );
  }
}
