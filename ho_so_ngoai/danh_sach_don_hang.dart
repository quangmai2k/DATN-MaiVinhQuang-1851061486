import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/market_development/job.dart';
import '../../../../model/market_development/order.dart';
import '../../../../model/market_development/status_order.dart';
import '../../../../model/market_development/union.dart';
import '../../../../model/market_development/xinghiep.dart';
import '../../../../model/model.dart';
import '../../forms/market_development/utils/form.dart';
import '../market_development/7-order_management/xuat_file.dart';
import '../navigation.dart';

class DanhSachDonHang extends StatelessWidget {
  const DanhSachDonHang({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: DanhSachDonHangBody());
  }
}

class DanhSachDonHangBody extends StatefulWidget {
  const DanhSachDonHangBody({Key? key}) : super(key: key);

  @override
  State<DanhSachDonHangBody> createState() => _DanhSachDonHangBodyState();
}

class _DanhSachDonHangBodyState extends State<DanhSachDonHangBody> {
  var body = {};
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  bool _setLoading = false;
  bool _setLoading1 = false;
  DateTime selectedDate = DateTime.now();

  List<Order> listOrder = [];
  List<Order> listOrderSelected = [];
  List<Order> listOrderSelectedChuaPhatHanh = [];
  List<Order> listOrderExcell = [];

  late Future<List<Order>> futureListOrder;

  String? selectedUnion;
  String? selectedXiNghiep;
  String? selectedNganhNghe;
  String? selectedTrangThai;
  TextEditingController _orderController = TextEditingController();

  String? dateFrom;
  String? dateTo;

  List<bool> _selected = []; // List này chứa trạng thái selected của data table

  List<bool> _selectedTrue = [];

  int indexSelectedDataRow = 0;
  bool checkSelected = false;

  List<UnionObj> listUnionObj = [];
  List<Jobs> listJobsResult = [];
  List<StatusOrder> listStatusOrder = [];
  List<Enterprise> listEnterprise = [];

  // scroll
  // final ScrollController? controller;

  Future<List<Order>> getListOrder(page, context, {order, orgName, companyName, jobName, statusName, dateFrom1, dateTo1}) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response;

    String condition = "";

    if (order != null) {
      condition += " ( orderCode ~'*$order*' ";
      condition += " OR orderName ~'*$order*' ) ";
    }

    if (orgName != null) {
      if (orgName.toString() == "Tất cả") {
        condition += " AND nghiepdoan.orgName ~'**' ";
      } else {
        condition += " AND nghiepdoan.orgName ~'*$orgName*' ";
      }
    }
    if (companyName != null) {
      if (companyName.toString() == "Tất cả") {
        condition += " AND xinghiep.companyName ~'**' ";
      } else {
        condition += " AND xinghiep.companyName ~'*$companyName*' ";
      }
    }

    if (statusName != null) {
      if (statusName.toString() == "Tất cả") {
        condition += " AND trangthai_donhang.statusName ~'**' ";
      } else {
        condition += " AND trangthai_donhang.statusName ~'*$statusName*' ";
      }
    }
    if (jobName != null) {
      if (jobName.toString() == "Tất cả") {
        condition += " AND nganhnghe_cuthe.jobName ~'**' ";
      } else {
        condition += " AND nganhnghe_cuthe.jobName ~'*$jobName*' ";
      }
    }
    if (dateFrom1 != null) {
      condition += " AND publishDate >:'$dateFrom1' ";
    }
    if (dateTo1 != null) {
      condition += " AND publishDate <:'$dateTo1' ";
    }

    response = await httpGet(
        "/api/donhang/get/page?page=$page&size=$rowPerPage&sort=orderName&filter=$condition and (orderStatusId:2 or orderStatusId:3 or orderStatusId:4) and stopProcessing:0",
        context);

    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        currentPage = page + 1;
        content = body['content'];
        rowCount = body["totalElements"];
        totalElements = body["totalElements"];
        lastRow = totalElements;
        listOrder = content.map((e) {
          return Order.fromJson(e);
        }).toList();
        _selected = List<bool>.generate(listOrder.length, (int index) => false);
        listOrderSelected.clear();
        listOrderSelectedChuaPhatHanh.clear();
        listOrderExcell.clear();
      });
    }
    return content.map((e) {
      return Order.fromJson(e);
    }).toList();
  }

  @override
  // ignore: must_call_super
  void initState() {
    initData();
    futureListOrder = getListOrder(page - 1, context, order: "");
  }

  initData() async {
    await getListUnionSearchBy(context);
    await getListJobSearchBy(context);
    await getListStatusOrder(context);
    await getListXiNghiepSearchBy(context);
    setState(() {
      _setLoading1 = true;
    });
  }

  handleClickBtnSearch({order, orgName, companyName, jobName, statusName, dateFrom, dateTo}) {
    print("clicked");
    setState(() {
      _setLoading = true;
    });
    print(dateFrom);
    Future<List<Order>> _future =
        getListOrder(0, context, order: order, orgName: orgName, companyName: companyName, statusName: statusName, jobName: jobName, dateFrom1: dateFrom, dateTo1: dateTo);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        futureListOrder = _future;
        _setLoading = false;
      });
    });
  }

  setLoadingWhenSubmit(value) {
    setState(() {
      _setLoading = true;
    });
    Future<List<Order>> _futureAfterUpdate = getListOrder(page - 1, context, order: "");

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        futureListOrder = _futureAfterUpdate;
        _setLoading = false;
      });
    });
  }

  Future<List<UnionObj>> getListUnionSearchBy(context, {key}) async {
    var response;
    // ignore: unused_local_variable
    Map<String, String> requestParam = Map();

    String condition = "";

    response = await httpGet("/api/nghiepdoan/get/page?filter=$condition", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      content = body['content'];
    }
    UnionObj union = new UnionObj(id: -1, orgCode: "", orgName: "Tất cả");
    List<UnionObj> list = content.map((e) {
      return UnionObj.fromJson(e);
    }).toList();

    list.insert(0, union);
    setState(() {
      listUnionObj = list;
    });
    return list;
  }

  Future<List<Enterprise>> getListXiNghiepSearchBy(context, {key}) async {
    List<Enterprise> list = [];
    var response;
    // ignore: unused_local_variable
    Map<String, String> requestParam = Map();
    String condition = "";

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

  Future<List<Jobs>> getListJobSearchBy(context, {key}) async {
    List<Jobs> list = [];
    var response;

    response = await httpGet("/api/nganhnghe/get/page??sort=id&filter=parentId is not null", context);

    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      content = body['content'];
    }
    Jobs jobs = new Jobs(id: -1, jobName: "Tất cả", description: "", parentId: -1);
    list = content.map((e) {
      return Jobs.fromJson(e);
    }).toList();
    list.insert(0, jobs);
    setState(() {
      listJobsResult = list;
    });
    return list;
  }

  Future<List<StatusOrder>> getListStatusOrder(context, {key}) async {
    List<StatusOrder> list = [];
    var response = await httpGet("/api/donhang-trangthai/get/page?filter=id:2 or id:3 or id:4", context);

    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      content = body['content'];
      list = content.map((e) {
        return StatusOrder.fromJson(e);
      }).toList();
    }
    StatusOrder statusOrder = new StatusOrder(id: -1, statusName: "Tất cả");
    list.insert(0, statusOrder);
    setState(() {
      listStatusOrder = list;
    });
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NavigationModel, SecurityModel>(
      builder: (context, navigationModel, securityModel, child) => ListView(
        children: [
          TitlePage(
            listPreTitle: [
              {'url': '/ho-so-ngoai', 'title': 'Dashboard'},
            ],
            content: "Danh sách đơn hàng",
          ),
          _setLoading1
              ? FutureBuilder<List<Order>>(
                  future: futureListOrder,
                  builder: (context, snapshot) {
                    double screenwidth = MediaQuery.of(context).size.width;
                    var tableIndex = (currentPage - 1) * rowPerPage + 1;
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
                                    Text('Nhập thông tin', style: titleBox),
                                    Icon(Icons.more_horiz, color: Color(0xff9aa5ce), size: 14),
                                  ],
                                ),
                                //Đường line
                                Container(margin: marginTopBottomHorizontalLine, child: Divider(thickness: 1, color: ColorHorizontalLine)),
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
                                              child: TextFieldValidatedMarket(
                                                  type: "None", labe: "Đơn hàng", isReverse: false, flexLable: 2, flexTextField: 5, marginBottom: 0, controller: _orderController),
                                            )
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
                                    Expanded(flex: 2, child: Container()),
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
                                                      selectedUnion = value!.orgName;
                                                      print(selectedUnion);
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
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(flex: 2, child: Text('Ngành nghề', style: titleWidgetBox)),
                                            Expanded(
                                              flex: 5,
                                              child: Container(
                                                height: 40,
                                                child: DropdownSearch<Jobs>(
                                                  mode: Mode.MENU,
                                                  showSearchBox: true,
                                                  items: listJobsResult,
                                                  itemAsString: (Jobs? u) => u!.jobName!,
                                                  selectedItem: listJobsResult.first,
                                                  dropdownSearchDecoration: styleDropDown,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedNganhNghe = value!.jobName;
                                                      print(selectedNganhNghe);
                                                    });
                                                  },
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
                                              flex: 3,
                                              child: Container(
                                                child: DatePickerBoxVQ(
                                                    isTime: false,
                                                    label: Text('Từ ngày', style: titleWidgetBox),
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
                                            flex: 3,
                                            child: Container(
                                              child: DatePickerBoxVQ(
                                                  isTime: false,
                                                  label: Text('Đến ngày', style: titleWidgetBox),
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
                                    Expanded(flex: 2, child: Container()),
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
                                            Expanded(flex: 2, child: Text('Trạng thái', style: titleWidgetBox)),
                                            Expanded(
                                              flex: 5,
                                              child: Container(
                                                height: 40,
                                                child: DropdownSearch<StatusOrder>(
                                                  mode: Mode.MENU,
                                                  showSearchBox: true,
                                                  items: listStatusOrder,
                                                  itemAsString: (StatusOrder? u) => u!.statusName,
                                                  selectedItem: listStatusOrder.first,
                                                  dropdownSearchDecoration: styleDropDown,
                                                  emptyBuilder: (context, String? value) {
                                                    return const Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                                      child: Align(alignment: Alignment.center, child: Text("Không có dữ liệu !")),
                                                    );
                                                  },
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedTrangThai = value!.statusName;
                                                      print(selectedTrangThai);
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
                                    Expanded(flex: 3, child: Container()),
                                    Expanded(flex: 2, child: Container()),
                                  ],
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
                                            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
                                            backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                            primary: Theme.of(context).iconTheme.color,
                                            textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                                          ),
                                          onPressed: () {
                                            if (dateFrom != null && dateTo != null) {
                                              print(dateReverse(dateFrom));
                                              DateTime dateTimeFrom = DateTime.parse(dateReverse(dateFrom));
                                              DateTime dateTimeTo = DateTime.parse(dateReverse(dateTo));
                                              if (dateTimeFrom.isAfter(dateTimeTo)) {
                                                showToast(
                                                    context: context,
                                                    msg: "Từ ngày phải nhỏ hơn đến ngày !",
                                                    color: Color.fromARGB(135, 247, 217, 179),
                                                    icon: Icon(Icons.warning_amber_outlined));
                                                return;
                                              }
                                            }
                                            handleClickBtnSearch(
                                                order: _orderController.text,
                                                orgName: selectedUnion,
                                                companyName: selectedXiNghiep,
                                                jobName: selectedNganhNghe,
                                                statusName: selectedTrangThai,
                                                dateFrom: dateFrom,
                                                dateTo: dateTo);
                                          },
                                          icon: Transform.rotate(
                                            angle: 270,
                                            child: Icon(Icons.search, color: Colors.white, size: 15),
                                          ),
                                          label: Row(
                                            children: [
                                              Text('Tìm kiếm ', style: textButton),
                                            ],
                                          ),
                                        ),
                                      ),
                                      //start button xuất file
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
                                            // print(listOrderExcell.length);
                                            if (listOrderExcell.isNotEmpty) {
                                              createExcel(listOrderExcell);
                                            } else {
                                              showToast(
                                                  context: context, msg: "Vui lòng chọn ít nhất 1 bản ghi", color: Color.fromARGB(255, 212, 240, 135), icon: Icon(Icons.warning));
                                            }
                                          },
                                          icon: Transform.rotate(
                                            angle: 270,
                                            child: Icon(Icons.file_open_sharp, color: Colors.white, size: 15),
                                          ),
                                          label: Row(
                                            children: [Text('Xuất file ', style: textButton)],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
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
                                    Text('Danh sách đơn hàng', style: titleBox),
                                    // Text('Số lượng đơn hàng : $totalElements', style: titleBox),
                                    Icon(Icons.more_horiz, color: colorIconTitleBox, size: 14),
                                  ],
                                ),
                                //Đường line
                                Container(
                                  margin: marginTopBottomHorizontalLine,
                                  child: Divider(thickness: 1, color: ColorHorizontalLine),
                                ),
                                //Start Datatable
                                Column(
                                  children: [
                                    if (snapshot.hasData)
                                      //Start Datatable
                                      !_setLoading
                                          ? Container(
                                              width: MediaQuery.of(context).size.width * 1,
                                              child: screenwidth >= 1024
                                                  ? DataTable(
                                                      dataTextStyle: const TextStyle(color: Color(0xff313131), fontSize: 14, fontWeight: FontWeight.w500),
                                                      showBottomBorder: true,
                                                      columnSpacing: 5,
                                                      dataRowHeight: 65,
                                                      showCheckboxColumn: true,
                                                      dataRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                                                        if (states.contains(MaterialState.selected)) {
                                                          return MaterialStateColor.resolveWith((states) => const Color(0xffeef3ff));
                                                        }
                                                        return MaterialStateColor.resolveWith((states) => Colors.white); // Use the default value.
                                                      }),
                                                      columns: <DataColumn>[
                                                        DataColumn(label: Text('STT', style: titleTableData, textAlign: TextAlign.center)),
                                                        DataColumn(label: Text('Mã đơn hàng', style: titleTableData, textAlign: TextAlign.center)),
                                                        DataColumn(label: Text('Tên đơn hàng', style: titleTableData, textAlign: TextAlign.center)),
                                                        DataColumn(label: Text('Nghiệp  đoàn', style: titleTableData, textAlign: TextAlign.center)),
                                                        DataColumn(label: Text('Xí nghiệp', style: titleTableData, textAlign: TextAlign.center)),
                                                        DataColumn(label: Text('Ngành nghề', style: titleTableData, textAlign: TextAlign.center)),
                                                        DataColumn(label: Text('Thời gian\nthực hiện', style: titleTableData, textAlign: TextAlign.center)),
                                                        DataColumn(label: Text('Trạng thái', style: titleTableData, textAlign: TextAlign.center)),
                                                        DataColumn(label: Text('Hành động', style: titleTableData, textAlign: TextAlign.center)),
                                                      ],
                                                      rows: <DataRow>[
                                                        for (int i = 0; i < listOrder.length; i++)
                                                          DataRow(
                                                            cells: <DataCell>[
                                                              DataCell(Container(
                                                                  width: (MediaQuery.of(context).size.width / 10) * 0.15,
                                                                  child: Text("${(currentPage - 1) * rowPerPage + i + 1}"))),
                                                              DataCell(Container(
                                                                  width: (MediaQuery.of(context).size.width / 10) * 0.7, child: Text(listOrder[i].orderCode, style: bangDuLieu))),
                                                              DataCell(
                                                                Container(
                                                                    width: (MediaQuery.of(context).size.width / 10) * 0.8,
                                                                    child: Padding(
                                                                      padding: const EdgeInsets.all(10.0),
                                                                      child: Tooltip(
                                                                        message: "${listOrder[i].orderName}",
                                                                        child: Text(listOrder[i].orderName, maxLines: 2, overflow: TextOverflow.ellipsis, style: bangDuLieu),
                                                                      ),
                                                                    )),
                                                              ),
                                                              DataCell(
                                                                Container(
                                                                    width: (MediaQuery.of(context).size.width / 10) * 0.7,
                                                                    child: Text(listOrder[i].union!.orgName!, style: bangDuLieu)),
                                                              ),
                                                              DataCell(Container(
                                                                  width: (MediaQuery.of(context).size.width / 10) * 0.7,
                                                                  child: Text(listOrder[i].enterprise!.companyName, style: bangDuLieu))),
                                                              DataCell(Container(
                                                                  width: (MediaQuery.of(context).size.width / 10) * 0.6,
                                                                  child: Text(listOrder[i].jobsDetail!.jobName!, style: bangDuLieu))),
                                                              DataCell(Container(
                                                                  width: (MediaQuery.of(context).size.width / 10) * 0.6,
                                                                  child: Text(listOrder[i].implementTime!, style: bangDuLieu))),
                                                              DataCell(Container(
                                                                  width: (MediaQuery.of(context).size.width / 10) * 0.7,
                                                                  child: Text(listOrder[i].statusOrder != null ? listOrder[i].statusOrder!.statusName : "", style: bangDuLieu))),
                                                              DataCell(Consumer<NavigationModel>(
                                                                builder: (context, navigationModel, child) => Container(
                                                                  margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                  child: InkWell(
                                                                    onTap: () {
                                                                      navigationModel.add(pageUrl: "/xem-chi-tiet-don-hang/${listOrder[i].id}");
                                                                    },
                                                                    child: Icon(Icons.visibility),
                                                                  ),
                                                                ),
                                                              )),
                                                            ],
                                                            selected: _selected[i],
                                                            onSelectChanged: (bool? value) {
                                                              setState(() {
                                                                // _selectedTrue.clear();
                                                                listOrderSelected.clear();
                                                                listOrderSelectedChuaPhatHanh.clear();
                                                                listOrderExcell.clear();
                                                                _selected[i] = value!;
                                                                //listOrderExcell xuất execll
                                                                for (int j = 0; j < _selected.length; j++) {
                                                                  if (_selected[j]) {
                                                                    listOrderExcell.add(listOrder[j]);
                                                                  }
                                                                }
                                                                for (int j = 0; j < _selected.length; j++) {
                                                                  if (_selected[j] == true && listOrder[j].statusOrder!.id != 5 && listOrder[j].statusOrder!.id != 4) {
                                                                    _selectedTrue.add(value);
                                                                    listOrderSelected.add(listOrder[j]);
                                                                    if (listOrder[j].statusOrder!.id == 1) {
                                                                      listOrderSelectedChuaPhatHanh.add(listOrder[j]);
                                                                    }
                                                                  }
                                                                }
                                                              });
                                                            },
                                                          ),
                                                      ],
                                                    )
                                                  : SingleChildScrollView(
                                                      scrollDirection: Axis.horizontal,
                                                      child: DataTable(
                                                        dataTextStyle: const TextStyle(color: Color(0xff313131), fontSize: 14, fontWeight: FontWeight.w500),
                                                        // showBottomBorder: true,
                                                        dataRowHeight: 60,
                                                        showCheckboxColumn: true,
                                                        dataRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                                                          if (states.contains(MaterialState.selected)) {
                                                            return MaterialStateColor.resolveWith((states) => const Color(0xffeef3ff));
                                                          }
                                                          return MaterialStateColor.resolveWith((states) => Colors.white); // Use the default value.
                                                        }),
                                                        columns: <DataColumn>[
                                                          DataColumn(label: Text('STT', style: titleTableData, textAlign: TextAlign.center)),
                                                          DataColumn(label: Text('Mã đơn hàng', style: titleTableData, textAlign: TextAlign.center)),
                                                          DataColumn(label: Text('Tên đơn hàng', style: titleTableData, textAlign: TextAlign.center)),
                                                          DataColumn(label: Text('Nghiệp  đoàn', style: titleTableData, textAlign: TextAlign.center)),
                                                          DataColumn(label: Text('Xí nghiệp', style: titleTableData, textAlign: TextAlign.center)),
                                                          DataColumn(label: Text('Ngành nghề', style: titleTableData, textAlign: TextAlign.center)),
                                                          DataColumn(label: Text('Thời hạn hợp đồng lao động', style: titleTableData, textAlign: TextAlign.center)),
                                                          DataColumn(label: Text('Trạng thái', style: titleTableData, textAlign: TextAlign.center)),
                                                          DataColumn(label: Text('Hành động', style: titleTableData, textAlign: TextAlign.center)),
                                                        ],
                                                        rows: <DataRow>[
                                                          for (int i = 0; i < listOrder.length; i++)
                                                            DataRow(
                                                              cells: <DataCell>[
                                                                DataCell(Text("${i + tableIndex}")),
                                                                DataCell(Text(listOrder[i].orderCode, style: bangDuLieu)),
                                                                DataCell(Container(width: 300, child: Text(listOrder[i].orderName, style: bangDuLieu))),
                                                                DataCell(Container(width: 300, child: Text(listOrder[i].union!.orgName!, style: bangDuLieu))),
                                                                DataCell(Text(listOrder[i].enterprise!.companyName, style: bangDuLieu)),
                                                                DataCell(Text(listOrder[i].jobsDetail!.jobName!, style: bangDuLieu)),
                                                                DataCell(Text(listOrder[i].implementTime!, style: bangDuLieu)),
                                                                DataCell(Text(listOrder[i].statusOrder != null ? listOrder[i].statusOrder!.statusName : "", style: bangDuLieu)),
                                                                DataCell(Row(
                                                                  children: [
                                                                    Consumer<NavigationModel>(
                                                                      builder: (context, navigationModel, child) => Container(
                                                                        margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                        child: InkWell(
                                                                          onTap: () {
                                                                            navigationModel.add(pageUrl: "/thong-tin-don-hang/${listOrder[i].id}");
                                                                          },
                                                                          child: Icon(Icons.visibility),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )),
                                                              ],
                                                              selected: _selected[i],
                                                              onSelectChanged: (bool? value) {
                                                                setState(() {
                                                                  // _selectedTrue.clear();
                                                                  listOrderSelected.clear();
                                                                  listOrderSelectedChuaPhatHanh.clear();
                                                                  listOrderExcell.clear();
                                                                  _selected[i] = value!;
                                                                  //listOrderExcell xuất execll
                                                                  for (int j = 0; j < _selected.length; j++) {
                                                                    if (_selected[j]) {
                                                                      listOrderExcell.add(listOrder[j]);
                                                                    }
                                                                  }
                                                                  for (int j = 0; j < _selected.length; j++) {
                                                                    if (_selected[j] == true && listOrder[j].statusOrder!.id != 5 && listOrder[j].statusOrder!.id != 4) {
                                                                      _selectedTrue.add(value);
                                                                      listOrderSelected.add(listOrder[j]);
                                                                      if (listOrder[j].statusOrder!.id == 1) {
                                                                        listOrderSelectedChuaPhatHanh.add(listOrder[j]);
                                                                      }
                                                                    }
                                                                  }
                                                                });
                                                              },
                                                            ),
                                                        ],
                                                      ),
                                                    ),
                                            )
                                          : Center(
                                              child: CircularProgressIndicator(),
                                            )
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
                                      setState(() {
                                        getListOrder(page - 1, context,
                                            order: _orderController.text,
                                            companyName: selectedXiNghiep,
                                            orgName: selectedUnion,
                                            statusName: selectedTrangThai,
                                            dateFrom1: dateFrom,
                                            jobName: selectedNganhNghe,
                                            dateTo1: dateTo);
                                        //currentPage = page - 1;
                                      });
                                    },
                                    rowPerPageChangeHandler: (rowPerPage) {
                                      setState(() {
                                        this.rowPerPage = rowPerPage!;
                                        //coding
                                        this.firstRow = page * currentPage;
                                        getListOrder(page - 1, context,
                                            order: _orderController.text,
                                            companyName: selectedXiNghiep,
                                            orgName: selectedUnion,
                                            statusName: selectedTrangThai,
                                            dateFrom1: dateFrom,
                                            jobName: selectedNganhNghe,
                                            dateTo1: dateTo);
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  })
              : Center(
                  child: const CircularProgressIndicator(),
                ),
        ],
      ),
    );
  }
}
