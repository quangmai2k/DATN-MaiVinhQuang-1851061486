import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/format_date.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/form.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:gentelella_flutter/widgets/utils/market_development.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/market_development/lichthisat.dart';
import '../../../../model/model.dart';
import 'dart:async';

import '../3-enterprise_manager/enterprise_manager.dart';

class InspectionCalendar extends StatefulWidget {
  const InspectionCalendar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _InspectionCalendarState();
  }
}

class _InspectionCalendarState extends State<InspectionCalendar> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: InspectionCalendarBody());
  }
}

class InspectionCalendarBody extends StatefulWidget {
  const InspectionCalendarBody({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _InspectionCalendarBodyState();
  }
}

class _InspectionCalendarBodyState extends State<InspectionCalendarBody> {
  final String urlAdd = "/them-moi-lich-thi-sat";
  final String urlJobDetail = "/lich-thi-sat/chi-tiet";
  var body = {};
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  bool _setLoading = false;
  late Future<List<InspectionCalendars>> _futureInspectionCalendars;
  List<InspectionCalendars> listInspectionCalendar = [];

  int? _selectedStatus;
  //List<String> _listStatus = ['Tất cả', 'Đã thị sát', 'Chờ thực hiện'];
  Map<int, String> _listStatus = {
    -1: "Tất cả",
    0: "Chờ thực hiện",
    1: "Đã thị sát",
  };

  TextEditingController unionController = TextEditingController();
  String? dateFrom;
  String? dateTo;

  Future<List<InspectionCalendars>> getListInspectionCalendarsSearchBy(page, {union, status, dateFrom, dateTo}) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response;

    String condition = "";

    if (union != null) {
      condition += " ( nghiepdoan.orgCode~'*$union*' ";

      condition += " OR nghiepdoan.orgName~'*$union*' )";
    }

    if (dateFrom != null) {
      condition += " AND dateFrom >: '$dateFrom'  ";
    }
    if (dateTo != null && dateFrom.toString().isNotEmpty) {
      condition += " AND dateTo <: '$dateTo'  ";
    }

    if (status != null && status != -1) {
      condition += " AND status:$status";
    }
    print(condition);
    response = await httpGet("/api/lichthisat/get/page?page=$page&size=$rowPerPage&filter=$condition", context);

    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        currentPage = page + 1;
        content = body['content'];
        rowCount = body["totalElements"];
        totalElements = body["totalElements"];
        lastRow = totalElements;
        listInspectionCalendar = content.map((e) {
          return InspectionCalendars.fromJson(e);
        }).toList();
      });
    }

    return content.map((e) {
      return InspectionCalendars.fromJson(e);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _futureInspectionCalendars = getListInspectionCalendarsSearchBy(
      page - 1,
    );
  }

  String getNameStatusByStatus(int status) {
    if (status == 0) {
      return "Chờ thực hiện";
    } else if (status == 1) {
      return "Đã thị sát";
    } else if (status == 2) {
      return "Hủy";
    }
    return "Nodata!";
  }

  handleClickBtnSearch({union, status, dateFrom, dateTo}) {
    print("clicked");
    setState(() {
      _setLoading = true;
    });

    Future<List<InspectionCalendars>> _futureInspectionCalendars1 = getListInspectionCalendarsSearchBy(0, union: union, status: status, dateFrom: dateFrom, dateTo: dateTo);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _futureInspectionCalendars = _futureInspectionCalendars1;
        _setLoading = false;
      });
    });
  }

  deleteLichThiSat(id) async {
    var response = await httpDelete("/api/lichthisat/del/$id", context);
    print(response);
    var body = jsonDecode(response['body']);
    if (body) {
      showToast(context: context, msg: "Xóa thành công !", color: Colors.green, icon: Icon(Icons.abc));
    } else {
      showToast(context: context, msg: "Xóa thất bại !", color: Colors.red, icon: Icon(Icons.abc));
    }
    // if (body.containsKey("1")) {
    //   showToast(context: context, msg: body['1'], color: Colors.green, icon: Icon(Icons.abc));
    // } else {
    //   showToast(context: context, msg: body['0'], color: Colors.red, icon: Icon(Icons.abc));
    // }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: userRule(Provider.of<SecurityModel>(context, listen: false).userLoginCurren['departId'] == 7 ? "/view-lich-thi-sat" : '/lich-thi-sat', context),
        builder: (context, listRule) {
          if (listRule.hasData) {
            return Consumer<NavigationModel>(
                builder: (context, navigationModel, child) => FutureBuilder<List<InspectionCalendars>>(
                    future: _futureInspectionCalendars,
                    builder: (context, snapshot) {
                      return ListView(
                        children: [
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
                                {'url': '/lich-thi-sat', 'title': 'Lịch thị sát'}
                              ],
                              content: 'Lịch thị sát',
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
                                      child: Column(children: [
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
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Container(
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        child: TextFieldValidatedMarket(
                                                          type: "None",
                                                          labe: "Nghiệp đoàn",
                                                          isReverse: false,
                                                          flexLable: 2,
                                                          flexTextField: 5,
                                                          marginBottom: 0,
                                                          controller: unionController,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              SizedBox(width: 100),
                                              Expanded(
                                                flex: 3,
                                                child: Container(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text('Trạng thái', style: titleWidgetBox),
                                                      ),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Container(
                                                          color: Colors.white,
                                                          width: MediaQuery.of(context).size.width * 1,
                                                          height: 40,
                                                          child: DropdownButtonHideUnderline(
                                                            child: DropdownButton2(
                                                              isExpanded: true,
                                                              hint: Row(
                                                                children: [
                                                                  Text(
                                                                    _listStatus[-1].toString(),
                                                                    style: const TextStyle(
                                                                      fontWeight: FontWeight.bold,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              items: _listStatus.entries
                                                                  .map((item) => DropdownMenuItem<int>(
                                                                        value: item.key,
                                                                        child: Text(
                                                                          item.value,
                                                                        ),
                                                                      ))
                                                                  .toList(),
                                                              value: _selectedStatus,
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  _selectedStatus = value as int;
                                                                });
                                                                print(value as int);
                                                              },
                                                              dropdownDecoration: BoxDecoration(border: Border.all(color: const Color.fromRGBO(216, 218, 229, 1))),
                                                              buttonDecoration: BoxDecoration(border: Border.all(width: 0.5, style: BorderStyle.solid)),
                                                              buttonElevation: 0,
                                                              buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                                                              itemPadding: const EdgeInsets.only(left: 14, right: 14),
                                                              dropdownElevation: 5,
                                                              focusColor: Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(flex: 2, child: Container()),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Container(
                                                        margin: EdgeInsets.only(bottom: 30),
                                                        child: DatePickerBoxCustomForMarkert(
                                                            requestDayBefore: dateTo,
                                                            isTime: false,
                                                            title: "Từ ngày",
                                                            isBlocDate: false,
                                                            isNotFeatureDate: true,
                                                            label: Text(
                                                              'Từ ngày',
                                                              style: titleWidgetBox,
                                                            ),
                                                            dateDisplay: dateFrom,
                                                            selectedDateFunction: (day) {
                                                              dateFrom = day;
                                                              setState(() {});
                                                            }),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(width: 100),
                                              Expanded(
                                                flex: 3,
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Container(
                                                        margin: EdgeInsets.only(bottom: 30),
                                                        child: DatePickerBoxCustomForMarkert(
                                                            isTime: false,
                                                            requestDayAfter: dateFrom,
                                                            title: "Đến ngày",
                                                            isBlocDate: false,
                                                            isNotFeatureDate: true,
                                                            label: Text(
                                                              'Đến ngày',
                                                              style: titleWidgetBox,
                                                            ),
                                                            dateDisplay: dateTo,
                                                            selectedDateFunction: (day) {
                                                              dateTo = day;
                                                              setState(() {});
                                                            }),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(flex: 2, child: Container()),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.fromLTRB(50, 50, 20, 0),
                                            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
                                                  onPressed: () {
                                                    if (dateFrom != null && dateTo != null) {
                                                      if (!DateFormat('dd-MM-yyyy').parse(dateFrom!).isBefore(DateFormat('dd-MM-yyyy').parse(dateTo!))) {
                                                        showToast(context: context, msg: "Từ ngày phải nhỏ hơn Đến ngày !", color: Colors.redAccent, icon: Icon(Icons.error));
                                                        return;
                                                      }
                                                    }

                                                    handleClickBtnSearch(union: unionController.text, status: _selectedStatus, dateFrom: dateFrom, dateTo: dateTo);
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
                                                          textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                        ),
                                                        onPressed: () {
                                                          navigationModel.add(pageUrl: urlAdd);
                                                        },
                                                        icon: Transform.rotate(
                                                          angle: 0,
                                                          child: Icon(
                                                            Icons.add,
                                                            color: Colors.white,
                                                            size: 15,
                                                          ),
                                                        ),
                                                        label: Row(
                                                          children: [
                                                            Text('Thêm mới', style: textButton),
                                                          ],
                                                        ),
                                                      ))
                                                  : Container(),
                                            ])),
                                      ])),
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
                                              'Lịch thị sát của các nghiệp đoàn',
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
                                        if (snapshot.hasData)
                                          //Start Datatable
                                          !_setLoading
                                              ? Row(
                                                  children: [
                                                    Expanded(child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                                                      return Center(
                                                          child: SingleChildScrollView(
                                                        scrollDirection: Axis.horizontal,
                                                        child: ConstrainedBox(
                                                            constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                                            child: DataTable(
                                                              columnSpacing: 5,
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
                                                                    'Mã nghiệp đoàn',
                                                                    style: titleTableData,
                                                                  ),
                                                                ),
                                                                DataColumn(
                                                                  label: Text(
                                                                    'Tên Nghiệp đoàn',
                                                                    style: titleTableData,
                                                                  ),
                                                                ),
                                                                DataColumn(
                                                                  label: Text(
                                                                    'Từ ngày',
                                                                    style: titleTableData,
                                                                  ),
                                                                ),
                                                                DataColumn(
                                                                  label: Text(
                                                                    'Đến ngày',
                                                                    style: titleTableData,
                                                                  ),
                                                                ),
                                                                DataColumn(
                                                                  label: Text(
                                                                    'Trạng thái',
                                                                    style: titleTableData,
                                                                  ),
                                                                ),
                                                                DataColumn(
                                                                  label: Text(
                                                                    'Thao tác',
                                                                    style: titleTableData,
                                                                  ),
                                                                ),
                                                              ],
                                                              rows: <DataRow>[
                                                                for (int i = 0; i < listInspectionCalendar.length; i++)
                                                                  DataRow(
                                                                    cells: <DataCell>[
                                                                      DataCell(Text("${(currentPage - 1) * rowPerPage + i + 1}")),
                                                                      DataCell(Text(listInspectionCalendar[i].union!.orgCode!)),
                                                                      DataCell(Text(listInspectionCalendar[i].union!.orgName!)),
                                                                      DataCell(Text(getDateViewDayAndHour(listInspectionCalendar[i].dateFrom))),
                                                                      DataCell(Text(getDateViewDayAndHour(listInspectionCalendar[i].dateTo))),
                                                                      DataCell(Text(getNameStatusByStatus(listInspectionCalendar[i].status))),
                                                                      DataCell(Row(
                                                                        children: [
                                                                          getRule(listRule.data, Role.Xem, context)
                                                                              ? Container(
                                                                                  margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                                  child: InkWell(
                                                                                    onTap: () {
                                                                                      navigationModel.add(
                                                                                          pageUrl: "/xem-chi-tiet-lich-thi-sat/" + listInspectionCalendar[i].id.toString());
                                                                                    },
                                                                                    child: Icon(Icons.visibility),
                                                                                  ),
                                                                                )
                                                                              : Container(),
                                                                          getRule(listRule.data, Role.Sua, context)
                                                                              ? Container(
                                                                                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                                  child: Tooltip(
                                                                                    message: listInspectionCalendar[i].status == 1 ? "Đã thi sát" : "",
                                                                                    child: InkWell(
                                                                                        onTap: listInspectionCalendar[i].status != 1
                                                                                            ? () {
                                                                                                navigationModel.add(
                                                                                                    pageUrl: "/cap-nhat-lich-thi-sat/${listInspectionCalendar[i].id}");
                                                                                              }
                                                                                            : null,
                                                                                        child: Icon(
                                                                                          Icons.edit_calendar,
                                                                                          color: listInspectionCalendar[i].status != 1 ? Color(0xff009C87) : Colors.grey,
                                                                                        )),
                                                                                  ))
                                                                              : Container(),
                                                                          getRule(listRule.data, Role.Xoa, context)
                                                                              ? Container(
                                                                                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                                  child: InkWell(
                                                                                      onTap: () {
                                                                                        showDialog(
                                                                                          context: context,
                                                                                          builder: (BuildContext context) => XacNhanXoaXiNghiep(
                                                                                            label: "Bạn có muốn xóa lịch thị sát này ?",
                                                                                            function: () async {
                                                                                              await deleteLichThiSat(listInspectionCalendar[i].id);
                                                                                              await handleClickBtnSearch();
                                                                                            },
                                                                                          ),
                                                                                        );
                                                                                      },
                                                                                      child: Icon(
                                                                                        Icons.delete_outlined,
                                                                                        color: Colors.red,
                                                                                      )))
                                                                              : Container(),
                                                                        ],
                                                                      )),
                                                                    ],
                                                                  ),
                                                              ],
                                                            )),
                                                      ));
                                                    }))
                                                  ],
                                                )
                                              : Center(
                                                  child: CircularProgressIndicator(),
                                                )
                                        else if (snapshot.hasError)
                                          Text("Fail! ${snapshot.error}")
                                        else if (!snapshot.hasData)
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
                                              setState(() async {
                                                await getListInspectionCalendarsSearchBy(page - 1,
                                                    union: unionController.text, status: _selectedStatus, dateFrom: dateFrom, dateTo: dateTo);
                                              });
                                            },
                                            rowPerPageChangeHandler: (rowPerPage) {
                                              setState(() {
                                                this.rowPerPage = rowPerPage!;

                                                getListInspectionCalendarsSearchBy(page - 1,
                                                    union: unionController.text, status: _selectedStatus, dateFrom: dateFrom, dateTo: dateTo);
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Footer(),
                                ],
                              )),
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
