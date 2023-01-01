import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/api.dart';
import 'package:gentelella_flutter/common/toast.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:gentelella_flutter/widgets/ui/source_information/common_ource_information/constant.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../../../../common/style.dart';

Color borderBlack = Colors.black54;

class CauHinhTinhThuongTTN extends StatelessWidget {
  const CauHinhTinhThuongTTN({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: CauHinhTinhThuongTTNBody());
  }
}

class CauHinhTinhThuongTTNBody extends StatefulWidget {
  const CauHinhTinhThuongTTNBody({Key? key}) : super(key: key);

  @override
  State<CauHinhTinhThuongTTNBody> createState() => _CauHinhTinhThuongTTNBodyState();
}

class _CauHinhTinhThuongTTNBodyState extends State<CauHinhTinhThuongTTNBody> {
  final String urlAddNewUpdateSI = "quan-ly-thong-tin-thuc-tap-sinh/add-new-update";

  TextEditingController unitPriceController = TextEditingController();
  TextEditingController dayFrom = TextEditingController();
  TextEditingController dayTo = TextEditingController();
  bool isNumber(String string) {
    try {
      int.parse(string);
      return true;
    } catch (e) {
      return false;
    }
  }

  addCauHinhTinhThuong(unitPrice, dayFrom, dayTo) async {
    var data = {"unitPrice": unitPrice, "dayFrom": dayFrom, "dayTo": dayTo, "calUnit": 0, "tienId": 2, "approve": 0};
    await httpPost('/api/ctv-cauhinh-tinhthuong/post/save', data, context);
    showToast(context: context, msg: "Thêm mới cấu hình tính thưởng thành công", color: Color.fromARGB(136, 72, 238, 67), icon: Icon(Icons.done));
    getCauHinhTinhthuong(0);
    setState(() {});
  }

  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  var tableIndex = 1;

  List<CauHinhTinhThuong> listCauHinhTinhThuong = [];
  late Future<List<CauHinhTinhThuong>> futureResult;

  Future<List<CauHinhTinhThuong>> getCauHinhTinhthuong(page) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response = await httpGet("/api/ctv-cauhinh-tinhthuong/get/page?size=$rowPerPage&page=$page&sort=approve,desc&sort=createdDate,desc", context);
    if (response.containsKey("body")) {
      var body = jsonDecode(response['body']);
      var content;
      listCauHinhTinhThuong = [];
      content = body['content'];
      currentPage = page + 1;
      if (content.length > 0) {
        for (var element in content) {
          CauHinhTinhThuong item = CauHinhTinhThuong(
              id: element['id'],
              ngayTao: DateTime.parse(element['createdDate']),
              tien: element['unitPrice'] ?? 0,
              trangThai: element['approve'] ?? 0,
              dayFrom: element['dayFrom'] ?? 0,
              dayTo: element['dayTo'] ?? 0);
          var respon = await httpGet("/api/ctv-lichsu-gioithieu/get/page?filter=tinhthuongId:${item.id}", context);
          if (respon.containsKey("body")) {
            var contentLS = jsonDecode(respon['body'])['content'];
            if (contentLS.length > 0)
              item.edit = 0;
            else
              item.edit = 1;
          }
          //  print("item.id:${item.id}--- item.edit:${item.edit}");
          listCauHinhTinhThuong.add(item);
        }
        if (content.length == 1) {
          if (content[0]['approve'] == 0) {
            await httpPut("/api/ctv-cauhinh-tinhthuong/put/${content[0]['id']}", {"unitPrice": content[0]['unitPrice'], "approve": 1}, context);
          }
        }
      }
      rowCount = body['totalElements'];
      totalElements = body["totalElements"];
      lastRow = totalElements;
      setState(() {});
      rowCount = body['totalElements'];
      if (content.length > 0) {
        var firstRow = (currentPage) * rowPerPage + 1;
        var lastRow = (currentPage + 1) * rowPerPage;
        if (lastRow > totalElements) {
          lastRow = totalElements;
        }
        tableIndex = (currentPage - 1) * rowPerPage + 1;
        // print(tableIndex);
      }
    }
    return listCauHinhTinhThuong;
  }

  bool checkSTT = false;
  bool checkClose = true;

  @override
  void initState() {
    super.initState();
    futureResult = getCauHinhTinhthuong(0);
  }

  @override
  void dispose() {
    super.dispose();
    unitPriceController.dispose();
  }

  //Phân quyền
  bool decentralizationManagement(user) {
    print("ddd$user");
    if (user["departId"] == 1 || user["departId"] == 2 || (user["departId"] == 3 && user["vaitro"] != null && user["vaitro"]["level"] == 2)) {
      return true;
    }
    return false;
  }

  final formatTien = new NumberFormat('#,##0', 'en_US');

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<SecurityModel>(context, listen: true).userLoginCurren;
    return FutureBuilder<dynamic>(
      future: userRule(CAU_HINH_TINH_THUONG_TTN, context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Consumer<NavigationModel>(
            builder: (context, navigationModel, child) => ListView(
              controller: ScrollController(),
              children: [
                TitlePage(
                  listPreTitle: [
                    {'url': THONG_TIN_NGUON, 'title': 'Dashboard'},
                    // {'url': "/de-nghi-tuyen-dung", 'title': 'Đề nghị tuyển dụng'},
                  ],
                  content: 'Cấu hình tính thưởng',
                ),
                Container(
                  color: backgroundPage,
                  padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (decentralizationManagement(user) == true)
                          // user["departId"] == 1 ||
                          //         user["departId"] == 2 ||
                          //         (user["departId"] == 3 && user["vaitro"] != null && user["vaitro"]["level"] == 2)
                          ? (checkClose)
                              ? Container(
                                  width: MediaQuery.of(context).size.width * 1,
                                  decoration: BoxDecoration(
                                    color: colorWhite,
                                    borderRadius: borderRadiusContainer,
                                    boxShadow: [boxShadowContainer],
                                    border: borderAllContainerBox,
                                  ),
                                  padding: paddingBoxContainer,
                                  // transform: Matrix4.rotationX(2),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Tính theo thực tập sinh đã xuất cảnh',
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
                                            label: 'Từ ngày',
                                            type: 'Number',
                                            height: 40,
                                            controller: dayFrom,
                                            onChanged: (value) {
                                              if (dayFrom.text.isNotEmpty && dayTo.text.isNotEmpty && unitPriceController.text.isNotEmpty) {
                                                checkSTT = true;
                                              } else {
                                                checkSTT = false;
                                              }
                                              setState(() {});
                                            },
                                          ),
                                          SizedBox(
                                            width: 50,
                                          ),
                                          TextFieldValidated(
                                            label: 'Đến ngày',
                                            type: 'Number',
                                            height: 40,
                                            controller: dayTo,
                                            onChanged: (value) {
                                              if (dayFrom.text.isNotEmpty && dayTo.text.isNotEmpty && unitPriceController.text.isNotEmpty) {
                                                checkSTT = true;
                                              } else {
                                                checkSTT = false;
                                              }
                                              setState(() {});
                                            },
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 25,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          TextFieldValidated(
                                            label: 'Số tiền',
                                            type: 'Number',
                                            height: 40,
                                            controller: unitPriceController,
                                            onChanged: (value) {
                                              if (dayFrom.text.isNotEmpty && dayTo.text.isNotEmpty && unitPriceController.text.isNotEmpty) {
                                                checkSTT = true;
                                              } else {
                                                checkSTT = false;
                                              }
                                              setState(() {});
                                            },
                                          ),
                                          SizedBox(width: 50),
                                          Expanded(
                                              flex: 3,
                                              child: Container(
                                                child: Text("VND/TTS"),
                                              )),
                                          Expanded(flex: 2, child: Container()),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            (user["departId"] != 1)
                                                ? (user["departId"] == 3 && user["vaitro"] != null && user["vaitro"]["level"] == 2)
                                                    ? Container(
                                                        margin: EdgeInsets.only(left: 20),
                                                        child: TextButton(
                                                          style: TextButton.styleFrom(
                                                            padding: const EdgeInsets.symmetric(
                                                              vertical: 20.0,
                                                              horizontal: 30.0,
                                                            ),
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(5.0),
                                                            ),
                                                            backgroundColor: (checkSTT) ? Color.fromRGBO(245, 117, 29, 1) : Color(0xfffcccccc),
                                                            primary: Theme.of(context).iconTheme.color,
                                                            textStyle:
                                                                Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                          ),
                                                          onPressed: (checkSTT)
                                                              ? () async {
                                                                  if (isNumber(dayFrom.text) &&
                                                                      isNumber(dayTo.text) &&
                                                                      isNumber(unitPriceController.text)) {
                                                                    int price = int.parse(unitPriceController.text);
                                                                    int dayFromInt = int.parse(dayFrom.text);
                                                                    int dayToInt = int.parse(dayTo.text);
                                                                    showDialog(
                                                                        context: context,
                                                                        builder: (BuildContext context) => ConfirmUpdate(
                                                                            title: "Xác nhận thêm mới",
                                                                            content: "Bạn có chắc chắn muốn thêm mới cấu hình tính thưởng?",
                                                                            function: () async {
                                                                              await addCauHinhTinhThuong(price, dayFromInt, dayToInt);
                                                                              Navigator.pop(context);
                                                                            }));
                                                                  } else {
                                                                    showToast(
                                                                      context: context,
                                                                      msg: "Phải là 1 số",
                                                                      color: colorOrange,
                                                                      icon: const Icon(Icons.warning),
                                                                    );
                                                                  }
                                                                }
                                                              : null,
                                                          child: Row(
                                                            children: [
                                                              Text('Lưu', style: textButton),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    : Container()
                                                : Container(
                                                    margin: EdgeInsets.only(left: 20),
                                                    child: TextButton(
                                                      style: TextButton.styleFrom(
                                                        padding: const EdgeInsets.symmetric(
                                                          vertical: 20.0,
                                                          horizontal: 30.0,
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(5.0),
                                                        ),
                                                        backgroundColor: (checkSTT) ? Color.fromRGBO(245, 117, 29, 1) : Color(0xfffcccccc),
                                                        primary: Theme.of(context).iconTheme.color,
                                                        textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                      ),
                                                      onPressed: (checkSTT)
                                                          ? () async {
                                                              if (isNumber(dayFrom.text) &&
                                                                  isNumber(dayTo.text) &&
                                                                  isNumber(unitPriceController.text)) {
                                                                int price = int.parse(unitPriceController.text);
                                                                int dayFromInt = int.parse(dayFrom.text);
                                                                int dayToInt = int.parse(dayTo.text);
                                                                showDialog(
                                                                    context: context,
                                                                    builder: (BuildContext context) => ConfirmUpdate(
                                                                        title: "Xác nhận thêm mới",
                                                                        content: "Bạn có chắc chắn muốn thêm mới cấu hình tính thưởng?",
                                                                        function: () async {
                                                                          await addCauHinhTinhThuong(price, dayFromInt, dayToInt);
                                                                          Navigator.pop(context);
                                                                        }));
                                                              } else {
                                                                showToast(
                                                                  context: context,
                                                                  msg: "Phải là 1 số",
                                                                  color: colorOrange,
                                                                  icon: const Icon(Icons.warning),
                                                                );
                                                              }
                                                            }
                                                          : null,
                                                      child: Row(
                                                        children: [
                                                          Text('Lưu', style: textButton),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                            Container(
                                              margin: EdgeInsets.only(left: 20),
                                              child: TextButton(
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(
                                                    vertical: 20.0,
                                                    horizontal: 30.0,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                  ),
                                                  backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                                  primary: Theme.of(context).iconTheme.color,
                                                  textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    checkClose = false;
                                                  });
                                                },
                                                child: Row(
                                                  children: [
                                                    Text('Đóng', style: textButton),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Container(
                                  width: MediaQuery.of(context).size.width * 1,
                                  decoration: BoxDecoration(
                                    color: colorWhite,
                                    borderRadius: borderRadiusContainer,
                                    boxShadow: [boxShadowContainer],
                                    border: borderAllContainerBox,
                                  ),
                                  padding: paddingBoxContainer,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(left: 20),
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 20.0,
                                              horizontal: 30.0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                            ),
                                            backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                            primary: Theme.of(context).iconTheme.color,
                                            textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              checkClose = true;
                                            });
                                          },
                                          child: Row(
                                            children: [
                                              Text('Thêm mới cấu hình tính thưởng', style: textButton),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                          : Container(),
                      FutureBuilder(
                        future: futureResult,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Container(
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
                                        'Áp dụng',
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
                                                  DataColumn(label: Text('Ngày tạo', style: titleTableData)),
                                                  DataColumn(label: Text('Số tiền', style: titleTableData)),
                                                  DataColumn(label: Text('Áp dụng', style: titleTableData)),
                                                  if ((user["departId"] == 1) ||
                                                      (user["departId"] == 3 && user["vaitro"] != null && user["vaitro"]["level"] == 2))
                                                    DataColumn(label: Text('Hành động', style: titleTableData)),
                                                ],
                                                rows: <DataRow>[
                                                  for (int i = 0; i < listCauHinhTinhThuong.length; i++)
                                                    DataRow(
                                                      cells: <DataCell>[
                                                        DataCell(Text("${tableIndex + i}")),
                                                        DataCell(
                                                          SelectableText(DateFormat('dd-MM-yyyy').format(listCauHinhTinhThuong[i].ngayTao)),
                                                        ),
                                                        DataCell(
                                                          Row(
                                                            children: [
                                                              SelectableText(
                                                                "${formatTien.format(listCauHinhTinhThuong[i].tien)}",
                                                                style: bangDuLieu,
                                                              ),
                                                              Text(" VND/TTS", style: bangDuLieu),
                                                            ],
                                                          ),
                                                        ),
                                                        DataCell((listCauHinhTinhThuong[i].trangThai == 0)
                                                            ? Container(
                                                                width: 180,
                                                                child: TextButton(
                                                                  style: TextButton.styleFrom(
                                                                    padding: paddingBtn,
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: borderRadiusBtn,
                                                                    ),
                                                                    backgroundColor: (user["departId"] != 1)
                                                                        ? (user["departId"] == 3 &&
                                                                                user["vaitro"] != null &&
                                                                                user["vaitro"]["level"] == 2)
                                                                            ? mainColorPage
                                                                            : Colors.grey
                                                                        : mainColorPage,
                                                                    primary: Theme.of(context).iconTheme.color,
                                                                    textStyle: Theme.of(context)
                                                                        .textTheme
                                                                        .caption
                                                                        ?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                                  ),
                                                                  onPressed: (user["departId"] != 1)
                                                                      ? (user["departId"] == 3 &&
                                                                              user["vaitro"] != null &&
                                                                              user["vaitro"]["level"] == 2)
                                                                          ? () {
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
                                                                                                      child: Image.asset('assets/images/logoAAM.png'),
                                                                                                      margin: EdgeInsets.only(right: 10),
                                                                                                    ),
                                                                                                    Text(
                                                                                                      'Xác nhận áp dụng cấu hình tính thưởng ',
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
                                                                                        content: Row(
                                                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                                                          children: [
                                                                                            Text(
                                                                                                "${formatTien.format(listCauHinhTinhThuong[i].tien)} VND/TTS"),
                                                                                          ],
                                                                                        ),
                                                                                        actions: [
                                                                                          ElevatedButton(
                                                                                            onPressed: () async {
                                                                                              var response = await httpGet(
                                                                                                  "/api/ctv-cauhinh-tinhthuong/get/page?filter=approve:1",
                                                                                                  context);
                                                                                              var content = jsonDecode(response['body'])['content'];
                                                                                              if (content.length > 0) {
                                                                                                var idChange = content[0]['id'];
                                                                                                var donGia = content[0]['unitPrice'];
                                                                                                await httpPut(
                                                                                                    "/api/ctv-cauhinh-tinhthuong/put/$idChange",
                                                                                                    {"unitPrice": donGia, "approve": 0},
                                                                                                    context);
                                                                                              }
                                                                                              await httpPut(
                                                                                                  "/api/ctv-cauhinh-tinhthuong/put/${listCauHinhTinhThuong[i].id}",
                                                                                                  {
                                                                                                    "unitPrice": listCauHinhTinhThuong[i].tien,
                                                                                                    "approve": 1
                                                                                                  },
                                                                                                  context);
                                                                                              await getCauHinhTinhthuong(0);
                                                                                              setState(() {});
                                                                                              Navigator.pop(context);
                                                                                              showToast(
                                                                                                context: context,
                                                                                                msg: "Áp dụng cấu hình tính thưởng thành công",
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
                                                                                        ],
                                                                                      ));
                                                                            }
                                                                          : null
                                                                      : () {
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
                                                                                                  child: Image.asset('assets/images/logoAAM.png'),
                                                                                                  margin: EdgeInsets.only(right: 10),
                                                                                                ),
                                                                                                Text(
                                                                                                  'Xác nhận áp dụng cấu hình tính thưởng ',
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
                                                                                    content: Row(
                                                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                                                      children: [
                                                                                        Text(
                                                                                            "${formatTien.format(listCauHinhTinhThuong[i].tien)} VND/TTS"),
                                                                                      ],
                                                                                    ),
                                                                                    actions: [
                                                                                      ElevatedButton(
                                                                                        onPressed: () async {
                                                                                          var response = await httpGet(
                                                                                              "/api/ctv-cauhinh-tinhthuong/get/page?filter=approve:1",
                                                                                              context);
                                                                                          var content = jsonDecode(response['body'])['content'];
                                                                                          if (content.length > 0) {
                                                                                            var idChange = content[0]['id'];
                                                                                            var donGia = content[0]['unitPrice'];
                                                                                            await httpPut("/api/ctv-cauhinh-tinhthuong/put/$idChange",
                                                                                                {"unitPrice": donGia, "approve": 0}, context);
                                                                                          }
                                                                                          await httpPut(
                                                                                              "/api/ctv-cauhinh-tinhthuong/put/${listCauHinhTinhThuong[i].id}",
                                                                                              {
                                                                                                "unitPrice": listCauHinhTinhThuong[i].tien,
                                                                                                "approve": 1
                                                                                              },
                                                                                              context);
                                                                                          await getCauHinhTinhthuong(0);
                                                                                          setState(() {});
                                                                                          Navigator.pop(context);
                                                                                          showToast(
                                                                                            context: context,
                                                                                            msg: "Áp dụng cấu hình tính thưởng thành công",
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
                                                                                    ],
                                                                                  ));
                                                                        },
                                                                  child: Row(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      Text('Áp dụng', style: textButton),
                                                                    ],
                                                                  ),
                                                                ),
                                                              )
                                                            : Container(
                                                                width: 180,
                                                                padding: EdgeInsets.only(top: 12, bottom: 12),
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.circular(5.0),
                                                                  color: colorOrange,
                                                                ),
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                  children: [
                                                                    Text(
                                                                      "Đang áp dụng",
                                                                      style: textButton,
                                                                    ),
                                                                  ],
                                                                ),
                                                              )),
                                                        if ((user["departId"] == 1) ||
                                                            (user["departId"] == 3 && user["vaitro"] != null && user["vaitro"]["level"] == 2))
                                                          DataCell(
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                  child: ((listCauHinhTinhThuong[i].edit == 1))
                                                                      ? InkWell(
                                                                          onTap: () {
                                                                            TextEditingController unitPrice =
                                                                                TextEditingController(text: listCauHinhTinhThuong[i].tien.toString());
                                                                            TextEditingController dayFromUpdate = TextEditingController(
                                                                                text: listCauHinhTinhThuong[i].dayFrom.toString());
                                                                            TextEditingController dayToUpdate = TextEditingController(
                                                                                text: listCauHinhTinhThuong[i].dayTo.toString());
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
                                                                                                    child: Image.asset('assets/images/logoAAM.png'),
                                                                                                    margin: EdgeInsets.only(right: 10),
                                                                                                  ),
                                                                                                  Text(
                                                                                                    'Cập nhật cấu hình tính thưởng',
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
                                                                                      content: Container(
                                                                                        height: 200,
                                                                                        width: 450,
                                                                                        child: Column(
                                                                                          children: [
                                                                                            TextFieldValidated(
                                                                                              label: 'Số tiền thưởng trên một TTS',
                                                                                              type: 'Number',
                                                                                              height: 40,
                                                                                              controller: unitPrice,
                                                                                              flexLable: 1,
                                                                                              flexTextField: 1,
                                                                                            ),
                                                                                            SizedBox(
                                                                                              height: 25,
                                                                                            ),
                                                                                            TextFieldValidated(
                                                                                              label: 'Từ ngày',
                                                                                              type: 'Number',
                                                                                              height: 40,
                                                                                              controller: dayFromUpdate,
                                                                                              flexLable: 1,
                                                                                              flexTextField: 1,
                                                                                            ),
                                                                                            SizedBox(
                                                                                              height: 25,
                                                                                            ),
                                                                                            TextFieldValidated(
                                                                                              label: 'Đến ngày',
                                                                                              type: 'Number',
                                                                                              height: 40,
                                                                                              controller: dayToUpdate,
                                                                                              flexLable: 1,
                                                                                              flexTextField: 1,
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                      actions: [
                                                                                        ElevatedButton(
                                                                                          onPressed: () async {
                                                                                            var price = double.tryParse(unitPrice.text);
                                                                                            if (price != null &&
                                                                                                isNumber(dayFromUpdate.text) &&
                                                                                                isNumber(dayToUpdate.text)) {
                                                                                              print({
                                                                                                "unitPrice": price,
                                                                                                "dayFrom": int.parse(dayFromUpdate.text),
                                                                                                "dayTo": int.parse(dayToUpdate.text),
                                                                                                "approve": listCauHinhTinhThuong[i].trangThai
                                                                                              });
                                                                                              await httpPut(
                                                                                                  "/api/ctv-cauhinh-tinhthuong/put/${listCauHinhTinhThuong[i].id}",
                                                                                                  {
                                                                                                    "unitPrice": price,
                                                                                                    "dayFrom": int.parse(dayFromUpdate.text),
                                                                                                    "dayTo": int.parse(dayToUpdate.text),
                                                                                                    "approve": listCauHinhTinhThuong[i].trangThai
                                                                                                  },
                                                                                                  context);
                                                                                              await getCauHinhTinhthuong(currentPage - 1);
                                                                                              setState(() {});
                                                                                              Navigator.pop(context);
                                                                                              showToast(
                                                                                                context: context,
                                                                                                msg: "Cập nhật cấu hình tính thưởng thành công",
                                                                                                color: Color.fromARGB(136, 72, 238, 67),
                                                                                                icon: const Icon(Icons.done),
                                                                                              );
                                                                                            } else {
                                                                                              showToast(
                                                                                                context: context,
                                                                                                msg: "Dữ liệu không hợp lệ",
                                                                                                color: colorOrange,
                                                                                                icon: const Icon(Icons.warning),
                                                                                              );
                                                                                            }
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
                                                                                      ],
                                                                                    ));
                                                                          },
                                                                          child: Icon(Icons.edit_calendar, color: Color(0xff009C87)),
                                                                        )
                                                                      : Tooltip(
                                                                          message: 'Đã được áp dụng',
                                                                          textStyle: const TextStyle(fontSize: 15, color: Colors.white),
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(25),
                                                                            color: colorOrange,
                                                                          ),
                                                                          child: Icon(Icons.edit_calendar, color: Color(0xfffcccccc))),
                                                                ),
                                                                Container(
                                                                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                  child: ((listCauHinhTinhThuong[i].edit == 1))
                                                                      ? InkWell(
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
                                                                                                    child: Image.asset('assets/images/logoAAM.png'),
                                                                                                    margin: EdgeInsets.only(right: 10),
                                                                                                  ),
                                                                                                  Text(
                                                                                                    'Xóa cấu hình tính thưởng',
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
                                                                                      content: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                                                        children: [
                                                                                          Text("${listCauHinhTinhThuong[i].tien} VND/TTS"),
                                                                                        ],
                                                                                      ),
                                                                                      actions: [
                                                                                        ElevatedButton(
                                                                                          onPressed: () async {
                                                                                            await httpDelete(
                                                                                                "/api/ctv-cauhinh-tinhthuong/del/${listCauHinhTinhThuong[i].id}",
                                                                                                context);
                                                                                            if (i == 0) {
                                                                                              if (listCauHinhTinhThuong.length > 1) {
                                                                                                await httpPut(
                                                                                                    "/api/ctv-cauhinh-tinhthuong/put/${listCauHinhTinhThuong[1].id}",
                                                                                                    {
                                                                                                      "unitPrice": listCauHinhTinhThuong[1].tien,
                                                                                                      "approve": 1
                                                                                                    },
                                                                                                    context);
                                                                                              }
                                                                                            }

                                                                                            await getCauHinhTinhthuong(currentPage - 1);
                                                                                            setState(() {});
                                                                                            Navigator.pop(context);
                                                                                            showToast(
                                                                                              context: context,
                                                                                              msg: "Xóa cấu hình tính thưởng thành công",
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
                                                                                      ],
                                                                                    ));
                                                                          },
                                                                          child: Icon(Icons.delete_outline, color: Colors.red),
                                                                        )
                                                                      : Tooltip(
                                                                          message: 'Đã được áp dụng',
                                                                          textStyle: const TextStyle(fontSize: 15, color: Colors.white),
                                                                          decoration: BoxDecoration(
                                                                            borderRadius: BorderRadius.circular(25),
                                                                            color: colorOrange,
                                                                          ),
                                                                          child: Icon(Icons.delete_outline, color: Color(0xfffcccccc))),
                                                                ),
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
                                        DynamicTablePagging(
                                          rowCount,
                                          currentPage,
                                          rowPerPage,
                                          pageChangeHandler: (page) {
                                            setState(() {
                                              futureResult = getCauHinhTinhthuong(page - 1);
                                              currentPage = page - 1;
                                            });
                                          },
                                          rowPerPageChangeHandler: (rowPerPage) {
                                            setState(() {
                                              this.rowPerPage = rowPerPage!;
                                              this.firstRow = page * currentPage;
                                              futureResult = getCauHinhTinhthuong(0);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text('${snapshot.error}');
                          }
                          return Center(child: const CircularProgressIndicator());
                        },
                      ),
                      Footer(paddingFooter: paddingBoxContainer, marginFooter: EdgeInsets.only(top: 30)),
                    ],
                  ),
                ),
              ],
            ),
          );

          // Text(listRule.data!.title);
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class CauHinhTinhThuong {
  int? id;
  DateTime ngayTao;
  double? tien;
  int? trangThai;
  int? edit;
  int dayFrom;
  int dayTo;
  CauHinhTinhThuong({this.id, required this.ngayTao, this.tien, this.trangThai, this.edit, required this.dayFrom, required this.dayTo});
}
