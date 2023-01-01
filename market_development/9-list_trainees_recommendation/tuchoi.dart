import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/api.dart';
import 'package:gentelella_flutter/common/style.dart';
import 'package:gentelella_flutter/common/toast.dart';
import 'package:provider/provider.dart';

import '../../../../common/format_date.dart';
import '../../../../model/market_development/order.dart';
import '../../../../model/market_development/tss_don_hang.dart';
import '../../../../model/model.dart';
import '../../../forms/market_development/utils/funciton.dart';

class DungXuLyDeXuatTienCu extends StatefulWidget {
  final Function? func;
  final String titleDialog;
  final int? ttsId;
  final int? donhangId;
  final int? doituong;
  final dynamic listId;
  final List<TTSDonHang>? ListTTSDonHang;
  final Order? order;
  DungXuLyDeXuatTienCu({Key? key, required this.titleDialog, required this.ttsId, required this.donhangId, this.doituong, this.func, this.listId, this.ListTTSDonHang, this.order})
      : super(key: key);

  @override
  State<DungXuLyDeXuatTienCu> createState() => _DungXuLyDeXuatTienCuState();
}

class _DungXuLyDeXuatTienCuState extends State<DungXuLyDeXuatTienCu> {
  bool check = false;
  TextEditingController mota = TextEditingController();

  Future<bool> putDonHangTtsTienCu(int id, requestBody, context) async {
    try {
      var response = await httpPut('/api/donhang-tts-tiencu/put/$id', requestBody, context); //Tra ve id
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

  Future<List<dynamic>> getTTSDonHang(int idTts, int orderId, context) async {
    var response =
        await httpGet("/api/donhang-tts-tiencu/get/page?filter=ttsId:$idTts AND ptttApproval:0 AND (nguoidung.stopProcessing:0 or nguoidung.stopProcessing is not null)", context);
    print('/api/donhang-tts-tiencu/get/page?filter=ttsId:$idTts AND ptttApproval:0 and ');
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      content = body['content'];
    }
    return content;
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
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<NavigationModel, SecurityModel, CaiDatThoiGian>(
        builder: (context, navigationModel, securityModel, number, child) => AlertDialog(
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
                height: 150,
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
                              Expanded(flex: 2, child: Text('Lý do', style: titleWidgetBox)),
                              Expanded(
                                flex: 6,
                                child: Container(
                                  width: 300,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 0.7, color: Color.fromARGB(255, 87, 85, 85)),
                                    color: Colors.transparent,
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
                              SizedBox(
                                width: 30,
                              )
                            ],
                          ),
                        ),
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
                    try {
                      if (mota.text.isEmpty) {
                        showToast(context: context, msg: "Nhập đầy đủ thông tin", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
                        return;
                      }
                      int countUpdateSucces = 0;
                      for (var item in widget.ListTTSDonHang!) {
                        var requestBody = {"ptttApproval": 2, "ptttNote": mota.text};
                        bool result = await putDonHangTtsTienCu(item.id, requestBody, context);
                        if (result) {
                          countUpdateSucces++;
                        }
                      }
                      if (countUpdateSucces == widget.ListTTSDonHang!.length) {
                        showToast(context: context, msg: "Lưu thành công", color: Colors.green, icon: Icon(Icons.supervised_user_circle));
                        try {
                          if (widget.ListTTSDonHang!.isNotEmpty) {
                            for (var item in widget.ListTTSDonHang!) {
                              List<dynamic> listTtsDonHangTienCu = await getTTSDonHang(item.user!.id, widget.donhangId!, context);
                              if (listTtsDonHangTienCu.isEmpty) {
                                //Update trạng thái thực tập sinh là chờ tiến cử lại nếu bị từ chối hết
                                var requestUpdateNguoiDung = {"ttsStatusId": 14, "isTts": 1};
                                await putNguoiDung(item.user!.id, requestUpdateNguoiDung, context);
                                await httpPostDiariStatus(item.user!.id, item.user!.ttsStatusId, 14, mota.text, context);
                              }
                            }
                          }
                        } catch (e) {
                          print("Lỗi trong quá trình duyệt lại thực tập sinh từ chối hết" + e.toString());
                        }
                        for (var item in widget.ListTTSDonHang!) {
                          //Khi mà từ chối thành công 1 tts thì bắn thông báo
                          //Thông báo cho thông tin nguồn
                          try {
                            await httpPost(
                                "/api/push/tags/depart_id/3",
                                {
                                  "title": "Hệ thống thông báo",
                                  "message":
                                      "Bộ phận PTTT Nhật bản từ chối TTS mã ${item.user!.userCode}-${item.user!.fullName} tiến cử vào đơn hàng ${widget.order!.orderCode}-${widget.order!.orderName} lúc ${getDateView(DateTime.now().toString())}."
                                },
                                context);
                          } catch (e) {
                            print("Lỗi trong quá trình bắn thông báo" + e.toString());
                          }
                          //Thông báo cho thông tin nguồn end
                        }
                        widget.func!();
                        Navigator.pop(context);
                      }
                    } catch (e) {
                      print("Ngoại lệ cả quá trình" + e.toString());
                    }
                  },
                  child: Text('Xác nhận', style: TextStyle()),
                  style: ElevatedButton.styleFrom(primary: colorBlueBtnDialog, onPrimary: colorWhite, elevation: 3, minimumSize: Size(140, 50)),
                )
              ],
            ));
  }
}
