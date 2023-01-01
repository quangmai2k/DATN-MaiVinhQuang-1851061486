import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/api.dart';
import 'package:gentelella_flutter/common/style.dart';
import 'package:gentelella_flutter/common/toast.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import 'mau_bieu.dart';

class SuaBM extends StatefulWidget {
  BieuMau bieuMau;
  Function? callback;
  SuaBM({Key? key, required this.bieuMau, this.callback}) : super(key: key);
  @override
  State<SuaBM> createState() => _SuaBMState();
}

class _SuaBMState extends State<SuaBM> {
  @override
  void initState() {
    super.initState();
  }

  @override
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
                'Thêm mẫu biểu',
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
      content: Container(
        padding: EdgeInsets.only(right: 10, left: 10),
        width: 550,
        height: 160,
        child: Column(
          children: [
            Row(
              children: [
                TextFieldValidated(
                  label: 'Cập nhật mẫu biểu:',
                  type: 'None',
                  height: 40,
                  requiredValue: 1,
                  controller: TextEditingController(text: widget.bieuMau.title),
                  onChanged: (value) {
                    widget.bieuMau.title = value;
                  },
                ),
              ],
            ),
            SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Text(
                          "Tải file",
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
                            widget.bieuMau.url = fileName;
                          });
                        }
                      },
                      child: widget.bieuMau.url != "" ? Text("${widget.bieuMau.url}") : Icon(Icons.upload_file),
                    ))
              ],
            ),
            SizedBox(height: 25),
            Row(
              children: [
                TextFieldValidated(
                  label: 'Mô tả :',
                  type: 'None',
                  height: 40,
                  controller: TextEditingController(text: widget.bieuMau.description),
                  onChanged: (value) {
                    widget.bieuMau.description = value;
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () async {
            if (widget.bieuMau.title == "" || widget.bieuMau.url == "") {
              showToast(
                context: context,
                msg: "Cần nhập đủ thông tin để lưu",
                color: colorOrange,
                icon: const Icon(Icons.warning),
              );
            } else {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
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
                                  'Xác nhận sửa mẫu biểu',
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
                        content: Container(
                          height: 100,
                          padding: EdgeInsets.only(left: 10),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Sửa biểu mẫu :${widget.bieuMau.title}"),
                            ],
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () async {
                              await httpPut(
                                  "/api/bieumau/put/${widget.bieuMau.id}",
                                  {
                                    "title": widget.bieuMau.title,
                                    "description": widget.bieuMau.description,
                                    "url": widget.bieuMau.url,
                                    "status": 1,
                                  },
                                  context);
                              widget.bieuMau.ngaySua = DateTime.now().toLocal().toString();
                              widget.callback!(widget.bieuMau);
                              showToast(
                                context: context,
                                msg: "Sửa mẫu biểu thành công",
                                color: Color.fromARGB(136, 72, 238, 67),
                                icon: const Icon(Icons.done),
                              );
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                            child: Text('Xác nhận'),
                            style: ElevatedButton.styleFrom(
                              primary: mainColorPage,
                              onPrimary: colorWhite,
                              minimumSize: Size(100, 40),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Hủy'),
                            style: ElevatedButton.styleFrom(
                              primary: colorOrange,
                              onPrimary: colorWhite,
                              elevation: 3,
                              minimumSize: Size(100, 40),
                            ),
                          ),
                        ],
                      ));
            }
          },
          child: Text(
            'Lưu',
            style: TextStyle(),
          ),
          style: ElevatedButton.styleFrom(
            primary: mainColorPage,
            onPrimary: colorWhite,
            elevation: 3,
            minimumSize: Size(100, 40),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Hủy'),
          style: ElevatedButton.styleFrom(
            primary: colorOrange,
            onPrimary: colorWhite,
            elevation: 3,
            minimumSize: Size(100, 40),
          ),
        ),
      ],
    );
  }
}
