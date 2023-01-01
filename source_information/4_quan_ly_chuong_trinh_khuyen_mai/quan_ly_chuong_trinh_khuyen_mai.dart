import 'dart:convert';
import "package:collection/collection.dart";

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../../../../common/style.dart';
import '../common_ource_information/constant.dart';

Color borderBlack = Colors.black54;

//-----------Trạng thái------
enum Status { TatCa, KichHoat, ChuaKichHoat } //Tình trạng sức khỏe

Status status = Status.TatCa; //Tình trạng sức khỏe

//-----------Trạng thái------
enum Effect { TatCa, ConHieuLuc, HetHieuLuc } //Tình trạng sức khỏe

Effect effect = Effect.TatCa; //Tình trạng sức khỏe

class QuanLyChuongTrinhKhuyenMai extends StatelessWidget {
  const QuanLyChuongTrinhKhuyenMai({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: QuanLyChuongTrinhKhuyenMaiBody());
  }
}

class QuanLyChuongTrinhKhuyenMaiBody extends StatefulWidget {
  const QuanLyChuongTrinhKhuyenMaiBody({Key? key}) : super(key: key);

  @override
  State<QuanLyChuongTrinhKhuyenMaiBody> createState() => _QuanLyChuongTrinhKhuyenMaiBodyState();
}

class _QuanLyChuongTrinhKhuyenMaiBodyState extends State<QuanLyChuongTrinhKhuyenMaiBody> {
  //url trang them moi cap nhat quan lys thong tin tts
  final String urlAddNewUpdate = "/add-new-update-qlctkm";

  var optionListTTSStatus = {"-1": "Tất cả"};
  //----------------Khai báo ngảy tháng định dạng ngày--------------------------------
  String? dateFrom;
  String? dateTo;
  //-------------url Breadcrumbs-----------------
  final String dashboard = '/thong-tin-nguon';

  late List listSelectedRow;
  List<dynamic> idSelectedList = [];
  Widget paging = Container();
  late Future<dynamic> futureListTrainee;
  String condition = ""; //Tình trạng
  var totalElements = 0;
  // var rowPerPage = 10;
  var listTrainee; //Danh sách thực tập sinh
  late int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 10;
  var lastRow = 0;
  TextEditingController nameCTDT = TextEditingController();
  //seachAndPageChange
  dynamic selectedValueDT = '-1';
  List<dynamic> itemsDT = [
    {'name': 'Thực tập sinh', 'value': '0'},
    {'name': 'Cộng tác viên', 'value': '1'},
  ];
  var searchRequest = "";
  var resultList = [];
  var firstRow = 1;
  var content = [];
  var listCtkm;
  Future<dynamic> pageChange(currentPage) async {
    // page = page - 1;
    // if ((page) * rowPerPage > rowCount) {
    //   page = (1.0 * rowCount / rowPerPage).ceil();
    // }
    // if (page <= 0) {
    //   page = 0;
    // }
    String queryRequest = '';
    queryRequest += requestStatus(status);
    if (queryRequest != '' && requestDateTo(effect) != '') {
      queryRequest += ' and ${requestDateTo(effect)}';
    } else {
      queryRequest += requestDateTo(effect);
    }
    if (queryRequest != '' && dateFrom != null && dateTo != null) {
      queryRequest += " and dateFrom>:'$dateFrom' and dateTo<:'$dateTo'";
    } else if (queryRequest != '' && dateFrom != null && dateTo == null) {
      queryRequest += " and dateFrom>:'$dateFrom'";
    } else if (queryRequest != "" && dateFrom == null && dateTo != null) {
      queryRequest += " and dateTo<:'$dateTo'";
    } else if (queryRequest == "" && dateFrom != null && dateTo != null) {
      queryRequest += "dateFrom>:'$dateFrom' and dateTo<:'$dateTo'";
    } else if (queryRequest == "" && dateFrom == null && dateTo != null) {
      queryRequest += "dateTo<:'$dateTo'";
    } else if (queryRequest == "" && dateFrom != null && dateTo == null) {
      queryRequest += "dateFrom>:'$dateFrom'";
    }

    if (nameCTDT.text != "" && queryRequest != "") {
      queryRequest += "and (name~'*${nameCTDT.text}*' or promotCode~'*${nameCTDT.text}*')";
    } else if (nameCTDT.text != "" && queryRequest == "") {
      queryRequest += "(name~'*${nameCTDT.text}*' or promotCode~'*${nameCTDT.text}*')";
    }
    if (queryRequest != "" && selectedValueDT != '-1') {
      queryRequest += " and target:$selectedValueDT";
    } else if (queryRequest == "" && selectedValueDT != '-1') {
      queryRequest += "target:$selectedValueDT";
    }

    var response;
    // response = await httpGet("/api/khuyenmai/get/page?page=$page&size=$rowPerPage&sort=id", context);
    // response = await httpGet("/api/khuyenmai/get/page?page=0&size=10&sort=modifiedDate", context);

    response = await httpGet("/api/khuyenmai/get/page?size=$rowPerPage&page=${currentPage - 1}&filter=$queryRequest &sort=dateFrom", context);
    if (response.containsKey("body")) {
      setState(() {
        listCtkm = jsonDecode(response['body'])['content'];
        rowCount = jsonDecode(response['body'])['totalElements'];
        // _selectedDataRow = List<bool>.generate(content.length, (int index) => false);
      });
      // print("aaaaaaaaaaaaaaaa");
      // print(listTrainee);
      idSelectedList.clear();
      return listCtkm;
    } else {
      throw Exception("failse");
    }
  }

  bool checkSelected = false;

  //-- Lấy id thực tập sinh để tiến cử
  String? idTTSRecommend;
  String getGender(int gender) {
    String nameGender = "";
    switch (gender) {
      case 0:
        {
          nameGender = "Nam";
        }
        break;
      case 1:
        {
          nameGender = "Nữ";
        }
        break;
      case 2:
        {
          nameGender = "Không xác định";
        }
        break;
      default:
        {}
        break;
    }
    return nameGender;
  }

  String requestStatus(Status input) {
    if (input == Status.ChuaKichHoat) {
      return 'status:0';
    } else if (input == Status.KichHoat) {
      return 'status:1';
    } else {
      return '';
    }
  }

  String requestDateTo(Effect input) {
    String dateToRequest = DateFormat("dd-MM-yyyy").format(DateTime.now().toLocal());
    if (input == Effect.ConHieuLuc) {
      return "dateTo>:'$dateToRequest'";
    } else if (input == Effect.HetHieuLuc) {
      return "dateTo<:'$dateToRequest'";
    } else
      return '';
  }

  String statusName(int status) {
    if (status == 0) {
      return 'Chưa kích hoạt';
    } else if (status == 1)
      return 'Kích hoạt';
    else
      return 'nodata';
  }

  String targetName(int target) {
    if (target == 0) {
      return 'Thực tập sinh';
    } else if (target == 1)
      return 'Cộng tác viên';
    else
      return 'nodata';
  }

  String titleLog = '';
  deleteCTKM(id) async {
    var response = await httpDelete("/api/khuyenmai/del/$id", context);
    print(response);
    if (jsonDecode(response["body"]).containsKey("1")) {
      var result = jsonDecode(response["body"]);
      titleLog = result["1"];
    } else {
      var result = jsonDecode(response["body"]);

      titleLog = result["0"];
    }
    return titleLog;
  }

  @override
  void initState() {
    print('object1233');
    listSelectedRow = [];
    super.initState();
    futureListTrainee = pageChange(1);
  }

  //---Hết phần url
  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return FutureBuilder<dynamic>(
      future: userRule(QUAN_LY_CHUONG_TRINH_KHUYEN_MAI, context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Consumer<NavigationModel>(
            builder: (context, navigationModel, child) => ListView(
              controller: ScrollController(),
              children: [
                //---------- Breadcrumbs----------------
                TitlePage(
                  listPreTitle: [
                    {'url': '/thong-tin-nguon', 'title': 'Dashboard'},
                  ],
                  content: 'Quản lý chương trình khuyến mại',
                ),
                //----------end Breadcrumbs----------------
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextFieldValidated(
                                  label: 'Chương trình',
                                  type: 'none',
                                  height: 40,
                                  controller: nameCTDT,
                                  hint: "Tên hoặc mã chương trình",
                                  enter: () {
                                    futureListTrainee = pageChange(0);
                                  },
                                ),
                                SizedBox(width: 50),
                                Expanded(
                                  flex: 3,
                                  child: DropdownBtnSearch(
                                    isAll: true,
                                    label: 'Đối tượng khuyến mãi',
                                    flexLabel: MediaQuery.of(context).size.width < 1600 ? 3 : 2,
                                    listItems: itemsDT,
                                    isSearch: false,
                                    selectedValue: selectedValueDT,
                                    setSelected: (selected) {
                                      selectedValueDT = selected;
                                    },
                                  ),
                                ),
                                Expanded(flex: 2, child: Container()),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: DatePickerBoxVQ(
                                      requestDayBefore: dateTo,
                                      isTime: false,
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
                                SizedBox(width: 50),
                                Expanded(
                                  flex: 3,
                                  child: DatePickerBoxVQ(
                                      requestDayAfter: dateFrom,
                                      flexLabel: MediaQuery.of(context).size.width < 1600 ? 3 : 2,
                                      isTime: false,
                                      label: Text(
                                        'Đến ngày',
                                        style: titleWidgetBox,
                                      ),
                                      dateDisplay: dateFrom,
                                      selectedDateFunction: (day) {
                                        dateTo = day;
                                        setState(() {});
                                      }),
                                ),
                                Expanded(flex: 2, child: Container()),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(30, 30, 0, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  //tìm kiếm
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
                                        futureListTrainee = pageChange(0);
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
                                          Text('Tìm kiếm', style: textButton),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: marginLeftBtn,
                                    child: TextButton.icon(
                                      icon: Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: paddingBtn,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: borderRadiusBtn,
                                        ),
                                        backgroundColor: backgroundColorBtn,
                                        primary: Theme.of(context).iconTheme.color,
                                        textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                      ),
                                      onPressed: () {
                                        navigationModel.add(pageUrl: urlAddNewUpdate);
                                      },
                                      label: Row(
                                        children: [
                                          Text('Thêm mới', style: textButton),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Container(
                              margin: marginTopBoxContainer,
                              width: MediaQuery.of(context).size.width * 1,
                              decoration: BoxDecoration(
                                color: colorWhite,
                                borderRadius: borderRadiusContainer,
                                boxShadow: [boxShadowContainer],
                                border: borderAllContainerBox,
                              ),
                              padding: paddingBoxContainer,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Lựa chọn',
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
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Trạng thái',
                                          textAlign: TextAlign.center,
                                          style: titleTableData,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        RadioListTile<Status>(
                                          title: const Text('Tất cả'),
                                          value: Status.TatCa,
                                          groupValue: status,
                                          onChanged: (Status? value) {
                                            setState(() {
                                              status = value!;
                                            });
                                            futureListTrainee = pageChange(0);
                                          },
                                        ),
                                        RadioListTile<Status>(
                                          title: const Text('Kích hoạt'),
                                          value: Status.KichHoat,
                                          groupValue: status,
                                          onChanged: (Status? value) {
                                            setState(() {
                                              status = value!;
                                            });
                                            futureListTrainee = pageChange(0);
                                          },
                                        ),
                                        RadioListTile<Status>(
                                          title: const Text('Chưa kích hoạt'),
                                          value: Status.ChuaKichHoat,
                                          groupValue: status,
                                          onChanged: (Status? value) {
                                            setState(() {
                                              status = value!;
                                              futureListTrainee = pageChange(0);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(top: 15),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hiệu lực',
                                          textAlign: TextAlign.center,
                                          style: titleTableData,
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                        RadioListTile<Effect>(
                                          title: const Text('Tất cả'),
                                          value: Effect.TatCa,
                                          groupValue: effect,
                                          onChanged: (Effect? value) {
                                            setState(() {
                                              effect = value!;
                                            });
                                            futureListTrainee = pageChange(0);
                                          },
                                        ),
                                        RadioListTile<Effect>(
                                          title: const Text('Còn hiệu lực'),
                                          value: Effect.ConHieuLuc,
                                          groupValue: effect,
                                          onChanged: (Effect? value) {
                                            setState(() {
                                              effect = value!;
                                              futureListTrainee = pageChange(0);
                                            });
                                          },
                                        ),
                                        RadioListTile<Effect>(
                                          title: const Text('Hết hiệu lực'),
                                          value: Effect.HetHieuLuc,
                                          groupValue: effect,
                                          onChanged: (Effect? value) {
                                            setState(() {
                                              effect = value!;
                                            });
                                            futureListTrainee = pageChange(0);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 8,
                            child: FutureBuilder(
                              future: futureListTrainee,
                              builder: (context, snapshot) {
                                var tableIndex = (currentPageDef - 1) * rowPerPage + 1;

                                if (snapshot.hasData) {
                                  return Container(
                                    margin: marginTopLeftContainer,
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
                                              'Chương trình khuyến mãi',
                                              style: titleBox,
                                            ),
                                            Text(
                                              'Kết quả tìm kiếm: $rowCount',
                                              style: titleBox,
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
                                                      columnSpacing: 20,
                                                      horizontalMargin: 10,
                                                      dataRowHeight: 60,
                                                      columns: [
                                                        DataColumn(label: Text('STT', style: titleTableData)),
                                                        DataColumn(
                                                            label: Container(
                                                          child: Expanded(
                                                            child: Text(
                                                              'Mã chương trình',
                                                              style: titleTableData,
                                                              maxLines: 2,
                                                              softWrap: true,
                                                              // overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        )),
                                                        DataColumn(
                                                            label: Container(
                                                          child: Expanded(
                                                            child: Text(
                                                              'Tên chương trình',
                                                              style: titleTableData,
                                                              maxLines: 2,
                                                              softWrap: true,
                                                              // overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        )),
                                                        DataColumn(
                                                            label: Container(
                                                          child: Expanded(
                                                            child: Text(
                                                              'Đến ngày',
                                                              style: titleTableData,
                                                              maxLines: 2,
                                                              softWrap: true,
                                                              // overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        )),
                                                        DataColumn(
                                                            label: Container(
                                                          child: Expanded(
                                                            child: Text(
                                                              'Đến ngày',
                                                              style: titleTableData,
                                                              maxLines: 2,
                                                              softWrap: true,
                                                              // overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        )),
                                                        DataColumn(
                                                            label: Container(
                                                          child: Expanded(
                                                            child: Text(
                                                              'Đối tượng khuyến mãi',
                                                              style: titleTableData,
                                                              maxLines: 2,
                                                              softWrap: true,
                                                              // overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        )),
                                                        DataColumn(
                                                            label: Container(
                                                          child: Expanded(
                                                            child: Text(
                                                              'Trạng thái',
                                                              style: titleTableData,
                                                              maxLines: 2,
                                                              softWrap: true,
                                                              // overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        )),
                                                        DataColumn(
                                                            label: Container(
                                                          child: Expanded(
                                                            child: Text(
                                                              'Hành động',
                                                              style: titleTableData,
                                                              maxLines: 2,
                                                              softWrap: true,
                                                              // overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        )),
                                                      ],
                                                      rows: <DataRow>[
                                                        for (var row in listCtkm ?? [])
                                                          DataRow(
                                                            cells: <DataCell>[
                                                              DataCell(SelectableText("${tableIndex++}")),
                                                              DataCell(
                                                                SelectableText(row["promotCode"] ?? "", style: bangDuLieu),
                                                              ),
                                                              DataCell(
                                                                Container(
                                                                  width: width < 1600 ? width * 0.07 : width * 0.17,
                                                                  // width:
                                                                  //     width * 0.1,
                                                                  child: InkWell(
                                                                    child: Text(row["name"].toString(), style: textButtonTable),
                                                                    onTap: () {
                                                                      if (row["target"] == 0) {
                                                                        showDialog(
                                                                          context: context,
                                                                          builder: (context) => TableDSTTS(
                                                                            row: row,
                                                                          ),
                                                                        );
                                                                      } else {
                                                                        showDialog(
                                                                          context: context,
                                                                          builder: (context) => TableDSCTV(
                                                                            row: row,
                                                                          ),
                                                                        );
                                                                      }
                                                                    },
                                                                  ),
                                                                ),
                                                              ),
                                                              DataCell(
                                                                SelectableText(dateReverse(displayDateTimeStamp(row["dateFrom"].toString())),
                                                                    style: bangDuLieu),
                                                              ),
                                                              DataCell(
                                                                SelectableText(dateReverse(displayDateTimeStamp(row["dateTo"].toString())),
                                                                    style: bangDuLieu),
                                                              ),
                                                              DataCell(
                                                                SelectableText(targetName(row["target"]), style: bangDuLieu),
                                                              ),
                                                              DataCell(
                                                                SelectableText(statusName(row["status"]), style: bangDuLieu),
                                                              ),
                                                              DataCell(
                                                                Row(
                                                                  children: [
                                                                    (getRule(listRule.data, Role.Xem, context))
                                                                        ? Container(
                                                                            child: Tooltip(
                                                                            message: "Xem chi tiết",
                                                                            child: InkWell(
                                                                                onTap: () {
                                                                                  // Navigator.of(context).pushNamed("/chi-tiet-ctkm/${row['id']}");
                                                                                  Provider.of<NavigationModel>(context, listen: false)
                                                                                      .add(pageUrl: "/chi-tiet-ctkm/${row['id']}");
                                                                                },
                                                                                child: Icon(Icons.visibility)),
                                                                          ))
                                                                        : Container(),
                                                                    (getRule(listRule.data, Role.Sua, context))
                                                                        ? Container(
                                                                            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                            child: Tooltip(
                                                                              message: "Sửa thông tin",
                                                                              child: InkWell(
                                                                                onTap: () {
                                                                                  Provider.of<NavigationModel>(context, listen: false)
                                                                                      .add(pageUrl: "/add-new-update-qlctkm/${row['id']}");
                                                                                },
                                                                                child: Icon(
                                                                                  Icons.edit_calendar,
                                                                                  color: Color(0xff009C87),
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : Container(),
                                                                    //----------Nút btn----------------------
                                                                    (getRule(listRule.data, Role.Xoa, context))
                                                                        ? Container(
                                                                            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                            child: InkWell(
                                                                              onTap: () {
                                                                                showDialog(
                                                                                  context: context,
                                                                                  builder: (BuildContext context) => XacNhanXoa(
                                                                                    function: () async {
                                                                                      await deleteCTKM(row['id']);
                                                                                      futureListTrainee = pageChange(0);
                                                                                      showToast(
                                                                                        context: context,
                                                                                        msg: titleLog,
                                                                                        color: titleLog == "Xóa thành công."
                                                                                            ? Color.fromARGB(136, 72, 238, 67)
                                                                                            : Colors.red,
                                                                                        icon: titleLog == "Xóa thành công."
                                                                                            ? Icon(Icons.done)
                                                                                            : Icon(Icons.warning),
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                );
                                                                              },
                                                                              child: Tooltip(
                                                                                message: "Xóa thông tin",
                                                                                child: Icon(
                                                                                  Icons.delete,
                                                                                  color: colorOrange,
                                                                                ),
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
                                              DynamicTablePagging(rowCount, currentPageDef, rowPerPage, pageChangeHandler: (currentPage) {
                                                setState(() {
                                                  futureListTrainee = pageChange(currentPage);
                                                  currentPageDef = currentPage;
                                                });
                                              }, rowPerPageChangeHandler: (rowPerPageChange) {
                                                currentPageDef = 1;
                                                rowPerPage = rowPerPageChange;
                                                futureListTrainee = pageChange(currentPageDef);
                                                setState(() {});
                                              })
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text('${snapshot.error}');
                                }
                                return const Center(
                                    child: Padding(
                                  padding: EdgeInsets.all(250),
                                  child: CircularProgressIndicator(),
                                ));
                              },
                            ),
                          ),
                        ],
                      ),
                      Footer(paddingFooter: paddingBoxContainer, marginFooter: EdgeInsets.only(top: 30)),
                    ],
                  ),
                ),
              ],
            ),
          );

          //  Text(listRule.data!.title);
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class TableDSTTS extends StatefulWidget {
  final dynamic row;
  const TableDSTTS({Key? key, this.row}) : super(key: key);
  @override
  State<TableDSTTS> createState() => _TableDSTTSState();
}

class _TableDSTTSState extends State<TableDSTTS> {
  late int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 5;
  var listTTS;
  late String dateFromRequest;
  late String dateToRequest;
  late Future<dynamic> getListTTSFuture;
  Future<dynamic> getListTTS(currentPage) async {
    var response = await httpGet(
        "/api/nguoidung/get/page?size=$rowPerPage&page=${currentPage - 1}&filter=createdDate>'$dateFromRequest' and createdDate<:'$dateToRequest' and isTts:1 and active:1",
        context);
    if (response.containsKey("body")) {
      setState(() {
        listTTS = jsonDecode(response["body"])['content'];
      });
      rowCount = jsonDecode(response["body"])['totalElements'];
    }
    return 0;
  }

  @override
  void initState() {
    dateFromRequest = dateReverse(displayDateTimeStamp(widget.row['dateFrom']));
    dateToRequest = dateReverse(displayDateTimeStamp(widget.row['dateTo']));
    getListTTSFuture = getListTTS(1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: getListTTSFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var tableIndex = (currentPageDef - 1) * rowPerPage + 1;
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
                        child: Image.asset('images/logoAAM.png'),
                        margin: EdgeInsets.only(right: 10),
                      ),
                      Text(
                        'Danh sách thực tập sinh được hưởng khuyến mại',
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
              width: 1000,
              height: 400,
              child: ListView(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Divider(
                          thickness: 1,
                        ),
                      ),
                      Container(
                        child: Container(
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DataTable(
                                          showCheckboxColumn: false,
                                          columns: [
                                            DataColumn(
                                                label: Expanded(
                                                    child: Text(
                                              'STT',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                            DataColumn(
                                                label: Expanded(
                                                    child: Text(
                                              'Mã TTS',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                            DataColumn(
                                                label: Expanded(
                                                    child: Text(
                                              'Họ và tên',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                            DataColumn(
                                                label: Expanded(
                                                    child: Text(
                                              'Trạng thái TTS',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                          ],
                                          rows: <DataRow>[
                                            for (var row in listTTS)
                                              DataRow(cells: [
                                                DataCell(Center(child: Text("${tableIndex++}"))),
                                                DataCell(Center(child: Text(row['userCode'], style: bangDuLieu))),
                                                DataCell(Center(child: Text(row['fullName'], style: bangDuLieu))),
                                                DataCell(Center(
                                                    child: Text(row['ttsTrangthai'] != null ? row['ttsTrangthai']['statusName'] : "nodata",
                                                        style: bangDuLieu))),
                                                //
                                              ])
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  DynamicTablePagging(rowCount, currentPageDef, rowPerPage, pageChangeHandler: (currentPage) {
                                    setState(() {
                                      getListTTSFuture = getListTTS(currentPage);
                                      currentPageDef = currentPage;
                                    });
                                  }, rowPerPageChangeHandler: (rowPerPageChange) {
                                    setState(() {
                                      rowPerPage = rowPerPageChange;
                                      getListTTSFuture = getListTTS(currentPageDef);
                                    });
                                  })
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.only(left: 20, bottom: 20),
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
                    textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                  ),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                  child: Text('Đóng', style: textButton),
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }
}

class TableDSCTV extends StatefulWidget {
  final dynamic row;
  const TableDSCTV({Key? key, this.row}) : super(key: key);

  @override
  State<TableDSCTV> createState() => _TableDSCTVState();
}

class _TableDSCTVState extends State<TableDSCTV> {
  late int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 5;
  var listCTV;
  late String dateFromRequest;
  late String dateToRequest;
  // late Future<dynamic> getListCTVFuture;
  late Future<dynamic> getListInfoCTVFuture;
  var listIdCtv = [];
  var listCtvGroupBy;
  Future<dynamic> getListCTV() async {
    var response = await httpGet(
        "/api/ctv-lichsu-gioithieu/get/page?filter=createdDate>:'$dateFromRequest' and createdDate<:'$dateToRequest' and thuctapsinh.ttsStatusId:11",
        context);
    if (response.containsKey("body")) {
      setState(() {
        listCTV = jsonDecode(response["body"])['content'];
      });
      listCtvGroupBy = groupBy(listCTV, (dynamic obj) => obj['ctvId']);
      // print(listCtvGroupBy[3].length);
      for (var row in listCTV) if (!listIdCtv.contains(row['ctvId'])) listIdCtv.add(row['ctvId']);
    }
    return 0;
  }

  var listInfoCTV;
  Future<dynamic> getListInfoCTV(currentPage) async {
    await getListCTV();
    var requestId = '';
    for (int i = 0; i < listIdCtv.length; i++) {
      requestId += listIdCtv[i].toString();
      if (i < listIdCtv.length - 1) {
        requestId += ',';
      }
    }
    if (requestId == '') {
      requestId = '0';
    }
    var response = await httpGet("/api/nguoidung/get/page?size=$rowPerPage&page=${currentPage - 1}&filter=id in ($requestId)", context);
    if (response.containsKey("body")) {
      setState(() {
        listInfoCTV = jsonDecode(response["body"])['content'];
      });
      rowCount = jsonDecode(response["body"])['totalElements'];
    }
    return 0;
  }

  @override
  void initState() {
    dateFromRequest = "${dateReverse(displayDateTimeStamp(widget.row['dateFrom']))} ${displayTimeStamp(widget.row['dateFrom'])}:00";
    dateToRequest = "${dateReverse(displayDateTimeStamp(widget.row['dateTo']))} ${displayTimeStamp(widget.row['dateTo'])}:00";
    getListInfoCTVFuture = getListInfoCTV(1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: getListInfoCTVFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var tableIndex = (currentPageDef - 1) * rowPerPage + 1;
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
                        child: Image.asset('images/logoAAM.png'),
                        margin: EdgeInsets.only(right: 10),
                      ),
                      Text(
                        'Danh sách cộng tác viên được hưởng khuyến mại',
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
              width: 1000,
              height: 400,
              child: ListView(
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Divider(
                          thickness: 1,
                        ),
                      ),
                      Container(
                        child: Container(
                          child: Column(
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: DataTable(
                                          showCheckboxColumn: false,
                                          columns: [
                                            DataColumn(
                                                label: Expanded(
                                                    child: Text(
                                              'STT',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                            DataColumn(
                                                label: Expanded(
                                                    child: Text(
                                              'Mã TTS',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                            DataColumn(
                                                label: Expanded(
                                                    child: Text(
                                              'Họ và tên',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                            DataColumn(
                                                label: Expanded(
                                                    child: Text(
                                              'Số TTS đã xuất cảnh',
                                              style: titleTableData,
                                              textAlign: TextAlign.center,
                                            ))),
                                          ],
                                          rows: <DataRow>[
                                            for (var row in listInfoCTV)
                                              DataRow(cells: [
                                                DataCell(Center(child: Text("${tableIndex++}"))),
                                                DataCell(Center(child: Text(row['userCode'], style: bangDuLieu))),
                                                DataCell(Center(child: Text(row['fullName'], style: bangDuLieu))),
                                                DataCell(Center(child: Text(listCtvGroupBy[row['id']].length.toString(), style: bangDuLieu)))
                                                //
                                              ])
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  DynamicTablePagging(rowCount, currentPageDef, rowPerPage, pageChangeHandler: (currentPage) {
                                    setState(() {
                                      getListInfoCTVFuture = getListInfoCTV(currentPage);
                                      currentPageDef = currentPage;
                                    });
                                  }, rowPerPageChangeHandler: (rowPerPageChange) {
                                    setState(() {
                                      rowPerPage = rowPerPageChange;
                                      getListInfoCTVFuture = getListInfoCTV(currentPageDef);
                                    });
                                  })
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              Container(
                margin: EdgeInsets.only(left: 20, bottom: 20),
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
                    textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                  ),
                  onPressed: () {
                    setState(() {
                      Navigator.pop(context);
                    });
                  },
                  child: Text('Đóng', style: textButton),
                ),
              ),
            ],
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return Center(child: const CircularProgressIndicator());
      },
    );
  }
}

class XacNhanXoa extends StatefulWidget {
  Function function;
  XacNhanXoa({Key? key, required this.function}) : super(key: key);
  @override
  State<XacNhanXoa> createState() => _XacNhanXoaState();
}

class _XacNhanXoaState extends State<XacNhanXoa> {
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
                  child: Image.asset('images/logoAAM.png'),
                  margin: EdgeInsets.only(right: 10),
                ),
                Text(
                  'Xác nhận xóa chương trình khuyến mại',
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
              'Bạn có chắc chắn muốn xóa chương trình khuyến mại không?',
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
            primary: colorOrange,
            onPrimary: colorWhite,
            // shadowColor: Colors.greenAccent,
            elevation: 3,
            // shape: Border.all(width: 1,color: Colors.red);
            // side: BorderSide(
            //   width: 1,
            //   color: Colors.black87,
            // ),
            minimumSize: Size(140, 50),
            // maximumSize: Size(140, 50), //////// HERE
          ),
        ),
        ElevatedButton(
          // textColor: Color(0xFF6200EE),
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
            // shadowColor: Colors.greenAccent,
            elevation: 3,
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(32.0)),
            minimumSize: Size(140, 50), //////// HERE
          ),
        ),
      ],
    );
  }
}
