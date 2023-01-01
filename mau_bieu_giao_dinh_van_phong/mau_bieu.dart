// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gentelella_flutter/api.dart';
import 'package:gentelella_flutter/common/dynamic_table.dart';
import 'package:gentelella_flutter/common/style.dart';
import 'package:gentelella_flutter/widgets/ui/mau_bieu_giao_dinh_van_phong/sua_bieu_mau.dart';
import 'package:gentelella_flutter/widgets/ui/mau_bieu_giao_dinh_van_phong/them_moi_bieu_mau.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../../../common/toast.dart';
import '../../../config.dart';
import '../navigation.dart';

class MauBieu extends StatefulWidget {
  const MauBieu({Key? key}) : super(key: key);

  @override
  State<MauBieu> createState() => _CaiDatBoPhanState();
}

class _CaiDatBoPhanState extends State<MauBieu> {
  var body = {};
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  var tableIndex = 1;
  List<BieuMau> listBieuMau = [];
  String find = "";
  Future<List<BieuMau>> getListHSNS(page, String find) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response;
    if (find == "") {
      response = await httpGet("/api/bieumau/get/page?size=$rowPerPage&page=$page&filter=status:1 ", context);
    } else {
      response = await httpGet("/api/bieumau/get/page?size=$rowPerPage&page=$page&filter=status:1 $find ", context);
    }
    if (response.containsKey("body")) {
      var body = jsonDecode(response['body']);
      var content = [];
      setState(() {
        currentPage = page + 1;
        content = body['content'];
        rowCount = body["totalElements"];
        totalElements = body["totalElements"];
        lastRow = totalElements;

        listBieuMau = content.map((e) {
          return BieuMau.fromJson(e);
        }).toList();
        if (listBieuMau.length > 0) {
          var firstRow = (currentPage) * rowPerPage + 1;
          var lastRow = (currentPage + 1) * rowPerPage;
          if (lastRow > totalElements) {
            lastRow = totalElements;
          }
          tableIndex = (currentPage - 1) * rowPerPage + 1;
        }
      });

      return listBieuMau;
    }

    return listBieuMau;
  }

  bool checkData = false;
  void callAPI() async {
    setState(() {
      checkData = false;
    });
    await getListHSNS(0, find);
    setState(() {
      checkData = true;
    });
  }

  TextEditingController titleFind = TextEditingController();

  @override
  void initState() {
    super.initState();
    callAPI();
  }

  void disPose() {
    titleFind.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
      widgetBody: Consumer<SecurityModel>(
          builder: (context, user, child) => SingleChildScrollView(
                controller: ScrollController(),
                child: Column(children: [
                  TitlePage(
                    listPreTitle: [
                      {'url': "/dashboard", 'title': 'Home'},
                    ],
                    content: 'Mẫu biểu giao dịch văn phòng',
                    widgetBoxRight: Row(
                      children: [],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                      color: colorWhite,
                      borderRadius: borderRadiusContainer,
                      boxShadow: [boxShadowContainer],
                      border: borderAllContainerBox,
                    ),
                    padding: paddingBoxContainer,
                    margin: EdgeInsets.only(top: 25, left: 25, right: 25),
                    // transform: Matrix4.rotationX(2),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Nhập thông tin',
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
                        Row(
                          children: [
                            TextFieldValidated(
                              label: 'Tên mẫu biểu',
                              type: 'None:',
                              height: 40,
                              controller: titleFind,
                              onChanged: (value) {},
                            ),
                            SizedBox(width: 100),
                            Expanded(flex: 3, child: Container()),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 20),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20.0,
                                      horizontal: 30.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                    primary: Theme.of(context).iconTheme.color,
                                    textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                  ),
                                  onPressed: () async {
                                    find = "";
                                    var title1;

                                    if (titleFind.text != "")
                                      find = "and title~'*${titleFind.text}*'";
                                    else
                                      find = "";
                                    getListHSNS(0, find);
                                  },
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.search,
                                        color: Colors.white,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text('Tìm kiếm', style: textButton),
                                    ],
                                  ),
                                ),
                              ),
                              (user.userLoginCurren['departId'] == 2 ||
                                      user.userLoginCurren['departId'] == 1 ||
                                      user.userLoginCurren['departId'] == 10)
                                  ? Container(
                                      margin: EdgeInsets.only(left: 20),
                                      child: TextButton(
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 20.0,
                                            horizontal: 30.0,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(5.0),
                                          ),
                                          backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                          primary: Theme.of(context).iconTheme.color,
                                          textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                        ),
                                        onPressed: () async {
                                          await showDialog(context: context, builder: (BuildContext context) => ThemMoiBM());
                                          callAPI();
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.add,
                                              color: Colors.white,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text('Thêm mới', style: textButton),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  (checkData)
                      ? Container(
                          margin: EdgeInsets.only(top: 25, left: 25, right: 25),
                          decoration: BoxDecoration(
                            color: colorWhite,
                            borderRadius: borderRadiusContainer,
                            boxShadow: [boxShadowContainer],
                            border: borderAllContainerBox,
                          ),
                          padding: paddingBoxContainer,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Mẫu biểu giao dịch',
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
                              Container(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DataTable(
                                            showCheckboxColumn: false,
                                            // columnSpacing: 20,
                                            horizontalMargin: 10,
                                            dataRowHeight: 60,
                                            columns: [
                                              DataColumn(label: Text('    STT', style: titleTableData)),
                                              DataColumn(label: Text('Tên mẫu biểu', style: titleTableData)),
                                              DataColumn(label: Text('Ngày cập nhật', style: titleTableData)),
                                              DataColumn(label: Text('Hành động', style: titleTableData)),
                                            ],
                                            rows: <DataRow>[
                                              for (int i = 0; i < listBieuMau.length; i++)
                                                DataRow(
                                                  cells: <DataCell>[
                                                    DataCell(Text("      ${1 + i}")),
                                                    DataCell(Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Flexible(child: Text("${listBieuMau[i].title}")),
                                                        (listBieuMau[i].description != "")
                                                            ? Tooltip(
                                                                message: "${listBieuMau[i].description}",
                                                                textStyle: TextStyle(fontSize: 15, color: colorWhite),
                                                                child: Icon(
                                                                  Icons.help,
                                                                  size: 20,
                                                                  color: colorOrange,
                                                                ),
                                                                verticalOffset: 15)
                                                            : Row()
                                                      ],
                                                    )),
                                                    DataCell(Text((listBieuMau[i].ngaySua != "")
                                                        ? "${DateFormat('HH:mm - dd/MM/yyyy').format(DateTime.parse(listBieuMau[i].ngaySua!).toLocal())}"
                                                        : "")),
                                                    DataCell(
                                                      Row(
                                                        children: [
                                                          Container(
                                                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                              child: Tooltip(
                                                                  message: "Tải file",
                                                                  textStyle: TextStyle(fontSize: 15, color: colorWhite),
                                                                  child: InkWell(
                                                                    onTap: () async {
                                                                      if (listBieuMau[i].url != "") downloadFile(listBieuMau[i].url!);
                                                                    },
                                                                    child: Icon(Icons.download, color: Color(0xff009C87)),
                                                                  ),
                                                                  verticalOffset: 15)),
                                                          Container(
                                                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                              child: Tooltip(
                                                                  message: "Copy link tải",
                                                                  textStyle: TextStyle(fontSize: 15, color: colorWhite),
                                                                  child: IconButton(
                                                                    onPressed: () {
                                                                      Clipboard.setData(
                                                                          ClipboardData(text: "$baseUrl/api/files/${listBieuMau[i].url!}"));
                                                                      showToast(
                                                                          context: context,
                                                                          msg: "Đã sao chép đường link tải",
                                                                          color: Color.fromARGB(255, 97, 248, 102),
                                                                          icon: const Icon(Icons.copy),
                                                                          timeHint: 2);
                                                                    },
                                                                    icon: Icon(Icons.content_copy, color: Color(0xff009C87)),
                                                                  ),
                                                                  verticalOffset: 15)),
                                                          (user.userLoginCurren['departId'] == 2 ||
                                                                  user.userLoginCurren['departId'] == 1 ||
                                                                  user.userLoginCurren['departId'] == 10)
                                                              ? Container(
                                                                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                  child: InkWell(
                                                                    onTap: () async {
                                                                      await showDialog(
                                                                          context: context,
                                                                          builder: (BuildContext context) => SuaBM(
                                                                                bieuMau: listBieuMau[i],
                                                                                callback: (value) {
                                                                                  setState(() {
                                                                                    listBieuMau[i] = value;
                                                                                  });
                                                                                },
                                                                              ));
                                                                    },
                                                                    child: Icon(Icons.edit_calendar, color: Color(0xff009C87)),
                                                                  ))
                                                              : Container(),
                                                          (user.userLoginCurren['departId'] == 2 ||
                                                                  user.userLoginCurren['departId'] == 1 ||
                                                                  user.userLoginCurren['departId'] == 10)
                                                              ? Container(
                                                                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                  child: InkWell(
                                                                    onTap: () {
                                                                      showDialog(
                                                                          context: context,
                                                                          builder: (BuildContext context) => AlertDialog(
                                                                                title:
                                                                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
                                                                                          'Xác nhận xóa mẫu biểu',
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
                                                                                  height: 100,
                                                                                  child: Text("Xóa biểu mẫu :${listBieuMau[i].title}"),
                                                                                ),
                                                                                actions: [
                                                                                  ElevatedButton(
                                                                                    onPressed: () async {
                                                                                      var response = await httpDelete(
                                                                                          "/api/bieumau/del/${listBieuMau[i].id}", context);
                                                                                      Navigator.pop(context);
                                                                                      callAPI();
                                                                                    },
                                                                                    child: Text(
                                                                                      'Xóa',
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
                                                                              ));
                                                                    },
                                                                    child: Icon(Icons.delete_outline, color: Colors.red),
                                                                  ))
                                                              : Container(),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    DynamicTablePagging(
                                      rowCount,
                                      currentPage,
                                      rowPerPage,
                                      pageChangeHandler: (page) {
                                        setState(() {
                                          getListHSNS(page - 1, find);
                                          currentPage = page - 1;
                                        });
                                      },
                                      rowPerPageChangeHandler: (rowPerPage) {
                                        setState(() {
                                          this.rowPerPage = rowPerPage!;
                                          this.firstRow = page * currentPage;
                                          getListHSNS(0, find);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : Center(child: const CircularProgressIndicator()),
                  Footer(marginFooter: EdgeInsets.only(top: 5), paddingFooter: EdgeInsets.all(15)),
                  SizedBox(height: 20)
                ]),
              )),
    );
  }
}

class BieuMau {
  int? id;
  String? ngaySua;
  String? title;
  String? description;
  String? url;
  int? status;
  BieuMau({this.id, this.title, this.description, this.url, this.status, this.ngaySua});

  factory BieuMau.fromJson(Map<dynamic, dynamic> json) {
    return BieuMau(
      id: json['id'] ?? 0,
      ngaySua: json['modifiedDate'] ?? "",
      title: json['title'] ?? "",
      description: json['description'] ?? "",
      url: json['url'] ?? "",
      status: json['status'] ?? 0,
    );
  }
  Map<String, dynamic> toMap() {
    return {'id': id, 'title': title, 'description': description, 'url': url, 'status': status};
  }
}
