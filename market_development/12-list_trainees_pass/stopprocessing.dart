import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/style.dart';
import 'package:gentelella_flutter/common/toast.dart';
import 'package:gentelella_flutter/model/market_development/user.dart';
import '../../../../api.dart';
import '../../../../common/format_date.dart';
import '../../../forms/market_development/utils/funciton.dart';
import '../../source_information/common_ource_information/constant.dart';
import 'service.dart';
// import '../api.dart';

class Stopprocessing12 extends StatefulWidget {
  final Function? func;
  final String titleDialog;
  final List<User>? listTts;
  final int? orderId;
  const Stopprocessing12({Key? key, required this.titleDialog, this.func, this.listTts, this.orderId}) : super(key: key);

  @override
  State<Stopprocessing12> createState() => _Stopprocessing12State();
}

class _Stopprocessing12State extends State<Stopprocessing12> {
  List<User> listCheckTTSDonHangAllThuocDonHang = [];
  bool check = false;
  TextEditingController mota = TextEditingController();
  var resultTTS;
  // String? trangThai;
  // Map<int, String> _mapTrangThai = {
  //   // 0: ' Chờ tiến cử',
  //   0: ' Dừng xử lý tạm thời',
  // };
  String? nguyenNhan;
  Map<int, String> _mapNguyenNhan = {
    0: ' Cá nhân',
    1: ' Nghiệp đoàn',
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
      var response = await httpPost(Uri.parse('/api/tts-donhang-dungxuly/post/save'), requestBody, context); //Tra ve id
      if (isNumber(jsonDecode(response['body']).toString())) {
        return jsonDecode(response['body']);
      }
    } catch (_) {
      print("Fail!");
    }
    return -1;
  }

  // Future<int> httpPostDiari(userId, statusUserId, statusUserIdAfter, content) async {
  //   try {
  //     var response = await httpPostDiariStatus(userId, statusUserId, statusUserIdAfter, content, context);
  //     var body = jsonDecode(response['body']);
  //     if (isNumber(body.toString())) {
  //       return body;
  //     }
  //   } catch (e) {
  //     print("Lỗi $e");
  //   }
  //   return -1;
  // }

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

  //update api trang thai thực tập sinh đã hoàn thành sau khi đã xuất cảnh
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

  callApi(idSelectedDonHang) async {
    await getListAllTtsTheoDonHang(widget.orderId);
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
  Widget build(BuildContext context) {
    return AlertDialog(
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
                          child: Container(
                            child: Row(children: [
                              Text(
                                'Dừng xử lý tạm thời',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ]),
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
                                  decoration: InputDecoration(
                                    labelText: 'Nhập nội dung',
                                  ),
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
            try {
              if (nguyenNhan == null || mota.text.isEmpty) {
                showToast(context: context, msg: "Nhập đầy đủ thông tin", color: Colors.yellow, icon: Icon(Icons.supervised_user_circle));
                return;
              }
              int countUpdateTTS = 0;
              int countAddNhatKyXuLySuccess = 0;
              int countResultAddTtsDonHangDungXuLy = 0;
              if (widget.listTts != null) {
                for (var tts in widget.listTts!) {
                  var requestBody = {"stopProcessing": 1, "isTts": 1, "orderId": tts.order!.id};
                  bool reuslt = await updateTTSStatus12(requestBody, tts.id);
                  int idAddNhatKyXuLy = await httpPostDiari(tts.id, tts.status!.id!, tts.status!.id!, "Tạm dừng xử lý", context);

                  //Thêm mới vào bảng tts-donhangdungxuly
                  var dataTtsDonHangDungXuLy = {
                    "ttsId": tts.id,
                    "itemType": 0,
                    "causeType": int.parse(nguyenNhan!),
                    "causeContent": mota.text,
                    "approvalType": 0 /*Loại đối tượng: 0:TTS | 1: Đơn hàng*/
                  };
                  int resultAdd = await postTtsDonhangDungxuly(dataTtsDonHangDungXuLy);
                  if (resultAdd != -1) {
                    countResultAddTtsDonHangDungXuLy++;
                  }
                  if (idAddNhatKyXuLy != -1) {
                    countAddNhatKyXuLySuccess++;
                  }
                  if (reuslt) {
                    countUpdateTTS++;
                  }
                }
              }

              if (countResultAddTtsDonHangDungXuLy == widget.listTts!.length && countUpdateTTS == widget.listTts!.length && countAddNhatKyXuLySuccess == widget.listTts!.length) {
                await callApi(widget.orderId);
                if (checkTtsDaHoanThanhHet(listCheckTTSDonHangAllThuocDonHang)) {
                  bool resultUpdateDonHang = false;
                  if (widget.orderId != null) {
                    var requestDonHang = {"orderStatusId": 4};
                    resultUpdateDonHang = await updateTrangThaiDonHang(requestDonHang, widget.orderId!);
                  }

                  if (countUpdateTTS == widget.listTts!.length && resultUpdateDonHang && countAddNhatKyXuLySuccess == widget.listTts!.length) {
                    // widget.func!();
                    showToast(context: context, msg: "Lưu thành công", color: Colors.green, icon: Icon(Icons.supervised_user_circle));
                    for (int i = 0; i < widget.listTts!.length; i++) {
                      try {
                        await httpPost(
                            API_THONG_BAO_PHONG_BAN_POST + "3&4&5&6&7&8&9&10",
                            {
                              "title": TIEU_DE_THONG_BAO,
                              "message": "Tạm dừng xử lý TTS có mã ${widget.listTts![i].userCode} lúc ${getDateViewDayAndHour(FormatDate.formatDateInsertDBHHss(DateTime.now()))}",
                            },
                            context);
                      } catch (e) {
                        print(e);
                      }
                    }

                    widget.func!();
                    print("DSDSĐ");
                    Navigator.pop(context);
                  } else {
                    showToast(context: context, msg: "Cập nhật không thành công", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
                    widget.func!();
                    Navigator.pop(context);
                  }
                }

                showToast(context: context, msg: "Lưu thành công", color: Colors.green, icon: Icon(Icons.supervised_user_circle));
              } else {
                showToast(context: context, msg: "Cập nhật không thành công", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
                widget.func!();
                Navigator.pop(context);
              }
            } catch (e) {
              print(e);
            }
          },
          child: Text('Xác nhận', style: TextStyle()),
          style: ElevatedButton.styleFrom(primary: colorBlueBtnDialog, onPrimary: colorWhite, elevation: 3, minimumSize: Size(140, 50)),
        )
      ],
    );
  }
}
