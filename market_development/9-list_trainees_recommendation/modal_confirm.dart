import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/format_date.dart';
import 'package:gentelella_flutter/model/type.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';
import 'package:provider/provider.dart';
import '../../../../api.dart';

import '../../../../common/toast.dart';

import '../../../../model/market_development/order.dart';
import '../../../../model/market_development/tss_don_hang.dart';
import '../../../../model/model.dart';

class ModelConfirm extends StatefulWidget {
  final String? url;
  final String? label;
  final int? idSelectedDonHang;
  final List<TTSDonHang>? listCheckTTSDonHangTienCu;
  final Function? func;
  final Order? order;
  ModelConfirm({Key? key, this.url, this.label, this.idSelectedDonHang, this.func, this.listCheckTTSDonHangTienCu, this.order}) : super(key: key);

  @override
  State<ModelConfirm> createState() => _ModelConfirmState();
}

class _ModelConfirmState extends State<ModelConfirm> {
  Future<bool> putTtsLichsuTiencu(List<dynamic> listDynamic, context) async {
    try {
      var response = await httpPut(Uri.parse('/api/tts-lichsu-tiencu/put/all'), listDynamic, context); //Tra ve id

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

  Future<bool> updatePtttApproval(int idSelectedDonHang, requestBody) async {
    try {
      var response = await httpPut(Uri.parse('/api/donhang-tts-tiencu/put/$idSelectedDonHang'), requestBody, context); //Tra ve id
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

  // Future<bool> updatePtttApprovalAll(List<TTSDonHang> listTTSDonHang) async {
  //   List<dynamic> listUpdate = [];
  //   for (var element in listTTSDonHang) {
  //     element.ptttApproval = 1;
  //     listUpdate.add(element.toMap());
  //   }
  //   try {
  //     var response = await httpPut(Uri.parse('/api/donhang-tts-tiencu/put/all'), listUpdate, context); //Tra ve id
  //     if (jsonDecode(response['body']) == true) {
  //       return true;
  //     } else {
  //       return false;
  //     }
  //   } catch (_) {
  //     print("Fail!");
  //   }
  //   return false;
  // }

  //update api nguoidung.ttsStatusId th??nh ???? ti???n c???
  Future<bool> updateTtsStatusId(int idTTS, var requestBody) async {
    try {
      var response = await httpPut(Uri.parse('/api/nguoidung/put/${idTTS}'), requestBody, context); //Tra ve id
      await httpPostDiariStatus(idTTS, 4, 5, 'Duy???t ti???n c??? ????n h??ng ${widget.order!.orderName}', context);
      if (jsonDecode(response["body"]).containsKey("1")) {
        return true;
      } else {
        return false;
      }
    } catch (_) {
      print("Fail!");
    }
    return false;
  }

  saveTTSThanhToan(requestBody, context) async {
    try {
      var response = await httpPost(Uri.parse('/api/tts-thanhtoan/post/save'), requestBody, context); //Tra ve id
      return jsonDecode(response['body']);
    } catch (e) {
      print("Fail!");
    }
    return null;
  }

  updateTTSThanhToan(id, requestBody, context) async {
    try {
      var response = await httpPut(Uri.parse('/api/tts-thanhtoan/put/$id'), requestBody, context); //Tra ve id
      return jsonDecode(response['body']);
    } catch (e) {
      print("Fail!");
    }
    return null;
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

  Future<List<dynamic>> getTTSDonHang(List<TTSDonHang> idTts, int orderId, context) async {
    String conditon = "";
    if (idTts.isNotEmpty) {
      conditon += "(";
      for (int i = 0; i < idTts.length; i++) {
        if (i == 0) {
          conditon += "${idTts[i].user!.id}";
        } else {
          conditon += ",${idTts[i].user!.id}";
        }
      }
      conditon += ")";
    }

    var response = await httpGet("/api/donhang-tts-tiencu/get/page?filter=ttsId in $conditon AND ptttApproval:0 AND orderId!$orderId ", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      content = body['content'];
    }
    return content;
  }

  Future<List<dynamic>> getTTSThanhToan(idTts, context) async {
    var response = await httpGet("/api/tts-thanhtoan/get/page?sort=createdDate,desc&filter=ttsId:$idTts", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      content = body['content'];
    }
    return content;
  }

  Future<List<dynamic>> getTTSThanhToanByIdTtsAndOrderId(idTts, orderId, context) async {
    var response = await httpGet("/api/tts-thanhtoan/get/page?sort=createdDate,desc&filter=ttsId:$idTts AND orderId:$orderId", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      content = body['content'];
    }
    return content;
  }

  Future<bool> handlePutTtsLSTC(securityModel, listCheckTTSDonHangTienCu, listPutTtsTienCu) async {
    bool resultUpdateLichSuTtsTienCu = await putTtsLichsuTiencu(listPutTtsTienCu, context);
    print(resultUpdateLichSuTtsTienCu);
    return resultUpdateLichSuTtsTienCu;
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<NavigationModel, SecurityModel, CaiDatThoiGian>(
        builder: (context, navigationModel, securityModel, number, child) => AlertDialog(
              title: Row(
                children: [
                  Image.asset(
                    "assets/images/logoAAM.png",
                    width: 30,
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text('X??c nh???n duy???t'),
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
                              widget.label != null ? widget.label! : "B???n c?? ch???c ch???n mu???n h???y ch???c n??ng n??y?",
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
                          child: Text('T??? ch???i')),
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
                          // List<dynamic> listTtsDonHangTienCu = await getTTSDonHang(widget.listCheckTTSDonHangTienCu!, widget.idSelectedDonHang!, context);
                          onLoading(context);
                          int countUpdateTTS = 0;
                          int countTTSThanhToan = 0;
                          var idTTSThanhToan;
                          // List<dynamic> listPutTtsTienCu = [];
                          //====
                          // for (var i = 0; i < widget.listCheckTTSDonHangTienCu!.length; i++) {
                          //   listPutTtsTienCu.add({
                          //     "ttsId": widget.listCheckTTSDonHangTienCu![i].user!.id,
                          //     "orderId": widget.idSelectedDonHang,
                          //     "status": 1, //Duy???t
                          //     "approver": securityModel.userLoginCurren['id'],
                          //     "approveDate": FormatDate.formatDateInsertDBHHss(DateTime.now())
                          //   });
                          // }

                          // //C???p nh???t l???ch s??? ti???n c???a
                          // bool resultUpdateLichSuTtsTienCu = await handlePutTtsLSTC(securityModel, widget.listCheckTTSDonHangTienCu, listPutTtsTienCu);
                          // if (!resultUpdateLichSuTtsTienCu) {
                          //   showToast(context: context, msg: "C???p nh???t kh??ng th??nh c??ng !", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
                          //   Navigator.pop(context);
                          //   Navigator.pop(context);
                          //   return;
                          // }
                          //Caaph nh???p tts-??on
                          int countSuccesUpdate = 0;
                          for (var ttsdhtc in widget.listCheckTTSDonHangTienCu!) {
                            ttsdhtc.ptttApproval = 1;
                            bool resultUpdatePtttApproval = await updatePtttApproval(ttsdhtc.id, ttsdhtc.toMap());
                            if (resultUpdatePtttApproval) {
                              countSuccesUpdate++;
                            }
                          }

                          if (countSuccesUpdate != widget.listCheckTTSDonHangTienCu!.length) {
                            showToast(context: context, msg: "C???p nh???t kh??ng th??nh c??ng !", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
                            Navigator.pop(context);
                            Navigator.pop(context);
                            return;
                          }
                          for (var i = 0; i < widget.listCheckTTSDonHangTienCu!.length; i++) {
                            //C???p nh???t tr???ng th??i ng?????i d??ng
                            var ttsDonHangUpdate = {"ttsStatusId": 5, "isTts": 1, "orderId": widget.idSelectedDonHang};
                            bool reuslt1UpdateTtsStatusId = await updateTtsStatusId(widget.listCheckTTSDonHangTienCu![i].user!.id, ttsDonHangUpdate);
                            // List<dynamic> listTTSThanhToanByOrderIdAndTtsId =
                            //     await getTTSThanhToanByIdTtsAndOrderId(widget.listCheckTTSDonHangTienCu![i].user!.id, widget.idSelectedDonHang, context);

                            List<dynamic> listTTSThanhToan = await getTTSThanhToan(widget.listCheckTTSDonHangTienCu![i].user!.id, context);
                            if (listTTSThanhToan.isEmpty) {
                              var requestBody = {
                                "ttsId": widget.listCheckTTSDonHangTienCu![i].user!.id,
                                "orderId": widget.idSelectedDonHang,
                                "paidBeforeExam": 0,
                                "paidAfterExam": 0,
                                "paidBeforeFlight": 0,
                                "paidTuition": 0,
                                "paidBeforeExamDate": null,
                                "paidAfterExamDate": null,
                                "paidBeforeFlightDate": null,
                                "paidTuitionDate": null,
                                "paidBeforeExamVerifier": null,
                                "paidAfterExamVerifier": null,
                                "paidBeforeFlightVerifier": null,
                                "paidTuitionVerifier": null
                              };
                              idTTSThanhToan = await saveTTSThanhToan(requestBody, context);
                            } else {
                              int count = 0;
                              for (var item in listTTSThanhToan) {
                                if (item['orderId'] == widget.idSelectedDonHang) {
                                  count++;
                                  break;
                                }
                              }
                              if (count == 0) {
                                var dataTtsThanhToan = listTTSThanhToan.first;
                                dataTtsThanhToan['orderId'] = widget.idSelectedDonHang;
                                dataTtsThanhToan['id'] = null;
                                idTTSThanhToan = await saveTTSThanhToan(dataTtsThanhToan, context);
                              }
                            }
                            //L??u v??o th???c t???p sinh thanh to??n

                            if (reuslt1UpdateTtsStatusId) {
                              countUpdateTTS++;
                            }
                          }

                          if (countUpdateTTS == widget.listCheckTTSDonHangTienCu!.length) {
                            try {
                              //T??? ch???i c??ng c??c tts c???a ????n h??ng c??n l???i
                              List<dynamic> listTtsDonHangTienCu = await getTTSDonHang(widget.listCheckTTSDonHangTienCu!, widget.idSelectedDonHang!, context);
                              if (listTtsDonHangTienCu.isNotEmpty) {
                                for (var item in listTtsDonHangTienCu) {
                                  var requestBody = {"ptttApproval": 2, "orderId": item['orderId']};
                                  await httpPut("/api/donhang-tts-tiencu/put/${item['id']}", requestBody, context);
                                }
                              }
                            } catch (e) {
                              Navigator.pop(context);
                              Navigator.pop(context);
                              print(e);
                            }

                            showToast(context: context, msg: "L??u th??nh c??ng", color: Colors.green, icon: Icon(Icons.supervised_user_circle));
                            //Th??ng b??o
                            for (var i = 0; i < widget.listCheckTTSDonHangTienCu!.length; i++) {
                              try {
                                //Th??ng b??o cho t???ng tts
                                try {
                                  await httpPost(
                                      "/api/push/tags/user_code/${widget.listCheckTTSDonHangTienCu![i].user!.userCode}",
                                      {
                                        "title": "H??? th???ng th??ng b??o",
                                        "message":
                                            "B???n ???? ???????c ti???n c??? v??o ????n h??ng ${widget.order!.orderCode}-${widget.order!.orderName} l??c ${getDateViewDayAndHour(FormatDate.formatDateInsertDBHHss(DateTime.now()))}."
                                      },
                                      context);
                                } catch (_) {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  print("Ngo???i l??? 1");
                                }

                                //Th??ng b??o cho th??ng tin ngu???n v?? pttt
                                try {
                                  await httpPost(
                                      "/api/push/tags/depart_id/3&5",
                                      {
                                        "title": "H??? th???ng th??ng b??o",
                                        "message":
                                            "Ph??ng PTTT Nh???t b???n duy???t ?????ng ?? ti???n c??? TTS c?? m?? ${widget.listCheckTTSDonHangTienCu![i].user!.userCode}-${widget.listCheckTTSDonHangTienCu![i].user!.fullName} v??o ????n h??ng ${widget.order!.orderCode}-${widget.order!.orderName} l??c ${getDateViewDayAndHour(FormatDate.formatDateInsertDBHHss(DateTime.now()))}"
                                      },
                                      context);
                                } catch (_) {
                                  Navigator.pop(context);
                                  Navigator.pop(context);
                                  print("Ngo???i l??? 2");
                                }
                              } catch (e) {
                                print(e);
                              }
                            }
                            //Th??ng b??o
                            if (widget.func != null) {
                              await widget.func!();
                            }
                            Navigator.pop(context);
                            Navigator.pop(context);
                            return;
                          } else {
                            showToast(context: context, msg: "Th???t b???i", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
                            if (widget.func != null) {
                              widget.func!();
                            }
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
            ));
  }
}
