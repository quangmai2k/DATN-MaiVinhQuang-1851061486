// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../../api.dart';

import '../../../../../common/style.dart';

import '../../../../../common/toast.dart';
import '../../../../../model/market_development/QuaTrinhLamViec.dart';

import '../../../../../model/market_development/phongban.dart';
import '../../../../../model/market_development/quydinh.dart';

import '../../../../forms/market_development/utils/funciton.dart';
import '../../3-enterprise_manager/enterprise_manager.dart';
import 'modal_add_ndvp.dart';

class ModalContentViolations extends StatefulWidget {
  int? idTTS;
  int? orderId;
  ModalContentViolations({Key? key, this.idTTS, this.orderId}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ModalContentViolationsState();
  }
}

class _ModalContentViolationsState extends State<ModalContentViolations> {
  var body = {};
  var page = 1;
  var rowPerPage = 5;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;

  bool isValidateForm = false;
  DateTime? violateDate;
  bool _setLoading = false;

  late Future<List<QuaTrinhLamViec1>> _futureNoiDungViPham;
  List<QuaTrinhLamViec1> listQuaTrinhLamViec1 = [];
  Future<List<QuaTrinhLamViec1>> getNoiDungViPham() async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response;

    // ignore: unused_local_variable
    String condition = "";

    response = await httpGet("/api/tts-quatrinhlamviec/get/page?filter=ttsId:${widget.idTTS}", context);

    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        currentPage = page + 1;
        content = body['content'];
        rowCount = body["totalElements"];
        totalElements = body["totalElements"];
        lastRow = totalElements;

        listQuaTrinhLamViec1 = content.map((e) {
          return QuaTrinhLamViec1.fromJson(e);
        }).toList();
      });
    }
    return content.map((e) {
      return QuaTrinhLamViec1.fromJson(e);
    }).toList();
  }

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

  loadDataWhenSubmit() async {
    setState(() {
      _setLoading = true;
      _futureNoiDungViPham = getNoiDungViPham();
      _setLoading = false;
    });
  }

  List<QuyDinh> listQuyDinh = [];

  String getRuleNameQuyDinh(List<QuyDinh> listQuyDinh, int? id) {
    if (id == null) {
      return "";
    }
    for (int i = 0; i < listQuyDinh.length; i++) {
      print("thai" + listQuyDinh[i].id.toString());
      if (id.toString().trim() == listQuyDinh[i].id.toString().trim()) {
        print("sss");
        return listQuyDinh[i].ruleName;
      }
    }
    return "Không có dữ liệu";
  }

  deleteDonHang(id) async {
    var response = await httpDelete("/api/tts-quatrinhlamviec/del/$id", context);
    print(response);
    var body = jsonDecode(response['body']);
    if (body.containsKey("1")) {
      showToast(context: context, msg: body['1'], color: Colors.green, icon: Icon(Icons.abc));
    } else {
      showToast(context: context, msg: body['0'], color: Colors.red, icon: Icon(Icons.abc));
    }
  }

  @override
  void initState() {
    super.initState();
    initData();
    _futureNoiDungViPham = getNoiDungViPham();
  }

  initData() async {
    await getDanhSachQuyDinh();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QuaTrinhLamViec1>>(
        future: _futureNoiDungViPham,
        builder: (context, snapshot) {
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
                  child: Text('Quá trình làm việc'),
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
              width: 1500,
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
                      child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: Colors.grey,
                          width: 90,
                          height: 40,
                          margin: EdgeInsets.only(left: 10),
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
                                    builder: (BuildContext context) => ModalContentViolationsAdd(
                                          idTTS: widget.idTTS,
                                          func: loadDataWhenSubmit,
                                          orderId: widget.orderId,
                                        ));
                              },
                              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                Text("Thêm mới", style: textButton),
                              ])),
                        ),
                      ),
                      Expanded(
                        child: Container(),
                        flex: 5,
                      )
                    ],
                  )),
                  Container(
                    height: 300,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (snapshot.hasData)
                            //Start Datatable
                            !_setLoading
                                ? LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
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
                                                      style: titleTableData,
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      'Tên quy định',
                                                      style: titleTableData,
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      'Nội dung',
                                                      style: titleTableData,
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      'Ngày phát sinh',
                                                      style: titleTableData,
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      'Ngày xử lý',
                                                      style: titleTableData,
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      'Kết quả xử lý',
                                                      style: titleTableData,
                                                    ),
                                                  ),
                                                  DataColumn(
                                                    label: Text(
                                                      'Hành động',
                                                      style: titleTableData,
                                                    ),
                                                  ),
                                                ],
                                                rows: <DataRow>[
                                                  for (int i = 0; i < listQuaTrinhLamViec1.length; i++)
                                                    DataRow(
                                                      cells: <DataCell>[
                                                        DataCell(Text("${i + 1}")),
                                                        DataCell(Tooltip(
                                                          message: getRuleNameQuyDinh(listQuyDinh, listQuaTrinhLamViec1[i].violateId),
                                                          child: Container(
                                                              width: (MediaQuery.of(context).size.width / 10) * 1,
                                                              child: Text(
                                                                getRuleNameQuyDinh(listQuyDinh, listQuaTrinhLamViec1[i].violateId),
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                              )),
                                                        )),
                                                        DataCell(Tooltip(
                                                          message: listQuaTrinhLamViec1[i].issuedContent.toString(),
                                                          child: Container(
                                                              width: (MediaQuery.of(context).size.width / 10) * 1,
                                                              child: Text(
                                                                snapshot.data![i].issuedContent.toString(),
                                                                maxLines: 2,
                                                                overflow: TextOverflow.ellipsis,
                                                              )),
                                                        )),
                                                        DataCell(Container(
                                                            width: (MediaQuery.of(context).size.width / 10) * 1,
                                                            child: Text(
                                                              getDateView(listQuaTrinhLamViec1[i].issuedDate, resultError: "Chưa có ngày phát sinh"),
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                            ))),
                                                        DataCell(Container(
                                                            width: (MediaQuery.of(context).size.width / 10) * 1,
                                                            child: Text(
                                                              getDateView(listQuaTrinhLamViec1[i].handleDate, resultError: "Chưa có ngày xử lý"),
                                                              maxLines: 2,
                                                              overflow: TextOverflow.ellipsis,
                                                            ))),
                                                        DataCell(Container(
                                                          width: (MediaQuery.of(context).size.width / 10) * 1,
                                                          child: Text(
                                                            listQuaTrinhLamViec1[i].handleResult ?? "",
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        )),
                                                        DataCell(Row(
                                                          children: [
                                                            Container(
                                                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                child: InkWell(
                                                                    onTap: () {
                                                                      setState(() {
                                                                        showDialog(
                                                                            context: context,
                                                                            builder: (BuildContext context) => ModalContentViolationsAdd(
                                                                                  idTTS: widget.idTTS,
                                                                                  idNoiDungViPham: snapshot.data![i].id,
                                                                                  func: loadDataWhenSubmit,
                                                                                ));
                                                                      });
                                                                    },
                                                                    child: Icon(
                                                                      Icons.edit_calendar,
                                                                      color: Color(0xff009C87),
                                                                    ))),
                                                            Container(
                                                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                child: InkWell(
                                                                    onTap: () async {
                                                                      showDialog(
                                                                        context: context,
                                                                        builder: (BuildContext context) => XacNhanXoaXiNghiep(
                                                                          label: "Bạn có muốn bản ghi này ?",
                                                                          function: () async {
                                                                            // await deleteDonHang(listOrder[i].id);
                                                                            // await handleClickBtnSearch();
                                                                            await deleteDonHang(listQuaTrinhLamViec1[i].id);
                                                                            _futureNoiDungViPham = getNoiDungViPham();
                                                                          },
                                                                        ),
                                                                      );
                                                                    },
                                                                    child: Icon(
                                                                      Icons.delete_outlined,
                                                                      color: Colors.red,
                                                                    )))
                                                          ],
                                                        )),
                                                      ],
                                                    ),
                                                ],
                                              ))),
                                    );
                                  })
                                : Center(
                                    child: CircularProgressIndicator(),
                                  )
                          else if (snapshot.hasError)
                            Text("Fail! ${snapshot.error}")
                          else if (!snapshot.hasData)
                            Center(
                              child: CircularProgressIndicator(),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
