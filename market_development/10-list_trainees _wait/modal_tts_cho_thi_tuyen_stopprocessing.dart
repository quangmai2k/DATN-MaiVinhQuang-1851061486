import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/api.dart';
import 'package:gentelella_flutter/common/style.dart';
import 'package:gentelella_flutter/common/toast.dart';
import 'package:provider/provider.dart';

import '../../../../common/format_date.dart';
import '../../../../model/market_development/lich_su_thi_tuyen.dart';

import '../../../../model/model.dart';
import '../../../forms/market_development/utils/funciton.dart';
import '../../source_information/common_ource_information/constant.dart';

class DungXuLyChoThiTuyen extends StatefulWidget {
  final Function? func;
  final String titleDialog;
  final int? ttsId;
  final int? donhangId;
  final int? doituong;
  final dynamic listId;
  final List<LichSuThiTuyen>? listLichSuThiTuyen;
  DungXuLyChoThiTuyen({Key? key, required this.titleDialog, required this.ttsId, required this.donhangId, this.doituong, this.func, this.listId, this.listLichSuThiTuyen})
      : super(key: key);

  @override
  State<DungXuLyChoThiTuyen> createState() => _DungXuLyChoThiTuyenState();
}

class _DungXuLyChoThiTuyenState extends State<DungXuLyChoThiTuyen> {
  bool check = false;
  TextEditingController mota = TextEditingController();
  var resultTTS;
  String? trangThai;
  Map<int, String> _mapTrangThai = {
    14: 'Chờ tiến cử lại',
    1: 'Dừng xử lý',
  };
  String? nguyenNhan;
  Map<int, String> _mapNguyenNhan = {
    0: ' Cá nhân',
    1: ' Nghiệp đoàn',
    2: ' Khác',
  };
  String? doituong;
  // ignore: unused_field
  Map<int, String> _doituong = {
    0: ' TTS',
    1: ' Đơn hàng',
  };

  Future<bool> updateStopProcessing(int idTTS, var requestBody) async {
    try {
      var response = await httpPut(Uri.parse('/api/nguoidung/put/$idTTS'), requestBody, context); //Tra ve id
      var body = jsonDecode(response['body']);
      if (body.containsKey("1")) {
        return true;
      }
    } catch (_) {
      print("Fail!");
    }
    return false;
  }

  Future<int> postTtsDonhangDungxuly(dynamic requestBody) async {
    try {
      var response = await httpPost('/api/tts-donhang-dungxuly/post/save', requestBody, context); //Tra ve id
      // return jsonDecode(response['body']);
      if (isNumber(jsonDecode(response['body']).toString())) {
        return jsonDecode(response['body']);
      }
    } catch (_) {
      print("Fail!");
    }
    return -1;
  }

  Future<bool> putTtsLichsuTiencu(List<dynamic> listDynamic, context) async {
    try {
      var response = await httpPut('/api/tts-lichsu-tiencu/put/all', listDynamic, context); //Tra ve id
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

  Future<bool> updateChoTienCuLai(int idTTS, var requestBody) async {
    try {
      var response = await httpPut(Uri.parse('/api/nguoidung/put/$idTTS'), requestBody, context); //Tra ve id
      var body = jsonDecode(response['body']);
      if (body.containsKey("1")) {
        return true;
      }
    } catch (_) {
      print("Fail!");
    }
    return false;
  }

  @override
  void initState() {
    super.initState();

    setState(() {
      trangThai = "1";
      nguyenNhan = "0";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NavigationModel, SecurityModel>(
        builder: (context, navigationModel, securityModel, child) => AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    child: Row(
                      children: [
                        Container(width: 40, height: 40, child: Image.asset('assets/images/logoAAM.png'), margin: EdgeInsets.only(right: 10)),
                        Text(widget.titleDialog, style: titleAlertDialog),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close),
                  ),
                ],
              ),
              content: Container(
                width: 550,
                height: 250,
                child: ListView(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Divider(
                            thickness: 1,
                          ),
                        ),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: Text('Trạng thái', style: titleWidgetBox)),
                              Expanded(
                                flex: 6,
                                child: Container(
                                  height: 40,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2(
                                      buttonDecoration: BoxDecoration(border: Border.all(width: 0.5, style: BorderStyle.solid)),
                                      hint: Text(' ${_mapTrangThai[1]}', style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor)),
                                      items: _mapTrangThai.entries
                                          .map((item) => DropdownMenuItem<String>(value: item.key.toString(), child: Text(item.value, style: const TextStyle(fontSize: 14))))
                                          .toList(),
                                      value: trangThai,
                                      onChanged: (value) {
                                        setState(() {
                                          trangThai = value as String;
                                        });
                                        print(trangThai);
                                      },
                                      buttonHeight: 40,
                                      itemHeight: 40,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(flex: 2, child: Container()),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: Text('Lý do', style: titleWidgetBox)),
                              Expanded(
                                flex: 6,
                                child: Container(
                                  height: 40,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2(
                                      buttonDecoration: BoxDecoration(border: Border.all(width: 0.5, style: BorderStyle.solid)),
                                      hint: Text('${_mapNguyenNhan[0]}', style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor)),
                                      items: _mapNguyenNhan.entries
                                          .map((item) => DropdownMenuItem<String>(value: item.key.toString(), child: Text(item.value, style: const TextStyle(fontSize: 14))))
                                          .toList(),
                                      value: nguyenNhan,
                                      onChanged: (value) {
                                        print(value);
                                        setState(() {
                                          nguyenNhan = value as String;
                                        });
                                      },
                                      buttonHeight: 40,
                                      itemHeight: 40,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(flex: 2, child: Container()),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(flex: 2, child: Text('Mô tả chi tiết', style: titleWidgetBox)),
                              Expanded(
                                flex: 6,
                                child: Container(
                                  width: 300,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 0.7, color: Color.fromARGB(255, 87, 85, 85)),
                                    color: Colors.transparent,
                                    // borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          controller: mota,
                                          expands: true,
                                          minLines: null,
                                          maxLines: null,
                                          decoration: InputDecoration(hintText: 'Nhập nội dung'),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(flex: 2, child: Container()),
                            ],
                          ),
                        ),
                        Container(child: Table()),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  // textColor: Color(0xFF6200EE),
                  onPressed: () => Navigator.pop(context),
                  child: Text('Hủy'),
                  style: ElevatedButton.styleFrom(primary: colorOrange, onPrimary: colorWhite, elevation: 3, minimumSize: Size(140, 50)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    print("Thái dat");
                    int countSubmit = 0;
                    if (nguyenNhan == null) {
                      countSubmit++;
                    }
                    if (mota.text.isEmpty) {
                      countSubmit++;
                    }

                    if (countSubmit > 0) {
                      showToast(context: context, msg: "Nhập đẩy đủ thông tin", color: Colors.red, icon: Icon(Icons.warning));
                      return;
                    }
                    print("Ok");
                    if (trangThai == "1") {
                      int countResultUpdateStopProcesing = 0;
                      //int countResultUpdateStopProcesing=0;
                      int countResultAddTtsDonHangDungXuLy = 0;
                      List<dynamic> listPutTtsTienCu = [];
                      //Tạm dừng xử lí tts
                      // for (int i = 0; i < widget.listLichSuThiTuyen!.length; i++) {
                      //   listPutTtsTienCu.add({
                      //     "ttsId": widget.listLichSuThiTuyen![i].user!.id,
                      //     "orderId": widget.donhangId,
                      //     "status": 2, ////0:Thêm mới|1:Duyệt|2:Từ chối
                      //     "approver": securityModel.userLoginCurren['id'],
                      //     "approveDate": FormatDate.formatDateInsertDBHHss(DateTime.now())
                      //   });
                      // }

                      // //Cập nhật lịch sử tiến cử
                      // bool resultUpdateLichSuTtsTienCu = await putTtsLichsuTiencu(listPutTtsTienCu, context);
                      // if (!resultUpdateLichSuTtsTienCu) {
                      //   showToast(context: context, msg: "Cập nhật không thành công !", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
                      //   Navigator.pop(context);
                      //   return;
                      // }

                      for (int i = 0; i < widget.listLichSuThiTuyen!.length; i++) {
                        //Cập nhật người dùng
                        var requestBody = {"stopProcessing": 1, "isTts": 1, "orderId": widget.listLichSuThiTuyen![i].orderId};
                        bool resultUpdateStopProcesing = await updateStopProcessing(widget.listLichSuThiTuyen![i].user!.id, requestBody);
                        if (resultUpdateStopProcesing) {
                          countResultUpdateStopProcesing++;
                        }

                        //Thêm mới vào bảng tts-donhangdungxuly
                        var dataTtsDonHangDungXuLy = {
                          "ttsId": widget.listLichSuThiTuyen![i].user!.id,
                          "itemType": 0,
                          "causeType": int.parse(nguyenNhan!),
                          "causeContent": mota.text,
                          "approvalType": 0 /*Loại đối tượng: 0:TTS | 1: Đơn hàng*/
                        };

                        int resultAdd = await postTtsDonhangDungxuly(dataTtsDonHangDungXuLy);
                        if (resultAdd != -1) {
                          countResultAddTtsDonHangDungXuLy++;
                        }

                        //Thêm mới vào nhật kí
                        await httpPostDiariStatus(widget.listLichSuThiTuyen![i].user!.id, widget.listLichSuThiTuyen![i].user!.ttsStatusId,
                            widget.listLichSuThiTuyen![i].user!.ttsStatusId, mota.text, context);
                      }

                      if (countResultAddTtsDonHangDungXuLy == widget.listLichSuThiTuyen!.length && countResultUpdateStopProcesing == widget.listLichSuThiTuyen!.length) {
                        showToast(context: context, msg: "Lưu thành công", color: Colors.green, icon: Icon(Icons.supervised_user_circle));

                        //Thông báo
                        for (int i = 0; i < widget.listLichSuThiTuyen!.length; i++) {
                          try {
                            await httpPost(
                                API_THONG_BAO_PHONG_BAN_POST + "3&4&5&6&7&8&9&10",
                                {
                                  "title": TIEU_DE_THONG_BAO,
                                  "message":
                                      "Tạm dừng xử lý TTS có mã ${widget.listLichSuThiTuyen![i].user!.userCode} lúc ${getDateViewDayAndHour(FormatDate.formatDateInsertDBHHss(DateTime.now()))}",
                                },
                                context);
                          } catch (e) {
                            print(e);
                          }
                        }
                        widget.func!();
                        Navigator.pop(context);
                        return;
                      } else {
                        showToast(context: context, msg: "Lưu không thành công", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
                        widget.func!();
                        Navigator.pop(context);
                        return;
                      }
                    }
                    if (trangThai == "14") {
                      int countResultUpdateStatus = 0;
                      //int countResultUpdateStopProcesing=0;
                      // List<dynamic> listPutTtsTienCu = [];

                      // for (int i = 0; i < widget.listLichSuThiTuyen!.length; i++) {
                      //   listPutTtsTienCu.add({
                      //     "ttsId": widget.listLichSuThiTuyen![i].user!.id,
                      //     "orderId": widget.donhangId,
                      //     "status": 2, ////0:Thêm mới|1:Duyệt|2:Từ chối
                      //     "approver": securityModel.userLoginCurren['id'],
                      //     "approveDate": FormatDate.formatDateInsertDBHHss(DateTime.now())
                      //   });
                      // }
                      // //Cập nhật lịch sử tiến cử
                      // bool resultUpdateLichSuTtsTienCu = await putTtsLichsuTiencu(listPutTtsTienCu, context);
                      // if (!resultUpdateLichSuTtsTienCu) {
                      //   showToast(context: context, msg: "Cập nhật không thành công !", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
                      //   Navigator.pop(context);
                      //   return;
                      // }
                      //Cập nhật chờ tiến cử lại cho TTS
                      for (int i = 0; i < widget.listLichSuThiTuyen!.length; i++) {
                        var requestBody = {"ttsStatusId": 14, "isTts": 1, "orderId": null};
                        bool resultUpdateStatus = await updateChoTienCuLai(widget.listLichSuThiTuyen![i].user!.id, requestBody);
                        if (resultUpdateStatus) {
                          countResultUpdateStatus++;
                        }

                        await httpPostDiariStatus(widget.listLichSuThiTuyen![i].user!.id, widget.listLichSuThiTuyen![i].user!.ttsStatusId, 14, mota.text, context);
                      }

                      if (countResultUpdateStatus == widget.listLichSuThiTuyen!.length) {
                        showToast(context: context, msg: "Lưu thành công", color: Colors.green, icon: Icon(Icons.supervised_user_circle));

                        //Bắn thông báo cho tts trong đơn hàng
                        for (int i = 0; i < widget.listLichSuThiTuyen!.length; i++) {
                          try {
                            await httpPost(
                                API_THONG_BAO_PHONG_BAN_POST + "3",
                                {
                                  "title": TIEU_DE_THONG_BAO,
                                  "message": "${widget.listLichSuThiTuyen![i].user!.userCode}-${widget.listLichSuThiTuyen![i].user!.fullName} được chuyển về chờ tiến cử lại.",
                                },
                                context);
                          } catch (e) {
                            print(e);
                          }
                        }
                        widget.func!();
                        Navigator.pop(context);
                        return;
                      } else {
                        showToast(context: context, msg: "Lưu không thành công", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
                        widget.func!();
                        Navigator.pop(context);
                        return;
                      }
                    }
                  },
                  child: Text('Xác nhận', style: TextStyle()),
                  style: ElevatedButton.styleFrom(primary: colorBlueBtnDialog, onPrimary: colorWhite, elevation: 3, minimumSize: Size(140, 50)),
                )
              ],
            ));
  }
}
