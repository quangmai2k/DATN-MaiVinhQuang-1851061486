import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/style.dart';
import 'package:intl/intl.dart';
import '../../../../api.dart';
import '../../../../common/format_date.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/market_development/order.dart';
import '../../../../model/market_development/union.dart';

var selectedOrderId;
var selectedOrderName;
var idDH;
var idND;
var countTTS;
var listThuongDonHangDeNghi = {};

TextEditingController title = TextEditingController();
final TextEditingController searchOrder = TextEditingController();
final TextEditingController searchUnion = TextEditingController();
bool check = false;

var listPay = {};
void _showMaterialDialog(BuildContext context, int index) {
  showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter _setState) {
          return AlertDialog(
            title: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          child: Image.asset('assets/images/logoAAM.png'),
                          margin: EdgeInsets.only(right: 10),
                        ),
                        Text(
                          'Danh sách nhân viên tuyển dụng',
                          style: TextStyle(
                              fontSize: 20,
                              color: Color(0xff333333),
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
                Text(
                  'Đơn hàng : $selectedOrderName',
                  style: TextStyle(
                      fontSize: 20,
                      color: Color(0xff333333),
                      fontWeight: FontWeight.w400),
                ),
                Container(
                  margin: marginTopBottomHorizontalLine,
                  child: Divider(
                    thickness: 1,
                    color: ColorHorizontalLine,
                  ),
                ),
                Container(
                    child: Row(
                  children: [
                    Expanded(
                        flex: 3,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text('Thưởng đơn hàng: ',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Color(0xff333333),
                                        fontWeight: FontWeight.w700)),
                                Text(' $listOrderBonus  VND/TTS ',
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Color(0xff333333),
                                        fontWeight: FontWeight.w400)),
                              ],
                            ),
                            Row(
                              children: [
                                Container(
                                    margin: EdgeInsets.only(top: 20),
                                    child: Text("")),
                              ],
                            )
                          ],
                        )),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(children: [
                        Container(
                          child: Row(
                            children: [
                              Text('Trạng thái thanh toán: ',
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xff333333),
                                      fontWeight: FontWeight.w700)),
                              (listPay["content"][0]["paidDate"] != null)
                                  ? (listPay["content"][0]["paidStatus"] == 2)
                                      ? Text(" Đã từ chối",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Color(0xff333333),
                                          ))
                                      : Text(" Đã thanh toán",
                                          style: TextStyle(
                                            fontSize: 18,
                                            color: Color(0xff333333),
                                          ))
                                  : Text(" Đã gửi thanh toán",
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Color(0xff333333),
                                      ))
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          child: Row(
                            children: [
                              Text("Ngày thanh toán: ",
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xff333333),
                                      fontWeight: FontWeight.w700)),
                              Text((listPay["content"][0]["paidDate"] != null)
                                  ? "${FormatDate.formatDateView(DateTime.parse(listPay["content"][0]["paidDate"]))}"
                                  : ''),
                            ],
                          ),
                        )
                      ]),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    )
                  ],
                )),
                Container(
                  // margin: marginTopBottomHorizontalLine,
                  margin: EdgeInsets.only(top: 10),
                  child: Divider(
                    thickness: 1,
                    color: ColorHorizontalLine,
                  ),
                ),
              ],
            ),
            //Bảng chot ds
            content: Container(
              width: 600,
              height: 300,
              child: DataTable(
                showCheckboxColumn: false,
                columns: [
                  DataColumn(label: Text('STT', style: titleTableData)),
                  DataColumn(
                      label: Text('Mã nhân viên', style: titleTableData)),
                  DataColumn(
                      label: Text('Tên nhân viên', style: titleTableData)),
                  DataColumn(
                      label: Text('Số lượng TTS', style: titleTableData)),
                  DataColumn(label: Text('Tổng tiền', style: titleTableData)),
                ],
                rows: <DataRow>[
                  if (listThuongDonHangDeNghi["content"] != null)
                    for (int i = 0;
                        i < listThuongDonHangDeNghi["content"].length;
                        i++)
                      DataRow(
                        cells: <DataCell>[
                          DataCell(Text("${i + 1}")),
                          DataCell(Text(
                            listThuongDonHangDeNghi["content"][i]["nhanvien"]
                                ["userCode"],
                            style: bangDuLieu,
                          )),

                          DataCell(Text(
                            listThuongDonHangDeNghi["content"][i]["nhanvien"]
                                ["fullName"],
                            style: bangDuLieu,
                          )),

                          DataCell(
                            TextButton(
                              child: Text(
                                listThuongDonHangDeNghi["content"][i]
                                        ["ttsTotal"]
                                    .toString(),
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w400),
                              ),
                              onPressed: () async {
                                var listTrainee = {};
                                var careUserId =
                                    listThuongDonHangDeNghi["content"][i]
                                        ["nhanvien"]['id'];
                                var response = await httpGet(
                                    "/api/tts-lichsu-thituyen/get/page?filter=orderId:$selectedOrderId and(thuctapsinh.stopProcessing is null or thuctapsinh.stopProcessing:0) and thuctapsinh.ttsStatusId!13 and examResult in (1,2) and thuctapsinh.careUser:$careUserId",
                                    context);
                                print(
                                    "/api/tts-lichsu-thituyen/get/page?filter=orderId:$selectedOrderId and(thuctapsinh.stopProcessing is null or thuctapsinh.stopProcessing:0) and examResult in (1,2) and thuctapsinh.careUser:$careUserId");
                                if (response.containsKey("body")) {
                                  listTrainee = jsonDecode(response["body"]);
                                }

                                final AlertDialog dialog1 = AlertDialog(
                                  title: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.55,
                                    child: SizedBox(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                height: 50,
                                                width: 50,
                                                child: Image.asset(
                                                    'assets/images/logoAAM.png'),
                                                margin:
                                                    EdgeInsets.only(right: 10),
                                              ),
                                              Text(
                                                'Danhh sách TTS',
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Color(0xff333333),
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                          IconButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            icon: Icon(Icons.close),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  content: DataTable(
                                    showCheckboxColumn: false,
                                    columns: [
                                      DataColumn(
                                          label: Text('STT',
                                              style: titleTableData)),
                                      DataColumn(
                                          label: Text('Mã TTS',
                                              style: titleTableData)),
                                      DataColumn(
                                          label: Text('Tên TTS',
                                              style: titleTableData)),
                                      DataColumn(
                                          label: Text('Ngày sinh',
                                              style: titleTableData)),
                                      DataColumn(
                                          label: Text('Trạng thái',
                                              style: titleTableData)),
                                    ],
                                    rows: <DataRow>[
                                      for (var i = 0;
                                          i < listTrainee["content"].length;
                                          i++)
                                        DataRow(
                                          cells: <DataCell>[
                                            DataCell(Text("${i + 1}")),
                                            DataCell(Text(
                                              (listTrainee["content"][i] !=
                                                      null)
                                                  ? listTrainee["content"][i]
                                                              ['thuctapsinh']
                                                          ["userCode"]
                                                      .toString()
                                                  : "",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400),
                                            )),
                                            DataCell(
                                              Text(
                                                  listTrainee["content"][i]
                                                              ['thuctapsinh']
                                                          ['fullName'] ??
                                                      "",
                                                  style: bangDuLieu),
                                            ),
                                            DataCell(Text(
                                                listTrainee["content"][i]
                                                                ['thuctapsinh']
                                                            ["birthDate"] !=
                                                        null
                                                    ? DateFormat("dd-MM-yyyy")
                                                        .format(DateTime.parse(
                                                            listTrainee["content"]
                                                                        [i][
                                                                    'thuctapsinh']
                                                                ["birthDate"]))
                                                    : "",
                                                style: bangDuLieu)),
                                            DataCell(
                                              Text(
                                                  listTrainee["content"][i][
                                                                  'thuctapsinh']
                                                              ["ttsTrangthai"]
                                                          ["statusName"] ??
                                                      "",
                                                  style: bangDuLieu),
                                            ),
                                          ],
                                        )
                                    ],
                                  ),
                                  actions: [],
                                );
                                showDialog<void>(
                                    context: context,
                                    builder: (context) => dialog1);
                              },
                            ),
                          ),
                          DataCell(
                            Text(
                              NumberFormat.simpleCurrency(locale: "vi")
                                  .format(listThuongDonHangDeNghi["content"][i]
                                      ["bonus"])
                                  .toString(),
                              style: bangDuLieu,
                            ),
                          ),

                          //
                        ],
                      )
                ],
              ),
            ),
            actions: <Widget>[],
          );
        });
      });
}

late Future futureListDonhang;
var listDHH = {};
var listAam = {};
int rowPerPage = 10;
int totalElements = 0;
int currentPage = 0;
String selectedDH = "";
String selectedND = "";
Widget paging = Container();
var resultListOrderBonus = {};
var listOrderBonus;

class ThuongDonHangLichSu extends StatefulWidget {
  ThuongDonHangLichSu({Key? key}) : super(key: key);

  @override
  State<ThuongDonHangLichSu> createState() => _ThuongDonHangLichSuState();
}

class _ThuongDonHangLichSuState extends State<ThuongDonHangLichSu> {
  Future getListDonHang(page) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }

    if (page < 1) {
      page = 0;
    }

    var response;
    if ((selectedDH == "" || selectedDH == "-1") &&
        (selectedND == "" || selectedND == '-1'))
      response = await httpGet(
          "/api/donhang/get/page?page=$page&size=$rowPerPage&filter=orderBonus!0",
          context); //thiếu (stopProcessing:0 or stopProcessing is null)
    else if ((selectedDH != "" || selectedDH != "-1") &&
        (selectedND == "" || selectedND == '-1')) {
      response = await httpGet(
          "/api/donhang/get/page?page=$page&size=$rowPerPage&sort=orderBonus&filter=id:$selectedDH and orderBonus!0",
          context);
    } else if ((selectedDH == "" || selectedDH == "-1") &&
        (selectedND != "" || selectedND != '-1')) {
      response = await httpGet(
          "/api/donhang/get/page?page=$page&size=$rowPerPage&sort=orderBonus&filter=nghiepdoan.id:$selectedND and orderBonus!0",
          context);
    } else {
      response = await httpGet(
          "/api/donhang/get/page?page=$page&size=$rowPerPage&sort=orderBonus&filter=id:$selectedDH AND nghiepdoan.id:$selectedND and orderBonus!0",
          context);
    }
    if (response.containsKey("body")) {
      setState(() {
        currentPage = page;
        listDHH = jsonDecode(response["body"]);
        totalElements = listDHH["totalElements"];
      });
    }
    return 0;
  }

  // Future getCountCareUser() async {
  //   var response = await httpGet("/api/nguoidung/get/count?filter=id:$idTTS", context);
  //   if (response.containsKey("body")) {
  //     setState(() {});
  //   }
  // }

  Future<List<Order>> getListOrder() async {
    List<Order> resultOrder = [];
    var response1 = await httpGet("/api/donhang/get/page?sort=id", context);
    var body = jsonDecode(response1['body']);
    var content = [];
    if (response1.containsKey("body")) {
      setState(() {
        content = body['content'];
        resultOrder = content.map((e) {
          return Order.fromJson(e);
        }).toList();
        Order all = new Order(
            id: -1,
            orderName: "Tất cả",
            enterprise: null,
            jobs: null,
            orderCode: '',
            orderStatusId: 0,
            union: null);
        resultOrder.insert(0, all);
      });
    }
    return resultOrder;
  }

  Future getOrderBonus() async {
    var response = await httpGet(
        "/api/thuong-chitieu-donhang/get/page?filter=orderId:$selectedOrderId and approve:1",
        context);
    if (response.containsKey("body")) {
      setState(() {
        resultListOrderBonus = jsonDecode(response["body"]);
      });
    }
    for (var element in resultListOrderBonus["content"]) {
      listOrderBonus = element["orderBonus"];
    }
  }

  var resultListOrderBonus1 = {};
  Future getOrderBonus1() async {
    var response = await httpGet(
        "/api/thuong-chitieu-donhang/get/page?filter= approve:1", context);
    if (response.containsKey("body")) {
      setState(() {
        resultListOrderBonus1 = jsonDecode(response["body"]);
      });
    }
    // for (var element in resultListOrderBonus["content"]) {
    //   listOrderBonus = element["orderBonus"];
    // }
  }

  var order = {};
  Future getOrder() async {
    print("getorder");
    print("/api/donhang/get/page?filter=id:$selectedOrderId");
    var response = await httpGet(
        "/api/donhang/get/page?filter=id:$selectedOrderId", context);
    if (response.containsKey("body")) {
      setState(() {
        order = jsonDecode(response["body"]);
      });
    }
    if (order["content"][0]["orderBonus"] != 0)
      check = true;
    else
      check = false;
  }

  Future<List<UnionObj>> getListUnion() async {
    List<UnionObj> resultUnion = [];
    var response = await httpGet("/api/nghiepdoan/get/page?sort=id", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
        resultUnion = content.map((e) {
          return UnionObj.fromJson(e);
        }).toList();
        UnionObj all = new UnionObj(id: -1, orgName: "Tất cả");
        resultUnion.insert(0, all);
      });
    }
    return resultUnion;
  }

  Future getPaidDate() async {
    var response = await httpGet(
        "/api/thuong-chitieu-denghi/get/page?filter=orderId:$selectedOrderId",
        context);
    if (response.containsKey("body")) {
      listPay = jsonDecode(response["body"]);
    }
  }

  getThuongDonHangDeNghi() async {
    var response = await httpGet(
        "/api/thuong-donhang-denghi-chitiet/get/page?filter=denghi.orderId:$selectedOrderId",
        context);
    if (response.containsKey("body")) {
      setState(
        () {
          listThuongDonHangDeNghi = jsonDecode(response["body"]);
        },
      );
    }
  }

  int getIndex(page, rowPerPage, index) {
    return ((page * rowPerPage) + index) + 1;
  }

  @override
  void initState() {
    super.initState();
    futureListDonhang = getListDonHang(currentPage);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureListDonhang,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (listDHH["content"].length > 0) {
              var firstRow = (currentPage) * rowPerPage + 1;
              var lastRow = (currentPage + 1) * rowPerPage;

              if (lastRow > listDHH["totalElements"]) {
                lastRow = listDHH["totalElements"];
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
                        getListDonHang(currentPage);
                      });
                    },
                    items: <int>[2, 5, 10, 25, 50, 100]
                        .map<DropdownMenuItem<int>>((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text("$value"),
                      );
                    }).toList(),
                  ),
                  Text(
                      "Dòng $firstRow - $lastRow của ${listDHH["totalElements"]}"),
                  IconButton(
                      onPressed: firstRow != 1
                          ? () {
                              getListDonHang(currentPage - 1);
                            }
                          : null,
                      icon: const Icon(Icons.chevron_left)),
                  IconButton(
                      onPressed: lastRow < listDHH["totalElements"]
                          ? () {
                              getListDonHang(currentPage + 1);
                            }
                          : null,
                      icon: const Icon(Icons.chevron_right)),
                ],
              );
            }
          }

          return Scaffold(
            body: ListView(children: [
              Container(
                color: backgroundPage,
                padding: EdgeInsets.symmetric(
                    vertical: verticalPaddingPage,
                    horizontal: horizontalPaddingPage),
                child: Container(
                  width: MediaQuery.of(context).size.width * 1,
                  decoration: BoxDecoration(
                    color: colorWhite,
                    borderRadius: borderRadiusContainer,
                    boxShadow: [boxShadowContainer],
                    border: borderAllContainerBox,
                  ),
                  padding: paddingBoxContainer,
                  child: Row(
                    children: [
                      Expanded(
                        // child: Padding(
                        //   padding: EdgeInsets.fromLTRB(60, 0, 0, 0),
                        child: Row(children: [
                          Text('Đơn hàng', style: titleWidgetBox),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 0, 50, 0),
                              child: Container(
                                height: 40,
                                child: DropdownSearch<Order>(
                                  // ignore: deprecated_member_use
                                  hint: "Tất cả",
                                  maxHeight: 350,
                                  mode: Mode.MENU,
                                  showSearchBox: true,
                                  onFind: (String? filter) => getListOrder(),
                                  itemAsString: (Order? u) =>
                                      '${u!.orderName}' + '(${u.orderCode})',
                                  dropdownSearchDecoration: styleDropDown,
                                  onChanged: (value) {
                                    setState(() {
                                      idDH = value!.id;
                                      selectedDH = idDH.toString();
                                      print(selectedDH);
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          Text('Nghiệp đoàn', style: titleWidgetBox),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
                              child: Container(
                                height: 40,
                                child: DropdownSearch<UnionObj>(
                                  // ignore: deprecated_member_use
                                  hint: "Tất cả",
                                  maxHeight: 350,
                                  mode: Mode.MENU,
                                  showSearchBox: true,
                                  onFind: (String? filter) => getListUnion(),
                                  itemAsString: (UnionObj? u) => u!.orgName!,
                                  dropdownSearchDecoration: styleDropDown,
                                  onChanged: (value) {
                                    setState(() {
                                      idND = value!.id;
                                      selectedND = idND.toString();
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                                margin: EdgeInsets.fromLTRB(50, 0, 50, 0),
                                child: Row(children: [
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 20.0,
                                        horizontal: 20.0,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      backgroundColor:
                                          Color.fromRGBO(245, 117, 29, 1),
                                      primary:
                                          Theme.of(context).iconTheme.color,
                                      textStyle: Theme.of(context)
                                          .textTheme
                                          .caption
                                          ?.copyWith(
                                              fontSize: 10.0,
                                              letterSpacing: 2.0),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        futureListDonhang =
                                            getListDonHang(currentPage);
                                        selectedND = "";
                                        selectedDH = "";
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Icon(Icons.search,
                                            color: Colors.white, size: 15),
                                        Text(' Tìm kiếm', style: textButton),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    height: 150,
                                  ),
                                ])),
                          )
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: backgroundPage,
                padding:
                    EdgeInsets.symmetric(horizontal: horizontalPaddingPage),
                child: Container(
                  width: MediaQuery.of(context).size.width * 1,
                  decoration: BoxDecoration(
                    color: colorWhite,
                    borderRadius: borderRadiusContainer,
                    boxShadow: [boxShadowContainer],
                    border: borderAllContainerBox,
                  ),
                  padding: paddingBoxContainer,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 1,
                        child: DataTable(
                          showCheckboxColumn: false,
                          columns: [
                            DataColumn(
                                label: Text('STT', style: titleTableData)),
                            DataColumn(
                                label:
                                    Text('Mã đơn hàng', style: titleTableData)),
                            DataColumn(
                                label: Text('Tên đơn hàng',
                                    style: titleTableData)),
                            DataColumn(
                                label:
                                    Text('Nghiệp đoàn', style: titleTableData)),
                          ],
                          rows: <DataRow>[
                            if (listDHH["content"] != null)
                              for (var i = 0;
                                  i < listDHH["content"].length;
                                  i++)
                                if (listDHH["content"][i]["orderBonus"] != 0 ||
                                    listDHH["content"][i]["orderBonus"] != null)
                                  DataRow(
                                    cells: <DataCell>[
                                      DataCell(Text(
                                        getIndex(currentPage, rowPerPage, i)
                                            .toString(),
                                      )),
                                      DataCell(TextButton(
                                        onPressed: () async {
                                          selectedOrderId =
                                              listDHH["content"][i]["id"];
                                          selectedOrderName = listDHH["content"]
                                              [i]["orderName"];
                                          await getOrderBonus();
                                          await getPaidDate();
                                          await getThuongDonHangDeNghi();

                                          _showMaterialDialog(context, i);
                                        },
                                        child: Text(
                                          listDHH["content"][i]["orderCode"] ??
                                              "",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      )),
                                      DataCell(TextButton(
                                        onPressed: () async {
                                          selectedOrderId =
                                              listDHH["content"][i]["id"];
                                          selectedOrderName = listDHH["content"]
                                              [i]["orderName"];
                                          await getOrderBonus();
                                          await getPaidDate();
                                          await getThuongDonHangDeNghi();
                                          _showMaterialDialog(context, i);
                                        },
                                        child: Text(
                                          listDHH["content"][i]["orderName"] ??
                                              "",
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      )),
                                      DataCell(
                                        Container(
                                            width: 200,
                                            child: Text(
                                                listDHH["content"][i]
                                                            ["nghiepdoan"]
                                                        ["orgName"] ??
                                                    "",
                                                style: bangDuLieu)),
                                      ),
                                    ],
                                  )
                          ],
                        ),
                      ),
                      paging
                    ],
                  ),
                ),
              ),
              Footer(
                  marginFooter: EdgeInsets.only(top: 25),
                  paddingFooter: EdgeInsets.all(15))
            ]),
          );
        });
  }
}
