import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';
import 'package:gentelella_flutter/widgets/forms/nhan_su/setting-data/depart.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:provider/provider.dart';
import '../../../../../common/style.dart';
import '../../../../../common/widgets_form.dart';
import '../../../../../model/model.dart';
import '../../../../api.dart';
import '../../../../common/format_date.dart';
import '../../../../common/toast.dart';
import '../../../../model/market_development/order.dart';
import '../../../../model/market_development/union.dart';
import '../../../../model/market_development/xinghiep.dart';
import '../../../utils/market_development.dart';
import '../../../forms/market_development/utils/form.dart';

class FormExamScheduleAdd extends StatelessWidget {
  const FormExamScheduleAdd({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: FormExamScheduleAddBody());
  }
}

class FormExamScheduleAddBody extends StatefulWidget {
  const FormExamScheduleAddBody({Key? key}) : super(key: key);

  @override
  State<FormExamScheduleAddBody> createState() => _FormExamScheduleAddBodyState();
}

class _FormExamScheduleAddBodyState extends State<FormExamScheduleAddBody> {
  TextEditingController textEditingController = TextEditingController();
  TextEditingController textXiNghiepAdd = TextEditingController();
  TextEditingController textNghiepDoanAdd = TextEditingController();
  TextEditingController textDiaDiem = TextEditingController();
  TextEditingController textDPV = TextEditingController();
  TextEditingController textContent = TextEditingController();

  DateTime selectedDate = DateTime.now();
  //url trang them moi cap nhat quan lys thong tin tts
  final String urlAdd = "lich-thi-tuyen/add";
  Order? donHang;
  Depart? phongBan;
  List<Enterprise> listEnterprise = [];
  List<UnionObj> listUnionObj = [];
  List<Depart> listDepart = [];
  UnionObj? unionObj;

  int? selectedXinghiep;
  int? selectedNghiepDoan;
  int? selectedDepart;

  var listDonHangThemMoi;
  late Future futureXiNghiepAdd;
  String? timeday;
  String? timehour;

  String? nghiepDoanThemMoi;
  String? xiNghiepThemMoi;

  // Map<int, String> appRove = {
  //   0: 'Thi tuy???n tr???c ti???p',
  //   1: 'Thi tuy???n online',
  // };

  List<dynamic> appRove = [
    {"key": 0, "value": " Thi tuy???n tr???c ti???p"},
    {"key": 1, "value": " ??Thi tuy???n online"},
  ];

  // ignore: unused_field
  bool _setLoading1 = false;
  var valueListDonHang;
  var dsxinghiep;
  var dsnghiepdoan;
  var selectedHTTT;

  String? erDonHang;
  String? erNghiepDoan;
  String? erXiNghiep;
  String? erDiaDiem;
  String? erThoiGianThiTuyen;

  String? donHangError;
  double? donHangHeightError;

  String? congTyError;
  double? congTygHeightError;

  String? hinhThucThiTuyenError;
  double? hinhThucThiTuyenHeightError;

  final _myWidgetDiaDiem = GlobalKey<TextFieldValidatedMarketState>();
  final _myWidgetStateFromDate = GlobalKey<DatePickerBoxVQState1>();
  // Future<List<UnionObj>> getListUnionSearchBy(context, {key}) async {
  //   var response;
  //   response = await httpGet("/api/nghiepdoan/get/page", context);
  //   var body = jsonDecode(response['body']);
  //   var content = [];
  //   if (response.containsKey("body")) {
  //     content = body['content'];
  //   }
  //   // ignore: unused_local_variable
  //   UnionObj union = new UnionObj(
  //     id: -1,
  //     orgCode: "",
  //     orgName: "",
  //   );
  //   List<UnionObj> list = content.map((e) {
  //     return UnionObj.fromJson(e);
  //   }).toList();
  //   setState(() {
  //     listUnionObj = list;
  //   });
  //   return list;
  // }

  // Future<List<Enterprise>> getListXiNghiepSearchBy(context, {key}) async {
  //   List<Enterprise> list = [];
  //   var response;

  //   response = await httpGet("/api/xinghiep/get/page?sort=id", context);

  //   var body = jsonDecode(response['body']);
  //   var content = [];

  //   if (response.containsKey("body")) {
  //     content = body['content'];
  //   }
  //   list = content.map((e) {
  //     return Enterprise.fromJson(e);
  //   }).toList();
  //   // ignore: unused_local_variable
  //   Enterprise enterprise =
  //       new Enterprise(id: -1, companyCode: "", companyName: "", orgId: -1, address: "", job: "", description: "", status: -1, createdUser: -1, createdDate: "");
  //   setState(() {
  //     listEnterprise = list;
  //   });
  //   return list;
  // }

  Future<List<Order>> getListOrderSearchBy() async {
    List<Order> listSearchBy = [];
    var response;
    response = await httpGet("/api/donhang/get/page?filter=closeNominateUser is not null", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      content = body['content'];
      listSearchBy = content.map((e) {
        return Order.fromJson(e);
      }).toList();

      return listSearchBy;
    }

    return listSearchBy;
  }

  Future<List<Depart>> getListDepart() async {
    List<Depart> listDepart = [];
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

  Future<List<dynamic>> getLichSuThiTuyen(int orderId) async {
    List<dynamic> listDataLichSuThiTuyen = [];
    var response =
        await httpGet("/api/tts-lichsu-thituyen/get/page?filter=orderId:$orderId AND donhang.closeNominateUser is not null AND donhang.nominateStatus:1 AND examResult:0", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      content = body['content'];
      listDataLichSuThiTuyen = content.toList();
    }
    return listDataLichSuThiTuyen;
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

  initData() async {
    // await getListUnionSearchBy(context);
    // await getListXiNghiepSearchBy(context);
    await getListOrderSearchBy();
    await getListDepart();
    setState(() {
      _setLoading1 = true;
    });
  }

  void initState() {
    super.initState();
    initData();
  }

  bool validateForm() {
    //Validate
    int countError = 0;
    if (_myWidgetDiaDiem.currentState!.validate() == false) {
      countError++;
    }

    if (donHang == null) {
      countError++;
      setState(() {
        donHangHeightError = 63;
        erDonHang = "Tr?????ng ????n h??ng kh??ng ???????c b??? tr???ng!";
      });
    }
    if (phongBan == null) {
      countError++;
      setState(() {
        congTygHeightError = 63;
        congTyError = "Tr?????ng c??ng ty kh??ng ???????c b??? tr???ng!";
      });
    }
    if (selectedHTTT == null) {
      countError++;
      setState(() {
        hinhThucThiTuyenHeightError = 63;
        hinhThucThiTuyenError = "Tr?????ng c??ng ty kh??ng ???????c b??? tr???ng!";
      });
    }

    if (_myWidgetStateFromDate.currentState!.validateDate() == false) {
      countError++;
    }
    if (countError > 0) {
      return false;
    }
    return true;
  }

  banThongBao(donHang) async {
    await httpPost(
        "/api/push/tags/depart_id/5&3&6&2",
        {
          "title": "H??? th???ng th??ng b??o",
          "message": "C?? l???ch thi tuy???n ????n h??ng ${donHang!.orderCode}-${donHang!.orderName} l??c ${getDateViewDayAndHour(convertTimeStamp(timeday.toString(), timehour))}."
        },
        context);
  }

  banThongBaoChoTts(listDataLichSuThiTuyen1, donHang, timeday, timehour) async {
    String condition = "";
    for (int i = 0; i < listDataLichSuThiTuyen1.length; i++) {
      if (i == 0) {
        condition += listDataLichSuThiTuyen1[i]['thuctapsinh']['userCode'];
      } else {
        condition += "&" + listDataLichSuThiTuyen1[i]['thuctapsinh']['userCode'];
      }
    }
    //Th??ng b??o cho t???ng tts
    if (condition.isNotEmpty) {
      await httpPost(
          "/api/push/tags/user_code/$condition",
          {
            "title": "H??? th???ng th??ng b??o",
            "message": "B???n c?? l???ch thi tuy???n ????n h??ng ${donHang!.orderCode}-${donHang!.orderName} l??c ${getDateViewDayAndHour(convertTimeStamp(timeday.toString(), timehour))}."
          },
          context);
    }
  }

  thongBaoThanhCong(context, msg, color, icon) {}

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: userRule('/them-moi-lich-thi-tuyen', context),
        builder: (context, listRule) {
          if (listRule.hasData) {
            return Consumer<NavigationModel>(
              builder: (context, navigationModel, child) => ListView(
                controller: ScrollController(),
                children: [
                  TitlePage(
                    listPreTitle: [
                      {'url': '/phat-trien-thi-truong', 'title': 'Dashboard'},
                      {'url': '/lich-thi-tuyen', 'title': 'L???ch thi tuy???n'},
                      {'url': null, 'title': 'Th??m m???i'},
                    ],
                    content: 'L???ch thi tuy???n',
                  ),
                  Container(
                    padding: paddingBoxContainer,
                    margin: marginBoxFormTab,
                    width: MediaQuery.of(context).size.width * 1,
                    decoration: BoxDecoration(
                      color: colorWhite,
                      borderRadius: borderRadiusContainer,
                      boxShadow: [boxShadowContainer],
                      border: borderAllContainerBox,
                    ),
                    child: SingleChildScrollView(
                      child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Form nh???p',
                              style: titleBox,
                            ),
                            Icon(
                              Icons.more_horiz,
                              color: colorIconTitleBox,
                              size: sizeIconTitleBox,
                            ),
                          ],
                        ),
                        //--------------???????ng line-------------
                        Container(
                          margin: marginTopBottomHorizontalLine,
                          child: Divider(
                            thickness: 1,
                            color: ColorHorizontalLine,
                          ),
                        ),
                        //------------k???t th??c ???????ng line--------

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text.rich(TextSpan(text: '????n h??ng', style: titleWidgetBox, children: <InlineSpan>[
                                      TextSpan(
                                        text: '*',
                                        style: TextStyle(color: Colors.red),
                                      )
                                    ])),
                                  ),
                                  Expanded(
                                    flex: 6,
                                    child: Container(
                                      height: donHangHeightError ?? 40,
                                      child: DropdownSearch<Order>(
                                        mode: Mode.MENU,
                                        showSearchBox: true,
                                        onFind: (String? filter) => getListOrderSearchBy(),
                                        itemAsString: (Order? u) => u!.orderName + "(${u.orderCode})",
                                        dropdownSearchDecoration: getValidateDropDown(erDonHang, hinText: "Vui l??ng ch???n ????n h??ng"),
                                        emptyBuilder: (context, String? value) {
                                          return const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                            child: Align(alignment: Alignment.center, child: Text("Kh??ng c?? d??? li???u !")),
                                          );
                                        },
                                        selectedItem: donHang,
                                        onChanged: (value) async {
                                          print("aaaaaaaaaaaaaa" + value.toString());
                                          setState(() {
                                            donHang = value!;
                                            if (donHang != null) {
                                              setState(() {
                                                phongBan = donHang!.union!.phongban;
                                                erDonHang = null;
                                                donHangHeightError = null;
                                              });
                                            }
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 60),
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
                                      child: Text.rich(TextSpan(text: 'Nghi???p ??o??n', style: titleWidgetBox, children: <InlineSpan>[
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
                                          items: listUnionObj,
                                          dropdownSearchDecoration: getValidateDropDown(null),
                                          enabled: false,
                                          itemAsString: (UnionObj? u) => u!.orgName!,
                                          selectedItem: donHang != null ? donHang!.union! : null,
                                          emptyBuilder: (context, String? value) {
                                            return const Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 10),
                                              child: Align(alignment: Alignment.center, child: Text("Kh??ng c?? d??? li???u !")),
                                            );
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                              selectedNghiepDoan = value!.id;
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
                        SizedBox(height: 35),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text.rich(TextSpan(text: 'X?? nghi???p', style: titleWidgetBox, children: <InlineSpan>[
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
                                        itemAsString: (Enterprise? u) => u!.companyName,
                                        dropdownSearchDecoration: getValidateDropDown(null),
                                        enabled: false,
                                        selectedItem: donHang != null ? donHang!.enterprise! : null,
                                        emptyBuilder: (context, String? value) {
                                          return const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                            child: Align(alignment: Alignment.center, child: Text("Kh??ng c?? d??? li???u !")),
                                          );
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            selectedXinghiep = value!.id;
                                          });
                                        },
                                      ),
                                    ),
                                  ), //
                                ],
                              ),
                            ),
                            SizedBox(width: 60),
                            Expanded(
                              flex: 3,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Text.rich(TextSpan(text: 'C??ng ty', style: titleWidgetBox, children: <InlineSpan>[
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
                                        showSearchBox: true,
                                        onFind: (String? filter) => getListDepart(),
                                        itemAsString: (Depart? u) => u!.departName,
                                        dropdownSearchDecoration: getValidateDropDown(congTyError, hinText: "Vui l??ng ch???n c??ng ty"),
                                        enabled: false,
                                        selectedItem: donHang != null ? donHang!.union!.phongban : null,
                                        emptyBuilder: (context, String? value) {
                                          return const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                            child: Align(alignment: Alignment.center, child: Text("Kh??ng c?? d??? li???u !")),
                                          );
                                        },
                                        onChanged: (value) {
                                          setState(() {
                                            phongBan = value;
                                            if (phongBan != null) {
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
                        SizedBox(height: 35),
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
                                labe: '?????a ??i???m',
                                marginBottom: 0,
                              ),
                            ),
                            SizedBox(width: 60),
                            Expanded(
                              flex: 3,
                              child: Container(),
                            ),
                          ],
                        ),
                        SizedBox(height: 35),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 6,
                                    child: DatePickerBoxCustomForMarkert(
                                        key: _myWidgetStateFromDate,
                                        title: "Th???i gian thi tuy???n",
                                        flexLabel: 3,
                                        flexDatePiker: 6,
                                        isTime: true,
                                        isBlocDate: false,
                                        isNotFeatureDate: true,
                                        timeDisplay: timehour,
                                        label: Row(
                                          children: [
                                            Text(
                                              'Th???i gian thi tuy???n',
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
                                        dateDisplay: timeday,
                                        selectedTimeFunction: (time) {
                                          setState(() {
                                            timehour = time;
                                          });
                                        },
                                        selectedDateFunction: (day) {
                                          setState(() {
                                            timeday = day;
                                          });
                                        }),
                                  )
                                ],
                              ),
                            ),
                            SizedBox(width: 60),
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
                                          Text('H??nh th???c thi tuy???n', style: titleWidgetBox),
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
                                          dropdownSearchDecoration: getValidateDropDown(hinhThucThiTuyenError, hinText: "Vui l??ng ch???n h??nh th???c thi tuy???n"),
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
                        SizedBox(height: 35),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                height: 100,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Th??ng tin ??o??n ph???ng v???n ',
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
                                                controller: textDPV,
                                                onChanged: (value) {
                                                  value = textDPV.text;
                                                },
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
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(width: 60),
                            Expanded(
                              flex: 3,
                              child: Container(
                                height: 100,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        'N???i dung thi tuy???n ',
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
                                                onChanged: ((value) {
                                                  value = textContent.text;
                                                }),
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
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Consumer<GetValueDropdow>(builder: (context, value, child) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(30, 30, 0, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                //t??m ki???m
                                getRule(listRule.data, Role.Them, context)
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
                                          onPressed: (() async {
                                            if (!validateForm()) {
                                              return;
                                            }
                                            var response = await httpGet("/api/lichthituyen/get/page?filter=orderId:${donHang!.id} AND status:0", context);
                                            if (response.containsKey("body")) {
                                              var content = jsonDecode(response["body"]);
                                              List<dynamic> list = content['content'];
                                              if (list.isNotEmpty) {
                                                showToast(
                                                    context: context,
                                                    msg: "???? t???n t???i l???ch thi tuy???n c???a ????n h??ng " + donHang!.orderName.toString(),
                                                    color: Colors.orange,
                                                    icon: Icon(Icons.warning));
                                                return;
                                              }
                                            }
                                            try {
                                              //Th??m m???i l???ch thi tuy???n

                                              var requestBody = {
                                                "orderId": donHang!.id,
                                                "content": textContent.text,
                                                "address": textDiaDiem.text,
                                                "examDate": "${getDateInsertDBDdMmYyHhss(timeday, timehour)}",
                                                "examGroup": textDPV.text,
                                                "examMethod": selectedHTTT,
                                                "status": 0,
                                                "teamId": phongBan!.id
                                              };

                                              var response1 = await httpPost("/api/lichthituyen/post/save", requestBody, context);

                                              //Ki???m tra th??m m???i th??nh c??ng th?? c???p nh???t l???ch s??? thi tuy???n
                                              if (isNumber(jsonDecode(response1['body']).toString())) {
                                                //C???p nh???t ng??y thi tuy???n cho th???c t???p sinh trong l???ch s??? thi tuy???n
                                                List<dynamic> listDataLichSuThiTuyen1 = await getLichSuThiTuyen(donHang!.id);
                                                if (listDataLichSuThiTuyen1.isNotEmpty) {
                                                  for (var element in listDataLichSuThiTuyen1) {
                                                    element['examDate'] = getDateInsertDBDdMmYyHhss(timeday, timehour);
                                                  }
                                                  bool result = await putTtsLichsuThiTuyen(listDataLichSuThiTuyen1, context);
                                                  if (result) {
                                                    try {
                                                      await banThongBao(donHang);
                                                      await banThongBaoChoTts(listDataLichSuThiTuyen1, donHang, timeday, timehour);
                                                    } catch (e) {
                                                      print(e);
                                                    }
                                                    showToast(context: context, msg: "Th??m m???i th??nh c??ng!", color: Colors.green, icon: Icon(Icons.supervised_user_circle));
                                                    Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/lich-thi-tuyen");
                                                    return;
                                                  } else {
                                                    Navigator.of(context).pop(true);
                                                    showToast(context: context, msg: "C???p nh???t kh??ng th??nh c??ng!", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
                                                    Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/lich-thi-tuyen");
                                                    return;
                                                  }
                                                }
                                              }
                                            } catch (e) {
                                              showToast(context: context, msg: "C???p nh???t kh??ng th??nh c??ng!", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
                                              Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/lich-thi-tuyen");
                                              return;
                                            }
                                            showToast(context: context, msg: "Th??m m???i th??nh c??ng!", color: Colors.green, icon: Icon(Icons.supervised_user_circle));
                                            Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/lich-thi-tuyen");
                                          }),
                                          child: Row(
                                            children: [
                                              Text('L??u', style: textButton),
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
                                        msg: "???? h???y th??m m???i l???ch thi tuy???n",
                                        color: Color.fromARGB(135, 247, 217, 179),
                                        icon: const Icon(Icons.done),
                                      );
                                    },
                                    child: Row(
                                      children: [
                                        Text('H???y', style: textButton),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        })
                      ]),
                    ),
                  ),
                ], //------------------column trang------------------------------
              ),
              //--------------Ch??n trang--------
            );
          } else if (listRule.hasError) {
            return Text('${listRule.error}');
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
