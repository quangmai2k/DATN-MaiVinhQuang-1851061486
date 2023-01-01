// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/config.dart';
import 'package:gentelella_flutter/widgets/forms/nhan_su/setting-data/duty.dart';
import 'package:gentelella_flutter/widgets/forms/nhan_su/setting-data/interview.dart';
import 'package:gentelella_flutter/widgets/forms/nhan_su/setting-data/userAAM.dart';
import 'package:gentelella_flutter/widgets/ui/nhan_su/sua-lpv.dart';
import 'package:gentelella_flutter/widgets/ui/nhan_su/view-lpv.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../api.dart';
import '../../../common/dynamic_table.dart';
import '../../../common/style.dart';
import '../../../common/toast.dart';
import '../../../common/widgets_form.dart';
import '../../../model/model.dart';
import '../../forms/nhan_su/setting-data/depart.dart';
import '../navigation.dart';

class LichPhongVan extends StatefulWidget {
  const LichPhongVan({Key? key}) : super(key: key);

  @override
  _LichPhongVanState createState() => _LichPhongVanState();
}

class _LichPhongVanState extends State<LichPhongVan> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: LichPhongVanBody());
  }
}

class LichPhongVanBody extends StatefulWidget {
  const LichPhongVanBody({Key? key}) : super(key: key);
  @override
  State<LichPhongVanBody> createState() => _LichPhongVanBodyState();
}

class _LichPhongVanBodyState extends State<LichPhongVanBody> {
  List<Interview> listInterViews = [];

  TextEditingController tieuDe = TextEditingController();

  late Future<List<Interview>> getListLPV;
  String findLPV = "";
  var time1;
  var time2;
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  var tableIndex = 1;
  Future<List<Interview>> getLPV(int page, String findLPV) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response5;
    if (findLPV == "")
      response5 = await httpGet("/api/tuyendung-phongvan/get/page?size=$rowPerPage&page=$page&sort=status&sort=interviewTime,desc", context);
    else
      response5 =
          await httpGet("/api/tuyendung-phongvan/get/page?size=$rowPerPage&page=$page&sort=status&sort=interviewTime,desc&filter=$findLPV", context);
    var content = [];
    var resultLPV = jsonDecode(response5["body"]);
    if (response5.containsKey("body")) {
      setState(() {
        listInterViews = [];
        currentPage = page + 1;
        content = resultLPV['content'];
        for (var item in content) {
          Interview e = new Interview();
          e.id = item['id'];
          e.tuyendungId = item['tuyendungId'];
          e.title = item['tuyendung']['title'];
          e.tuyendungChitietId = item['tuyendungChitietId'];
          e.depart = Depart(id: item['tuyendungChitiet']['departId'], departName: item['tuyendungChitiet']['phongban']['departName']);
          e.duty = Duty(
              id: item['tuyendungChitiet']['dutyId'],
              dutyName: item['tuyendungChitiet']['vaitro']['name'],
              departId: item['tuyendungChitiet']['departId']);
          e.qty = item['qty'];
          e.candidateQty = item['candidateQty'] ?? 0;
          e.qtyRecruited = item['qtyRecruited'] ?? 0;
          e.interviewAddress = item['interviewAddress'] ?? "";
          e.interviewTime = item['interviewTime'];
          e.jobDesc = item['jobDesc'] ?? "";
          e.status = item['status'];
          e.interviewComponents = item['interviewComponents'] ?? "";
          e.createUser = UserAAM(
            id: item['recruitmentUser'],
            userCode: (item['nhanvientuyendung'] != null) ? (item['nhanvientuyendung']['userCode']) ?? "" : "",
            fullName: (item['nhanvientuyendung'] != null) ? (item['nhanvientuyendung']['fullName']) ?? "" : "",
          );
          listInterViews.add(e);
        }
        rowCount = resultLPV["totalElements"];
        totalElements = resultLPV["totalElements"];
        lastRow = totalElements;

        rowCount = resultLPV['totalElements'];
        if (content.length > 0) {
          firstRow = (currentPage) * rowPerPage + 1;
          lastRow = (currentPage + 1) * rowPerPage;
          if (lastRow > totalElements) {
            lastRow = totalElements;
          }
          tableIndex = (currentPage - 1) * rowPerPage + 1;
        }
      });
      return listInterViews;
    } else
      throw Exception('Không có data');
  }

  int? selectedBP;
  Future<List<Depart>> getPhongBan() async {
    List<Depart> resultPhongBan = [];
    var response1 = await httpGet("/api/phongban/get/page?sort=id,asc&filter=parentId:0 and id>2 and status:1", context);
    if (response1.containsKey("body")) {
      var body = jsonDecode(response1['body']);
      var content = [];
      setState(() {
        content = body['content'];
        resultPhongBan = content.map((e) {
          return Depart.fromJson(e);
        }).toList();
        Depart all = new Depart(id: -1, departName: "Tất cả");
        resultPhongBan.insert(0, all);
      });
    }
    return resultPhongBan;
  }

  String timecheck = "${DateFormat("dd-MM-yyyy").format(DateTime.now().toLocal())}";
  getLPV2() async {
    var response2 = await httpGet("/api/tuyendung-phongvan/get/page?filter=interviewTime < '$timecheck'", context);

    if (response2.containsKey("body")) {
      setState(() {
        var resultLPV2 = jsonDecode(response2["body"]);
        for (var i = 0; i < resultLPV2['totalElements']; i++) {
          // print(resultLPV2['content'][i]['interviewTime']);
          upDateLPV(resultLPV2['content'][i]['id'], 1);
        }
      });
    }
  }

  upDateLPV(int idLPV, int idTT) async {
    var requestBody = {"status": idTT};
    await httpPut("/api/tuyendung-phongvan/put/$idLPV", requestBody, context);
  }

  @override
  void initState() {
    // getLPV2();
    getListLPV = getLPV(0, findLPV);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/lich-phong-van', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Consumer2<NavigationModel, SecurityModel>(
              builder: (context, navigationModel, user, child) => ListView(
                    controller: ScrollController(),
                    children: [
                      TitlePage(
                        listPreTitle: [
                          {'url': "/nhan-su", 'title': 'Dashboard'},
                          // {'url': "/de-nghi-tuyen-dung", 'title': 'Đề nghị tuyển dụng'},
                        ],
                        content: 'Lịch phỏng vấn',
                      ),
                      Container(
                        // margin: EdgeInsets.only(top: 25),
                        padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nhap thong tin
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
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: TextFieldValidatedForm(
                                              type: 'None',
                                              height: 40,
                                              controller: tieuDe,
                                              label: 'Tiêu đề:',
                                              flexLable: 2,
                                            ),
                                          ),
                                          SizedBox(width: 100),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              margin: EdgeInsets.only(bottom: 30),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 2,
                                                    child: Text('Phòng ban:', style: titleWidgetBox),
                                                  ),
                                                  Expanded(
                                                      flex: 5,
                                                      child: Container(
                                                        color: Colors.white,
                                                        width: MediaQuery.of(context).size.width * 0.20,
                                                        height: 40,
                                                        child: DropdownSearch<Depart>(
                                                          hint: "Tất cả",
                                                          maxHeight: 350,
                                                          mode: Mode.MENU,
                                                          showSearchBox: true,
                                                          onFind: (String? filter) => getPhongBan(),
                                                          itemAsString: (Depart? u) => u!.departName,
                                                          dropdownSearchDecoration: styleDropDown,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              selectedBP = value!.id;
                                                              print(selectedBP);
                                                            });
                                                          },
                                                        ),
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(flex: 1, child: Container()),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: DatePickerBox1(
                                                requestDayBefore: time2,
                                                isTime: false,
                                                label: Text(
                                                  'Từ ngày:',
                                                  style: titleWidgetBox,
                                                ),
                                                dateDisplay: time1,
                                                selectedDateFunction: (day) {
                                                  time1 = day;
                                                  setState(() {});
                                                }),
                                          ),
                                          SizedBox(width: 100),
                                          Expanded(
                                            flex: 3,
                                            child: DatePickerBox1(
                                                requestDayAfter: time1,
                                                isTime: false,
                                                label: Text(
                                                  'Đến ngày:',
                                                  style: titleWidgetBox,
                                                ),
                                                dateDisplay: time1,
                                                selectedDateFunction: (day) {
                                                  time2 = day;
                                                  print(day);
                                                  setState(() {});
                                                }),
                                          ),
                                          Expanded(flex: 1, child: Container()),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(30, 20, 0, 0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            //tìm kiếm
                                            getRule(listRule.data, Role.Xem, context)
                                                ? Container(
                                                    margin: EdgeInsets.only(left: 20),
                                                    child: TextButton(
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
                                                        findLPV = "";
                                                        var title1;
                                                        var idPhongBan = "";
                                                        var tuNgay = "";
                                                        var denNgay = "";
                                                        if (tieuDe.text != "")
                                                          title1 = "and tuyendung.title~'*${tieuDe.text}*' ";
                                                        else
                                                          title1 = "";
                                                        if (selectedBP != null && selectedBP != -1)
                                                          idPhongBan = "and tuyendungChitiet.departId:$selectedBP ";
                                                        else
                                                          idPhongBan = "";
                                                        if (time1 != null)
                                                          tuNgay = "and interviewTime>:'$time1' ";
                                                        else
                                                          tuNgay = "";
                                                        if (time2 != null) {
                                                          denNgay = "and interviewTime<:'$time2 23:59:59' ";
                                                        } else
                                                          denNgay = "";
                                                        findLPV = title1 + idPhongBan + tuNgay + denNgay;

                                                        if (findLPV != "") if (findLPV.substring(0, 3) == "and") findLPV = findLPV.substring(4);

                                                        getLPV(0, findLPV);
                                                        print(findLPV);
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.search, color: colorWhite),
                                                          SizedBox(width: 5),
                                                          Text('Tìm kiếm', style: textButton),
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                            getRule(listRule.data, Role.Them, context)
                                                ? Container(
                                                    margin: marginLeftBtn,
                                                    child: TextButton(
                                                      style: TextButton.styleFrom(
                                                        padding: const EdgeInsets.symmetric(
                                                          vertical: 20.0,
                                                          horizontal: 10.0,
                                                        ),
                                                        backgroundColor: backgroundColorBtn,
                                                        primary: Theme.of(context).iconTheme.color,
                                                        textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                      ),
                                                      onPressed: () {
                                                        Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/them-moi-lpv");
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Icon(Icons.add, color: colorWhite),
                                                          SizedBox(width: 5),
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
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: backgroundPage,
                        padding: EdgeInsets.only(left: 25, right: 25),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 1,
                          // margin: marginTopBoxContainer,
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
                                children: [
                                  Expanded(
                                      child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Thông tin lịch phỏng vấn',
                                            style: titleBox,
                                          ),
                                          Icon(
                                            Icons.more_horiz,
                                            color: Color(0xff9aa5ce),
                                            size: 14,
                                          ),
                                        ],
                                      ),
                                      Container(
                                        margin: marginTopBottomHorizontalLine,
                                        child: Divider(
                                          thickness: 1,
                                          color: ColorHorizontalLine,
                                        ),
                                      ),
                                      Container(
                                          child: FutureBuilder<dynamic>(
                                        future: getListLPV,
                                        builder: (context, snapshot) {
                                          if (snapshot.hasData) {
                                            return Container(
                                              child: Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: DataTable(showCheckboxColumn: false, columnSpacing: 5, columns: [
                                                          DataColumn(label: Text('STT', style: titleTableData)),
                                                          DataColumn(label: Text('Tiêu đề', style: titleTableData)),
                                                          DataColumn(label: Text('Vị trí', style: titleTableData)),
                                                          DataColumn(label: Text('Phòng ban', style: titleTableData)),
                                                          DataColumn(label: Text('SL\nứng\nviên', style: titleTableData)),
                                                          DataColumn(label: Text('SL\ncần', style: titleTableData)),
                                                          DataColumn(label: Text('SL\ntrúng\ntuyển', style: titleTableData)),
                                                          DataColumn(label: Text('Thời gian', style: titleTableData)),
                                                          DataColumn(label: Text('Cán bộ tuyển dụng', style: titleTableData)),
                                                          DataColumn(label: Text('Trạng\nthái', style: titleTableData)),
                                                          DataColumn(label: Text('Hành động', style: titleTableData)),
                                                        ], rows: <DataRow>[
                                                          for (var i = 0; i < listInterViews.length; i++)
                                                            DataRow(
                                                              cells: [
                                                                DataCell(Text(" ${tableIndex + i}")),
                                                                DataCell(TextButton(
                                                                    onPressed: () {
                                                                      Navigator.push(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (context) =>
                                                                                ViewLPVBody(idLPV: listInterViews[i].id.toString())),
                                                                      );
                                                                    },
                                                                    child: Text(listInterViews[i].title.toString()))),
                                                                DataCell(Text(listInterViews[i].duty!.dutyName.toString())),
                                                                DataCell(Text(listInterViews[i].depart!.departName.toString())),
                                                                DataCell(Text(listInterViews[i].candidateQty.toString())),
                                                                DataCell(Text(listInterViews[i].qty.toString())),
                                                                DataCell(Text(listInterViews[i].qtyRecruited.toString())),
                                                                DataCell(Text(
                                                                    "${DateFormat('HH:mm - dd/MM/yyyy').format(DateTime.parse(listInterViews[i].interviewTime.toString()).toLocal())}")),
                                                                DataCell(Text(
                                                                    "${listInterViews[i].createUser!.fullName} - ${listInterViews[i].createUser!.userCode}")),
                                                                DataCell((listInterViews[i].status == 0)
                                                                    ? Tooltip(
                                                                        message: "Chưa phỏng vấn",
                                                                        textStyle: TextStyle(fontSize: 15, color: colorWhite),
                                                                        child: Icon(
                                                                          Icons.pending,
                                                                          size: 20,
                                                                          color: colorOrange,
                                                                        ),
                                                                        verticalOffset: 15)
                                                                    : (listInterViews[i].status == 1)
                                                                        ? Tooltip(
                                                                            message: "Đã phỏng vấn",
                                                                            textStyle: TextStyle(fontSize: 15, color: colorWhite),
                                                                            child: Icon(
                                                                              Icons.check_circle,
                                                                              size: 20,
                                                                              color: mainColorPage,
                                                                            ),
                                                                            verticalOffset: 15)
                                                                        : Tooltip(
                                                                            message: "Hủy",
                                                                            textStyle: TextStyle(fontSize: 15, color: colorWhite),
                                                                            child: Icon(
                                                                              Icons.cancel,
                                                                              size: 20,
                                                                              color: Colors.red,
                                                                            ),
                                                                            verticalOffset: 15)),
                                                                DataCell(Row(
                                                                  children: [
                                                                    getRule(listRule.data, Role.Xem, context)
                                                                        ? Consumer<NavigationModel>(
                                                                            builder: (context, navigationModel, child) => Container(
                                                                                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                                child: InkWell(
                                                                                    onTap: () {
                                                                                      // Provider.of<NavigationModel>(context, listen: false)
                                                                                      //     .add(pageUrl: "/view-lpv" + "/${listInterViews[i].id}");

                                                                                      Navigator.push(
                                                                                        context,
                                                                                        MaterialPageRoute(
                                                                                            builder: (context) =>
                                                                                                ViewLPVBody(idLPV: listInterViews[i].id.toString())),
                                                                                      );
                                                                                    },
                                                                                    child: Icon(Icons.visibility))),
                                                                          )
                                                                        : Text(""),
                                                                    (user.userLoginCurren['departId'] == 2 ||
                                                                            user.userLoginCurren['departId'] == 1 ||
                                                                            (user.userLoginCurren['vaitro'] != null &&
                                                                                user.userLoginCurren['vaitro']['level'] > 0) ||
                                                                            (user.userLoginCurren['id'] == listInterViews[i].createUser!.id))
                                                                        ? Consumer<NavigationModel>(
                                                                            builder: (context, navigationModel, child) => Container(
                                                                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                              child: InkWell(
                                                                                  onTap: () {
                                                                                    Navigator.push(
                                                                                      context,
                                                                                      MaterialPageRoute(
                                                                                          builder: (context) => Updatelpv(
                                                                                                idLPV: listInterViews[i].id.toString(),
                                                                                                interViewData: listInterViews[i],
                                                                                                callback: (value) {
                                                                                                  setState(() {
                                                                                                    listInterViews[i] = value;
                                                                                                  });
                                                                                                },
                                                                                              )),
                                                                                    );
                                                                                  },
                                                                                  child: Icon(Icons.edit_calendar, color: Color(0xff009C87))),
                                                                            ),
                                                                          )
                                                                        : Text(""),
                                                                    (user.userLoginCurren['departId'] == 2 ||
                                                                            user.userLoginCurren['departId'] == 1 ||
                                                                            (user.userLoginCurren['vaitro'] != null &&
                                                                                user.userLoginCurren['vaitro']['level'] > 0) ||
                                                                            (user.userLoginCurren['id'] == listInterViews[i].createUser!.id))
                                                                        ? Consumer<NavigationModel>(
                                                                            builder: (context, navigationModel, child) => Container(
                                                                                margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                                child: InkWell(
                                                                                    onTap: () {
                                                                                      showDialog(
                                                                                          context: context,
                                                                                          builder: (BuildContext context) => AlertDialog(
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
                                                                                                                  'assets/images/logoAAM.png'),
                                                                                                              margin: EdgeInsets.only(right: 10),
                                                                                                            ),
                                                                                                            Text(
                                                                                                              'Xác nhận xóa đề nghị tuyển dụng ',
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
                                                                                                //content
                                                                                                content: Container(
                                                                                                  width: 400,
                                                                                                  height: 150,
                                                                                                  child: Column(
                                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                    children: [
                                                                                                      //đường line
                                                                                                      Container(
                                                                                                        margin: marginTopBottomHorizontalLine,
                                                                                                        child: Divider(
                                                                                                          thickness: 1,
                                                                                                          color: ColorHorizontalLine,
                                                                                                        ),
                                                                                                      ),
                                                                                                      Container(
                                                                                                        child: Text(
                                                                                                            'Xóa lịch phỏng vấn: "${listInterViews[i].title}"'),
                                                                                                      ),
                                                                                                      //đường line
                                                                                                      Container(
                                                                                                        margin: marginTopBottomHorizontalLine,
                                                                                                        child: Divider(
                                                                                                          thickness: 1,
                                                                                                          color: ColorHorizontalLine,
                                                                                                        ),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                                //actions
                                                                                                actions: [
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
                                                                                                  ElevatedButton(
                                                                                                    onPressed: () async {
                                                                                                      var response = await httpDelete(
                                                                                                          "/api/tuyendung-phongvan/del/${listInterViews[i].id}",
                                                                                                          context);
                                                                                                      print(response['body']);
                                                                                                      await getLPV(currentPage - 1, findLPV);

                                                                                                      Navigator.pop(context);
                                                                                                      showToast(
                                                                                                        context: context,
                                                                                                        msg: "Xóa đề lịch phỏng vấn thành công",
                                                                                                        color: Color.fromARGB(136, 72, 238, 67),
                                                                                                        icon: const Icon(Icons.done),
                                                                                                      );
                                                                                                    },
                                                                                                    child: Text(
                                                                                                      'Xác nhận',
                                                                                                      style: TextStyle(),
                                                                                                    ),
                                                                                                    style: ElevatedButton.styleFrom(
                                                                                                      primary: mainColorPage,
                                                                                                      onPrimary: colorWhite,
                                                                                                      elevation: 3,
                                                                                                      minimumSize: Size(100, 40),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ));
                                                                                    },
                                                                                    child: Icon(Icons.delete_outline, color: Colors.red))),
                                                                          )
                                                                        : Text(""),
                                                                  ],
                                                                )),
                                                              ],
                                                            )
                                                        ]),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else if (snapshot.hasError) {
                                            return Text('${snapshot.error}');
                                          }

                                          // By default, show a loading spinner.
                                          return const CircularProgressIndicator();
                                        },
                                      )),
                                      Container(
                                        margin: const EdgeInsets.only(right: 50),
                                        child: DynamicTablePagging(
                                          rowCount,
                                          currentPage,
                                          rowPerPage,
                                          pageChangeHandler: (page) {
                                            setState(() {
                                              getLPV(page - 1, findLPV);
                                              currentPage = page - 1;
                                            });
                                          },
                                          rowPerPageChangeHandler: (rowPerPage) {
                                            setState(() {
                                              this.rowPerPage = rowPerPage!;
                                              this.firstRow = page * currentPage;
                                              getLPV(0, findLPV);
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Footer(marginFooter: EdgeInsets.only(top: 5), paddingFooter: EdgeInsets.all(15)),
                      SizedBox(height: 20)
                    ],
                  ));
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
