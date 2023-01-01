import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/api.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/register_for_work/service.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/form.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';
import 'package:provider/provider.dart';

import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/market_development/dangkicongtac.dart';
import '../../../../model/model.dart';
import '../../../utils/market_development.dart';

class ModelPheDuyet extends StatefulWidget {
  final List<WorkRegistration>? listWorkRegistrationSelected;
  final Function? func;
  ModelPheDuyet({Key? key, this.listWorkRegistrationSelected, this.func}) : super(key: key);

  @override
  State<ModelPheDuyet> createState() => _ModelPheDuyetState();
}

class _ModelPheDuyetState extends State<ModelPheDuyet> {
  String? selectedDate;
  bool _isTuChoi = false;
  final _myWidgetStateFromDate = GlobalKey<DatePickerBoxVQState1>();
  TextEditingController _contentController = TextEditingController();
  final _myWidgetStateMaNV = GlobalKey<TextFieldValidatedMarketState>();

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
                    child: Text('Phê duyệt đăng kí công tác'),
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
                height: 190,
                width: 600,
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
                      _isTuChoi
                          ? Container(
                              margin: EdgeInsets.only(top: 30),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 5,
                                              child: DatePickerBoxCustomForMarkert(
                                                  key: _myWidgetStateFromDate,
                                                  isTime: false,
                                                  title: "Ngày phê duyệt:",
                                                  isBlocDate: false,
                                                  isNotFeatureDate: true,
                                                  flexLabel: 2,
                                                  flexDatePiker: 4,
                                                  label: Row(
                                                    children: [
                                                      Text(
                                                        'Ngày phê duyệt',
                                                        style: titleWidgetBox,
                                                      ),
                                                    ],
                                                  ),
                                                  dateDisplay: selectedDate,
                                                  selectedDateFunction: (day) {
                                                    setState(() {
                                                      selectedDate = day;
                                                    });
                                                  }),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                    ],
                                  ),

                                  //
                                  Container(
                                    margin: EdgeInsets.only(top: 10),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextFieldValidatedMarket(
                                            key: _myWidgetStateMaNV,
                                            type: "Text",
                                            labe: "Lý do từ chối:",
                                            isReverse: false,
                                            maxLines: 100,
                                            height: 150,
                                            flexLable: 1,
                                            flexTextField: 2,
                                            controller: _contentController,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              margin: EdgeInsets.only(top: 30),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 5,
                                              child: DatePickerBoxCustomForMarkert(
                                                  key: _myWidgetStateFromDate,
                                                  isTime: false,
                                                  title: "Ngày phê duyệt:",
                                                  isBlocDate: false,
                                                  isNotFeatureDate: true,
                                                  flexLabel: 2,
                                                  flexDatePiker: 4,
                                                  label: Row(
                                                    children: [
                                                      Text(
                                                        'Ngày phê duyệt',
                                                        style: titleWidgetBox,
                                                      ),
                                                    ],
                                                  ),
                                                  dateDisplay: selectedDate,
                                                  selectedDateFunction: (day) {
                                                    setState(() {
                                                      selectedDate = day;
                                                    });
                                                  }),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                    ],
                  ),
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
                    _isTuChoi
                        ? Container(
                            width: 120,
                            height: 40,
                            child: OutlinedButton(
                                style: ElevatedButton.styleFrom(
                                  onPrimary: Color(0xffF77919), // Background color
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isTuChoi = false;
                                  });
                                },
                                child: Text('Hủy')),
                          )
                        : Container(),
                    _isTuChoi
                        ? Container(
                            width: 120,
                            height: 40,
                            padding: EdgeInsets.only(left: 20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xffF77919),
                                onPrimary: Colors.white, // Background color
                              ),
                              onPressed: () async {
                                if (_contentController.text.isNotEmpty && selectedDate != null) {
                                  var requestBody = {
                                    "status": 3,
                                    "approver": securityModel.userLoginCurren['id'], //quangthaigiam
                                    "dateApproved": convertTimeStamp(selectedDate!, "00:00"),
                                    "refuseContent": _contentController.text,
                                  };
                                  int countSucces = 0;
                                  for (var item in widget.listWorkRegistrationSelected!) {
                                    bool result = await updateDataLichCongTac(requestBody, item.id, context);
                                    if (result) {
                                      countSucces++;
                                    }
                                  }
                                  if (countSucces == widget.listWorkRegistrationSelected!.length) {
                                    showToast(context: context, msg: "Từ chối thành công !", color: Colors.green, icon: Icon(Icons.abc));
                                  }
                                  Navigator.pop(context);
                                  widget.func!();
                                } else {
                                  showToast(context: context, msg: "Vui lòng chọn đầy đủ thông tin !", color: Colors.red, icon: Icon(Icons.warning));
                                }
                              },
                              child: Text('Xác nhận'),
                            ),
                          )
                        : Container(),
                    !_isTuChoi
                        ? Container(
                            width: 120,
                            height: 40,
                            child: OutlinedButton(
                                style: ElevatedButton.styleFrom(
                                  onPrimary: Color(0xffF77919), // Background color
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isTuChoi = true;
                                  });
                                },
                                child: Text('Từ chối')),
                          )
                        : Container(),
                    !_isTuChoi
                        ? Container(
                            width: 120,
                            height: 40,
                            padding: EdgeInsets.only(left: 20),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xffF77919),
                                onPrimary: Colors.white, // Background color
                              ),
                              onPressed: () async {
                                print(widget.listWorkRegistrationSelected);
                                if (widget.listWorkRegistrationSelected != null) {
                                  if (selectedDate != null) {
                                    var requestBody = {
                                      "status": 1,
                                      "approver": securityModel.userLoginCurren['id'], //quangthaigiam
                                      "dateApproved": convertTimeStamp(selectedDate!, "00:00")
                                    };
                                    int countSucces = 0;
                                    for (var item in widget.listWorkRegistrationSelected!) {
                                      bool result = await updateDataLichCongTac(requestBody, item.id, context);

                                      var response = await httpGet("/api/lichcongtac-nghiepdoan/get/page?filter=onsiteId:${item.id}", context);

                                      var body = jsonDecode(response['body']);

                                      if (body['content'].isNotEmpty) {
                                        for (int i = 0; i < body['content'].length; i++) {
                                          var updateData = {
                                            "orgStatus": 2,
                                          };
                                          var resultUpdate = await httpPut("/api/lichcongtac-nghiepdoan/put/${body['content'][i]['id']}", updateData, context);
                                        }
                                      }

                                      if (result) {
                                        countSucces++;
                                      }
                                    }
                                    if (countSucces == widget.listWorkRegistrationSelected!.length) {
                                      showToast(context: context, msg: "Duyệt thành công !", color: Colors.green, icon: Icon(Icons.abc));
                                      //Thông báo lịch thị sát cho tất cả các phòng ban
                                      for (var element in widget.listWorkRegistrationSelected!) {
                                        try {
                                          //Thông báo cho pttt
                                          await httpPost(
                                              "/api/push/tags/depart_id/5",
                                              {
                                                "title": "Hệ thống thông báo",
                                                "message":
                                                    "${element.user!.userCode}-${element.user!.userName} có lịch công tác từ ${getDateView(element.dateFrom)}-${getDateView(element.dateTo)}"
                                              },
                                              context);
                                        } catch (e) {
                                          print("Ex " + e.toString());
                                        }
                                      }
                                    }
                                    Navigator.pop(context);
                                    widget.func!();
                                  } else {
                                    showToast(context: context, msg: "Vui lòng chọn chọn ngày phê duyệt !", color: Colors.red, icon: Icon(Icons.warning));
                                  }
                                }
                              },
                              child: Text('Duyệt'),
                            ),
                          )
                        : Container()
                  ],
                ),
              ],
            ));
  }
}
