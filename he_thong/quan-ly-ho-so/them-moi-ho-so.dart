import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/he_thong/quan-ly-ho-so/quan-ly-ho-so.dart';

import '../../../../api.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';

class ThemMoiHoSo extends StatefulWidget {
  HoSo hoSo;
  ThemMoiHoSo({Key? key, required this.hoSo}) : super(key: key);

  @override
  State<ThemMoiHoSo> createState() => _ThemMoiHoSoState();
}

class _ThemMoiHoSoState extends State<ThemMoiHoSo> with TickerProviderStateMixin {
  Map<int, String> requiredFind = {0: 'Không', 1: 'Có'};
  Map<int, String> fileGroupFind = {0: 'Chính', 1: 'Khác'};
  Map<int, String> fileGenericFind = {0: 'Cá nhân', 1: 'Xuất cảnh', 2: 'Nhân sự'};
  Map<int, String> contentTypeFind = {0: 'File', 1: 'Văn bản', 2: 'Ngày', 3: 'Ảnh'};
  addHoSo(HoSo hoSo) async {
    bool request = false;
    var requestBody = {
      "name": hoSo.name,
      "required": hoSo.requiredHoso,
      "fileGroup": hoSo.fileGroup,
      "fileGeneric": hoSo.fileGeneric,
      "contentType": hoSo.contentType,
      "description": (hoSo.description != "") ? hoSo.description : null
    };
    print("requestBody:$requestBody");
    var response = await httpPost("/api/tts-hoso/post/save", requestBody, context);
    if (response.containsKey("body")) {
      var response1 = jsonDecode(response["body"]);
      int? id = int.tryParse(response1.toString());
      if (id != null)
        request = true;
      else
        request = false;
    }
    return request;
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
                'Thêm mới hồ sơ',
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
        width: 400,
        height: 470,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            TextFieldValidatedForm(
              type: 'None',
              height: 40,
              // controller: tieuDe,
              label: 'Tên hồ sơ:',
              flexLable: 2,
              onChange: (value) {
                setState(() {
                  widget.hoSo.name = value;
                });
              },
            ),
            Container(
              margin: EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text('Loại hồ sơ:', style: titleWidgetBox),
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
                          items: fileGenericFind.entries.map((item) => DropdownMenuItem<int>(value: item.key, child: Text(item.value))).toList(),
                          value: widget.hoSo.fileGeneric,
                          onChanged: (value) {
                            setState(() {
                              widget.hoSo.fileGeneric = value as int;
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
            Container(
              margin: EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text('Bắt buộc:', style: titleWidgetBox),
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
                          items: requiredFind.entries.map((item) => DropdownMenuItem<int>(value: item.key, child: Text(item.value))).toList(),
                          value: widget.hoSo.requiredHoso,
                          onChanged: (value) {
                            setState(() {
                              widget.hoSo.requiredHoso = value as int;
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
            Container(
              margin: EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text('Nhóm:', style: titleWidgetBox),
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
                          items: fileGroupFind.entries.map((item) => DropdownMenuItem<int>(value: item.key, child: Text(item.value))).toList(),
                          value: widget.hoSo.fileGroup,
                          onChanged: (value) {
                            setState(() {
                              widget.hoSo.fileGroup = value as int;
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
            Container(
              margin: EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text('Kiểu:', style: titleWidgetBox),
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
                          items: contentTypeFind.entries.map((item) => DropdownMenuItem<int>(value: item.key, child: Text(item.value))).toList(),
                          value: widget.hoSo.contentType,
                          onChanged: (value) {
                            setState(() {
                              widget.hoSo.contentType = value as int;
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
            TextFieldValidatedForm(
              type: 'None',
              height: 40,
              // controller: tieuDe,
              label: 'Mô tả:',
              flexLable: 2,
              onChange: (value) {
                setState(() {
                  widget.hoSo.description = value;
                });
              },
            ),
          ],
        ),
      ),
      //actions
      actions: [
        Container(
          margin: EdgeInsets.only(right: 10),
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
        Container(
          margin: EdgeInsets.only(right: 20),
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
              if (widget.hoSo.name != null &&
                  widget.hoSo.requiredHoso != null &&
                  widget.hoSo.fileGroup != null &&
                  widget.hoSo.fileGeneric != null &&
                  widget.hoSo.contentType != null) {
                var response = await addHoSo(widget.hoSo);
                if (response == true) {
                  Navigator.pop(context);
                  showToast(
                    context: context,
                    msg: "Thêm mới thành công",
                    color: mainColorPage,
                    icon: const Icon(Icons.done),
                  );
                } else {
                  showToast(
                    context: context,
                    msg: "Thêm mới không thành công",
                    color: colorOrange,
                    icon: const Icon(Icons.warning),
                  );
                }
              } else {
                showToast(
                  context: context,
                  msg: "phải nhập đủ thông tin",
                  color: colorOrange,
                  icon: const Icon(Icons.warning),
                );
              }
            },
            child: Text('Xác nhận', style: textButton),
          ),
        ),
      ],
    );
  }
}
