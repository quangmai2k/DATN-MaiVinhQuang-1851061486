import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/style.dart';
import 'package:gentelella_flutter/common/toast.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';

import '../../../../api.dart';
import '../../../forms/market_development/utils/funciton.dart';

class Confirm extends StatefulWidget {
  final Function? funcXN;
  final String titleDialog;
  final List<dynamic> listId;
  final dynamic donhangId;

  const Confirm({Key? key, required this.titleDialog, this.funcXN, required this.listId, this.donhangId}) : super(key: key);

  @override
  State<Confirm> createState() => _ConfirmState();
}

class _ConfirmState extends State<Confirm> {
  var time1;
  var time2;
  // DateTime? dateXC;
  // DateTime? dateHH;
  // Future<DateTime> _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2000),
  //     lastDate: DateTime(2025),
  //   );
  //   if (picked != null) {
  //     return picked;
  //   }
  //   return DateTime.now();
  // }

  upXacNhanXC(var data) async {
    if (data["orderId"] != null) {
      var requestBody = {"orderStatusId": 3};
      await httpPut("/api/donhang/put/${data["orderId"]}", requestBody, context);
    }
    if (data['id'] != null) {
      var requestBody = {
        "isTts": 1,
        "ttsStatusId": 11,
        "orderId": data["orderId"],
        "profileDocumentsCompleted": data["profileDocumentsCompleted"],
        "departureDate": dateReverse(time1!),
        "contractExpireDate": dateReverse(time2!),
        "resetPasswordToken": data["resetPasswordToken"],
        "removeAccountEnable": data["removeAccountEnable"]
      };
      print(requestBody);
      await httpPut("/api/nguoidung/put/${data['id']}", requestBody, context);
      //
      var nhatky = {"ttsId": data['id'], "ttsStatusBeforeId": data['ttsStatusId'], "ttsStatusAfterId": 11, "content": "Xác nhận xuất cảnh"};
      await httpPost("/api/tts-nhatky/post/save", nhatky, context);
      //
      await httpPost(
          "/api/push/tags/user_code/${data['careUser']}",
          {
            "title": "Hệ thống thông báo",
            "message": " ${data['userCode']}(${data['fullName']}) đã xuất cảnh lúc ${getDateView(data['departureDate'])}"
          },
          context);
      await httpPost(
          "/api/push/tags/depart_id/5&6&8",
          {
            "title": "Hệ thống thông báo",
            "message": " ${data['userCode']}(${data['fullName']}) đã xuất cảnh lúc ${getDateView(data['departureDate'])}"
          },
          context);
    }
  }

  @override
  void initState() {
    // getStatusTTS();
    super.initState();
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
                Container(width: 40, height: 40, child: Image.asset('images/logoAAM.png'), margin: EdgeInsets.only(right: 10)),
                Text(widget.titleDialog, style: titleAlertDialog),
              ],
            ),
          ),
          IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.close)),
        ],
      ),
      content: Container(
        width: 550,
        height: 250,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(padding: const EdgeInsets.all(5.0), child: Divider(thickness: 1)),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: DatePickerBox1(
                  requestDayBefore: time2,
                  isTime: false,
                  label: Text('Ngày xuất cảnh: ', style: titleWidgetBox),
                  dateDisplay: time1,
                  selectedDateFunction: (day) {
                    setState(() {
                      time1 = day;
                    });
                  }),
            ),
            SizedBox(height: 20),
            DatePickerBox1(
                requestDayAfter: time1,
                isTime: false,
                label: Text('Ngày hết hạn hợp đồng: ', style: titleWidgetBox),
                dateDisplay: time1,
                selectedDateFunction: (day) {
                  setState(() {
                    time2 = day;
                    print(time2);
                  });
                }),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Hủy'),
          style: ElevatedButton.styleFrom(primary: colorOrange, onPrimary: colorWhite, elevation: 3, minimumSize: Size(140, 50)),
        ),
        (time1 != null && time2 != null)
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
                          for (var idItem in widget.listId) {
                            await upXacNhanXC(idItem);
                          }

                          showToast(context: context, msg: "Cập nhật thành công!", color: Colors.green, icon: Icon(Icons.supervised_user_circle));
                          await widget.funcXN!(true);
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
