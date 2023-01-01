import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';

import 'package:intl/intl.dart';

import '../../../../../api.dart';

import '../../../../../common/style.dart';
import '../../../../../common/toast.dart';
import '../../../../../model/market_development/QuaTrinhLamViec.dart';

import '../../../../../model/market_development/phongban.dart';
import '../../../../../model/market_development/quydinh.dart';
import '../../../../forms/market_development/utils/funciton.dart';
import '../../../../utils/market_development.dart';

class ModalContentViolationsAdd extends StatefulWidget {
  final int? idTTS;
  final int? idNoiDungViPham;
  final int? orderId;
  final Function? func;
  ModalContentViolationsAdd({Key? key, this.idTTS, this.idNoiDungViPham, this.func, this.orderId}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ModalContentViolationsAddState();
  }
}

class _ModalContentViolationsAddState extends State<ModalContentViolationsAdd> {
  bool isValidateForm = false;
  String? violateDate;
  bool _isShowBtnUpdate = false;
  bool _setLoading = false;
  int? selectedStatus;

  int? violateId;
  TextEditingController issuedContent = TextEditingController();
  TextEditingController handleResult = TextEditingController();
  String? issuedDate;
  String? handleDate;

  bool _isErrorViolateId = false;
  bool _isErrorIssuedContent = false;
  bool _isErrorHandleResult = false;
  bool _isErrorIssuedDate = false;
  bool _isErrorHandleDate = false;

  int countErrorWhenSubmit(int? idNoiDungViPham) {
    int count = 0;
    // if (violateId == null) {
    //   setState(() {
    //     _isErrorViolateId = true;
    //   });
    //   count++;
    // }

    if (issuedContent == null || issuedContent.text.toString().isEmpty) {
      setState(() {
        _isErrorIssuedContent = true;
      });
      count++;
    }
    if (idNoiDungViPham != null) {
      if (handleResult == null || handleResult.text.toString().isEmpty) {
        setState(() {
          _isErrorHandleResult = true;
        });
        count++;
      }
    }

    if (issuedDate == null) {
      setState(() {
        _isErrorIssuedDate = true;
      });
      count++;
    }
    if (idNoiDungViPham != null) {
      if (handleDate == null) {
        setState(() {
          _isErrorHandleDate = true;
        });
        count++;
      }
    }

    return count;
  }

  List<QuyDinh> listQuyDinh = [];
  Future<List<QuyDinh>> getDanhSachQuyDinh() async {
    var response;

    response = await httpGet("/api/quydinh/get/page", context);

    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      content = body['content'];
      setState(() {
        listQuyDinh = content.map((e) {
          return QuyDinh.fromJson(e);
        }).toList();
      });
    }
    return content.map((e) {
      return QuyDinh.fromJson(e);
    }).toList();
  }

  Future<List<PhongBans>> getDanhSachPhongBan() async {
    var response;

    response = await httpGet("/api/phongban/get/page", context);

    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      content = body['content'];
    }
    return content.map((e) {
      return PhongBans.fromJson(e);
    }).toList();
  }

  QuaTrinhLamViec1 quaTrinhLamViec = new QuaTrinhLamViec1();
  getChiTietNoiDungViPham(int id) async {
    var response = await httpGet("/api/tts-quatrinhlamviec/get/$id", context);
    var body = jsonDecode(response['body']);

    if (response.containsKey("body")) {
      setState(() {
        quaTrinhLamViec = QuaTrinhLamViec1.fromJson(body);
        if (quaTrinhLamViec != null) {
          issuedContent.text = quaTrinhLamViec.issuedContent != null ? quaTrinhLamViec.issuedContent.toString() : "";
          handleResult.text = quaTrinhLamViec.handleResult != null ? quaTrinhLamViec.handleResult.toString() : "";
          violateId = quaTrinhLamViec.violateId;
          issuedDate = quaTrinhLamViec.issuedDate != null ? dateReverse(quaTrinhLamViec.issuedDate) : null;
          handleDate = quaTrinhLamViec.handleDate != null ? dateReverse(quaTrinhLamViec.handleDate) : null;
          //isLoading = true;
        }
      });
    }
  }

  Future<int> saveDataNoiDungViPham(dynamic requestBody) async {
    try {
      var response = await httpPost(Uri.parse('/api/tts-quatrinhlamviec/post/save'), requestBody, context); //Tra ve id
      var idAdd = jsonDecode(response['body']).toString();
      if (isNumber(idAdd)) {
        return int.parse(idAdd);
      }
    } catch (_) {
      print("Fail!");
    }
    return -1;
  }

  Future<bool> updateDataNoiDungViPham(dynamic requestBody, int id) async {
    try {
      var response = await httpPut(Uri.parse('/api/tts-quatrinhlamviec/put/${id}'), requestBody, context); //Tra ve id
      if (jsonDecode(response['body']) == true) {
        return true;
      } else {
        return false;
      }
    } catch (_) {
      print("Fail!");
    }
    return false;
  }

  String? getDateInsertDb(String date) {
    try {
      var inputFormat = DateFormat('dd-MM-yyyy');
      var inputDate = inputFormat.parse(date); // <-- dd/MM 24H format
      var outputFormat = DateFormat('yyyy-MM-dd');
      var outputDate = outputFormat.format(inputDate);
      return outputDate;
    } catch (e) {}
    return null;
  }

  String? er;
  handleSaveDataNoiDungViPham() async {
    var requestBody = {
      "ttsId": widget.idTTS,
      "orderId": widget.orderId,
      "violateId": violateId,
      "issuedContent": issuedContent.text.isNotEmpty ? issuedContent.text : null, //Nội dung vi phạm phát sinh tại nghiệp đoàn
      "handleResult": null, //Kết quả xử lý vi phạm
      "issuedDate": getDateInsertDb(issuedDate!),
      "handleDate": null, //Mặc định khi thêm mới
    };
    print(requestBody);
    int result = await saveDataNoiDungViPham(requestBody);
    if (result != -1) {
      showToast(context: context, msg: "Thêm mới thành công!", color: Colors.green, icon: Icon(Icons.supervised_user_circle));
    } else {
      showToast(context: context, msg: "Thất bại!", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
    }
    widget.func!();
    Navigator.pop(context);
  }

  handleUpdateDataNoiDungViPham() async {
    var requestBody = {
      "ttsId": widget.idTTS,
      "orderId": widget.orderId,
      "violateId": violateId,
      "issuedContent": issuedContent.text.isNotEmpty ? issuedContent.text : null, //Nội dung vi phạm phát sinh tại nghiệp đoàn
      "handleResult": handleResult.text.isNotEmpty ? handleResult.text : null, //Kết quả xử lý vi phạm
      "issuedDate": getDateInsertDb(issuedDate!),
      "handleDate": getDateInsertDb(handleDate!), //Mặc định khi thêm mới
    };
    print(requestBody);
    bool result = await updateDataNoiDungViPham(requestBody, widget.idNoiDungViPham!);
    if (result) {
      showToast(context: context, msg: "Cập nhật thành công!", color: Colors.green, icon: Icon(Icons.supervised_user_circle));
    } else {
      showToast(context: context, msg: "Thất bại!", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
    }
    widget.func!();
    Navigator.pop(context);
  }

  Map mapStatus = {
    0: "Chưa",
    1: "Có",
  };

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    await getDanhSachQuyDinh();
    if (widget.idNoiDungViPham != null) {
      await getChiTietNoiDungViPham(widget.idNoiDungViPham!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Image.asset(
            "assets/images/logoAAM.png",
            width: 30,
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Text(widget.idNoiDungViPham != null ? 'Cập nhật' : "Thêm mới"),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close)),
            ),
          )
        ],
      ),
      content: Container(
        height: 600,
        width: 800,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                child: Divider(
                  thickness: 1,
                  color: Colors.grey,
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: Container(
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Text('Danh sách quy định(Nếu có)', style: titleBox),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Container(
                                      color: Colors.white,
                                      // width: MediaQuery.of(context).size.width * 0.15,
                                      height: 40,
                                      child: DropdownSearch<QuyDinh>(
                                        mode: Mode.MENU,
                                        showSearchBox: true,
                                        itemAsString: (QuyDinh? u) => u!.ruleName,
                                        dropdownSearchDecoration: styleDropDown,
                                        selectedItem: violateId != null ? listQuyDinh.where((element) => element.id.toString() == violateId.toString()).first : null,
                                        items: listQuyDinh,
                                        //onFind: (String? filter) => getDanhSachQuyDinh(),
                                        onChanged: (value) {
                                          setState(() {
                                            violateId = value!.id;

                                            print(violateId);
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 30),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: DatePickerBoxCustomForMarkert(
                                      // key: _myWidgetStateFromDate,
                                      label: Row(
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              'Ngày phát sinh ',
                                              style: titleWidgetBox,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(
                                              margin: EdgeInsets.only(left: 5),
                                              child: Text(
                                                "*",
                                                style: TextStyle(color: Colors.red, fontSize: 16),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      isTime: false,
                                      title: "Ngày phát sinh",
                                      isBlocDate: false,
                                      isNotFeatureDate: true,
                                      flexLabel: 2,
                                      flexDatePiker: 5,
                                      dateDisplay: issuedDate,
                                      selectedDateFunction: (day) {
                                        // dateFrom = day;
                                        setState(() {
                                          issuedDate = day;
                                        });
                                      }),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    widget.idNoiDungViPham != null
                        ? Container(
                            margin: EdgeInsets.only(top: 30),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: DatePickerBoxCustomForMarkert(
                                            // key: _myWidgetStateFromDate,
                                            label: Row(
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Text(
                                                    'Ngày xử lý',
                                                    style: titleWidgetBox,
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(
                                                    margin: EdgeInsets.only(left: 5),
                                                    child: Text(
                                                      "*",
                                                      style: TextStyle(color: Colors.red, fontSize: 16),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            isTime: false,
                                            title: "Ngày xử lý",
                                            isBlocDate: false,
                                            isNotFeatureDate: true,
                                            flexLabel: 2,
                                            flexDatePiker: 5,
                                            dateDisplay: handleDate,
                                            selectedDateFunction: (day) {
                                              // dateFrom = day;
                                              setState(() {
                                                handleDate = day;
                                              });
                                            }),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                    Container(
                      margin: EdgeInsets.only(top: 30),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Nội dung",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "*",
                                    style: TextStyle(color: Colors.red, fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              child: TextFormField(
                                decoration: InputDecoration(
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(0)),
                                    ),
                                    errorText: er),
                                minLines: 6, // any number you need (It works as the rows for the textarea)
                                maxLines: 6,
                                keyboardType: TextInputType.multiline,
                                controller: issuedContent,
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    setState(() {
                                      er = null;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    widget.idNoiDungViPham != null
                        ? Container(
                            margin: EdgeInsets.only(top: 30),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          "Kết quả",
                                          style: titleWidgetBox,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "*",
                                          style: TextStyle(color: Colors.red, fontSize: 16),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    child: TextFormField(
                                      decoration: InputDecoration(
                                          isDense: true,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(0)),
                                          ),
                                          errorText: er),
                                      minLines: 6, // any number you need (It works as the rows for the textarea)
                                      maxLines: 6,
                                      keyboardType: TextInputType.multiline,
                                      controller: handleResult,
                                      onChanged: (value) {
                                        if (value.isNotEmpty) {
                                          setState(() {
                                            er = null;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          // textColor: Color(0xFF6200EE),
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Hủy',
            style: TextStyle(),
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.transparent,
            onPrimary: Colors.white,
            // shadowColor: Colors.greenAccent,
            elevation: 3,
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(32.0)),
            minimumSize: Size(140, 50), //////// HERE
          ),
        ),
        ElevatedButton(
          // textColor: Color(0xFF6200EE),
          onPressed: () async {
            if (countErrorWhenSubmit(widget.idNoiDungViPham) > 0) {
              showToast(context: context, msg: "Vui lòng nhập đầy đủ thông tin!", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
              return;
            }
            if (widget.idNoiDungViPham != null) {
              await handleUpdateDataNoiDungViPham();
            } else {
              await handleSaveDataNoiDungViPham();
            }
          },
          child: Text(
            'Lưu',
            style: TextStyle(),
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.orange[400],
            onPrimary: Colors.white,
            // shadowColor: Colors.greenAccent,
            elevation: 3,
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(32.0)),
            minimumSize: Size(140, 50), //////// HERE
          ),
        ),
      ],
    );
  }
}
