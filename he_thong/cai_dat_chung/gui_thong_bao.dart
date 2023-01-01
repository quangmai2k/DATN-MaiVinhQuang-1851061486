import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';

import '../../../../api.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';

class FormGuiThongBao extends StatefulWidget {
  const FormGuiThongBao({Key? key}) : super(key: key);

  @override
  State<FormGuiThongBao> createState() => _FormGuiThongBaoState();
}

class _FormGuiThongBaoState extends State<FormGuiThongBao> {
  var items = [
    {'name': 'Phòng ban', 'value': '0'},
    {'name': 'Theo mã người dùng', 'value': '1'},
    {'name': 'Tất cả nhân viên', 'value': '2'},
    {'name': 'Tất cả thực tập sinh, cộng tác viên', 'value': '3'}
  ];
  dynamic selectedItem = '0';
  @override
  void initState() {
    getDepartFuture = getDepart();
    super.initState();
  }

  var listDepart;
  var listCheckbox = [];
  late Future<dynamic> getDepartFuture;
  getDepart() async {
    var response = await httpGet("/api/phongban/get/page", context);
    if (response.containsKey("body")) {
      listDepart = jsonDecode(response["body"])['content'];
      listCheckbox = [];
      for (var row in listDepart) {
        listCheckbox
            .add({'id': row['id'], 'name': row['departName'], 'value': false});
      }
      setState(() {});
      return listDepart;
    } else
      throw Exception("Error load data");
  }

  TextEditingController title = TextEditingController();
  TextEditingController message = TextEditingController();
  TextEditingController link = TextEditingController();
  TextEditingController userCode = TextEditingController();

  var fileImage;
  String titleLog = '';
  pushNotification() async {
    var data = {"title": "${title.text}", "message": "${message.text}"};
    if (link.text.isNotEmpty) data['url'] = link.text;
    String query = '';
    for (int i = 0; i < listCheckbox.length; i++) {
      if (listCheckbox[i]['value'] == true) {
        query += listCheckbox[i]['id'].toString();
        query += '&';
      }
    }
    if (query != '') query = query.substring(0, query.length - 1);
    if (fileImage == null) {
      if (selectedItem == '0') {
        var response =
            await httpPost('/api/push/tags/depart_id/$query', data, context);
        if (response['body'] == 'true') {
          titleLog = 'Gửi thông báo thành công';
          title.text = '';
          message.text = '';
          link.text = '';
          userCode.text = '';
        } else {
          titleLog = 'Gửi thông báo thất bại';
        }
      } else if (selectedItem == '1') {
        var response = await httpPost(
            '/api/push/tags/user_code/${userCode.text}', data, context);
        if (response['body'] == 'true') {
          titleLog = 'Gửi thông báo thành công';
          title.text = '';
          message.text = '';
          link.text = '';
          userCode.text = '';
        } else {
          titleLog = 'Gửi thông báo thất bại';
        }
      } else {
        var response = await httpPost(
            '/api/push/${selectedItem == '2' ? 'tags' : 'guest'}/user_type/${selectedItem == '2' ? 'aam' : 'guest'}',
            data,
            context);
        if (response['body'] == 'true') {
          titleLog = 'Gửi thông báo thành công';
          title.text = '';
          message.text = '';
          link.text = '';
          userCode.text = '';
        } else {
          titleLog = 'Gửi thông báo thất bại';
        }
      }
    } else {
      await uploadFile(fileImage, context: context).then((image) async {
        fileImage = null;
        data['bigImage'] = image;
        if (selectedItem == '0') {
          var response =
              await httpPost('/api/push/tags/depart_id/$query', data, context);
          if (response['body'] == 'true') {
            titleLog = 'Gửi thông báo thành công';
            title.text = '';
            message.text = '';
            link.text = '';
            userCode.text = '';
          } else {
            titleLog = 'Gửi thông báo thất bại';
          }
        } else if (selectedItem == '1') {
          var response = await httpPost(
              '/api/push/tags/user_code/${userCode.text}', data, context);
          if (response['body'] == 'true') {
            titleLog = 'Gửi thông báo thành công';
            title.text = '';
            message.text = '';
            link.text = '';
            userCode.text = '';
          } else {
            titleLog = 'Gửi thông báo thất bại';
          }
        } else {
          var response = await httpPost(
              '/api/push/tags/user_type/${selectedItem == '2' ? 'aam' : 'guest'}',
              data,
              context);
          if (response['body'] == 'true') {
            titleLog = 'Gửi thông báo thành công';
            title.text = '';
            message.text = '';
            link.text = '';
            userCode.text = '';
          } else {
            titleLog = 'Gửi thông báo thất bại';
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: getDepartFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            color: backgroundPage,
            padding: EdgeInsets.fromLTRB(25, 25, 25, 0),
            child: SingleChildScrollView(
                controller: ScrollController(),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorWhite,
                    borderRadius: borderRadiusContainer,
                    boxShadow: [boxShadowContainer],
                    border: borderAllContainerBox,
                  ),
                  padding: paddingBoxContainer,
                  child: Column(children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nhập thông tin ',
                          style: titleBox,
                        ),
                        Icon(
                          Icons.more_horiz,
                          color: Color(0xff9aa5ce),
                          size: 14,
                        ),
                      ],
                    ),
                    //Đường line
                    Container(
                      margin: marginTopBottomHorizontalLine,
                      child: Divider(
                        thickness: 1,
                        color: ColorHorizontalLine,
                      ),
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      children: [
                        TextFieldValidated(
                          type: 'None',
                          label: 'Tiêu đề',
                          height: 40,
                          controller: title,
                          flexLable: 2,
                          flexTextField: 5,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Nội dung thông báo',
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(left: 5),
                                      child: Text("*",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontSize: 16,
                                          )),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Container(
                            child: TextField(
                              minLines: 3,
                              maxLines: 3,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                              ),
                              controller: message,
                              onSubmitted: (value) {},
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            'Hình ảnh',
                            style: titleWidgetBox,
                          ),
                        ),
                        Expanded(
                            flex: 5,
                            child: TextButton(
                              onPressed: () async {
                                var file = await FilePicker.platform.pickFiles(
                                  type: FileType.custom,
                                  allowedExtensions: ['jpeg', 'png', 'jpg'],
                                  withReadStream: true, //
                                );
                                fileImage = file;
                                setState(() {});
                              },
                              child: Row(children: [
                                Icon(
                                  Icons.upload_file,
                                  color: Colors.blue[400],
                                ),
                                Text(
                                    '${fileImage == null ? 'Tải ảnh lên' : fileImage!.files.first.name}')
                              ]),
                            ))
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      children: [
                        TextFieldValidated(
                          type: 'None',
                          label: 'Link',
                          height: 40,
                          controller: link,
                          flexLable: 2,
                          flexTextField: 5,
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    DropdownBtnSearch(
                      isAll: false,
                      label: 'Đối tượng gửi thông báo',
                      listItems: items,
                      isSearch: false,
                      selectedValue: selectedItem,
                      setSelected: (selected) {
                        selectedItem = selected;
                        setState(() {});
                      },
                    ),

                    selectedItem == '0'
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 50,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Phòng ban nhận thông báo:',
                                      style: titleWidgetBox,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 50,
                              ),
                              Wrap(
                                runSpacing: 25.0,
                                spacing: 5.0,
                                children: [
                                  for (var row in listCheckbox)
                                    Container(
                                      width: 265,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Checkbox(
                                              checkColor: Colors.white,
                                              value: row['value'],
                                              onChanged: (value) {
                                                row['value'] = value;
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            flex: 4,
                                            child: Text(
                                              row['name'],
                                              style: TextStyle(
                                                color: Color(0xff333333),
                                                fontSize: 16,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                ],
                              )
                            ],
                          )
                        : selectedItem == '1'
                            ? Column(
                                children: [
                                  SizedBox(
                                    height: 25,
                                  ),
                                  Row(
                                    children: [
                                      TextFieldValidated(
                                        type: 'Text',
                                        label: 'UserCode',
                                        height: 40,
                                        controller: userCode,
                                        flexLable: 2,
                                        flexTextField: 5,
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            : Container(),
                    SizedBox(
                      height: 50,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                                horizontal: 10.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                              primary: Theme.of(context).iconTheme.color,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .caption
                                  ?.copyWith(
                                      fontSize: 10.0, letterSpacing: 2.0),
                            ),
                            onPressed: () async {
                              bool checkValidate = true;
                              bool checkUser = true;
                              for (var row in listCheckbox) {
                                if (row['value'] == true) {
                                  checkValidate = true;
                                  break;
                                } else {
                                  checkValidate = false;
                                }
                              }
                              if (message.text.isEmpty) {
                                checkValidate = false;
                                checkUser = false;
                              }
                              if (selectedItem == '1') if (userCode
                                  .text.isEmpty) checkUser = false;
                              if (selectedItem == '0') {
                                if (selectedItem == '0' &&
                                    checkValidate == true) {
                                  await showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        ConfirmUpdate(
                                            title: "Xác nhận gửi thông báo",
                                            content:
                                                "Bạn có chắc chắn muốn gửi thông báo này đi không",
                                            function: () async {
                                              await pushNotification();
                                              Navigator.pop(context);
                                            }),
                                  );
                                } else {
                                  showToast(
                                    context: context,
                                    msg:
                                        'Yêu cầu nhập đủ dữ liệu trước khi gửi thông báo',
                                    color: Colors.red,
                                    icon: const Icon(Icons.warning),
                                  );
                                }
                              } else if (selectedItem == '1') {
                                if (selectedItem == '1' && checkUser == true) {
                                  await showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        ConfirmUpdate(
                                            title: "Xác nhận gửi thông báo",
                                            content:
                                                "Bạn có chắc chắn muốn gửi thông báo này đi không",
                                            function: () async {
                                              await pushNotification();
                                              Navigator.pop(context);
                                            }),
                                  );
                                } else {
                                  showToast(
                                    context: context,
                                    msg:
                                        'Yêu cầu nhập đủ dữ liệu trước khi gửi thông báo',
                                    color: Colors.red,
                                    icon: const Icon(Icons.warning),
                                  );
                                }
                              } else {
                                await showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      ConfirmUpdate(
                                          title: "Xác nhận gửi thông báo",
                                          content:
                                              "Bạn có chắc chắn muốn gửi thông báo này đi không",
                                          function: () async {
                                            await pushNotification();
                                            Navigator.pop(context);
                                          }),
                                );
                              }
                              if (titleLog != '')
                                showToast(
                                  context: context,
                                  msg: titleLog,
                                  color: titleLog == 'Gửi thông báo thành công'
                                      ? Color.fromARGB(136, 72, 238, 67)
                                      : Colors.red,
                                  icon: titleLog == 'Gửi thông báo thành công'
                                      ? Icon(Icons.done)
                                      : Icon(Icons.warning),
                                );
                              setState(() {});
                            },
                            child: Row(
                              children: [
                                Text('Gửi thông báo', style: textButton),
                              ],
                            ),
                          ),
                        )
                      ],
                    )
                  ]),
                )),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return Center(child: const CircularProgressIndicator());
      },
    );
  }
}
