import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/style.dart';
import 'package:gentelella_flutter/common/toast.dart';
import 'package:gentelella_flutter/widgets/ui/ho_so_ngoai/datahsn/tts.dart';
import 'package:gentelella_flutter/widgets/ui/source_information/common_ource_information/constant.dart';
import '../../../../api.dart';
import '../../../../common/format_date.dart';
import '../setting-data/tts.dart';

class StopprocessingTTS extends StatefulWidget {
  final Function? func;
  final String titleDialog;
  final int? ttsId;
  final int? donhangId;
  final int? doituong;
  final dynamic listId;
  final int? widgetRight; //Hiện thay đổi tiền cọc
  final int? hienDanhSach; //Không cho chờ tiến cử lại
  final List<InformationTTS>? informationTTS;
  final List<Tts>? informationTTSHSN;
  const StopprocessingTTS({
    Key? key,
    required this.titleDialog,
    required this.ttsId,
    required this.donhangId,
    this.doituong,
    this.func,
    this.listId,
    this.widgetRight,
    this.hienDanhSach,
    this.informationTTS,
    this.informationTTSHSN,
  }) : super(key: key);

  @override
  State<StopprocessingTTS> createState() => _StopprocessingTTSState();
}

class _StopprocessingTTSState extends State<StopprocessingTTS> {
  String? er;
  bool check = false;
  TextEditingController mota = TextEditingController();
  var resultTTS;
  String? trangThai;
  Map<int, String> _mapTrangThai = {
    1: 'Tạm dừng xử lý',
  };
  String? nguyenNhan;
  Map<int, String> _mapNguyenNhan = {
    0: 'Cá nhân',
    1: 'Nghiệp đoàn',
    2: 'Khác',
  };
  String? doituong;
  // ignore: unused_field
  Map<int, String> _doituong = {
    0: 'TTS',
    1: 'Đơn hàng',
  };
  bool moneyBack = false;

  String? moneyBackData;
  Map<int, String> _mapMoneyBack = {
    0: 'Không trả lại tiền',
    1: 'Trả lại tiền cọc',
  };
  @override
  void dispose() {
    mota.dispose();
    super.dispose();
  }

  var listStatusTTS = [];

  lisDropdow() {
    if (widget.hienDanhSach != null) _mapTrangThai.remove(14);
  }

  Future<void> processing() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Center(child: const CircularProgressIndicator());
      },
    );
  }

  late int message;
  late String messageEr;
  addDungXuLyTTSHSNList(InformationTTS tts) async {
    var requestBody = tts.toJson();
    if (trangThai == "1") {
      var response1 = await httpPut("/api/nguoidung/put/${tts.id}", requestBody, context);
      var body = jsonDecode(response1['body']);
      if (body.containsKey("1")) {
        message = 1;
        messageEr = body["1"];

        await httpPost(
            API_THONG_BAO_PHONG_BAN_POST + "3&4&5&6&7&8&9&10",
            {
              "title": TIEU_DE_THONG_BAO,
              "message": "Tạm dừng xử lý TTS có mã ${tts.userCode} lúc ${FormatDate.formatDateDayHours(dateTimeNow)}",
            },
            context);
        // var dungXuLy = {
        //   "ttsId": tts.id, //ID TTS nếu đối tượng là TTS
        //   "orderId": widget.donhangId, //ID đơn hàng nếu đối tượng là đơn hàng
        //   "itemType": widget.doituong, //Loại đối tượng: 0:TTS | 1: Đơn hàng
        //   "causeType": nguyenNhan, //Nguyên nhân=0:Cá nhân|1:Nghiệp đoàn|2:Khác
        //   "causeContent": mota.text, //Mô tả nguyên nhân
        //   "approvalType": 0,
        //   "moneyBack": moneyBack,
        // };
        //Thêm mới vào bảng tts-donhangdungxuly
        var dataTtsDonHangDungXuLy = {
          "ttsId": tts.id,
          "itemType": 0,
          "causeType": int.parse(nguyenNhan!),
          "causeContent": mota.text,
          "approvalType": 0,
          /*Loại đối tượng: 0:TTS | 1: Đơn hàng*/
          "moneyBack": moneyBack,
        };
        await httpPost("/api/tts-donhang-dungxuly/post/save", dataTtsDonHangDungXuLy, context);

        // int resultAdd = await postTtsDonhangDungxuly(dataTtsDonHangDungXuLy);
        // if (resultAdd != -1) {
        //   countResultAddTtsDonHangDungXuLy++;
        // }
        //Thêm mới vào nhật kí
        await httpPostDiariStatus(tts.id!, tts.ttsStatusId!, tts.ttsStatusId!, 'Thực tâp sinh đã tạm dừng xử lý', context);
      } else {
        messageEr = body["0"];
        message = 0;
      }
    }
  }

  @override
  void initState() {
    // getStatusTTS();

    lisDropdow();
    super.initState();
  }

  var dateTimeNow = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Row(
              children: [
                Container(width: 40, height: 40, child: Image.asset('images/logoAAM.png'), margin: EdgeInsets.only(right: 10)),
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
        width: MediaQuery.of(context).size.width * 0.5,
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
                              hint: Text('', style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor)),
                              items: _mapTrangThai.entries
                                  .map((item) => DropdownMenuItem<String>(
                                      value: item.key.toString(), child: Text(item.value, style: const TextStyle(fontSize: 14))))
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
                      SizedBox(width: 30),
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
                              hint: Text('', style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor)),
                              items: _mapNguyenNhan.entries
                                  .map((item) => DropdownMenuItem<String>(
                                      value: item.key.toString(), child: Text(item.value, style: const TextStyle(fontSize: 14))))
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
                      SizedBox(width: 30),
                      Expanded(
                          flex: 2,
                          child: Container(
                            height: 40,
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton2(
                                buttonDecoration: BoxDecoration(border: Border.all(width: 0.5, style: BorderStyle.solid)),
                                hint: Text('', style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor)),
                                items: _mapMoneyBack.entries
                                    .map((item) => DropdownMenuItem<String>(
                                        value: item.key.toString(), child: Text(item.value, style: const TextStyle(fontSize: 14))))
                                    .toList(),
                                value: moneyBackData,
                                onChanged: (value) {
                                  setState(() {
                                    moneyBackData = value as String;
                                    (value == "0") ? moneyBack = false : moneyBack = true;
                                  });
                                },
                                buttonHeight: 40,
                                itemHeight: 40,
                              ),
                            ),
                          )),
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
                          child: Column(
                            children: [
                              Expanded(
                                child: TextField(
                                  onChanged: (value) {
                                    if (value.isEmpty) {
                                      setState(() {
                                        check = false;
                                      });
                                    } else {
                                      setState(() {
                                        // er = null;
                                        check = true;
                                      });
                                    }
                                  },
                                  maxLines: 5,
                                  minLines: 5,
                                  controller: mota,
                                  decoration: InputDecoration(
                                    hintText: "Mô tả lý do dừng xử lý",
                                    filled: true,
                                    fillColor: Colors.white,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 30),
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
          onPressed: () => Navigator.pop(context),
          child: Text('Hủy'),
          style: ElevatedButton.styleFrom(primary: colorOrange, onPrimary: colorWhite, elevation: 3, minimumSize: Size(140, 50)),
        ),
        (check == true && trangThai != null || nguyenNhan != null)
            ? ElevatedButton(
                onPressed: () => showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Đồng ý thay đổi ?'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Không'),
                        style: ElevatedButton.styleFrom(primary: colorOrange, onPrimary: colorWhite, minimumSize: Size(80, 40)),
                      ),
                      TextButton(
                        onPressed: () async {
                          processing();
                          for (var idItem in widget.informationTTS!) {
                            idItem.stopProcessing = 1;
                            await addDungXuLyTTSHSNList(idItem);
                          }
                          (message == 1)
                              ? showToast(context: context, msg: messageEr, color: Colors.green, icon: Icon(Icons.supervised_user_circle))
                              : showToast(context: context, msg: messageEr, color: Colors.red, icon: Icon(Icons.supervised_user_circle));
                          await widget.func!(true);
                          Navigator.pop(context);
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: const Text('Có'),
                        style: ElevatedButton.styleFrom(primary: colorBlueBtnDialog, onPrimary: colorWhite, minimumSize: Size(80, 40)),
                      ),
                    ],
                  ),
                ),
                child: Text('Xác nhận', style: TextStyle()),
                style: ElevatedButton.styleFrom(primary: colorBlueBtnDialog, onPrimary: colorWhite, elevation: 3, minimumSize: Size(140, 50)),
              )
            : ElevatedButton(
                onPressed: null,
                child: Text('Xác nhận', style: TextStyle()),
                style: ElevatedButton.styleFrom(primary: colorBlueBtnDialog, onPrimary: colorWhite, elevation: 3, minimumSize: Size(140, 50)),
              )
      ],
    );
  }
}
