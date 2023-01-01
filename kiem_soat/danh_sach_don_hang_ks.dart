import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/format_date.dart';
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
import '../market_development/7-order_management/service/service.dart';
import '../navigation.dart';

class DanhSachDonHangKS extends StatefulWidget {
  const DanhSachDonHangKS({Key? key}) : super(key: key);

  @override
  State<DanhSachDonHangKS> createState() => _DanhSachDonHangKSState();
}

class _DanhSachDonHangKSState extends State<DanhSachDonHangKS> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: DanhSachDonHangKSBody());
  }
}

class DanhSachDonHangKSBody extends StatefulWidget {
  const DanhSachDonHangKSBody({Key? key}) : super(key: key);

  @override
  State<DanhSachDonHangKSBody> createState() => _DanhSachDonHangKSBodyState();
}

class _DanhSachDonHangKSBodyState extends State<DanhSachDonHangKSBody> {
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
  //url trang them moi cap nhat quan lys thong tin tts
  final String urlAddNewUpdateSI = "quan-li-don-hang/add";
  final String urlDetail = "quan-li-don-hang/chi-tiet";

  List<Order> listOrder = [];
  List<Order> listOrderSelected = [];
  List<Order> listOrderSelectedChuaPhatHanh = [];

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

  Future<List<Order>> getListOrder(page, context,
      {order,
      orgName,
      companyName,
      jobName,
      statusName,
      dateFrom1,
      dateTo1}) async {
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

    if (dateFrom1 != null) {
      condition += " AND publishDate >:'${dateFrom1}' ";
    }
    if (dateTo1 != null) {
      condition += " AND publishDate <:'${dateTo1}' ";
    }

    response = await httpGet(
        "/api/donhang/get/page?page=$page&size=$rowPerPage&filter=${condition}",
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
      });
    }
    return content.map((e) {
      return Order.fromJson(e);
    }).toList();
  }

  @override
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

  Future<DateTime> _selectDate1(context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      return picked;
    }
    return DateTime.now();
  }

  handleClickBtnSearch(
      {order, orgName, companyName, jobName, statusName, dateFrom, dateTo}) {
    print("clicked");
    setState(() {
      _setLoading = true;
    });
    print(dateFrom);
    Future<List<Order>> _future = getListOrder(0, context,
        order: order,
        orgName: orgName,
        companyName: companyName,
        statusName: statusName,
        jobName: jobName,
        dateFrom1: dateFrom,
        dateTo1: dateTo);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        futureListOrder = _future;
        _setLoading = false;
      });
    });
  }

  handleButtonStartProcessing(securityModel) async {
    var requestBody = {
      "orderStatusId": 2, //Trạng thái chờ xử lý
      "publishUser": securityModel.userLoginCurren['id'], //id của quangthaigiam
      "publishDate": FormatDate.formatDateInsertDB(DateTime.now())
    };
    int countSucces = 0;
    for (var item in listOrderSelected) {
      if (item.stopProcessing != 1) {
        //Loại bỏ những ông đã có trong tts-donhang
        bool result = await updateStatusOrder(requestBody, item.id, context);
        if (result) {
          countSucces++;
        }
      }
    }
    if (countSucces == listOrderSelected.length) {
      showToast(
          context: context,
          msg: "Cập nhật trạng thái đơn hàng thành công",
          color: Colors.green,
          icon: Icon(Icons.supervised_user_circle));
      setState(() {
        _setLoading = true;
      });
      Future<List<Order>> _futureAfterUpdate =
          getListOrder(0, context, order: "");

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          futureListOrder = _futureAfterUpdate;
          _setLoading = false;
        });
      });
    } else {
      showToast(
          context: context,
          msg: "Cập nhật thiếu bảng ghi",
          color: Colors.red,
          icon: Icon(Icons.supervised_user_circle));
    }
  }

  setLoadingWhenSubmit(value) {
    setState(() {
      _setLoading = true;
    });
    Future<List<Order>> _futureAfterUpdate =
        getListOrder(page - 1, context, order: "");

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        futureListOrder = _futureAfterUpdate;
        _setLoading = false;
      });
    });
  }

  Future<List<UnionObj>> getListUnionSearchBy(context, {key}) async {
    var response;
    Map<String, String> requestParam = Map();

    String condition = "";

    response =
        await httpGet("/api/nghiepdoan/get/page?filter=${condition}", context);
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

  Future<List<Enterprise>> getListXiNghiepSearchBy(context, {key}) async {
    List<Enterprise> list = [];
    var response;
    Map<String, String> requestParam = Map();
    String condition = "";

    response = await httpGet(
        "/api/xinghiep/get/page?sort=id&filter=${condition}", context);

    var body = jsonDecode(response['body']);
    var content = [];

    if (response.containsKey("body")) {
      content = body['content'];
    }
    list = content.map((e) {
      return Enterprise.fromJson(e);
    }).toList();
    Enterprise enterprise = new Enterprise(
        id: -1,
        companyCode: "",
        companyName: "Tất cả",
        orgId: -1,
        address: "",
        job: "",
        description: "",
        status: -1,
        createdUser: -1,
        createdDate: "");
    list.insert(0, enterprise);
    setState(() {
      listEnterprise = list;
    });
    return list;
  }

  Future<List<Jobs>> getListJobSearchBy(context, {key}) async {
    List<Jobs> list = [];
    var response;

    response = await httpGet(
        "/api/nganhnghe/get/page?filter=parentId is null", context);

    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      content = body['content'];
    }
    Jobs jobs =
        new Jobs(id: -1, jobName: "Tất cả", description: "", parentId: -1);
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
    var response =
        await httpGet("/api/donhang-trangthai/get/page?sort=id,asc", context);

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

  deleteDonHang(id) async {
    var response = await httpDelete("/api/donhang/del/$id", context);
    print(response);
    var body = jsonDecode(response['body']);
    if (body.containsKey("1")) {
      showToast(
          context: context,
          msg: body['1'],
          color: Colors.green,
          icon: Icon(Icons.abc));
    } else {
      showToast(
          context: context,
          msg: body['0'],
          color: Colors.red,
          icon: Icon(Icons.abc));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NavigationModel, SecurityModel>(
      builder: (context, navigationModel, securityModel, child) => _setLoading1
          ? FutureBuilder<List<Order>>(
              future: futureListOrder,
              builder: (context, snapshot) {
                return ListView(
                  controller: ScrollController(),
                  children: [
                    TitlePage(
                      listPreTitle: [
                        {'url': '/kiem-soat', 'title': 'Dashboard'},
                      ],
                      content: "Danh sách đơn hàng",
                    ),
                    Container(
                      color: backgroundPage,
                      padding: EdgeInsets.symmetric(
                          vertical: verticalPaddingPage,
                          horizontal: horizontalPaddingPage),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: TextFieldValidatedMarket(
                                                  type: "None",
                                                  labe: "Đơn hàng",
                                                  isReverse: false,
                                                  flexLable: 2,
                                                  flexTextField: 5,
                                                  marginBottom: 0,
                                                  controller: _orderController),
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text('Xí nghiệp',
                                                  style: titleWidgetBox),
                                            ),
                                            Expanded(
                                              flex: 5,
                                              child: Container(
                                                // width: MediaQuery.of(context).size.width * 0.15,

                                                height: 40,
                                                child:
                                                    DropdownSearch<Enterprise>(
                                                  mode: Mode.MENU,
                                                  showSearchBox: true,
                                                  items: listEnterprise,
                                                  selectedItem:
                                                      listEnterprise.first,
                                                  itemAsString:
                                                      (Enterprise? u) =>
                                                          u!.companyName,
                                                  dropdownSearchDecoration:
                                                      styleDropDown,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedXiNghiep =
                                                          value!.companyName;
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
                                SizedBox(
                                  height: 25,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text('Nghiệp đoàn',
                                                  style: titleWidgetBox),
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
                                                  itemAsString: (UnionObj? u) =>
                                                      u!.orgName!,
                                                  selectedItem:
                                                      listUnionObj.first,
                                                  dropdownSearchDecoration:
                                                      styleDropDown,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedUnion =
                                                          value!.orgName;
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text('Ngành nghề',
                                                  style: titleWidgetBox),
                                            ),
                                            Expanded(
                                              flex: 5,
                                              child: Container(
                                                // width: MediaQuery.of(context).size.width * 0.15,
                                                height: 40,
                                                child: DropdownSearch<Jobs>(
                                                  mode: Mode.MENU,
                                                  showSearchBox: true,
                                                  items: listJobsResult,
                                                  itemAsString: (Jobs? u) =>
                                                      u!.jobName!,
                                                  selectedItem:
                                                      listJobsResult.first,
                                                  dropdownSearchDecoration:
                                                      styleDropDown,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedNganhNghe =
                                                          value!.jobName;
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
                                      child: Container(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text('Trạng thái',
                                                  style: titleWidgetBox),
                                            ),
                                            Expanded(
                                              flex: 5,
                                              child: Container(
                                                // decoration: styleDropDownSearchContainer,
                                                // width: MediaQuery.of(context).size.width * 0.15,
                                                height: 40,
                                                child:
                                                    DropdownSearch<StatusOrder>(
                                                  mode: Mode.MENU,
                                                  showSearchBox: true,
                                                  items: listStatusOrder,
                                                  itemAsString:
                                                      (StatusOrder? u) =>
                                                          u!.statusName,
                                                  selectedItem:
                                                      listStatusOrder.first,
                                                  dropdownSearchDecoration:
                                                      styleDropDown,
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedTrangThai =
                                                          value!.statusName;
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
                                    Expanded(
                                      flex: 3,
                                      child: Container(),
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
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(bottom: 30),
                                                child: DatePickerBoxVQ(
                                                    isTime: false,
                                                    label: Text(
                                                      'Từ ngày',
                                                      style: titleWidgetBox,
                                                    ),
                                                    dateDisplay: dateTo,
                                                    selectedDateFunction:
                                                        (day) {
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              margin:
                                                  EdgeInsets.only(bottom: 30),
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
                                    Expanded(flex: 2, child: Container()),
                                  ],
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(30, 30, 0, 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      //start button tìm kiếm
                                      Container(
                                        margin: EdgeInsets.only(left: 20),
                                        child: TextButton.icon(
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 20.0,
                                              horizontal: 10.0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            backgroundColor:
                                                Color.fromRGBO(245, 117, 29, 1),
                                            primary: Theme.of(context)
                                                .iconTheme
                                                .color,
                                            textStyle: Theme.of(context)
                                                .textTheme
                                                .caption
                                                ?.copyWith(
                                                    fontSize: 20.0,
                                                    letterSpacing: 2.0),
                                          ),
                                          onPressed: () {
                                            if (dateFrom != null &&
                                                dateTo != null) {
                                              print(dateReverse(dateFrom));
                                              DateTime dateTimeFrom =
                                                  DateTime.parse(
                                                      dateReverse(dateFrom));
                                              DateTime dateTimeTo =
                                                  DateTime.parse(
                                                      dateReverse(dateTo));
                                              if (dateTimeFrom
                                                  .isAfter(dateTimeTo)) {
                                                showToast(
                                                    context: context,
                                                    msg:
                                                        "Từ ngày phải nhỏ hơn đến ngày !",
                                                    color: Colors.red,
                                                    icon: Icon(Icons
                                                        .warning_amber_outlined));
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
                                            child: Icon(
                                              Icons.search,
                                              color: Colors.white,
                                              size: 15,
                                            ),
                                          ),
                                          label: Row(
                                            children: [
                                              Text('Tìm kiếm ',
                                                  style: textButton),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Danh sách đơn hàng',
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
                                if (snapshot.hasData)
                                  //Start Datatable
                                  !_setLoading
                                      ? Row(
                                          children: [
                                            Expanded(child: LayoutBuilder(
                                                builder: (BuildContext context,
                                                    BoxConstraints
                                                        constraints) {
                                              return Center(
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: ConstrainedBox(
                                                      constraints:
                                                          BoxConstraints(
                                                              minWidth:
                                                                  constraints
                                                                      .maxWidth),
                                                      // width: MediaQuery.of(context).size.width * 1,
                                                      child: DataTable(
                                                        dataTextStyle:
                                                            const TextStyle(
                                                                color: Color(
                                                                    0xff313131),
                                                                fontSize: 14,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                        showBottomBorder: true,
                                                        dataRowHeight: 60,
                                                        // showCheckboxColumn: true,
                                                        dataRowColor:
                                                            MaterialStateProperty
                                                                .resolveWith<
                                                                    Color?>((Set<
                                                                        MaterialState>
                                                                    states) {
                                                          if (states.contains(
                                                              MaterialState
                                                                  .selected)) {
                                                            return MaterialStateColor
                                                                .resolveWith((states) =>
                                                                    const Color(
                                                                        0xffeef3ff));
                                                          }
                                                          return MaterialStateColor
                                                              .resolveWith(
                                                                  (states) => Colors
                                                                      .white); // Use the default value.
                                                        }),
                                                        columns: <DataColumn>[
                                                          DataColumn(
                                                            label: Text(
                                                              'STT',
                                                              style:
                                                                  titleTableData,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                          DataColumn(
                                                            label: Text(
                                                              'Mã đơn hàng',
                                                              style:
                                                                  titleTableData,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                          DataColumn(
                                                            label: Text(
                                                              'Tên đơn hàng',
                                                              style:
                                                                  titleTableData,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                          DataColumn(
                                                            label: Text(
                                                              'Nghiệp đoàn',
                                                              style:
                                                                  titleTableData,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                          // DataColumn(
                                                          //   label: Text(
                                                          //     'Xí nghiệp',
                                                          //     style: titleTableData,
                                                          //     textAlign: TextAlign.center,
                                                          //   ),
                                                          // ),
                                                          DataColumn(
                                                            label: Text(
                                                              'Ngành \nnghề',
                                                              style:
                                                                  titleTableData,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                          DataColumn(
                                                            label: Text(
                                                              'Người \nphụ trách',
                                                              style:
                                                                  titleTableData,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                          DataColumn(
                                                            label: Text(
                                                              'Trạng thái',
                                                              style:
                                                                  titleTableData,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                          DataColumn(
                                                            label: Text(
                                                              'Thao tác',
                                                              style:
                                                                  titleTableData,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                          ),
                                                        ],
                                                        rows: <DataRow>[
                                                          //var tableIndex = (currentPage) * rowPerPage + 1;
                                                          for (int i = 0;
                                                              i <
                                                                  listOrder
                                                                      .length;
                                                              i++)
                                                            DataRow(
                                                              cells: <DataCell>[
                                                                DataCell(Container(
                                                                    width: (MediaQuery.of(context).size.width /
                                                                            10) *
                                                                        0.15,
                                                                    child: Text(
                                                                        "${i + ((currentPage) * rowPerPage + 1) - 10}"))),
                                                                DataCell(Container(
                                                                    width: (MediaQuery.of(context).size.width /
                                                                            10) *
                                                                        0.6,
                                                                    child: Text(
                                                                        listOrder[i]
                                                                            .orderCode))),
                                                                DataCell(
                                                                  Container(
                                                                      width: (MediaQuery.of(context).size.width /
                                                                              10) *
                                                                          0.7,
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            const EdgeInsets.all(10.0),
                                                                        child:
                                                                            Tooltip(
                                                                          message:
                                                                              "${listOrder[i].orderName}",
                                                                          child:
                                                                              Text(
                                                                            listOrder[i].orderName,
                                                                            maxLines:
                                                                                2,
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      )),
                                                                ),
                                                                DataCell(
                                                                  Container(
                                                                      width: (MediaQuery.of(context).size.width /
                                                                              10) *
                                                                          0.5,
                                                                      child: Text(listOrder[
                                                                              i]
                                                                          .union!
                                                                          .orgName!)),
                                                                ),
                                                                // DataCell(Container(
                                                                //     width: (MediaQuery.of(context).size.width / 10) * 0.6,
                                                                //     child: Text(listOrder[i].enterprise!.companyName))),
                                                                DataCell(Container(
                                                                    width: (MediaQuery.of(context).size.width /
                                                                            10) *
                                                                        0.4,
                                                                    child: Text(
                                                                        listOrder[i]
                                                                            .jobs!
                                                                            .jobName!))),
                                                                DataCell(Container(
                                                                    width: (MediaQuery.of(context).size.width /
                                                                            10) *
                                                                        0.4,
                                                                    child: Text(
                                                                        listOrder[i]
                                                                            .user!
                                                                            .fullName))),
                                                                DataCell(
                                                                    Container(
                                                                  width: (MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          10) *
                                                                      0.4,
                                                                  child: Text(
                                                                    listOrder[i].statusOrder!.id ==
                                                                            5
                                                                        ? listOrder[i]
                                                                            .statusOrder!
                                                                            .statusName
                                                                        : listOrder[i].stopProcessing !=
                                                                                1
                                                                            ? listOrder[i].statusOrder!.statusName
                                                                            : "Tạm dừng xử lý",
                                                                    style: TextStyle(
                                                                        color: listOrder[i].statusOrder!.id == 5
                                                                            ? Colors.red
                                                                            : listOrder[i].stopProcessing == 1
                                                                                ? Colors.orange
                                                                                : Colors.black),
                                                                  ),
                                                                )),
                                                                DataCell(Row(
                                                                  children: [
                                                                    Consumer<
                                                                        NavigationModel>(
                                                                      builder: (context,
                                                                              navigationModel,
                                                                              child) =>
                                                                          Container(
                                                                        margin: const EdgeInsets.fromLTRB(
                                                                            10,
                                                                            0,
                                                                            0,
                                                                            0),
                                                                        child:
                                                                            InkWell(
                                                                          onTap:
                                                                              () {
                                                                            navigationModel.add(pageUrl: "/xem-chi-tiet-don-hang/${listOrder[i].id}");
                                                                          },
                                                                          child:
                                                                              Icon(Icons.visibility),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                )),
                                                              ],
                                                            ),
                                                        ],
                                                      )),
                                                ),
                                              );
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
                                        currentPage = page - 1;
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
                          Footer()
                        ],
                      ),
                    ),
                  ],
                );
              })
          : Center(
              child: const CircularProgressIndicator(),
            ),
    );
  }
}

// ignore: camel_case_types
class showNotification extends StatefulWidget {
  showNotification({Key? key}) : super(key: key);

  @override
  State<showNotification> createState() => _showNotificationState();
}

// ignore: camel_case_types
class _showNotificationState extends State<showNotification> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.4,
            height: 50,
            child: Row(
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
                      Text('Đã chuyển dữ liệu vào kho lưu trữ',
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
