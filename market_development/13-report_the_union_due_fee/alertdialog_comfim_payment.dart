import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/api.dart';
import 'package:gentelella_flutter/widgets/ui/he_thong/quan-ly-ho-so/quan-ly-ho-so.dart';
import 'package:gentelella_flutter/widgets/ui/ho_so_noi/chot_danh_sach_tts_tien_cu/chot_danh_sach_tts.dart';
import 'package:intl/intl.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../utils/market_development.dart';

class XacNhanThanhToan extends StatefulWidget {
  List<dynamic> idCheck;
  Function? callBack;
  XacNhanThanhToan({Key? key, required this.idCheck, this.callBack}) : super(key: key);

  @override
  State<XacNhanThanhToan> createState() => _XacNhanThanhToanState();
}

class _XacNhanThanhToanState extends State<XacNhanThanhToan> with TickerProviderStateMixin {
  var object;
  Map<int, String> tranhThai = {0: 'Chưa', 1: 'Thanh toán đủ', 2: 'Thanh toán 1 phần'};
  int selectedTT = 0;
  String requestFileEdited = "";
  String? paymentDate;
  TextEditingController noteTT = TextEditingController();

  @override
  void initState() {
    super.initState();
    object = widget.idCheck.first;
    selectedTT = object['paymentStatus'];
    requestFileEdited = object['requestFileEdited'] ?? "";
    noteTT.text = object['requestNoteEdited'] ?? "";
    paymentDate = (object['paymentDate'] != null) ? DateFormat('dd-MM-yyyy').format(DateTime.parse(object['paymentDate'])) : null;
  }

  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        SizedBox(
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                child: Image.asset('assets/images/logoAAM.png'),
                margin: EdgeInsets.only(right: 10),
              ),
              Text(
                'Xác nhận thanh toán',
                style: titleAlertDialog,
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => {Navigator.pop(context)},
          icon: Icon(
            Icons.close,
          ),
        ),
      ]),
      //content
      content: Container(
        width: 650,
        height: 320,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //đường line
            Container(
              margin: marginTopBottomHorizontalLine,
              child: Divider(
                thickness: 1,
                color: ColorHorizontalLine,
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text('Trạng thái:', style: titleWidgetBox),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width * 0.20,
                      // width: MediaQuery.of(context).size.width * 0.15,
                      height: 40,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton2(
                          dropdownMaxHeight: 250,
                          hint: Text(
                            '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          items: tranhThai.entries.map((item) => DropdownMenuItem<int>(value: item.key, child: Text(item.value))).toList(),
                          value: selectedTT,
                          onChanged: (value) {
                            setState(() {
                              selectedTT = value as int;
                            });
                          },
                          buttonHeight: 40,
                          itemHeight: 40,
                          dropdownDecoration: BoxDecoration(border: Border.all(color: const Color.fromRGBO(216, 218, 229, 1))),
                          buttonDecoration: BoxDecoration(border: Border.all(width: 0.5, style: BorderStyle.solid)),
                          buttonElevation: 0,
                          buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                          itemPadding: const EdgeInsets.only(left: 14, right: 14),
                          dropdownElevation: 5,
                          focusColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            (selectedTT != 0)
                ? Container(
                    margin: EdgeInsets.only(bottom: 30),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Text(
                                  "Tải file sau chỉnh sửa",
                                  style: titleWidgetBox,
                                ),
                                Container(
                                  margin: EdgeInsets.only(left: 5),
                                  child: Text("*",
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 16,
                                      )),
                                ),
                              ],
                            )),
                        Expanded(
                            flex: 5,
                            child: TextButton(
                              onPressed: () async {
                                var file = await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['pdf', 'docx', 'jpeg', 'png', 'jpg', 'xlsx'],
                                  withReadStream: true, //
                                );
                                if (file != null) {
                                  String fileName = await uploadFile(file, context: context) ?? "";
                                  setState(() {
                                    requestFileEdited = fileName;
                                  });
                                }
                              },
                              child: requestFileEdited != "" ? Text(requestFileEdited) : Icon(Icons.upload_file),
                            ))
                      ],
                    ),
                  )
                : Container(
                    margin: EdgeInsets.only(bottom: 30),
                  ),
            (selectedTT != 0)
                ? Container(
                    margin: EdgeInsets.only(bottom: 30),
                    child: DatePickerBoxCustomForMarkert(
                        isTime: false,
                        title: "Ngày thanh toán",
                        isBlocDate: false,
                        isNotFeatureDate: true,
                        flexLabel: 2,
                        flexDatePiker: 5,
                        label: Row(
                          children: [
                            Text(
                              'Ngày thanh toán:',
                              style: titleWidgetBox,
                            ),
                            Text(' *',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 213, 6, 6),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                        dateDisplay: paymentDate,
                        selectedDateFunction: (day) {
                          setState(() {
                            paymentDate = day;
                            print("paymentDate:$paymentDate");
                          });
                        }),
                  )
                : Container(
                    margin: EdgeInsets.only(bottom: 30),
                  ),
            (selectedTT != 0)
                ? TextFieldValidatedForm(
                    type: 'None',
                    height: 40,
                    controller: noteTT,
                    label: 'Mô tả:',
                    flexLable: 2,
                  )
                : Container(
                    margin: EdgeInsets.only(bottom: 30),
                  ),
          ],
        ),
      ),
      //actions
      actions: [
        Container(
          margin: EdgeInsets.only(right: 15),
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 10.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              backgroundColor: mainColorPage,
              primary: Theme.of(context).iconTheme.color,
              textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
            ),
            onPressed: () async {
              if (selectedTT == 0) {
                var requestBody = {
                  "times": object['times'],
                  "paymentStatus": 0,
                  "paymentDate": null,
                  "requestFileEdited": null,
                  "requestNoteEdited": null
                };
                var respnse = await httpPut("/api/nghiepdoan-denghi/put/${object['id']}", requestBody, context);
                print(respnse);
                widget.callBack!([0, null, null, null]);
                Navigator.pop(context);
              } else {
                if (requestFileEdited != "" && paymentDate != null) {
                  var requestBody = {
                    "times": object['times'],
                    "paymentStatus": selectedTT,
                    "paymentDate": "${paymentDate!.substring(6)}${paymentDate!.substring(2, 6)}${paymentDate!.substring(0, 2)}",
                    "requestFileEdited": requestFileEdited,
                    "requestNoteEdited": (noteTT.text != "") ? noteTT.text : null,
                  };
                  await httpPut("/api/nghiepdoan-denghi/put/${object['id']}", requestBody, context);
                  String date = "${paymentDate!.substring(6)}${paymentDate!.substring(2, 6)}${paymentDate!.substring(0, 2)}";
                  var responseNDNCT = await httpGet("/api/nghiepdoan-denghi-nhom-chitiet/get/page?filter=requestId:${object['id']}", context);
                  if (responseNDNCT.containsKey("body")) {
                    var body = jsonDecode(responseNDNCT['body']);
                    var listNhomDeNghi = body['content'];
                    for (var item in listNhomDeNghi) {
                      item['invoiced'] = 1;
                      await httpPut("/api/nghiepdoan-denghi-nhom-chitiet/put/${item['id']}", item, context);
                    }
                  }
                  widget.callBack!([selectedTT, date, requestFileEdited, noteTT.text]);
                  Navigator.pop(context);
                } else {
                  showToast(
                    context: context,
                    msg: "Cần nhập đủ thông tin để lưu",
                    color: colorOrange,
                    icon: const Icon(Icons.warning),
                  );
                }
              }
            },
            child: Text('Xác nhận', style: textButton),
          ),
        ),
        Container(
          margin: EdgeInsets.only(right: 25),
          child: TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 25.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              backgroundColor: Color.fromRGBO(245, 117, 29, 1),
              primary: Theme.of(context).iconTheme.color,
              textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
            ),
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: textButton),
          ),
        ),
      ],
    );
  }
}
