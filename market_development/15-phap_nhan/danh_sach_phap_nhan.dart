import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/model/market_development/phapnhan.dart';

import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:provider/provider.dart';

import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../config.dart';
import '../../../../model/model.dart';
import '../../../forms/market_development/utils/form.dart';
import '../3-enterprise_manager/enterprise_manager.dart';

// import '../../../api.dart';
// import '../../../common/widgets_form.dart';
// import '../../../model/model.dart';
// import '../../../common/style.dart';
// import '../../../model/type.dart';

class DanhSachPhapNhan extends StatelessWidget {
  const DanhSachPhapNhan({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: DanhSachPhapNhanBody());
  }
}

class DanhSachPhapNhanBody extends StatefulWidget {
  const DanhSachPhapNhanBody({Key? key}) : super(key: key);

  @override
  State<DanhSachPhapNhanBody> createState() => _DanhSachPhapNhanBodyState();
}

class _DanhSachPhapNhanBodyState extends State<DanhSachPhapNhanBody> {
  var body = {};
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  late Future<List<PhapNhan>> futureListPhapNhan;
  List<PhapNhan> listPhapNhan = [];
  bool _setLoading = false;
  bool _setLoading1 = false;
  List<bool> _selected = [];
  Map<int, String> _mapStatus = {
    0: ' Không hoạt động',
    1: ' Hoạt động',
  };
  TextEditingController tenPhapNhanController = TextEditingController();

  Future<List<PhapNhan>> getListOrder(page, context, {tenPhapNhan}) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response;

    String condition = "";
    if (tenPhapNhan != null) {
      condition += " name~'*$tenPhapNhan*' ";
    }
    response = await httpGet("/api/phapnhan/get/page?page=$page&size=$rowPerPage&filter=$condition", context);

    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        currentPage = page + 1;
        content = body['content'];
        rowCount = body["totalElements"];
        totalElements = body["totalElements"];
        lastRow = totalElements;
        listPhapNhan = content.map((e) {
          return PhapNhan.fromJson(e);
        }).toList();
        _selected = List<bool>.generate(listPhapNhan.length, (int index) => false);
      });
    }
    return content.map((e) {
      return PhapNhan.fromJson(e);
    }).toList();
  }

  Widget getImage({id, fileName}) {
    if (fileName == null) {
      return Container();
    }
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2.0, style: BorderStyle.solid),
        ),
        margin: EdgeInsets.only(bottom: 15),
        width: 300,
        height: 200,
        child: Image.network("$baseUrl/api/files/$fileName"));
  }

  // String titleLog = '';
  deletePhapNhan(id) async {
    var response = await httpDelete("/api/phapnhan/del/$id", context);

    var body = jsonDecode(response['body']);
    if (body.containsKey("1")) {
      print(body.containsKey);
      showToast(context: context, msg: body['1'], color: Colors.green, icon: Icon(Icons.abc));
    } else {
      showToast(context: context, msg: body['0'], color: Colors.red, icon: Icon(Icons.abc));
    }
  }

  @override
  void initState() {
    super.initState();
    futureListPhapNhan = getListOrder(page - 1, context);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: userRule('/quan-ly-phap-nhan', context),
        builder: (context, listRule) {
          if (listRule.hasData) {
            return Consumer2<NavigationModel, SecurityModel>(
                builder: (context, navigationModel, securityModel, child) => FutureBuilder<List<PhapNhan>>(
                    future: futureListPhapNhan,
                    builder: (context, snapshot) {
                      return ListView(
                        children: [
                          TitlePage(
                            listPreTitle: [
                              {'url': '/phat-trien-thi-truong', 'title': 'Dashboard'},
                              {'url': '/quan-ly-phap-nhan', 'title': 'Quản lý pháp nhân'}
                            ],
                            content: 'Quản lý pháp nhân',
                          ),
                          Container(
                            color: backgroundPage,
                            padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: MediaQuery.of(context).size.width * 1,
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
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.fromLTRB(30, 30, 0, 0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  //end button Bắt đầu xử lý
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Expanded(
                                                            flex: 3,
                                                            child: TextFieldValidatedMarket(
                                                                type: "None",
                                                                labe: "Tên pháp nhân",
                                                                isReverse: false,
                                                                flexLable: 2,
                                                                flexTextField: 6,
                                                                marginBottom: 0,
                                                                controller: tenPhapNhanController),
                                                          ),
                                                          Expanded(
                                                            flex: 1,
                                                            child: Container(),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(flex: 2, child: Container()),
                                                  Container(
                                                    margin: EdgeInsets.only(left: 20),
                                                    child: TextButton.icon(
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
                                                        textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                                                      ),
                                                      onPressed: () async {
                                                        await getListOrder(0, context, tenPhapNhan: tenPhapNhanController.text);
                                                      },
                                                      icon: Transform.rotate(
                                                        angle: 270,
                                                        child: Icon(
                                                          Icons.search,
                                                          color: Colors.white,
                                                          size: 15,
                                                        ),
                                                      ),
                                                      label: Row(
                                                        children: [
                                                          Text('Tìm kiếm ', style: textButton),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  //end button tìm kiếm
                                                  //start button xuất file
                                                  getRule(listRule.data, Role.Them, context)
                                                      ? Container(
                                                          margin: EdgeInsets.only(left: 20),
                                                          child: TextButton.icon(
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
                                                              textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                                                            ),
                                                            onPressed: () {
                                                              navigationModel.add(pageUrl: "/them-moi-phap-nhan");
                                                            },
                                                            icon: Icon(
                                                              Icons.add,
                                                              color: Colors.white,
                                                              size: 15,
                                                            ),
                                                            label: Row(
                                                              children: [
                                                                Text('Thêm mới', style: textButton),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      : Container(),
                                                  //end button thêm mới
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width * 1,
                                  margin: marginTopBoxContainer,
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
                                            'Quản lý pháp nhân',
                                            style: titleBox,
                                          ),
                                          Icon(
                                            Icons.more_horiz,
                                            color: colorIconTitleBox,
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
                                      //Start Datatable
                                      Column(
                                        children: [
                                          if (snapshot.hasData)
                                            Container(
                                                width: MediaQuery.of(context).size.width * 1,
                                                child: DataTable(
                                                  dataTextStyle: const TextStyle(color: Color(0xff313131), fontSize: 14, fontWeight: FontWeight.w500),
                                                  showBottomBorder: true,
                                                  dataRowHeight: 60,
                                                  columnSpacing: 5,
                                                  showCheckboxColumn: true,
                                                  dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                                                    (Set<MaterialState> states) {
                                                      if (states.contains(MaterialState.selected)) {
                                                        return MaterialStateColor.resolveWith((states) => const Color(0xffeef3ff));
                                                      }
                                                      return MaterialStateColor.resolveWith((states) => Colors.white); // Use the default value.
                                                    },
                                                  ),
                                                  columns: <DataColumn>[
                                                    DataColumn(
                                                      label: Text(
                                                        'STT',
                                                        style: titleTableData,
                                                        // textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'Tên pháp nhân',
                                                        style: titleTableData,
                                                        // textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'Mô tả',
                                                        style: titleTableData,
                                                        // textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'Trạng thái',
                                                        style: titleTableData,
                                                        // textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                    DataColumn(
                                                      label: Text(
                                                        'Hành động',
                                                        style: titleTableData,
                                                        // textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                  ],
                                                  rows: <DataRow>[
                                                    for (int i = 0; i < listPhapNhan.length; i++)
                                                      DataRow(
                                                        cells: <DataCell>[
                                                          DataCell(Container(
                                                              width: (MediaQuery.of(context).size.width / 10) * 0.15, child: Text("${(currentPage - 1) * rowPerPage + i + 1}"))),
                                                          DataCell(Container(width: (MediaQuery.of(context).size.width / 10) * 0.7, child: Text(listPhapNhan[i].name.toString()))),
                                                          DataCell(
                                                            Container(
                                                                width: (MediaQuery.of(context).size.width / 10) * 0.8,
                                                                child: Tooltip(
                                                                  height: 30,
                                                                  message: listPhapNhan[i].description != null ? listPhapNhan[i].description!.toString() : "Không có mô tả",
                                                                  child: ConstrainedBox(
                                                                    constraints: BoxConstraints(maxWidth: 200),
                                                                    child: Text(
                                                                      listPhapNhan[i].description != null ? listPhapNhan[i].description!.toString() : "Không có mô tả",
                                                                      overflow: TextOverflow.ellipsis,
                                                                      maxLines: 3,
                                                                    ),
                                                                  ),
                                                                )),
                                                          ),
                                                          DataCell(Container(
                                                              width: (MediaQuery.of(context).size.width / 10) * 0.4,
                                                              child: Text(listPhapNhan[i].status != null ? _mapStatus[listPhapNhan[i].status].toString() : ""))),
                                                          DataCell(Row(
                                                            children: [
                                                              getRule(listRule.data, Role.Xem, context)
                                                                  ? Container(
                                                                      margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                      child: InkWell(
                                                                        onTap: () {
                                                                          navigationModel.add(pageUrl: "/xem-chi-tiet-phap-nhan/${listPhapNhan[i].id.toString()}");
                                                                        },
                                                                        child: Icon(Icons.visibility),
                                                                      ),
                                                                    )
                                                                  : Container(),
                                                              getRule(listRule.data, Role.Sua, context)
                                                                  ? Container(
                                                                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                      child: Tooltip(
                                                                        message: "",
                                                                        child: InkWell(
                                                                            onTap: () {
                                                                              navigationModel.add(pageUrl: "/cap-nhat-phap-nhan/${listPhapNhan[i].id.toString()}");
                                                                            },
                                                                            child: Icon(
                                                                              Icons.edit_calendar,
                                                                              color: Color(0xff009C87),
                                                                            )),
                                                                      ))
                                                                  : Container(),
                                                            ],
                                                          )),
                                                        ],
                                                        // onSelectChanged: (bool? value) {
                                                        //   setState(() {
                                                        //     // print(listOrderExcell.length);
                                                        //     // //5 la dung xu li han
                                                        //     // if (listOrder[i].statusOrder!.id == 5) {
                                                        //     //   _selected[i] = false;
                                                        //     //   showToast(
                                                        //     //       context: context,
                                                        //     //       msg: "Đơn hàng này đã dừng xử lý!",
                                                        //     //       color: Color.fromARGB(135, 247, 217, 179),
                                                        //     //       icon: Icon(Icons.supervised_user_circle));
                                                        //     // } else if (listOrder[i] //4 la da hoan thanh
                                                        //     //         .statusOrder!
                                                        //     //         .id ==
                                                        //     //     4) {
                                                        //     //   _selected[i] = false;
                                                        //     //   showToast(
                                                        //     //       context: context,
                                                        //     //       msg: "Đơn hàng này đã hoàn thành!",
                                                        //     //       color: Color.fromARGB(135, 247, 217, 179),
                                                        //     //       icon: Icon(Icons.supervised_user_circle));
                                                        //     // } else {
                                                        //     //   _selected[i] = value;
                                                        //     // }
                                                        //   });
                                                        // },
                                                      ),
                                                  ],
                                                ))
                                          else if (snapshot.hasError)
                                            Text("Fail! ${snapshot.error}")
                                          else if (!snapshot.hasData)
                                            Center(
                                              child: Center(child: CircularProgressIndicator()),
                                            ),
                                        ],
                                      ),

                                      //End Datatable
                                      Container(
                                        margin: const EdgeInsets.only(right: 50),
                                        child: DynamicTablePagging(
                                          rowCount,
                                          currentPage,
                                          rowPerPage,
                                          pageChangeHandler: (page) {
                                            setState(() {});
                                          },
                                          rowPerPageChangeHandler: (rowPerPage) {
                                            setState(() {
                                              this.rowPerPage = rowPerPage!;
                                              //coding
                                              this.firstRow = page * currentPage;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Footer()
                              ],
                            ),
                          ),
                        ],
                      );
                    }));
          } else if (listRule.hasError) {
            return Text('${listRule.error}');
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
