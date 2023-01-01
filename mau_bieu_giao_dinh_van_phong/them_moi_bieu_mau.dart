import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/api.dart';
import 'package:gentelella_flutter/common/style.dart';
import 'package:gentelella_flutter/common/toast.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';

class ThemMoiBM extends StatefulWidget {
  ThemMoiBM({Key? key}) : super(key: key);
  @override
  State<ThemMoiBM> createState() => _ThemMoiBMState();
}

class _ThemMoiBMState extends State<ThemMoiBM> {
  String titleBMN = "";
  String fileNameBMN = "";
  String desBMN = "";
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
        width: 500,
        height: 160,
        child: Column(
          children: [
            Row(
              children: [
                TextFieldValidated(
                  label: 'Tên mẫu biểu:',
                  type: 'None',
                  height: 40,
                  requiredValue: 1,
                  onChanged: (value) {
                    titleBMN = value;
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
                            fileNameBMN = fileName;
                          });
                        }
                      },
                      child: fileNameBMN != "" ? Text(fileNameBMN) : Icon(Icons.upload_file),
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
                  onChanged: (value) {
                    desBMN = value;
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
            if (titleBMN == "" || fileNameBMN == "") {
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
                                  'Xác nhận thêm mới mẫu biểu',
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
                              Text("Thêm mới :$titleBMN"),
                            ],
                          ),
                        ),
                        actions: [
                          ElevatedButton(
                            onPressed: () async {
                              await httpPost(
                                  "/api/bieumau/post/save",
                                  {
                                    "title": titleBMN,
                                    "description": desBMN,
                                    "url": fileNameBMN,
                                    "status": 1,
                                  },
                                  context);
                              showToast(
                                context: context,
                                msg: "Thêm mới mẫu biểu thành công",
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
