import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/dynamic_table.dart';
import 'package:gentelella_flutter/model/market_development/lichBay.dart';
import 'package:gentelella_flutter/model/market_development/union.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../api.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/market_development/xinghiep.dart';
import '../../../../model/model.dart';
import '../../navigation.dart';

class LichBayPTTT extends StatefulWidget {
  const LichBayPTTT({Key? key}) : super(key: key);

  @override
  _LichBayState createState() => _LichBayState();
}

class _LichBayState extends State<LichBayPTTT> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: LichBayHoSoNgoaiBody());
  }
}

class LichBayHoSoNgoaiBody extends StatefulWidget {
  const LichBayHoSoNgoaiBody({Key? key}) : super(key: key);

  @override
  State<LichBayHoSoNgoaiBody> createState() => _LichBayHoSoNgoaiBodyState();
}

class _LichBayHoSoNgoaiBodyState extends State<LichBayHoSoNgoaiBody> {
  final String urlAddNewLB = "lich-bay/add";
  final String urlThongTinLB = "/xem-chi-tiet-lich-bay";
  final String urlUpdateLB = "/lich-bay/cap-nhat";
  final String dashboard = '/ho-so-ngoai';
  var listLichBay;

  bool checkSelected = false;
  TextEditingController tenDH = TextEditingController();
  var idLichBay;
  String? selectedXiNghiep;
  String? selectedNghiepDoan;
//code mới
  List<bool> _selected = [];
  var body = {};
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  bool _setLoading = false;
  bool _setLoading1 = false;

  List<Enterprise> listEnterprise = [];
  List<UnionObj> listUnionObj = [];

  String? dateFrom;
  String? dateTo;
  TextEditingController _orderController = TextEditingController();
  List<LichBay> listFlightSchedules = [];

  late Future<List<LichBay>> futureListFlightSchedules;
  //code mới
  Future<List<Enterprise>> getListXiNghiepSearchBy(context, {key}) async {
    List<Enterprise> list = [];
    var response;
    Map<String, String> requestParam = Map();
    String condition = "";

    response = await httpGet("/api/xinghiep/get/page?sort=id&filter=${condition}", context);

    var body = jsonDecode(response['body']);
    var content = [];

    if (response.containsKey("body")) {
      content = body['content'];
    }
    list = content.map((e) {
      return Enterprise.fromJson(e);
    }).toList();
    Enterprise enterprise =
        new Enterprise(id: -1, companyCode: "", companyName: "Tất cả", orgId: -1, address: "", job: "", description: "", status: -1, createdUser: -1, createdDate: "");
    list.insert(0, enterprise);
    setState(() {
      listEnterprise = list;
    });
    return list;
  }

  Future<List<UnionObj>> getListUnionSearchBy(context, {key}) async {
    var response;
    Map<String, String> requestParam = Map();

    String condition = "";

    response = await httpGet("/api/nghiepdoan/get/page?filter=$condition", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      content = body['content'];
    }
    UnionObj union = new UnionObj(
      id: -1,
      orgCode: "",
      orgName: "Tất cả",
    );
    List<UnionObj> list = content.map((e) {
      return UnionObj.fromJson(e);
    }).toList();
    print("trung + $list");

    list.insert(0, union);
    setState(() {
      listUnionObj = list;
    });
    return list;
  }

  Future<List<LichBay>> getListFlightSchedules(page, context, {order, orgName, companyName, dateFrom1, dateTo1}) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response;

    String condition = "";

    if (order != null) {
      condition += " ( donhang.orderCode ~'*$order*' ";
      condition += " OR donhang.orderName ~'*$order*' ) ";
    }

    if (orgName != null) {
      if (orgName.toString() == "Tất cả") {
        condition += " AND donhang.nghiepdoan.orgName ~'**' ";
      } else {
        condition += " AND donhang.nghiepdoan.orgName ~'*$orgName*' ";
      }
    }
    if (companyName != null) {
      if (companyName.toString() == "Tất cả") {
        condition += " AND donhang.xinghiep.companyName ~'**' ";
      } else {
        condition += " AND donhang.xinghiep.companyName ~'*$companyName*' ";
      }
    }

    if (dateFrom1 != null) {
      condition += " AND flightDate >:'$dateFrom1' ";
    }
    if (dateTo1 != null) {
      condition += " AND flightDate <:'$dateTo1' ";
    }

    response = await httpGet("/api/lichxuatcanh/get/page?page=$page&size=$rowPerPage&filter=$condition and donhang.orderStatusId!5", context);
    print(response);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        currentPage = page + 1;
        content = body['content'];
        rowCount = body["totalElements"];
        totalElements = body["totalElements"];
        lastRow = totalElements;
        listFlightSchedules = content.map((e) {
          return LichBay.fromJson(e);
        }).toList();
        print("trung + $listFlightSchedules");
        _selected = List<bool>.generate(totalElements, (int index) => false);
      });
    }
    return content.map((e) {
      return LichBay.fromJson(e);
    }).toList();
  }

  deleteLichBay(id) async {
    var response = await httpDelete("/api/lichxuatcanh/del/$id", context);
    print(response);
    var body = jsonDecode(response['body']);
    if (body.containsKey("1")) {
      showToast(context: context, msg: body['1'], color: Colors.green, icon: Icon(Icons.abc));
    } else {
      showToast(context: context, msg: body['0'], color: Colors.red, icon: Icon(Icons.abc));
    }
  }

  handleClickBtnSearch({order, orgName, companyName, dateFrom, dateTo}) {
    print("clicked");
    setState(() {
      _setLoading = true;
    });
    print(dateFrom);
    Future<List<LichBay>> _future = getListFlightSchedules(0, context, order: order, orgName: orgName, companyName: companyName, dateFrom1: dateFrom, dateTo1: dateTo);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        futureListFlightSchedules = _future;
        _setLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initData();
    futureListFlightSchedules = getListFlightSchedules(page - 1, context, order: "");
  }

  initData() async {
    await getListUnionSearchBy(context);
    await getListXiNghiepSearchBy(context);
    setState(() {
      _setLoading1 = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: userRule('/lich-bay-pttt', context),
        builder: (context, listRule) {
          if (listRule.hasData) {
            return Consumer<NavigationModel>(
              builder: (context, navigationModel, securityModel) => _setLoading1
                  ? FutureBuilder<List<LichBay>>(
                      future: futureListFlightSchedules,
                      builder: (context, snapshot) {
                        return ListView(children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 1,
                            decoration: BoxDecoration(
                              color: colorWhite,
                              boxShadow: [boxShadowContainer],
                              border: Border(
                                bottom: borderTitledPage,
                              ),
                            ),
                            child: TitlePage(
                              listPreTitle: [
                                {'url': '/phat-trien-thi-truong', 'title': 'Dashboard'},
                                {'url': '/lich-bay-pttt', 'title': 'Lịch bay'}
                              ],
                              content: 'Lịch bay',
                            ),
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
                                          Text('Nhập thông tin', style: titleBox),
                                          Icon(Icons.more_horiz, color: Color(0xff9aa5ce), size: 14),
                                        ],
                                      ),
                                      //Đường line
                                      Container(
                                        margin: marginTopBottomHorizontalLine,
                                        child: Divider(thickness: 1, color: ColorHorizontalLine),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          TextFieldValidated(
                                            type: 'None',
                                            height: 40,
                                            controller: _orderController,
                                            label: 'Đơn hàng',
                                            flexLable: 2,
                                            flexTextField: 5,
                                          ),
                                          SizedBox(width: 100),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text('Xí nghiệp', style: titleWidgetBox),
                                                  ),
                                                  Expanded(
                                                    flex: 5,
                                                    child: Container(
                                                      height: 40,
                                                      child: DropdownSearch<Enterprise>(
                                                        mode: Mode.MENU,
                                                        showSearchBox: true,
                                                        items: listEnterprise,
                                                        selectedItem: listEnterprise.first,
                                                        itemAsString: (Enterprise? u) => u!.companyName,
                                                        dropdownSearchDecoration: styleDropDown,
                                                        emptyBuilder: (context, String? value) {
                                                          return const Padding(
                                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                                            child: Align(alignment: Alignment.center, child: Text("Không có dữ liệu !")),
                                                          );
                                                        },
                                                        onChanged: (value) {
                                                          setState(() {
                                                            selectedXiNghiep = value!.companyName;
                                                            print(selectedXiNghiep);
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(flex: 1, child: Container())
                                        ],
                                      ),
                                      SizedBox(height: 25),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text('Nghiệp đoàn', style: titleWidgetBox),
                                                  ),
                                                  Expanded(
                                                    flex: 5,
                                                    child: Container(
                                                      // width: MediaQuery.of(context).size.width * 0.15,
                                                      height: 40,
                                                      child: DropdownSearch<UnionObj>(
                                                        mode: Mode.MENU,
                                                        showSearchBox: true,
                                                        items: listUnionObj,
                                                        itemAsString: (UnionObj? u) => u!.orgName!,
                                                        selectedItem: listUnionObj.first,
                                                        dropdownSearchDecoration: styleDropDown,
                                                        emptyBuilder: (context, String? value) {
                                                          return const Padding(
                                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                                            child: Align(alignment: Alignment.center, child: Text("Không có dữ liệu !")),
                                                          );
                                                        },
                                                        onChanged: (value) {
                                                          setState(() {
                                                            selectedNghiepDoan = value!.orgName;
                                                            print(selectedNghiepDoan);
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 100),
                                          Expanded(flex: 4, child: Container()),
                                        ],
                                      ),
                                      SizedBox(height: 25),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                              flex: 3,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      margin: EdgeInsets.only(bottom: 30),
                                                      child: DatePickerBoxVQ(
                                                          isTime: false,
                                                          label: Text(
                                                            'Từ ngày',
                                                            style: titleWidgetBox,
                                                          ),
                                                          dateDisplay: dateTo,
                                                          selectedDateFunction: (day) {
                                                            setState(() {
                                                              dateFrom = day;
                                                            });
                                                          }),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                          SizedBox(width: 100),
                                          Expanded(
                                            flex: 3,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 2,
                                                  child: Container(
                                                    margin: EdgeInsets.only(bottom: 30),
                                                    child: DatePickerBoxVQ(
                                                        isTime: false,
                                                        label: Text(
                                                          'Đến ngày',
                                                          style: titleWidgetBox,
                                                        ),
                                                        dateDisplay: dateTo,
                                                        selectedDateFunction: (day) {
                                                          setState(() {
                                                            dateTo = day;
                                                          });
                                                        }),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(flex: 1, child: Container()),
                                        ],
                                      ),
                                      SizedBox(height: 25),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
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
                                                textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                              ),
                                              onPressed: () async {
                                                if (dateFrom != null && dateTo != null) {
                                                  print(dateReverse(dateFrom));
                                                  DateTime dateTimeFrom = DateTime.parse(dateReverse(dateFrom));
                                                  DateTime dateTimeTo = DateTime.parse(dateReverse(dateTo));
                                                  if (dateTimeFrom.isAfter(dateTimeTo)) {
                                                    showToast(
                                                        context: context,
                                                        msg: "Từ ngày phải nhỏ hơn đến ngày !",
                                                        color: Color.fromARGB(134, 251, 8, 8),
                                                        icon: Icon(Icons.warning_amber_outlined));
                                                    return;
                                                  }
                                                }
                                                handleClickBtnSearch(
                                                    order: _orderController.text, orgName: selectedNghiepDoan, companyName: selectedXiNghiep, dateFrom: dateFrom, dateTo: dateTo);
                                                // print(handleClickBtnSearch);
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
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // --------------------table--------------------
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
                                          Text('Thông tin lịch bay', style: titleBox),
                                          Text('Số lượng lịch bay : $totalElements', style: titleBox),
                                        ],
                                      ),
                                      //Đường line
                                      Container(
                                        margin: EdgeInsets.only(top: 10),
                                        child: Divider(thickness: 1, color: ColorHorizontalLine),
                                      ),
                                      !_setLoading
                                          ? Column(
                                              children: [
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
                                                                  columnSpacing: 5,
                                                                  showCheckboxColumn: false,
                                                                  dataRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                                                                    if (states.contains(MaterialState.selected)) {
                                                                      return MaterialStateColor.resolveWith((states) => const Color(0xffeef3ff));
                                                                    }
                                                                    return MaterialStateColor.resolveWith((states) => Colors.white); // Use the default value.
                                                                  }),
                                                                  columns: <DataColumn>[
                                                                    DataColumn(label: Text('STT', style: titleTableData)),
                                                                    DataColumn(label: Text('Mã Đơn hàng', style: titleTableData)),
                                                                    DataColumn(label: Text('Tên đơn hàng', style: titleTableData)),
                                                                    DataColumn(label: Text('Thời gian \n xuất cảnh', style: titleTableData)),
                                                                    DataColumn(label: Text('Tên nghiệp đoàn', style: titleTableData)),
                                                                    DataColumn(label: Text('Tên xí nghiệp', style: titleTableData)),
                                                                    DataColumn(label: Text('Hành động', style: titleTableData)),
                                                                  ],
                                                                  rows: <DataRow>[
                                                                    for (int i = 0; i < listFlightSchedules.length; i++)
                                                                      DataRow(
                                                                        cells: <DataCell>[
                                                                          DataCell(Text("${(currentPage - 1) * rowPerPage + i + 1}", style: bangDuLieu)),
                                                                          DataCell(
                                                                            Tooltip(
                                                                                message: listFlightSchedules[i].oder!.orderCode.toString(),
                                                                                child: Text(listFlightSchedules[i].oder!.orderCode, style: bangDuLieu)),
                                                                          ),
                                                                          DataCell(
                                                                            Container(
                                                                                width: (MediaQuery.of(context).size.width / 10) * 0.8,
                                                                                child: Tooltip(
                                                                                  message: listFlightSchedules[i].oder!.orderName.toString(),
                                                                                  child: Text(
                                                                                    listFlightSchedules[i].oder!.orderName,
                                                                                    style: bangDuLieu,
                                                                                    maxLines: 2,
                                                                                    softWrap: true,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                  ),
                                                                                )),
                                                                          ),
                                                                          //
                                                                          DataCell(Text(
                                                                            (listFlightSchedules[i].flightDate != null)
                                                                                ? DateFormat('dd-MM-yyyy').format(listFlightSchedules[i].flightDate)
                                                                                : "",
                                                                            style: bangDuLieu,
                                                                            maxLines: 2,
                                                                            overflow: TextOverflow.ellipsis,
                                                                          )),
                                                                          DataCell(
                                                                            Tooltip(
                                                                              message: listFlightSchedules[i].oder!.union!.orgName.toString(),
                                                                              child: Text(
                                                                                listFlightSchedules[i].oder!.union!.orgName.toString(),
                                                                                style: bangDuLieu,
                                                                                maxLines: 2,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          DataCell(
                                                                            Tooltip(
                                                                              message: listFlightSchedules[i].oder!.enterprise!.companyName.toString(),
                                                                              child: Text(
                                                                                listFlightSchedules[i].oder!.enterprise!.companyName,
                                                                                style: bangDuLieu,
                                                                                maxLines: 2,
                                                                                overflow: TextOverflow.ellipsis,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          DataCell(Row(
                                                                            children: [
                                                                              getRule(listRule.data, Role.Xem, context)
                                                                                  ? Container(
                                                                                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                                      child: InkWell(
                                                                                          onTap: () {
                                                                                            idLichBay = listFlightSchedules[i].id.toString();
                                                                                            navigationModel.add(pageUrl: (urlThongTinLB + "/$idLichBay"));
                                                                                          },
                                                                                          child: Icon(Icons.visibility)))
                                                                                  : Container(),
                                                                            ],
                                                                          )),
                                                                        ],
                                                                        selected: _selected[i],
                                                                        onSelectChanged: (bool? value) {
                                                                          setState(() {
                                                                            _selected[i] = value!;
                                                                          });
                                                                        },
                                                                      )
                                                                  ],
                                                                ))));
                                                  }),
                                              ],
                                            )
                                          : Center(
                                              child: const CircularProgressIndicator(),
                                            ),
                                      Container(
                                        margin: const EdgeInsets.only(right: 50),
                                        child: DynamicTablePagging(
                                          rowCount,
                                          currentPage,
                                          rowPerPage,
                                          pageChangeHandler: (page) {
                                            setState(() {
                                              getListFlightSchedules(page - 1, context,
                                                  order: _orderController.text, companyName: selectedXiNghiep, orgName: selectedNghiepDoan, dateFrom1: dateFrom, dateTo1: dateTo);
                                              currentPage = page - 1;
                                            });
                                          },
                                          rowPerPageChangeHandler: (rowPerPage) {
                                            setState(() {
                                              this.rowPerPage = rowPerPage!;
                                              //coding
                                              this.firstRow = page * currentPage;
                                              getListFlightSchedules(page - 1, context,
                                                  order: _orderController.text, companyName: selectedXiNghiep, orgName: selectedNghiepDoan, dateFrom1: dateFrom, dateTo1: dateTo);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ]);
                      },
                    )
                  : Center(
                      child: const CircularProgressIndicator(),
                    ),
            );
          } else if (listRule.hasError) {
            return Text('${listRule.error}');
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
