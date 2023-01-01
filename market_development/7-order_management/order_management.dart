import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';

import 'package:provider/provider.dart';

import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/format_date.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../config.dart';
import '../../../../model/market_development/job.dart';

import '../../../../model/market_development/order.dart';
import '../../../../model/market_development/status_order.dart';
import '../../../../model/market_development/union.dart';
import '../../../../model/market_development/xinghiep.dart';
import '../../../../model/model.dart';
import '../../../forms/market_development/utils/form.dart';
import '../../navigation.dart';
import '../3-enterprise_manager/enterprise_manager.dart';
import '../util/get-time-current.dart';
import 'order_modal_dung_thuc_hien.dart';
import 'service/service.dart';
import 'xuat_file.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:js' as js;

class OrderManagement extends StatelessWidget {
  SecurityModel? securityModel;
  OrderManagement({Key? key, this.securityModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: OrderManagementBody(securityModel: securityModel));
  }
}

class OrderManagementBody extends StatefulWidget {
  SecurityModel? securityModel;
  OrderManagementBody({Key? key, this.securityModel}) : super(key: key);

  @override
  State<OrderManagementBody> createState() => _OrderManagementBodyState();
}

class _OrderManagementBodyState extends State<OrderManagementBody> {
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
  final String urlAddNewUpdateSI = "/them-moi-don-hang";
  final String urlDetail = "/quan-li-don-hang/chi-tiet";

  List<Order> listOrder = [];
  List<Order> listOrderTamDungXuLy = [];
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

    String conditionByDepart = "";
    try {
      if (widget.securityModel != null) {
        if (widget.securityModel!.userLoginCurren != null) {
          if (widget.securityModel!.userLoginCurren['teamId'] != null) {
            conditionByDepart += " nhanvien_xuly.teamId:${widget.securityModel!.userLoginCurren['teamId']}";
          } else {
            conditionByDepart = "";
          }
        }
      }
    } catch (e) {
      print(e);
    }

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
        condition += " AND trangthai_donhang.statusName ~'*$statusName*'";
      }
    }
    if (jobName != null) {
      if (jobName.toString() == "Tất cả") {
        condition += " AND nganhnghe.jobName ~'**' ";
      } else {
        condition += " AND nganhnghe.jobName ~'*$jobName*' ";
      }
    }
    if (dateFrom1 != null) {
      condition += " AND publishDate >:'$dateFrom1' ";
    }
    if (dateTo1 != null) {
      condition += " AND publishDate <:'$dateTo1' ";
    }

    if (condition.isNotEmpty) {
      if (conditionByDepart.isNotEmpty) {
        response = await httpGet("/api/donhang/get/page?page=$page&size=$rowPerPage&filter=$condition AND $conditionByDepart", context);
      } else {
        response = await httpGet("/api/donhang/get/page?page=$page&size=$rowPerPage&filter=$condition", context);
      }
    } else {
      if (conditionByDepart.isNotEmpty) {
        response = await httpGet("/api/donhang/get/page?page=$page&size=$rowPerPage&filter=$conditionByDepart", context);
      } else {
        response = await httpGet("/api/donhang/get/page?page=$page&size=$rowPerPage", context);
      }
    }

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
    super.initState();
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

  handleButtonStartProcessing(securityModel) async {
    // var dateUtc1 = DateTime.now().toUtc();
    // var dateTime1 = DateFormat("HH:mm:ss dd-MM-yyyy").parse(dateUtc1, true);
    // var dateLocal = dateTime1.toLocal();
    print("oo ${getDateViewDayAndHour(FormatDate.formatDateInsertDBHHss(DateTime.now()))}");
    print(" ${getDateViewDayAndHour(FormatDate.formatDateInsertDBHHss(DateTime.now().toUtc()))}");
    // return;
    var content = await getCurrentTime(context);
    var dateTime = content != null ? content['datetime'] : null;
    var requestBody = {
      "orderStatusId": 2, //Trạng thái chờ xử lý
      "publishUser": securityModel.userLoginCurren['id'], //id của quangthaigiam
      "publishDate": dateTime
    };

    int countSucces = 0;
    for (var item in listOrderTamDungXuLy) {
      if (item.stopProcessing != 1) {
        //Loại bỏ những ông đã có trong tts-donhang
        bool result = await updateStatusOrder(requestBody, item.id, context);
        if (result) {
          countSucces++;
        }
      }
    }
    if (countSucces > 0) {
      showToast(
          context: context,
          msg: "Cập nhật trạng thái đơn hàng thành công $countSucces/${listOrderTamDungXuLy.length}",
          color: Colors.green,
          icon: Icon(Icons.supervised_user_circle));
      setState(() {
        _setLoading = true;
      });

      Future<List<Order>> _futureAfterUpdate = getListOrder(0, context, order: "");

      setState(() {
        futureListOrder = _futureAfterUpdate;
        _setLoading = false;
        listOrderSelectedChuaPhatHanh.clear();
      });

      //Thông báo lịch thị sát cho tất cả các phòng ban
      for (var item in listOrderTamDungXuLy) {
        if (item.stopProcessing != 1) {
          try {
            //Thông báo cho pttt
            print("Đơn hàng ${item.orderCode}-${item.orderName} được phát hành lúc ${getDateViewDayAndHour(dateTime)}.");
            await httpPost("/api/push/tags/depart_id/1&2&3&4&5&6&7&8&9&10&11&16&17&18&21&22&23&24",
                {"title": "Hệ thống thông báo", "message": "Đơn hàng ${item.orderCode}-${item.orderName} được phát hành lúc  ${getDateViewDayAndHour(dateTime)}."}, context);
          } catch (e) {
            print("Ex " + e.toString());
          }
        }
      }
    } else {
      showToast(context: context, msg: "Không cập nhật được số lượng bản ghi", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
    }
  }

  setLoadingWhenSubmit(value) {
    Future<List<Order>> _futureAfterUpdate = getListOrder(page - 1, context, order: "");

    setState(() {
      futureListOrder = _futureAfterUpdate;
      _setLoading = false;
    });
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

  Future<List<Enterprise>> getListXiNghiepSearchBy(context, {key}) async {
    List<Enterprise> list = [];
    var response;

    response = await httpGet("/api/xinghiep/get/page?sort=id", context);

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

    response = await httpGet("/api/nganhnghe/get/page?filter=parentId is null", context);

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
    var response = await httpGet("/api/donhang-trangthai/get/page?sort=id,asc", context);

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
      showToast(context: context, msg: body['1'], color: Colors.green, icon: Icon(Icons.abc));
    } else {
      showToast(context: context, msg: body['0'], color: Colors.red, icon: Icon(Icons.abc));
    }
  }

  bool checkStatusOrderDisable(Order order) {
    //widget.order!.stopProcessing == 1 Đang chờ xử lí tạm dừng
    //widget.order!.statusOrder!.id == 4 Dừng hẳn
    //widget.order!.statusOrder!.id == 5 Đã hoàn thành

    if (order.stopProcessing == 1 || order.statusOrder!.id == 4 || order.statusOrder!.id == 5) {
      return true;
    }
    return false;
  }

  String hienThiTooltip(Order order) {
    if (order.statusOrder!.id == 5) {
      return "Đơn hàng đã dừng hẳn";
    }
    if (order.statusOrder!.id == 4) {
      return "Đơn hàng đã hoàn thành";
    }
    if (order.stopProcessing == 1 && order.statusOrder!.id != 4) {
      return "Đơn hàng đang tạm dùng xử lý";
    }

    return "";
  }

  String getHienThiTrangThaiDonHang(Order order) {
    if (order.statusOrder!.id == 5 && order.stopProcessing == 1) {
      return "Tạm dừng xử lý -> " + order.statusOrder!.statusName.toString();
    }
    if (order.stopProcessing == 1) {
      return "Tạm dừng xử lý";
    }
    return order.statusOrder!.statusName.toString();
  }

  getColorByStatusOrder(Order order) {
    if (order.stopProcessing == 1 && order.statusOrder!.id != 5) {
      return Colors.orange;
    }
    if (order.statusOrder!.id == 5) {
      return Colors.red;
    }
    if (order.statusOrder!.id == 4) {
      return Colors.green;
    }
    return Colors.black;
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, String title) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) => pw.Placeholder(),
      ),
    );

    return pdf.save();
  }

  final ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: userRule('/quan-li-don-hang', context),
        builder: (context, listRule) {
          if (listRule.hasData) {
            return Consumer2<NavigationModel, SecurityModel>(
              builder: (context, navigationModel, securityModel, child) => _setLoading1
                  ? FutureBuilder<List<Order>>(
                      future: futureListOrder,
                      builder: (context, snapshot) {
                        double screenwidth = MediaQuery.of(context).size.width;
                        print(screenwidth);
                        return ListView(
                          children: [
                            TitlePage(
                              listPreTitle: [
                                {'url': '/phat-trien-thi-truong', 'title': 'Dashboard'},
                                {'url': '/quan-li-don-hang', 'title': 'Quản lý đơn hàng'}
                              ],
                              content: 'Quản lý đơn hàng',
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
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text('Xí nghiệp', style: titleWidgetBox),
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Container(
                                                        // width: MediaQuery.of(context).size.width * 0.15,

                                                        height: 40,
                                                        child: DropdownSearch<Enterprise>(
                                                          mode: Mode.MENU,
                                                          showSearchBox: true,
                                                          items: listEnterprise,
                                                          selectedItem: listEnterprise.first,
                                                          itemAsString: (Enterprise? u) => u!.companyName,
                                                          dropdownSearchDecoration: styleDropDown,
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
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text('Ngành nghề', style: titleWidgetBox),
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
                                              child: Container(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text('Trạng thái', style: titleWidgetBox),
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Container(
                                                        // decoration: styleDropDownSearchContainer,
                                                        // width: MediaQuery.of(context).size.width * 0.15,
                                                        height: 40,
                                                        child: DropdownSearch<StatusOrder>(
                                                          mode: Mode.MENU,
                                                          showSearchBox: true,
                                                          items: listStatusOrder,
                                                          itemAsString: (StatusOrder? u) => u!.statusName.trim(),
                                                          selectedItem: listStatusOrder.first,
                                                          dropdownSearchDecoration: styleDropDown,
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
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 3,
                                                      child: Container(
                                                        margin: EdgeInsets.only(bottom: 30),
                                                        child: DatePickerBoxVQ(
                                                            requestDayBefore: dateTo,
                                                            isTime: false,
                                                            label: Text(
                                                              'Từ ngày',
                                                              style: titleWidgetBox,
                                                            ),
                                                            dateDisplay: dateFrom,
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
                                                      margin: EdgeInsets.only(bottom: 30),
                                                      child: DatePickerBoxVQ(
                                                          requestDayAfter: dateFrom,
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
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(30, 30, 0, 0),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    getRule(listRule.data, Role.Xem, context)
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
                                                              onPressed: () async {
                                                                if (listOrderExcell.isEmpty) {
                                                                  showToast(context: context, msg: "Vui lòng chọn 1 đơn hàng !", color: Colors.yellow, icon: Icon(Icons.warning));
                                                                  return;
                                                                }
                                                                for (var item in listOrderExcell) {
                                                                  js.context.callMethod("myPrint", [
                                                                    item.orderCode,
                                                                    item.orderName,
                                                                    item.union!.orgCode,
                                                                    item.enterprise!.companyCode,
                                                                    item.workAddress,
                                                                    item.jobs!.jobName,
                                                                    item.jobsDetail!.jobName,
                                                                    item.implementTime,
                                                                    item.genderRequired,
                                                                    item.ageFrom,
                                                                    item.ageTo,
                                                                    item.ttsRequired,
                                                                    item.ttsMaleRequired,
                                                                    item.ttsFemaleRequired,
                                                                    item.ttsCandidates,
                                                                    item.ttsMaleCandidates,
                                                                    item.ttsFemaleCandidates,
                                                                    item.level!.name,
                                                                    item.skill,
                                                                    item.eyeSight,
                                                                    item.eyeSightGlasses,
                                                                    item.eyeSightSurgery,
                                                                    item.heigth,
                                                                    item.weight,
                                                                    item.rightHanded,
                                                                    item.leftHanded,
                                                                    item.maritalStatus,
                                                                    item.smoke,
                                                                    item.drinkAlcohol,
                                                                    item.tattoo,
                                                                    item.everSurgery,
                                                                    item.everCesareanSection,
                                                                    item.otherHealthRequired,
                                                                    item.otherHealthRequiredAccept,
                                                                    item.priorityCases,
                                                                    item.restrictionCases,
                                                                    item.recruiMethod,
                                                                    item.recruiContent,
                                                                    item.testFormNumber,
                                                                    getDateView(item.sendListFormDate),
                                                                    getDateView(item.estimatedInterviewDate),
                                                                    getDateView(item.estimatedAdmissionDate),
                                                                    getDateView(item.estimatedEntryDate),
                                                                    item.firstMonthSubsidy,
                                                                    item.salary,
                                                                    item.insurance,
                                                                    item.livingCost,
                                                                    item.netMoney,
                                                                    item.orderUrgent,
                                                                    item.image,
                                                                    item.image2,
                                                                    baseUrl,
                                                                    item.union!.phapNhan!.image,
                                                                    item.otherHealthRequiredAccept
                                                                  ]);
                                                                }
                                                              },
                                                              icon: Transform.rotate(
                                                                angle: 270,
                                                                child: Icon(
                                                                  Icons.file_open_sharp,
                                                                  color: Colors.white,
                                                                  size: 15,
                                                                ),
                                                              ),
                                                              label: Row(
                                                                children: [
                                                                  Text('In đơn hàng', style: textButton),
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                    getRule(listRule.data, Role.Sua, context)
                                                        ? Container(
                                                            margin: marginLeftBtn,
                                                            child: TextButton(
                                                              style: TextButton.styleFrom(
                                                                padding: paddingBtn,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: borderRadiusBtn,
                                                                ),
                                                                backgroundColor: listOrderTamDungXuLy.length > 0 ? Color.fromRGBO(245, 117, 29, 1) : Colors.grey,
                                                                primary: Theme.of(context).iconTheme.color,
                                                                textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                              ),
                                                              onPressed: listOrderTamDungXuLy.length > 0
                                                                  ? () {
                                                                      showDialog(
                                                                        context: context,
                                                                        builder: (BuildContext context) => ModalPerformOrder(
                                                                          listOrderSelected: listOrderTamDungXuLy,
                                                                          func: setLoadingWhenSubmit,
                                                                        ),
                                                                      );
                                                                    }
                                                                  : null,
                                                              child: Row(
                                                                children: [
                                                                  Text('Dừng thực hiện đơn hàng', style: textButton),
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                    getRule(listRule.data, Role.Sua, context)
                                                        ? Container(
                                                            margin: marginLeftBtn,
                                                            child: TextButton(
                                                              style: TextButton.styleFrom(
                                                                padding: paddingBtn,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: borderRadiusBtn,
                                                                ),
                                                                backgroundColor: listOrderSelectedChuaPhatHanh.isNotEmpty ? Color.fromRGBO(245, 117, 29, 1) : Colors.grey,
                                                                primary: Theme.of(context).iconTheme.color,
                                                                textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                              ),
                                                              onPressed: listOrderSelectedChuaPhatHanh.isNotEmpty
                                                                  ? () {
                                                                      showDialog(
                                                                        context: context,
                                                                        builder: (BuildContext context) => XacNhanXoaXiNghiep(
                                                                          title: "Xác nhận đơn hàng",
                                                                          label: "Bạn có muốn xác nhận đơn hàng này ?",
                                                                          function: () async {
                                                                            await handleButtonStartProcessing(securityModel);
                                                                          },
                                                                        ),
                                                                      );
                                                                    }
                                                                  : null,
                                                              child: Row(
                                                                children: [
                                                                  Text('Bắt đầu xử lý', style: textButton),
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
                                                    //end button Bắt đầu xử lý

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
                                                          if (dateFrom != null && dateTo != null) {
                                                            print(dateReverse(dateFrom));
                                                            DateTime dateTimeFrom = DateTime.parse(dateReverse(dateFrom));
                                                            DateTime dateTimeTo = DateTime.parse(dateReverse(dateTo));
                                                            if (dateTimeFrom.isAfter(dateTimeTo)) {
                                                              showToast(
                                                                  context: context,
                                                                  msg: "Từ ngày phải nhỏ hơn đến ngày !",
                                                                  color: Colors.red,
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
                                                    getRule(listRule.data, Role.Xem, context)
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
                                                              onPressed: () async {
                                                                print(listOrderExcell.length);
                                                                if (listOrderExcell.isNotEmpty) {
                                                                  onLoading(context);
                                                                  await createExcel(listOrderExcell).whenComplete(() => Navigator.pop(context));
                                                                } else {
                                                                  showToast(
                                                                      context: context,
                                                                      msg: "Vui lòng chọn ít nhất 1 bản ghi",
                                                                      color: Color.fromARGB(255, 212, 240, 135),
                                                                      icon: Icon(Icons.warning));
                                                                }
                                                              },
                                                              icon: Transform.rotate(
                                                                angle: 270,
                                                                child: Icon(
                                                                  Icons.file_open_sharp,
                                                                  color: Colors.white,
                                                                  size: 15,
                                                                ),
                                                              ),
                                                              label: Row(
                                                                children: [
                                                                  Text('Xuất file ', style: textButton),
                                                                ],
                                                              ),
                                                            ),
                                                          )
                                                        : Container(),
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
                                                                navigationModel.add(pageUrl: urlAddNewUpdateSI);
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
                                              'Quản lý đơn hàng',
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
                                              //Start Datatable
                                              !_setLoading
                                                  ? Container(
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
                                                              'Mã đơn hàng',
                                                              style: titleTableData,
                                                              // textAlign: TextAlign.center,
                                                            ),
                                                          ),
                                                          DataColumn(
                                                            label: Text(
                                                              'Tên đơn hàng',
                                                              style: titleTableData,
                                                              // textAlign: TextAlign.center,
                                                            ),
                                                          ),
                                                          DataColumn(
                                                            label: Text(
                                                              'Nghiệp đoàn',
                                                              style: titleTableData,
                                                              // textAlign: TextAlign.center,
                                                            ),
                                                          ),
                                                          DataColumn(
                                                            label: Text(
                                                              'Ngành nghề',
                                                              style: titleTableData,
                                                              // textAlign: TextAlign.center,
                                                            ),
                                                          ),
                                                          DataColumn(
                                                            label: Text(
                                                              'Người\nphụ trách',
                                                              style: titleTableData,
                                                              // textAlign: TextAlign.center,
                                                            ),
                                                          ),
                                                          DataColumn(
                                                            label: Text(
                                                              'Trạng\nthái',
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
                                                          for (int i = 0; i < listOrder.length; i++)
                                                            DataRow(
                                                              cells: <DataCell>[
                                                                DataCell(Container(
                                                                    width: (MediaQuery.of(context).size.width / 10) * 0.15,
                                                                    child: Text("${(currentPage - 1) * rowPerPage + i + 1}"))),
                                                                DataCell(Container(width: (MediaQuery.of(context).size.width / 10) * 0.7, child: Text(listOrder[i].orderCode))),
                                                                DataCell(
                                                                  Container(
                                                                      width: (MediaQuery.of(context).size.width / 10) * 0.8,
                                                                      child: Padding(
                                                                        padding: const EdgeInsets.all(10.0),
                                                                        child: Tooltip(
                                                                          message: "${listOrder[i].orderName}",
                                                                          child: Text(
                                                                            listOrder[i].orderName,
                                                                            maxLines: 2,
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      )),
                                                                ),
                                                                DataCell(
                                                                  Container(width: (MediaQuery.of(context).size.width / 10) * 0.6, child: Text(listOrder[i].union!.orgName!)),
                                                                ),
                                                                DataCell(Container(
                                                                    width: (MediaQuery.of(context).size.width / 10) * 0.6, child: Text(listOrder[i].jobs!.jobName.toString()))),
                                                                DataCell(
                                                                    Container(width: (MediaQuery.of(context).size.width / 10) * 0.4, child: Text(listOrder[i].user!.fullName))),
                                                                DataCell(Container(
                                                                  width: (MediaQuery.of(context).size.width / 10) * 0.7,
                                                                  child: Text(
                                                                    getHienThiTrangThaiDonHang(listOrder[i]),
                                                                    style: TextStyle(color: getColorByStatusOrder(listOrder[i])),
                                                                  ),
                                                                )),
                                                                DataCell(Row(
                                                                  children: [
                                                                    getRule(listRule.data, Role.Xem, context)
                                                                        ? Container(
                                                                            margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                            child: InkWell(
                                                                              onTap: () {
                                                                                navigationModel.add(pageUrl: "/xem-chi-tiet-don-hang/${listOrder[i].id}");
                                                                              },
                                                                              child: Icon(Icons.visibility),
                                                                            ),
                                                                          )
                                                                        : Container(),
                                                                    getRule(listRule.data, Role.Sua, context)
                                                                        ? Container(
                                                                            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                            child: Tooltip(
                                                                              message: hienThiTooltip(listOrder[i]),
                                                                              child: InkWell(
                                                                                  onTap: checkStatusOrderDisable(listOrder[i]) == false
                                                                                      ? () {
                                                                                          navigationModel.add(pageUrl: "/cap-nhat-don-hang/${listOrder[i].id}");
                                                                                        }
                                                                                      : null,
                                                                                  child: Icon(
                                                                                    Icons.edit_calendar,
                                                                                    color: checkStatusOrderDisable(listOrder[i]) == false ? Color(0xff009C87) : Colors.grey,
                                                                                  )),
                                                                            ))
                                                                        : Container(),
                                                                    getRule(listRule.data, Role.Xoa, context)
                                                                        ? Container(
                                                                            margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                            child: InkWell(
                                                                                onTap: () async {
                                                                                  showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) => XacNhanXoaXiNghiep(
                                                                                      label: "Bạn có muốn xóa đơn hàng này ?",
                                                                                      function: () async {
                                                                                        await deleteDonHang(listOrder[i].id);
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
                                                              selected: _selected[i],
                                                              onSelectChanged: (bool? value) {
                                                                setState(() {
                                                                  // _selectedTrue.clear();
                                                                  listOrderTamDungXuLy.clear();
                                                                  listOrderSelectedChuaPhatHanh.clear();
                                                                  listOrderExcell.clear();

                                                                  _selected[i] = value!;
                                                                  print(_selected);

                                                                  // print("Thái" + _selected.toString() + _selected.length.toString());
                                                                  // //listOrderExcell xuất execll
                                                                  for (int j = 0; j < _selected.length; j++) {
                                                                    if (_selected[j]) {
                                                                      listOrderExcell.add(listOrder[j]);
                                                                    }
                                                                  }
                                                                  // print(listOrderExcell.length);
                                                                  // //5 la dung xu li han
                                                                  // if (listOrder[i].statusOrder!.id == 5) {
                                                                  //   _selected[i] = false;
                                                                  //   showToast(
                                                                  //       context: context,
                                                                  //       msg: "Đơn hàng này đã dừng xử lý!",
                                                                  //       color: Color.fromARGB(135, 247, 217, 179),
                                                                  //       icon: Icon(Icons.supervised_user_circle));
                                                                  // } else if (listOrder[i] //4 la da hoan thanh
                                                                  //         .statusOrder!
                                                                  //         .id ==
                                                                  //     4) {
                                                                  //   _selected[i] = false;
                                                                  //   showToast(
                                                                  //       context: context,
                                                                  //       msg: "Đơn hàng này đã hoàn thành!",
                                                                  //       color: Color.fromARGB(135, 247, 217, 179),
                                                                  //       icon: Icon(Icons.supervised_user_circle));
                                                                  // } else {
                                                                  //   _selected[i] = value;
                                                                  // }

                                                                  for (int j = 0; j < _selected.length; j++) {
                                                                    if (_selected[j] == true &&
                                                                        listOrder[j].statusOrder!.id != 5 &&
                                                                        listOrder[j].statusOrder!.id != 4 &&
                                                                        listOrder[j].stopProcessing == 0) {
                                                                      print(listOrder[j]);
                                                                      listOrderTamDungXuLy.add(listOrder[j]);
                                                                    }
                                                                    if (_selected[j] == true &&
                                                                        listOrder[j].statusOrder!.id == 1 &&
                                                                        listOrder[j].nguoiXuatBan == null &&
                                                                        listOrder[j].stopProcessing == 0) {
                                                                      listOrderSelectedChuaPhatHanh.add(listOrder[j]);
                                                                    }
                                                                  }

                                                                  print(_selectedTrue);
                                                                  print(listOrderTamDungXuLy);
                                                                  print(listOrderSelectedChuaPhatHanh);
                                                                });
                                                              },
                                                            ),
                                                        ],
                                                      ))
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
                                                //page = page;
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
          } else if (listRule.hasError) {
            return Text('${listRule.error}');
          }
          return Center(child: CircularProgressIndicator());
        });
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
                      Text('Đã chuyển dữ liệu vào kho lưu trữ', style: TextStyle(fontSize: 16)),
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
