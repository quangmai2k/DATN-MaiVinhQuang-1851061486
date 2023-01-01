import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/format_date.dart';
import 'package:gentelella_flutter/common/style.dart';

import 'package:gentelella_flutter/model/market_development/order.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';
import 'package:gentelella_flutter/widgets/ui/market_development/7-order_management/detail/modal_order_split.dart';
import 'package:provider/provider.dart';

import '../../../../../api.dart';
import '../../../../../common/dynamic_table.dart';

import '../../../../../model/market_development/user.dart';
import '../../../../../model/model.dart';
import 'modal_detail_ndvp.dart';

class ListTTS extends StatefulWidget {
  final Order? order;
  ListTTS({Key? key, this.order}) : super(key: key);

  @override
  State<ListTTS> createState() => _ListTTSState();
}

class _ListTTSState extends State<ListTTS> {
  var body = {};
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  //==============Table start
  List<bool> _selected = [];
  List<bool> _selectedTrue = [];
  List<User> listTTSDonHang = [];

  List<User> listUserInOrder = [];

  late Future<List<User>> futureListTTSDonHang;
  Future<List<User>> getListTTS(page, {order, orgName, companyName, jobName, statusName, dateFrom, dateTo}) async {
    print("thaida step1");
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }

    var response = await httpGet("/api/nguoidung/get/page?page=$page&size=$rowPerPage&filter=orderId:${widget.order!.id}", context);
    print("thaida step3 $response");
    var body = jsonDecode(response['body']);

    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        currentPage = page + 1;
        content = body['content'];
        rowCount = body["totalElements"];
        totalElements = body["totalElements"];
        lastRow = totalElements;
        listUserInOrder = content.map((e) {
          return User.fromJson(e);
        }).toList();
        _selected = List<bool>.generate(content.length, (int index) => false);
      });
    }
    return content.map((e) {
      return User.fromJson(e);
    }).toList();
  }

  int numberTTSXuatCanh = 0;
  countTTSXuatCanh() async {
    var response = await httpGet("/api/nguoidung/get/count?filter=ttsTrangthai.id:11 AND orderId:${widget.order!.id}", context);

    if (response.containsKey("body")) {
      setState(() {
        numberTTSXuatCanh = jsonDecode(response['body']);
      });
    }
  }

  hienThiTamDungXuly(User? user) {
    try {
      if (user != null) {
        if (user.stopProcessing == 1) {
          return "/Tạm dừng xử lý";
        }
      }
    } catch (e) {}
    return "";
  }

  @override
  void initState() {
    super.initState();
    futureListTTSDonHang = getListTTS(page - 1);
    countTTSXuatCanh();
  }

  handleSearch(page) {
    setState(() {
      futureListTTSDonHang = getListTTS(page - 1);
    });
  }

  handleSearch1() {
    setState(() {
      futureListTTSDonHang = getListTTS(0);
    });
  }

  dynamic handleTachDonHang(securityModel) {
    var requestBody = {
      "orderName": widget.order!.orderName,
      "orgId": widget.order!.union!.id,
      "companyId": widget.order!.enterprise!.id,
      "workAddress": widget.order!.workAddress,
      "jobId": widget.order!.jobs!.id,
      "jobDetailId": widget.order!.jobsDetail!.id,
      "implementTime": widget.order!.implementTime,
      "genderRequired": widget.order!.genderRequired,
      "ageFrom": widget.order!.ageFrom,
      "ageTo": widget.order!.ageTo,
      "ttsRequired": widget.order!.ttsRequired,
      "ttsMaleRequired": widget.order!.ttsRequired,
      "ttsFemaleRequired": widget.order!.ttsFemaleRequired,
      "ttsCandidates": widget.order!.ttsCandidates,
      "ttsMaleCandidates": widget.order!.ttsMaleCandidates,
      "ttsFemaleCandidates": widget.order!.ttsFemaleCandidates,
      "academicId": widget.order!.academicId,
      "skill": widget.order!.skill,
      "eyeSight": widget.order!.eyeSight,
      "eyeSightGlasses": widget.order!.eyeSightGlasses,
      "eyeSightSurgery": widget.order!.eyeSightSurgery,
      "height": widget.order!.heigth,
      "weight": widget.order!.weight,
      "rightHanded": widget.order!.rightHanded,
      "leftHanded": widget.order!.leftHanded,
      "maritalStatus": widget.order!.maritalStatus,
      "smoke": widget.order!.smoke,
      "drinkAlcohol": widget.order!.drinkAlcohol,
      "tattoo": widget.order!.tattoo,
      "everSurgery": widget.order!.everSurgery,
      "everCesareanSection": widget.order!.everCesareanSection,
      "otherHealthRequired": widget.order!.otherHealthRequired,
      "otherHealthRequiredAccept": widget.order!.otherHealthRequiredAccept,
      "priorityCases": widget.order!.priorityCases,
      "restrictionCases": widget.order!.restrictionCases,
      "recruiMethod": widget.order!.recruiMethod,
      "recruiContent": widget.order!.recruiContent,
      "testFormNumber": widget.order!.testFormNumber,
      "sendListFormDate": widget.order!.sendListFormDate,
      "estimatedInterviewDate": widget.order!.estimatedInterviewDate,
      "estimatedAdmissionDate": widget.order!.estimatedAdmissionDate,
      "estimatedEntryDate": widget.order!.estimatedEntryDate,
      "firstMonthSubsidy": widget.order!.firstMonthSubsidy,
      "salary": widget.order!.salary,
      "insurance": widget.order!.insurance,
      "livingCost": widget.order!.livingCost,
      "netMoney": widget.order!.netMoney,
      "orderUrgent": widget.order!.orderUrgent,
      "nominateStatus": widget.order!.nominateStatus,
      "closeNominateUser": widget.order!.closeNominateUser,
      "closeNominateDate": widget.order!.closeNominateDate,
      "orderStatusId": widget.order!.orderStatusId,
      "aamUser": securityModel.userLoginCurren['id'], //user đang đăng nhập
      "changeUserDate": FormatDate.formatDateInsertDB(DateTime.now()),
      "publishDate": widget.order!.publishDate,
      "stopProcessing": widget.order!.stopProcessing
    };

    return requestBody;
  }

  //Sửa đang được thực hiện
  bool checkStatusOrderDisable() {
    //widget.order!.stopProcessing == 1 Đang chờ xử lí tạm dừng
    //widget.order!.statusOrder!.id == 4 Dừng hẳn
    //widget.order!.statusOrder!.id == 5 Đã hoàn thành
    //widget.order!.closeNominateUser == null -1 Không tồn tại người chốt tiến cử
    //widget.order!.nominateStatus != 1 chưa phải là trạng thái Da dung tien cu don hang
    // if (widget.order!.stopProcessing == 1 ||
    //     widget.order!.statusOrder!.id == 4 ||
    //     widget.order!.statusOrder!.id == 5 ||
    //     widget.order!.closeNominateUser == null ||
    //     widget.order!.nominateStatus != 1) {
    //   return true;
    // }
    // return false;
    if (widget.order!.stopProcessing != 1 && widget.order!.statusOrder!.id == 3) {
      return true;
    }
    return false;
  }

  hienThiNgayXuatCanhCuaThucTapSinh(User? ttsDonHang) {
    try {
      if (ttsDonHang != null) {
        if (ttsDonHang.departureDate != null) {
          return getDateView(ttsDonHang.departureDate);
        }
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NavigationModel, SecurityModel>(
        builder: (context, navigationModel, securityModel, child) => FutureBuilder<List<User>>(
            future: futureListTTSDonHang,
            builder: (context, snapshot) {
              return ListView(
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: marginBoxFormTab,
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                      color: colorWhite,
                      borderRadius: borderRadiusContainer,
                      boxShadow: [boxShadowContainer],
                      border: borderAllContainerBox,
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 5),
                        Container(
                          color: backgroundPage,
                          padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 5,
                                child: Container(
                                  // padding: paddingBoxContainer,
                                  margin: marginTopBoxContainer,
                                  decoration: BoxDecoration(
                                    color: colorWhite,
                                    borderRadius: borderRadiusContainer,
                                    boxShadow: [boxShadowContainer],
                                    border: borderAllContainerBox,
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      //start button thêm mới
                                      Container(
                                        margin: EdgeInsets.only(top: 30, right: 30),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            if (widget.order!.stopProcessing == 1)
                                              if (widget.order!.orderStatusId == 5)
                                                Text(
                                                  "*Đơn hàng đã dừng xử lí!",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 16,
                                                    fontStyle: FontStyle.italic,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                )
                                              else
                                                Text(
                                                  "*Đơn hàng đang tạm dừng xử lí!",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 16,
                                                    fontStyle: FontStyle.italic,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ),
                                            if (widget.order!.orderStatusId == 4)
                                              Text(
                                                "*Đơn hàng đã hoàn thành!",
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 16,
                                                  fontStyle: FontStyle.italic,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            Container(),
                                            Container(
                                              margin: marginLeftBtn,
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                  padding: paddingBtn,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: borderRadiusBtn,
                                                  ),
                                                  backgroundColor: checkStatusOrderDisable()
                                                      ? _selectedTrue.length > 0
                                                          ? backgroundColorBtn
                                                          : Colors.grey
                                                      : Colors.grey,
                                                  primary: Theme.of(context).iconTheme.color,
                                                  textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                ),
                                                onPressed: checkStatusOrderDisable()
                                                    ? _selectedTrue.length > 0
                                                        ? () {
                                                            var requestBody = handleTachDonHang(securityModel);
                                                            showDialog(
                                                              context: context,
                                                              builder: (BuildContext context) => ModalOrderSplit(
                                                                orderCopy: requestBody,
                                                                id: widget.order!.id,
                                                                listTTSDonHang: listTTSDonHang,
                                                                func: handleSearch1,
                                                              ),
                                                            );
                                                          }
                                                        : null
                                                    : null,
                                                child: Row(
                                                  children: [
                                                    Text('Tách đơn hàng', style: textButton),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      //end button thêm mới
                                      Container(
                                        padding: EdgeInsets.fromLTRB(10, 15, 0, 15),
                                        width: MediaQuery.of(context).size.width * 1,
                                        color: Colors.white,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      'Danh sách TTS thuộc đơn hàng',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      'Tổng số TTS đã xuất cảnh: $numberTTSXuatCanh',
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Container(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      //Start Datatable
                                      if (snapshot.hasData)
                                        LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                                          return Center(
                                              child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                              child: DataTable(
                                                dataTextStyle: const TextStyle(color: Color(0xff313131), fontSize: 14, fontWeight: FontWeight.w500),
                                                showBottomBorder: true,
                                                dataRowHeight: 60,
                                                showCheckboxColumn: true,
                                                dataRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                                                  if (states.contains(MaterialState.selected)) {
                                                    return MaterialStateColor.resolveWith((states) => const Color(0xffeef3ff));
                                                  }
                                                  return MaterialStateColor.resolveWith((states) => Colors.white); // Use the default value.
                                                }),
                                                columns: <DataColumn>[
                                                  DataColumn(
                                                    label: Text(
                                                      'STT',
                                                      style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xff858791), fontSize: 12),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      'Ngày xuất cảnh',
                                                      style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xff858791), fontSize: 12),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      'Mã TTS',
                                                      style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xff858791), fontSize: 12),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      'Tên TTS',
                                                      style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xff858791), fontSize: 12),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      'Giới tính',
                                                      style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xff858791), fontSize: 12),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      'Trạng thái',
                                                      style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xff858791), fontSize: 12),
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      'Quá trình làm việc',
                                                      style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xff858791), fontSize: 12),
                                                    ),
                                                  ),
                                                ],
                                                rows: <DataRow>[
                                                  for (int i = 0; i < listUserInOrder.length; i++)
                                                    DataRow(
                                                      cells: <DataCell>[
                                                        DataCell(Text("${(currentPage - 1) * rowPerPage + i + 1}")),
                                                        DataCell(Text(hienThiNgayXuatCanhCuaThucTapSinh(listUserInOrder[i]) != null
                                                            ? hienThiNgayXuatCanhCuaThucTapSinh(listUserInOrder[i])
                                                            : getDateView(widget.order!.estimatedEntryDate))),
                                                        DataCell(Text(listUserInOrder[i].userCode)),
                                                        DataCell(Text(listUserInOrder[i].fullName + "\n(" + getDateView(listUserInOrder[i].birthDate) + ")")),
                                                        DataCell(Text(listUserInOrder[i].gender == 1 ? "Nam" : "Nữ")),
                                                        DataCell(Text(listUserInOrder[i].status!.statusName.toString() + hienThiTamDungXuly(listUserInOrder[i]))),
                                                        DataCell(listUserInOrder[i].status!.id == 11
                                                            ? Container(
                                                                color: Colors.grey,
                                                                width: 100,
                                                                child: TextButton(
                                                                    style: TextButton.styleFrom(
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(5.0),
                                                                      ),
                                                                      backgroundColor: Color(0xffF77919),
                                                                      primary: Theme.of(context).iconTheme.color,
                                                                    ),
                                                                    onPressed: () {
                                                                      showDialog(
                                                                          context: context,
                                                                          builder: (BuildContext context) => ModalContentViolations(
                                                                                idTTS: listUserInOrder[i].id,
                                                                                orderId: widget.order!.id,
                                                                              ));
                                                                    },
                                                                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                      Text('Xem chi tiết', style: textButton),
                                                                    ])),
                                                              )
                                                            : Container(
                                                                width: 100,
                                                                child: Tooltip(
                                                                  message: "Chỉ xem khi thực tập sinh đã xuất cảnh",
                                                                  child: TextButton(
                                                                      style: TextButton.styleFrom(
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(5.0),
                                                                        ),
                                                                        backgroundColor: Colors.grey,
                                                                        primary: Theme.of(context).iconTheme.color,
                                                                      ),
                                                                      onPressed: () {},
                                                                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                                        Text('Xem chi tiết', style: textButton),
                                                                      ])),
                                                                ),
                                                              )),
                                                      ],
                                                      selected: _selected[i],
                                                      onSelectChanged: (bool? value) {
                                                        setState(() {
                                                          _selectedTrue.clear();
                                                          listTTSDonHang.clear();
                                                          _selected[i] = value!;

                                                          for (int j = 0; j < _selected.length; j++) {
                                                            if (_selected[j] == true) {
                                                              _selectedTrue.add(_selected[j]);
                                                              listTTSDonHang.add(listUserInOrder[j]);
                                                            }
                                                          }
                                                          print(_selectedTrue);
                                                          print(listTTSDonHang);
                                                        });
                                                      },
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ));
                                        })
                                      //End Datatable
                                      else if (snapshot.hasError)
                                        Text("Fail! ${snapshot.error}")
                                      else
                                        Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      Container(
                                        margin: const EdgeInsets.only(right: 50),
                                        child: DynamicTablePagging(
                                          rowCount,
                                          currentPage,
                                          rowPerPage,
                                          pageChangeHandler: (page) {
                                            setState(() {
                                              //currentPage = page - 1;
                                              handleSearch(page);
                                            });
                                          },
                                          rowPerPageChangeHandler: (rowPerPage) {
                                            setState(() {
                                              this.rowPerPage = rowPerPage!;
                                              //coding
                                              this.firstRow = page * currentPage;
                                              handleSearch(page);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              );
            }));
  }
}
