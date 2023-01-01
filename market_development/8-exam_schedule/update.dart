import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/format_date.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/market_development/order.dart';
import '../../../../model/market_development/union.dart';
import '../../../../model/market_development/xinghiep.dart';
import '../../../../model/model.dart';
import '../../../forms/market_development/utils/form.dart';
import '../../../forms/nhan_su/setting-data/depart.dart';
import '../../../utils/market_development.dart';

class UpdateLTT extends StatefulWidget {
  final String? idLTTUpdate;
  UpdateLTT({Key? key, this.idLTTUpdate}) : super(key: key);

  @override
  State<UpdateLTT> createState() => _UpdateLTTstate();
}

class _UpdateLTTstate extends State<UpdateLTT> {
  var resultLTTUpdate = {};
  var orderIdLTT;
  var time1;
  List<Order> listSearchBy = [];
  List<Depart> listDepart = [];
  Order? order;
  int? phongBanId;
  int? selectedDonHang;
  int? selectedNghiepDoan;
  int? selectedXinghiep;
  var selectedHTTT;

  String? congTyError;
  double? congTygHeightError;

  String? hinhThucThiTuyenError;
  double? hinhThucThiTuyenHeightError;

  List<UnionObj> listUnionObj = [];
  List<Enterprise> listEnterprise = [];
  var listNghiepDoan;

  var listXiNghiep;

  String? timeDayTT;
  var timeTT;
  String? timeHoursTT;
  late Future futureXiNghiep;

  TextEditingController textDiaDiem = TextEditingController();
  TextEditingController textTTDPV = TextEditingController();
  TextEditingController textContent = TextEditingController();

  var listDonHangCT;

  String? nghiepDoan;
  String? xiNghiep;

  var listDonhang;
  var listLTT;

  var listDonHang;

  List<dynamic> appRove = [
    {"key": 0, "value": " Thi tuyển trực tiếp"},
    {"key": 1, "value": " ĐThi tuyển online"},
  ];
  var listLTTUpdate;

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
    // UnionObj union = new UnionObj(
    //   id: -1,
    //   orgCode: "",
    //   orgName: "",
    // );
    List<UnionObj> list = content.map((e) {
      return UnionObj.fromJson(e);
    }).toList();
    setState(() {
      listUnionObj = list;
    });
    return list;
  }

  Future<List<Order>> getListOrderSearchBy() async {
    var response;
    response = await httpGet("/api/donhang/get/page", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
        listSearchBy = content.map((e) {
          return Order.fromJson(e);
        }).toList();
        // Order order = new Order(id: -1, union: null, enterprise: null, jobs: null, orderCode: "", orderName: "Tất cả", orderStatusId: -1);
      });
    }

    return listSearchBy;
  }

  Future getlistLTTUpdate() async {
    await getListDepart();
    await getListOrderSearchBy();
    var response = await httpGet("/api/lichthituyen/get/${widget.idLTTUpdate}", context);
    if (response.containsKey("body")) {
      setState(() {
        listLTTUpdate = jsonDecode(response["body"]);
        selectedDonHang = listLTTUpdate['donhang']['id'];
        textDiaDiem.text = listLTTUpdate["address"];
        textTTDPV.text = listLTTUpdate["examGroup"];
        textContent.text = listLTTUpdate["content"];
        phongBanId = listLTTUpdate["teamId"];
        timeTT = listLTTUpdate["examDate"];
        selectedHTTT = listLTTUpdate["examMethod"];
        timeDayTT = timeTT.toString().substring(8, 10) + "-" + timeTT.toString().substring(5, 7) + "-" + timeTT.toString().substring(0, 4);
        timeHoursTT = timeTT.substring(11, 16);
        listDonHangCT = listLTTUpdate["donhang"];
        selectedXinghiep = listDonHangCT["companyId"];
        selectedNghiepDoan = listDonHangCT["orgId"];
      });
    }
    //await getDonHangg(listLTTUpdate["orderId"]);
    return listLTTUpdate;
  }

  // getDonHangg(id) async {
  //   var responseDH = await httpGet("/api/donhang/get/$id", context);
  //   if (responseDH.containsKey("body")) {
  //     setState(() {
  //       listDonHangCT = jsonDecode(responseDH["body"]);
  //       selectedXinghiep = listDonHangCT["companyId"];
  //       selectedNghiepDoan = listDonHangCT["orgId"];
  //     });
  //   }
  //   return listDonHangCT;
  // }

  Future<List<Depart>> getListDepart() async {
    var response;
    response = await httpGet("/api/phongban/get/page?filter=parentId:5", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      content = body['content'];
      listDepart = content.map((e) {
        return Depart.fromJson(e);
      }).toList();

      return listDepart;
    }

    return listDepart;
  }

  @override
  void initState() {
    super.initState();
    futureXiNghiep = getlistLTTUpdate();
    initData();
  }

  initData() async {
    await getListUnionSearchBy(context);
    await getListXiNghiepSearchBy(context);
  }

  Future<bool> putTtsLichsuThiTuyen(List<dynamic> listDynamic, context) async {
    try {
      var response = await httpPut(Uri.parse('/api/tts-lichsu-thituyen/put/all'), listDynamic, context); //Tra ve id
      if (jsonDecode(response['body']) == true) {
        return true;
      }
    } catch (_) {
      print("Fail!");
    }
    return false;
  }

  String? erDonHang;
  String? erNghiepDoan;
  String? erXiNghiep;
  String? erDiaDiem;
  String? erThoiGianThiTuyen;

  String? donHangError;
  double? donHangHeightError;
  final _myWidgetDiaDiem = GlobalKey<TextFieldValidatedMarketState>();
  final _myWidgetStateFromDate = GlobalKey<DatePickerBoxVQState1>();

  Future<List<dynamic>> getLichSuThiTuyen(int orderId) async {
    List<dynamic> listDataLichSuThiTuyen = [];
    var response = await httpGet("/api/tts-lichsu-thituyen/get/page?filter=orderId:$orderId AND donhang.closeNominateUser is not null AND examResult:0", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      content = body['content'];
      listDataLichSuThiTuyen = content.toList();
    }
    return listDataLichSuThiTuyen;
  }

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
      widgetBody: Consumer<NavigationModel>(
        builder: (context, navigationModel, child) => FutureBuilder<dynamic>(
            future: userRule('/them-moi-nghiep-doan', context),
            builder: (context, listRule) {
              if (listRule.hasData) {
                return ListView(
                  controller: ScrollController(),
                  children: [
                    TitlePage(
                      listPreTitle: [
                        {'url': '/phat-trien-thi-truong', 'title': 'Dashboard'},
                        {'url': '/lich-thi-tuyen', 'title': 'Lịch thi tuyển'},
                        {'url': null, 'title': 'Cập nhật'}
                      ],
                      content: 'Lịch thi tuyển',
                    ),
                    FutureBuilder(
                        future: futureXiNghiep,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Container(
                              padding: paddingBoxContainer,
                              margin: marginBoxFormTab,
                              width: MediaQuery.of(context).size.width * 1,
                              decoration: BoxDecoration(
                                color: colorWhite,
                                borderRadius: borderRadiusContainer,
                                boxShadow: [boxShadowContainer],
                                border: borderAllContainerBox,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Cập nhật',
                                        style: titleBox,
                                      ),
                                      Icon(
                                        Icons.more_horiz,
                                        color: colorIconTitleBox,
                                        size: sizeIconTitleBox,
                                      ),
                                    ],
                                  ),
                                  //--------------Đường line-------------
                                  Container(
                                    margin: marginTopBottomHorizontalLine,
                                    child: Divider(
                                      thickness: 1,
                                      color: ColorHorizontalLine,
                                    ),
                                  ),
                                  //------------kết thúc đường line--------
                                  // MyHomePage(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          height: 40,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                  flex: 3,
                                                  child: Text.rich(TextSpan(
                                                      text: "Đơn hàng", style: titleWidgetBox, children: <InlineSpan>[TextSpan(text: '*', style: TextStyle(color: Colors.red))]))),
                                              Expanded(
                                                flex: 6,
                                                child: Container(
                                                  height: 40,
                                                  child: DropdownSearch<Order>(
                                                    mode: Mode.MENU,
                                                    showSearchBox: true,
                                                    itemAsString: (Order? u) => u!.orderName,
                                                    items: listSearchBy,
                                                    dropdownSearchDecoration: getValidateDropDown(erDonHang, hinText: "Vui lòng chọn đơn hàng"),
                                                    emptyBuilder: (context, String? value) {
                                                      return const Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                                        child: Align(alignment: Alignment.center, child: Text("Không có dữ liệu !")),
                                                      );
                                                    },
                                                    selectedItem: listSearchBy.where((element) => element.id == selectedDonHang).toList().first,
                                                    onChanged: (value) async {
                                                      setState(() {
                                                        selectedDonHang = value!.id;
                                                        selectedNghiepDoan = value.union!.id;
                                                        selectedXinghiep = value.enterprise!.id;
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
                                      SizedBox(width: 60),
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          height: 40,
                                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text.rich(TextSpan(text: 'Nghiệp đoàn', style: titleWidgetBox, children: <InlineSpan>[
                                                TextSpan(
                                                  text: '*',
                                                  style: TextStyle(color: Colors.red),
                                                )
                                              ])),
                                            ),
                                            Expanded(
                                              flex: 6,
                                              child: Container(
                                                height: 40,
                                                child: DropdownSearch<UnionObj>(
                                                  mode: Mode.MENU,
                                                  maxHeight: 300,
                                                  showSearchBox: true,
                                                  enabled: false,
                                                  items: listUnionObj,
                                                  itemAsString: (UnionObj? u) => u!.orgName!,
                                                  dropdownSearchDecoration: getValidateDropDown(null),
                                                  selectedItem: selectedDonHang != null ? listUnionObj.where((element) => element.id == selectedNghiepDoan).toList().first : null,
                                                  emptyBuilder: (context, String? value) {
                                                    return const Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                                      child: Align(alignment: Alignment.center, child: Text("Không có dữ liệu !")),
                                                    );
                                                  },
                                                  onChanged: (value) async {
                                                    setState(() {
                                                      selectedNghiepDoan = value!.id;
                                                    });
                                                  },
                                                ),
                                              ),
                                            ),
                                          ]),
                                        ),
                                      )
                                    ],
                                  ),
                                  //-------------------------
                                  SizedBox(
                                    height: 35,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                            height: 40,
                                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                                              Expanded(
                                                flex: 3,
                                                child: Text.rich(TextSpan(text: 'Xí nghiệp', style: titleWidgetBox, children: <InlineSpan>[
                                                  TextSpan(
                                                    text: '*',
                                                    style: TextStyle(color: Colors.red),
                                                  )
                                                ])),
                                              ),
                                              Expanded(
                                                flex: 6,
                                                child: Container(
                                                  height: 40,
                                                  child: DropdownSearch<Enterprise>(
                                                    mode: Mode.MENU,
                                                    maxHeight: 300,
                                                    showSearchBox: true,
                                                    items: listEnterprise,
                                                    enabled: false,
                                                    itemAsString: (Enterprise? u) => u!.companyName,
                                                    dropdownSearchDecoration: getValidateDropDown(null),
                                                    selectedItem: selectedDonHang != null ? listEnterprise.where((element) => element.id == selectedXinghiep).toList().first : null,
                                                    emptyBuilder: (context, String? value) {
                                                      return const Padding(
                                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                                        child: Align(alignment: Alignment.center, child: Text("Không có dữ liệu !")),
                                                      );
                                                    },
                                                    onChanged: (value) {
                                                      setState(() {
                                                        selectedXinghiep = value!.id;
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ]),
                                          )),
                                      SizedBox(
                                        width: 60,
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Text.rich(TextSpan(text: 'Công ty', style: titleWidgetBox, children: <InlineSpan>[
                                                TextSpan(
                                                  text: '*',
                                                  style: TextStyle(color: Colors.red),
                                                )
                                              ])),
                                            ),
                                            Expanded(
                                              flex: 6,
                                              child: Container(
                                                height: congTygHeightError ?? 40,
                                                child: DropdownSearch<Depart>(
                                                  mode: Mode.MENU,
                                                  maxHeight: 300,
                                                  items: listDepart,
                                                  showSearchBox: true,
                                                  itemAsString: (Depart? u) => u!.departName,
                                                  dropdownSearchDecoration: getValidateDropDown(congTyError, hinText: "Vui lòng chọn công ty"),
                                                  enabled: false,
                                                  selectedItem: phongBanId != null ? listDepart.where((element) => element.id == phongBanId).first : null,
                                                  emptyBuilder: (context, String? value) {
                                                    return const Padding(
                                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                                      child: Align(alignment: Alignment.center, child: Text("Không có dữ liệu !")),
                                                    );
                                                  },
                                                  onChanged: (value) {
                                                    setState(() {
                                                      phongBanId = value!.id;
                                                      if (phongBanId != null) {
                                                        setState(() {
                                                          congTyError = null;
                                                          congTygHeightError = null;
                                                        });
                                                      }
                                                    });
                                                  },
                                                ),
                                              ),
                                            ), //
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 35,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: TextFieldValidatedMarket(
                                          key: _myWidgetDiaDiem,
                                          type: 'Text',
                                          height: 40,
                                          isShowDau: true,
                                          controller: textDiaDiem,
                                          flexLable: 3,
                                          flexTextField: 6,
                                          isReverse: false,
                                          labe: 'Địa điểm',
                                          marginBottom: 0,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 60,
                                      ),
                                      Expanded(flex: 3, child: Container())
                                    ],
                                  ),
                                  SizedBox(
                                    height: 35,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                                            Expanded(
                                              flex: 6,
                                              child: DatePickerBoxCustomForMarkert(
                                                  key: _myWidgetStateFromDate,
                                                  title: "Thời gian thi tuyển",
                                                  flexLabel: 3,
                                                  flexDatePiker: 6,
                                                  isTime: true,
                                                  isBlocDate: false,
                                                  isNotFeatureDate: true,
                                                  timeDisplay: timeHoursTT,
                                                  label: Row(
                                                    children: [
                                                      Text(
                                                        'Thời gian thi tuyển',
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
                                                  dateDisplay: timeDayTT,
                                                  selectedTimeFunction: (time) {
                                                    setState(() {
                                                      timeHoursTT = time;
                                                    });
                                                  },
                                                  selectedDateFunction: (day) {
                                                    setState(() {
                                                      timeDayTT = day;
                                                    });
                                                  }),
                                            )
                                          ])),
                                      SizedBox(
                                        width: 60,
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 3,
                                                child: Row(
                                                  children: [
                                                    Text('Hình thức thi tuyển', style: titleWidgetBox),
                                                    Container(
                                                      margin: EdgeInsets.only(left: 5),
                                                      child: Text(
                                                        "*",
                                                        style: TextStyle(color: Colors.red, fontSize: 16),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 6,
                                                child: Container(
                                                  color: Colors.white,
                                                  width: MediaQuery.of(context).size.width * 0.20,
                                                  height: hinhThucThiTuyenHeightError ?? 40,
                                                  child: DropdownSearch<dynamic>(
                                                    mode: Mode.MENU,
                                                    maxHeight: 150,
                                                    showSearchBox: false,
                                                    //enabled: widget.requestBody!["contractStatus"] == 3 ? false : true,
                                                    dropdownSearchDecoration: getValidateDropDown(hinhThucThiTuyenError, hinText: "Vui lòng chọn hình thức thi tuyển"),
                                                    itemAsString: (dynamic u) => u['value'],
                                                    selectedItem: selectedHTTT != null ? appRove.where((element) => element['key'] == selectedHTTT).toList().first : null,
                                                    items: appRove,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        selectedHTTT = value['key'];
                                                        print(selectedHTTT);
                                                        if (selectedHTTT != null) {
                                                          hinhThucThiTuyenHeightError = 40;
                                                          hinhThucThiTuyenError = null;
                                                        }
                                                      });
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 35,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                            height: 100,
                                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  'Thông tin đoàn phỏng vấn ',
                                                  style: titleWidgetBox,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 6,
                                                child: Container(
                                                  height: 100,
                                                  child: TextFormField(
                                                    controller: textTTDPV,
                                                    decoration: InputDecoration(
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(0)),
                                                        borderSide: BorderSide(
                                                          color: Colors.black,
                                                          width: 0.5,
                                                        ),
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.all(Radius.circular(0)),
                                                        borderSide: BorderSide(
                                                          color: Colors.black,
                                                          width: 0.5,
                                                        ),
                                                      ),
                                                    ),
                                                    minLines: 3, // any number you need (It works as the rows for the textarea)
                                                    keyboardType: TextInputType.multiline,
                                                    maxLines: null,
                                                  ),
                                                ),
                                              ),
                                            ]),
                                          )),
                                      SizedBox(
                                        width: 60,
                                      ),
                                      Expanded(
                                          flex: 3,
                                          child: Container(
                                            height: 100,
                                            child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                                              Expanded(
                                                flex: 3,
                                                child: Text(
                                                  'Nội dung thi tuyển ',
                                                  style: titleWidgetBox,
                                                ),
                                              ),
                                              Expanded(
                                                flex: 6,
                                                child: Container(
                                                  height: 100,
                                                  child: Column(
                                                    children: [
                                                      Expanded(
                                                        child: TextFormField(
                                                          controller: textContent,
                                                          decoration: InputDecoration(
                                                            focusedBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.all(Radius.circular(0)),
                                                              borderSide: BorderSide(
                                                                color: Colors.black,
                                                                width: 0.5,
                                                              ),
                                                            ),
                                                            enabledBorder: OutlineInputBorder(
                                                              borderRadius: BorderRadius.all(Radius.circular(0)),
                                                              borderSide: BorderSide(
                                                                color: Colors.black,
                                                                width: 0.5,
                                                              ),
                                                            ),
                                                          ),
                                                          minLines: 3, // any number you need (It works as the rows for the textarea)
                                                          keyboardType: TextInputType.multiline,
                                                          maxLines: null,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ]),
                                          ))
                                    ],
                                  ),

                                  Consumer<GetValueDropdow>(builder: (context, value, child) {
                                    return Padding(
                                      padding: const EdgeInsets.fromLTRB(30, 30, 0, 0),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          //tìm kiếm
                                          getRule(listRule.data, Role.Sua, context)
                                              ? Container(
                                                  margin: EdgeInsets.only(left: 20),
                                                  child: TextButton(
                                                    style: TextButton.styleFrom(
                                                      padding: paddingBtn,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(5.0),
                                                      ),
                                                      backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                                      primary: Theme.of(context).iconTheme.color,
                                                      textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                    ),
                                                    onPressed: () async {
                                                      try {
                                                        int countError = 0;
                                                        if (_myWidgetDiaDiem.currentState!.validate() == false) {
                                                          countError++;
                                                        }

                                                        if (_myWidgetStateFromDate.currentState!.validateDate() == false) {
                                                          countError++;
                                                        }
                                                        if (countError > 0) {
                                                          return;
                                                        }
                                                        var requestBody = {
                                                          "orderId": selectedDonHang,
                                                          "content": textContent.text,
                                                          "address": textDiaDiem.text,
                                                          "examDate": "${getDateInsertDBDdMmYyHhss(timeDayTT, timeHoursTT)}",
                                                          "examGroup": textTTDPV.text,
                                                          "examMethod": selectedHTTT,
                                                          "status": listLTTUpdate["status"],
                                                          "teamId": phongBanId
                                                        };
                                                        var response = await httpPut("/api/lichthituyen/put/${widget.idLTTUpdate}", requestBody, context);

                                                        if (jsonDecode(response['body']) == true) {
                                                          //Cập nhật ngày thi tuyển cho thực tập sinh trong lịch sử thi tuyển
                                                          Order? order = listSearchBy.where((element) => element.id == selectedDonHang).toList().first;
                                                          List<dynamic> listDataLichSuThiTuyen1 = await getLichSuThiTuyen(selectedDonHang!);
                                                          // List<dynamic> listTtsLichSuThiTuyen = [];
                                                          if (listDataLichSuThiTuyen1.isNotEmpty) {
                                                            for (var element in listDataLichSuThiTuyen1) {
                                                              element["examDate"] = getDateInsertDBDdMmYyHhss(timeDayTT, timeHoursTT);
                                                            }
                                                            bool result = await putTtsLichsuThiTuyen(listDataLichSuThiTuyen1, context);
                                                            if (result) {
                                                              //Cập nhật lại thông báo
                                                              try {
                                                                var responeThongBaoCuaLichThiTuyen =
                                                                    await httpGet("/api/thongbao/get/page?filter=notiType:2 AND typeId:${widget.idLTTUpdate}", context);
                                                                var body = jsonDecode(responeThongBaoCuaLichThiTuyen['body']);
                                                                if (responeThongBaoCuaLichThiTuyen.containsKey("body")) {
                                                                  var content = body['content'];
                                                                  if (content.length > 0) {
                                                                    for (var item in content) {
                                                                      try {
                                                                        await httpPut(
                                                                            "/api/thongbao/put/${item['id']}",
                                                                            {
                                                                              "notiType": 2, //2:Lịch thi tuyển
                                                                              "content":
                                                                                  "Lịch thi tuyển ${order.orderName}(${order.orderCode}) của bạn đã được cập nhật vào ngày ${getDateViewDayAndHour(convertTimeStamp(timeDayTT.toString(), timeHoursTT))}",
                                                                              "implementDate": "${FormatDate.formatDateInsertDB(DateTime.now())}",
                                                                              "typeId": widget.idLTTUpdate
                                                                            },
                                                                            context);
                                                                      } catch (_) {
                                                                        print("Lỗi update lịch thi tuyển");
                                                                      }
                                                                    }
                                                                  }
                                                                }

                                                                //Thông báo cho phòng ban
                                                                await httpPost(
                                                                    "/api/push/tags/depart_id/5&3&6&2",
                                                                    {
                                                                      "title": "Hệ thống thông báo",
                                                                      "message":
                                                                          "Có lịch thi tuyển đơn hàng ${order.orderCode}-${order.orderName} lúc ${getDateViewDayAndHour(convertTimeStamp(timeDayTT.toString(), timeHoursTT))}."
                                                                    },
                                                                    context);
                                                                //Thông báo cho tts

                                                                String condition = "";
                                                                for (int i = 0; i < listDataLichSuThiTuyen1.length; i++) {
                                                                  if (i == 0) {
                                                                    condition += listDataLichSuThiTuyen1[i]['thuctapsinh']['userCode'];
                                                                  } else {
                                                                    condition += "&" + listDataLichSuThiTuyen1[i]['thuctapsinh']['userCode'];
                                                                  }
                                                                }
                                                                //Thông báo cho từng tts
                                                                if (condition.isNotEmpty) {
                                                                  await httpPost(
                                                                      "/api/push/tags/user_code/$condition",
                                                                      {
                                                                        "title": "Hệ thống thông báo",
                                                                        "message":
                                                                            " Bạn có lịch thi tuyển đơn hàng ${order.orderCode}-${order.orderName} lúc ${getDateViewDayAndHour(convertTimeStamp(timeDayTT.toString(), timeHoursTT))}."
                                                                      },
                                                                      context);
                                                                }
                                                              } catch (e1) {
                                                                print(e1);
                                                              }
                                                              //Kết thúc cập nhật lịch thông báo

                                                              Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/lich-thi-tuyen");

                                                              showToast(
                                                                  context: context, msg: "Cập nhật thành công!", color: Colors.green, icon: Icon(Icons.supervised_user_circle));
                                                              return;
                                                            } else {
                                                              showToast(
                                                                  context: context, msg: "Cập nhật không thành công!", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
                                                              return;
                                                            }
                                                          }
                                                          Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/lich-thi-tuyen");
                                                          showToast(
                                                              context: context,
                                                              msg: "Cập nhật thông tin thành công!",
                                                              color: Colors.green,
                                                              icon: Icon(Icons.supervised_user_circle));
                                                        } else {
                                                          return showToast(
                                                              context: context,
                                                              msg: "Cập nhật không thành công! Các trường dữ liệu bắt buộc không được để trống",
                                                              color: Colors.red,
                                                              icon: Icon(Icons.error));
                                                        }
                                                      } catch (e) {
                                                        print("Lỗi $e");
                                                      }
                                                    },
                                                    child: Row(
                                                      children: [
                                                        Text('Lưu', style: textButton),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                          Container(
                                            margin: marginLeftBtn,
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                padding: paddingBtn,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: borderRadiusBtn,
                                                ),
                                                backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                                primary: Colors.white,
                                                textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                              ),
                                              onPressed: () {
                                                Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/lich-thi-tuyen");
                                                showToast(
                                                  context: context,
                                                  msg: "Đã hủy cập nhật lịch thi tuyển",
                                                  color: Color.fromARGB(135, 247, 217, 179),
                                                  icon: const Icon(Icons.done),
                                                );
                                              },
                                              child: Row(
                                                children: [
                                                  Text('Hủy', style: textButton),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  })
                                ], //------------------column trang------------------------------
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          }
                          return const Center(child: CircularProgressIndicator());
                        }),
                    //--------------Chân trang--------
                  ],
                );
              } else if (listRule.hasError) {
                return Text('${listRule.error}');
              }
              return Center(child: CircularProgressIndicator());
            }),
      ),
    );
  }
}
