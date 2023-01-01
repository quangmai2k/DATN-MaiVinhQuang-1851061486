import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/style.dart';
import 'package:gentelella_flutter/model/market_development/nghiepdoan-thanhtoan.dart';

import 'package:gentelella_flutter/widgets/forms/market_development/utils/form.dart';

import 'package:provider/provider.dart';

import '../../../../../api.dart';
import '../../../../../common/toast.dart';

import '../../../../common/format_date.dart';
import '../../../../common/widgets_form.dart';

import '../../../../model/model.dart';

import '../../../utils/market_development.dart';

class ModelXacNhan extends StatefulWidget {
  final List<NghiepDoanThanhToan>? listUnionObjectResultSelected;
  final Function? func;
  ModelXacNhan({Key? key, this.listUnionObjectResultSelected, this.func}) : super(key: key);

  @override
  State<ModelXacNhan> createState() => _ModelXacNhanState();
}

class _ModelXacNhanState extends State<ModelXacNhan> {
  dynamic file;
  List<dynamic> listStatusUnion = [
    {"key": 0, "value": " Chưa thanh toán"},
    {"key": 1, "value": " Đã thanh toán"},
    {"key": 2, "value": " Thanh toán 1 phần"},
  ];
  bool isHidden = false;
  String? selectedDate;
  @override
  void initState() {
    super.initState();
    setState(() {
      isHidden = false;
    });
  }

  TextEditingController _titleController = TextEditingController(text: "AAM - THÔNG BÁO NGHIỆP ĐOÀN ĐẾN HẠN THU PHÍ");
  TextEditingController _contentController = TextEditingController();

  String? fileName;
  // bool _setLoading = false;
  // bool _validate = false;

  int? selectedStatus;

  double? heightErrorTieuDe;
  String? errorTieuDe;

  double? heightErrorNoiDung;
  String? errorNoiDung;

  // final _myWidgetTieuDe = GlobalKey<TextFieldValidatedMarketState>();
  // final _myWidgetNoiDung = GlobalKey<TextFieldValidatedMarketState>();

  // double _phanTram = 0.0;
  // String _ketQua = "Đang gửi mail.Vui lòng đợi chút!";
  // bool _hienQuaTrinh = false;
  @override
  void dispose() {
    super.dispose();

    _titleController.dispose();
    _contentController.dispose();
  }

  Future selectedFile() async {
    var image = await FilePicker.platform.pickFiles(
      withReadStream: true,
    );

    setState(() {
      file = image;
      if (image!.files.length > 0) {
        fileName = image.files.first.name;
        print(fileName);
      }
    });
  }

  sendEmail(dynamic requestBody) async {
    try {
      print("OOOOO");

      var response = await httpPost(Uri.parse('/api/utils/post/mail'), requestBody, context);

      return true;
    } catch (e) {
      print("Fail! $e");
    }
    return false;
  }

  int countErrorWhenSubmit() {
    int count = 0;
    if (_contentController.text.isEmpty) {
      count++;
    }
    if (_titleController.text.isEmpty) {
      count++;
    }
    return count;
  }

  Future<bool> putNghiepDoanThanhToan(int id, dynamic requestBody) async {
    try {
      var response = await httpPut(Uri.parse('/api/nghiepdoan-thanhtoan/put/$id'), requestBody, context); //Tra ve id

      return jsonDecode(response['body']);
    } catch (_) {
      print("Fail!");
    }
    return false;
  }

  tinhHanThuPhi(String dateTime, int chuKyThuPhi) {
    if (dateTime.isNotEmpty) {
      DateTime time = DateTime.parse(dateTime);
      DateTime timeAdd;
      timeAdd = time.add(new Duration(days: chuKyThuPhi));
      // var string = FormatDate.formatDateddMMyy(timeAdd);
      // print(FormatDate.formatDateInsertDB(timeAdd));
      return FormatDate.formatDateInsertDB(timeAdd);
    }
    return null;
  }

  //
  @override
  Widget build(BuildContext context) {
    return Consumer2<NavigationModel, SecurityModel>(
        builder: (context, navigationModel, securityModel, child) => AlertDialog(
              title: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            child: Image.asset('assets/images/logoAAM.png'),
                            margin: EdgeInsets.only(right: 10),
                          ),
                          Expanded(
                              flex: 4,
                              child: Text(
                                'Xác nhận thanh toán',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                              )),
                          Expanded(
                            flex: 0,
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: Icon(Icons.close),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              content: Container(
                  width: MediaQuery.of(context).size.width * 0.6,
                  height: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Container(
                            margin: EdgeInsets.only(bottom: 30),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Trạng thái",
                                    style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                  flex: 2,
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    height: 40,
                                    child: DropdownSearch<dynamic>(
                                      mode: Mode.MENU,
                                      maxHeight: 150,
                                      showSearchBox: false,
                                      dropdownSearchDecoration: styleDropDown,
                                      itemAsString: (dynamic u) => u['value'],
                                      selectedItem: selectedStatus != null ? listStatusUnion.where((element) => element['key'] == selectedStatus).toList().first : null,
                                      items: listStatusUnion,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedStatus = value['key'];
                                          if (selectedStatus == 0) {
                                            isHidden = false;
                                            selectedDate = "";
                                          } else {
                                            isHidden = true;
                                            selectedDate = null;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            )),
                        Container(
                            margin: EdgeInsets.only(bottom: 30),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Upload file chỉnh sửa",
                                    style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                  flex: 2,
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.upload_file),
                                        tooltip: 'Upload file',
                                        onPressed: () async {
                                          selectedFile();
                                          print("123");
                                        },
                                      ),
                                      file != null ? Expanded(flex: 1, child: Text(fileName!)) : Expanded(flex: 1, child: Text("")),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                        Container(
                          margin: EdgeInsets.only(bottom: 30),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFieldValidatedMarket(
                                  flexLable: 2,
                                  flexTextField: 5,
                                  hint: "Mô tả lý do chỉnh sửa của file",
                                  height: 100,
                                  type: "Text",
                                  labe: "Mô tả lý do chỉnh sửa của file",
                                  isReverse: false,
                                  controller: _contentController,
                                ),
                              ),
                            ],
                          ),
                        ),
                        isHidden
                            ? Container(
                                margin: EdgeInsets.only(bottom: 30),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: Container(
                                        child: DatePickerBoxCustomForMarkert(
                                            isTime: false,
                                            isBlocDate: false,
                                            isNotFeatureDate: true,
                                            label: Text(
                                              "Ngày",
                                              style: titleWidgetBox,
                                            ),
                                            dateDisplay: selectedDate,
                                            selectedDateFunction: (day) {
                                              setState(() {
                                                selectedDate = day;
                                              });
                                            }),
                                      ),
                                    ),
                                  ],
                                ))
                            : Container(),
                      ],
                    ),
                  )),
              actions: <Widget>[
                ElevatedButton(
                  // textColor: Color(0xFF6200EE),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Hủy',
                    style: TextStyle(),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.black,
                    // shadowColor: Colors.greenAccent,
                    elevation: 3,
                    // shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(32.0)),
                    minimumSize: Size(140, 50), //////// HERE
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    int count = 0;
                    if (selectedStatus == null) {
                      count++;
                    }
                    if (selectedDate == null) {
                      count++;
                    }
                    var resultFile = await uploadFile(file, context: context);
                    if (resultFile != "null") {
                      int countUpdate = 0;
                      if (count == 0) {
                        if (widget.listUnionObjectResultSelected != null) {
                          for (var item in widget.listUnionObjectResultSelected!) {
                            var requestBody = {
                              "paidDate": selectedDate != null ? dateReverse(selectedDate) : null,
                              "status": selectedStatus ?? 0,
                              "payRequestFileEdited": resultFile,
                              "payEditedNote": _contentController.text,
                            };
                            if (selectedStatus == 0) {
                              requestBody = {"paidDate": null, "status": selectedStatus};
                            }

                            bool result = await putNghiepDoanThanhToan(item.id!, requestBody);
                            if (result) {
                              countUpdate++;
                            }
                          }
                        }
                      } else {
                        showToast(context: context, msg: "Nhập đẩy đủ thông tin !", color: Colors.yellow, icon: Icon(Icons.warning));
                        return;
                      }
                      if (countUpdate == widget.listUnionObjectResultSelected!.length) {
                        widget.func!();
                        Navigator.pop(context);
                        showToast(context: context, msg: "Cập nhật thành công !", color: Colors.green, icon: Icon(Icons.done));
                      } else {
                        showToast(context: context, msg: "Cập nhật không thành công !", color: Colors.red, icon: Icon(Icons.warning));
                      }
                    } else {
                      showToast(context: context, msg: "Không upload được file!", color: Colors.red, icon: Icon(Icons.warning));
                    }
                  },
                  child: Text(
                    'Xác nhận',
                    style: TextStyle(),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromRGBO(245, 117, 29, 1),
                    onPrimary: Colors.white,
                    // shadowColor: Colors.greenAccent,
                    elevation: 3,
                    // shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(32.0)),
                    minimumSize: Size(140, 50), //////// HERE
                  ),
                ),
              ],
            ));
  }
}
