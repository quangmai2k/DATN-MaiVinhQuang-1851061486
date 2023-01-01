// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/toast.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';
import '../../../utils/market_development.dart';

import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/style.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/market_development/union.dart';
import '../../../../model/market_development/xinghiep.dart';
import '../../../../model/model.dart';
import '../../../../model/type.dart';
import '../../navigation.dart';

class ExamSchedule extends StatelessWidget {
  ExamSchedule({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: ExamScheduleBody());
  }
}

class ExamScheduleBody extends StatefulWidget {
  const ExamScheduleBody({Key? key}) : super(key: key);

  @override
  State<ExamScheduleBody> createState() => _ExamScheduleBodyState();
}

class _ExamScheduleBodyState extends State<ExamScheduleBody> {
  //url trang them moi cap nhat quan lys thong tin tts
  String? dateFrom;
  String? dateTo;
  var firstRow = 0;
  var rowPerPage = 10;
  var totalElements = 0;
  var currentPage = 0;
  final String urlAdd = "/them-moi-lich-thi-tuyen";
  late List<TableDSTTS> listSelectedRow;

  int? selectedXiNghiep;

  int? selectedNghiepDoan;

  var idLichThiTuyen;
  Widget paging = Container();
  var resultLTT;
  late Future<dynamic> futureLTT;
  DateTime selectedDate = DateTime.now();
  TextEditingController tenDH = TextEditingController();
  bool _setLoading1 = false;
  String searchLTT = "";

  List<UnionObj> listUnionObj = [];
  List<Enterprise> listEnterprise = [];

  Future<List<Enterprise>> getListXiNghiepSearchBy(context, {key}) async {
    List<Enterprise> list = [];
    var response;
    String condition = "";
    if (key != null) {
      condition += "nghiepdoan.id:$key";
    }
    response = await httpGet("/api/xinghiep/get/page?sort=id&filter=$condition", context);

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
    response = await httpGet("/api/nghiepdoan/get/page", context);
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
    list.insert(0, union);
    setState(() {
      listUnionObj = list;
    });
    return list;
  }

  Future<dynamic> getLTT(page, String searchLTT) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response;
    if (searchLTT == "") {
      response = await httpGet("/api/lichthituyen/get/page?page=$page&size=$rowPerPage&sort=id,desc", context);
    } else
      response = await httpGet("/api/lichthituyen/get/page?page=$page&size=$rowPerPage&sort=id,desc&filter=$searchLTT", context);
    if (response.containsKey("body")) {
      setState(() {
        currentPage = page;
        resultLTT = jsonDecode(response["body"]);
        totalElements = resultLTT["totalElements"];
      });
    }
    return resultLTT;
  }

  deleteLTT(idLichThiTuyen) async {
    var response = await httpDelete("/api/lichthituyen/del/$idLichThiTuyen", context);
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
  }

  initData() async {
    await getListUnionSearchBy(context);
    await getListXiNghiepSearchBy(context);
    futureLTT = getLTT(currentPage, searchLTT);
    setState(() {
      _setLoading1 = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    var curentUser = Provider.of<SecurityModel>(context, listen: false).userLoginCurren;
    return FutureBuilder<dynamic>(
        future: userRule(curentUser['departId'] == 5 ? '/lich-thi-tuyen' : '/lich-thi-tuyen-ttdt', context),
        builder: (context, listRule) {
          if (listRule.hasData) {
            return Consumer<NavigationModel>(
              builder: (context, navigationModel, child) => ListView(controller: ScrollController(), children: [
                TitlePage(
                  listPreTitle: [
                    {'url': '/phat-trien-thi-truong', 'title': 'Dashboard'},
                    {'url': '/lich-thi-tuyen', 'title': 'Lịch thi tuyển'}
                  ],
                  content: 'Lịch thi tuyển',
                ),
                _setLoading1
                    ? FutureBuilder(
                        future: futureLTT,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var tableIndex = (currentPage) * rowPerPage + 1;

                            if (resultLTT["content"].length > 0) {
                              var firstRow = (currentPage) * rowPerPage + 1;
                              var lastRow = (currentPage + 1) * rowPerPage;
                              if (lastRow > resultLTT["totalElements"]) {
                                lastRow = resultLTT["totalElements"];
                              }
                              paging = Row(
                                children: [
                                  Expanded(flex: 1, child: Container()),
                                  const Text("Số dòng trên trang: "),
                                  DropdownButton<int>(
                                    value: rowPerPage,
                                    icon: const Icon(Icons.keyboard_arrow_down),
                                    elevation: 16,
                                    style: const TextStyle(color: Colors.deepPurple),
                                    underline: Container(
                                      height: 2,
                                      color: Colors.deepPurpleAccent,
                                    ),
                                    onChanged: (int? newValue) {
                                      setState(() {
                                        rowPerPage = newValue!;
                                        getLTT(currentPage, searchLTT);
                                      });
                                    },
                                    items: <int>[5, 10, 25, 50, 100].map<DropdownMenuItem<int>>((int value) {
                                      return DropdownMenuItem<int>(
                                        value: value,
                                        child: Text("$value"),
                                      );
                                    }).toList(),
                                  ),
                                  Text("Dòng $firstRow - $lastRow của ${resultLTT["totalElements"]}"),
                                  IconButton(
                                      onPressed: firstRow != 1
                                          ? () {
                                              getLTT(currentPage - 1, searchLTT);
                                            }
                                          : null,
                                      icon: const Icon(Icons.chevron_left)),
                                  IconButton(
                                      onPressed: lastRow < resultLTT["totalElements"]
                                          ? () {
                                              getLTT(currentPage + 1, searchLTT);
                                            }
                                          : null,
                                      icon: const Icon(Icons.chevron_right)),
                                ],
                              );
                            }
                            return Container(
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
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                height: 40,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text("Đơn hàng", style: titleWidgetBox),
                                                      flex: 2,
                                                    ),
                                                    Expanded(
                                                      child: TextField(
                                                        controller: tenDH,
                                                        decoration: InputDecoration(
                                                          contentPadding: const EdgeInsets.fromLTRB(10, 7, 5, 0),
                                                          filled: true,
                                                          fillColor: Colors.white,
                                                          enabledBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(0),
                                                            borderSide: BorderSide(color: Colors.black, width: 0.5),
                                                          ),
                                                          focusedBorder: OutlineInputBorder(
                                                            borderRadius: BorderRadius.circular(0),
                                                            borderSide: BorderSide(color: Colors.black, width: 0.5),
                                                          ),
                                                        ),
                                                      ),
                                                      flex: 5,
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
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(flex: 2, child: Text('Xí nghiệp', style: titleWidgetBox)),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Container(
                                                        height: 40,
                                                        child: DropdownSearch<Enterprise>(
                                                          mode: Mode.MENU,
                                                          maxHeight: 300,
                                                          showSearchBox: true,
                                                          items: listEnterprise,
                                                          selectedItem: listEnterprise.first,
                                                          itemAsString: (Enterprise? u) => u!.companyName,
                                                          dropdownSearchDecoration: styleDropDown,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              selectedXiNghiep = value!.id;
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
                                                    Expanded(flex: 2, child: Text('Nghiệp đoàn', style: titleWidgetBox)),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Container(
                                                        height: 40,
                                                        child: DropdownSearch<UnionObj>(
                                                          mode: Mode.MENU,
                                                          maxHeight: 300,
                                                          showSearchBox: true,
                                                          items: listUnionObj,
                                                          selectedItem: listUnionObj.first,
                                                          itemAsString: (UnionObj? u) => u!.orgName!,
                                                          dropdownSearchDecoration: styleDropDown,
                                                          onChanged: (value) {
                                                            selectedNghiepDoan = value!.id;
                                                            getListXiNghiepSearchBy(context, key: selectedNghiepDoan);
                                                            setState(() {});
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
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: DatePickerBoxCustomForMarkert(
                                                  title: "Từ ngày",
                                                  isTime: false,
                                                  isBlocDate: false,
                                                  isNotFeatureDate: true,
                                                  label: Row(
                                                    children: [
                                                      Text(
                                                        'Từ ngày',
                                                        style: titleWidgetBox,
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(left: 5),
                                                        child: Text(
                                                          "*",
                                                          style: TextStyle(color: Colors.red, fontSize: 16),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  dateDisplay: dateFrom,
                                                  selectedDateFunction: (day) {
                                                    setState(() {
                                                      dateFrom = day;
                                                    });
                                                  }),
                                            ),
                                            SizedBox(width: 100),
                                            Expanded(
                                              flex: 3,
                                              child: DatePickerBoxCustomForMarkert(
                                                  title: "Đến ngày",
                                                  isTime: false,
                                                  isBlocDate: false,
                                                  isNotFeatureDate: true,
                                                  label: Row(
                                                    children: [
                                                      Text(
                                                        'Đến ngày',
                                                        style: titleWidgetBox,
                                                      ),
                                                      Container(
                                                        margin: EdgeInsets.only(left: 5),
                                                        child: Text(
                                                          "*",
                                                          style: TextStyle(color: Colors.red, fontSize: 16),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  dateDisplay: dateTo,
                                                  selectedDateFunction: (day) {
                                                    setState(() {
                                                      dateTo = day;
                                                    });
                                                  }),
                                            ),
                                            Expanded(flex: 1, child: Container()),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 25,
                                        ),

                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(30, 30, 0, 0),
                                          child: Row(
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
                                                    textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                                                  ),
                                                  onPressed: () {
                                                    searchLTT = "";
                                                    var title = "";
                                                    var xiNghiep = "";
                                                    var nghiepDoan = "";
                                                    var time1 = "";
                                                    var time2 = "";
                                                    if (tenDH.text != "") {
                                                      title = "and donhang.orderName~'*${tenDH.text}*' ";
                                                    } else
                                                      title = "";

                                                    if (selectedXiNghiep != null && selectedXiNghiep != -1) {
                                                      xiNghiep = "and donhang.companyId:$selectedXiNghiep ";
                                                    } else
                                                      xiNghiep = "";

                                                    if (selectedNghiepDoan != null && selectedNghiepDoan != -1)
                                                      nghiepDoan = "and donhang.orgId:$selectedNghiepDoan ";
                                                    else
                                                      nghiepDoan = "";

                                                    if (dateFrom != null) {
                                                      time1 = "and examDate>:'$dateFrom' ";
                                                    } else
                                                      time1 = "";
                                                    if (dateTo != null) {
                                                      int a = int.parse(dateTo.toString().substring(0, 2));
                                                      if (a > 9)
                                                        time2 = "and examDate<:'${a + 1}${dateTo.toString().substring(2)}' ";
                                                      else
                                                        time2 = "and examDate<:'0${a + 1}${dateTo.toString().substring(2)}' ";
                                                    } else
                                                      time2 = "";

                                                    searchLTT = title + nghiepDoan + xiNghiep + time1 + time2;
                                                    if (searchLTT != "") if (searchLTT.substring(0, 3) == "and") searchLTT = searchLTT.substring(4);
                                                    getLTT(currentPage, searchLTT);
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
                                                          textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                                                        ),
                                                        onPressed: () {
                                                          navigationModel.add(pageUrl: urlAdd);
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
                                      ],
                                    ),
                                  ),
                                  Builder(builder: (context) {
                                    return Container(
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
                                                  'Thông tin lịch thi tuyển',
                                                  style: titleBox,
                                                ),
                                                Text('Số lượng : $totalElements', style: titleBox),
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
                                                      Expanded(child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                                                        return Center(
                                                            child: SingleChildScrollView(
                                                          scrollDirection: Axis.horizontal,
                                                          child: ConstrainedBox(
                                                            constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                                            child: DataTable(
                                                              showCheckboxColumn: false,
                                                              columnSpacing: 5,
                                                              horizontalMargin: 0,
                                                              dataRowHeight: 60,
                                                              columns: [
                                                                DataColumn(label: Text('STT', style: titleTableData)),
                                                                DataColumn(label: Text('Mã đơn hàng', style: titleTableData)),
                                                                DataColumn(label: Text('Tên đơn hàng', style: titleTableData)),
                                                                DataColumn(label: Text('Thời gian\n thi tuyển', style: titleTableData)),
                                                                // DataColumn(label: Text('Nội dung', style: titleTableData)),
                                                                DataColumn(label: Text('Nghiệp đoàn', style: titleTableData)),
                                                                DataColumn(label: Text('Xí nghiệp', style: titleTableData)),
                                                                DataColumn(label: Text('Công ty', style: titleTableData)),
                                                                DataColumn(label: Text('Số lượng TTS', style: titleTableData)),
                                                                DataColumn(label: Text('Hành động', style: titleTableData)),
                                                              ],
                                                              rows: <DataRow>[
                                                                for (int i = 0; i < resultLTT["content"].length; i++)
                                                                  DataRow(
                                                                    cells: <DataCell>[
                                                                      DataCell(Container(
                                                                        width: (MediaQuery.of(context).size.width / 10) * 0.2,
                                                                        child: Text(
                                                                          "${tableIndex + i}",
                                                                          style: bangDuLieu,
                                                                          textAlign: TextAlign.center,
                                                                        ),
                                                                      )),
                                                                      DataCell(
                                                                        Container(
                                                                          width: (MediaQuery.of(context).size.width / 10) * 0.85,
                                                                          child: Tooltip(
                                                                            message: "${resultLTT["content"][i]["donhang"]["orderCode"].toString()}",
                                                                            child: Text(
                                                                              (resultLTT["content"][i]["donhang"] != null
                                                                                  ? resultLTT["content"][i]["donhang"]["orderCode"].toString()
                                                                                  : " "),
                                                                              style: bangDuLieu,
                                                                              maxLines: 3,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        Container(
                                                                          width: (MediaQuery.of(context).size.width / 10) * 1,
                                                                          child: Tooltip(
                                                                            message: "${resultLTT["content"][i]["donhang"]["orderName"]}",
                                                                            child: Text(
                                                                              (resultLTT["content"][i]["donhang"] != null ? resultLTT["content"][i]["donhang"]["orderName"] : " "),
                                                                              style: bangDuLieu,
                                                                              maxLines: 3,
                                                                              overflow: TextOverflow.ellipsis,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        Container(
                                                                          width: (MediaQuery.of(context).size.width / 10) * 0.6,
                                                                          child: Text(
                                                                            (resultLTT["content"][i]["examDate"] != null
                                                                                ? getDateViewDayAndHour(resultLTT["content"][i]["examDate"])
                                                                                : " "),
                                                                            style: bangDuLieu,
                                                                            maxLines: 3,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        Container(
                                                                          width: (MediaQuery.of(context).size.width / 10) * 0.85,
                                                                          child: Text(
                                                                            (resultLTT["content"][i]["donhang"] != null
                                                                                ? resultLTT["content"][i]["donhang"]["nghiepdoan"]["orgName"]
                                                                                : " "),
                                                                            style: bangDuLieu,
                                                                            maxLines: 3,
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        Container(
                                                                          width: (MediaQuery.of(context).size.width / 10) * 0.85,
                                                                          child: Text(
                                                                            (resultLTT["content"][i]["donhang"] != null
                                                                                ? resultLTT["content"][i]["donhang"]["xinghiep"]["companyName"]
                                                                                : " "),
                                                                            style: bangDuLieu,
                                                                            maxLines: 3,
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        Container(
                                                                          width: (MediaQuery.of(context).size.width / 10) * 0.85,
                                                                          child: Text(
                                                                            (resultLTT["content"][i]["donhang"]["nghiepdoan"]['phongban'] != null
                                                                                ? resultLTT["content"][i]["donhang"]["nghiepdoan"]['phongban']['departName'].toString()
                                                                                : " "),
                                                                            style: bangDuLieu,
                                                                            maxLines: 3,
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        Container(
                                                                          width: (MediaQuery.of(context).size.width / 10) * 0.85,
                                                                          child: Text(
                                                                            resultLTT["content"][i]['countTts'].toString(),
                                                                            style: bangDuLieu,
                                                                            maxLines: 3,
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataCell(Row(
                                                                        children: [
                                                                          getRule(listRule.data, Role.Xem, context)
                                                                              ? Container(
                                                                                  margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                                  child: InkWell(
                                                                                    onTap: () {
                                                                                      idLichThiTuyen = resultLTT["content"][i]["id"].toString();
                                                                                      Provider.of<NavigationModel>(context, listen: false)
                                                                                          .add(pageUrl: ("/xem-chi-tiet-lich-thi-tuyen" + "/$idLichThiTuyen"));
                                                                                    },
                                                                                    child: Icon(Icons.visibility),
                                                                                  ),
                                                                                )
                                                                              : Container(),
                                                                          getRule(listRule.data, Role.Sua, context)
                                                                              ? Container(
                                                                                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                                  child: Tooltip(
                                                                                    message: resultLTT["content"][i]["status"] != 1 ? "" : "Đã kết thúc thi tuyển",
                                                                                    child: InkWell(
                                                                                        onTap: resultLTT["content"][i]["status"] != 1
                                                                                            ? () {
                                                                                                idLichThiTuyen = resultLTT["content"][i]["id"].toString();
                                                                                                Provider.of<NavigationModel>(context, listen: false)
                                                                                                    .add(pageUrl: "/cap-nhat-lich-thi-tuyen" + "/$idLichThiTuyen");
                                                                                              }
                                                                                            : null,
                                                                                        child: Icon(Icons.edit_calendar,
                                                                                            color: resultLTT["content"][i]["status"] != 1 ? Color(0xff009C87) : Colors.grey)),
                                                                                  ))
                                                                              : Container(),
                                                                          getRule(listRule.data, Role.Xoa, context)
                                                                              ? Container(
                                                                                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                                  child: Tooltip(
                                                                                    message: resultLTT["content"][i]["status"] != 1 ? "" : "Đã kết thúc thi tuyển",
                                                                                    child: InkWell(
                                                                                        onTap: resultLTT["content"][i]["status"] != 1
                                                                                            ? () async {
                                                                                                idLichThiTuyen = resultLTT["content"][i]["id"];
                                                                                                showDialog(
                                                                                                  context: context,
                                                                                                  builder: (BuildContext context) => XacNhanXoaLTT(
                                                                                                    label: "Bạn có muốn xóa lịch thi tuyển này ?",
                                                                                                    function: () async {
                                                                                                      await deleteLTT(idLichThiTuyen);
                                                                                                      setState(() {
                                                                                                        getLTT(currentPage, searchLTT);
                                                                                                      });
                                                                                                    },
                                                                                                  ),
                                                                                                );
                                                                                              }
                                                                                            : null,
                                                                                        child: Icon(
                                                                                          Icons.delete_outlined,
                                                                                          color: resultLTT["content"][i]["status"] != 1 ? Colors.red : Colors.grey,
                                                                                        )),
                                                                                  ))
                                                                              : Container(),
                                                                        ],
                                                                      )),
                                                                    ],
                                                                  )
                                                              ],
                                                            ),
                                                          ),
                                                        ));
                                                      }))
                                                    ],
                                                  ),
                                                  if (totalElements != 0)
                                                    paging
                                                  else
                                                    Center(
                                                        child: Text("Không có kết quả phù hợp",
                                                            style: TextStyle(
                                                              fontSize: 15,
                                                            ))),
                                                ],
                                              ),
                                            ),
                                            Footer()
                                          ],
                                        ));
                                  }),
                                ],
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          }
                          return const Center(child: CircularProgressIndicator());
                        })
                    : Center(
                        child: const CircularProgressIndicator(),
                      ),
              ]),
            );
          } else if (listRule.hasError) {
            return Text('${listRule.error}');
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}

// --------------Thông báo xóa lịch thi tuyển----------

class XacNhanXoaLTT extends StatefulWidget {
  final Function function;
  final String? label;
  XacNhanXoaLTT({Key? key, required this.function, this.label}) : super(key: key);
  @override
  State<XacNhanXoaLTT> createState() => _XacNhanXoaLTTState();
}

class _XacNhanXoaLTTState extends State<XacNhanXoaLTT> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  child: Image.asset(
                    "assets/images/logoAAM.png",
                    width: 30,
                    height: 30,
                  ),
                  margin: EdgeInsets.only(right: 10),
                ),
                Text(
                  "Xác nhận xóa lịch thi tuyển ?",
                  style: titleAlertDialog,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
          ),
        ],
      ),
      content: Container(
        height: 100,
        width: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: Divider(
                thickness: 1,
              ),
            ),
            Text(
              widget.label != null ? widget.label! : "Bạn có chắc chắn muốn hủy chức năng này?",
            ),
            Padding(
              padding: const EdgeInsets.all(0),
              child: Divider(
                thickness: 1,
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          // textColor: Color(0xFF6200EE),
          onPressed: () => Navigator.pop(context),
          child: Text('Hủy'),
          style: ElevatedButton.styleFrom(
            primary: Color.fromRGBO(245, 117, 29, 1),
            onPrimary: colorWhite,
            elevation: 3,
            minimumSize: Size(140, 50),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            widget.function();
            Navigator.pop(context);
          },
          child: Text(
            'Đồng ý',
            style: TextStyle(),
          ),
          style: ElevatedButton.styleFrom(
            primary: colorBlueBtnDialog,
            onPrimary: colorWhite,
            elevation: 3,
            minimumSize: Size(140, 50), //////// HERE
          ),
        ),
      ],
    );
  }
}
