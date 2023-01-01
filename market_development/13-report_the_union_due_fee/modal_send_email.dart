import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/style.dart';

import 'package:gentelella_flutter/widgets/forms/market_development/utils/form.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:provider/provider.dart';

import '../../../../../api.dart';
import '../../../../../common/toast.dart';

import '../../../../common/format_date.dart';
import '../../../../model/market_development/nghiepdoan_tts_xuat_canh.dart';
import '../../../../model/market_development/union.dart';
import '../../../../model/market_development/user.dart';
import '../../../../model/model.dart';
import '../7-order_management/xuat_file.dart';

class ModelGuiMailHanThuPhi extends StatefulWidget {
  final List<NghiepDoanThucTapSinhXuatCanh>? listUnionObjectResultSelected;
  final Map<int, List<User>>? mapNhomNghiepDoan;
  ModelGuiMailHanThuPhi({Key? key, this.listUnionObjectResultSelected, this.mapNhomNghiepDoan}) : super(key: key);

  @override
  State<ModelGuiMailHanThuPhi> createState() => _ModelGuiMailHanThuPhiState();
}

class _ModelGuiMailHanThuPhiState extends State<ModelGuiMailHanThuPhi> {
  List<String> listEmail = [];
  @override
  void initState() {
    super.initState();
    setState(() {
      try {
        for (var item in widget.listUnionObjectResultSelected!) {
          listEmail.add(item.email!);
        }
      } catch (e) {
        print(e);
      }
    });
  }

  TextEditingController _titleController = TextEditingController(text: "AAM - THÔNG BÁO NGHIỆP ĐOÀN ĐẾN HẠN THU PHÍ");
  TextEditingController _contentController = TextEditingController();

  String? fileName;
  // bool _setLoading = false;
  // bool _validate = false;
  dynamic file;

  double? heightErrorTieuDe;
  String? errorTieuDe;

  double? heightErrorNoiDung;
  String? errorNoiDung;

  // final _myWidgetTieuDe = GlobalKey<TextFieldValidatedMarketState>();
  // final _myWidgetNoiDung = GlobalKey<TextFieldValidatedMarketState>();

  double _phanTram = 0.0;
  String _ketQua = "Đang gửi mail.Vui lòng đợi chút!";
  bool _hienQuaTrinh = false;
  @override
  void dispose() {
    super.dispose();

    _titleController.dispose();
    _contentController.dispose();
  }

  sendEmail(dynamic requestBody) async {
    try {
      var response = await httpPost(Uri.parse('/api/utils/post/mail'), requestBody, context);
      //Tra ve id
      print("11111");

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

  Future<int> saveDataNghiepDoanThanhToan(dynamic requestBody) async {
    try {
      var response = await httpPost(Uri.parse('/api/nghiepdoan-thanhtoan/post/save'), requestBody, context); //Tra ve id

      return jsonDecode(response['body']);
    } catch (_) {
      print("Fail!");
    }
    return -1;
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

  TextEditingController _emailController = TextEditingController();
  //

  getDueDate(firstDueDate, nextDueDate) {
    if (firstDueDate != null && nextDueDate != null) {
      return nextDueDate;
    }
    if (nextDueDate == null) {
      return firstDueDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NavigationModel, SecurityModel>(
        builder: (context, navigationModel, securityModel, child) => AlertDialog(
              title: Row(
                children: [
                  Image.asset(
                    "assets/images/logoAAM.png",
                    width: 30,
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(
                      'Xác nhận thu phí quản lý',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
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
                height: 100,
                width: 600,
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
                      margin: EdgeInsets.only(top: 30),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Text(
                              "Bạn có chắc chắc muốn xác nhận ?",
                              style: TextStyle(
                                fontSize: 17,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 100,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              actions: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  child: Divider(
                    thickness: 1,
                    color: Colors.grey,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 120,
                      height: 40,
                      child: OutlinedButton(
                          style: ElevatedButton.styleFrom(
                            onPrimary: Color(0xff42a5f5), // Background color
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Hủy')),
                    ),
                    Container(
                      width: 120,
                      height: 40,
                      padding: EdgeInsets.only(left: 20),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xff42a5f5),
                          onPrimary: Colors.white, // Background color
                        ),
                        onPressed: () async {
                          if (widget.listUnionObjectResultSelected!.isNotEmpty) {
                            onLoading(context);
                            setState(() {
                              _hienQuaTrinh = true;
                            });
                            int countMailSuccess = 0;

                            List<dynamic> listOrgIdAndFile = await exportFile1(widget.listUnionObjectResultSelected!, context, widget.mapNhomNghiepDoan!);
                            for (int i = 0; i < listOrgIdAndFile.length; i++) {
                              var requestBody = {
                                "orgId": listOrgIdAndFile[i]['orgId'],
                                "manageFeeId": listOrgIdAndFile[i]['manageFeeId'],
                                "dueDate": getDueDate(listOrgIdAndFile[i]['firstDueDate'], listOrgIdAndFile[i]['nextDueDate']),
                                "paidDate": null,
                                "payRequestFile": listOrgIdAndFile[i]['payRequestFile'],
                                "requestSender": securityModel.userLoginCurren['id'],
                                "requestDate": FormatDate.formatDateInsertDBHHss(DateTime.now()),
                                "status": 0
                              };
                              var ketQuaThemMoi = await saveDataNghiepDoanThanhToan(requestBody);
                              if (ketQuaThemMoi != -1) {
                                countMailSuccess++;
                              }
                            }
                            if (countMailSuccess == listOrgIdAndFile.length) {
                              showToast(context: context, msg: "Đã gửi xác nhận thu phí quản lý !", color: Color.fromARGB(255, 157, 238, 160), icon: Icon(Icons.done));
                              //Gửi thông báo cho nghiệp đoàn
                              for (int i = 0; i < listOrgIdAndFile.length; i++) {
                                try {
                                  //Thông báo cho pttt

                                  await httpPost(
                                      "/api/push/tags/depart_id/5&3",
                                      {
                                        "title": "Hệ thống thông báo",
                                        "message":
                                            "Đã gửi thông báo hạn thu phí đến nghiệp đoàn ${listOrgIdAndFile[i]['orgCode']}-${listOrgIdAndFile[i]['orgName']} .Hạn thu phí ${getDateView(FormatDate.formatDateInsertDBHHss(DateTime.now()))}."
                                      },
                                      context);
                                } catch (e) {
                                  print("Ex " + e.toString());
                                }
                              }

                              Navigator.of(context).pop(true);
                              Navigator.of(context).pop(true);
                            }
                          } else {
                            showToast(context: context, msg: "Vui lòng chọn ít nhất một bản ghi", color: Color.fromARGB(255, 223, 248, 174), icon: Icon(Icons.warning));
                          }
                        },
                        child: Text('Xác nhận'),
                      ),
                    )
                  ],
                ),
              ],
            ));
  }
}
