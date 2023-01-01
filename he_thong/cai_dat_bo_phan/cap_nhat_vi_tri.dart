import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import '../../../../api.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../forms/nhan_su/setting-data/depart.dart';

// ignore: must_be_immutable
class CapNhatViTri extends StatefulWidget {
  var data;
  CapNhatViTri({Key? key, this.data}) : super(key: key);
  @override
  State<CapNhatViTri> createState() => _CapNhatViTriState();
}

class _CapNhatViTriState extends State<CapNhatViTri> {
  int? selectedTt;
  Map<int, String> trangThai = {
    0: 'Chưa kích hoạt',
    1: 'Đã kích hoạt',
  };
  TextEditingController tenVT = TextEditingController();
  TextEditingController level = TextEditingController();

  Depart? selectedBP1;
  Future<List<Depart>> getPhongBan() async {
    List<Depart> resultPhongBan = [];

    var response1 = await httpGet("/api/phongban/get/page?sort=id,asc", context);
    var content = [];
    if (response1.containsKey("body")) {
      var body = jsonDecode(response1['body']);
      setState(() {
        content = body['content'];
        for (var element in content) {
          if (element['id'] > 2) {
            Depart item = Depart(id: element['id'], departName: element['departName']);
            resultPhongBan.add(item);
          }
        }
      });
    }
    return resultPhongBan;
  }

  void initState() {
    super.initState();
    setState(() {
      if (widget.data != null) {
        tenVT.text = widget.data.name;
        selectedBP1 = Depart(id: widget.data.departId, departName: widget.data.departName);
        level.text = widget.data.level.toString();
        selectedTt = widget.data.status;
      }
    });
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
                'Cập nhật vị trí',
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
        height: 260,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text('Phòng ban:', style: titleWidgetBox),
                ),
                Expanded(
                    flex: 5,
                    child: Container(
                      color: Colors.white,
                      width: MediaQuery.of(context).size.width * 0.20,
                      height: 40,
                      child: DropdownSearch<Depart>(
                        // ignore: deprecated_member_use
                        hint: "Chọn",
                        mode: Mode.MENU,
                        maxHeight: 250,
                        showSearchBox: true,
                        onFind: (String? filter) => getPhongBan(),
                        itemAsString: (Depart? u) => u!.departName,
                        dropdownSearchDecoration: styleDropDown,
                        selectedItem: selectedBP1,
                        onChanged: (value) {
                          setState(() {
                            selectedBP1 = value!;
                            print(selectedBP1?.id);

                            // if (selectedBP != -1) getDNTDChiTiet(selectedBP);
                          });
                        },
                      ),
                    )),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                TextFieldValidated(
                  label: 'Tên vị trí',
                  type: 'None',
                  height: 40,
                  controller: tenVT,
                  onChanged: (value) {},
                  requiredValue: 1,
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                TextFieldValidated(
                  label: 'Cấp độ',
                  type: 'None',
                  height: 40,
                  controller: level,
                  onChanged: (value) {},
                  requiredValue: 1,
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
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
                          'Chọn',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        items: trangThai.entries.map((item) => DropdownMenuItem<int>(value: item.key, child: Text(item.value))).toList(),
                        value: selectedTt,
                        onChanged: (value) {
                          setState(() {
                            selectedTt = value as int;
                            print(selectedTt);
                          });
                        },
                        buttonHeight: 40,
                        itemHeight: 40,
                        dropdownDecoration: BoxDecoration(border: Border.all(color: const Color.fromRGBO(216, 218, 229, 1))),
                        buttonDecoration: BoxDecoration(border: Border.all(width: 0.5, style: BorderStyle.solid)),
                        buttonElevation: 0,
                        buttonPadding: const EdgeInsets.only(left: 14, right: 7),
                        itemPadding: const EdgeInsets.only(left: 14, right: 14),
                        dropdownElevation: 5,
                        focusColor: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: (level.text != "" && selectedTt != null && selectedBP1 != null)
              ? () async {
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
                                      'Xác nhận cập nhật vị trí',
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
                              height: 120,
                              padding: EdgeInsets.only(left: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Vị trí: ${tenVT.text}"),
                                  SizedBox(height: 10),
                                  Text("Cấp độ: ${level.text}"),
                                  SizedBox(height: 10),
                                  Text("Phòng ban: ${selectedBP1?.departName}"),
                                  SizedBox(height: 10),
                                  Text("Trạng thái: ${trangThai[selectedTt]}"),
                                ],
                              ),
                            ),
                            actions: [
                              ElevatedButton(
                                onPressed: () async {
                                  int? levelCheck = int.tryParse(level.text);
                                  if (levelCheck != null) {
                                    if (levelCheck < 10) {
                                      var body = {"name": tenVT.text, "departId": selectedBP1!.id, "level": levelCheck, "status": selectedTt};
                                      print(widget.data.id);
                                      print(body);
                                      var response = await httpPut("/api/vaitro/put/${widget.data.id}", body, context);
                                      print(response);
                                      if (response.containsKey('body')) {
                                        var responseBody = jsonDecode(response['body']);
                                        // var check = int.tryParse(responseBody.toString());
                                        if (responseBody) {
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          // getBoPhan(page);
                                          showToast(
                                            context: context,
                                            msg: "Đã cập nhật  vị trí",
                                            color: mainColorPage,
                                            icon: const Icon(Icons.done),
                                          );
                                        } else
                                          showToast(
                                            context: context,
                                            msg: "Cập nhật lỗi",
                                            color: colorOrange,
                                            icon: const Icon(Icons.warning),
                                          );
                                      } else
                                        showToast(
                                          context: context,
                                          msg: "Cập nhật lỗi",
                                          color: colorOrange,
                                          icon: const Icon(Icons.warning),
                                        );
                                    } else {
                                      showToast(
                                        context: context,
                                        msg: "Cấp độ từ 0 đến 9",
                                        color: colorOrange,
                                        icon: const Icon(Icons.warning),
                                      );
                                    }
                                  } else {
                                    showToast(
                                      context: context,
                                      msg: "Cấp độ không hợp lệ",
                                      color: colorOrange,
                                      icon: const Icon(Icons.warning),
                                    );
                                  }
                                },
                                child: Text('Xác nhận'),
                                style: ElevatedButton.styleFrom(
                                  onPrimary: colorWhite,
                                  primary: mainColorPage,
                                  minimumSize: Size(100, 40),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('Hủy'),
                                style: ElevatedButton.styleFrom(
                                  onPrimary: colorWhite,
                                  primary: colorOrange,
                                  elevation: 3,
                                  minimumSize: Size(100, 40),
                                ),
                              ),
                            ],
                          ));
                }
              : null,
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
