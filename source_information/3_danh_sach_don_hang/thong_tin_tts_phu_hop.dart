import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../common_ource_information/constant.dart';

Color borderBlack = Colors.black54;

class DaSachTTSPhuHopDSDH extends StatelessWidget {
  final String id;
  const DaSachTTSPhuHopDSDH({Key? key, required this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: DaSachTTSPhuHopDSDHBody(
      id: id,
    ));
  }
}

class DaSachTTSPhuHopDSDHBody extends StatefulWidget {
  final String id;
  const DaSachTTSPhuHopDSDHBody({Key? key, required this.id}) : super(key: key);

  @override
  State<DaSachTTSPhuHopDSDHBody> createState() => _DaSachTTSPhuHopDSDHBodyState();
}

class _DaSachTTSPhuHopDSDHBodyState extends State<DaSachTTSPhuHopDSDHBody> {
  //url trang them moi cap nhat quan lys thong tin tts
  final String urlAddNewUpdateSI = "/thong-tin-tts-phu-hop";

  //--lấy dữ liệu trong ô nhập
  TextEditingController nameController = TextEditingController();
  List<dynamic> idSelectedList = [];
  Widget paging = Container();
  List<bool> _selectedDataRow = [];
  late Future<dynamic> futureListTrainee;
  String condition = ""; //Tình trạng
  int rowCount = 0;
  int currentPage = 1;
  int rowPerPage = 10;
  var firstRow;
  var lastRow;

  //seachAndPageChange
  var searchRequest = "";
  var resultList = [];
  var content = [];
  var orderInfo;
  getOrderInfo() async {
    var response = await httpGet("/api/donhang/get/${widget.id}", context);
    if (response.containsKey("body")) {
      orderInfo = jsonDecode(response['body']);
      return orderInfo;
    } else {
      throw Exception("failse");
    }
  }

  int pointSuggest(tts) {
    int point = 0;
    if (orderInfo['ageFrom'] != null && orderInfo['ageTo'] != null && tts['age'] != null) if (tts['age'] > orderInfo['ageFrom'] &&
        tts['age'] < orderInfo['ageTo']) {
      point += 5;
    }
    if (orderInfo['ageFrom'] != null && orderInfo['ageTo'] == null && tts['age'] != null) if (tts['age'] > orderInfo['ageFrom']) point += 5;
    if (orderInfo['ageFrom'] == null && orderInfo['ageTo'] != null && tts['age'] != null) if (tts['age'] < orderInfo['ageTo']) point += 5;
    var formChiTiet;
    for (var row in listTtsForm) {
      if (tts['id'] == row['ttsId']) {
        formChiTiet = row;
        break;
      }
    }
    var sucKhoe;

    for (var row in listTtsSk) {
      if (tts['id'] == row['ttsId']) {
        sucKhoe = row;
        break;
      }
    }
    if (orderInfo['genderRequired'] != null) if (orderInfo['genderRequired'] != 2) {
      if (tts['gender'] == orderInfo['genderRequired']) point += 5;
    }
    if (formChiTiet != null) {
      if (orderInfo['academicId'] != null && formChiTiet['academicId'] != null) if (formChiTiet['academicId'] == orderInfo['academicId']) point += 5;
      if (orderInfo['jobId'] != null && formChiTiet['jobId'] != null) if (formChiTiet['jobId'] == orderInfo['jobId']) point += 10;
    }
    if (sucKhoe != null) {
      if (orderInfo['height'] != null && sucKhoe['height'] != null) if (sucKhoe['height'] == orderInfo['height']) point += 5;
      if (orderInfo['weight'] != null && sucKhoe['weight'] != null) if (sucKhoe['weight'] == orderInfo['weight']) point += 5;
    }
    return point;
  }

  var listTts = [];
  var listIdExitst = [];
  getListTts() async {
    var ttsInOrder = await httpGet("/api/tts-lichsu-tiencu/get/page?filter=orderId:${widget.id}", context);
    var listTtsInOrder = jsonDecode(ttsInOrder['body'])['content'];
    String query = '';
    listIdExitst.clear();
    for (var row in listTtsInOrder) {
      listIdExitst.add(row['ttsId']);
    }
    print(listIdExitst);
    if (query != '') {
      query = 'and not(id in($query))';
    }
    var phanQuyenXem = '';
    if (Provider.of<SecurityModel>(context, listen: false).userLoginCurren['departId'] == 1 ||
        Provider.of<SecurityModel>(context, listen: false).userLoginCurren['departId'] == 2) {
      phanQuyenXem = "";
    } else {
      if (Provider.of<SecurityModel>(context, listen: false).userLoginCurren['vaitro']['level'] == 2) {
        if (Provider.of<SecurityModel>(context, listen: false).userLoginCurren['departId'] != 3)
          phanQuyenXem =
              "and nhanvientuyendung.departId:${Provider.of<SecurityModel>(context, listen: false).userLoginCurren['departId']} and not(careUser is null)";
        else
          phanQuyenXem =
              "and (nhanvientuyendung.departId:${Provider.of<SecurityModel>(context, listen: false).userLoginCurren['departId']} or careUser is null) ";
      }
      if (Provider.of<SecurityModel>(context, listen: false).userLoginCurren['vaitro']['level'] == 1) {
        phanQuyenXem = "and nhanvientuyendung.teamId:${Provider.of<SecurityModel>(context, listen: false).userLoginCurren['teamId']}";
      }
      if (Provider.of<SecurityModel>(context, listen: false).userLoginCurren['vaitro']['level'] == 0) {
        phanQuyenXem = "and careUser:${Provider.of<SecurityModel>(context, listen: false).userLoginCurren['id']}";
      }
    }
    
    var response = await httpGet(
        "/api/nguoidung/get/page?filter=ttsStatusId in (3,4,14) and isTts:1 and active:1 and stopProcessing:0 and (fullName~'*${nameController.text}*' or userCode~'*${nameController.text}*') $phanQuyenXem",
        context);

    if (response.containsKey("body")) {
      listTts = [];
      listTts = jsonDecode(response['body'])['content'];
      rowCount = jsonDecode(response['body'])['totalElements'];
      for (var row in listTts) {
        idRequest += ',';
        idRequest += row['id'].toString();
      }
      await getOrderInfo();
      await getListTtsForm();
      await getListTtsSk();
      for (var row in listTts) {
        row['pointSuggest'] = pointSuggest(row);
        row['selected'] = false;
      }
      listTts.sort((a, b) => b["pointSuggest"].compareTo(a["pointSuggest"]));
      setState(() {});
      return listTts;
    } else {
      throw Exception("failse");
    }
  }

  String idRequest = '0';

  var listTtsForm;
  getListTtsForm() async {
    var response = await httpGet("/api/tts-form-chitiet/get/page?filter=ttsId in ($idRequest)", context);
    if (response.containsKey("body")) {
      listTtsForm = jsonDecode(response['body'])['content'];
      return listTtsForm;
    } else {
      throw Exception("failse");
    }
  }

  var listTtsSk;
  getListTtsSk() async {
    var response = await httpGet("/api/tts-suckhoe/get/page?filter=ttsId in ($idRequest)", context);
    if (response.containsKey("body")) {
      listTtsSk = jsonDecode(response['body'])['content'];
      return listTtsSk;
    } else {
      throw Exception("failse");
    }
  }

  String getGender(int gender) {
    String nameGender = "";
    switch (gender) {
      case 0:
        {
          nameGender = "Nữ";
        }
        break;
      case 1:
        {
          nameGender = "Nam";
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

  String getBirthDate(String? birthDateData) {
    String birthDate = "";
    print("getBirth$birthDateData");
    if (birthDateData != null && birthDateData != '') {
      birthDate = DateFormat("dd-MM-yyyy").format(DateTime.parse(birthDateData));
    } else {
      birthDate = "";
    }
    return birthDate;
  }

  bool isNumber(String string) {
    try {
      int.parse(string);
      return true;
    } catch (e) {
      return false;
    }
  }

  String titleLog = "Tiến cử thành công";
  addDxtc(listSelectedRow) async {
    var listTtsTc = [];
    var historyTtsTc = [];
    for (var tts in listSelectedRow) {
      listTtsTc.add({
        "orderId": int.parse(widget.id),
        "ttsId": tts['id'],
        "qcApproval": 0,
        "ptttApproval": 0,
      });
      historyTtsTc.add({
        "orderId": int.parse(widget.id),
        "ttsId": tts['id'],
        "status": 0,
        "nominateUser": Provider.of<SecurityModel>(context, listen: false).userLoginCurren['id'],
        "nominateDate": DateFormat('yyyy-MM-ddTHH:mm:ss').format(DateTime.now())
      });
      print(historyTtsTc);
      int beforeStt = tts['ttsStatusId'];
      tts['ttsStatusId'] = 4;
      await httpPut('/api/nguoidung/put/${tts['id']}', tts, context);
      await httpPostDiariStatus(tts['id'], beforeStt, 4, 'Đề xuất tiến cử', context);
    }
    var response = await httpPost('/api/donhang-tts-tiencu/post/saveAll', listTtsTc, context);

    if (response['body'] == 'true') {
      await httpPost('/api/tts-lichsu-tiencu/post/saveAll', historyTtsTc, context);
    } else {
      titleLog = 'Cập nhật thất bại';
    }
  }

  var listSelectedRow = [];
  //--Search theo trạng thái thức tập sinh--
  var optionListTTSStatus = {"-1": "Tất cả"};
  //-- Lấy id thực tập sinh để tiến cử
  String? idTTSRecommend;
  bool checkSelected = false;

  @override
  void initState() {
    futureListTrainee = getListTts();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NavigationModel, SecurityModel>(
      builder: (context, navigationModel, user, child) => ListView(
        children: [
          //---------- Breadcrumbs----------------
          TitlePage(
            listPreTitle: [
              {'url': THONG_TIN_NGUON, 'title': 'Dashboard'},
              {'url': DANH_SACH_DON_HANG_TTN, 'title': 'Danh sách đơn hàng'}
            ],
            content: 'Thông tin các thực tập sinh phù hợp',
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
                            label: 'Thực tập sinh',
                            type: 'none',
                            height: 40,
                            controller: nameController,
                            enter: () {
                              futureListTrainee = getListTts();
                            },
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
                                  futureListTrainee = getListTts();
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                //--------------------------------------------
                FutureBuilder(
                  future: futureListTrainee,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      rowCount = listTts.length;
                      firstRow = (currentPage - 1) * rowPerPage;
                      lastRow = currentPage * rowPerPage - 1;
                      if (lastRow > rowCount - 1) {
                        lastRow = rowCount - 1;
                      }
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
                                  'Thông tin thực tập sinh phù hợp',
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
                                            DataColumn(label: Text('Mã TTS', style: titleTableData)),
                                            DataColumn(label: Text('Họ tên', style: titleTableData)),
                                            DataColumn(label: Text('Ngày sinh', style: titleTableData)),
                                            DataColumn(label: Text('Giới tính', style: titleTableData)),
                                            DataColumn(label: Text('Số điện thoại', style: titleTableData)),
                                            DataColumn(label: Text('Trạng thái TTS', style: titleTableData)),
                                            DataColumn(label: Text('Tiến cử', style: titleTableData)),
                                          ],
                                          rows: <DataRow>[
                                            for (int i = firstRow; i <= lastRow; i++)
                                              DataRow(
                                                cells: <DataCell>[
                                                  DataCell(SelectableText("${++firstRow}")),
                                                  DataCell(
                                                    SelectableText(listTts[i]["userCode"] ?? "no data", style: bangDuLieu),
                                                  ),
                                                  DataCell(
                                                    Container(
                                                      width: MediaQuery.of(context).size.width * 0.08,
                                                      child: SelectableText(listTts[i]["fullName"].toString(), style: bangDuLieu),
                                                    ),
                                                  ),
                                                  DataCell(
                                                    SelectableText(getBirthDate(listTts[i]["birthDate"]), style: bangDuLieu),
                                                  ),
                                                  DataCell(
                                                    SelectableText((listTts[i]["gender"] != null) ? getGender(listTts[i]["gender"]) : "",
                                                        style: bangDuLieu),
                                                  ),
                                                  DataCell(
                                                    SelectableText(listTts[i]["phone"].toString(), style: bangDuLieu),
                                                  ),
                                                  DataCell(
                                                    SelectableText(
                                                        (listTts[i]["ttsTrangthai"] != null && listTts[i]["ttsTrangthai"]["statusName"] != null)
                                                            ? listTts[i]["ttsTrangthai"]["statusName"]
                                                            : "Trạng thái chưa xác định",
                                                        style: bangDuLieu),
                                                  ),
                                                  DataCell(
                                                    !listIdExitst.contains(listTts[i]['id'])
                                                        ? Checkbox(
                                                            checkColor: Colors.white,
                                                            value: listTts[i]['selected'],
                                                            onChanged: (bool? value) {
                                                              setState(() {
                                                                if (value == false) {
                                                                  listSelectedRow.remove(listTts[i]);
                                                                } else {
                                                                  listSelectedRow.add(listTts[i]);
                                                                }
                                                                listTts[i]['selected'] = value!;
                                                              });
                                                            },
                                                          )
                                                        : Text(
                                                            'Đã tiến cử ĐH này',
                                                            style: TextStyle(color: Color.fromARGB(255, 31, 162, 227)),
                                                          ),
                                                  ),
                                                  //
                                                ],
                                              ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  DynamicTablePagging(rowCount, currentPage, rowPerPage, pageChangeHandler: (currentPageCallBack) {
                                    setState(() {
                                      currentPage = currentPageCallBack;
                                    });
                                  }, rowPerPageChangeHandler: (rowPerPageChange) {
                                    currentPage = 1;
                                    rowPerPage = rowPerPageChange;
                                    setState(() {});
                                  }),
                                  SizedBox(
                                    height: 25,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
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
                                            backgroundColor: listSelectedRow.length != 0 ? Color.fromRGBO(245, 117, 29, 1) : Colors.grey,
                                            primary: Theme.of(context).iconTheme.color,
                                            textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                          ),
                                          onPressed: listSelectedRow.length != 0
                                              ? () async {
                                                  await showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) => XacNhanTienCu(
                                                          function: () async {
                                                            await addDxtc(listSelectedRow);
                                                            futureListTrainee = getListTts();
                                                            showToast(
                                                              context: context,
                                                              msg: titleLog,
                                                              color: titleLog == "Tiến cử thành công" ? Color.fromARGB(136, 72, 238, 67) : Colors.red,
                                                              icon: titleLog == "Tiến cử thành công" ? Icon(Icons.done) : Icon(Icons.warning),
                                                            );
                                                            Navigator.pop(context);
                                                          },
                                                          content:
                                                              "Bạn có chắc chắn tiến cử ${listSelectedRow.length} thực tập sinh vào đơn hàng ${orderInfo['orderName']}"));
                                                }
                                              : null,
                                          child: Row(
                                            children: [
                                              Text('Xác nhận', style: textButton),
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
                                            Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/danh-sach-don-hang-ttn");
                                          },
                                          child: Row(
                                            children: [
                                              Text('Hủy', style: textButton),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                Container(
                  margin: EdgeInsets.only(top: 30),
                  width: MediaQuery.of(context).size.width * 1,
                  decoration: BoxDecoration(
                    color: colorWhite,
                    boxShadow: [boxShadowContainer],
                    border: Border(
                      bottom: borderTitledPage,
                    ),
                  ),
                  padding: paddingTitledPage,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('no copyright'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class XacNhanTienCu extends StatefulWidget {
  Function function;
  String content;
  XacNhanTienCu({Key? key, required this.function, required this.content}) : super(key: key);
  @override
  State<XacNhanTienCu> createState() => _XacNhanTienCuState();
}

class _XacNhanTienCuState extends State<XacNhanTienCu> {
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
                  'Xác nhận tiến cử thực tập sinh',
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
        height: 150,
        width: 600,
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
              widget.content,
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
