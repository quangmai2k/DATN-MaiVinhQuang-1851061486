import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/bars.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../../../../common/style.dart';
// import 'dart:io';

typedef void OnDownloadProgressCallback(int receivedBytes, int totalBytes);
typedef void OnUploadProgressCallback(int sentBytes, int totalBytes);

class ThongTinDaoTao extends StatefulWidget {
  final String? id;
  const ThongTinDaoTao({Key? key, this.id}) : super(key: key);

  @override
  State<ThongTinDaoTao> createState() => _ThongTinDaoTaoState();
}

class _ThongTinDaoTaoState extends State<ThongTinDaoTao> {
  String? text;

  TextEditingController trainedContentBeforeExam = TextEditingController();
  TextEditingController alphabetScore = TextEditingController();
  TextEditingController n4Score = TextEditingController();
  TextEditingController n5Score = TextEditingController();
  TextEditingController trainedContentBeforeFlight = TextEditingController();

  List<dynamic> listNhuYeuPham = [
    {'title': 'Sách Min 1', 'value': false},
    {'title': 'Sách Min 2', 'value': false},
    {'title': 'Từ điển', 'value': false},
    {'title': 'Kanji', 'value': false},
    {'title': '2 áo', 'value': false},
    {'title': '1 đôi dép', 'value': false},
    {'title': '1 thẻ', 'value': false},
    {'title': 'Chăn', 'value': false},
    {'title': 'Chiếu', 'value': false},
    {'title': 'Màn', 'value': false}
  ];

  bool trainedBeforeExam = false;
  bool trainedBeforeFlight = false;

  String selectedCHCB = '0';
  List<dynamic> itemsTT = [
    {'name': 'Không đạt', 'value': '0'},
    {'name': 'Đạt', 'value': '1'},
  ];
  List<dynamic> itemsBPXL = [
    {'name': 'Trung tâm đào tạo', 'value': '7'},
    {'name': 'Bp. Kiểm soát', 'value': '4'}
  ];
  List<dynamic> itemsKQXL = [
    {'name': 'Đã xử lý', 'value': '1'},
    {'name': 'Chưa xử lý', 'value': '0'}
  ];
  String selectedBCC = '0';
  String selectedDTN4 = '0';
  String selectedDTN5 = '0';
  String? dateDisplay;
  var daoTaoTiengNhat = [];
  late Future<dynamic> getInfoTtsFuture;
  DateTime selectedDate = DateTime.now();
  dynamic fileChungChi;

  var infoTts;
  var quyDinh;
  var listItemsQuyDinh = [];
  getQuyDinh() async {
    var getQuyDinh = await httpGet("/api/quydinh/get/page", context);
    if (getQuyDinh.containsKey("body")) {
      setState(() {
        quyDinh = jsonDecode(getQuyDinh["body"])['content'];
      });
    }
    listItemsQuyDinh = [];
    for (var row in quyDinh) {
      listItemsQuyDinh.add({
        'value': row['id'].toString(),
        'name': row['ruleName'],
        "code": 'QD0${row['id']}'
      });
    }
    return 0;
  }

  getInfoTts() async {
    await getQuyDinh();
    await getListInfoTTDT();
    await getListNYP();
    await getListInfoVP();
    var response = await httpGet(
        "/api/daotao-tts/get/page?filter=ttsId:${widget.id}", context);
    if (response.containsKey("body")) {
      setState(() {
        if (jsonDecode(response["body"])['content'].isNotEmpty)
          infoTts = jsonDecode(response["body"])['content'][0];
      });
    }
    return 0;
  }

  var listCheckNYP;
  var listNYP = {};
  getListNYP() async {
    var response = await httpGet(
        "/api/tts-thongtindaotao-hocpham/get/page?filter=ttsId:${widget.id}",
        context);
    if (response.containsKey("body")) {
      listCheckNYP = jsonDecode(response["body"])['content'];
      if (listCheckNYP.length > 0) {
        listNYP = listCheckNYP[0];
        if (listNYP['minBook1'] == 1) {
          setNhuYeuPham('Sách Min 1');
        }
        if (listNYP['minBook2'] == 1) {
          setNhuYeuPham('Sách Min 2');
        }
        if (listNYP['dictionary'] == 1) {
          setNhuYeuPham('Từ điển');
        }
        if (listNYP['kanji'] == 1) {
          setNhuYeuPham('Kanji');
        }
        if (listNYP['clothes'] == 1) {
          setNhuYeuPham('2 áo');
        }
        if (listNYP['sandals'] == 1) {
          setNhuYeuPham('1 đôi dép');
        }
        if (listNYP['userCard'] == 1) {
          setNhuYeuPham('1 thẻ');
        }
        if (listNYP['blanket'] == 1) {
          setNhuYeuPham('Chăn');
        }
        if (listNYP['mat'] == 1) {
          setNhuYeuPham('Chiếu');
        }
        if (listNYP['drape'] == 1) {
          setNhuYeuPham('Màn');
        }
      }
    }

    return 0;
  }

  setNhuYeuPham(String title) {
    for (var row in listNhuYeuPham) {
      if (title == row['title']) {
        row['value'] = true;
      }
    }
  }

  var listDTTN;
  getListInfoDTTN(id) async {
    var response = await httpGet(
        "/api/tts-thongtindaotao-tiengnhat/get/page?filter=thongtindaotaoId:$id&sort=lessonFrom",
        context);
    if (response.containsKey("body")) {
      listDTTN = jsonDecode(response["body"])['content'];
      print("listDTTN");
    }
    daoTaoTiengNhat = [];
    for (var row in listDTTN) {
      daoTaoTiengNhat.add({
        'id': row['id'],
        'reportDate': dateReverse(displayDateTimeStamp(row['reportDate'])),
        'lessonFrom': TextEditingController(text: row['lessonFrom'].toString()),
        'lessonTo': TextEditingController(text: row['lessonTo'].toString()),
        'reportFile': row['reportFile'],
        'attitudeComment': TextEditingController(text: row['attitudeComment']),
        'academicPerformanceComment':
            TextEditingController(text: row['academicPerformanceComment']),
        'status': true
      });
    }
    return 0;
  }

  late int idTtdt;
  var infoTtsTTDT;
  var checkInfoTtsTTDT = [];
  getListInfoTTDT() async {
    var response = await httpGet(
        "/api/tts-thongtindaotao/get/page?filter=ttsId:${widget.id}", context);
    if (response.containsKey("body")) {
      checkInfoTtsTTDT = jsonDecode(response["body"])['content'];
      if (checkInfoTtsTTDT.length > 0) {
        infoTtsTTDT = checkInfoTtsTTDT[0];
        dateDisplay = dateReverse(infoTtsTTDT['admissionDate']);
        setState(() {});
      }
    }

    return 0;
  }

  var viPham = [];
  var listViPham = [];
  getListInfoVP() async {
    var response = await httpGet(
        "/api/tts-thongtindaotao-vipham/get/page?filter=ttsId:${widget.id} &sort=isDone",
        context);
    if (response.containsKey("body")) {
      listViPham = jsonDecode(response["body"])['content'];
    }
    viPham = [];
    for (var row in listViPham) {
      viPham.add({
        "id": row['id'],
        "ttsId": row['ttsId'],
        "departId": 4,
        "violateContent": TextEditingController(text: row['violateContent']),
        "violateDate": dateReverse(displayDateTimeStamp(row['violateDate'])),
        'ruleId': row['ruleId'].toString(),
        "isDone": row['isDone'].toString(),
        "status": true,
      });
    }
    return 0;
  }

  bool isNumber(String string) {
    try {
      int.parse(string);
      return true;
    } catch (e) {
      return false;
    }
  }

  late String titleLog;
  addTTDT(
    ttsId,
    admissionDate,
  ) async {
    int trainedAfterExam;
    trainedAfterExam = alphabetScore != '' ? 1 : 0;
    var data = {
      "ttsId": ttsId,
      "admissionDate": admissionDate,
    };

    var response =
        await httpPost('/api/tts-thongtindaotao/post/save', data, context);
    if (isNumber(response['body'])) {
      titleLog = 'Cập nhật dữ liệu thành công';
      idTtdt = int.parse(response['body']);
    } else {
      titleLog = 'Thêm mới thất bại';
    }
    return titleLog;
  }

  addNYP(ttsId, minBook1, minBook2, dictionary, kanji, clothes, sandals,
      userCard, blanket, mat, drape) async {
    var data = {
      "ttsId": int.parse(ttsId),
      "minBook1": minBook1,
      "minBook2": minBook2,
      "dictionary": dictionary,
      "kanji": kanji,
      "clothes": clothes,
      "sandals": sandals,
      "userCard": userCard,
      "blanket": blanket,
      "mat": mat,
      "drape": drape,
    };
    var response = await httpPost(
        '/api/tts-thongtindaotao-hocpham/post/save', data, context);
    if (isNumber(response['body'])) {
      titleLog = 'Cập nhật dữ liệu thành công';
    } else {
      titleLog = 'Thêm mới thất bại';
    }
    return titleLog;
  }

  addTN(academicPerformanceComment, attitudeComment, lessonFrom, lessonTo,
      reportDate, fileName) async {
    var data = {
      "thongtindaotaoId": idTtdt,
      "academicPerformanceComment": academicPerformanceComment,
      "attitudeComment": attitudeComment,
      "lessonFrom": lessonFrom,
      "lessonTo": lessonTo,
      "reportDate": reportDate,
      "reported": 0,
      "ttsId": int.parse(widget.id!)
    };
    if (fileName != null) {
      data["reportFile"] = fileName;
    }
    // print(data);
    var response = await httpPost(
        '/api/tts-thongtindaotao-tiengnhat/post/save', data, context);
    if (isNumber(response['body'])) {
      titleLog = 'Cập nhật dữ liệu thành công';
    } else {
      titleLog = 'Cập nhật thất bại';
    }
    return titleLog;
  }

  addVP(deleted, ttsId, violateContent, violateDate, isDone, ruleId) async {
    var data = {
      "deleted": deleted,
      "ttsId": ttsId,
      "departId": 4,
      "violateContent": violateContent,
      "ruleId": ruleId,
      "violateDate": violateDate,
      "isDone": 0
    };
    var response = await httpPost(
        '/api/tts-thongtindaotao-vipham/post/save', data, context);
    print("aaaaaaaaaa $response");
    if (isNumber(response['body'])) {
      titleLog = 'Cập nhật dữ liệu thành công';
    } else {
      titleLog = 'Cập nhật thất bại';
    }
    return titleLog;
  }

  updateVP(id, deleted, violateContent, violateDate, isDone, ruleId) async {
    var data = {
      "deleted": deleted,
      "departId": 4,
      "violateContent": violateContent,
      "violateDate": violateDate,
      "ruleId": ruleId,
      "isDone": 0
    };
    var response =
        await httpPut('/api/tts-thongtindaotao-vipham/put/$id', data, context);
    if (response['body'] == 'true') {
      titleLog = 'Cập nhật dữ liệu thành công';
    } else {
      titleLog = 'Cập nhật thất bại';
    }
    return titleLog;
  }

  updateTN(id, academicPerformanceComment, attitudeComment, lessonFrom,
      lessonTo, reportDate, deleted, fileName) async {
    var data = {
      "deleted": deleted,
      "thongtindaotaoId": idTtdt,
      "academicPerformanceComment": academicPerformanceComment,
      "attitudeComment": attitudeComment,
      "reportFile": fileName,
      "lessonFrom": lessonFrom,
      "lessonTo": lessonTo,
      "reportDate": reportDate,
    };

    var response = await httpPut(
        '/api/tts-thongtindaotao-tiengnhat/put/$id', data, context);
    if (response['body'] == 'true') {
      titleLog = 'Cập nhật dữ liệu thành công';
    } else {
      titleLog = 'Cập nhật thất bại';
    }
    return titleLog;
  }

  updateTTDT(id, admissionDate) async {
    infoTtsTTDT["admissionDate"] = admissionDate;

    var response =
        await httpPut('/api/tts-thongtindaotao/put/$id', infoTtsTTDT, context);
    if (response['body'] == 'true') {
      titleLog = 'Cập nhật dữ liệu thành công';
    } else {
      titleLog = 'Cập nhật thất bại';
    }
    return titleLog;
  }

  updateNYP(id, minBook1, minBook2, dictionary, kanji, clothes, sandals,
      userCard, blanket, mat, drape) async {
    var data = {
      "minBook1": minBook1,
      "minBook2": minBook2,
      "dictionary": dictionary,
      "kanji": kanji,
      "clothes": clothes,
      "sandals": sandals,
      "userCard": userCard,
      "blanket": blanket,
      "mat": mat,
      "drape": drape
    };
    var response =
        await httpPut('/api/tts-thongtindaotao-hocpham/put/$id', data, context);
    if (response['body'] == 'true') {
      titleLog = 'Cập nhật dữ liệu thành công';
    } else {
      titleLog = 'Cập nhật thất bại';
    }
    return titleLog;
  }

  submitForm() async {
    bool status = true;
    for (var row in viPham) {
      if (row['violateContent'].text == '' && row['status'] == true)
        status = false;
      if (row['violateDate'] == null && row['status'] == true) status = false;
    }
    if (dateDisplay == null) {
      status = false;
    }

    if (status) {
      if (checkInfoTtsTTDT.isNotEmpty) {
        await updateTTDT(
          infoTtsTTDT['id'],
          dateReverse(dateDisplay),
        );
      } else {
        await addTTDT(widget.id, dateReverse(dateDisplay));
        await httpPost(
            "/api/thongbao/post/save",
            {
              "userId": widget.id,
              "notiType": 3,
              "content":
                  "Bạn có lịch nhập học ${DateFormat("dd-MM-yyyy").format(DateTime.now())}",
              "implementDate":
                  "${DateFormat("yyyy-MM-dd").format(DateTime.now())}"
            },
            context);
      }
      int getNhuYeuPham(title) {
        for (var row in listNhuYeuPham) {
          if (row['title'] == title && row['value'] == true) {
            return 1;
          }
        }
        return 0;
      }

      if (listCheckNYP.isNotEmpty) {
        await updateNYP(
            listNYP['id'],
            getNhuYeuPham('Sách Min 1'),
            getNhuYeuPham('Sách Min 2'),
            getNhuYeuPham('Từ điển'),
            getNhuYeuPham('Kanji'),
            getNhuYeuPham('2 áo'),
            getNhuYeuPham('1 đôi dép'),
            getNhuYeuPham('1 thẻ'),
            getNhuYeuPham('Chăn'),
            getNhuYeuPham('Chiếu'),
            getNhuYeuPham('Màn'));
      } else {
        await addNYP(
            widget.id,
            getNhuYeuPham('Sách Min 1'),
            getNhuYeuPham('Sách Min 2'),
            getNhuYeuPham('Từ điển'),
            getNhuYeuPham('Kanji'),
            getNhuYeuPham('2 áo'),
            getNhuYeuPham('1 đôi dép'),
            getNhuYeuPham('1 thẻ'),
            getNhuYeuPham('Chăn'),
            getNhuYeuPham('Chiếu'),
            getNhuYeuPham('Màn'));
      }
      for (var row in viPham) {
        if (row['status'] == true && row['id'] != null) {
          await updateVP(
              row['id'],
              false,
              row['violateContent'].text,
              dateReverse(row['violateDate']),
              int.parse(row['isDone']),
              int.parse(row['ruleId']));
        } else if (row['status'] == true && row['id'] == null) {
          await addVP(
              false,
              int.parse(widget.id!),
              row['violateContent'].text,
              dateReverse(row['violateDate']),
              int.parse(row['isDone']),
              int.parse(row['ruleId']));
        } else if (row['status'] == false && row['id'] != null) {
          await updateVP(
              row['id'],
              true,
              row['violateContent'].text,
              dateReverse(row['violateDate']),
              int.parse(row['isDone']),
              int.parse(row['ruleId']));
        }
      }
      showToast(
        context: context,
        msg: titleLog,
        color: titleLog == "Cập nhật dữ liệu thành công"
            ? Color.fromARGB(136, 72, 238, 67)
            : Colors.red,
        icon: titleLog == "Cập nhật dữ liệu thành công"
            ? Icon(Icons.done)
            : Icon(Icons.warning),
      );
      Provider.of<NavigationModel>(context, listen: false)
          .add(pageUrl: "/danh-sach-thuc-tap-sinh");
      getInfoTtsFuture = getInfoTts();
    } else {
      showToast(
        context: context,
        msg: "Yêu cầu nhập đầy đủ các trường yêu cầu",
        color: Colors.red,
        icon: Icon(Icons.warning),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    // titleLog = 'Cập nhật thất bại';
    getInfoTtsFuture = getInfoTts();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    return FutureBuilder<dynamic>(
      future: userRule('/cap-nhat-thong-tin-dao-tao', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return FutureBuilder<dynamic>(
            future: getInfoTtsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  color: backgroundPage,
                  padding: EdgeInsets.symmetric(
                      vertical: verticalPaddingPage,
                      horizontal: horizontalPaddingPage),
                  child: SingleChildScrollView(
                    controller: ScrollController(),
                    child: Container(
                      // padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
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
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SelectableText(
                                'Thông tin lớp học  ',
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
                          Row(
                            children: [
                              Expanded(
                                  flex: 7,
                                  child: DatePickerBoxVQ(
                                      label: Row(
                                        children: [
                                          SelectableText(
                                            'Ngày nhập học',
                                            style: titleWidgetBox,
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(left: 5),
                                            child: SelectableText(
                                              "*",
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 16),
                                            ),
                                          ),
                                        ],
                                      ),
                                      isTime: false,
                                      dateDisplay: dateDisplay,
                                      selectedDateFunction: (day) {
                                        dateDisplay = day;
                                        setState(() {});
                                      })),
                              Expanded(
                                flex: 6,
                                child: Container(),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: SelectableText('Lớp',
                                    style: titleWidgetBox),
                              ),
                              Expanded(
                                flex: 5,
                                child: SelectableText(infoTts != null
                                    ? infoTts['lophoc']['name']
                                    : 'Chưa phân lớp'),
                              ),
                              Expanded(
                                flex: 6,
                                child: Container(),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: SelectableText('Giáo viên chủ nhiệm',
                                    style: titleWidgetBox),
                              ),
                              Expanded(
                                  flex: 5,
                                  child: SelectableText(infoTts != null
                                      ? infoTts['lophoc']['giaovien']
                                          ['fullName']
                                      : 'Chưa phân lớp')),
                              Expanded(
                                flex: 6,
                                child: Container(),
                              )
                            ],
                          ),

                          SizedBox(
                            height: 50,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SelectableText(
                                'Nhu yếu phẩm ',
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
                          LableWidthCheckbox(
                            listCheckBox: listNhuYeuPham,
                            function: (value) {
                              listNhuYeuPham = value;
                            },
                          ),

                          SizedBox(
                            height: 50,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SelectableText(
                                'Các vi phạm (Nếu có) ',
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
                          Row(
                            children: [
                              Expanded(
                                child: DataTable(
                                  headingRowColor: MaterialStateProperty.all(
                                      backgroundColor),
                                  columnSpacing: 0,
                                  horizontalMargin: 0,
                                  columns: [
                                    DataColumn(
                                        label: Container(
                                      width: width * .02,
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: SelectableText(
                                            'STT',
                                            style: titleTableData,
                                            textAlign: TextAlign.center,
                                          )),
                                        ],
                                      ),
                                    )),
                                    DataColumn(
                                        label: Container(
                                      width: width * .1,
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: SelectableText(
                                            'Ngày tháng',
                                            style: titleTableData,
                                            textAlign: TextAlign.center,
                                          )),
                                        ],
                                      ),
                                    )),
                                    DataColumn(
                                        label: Container(
                                      width: width * .15,
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: SelectableText(
                                            'Phát sinh/Lỗi',
                                            style: titleTableData,
                                            textAlign: TextAlign.center,
                                          )),
                                        ],
                                      ),
                                    )),
                                    DataColumn(
                                        label: Container(
                                      width: width * .35,
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: SelectableText(
                                            'Quy định',
                                            style: titleTableData,
                                            textAlign: TextAlign.center,
                                          )),
                                        ],
                                      ),
                                    )),
                                    DataColumn(
                                        label: Container(
                                      width: width * .05,
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: SelectableText(
                                            '',
                                            style: titleTableData,
                                            textAlign: TextAlign.center,
                                          )),
                                        ],
                                      ),
                                    )),
                                  ],
                                  rows: <DataRow>[
                                    for (int i = 0; i < viPham.length; i++)
                                      if (viPham[i]['status'] == true)
                                        DataRow(cells: <DataCell>[
                                          DataCell(Container(
                                              width: width * .02,
                                              margin: EdgeInsets.only(
                                                  left: width * .005),
                                              child: SelectableText(
                                                  (i + 1).toString(),
                                                  style: bangDuLieu))),
                                          // DataCell(DateTimePiker(
                                          //   time: data[i].time,
                                          // )),
                                          DataCell(Container(
                                            width: width * .1,
                                            child: DatePickerInTable(
                                              dateDisplay: viPham[i]
                                                  ['violateDate'],
                                              function: (date) {
                                                viPham[i]['violateDate'] = date;
                                              },
                                            ),
                                          )),
                                          DataCell(Container(
                                            width: width * .15,
                                            height: 40,
                                            child: TextField(
                                              textAlign: TextAlign.center,
                                              decoration: InputDecoration(
                                                  hintText: 'Nhập thông tin',
                                                  border: InputBorder.none),
                                              controller: viPham[i]
                                                  ['violateContent'],
                                              onSubmitted: (value) {
                                                submitForm();
                                              },
                                            ),
                                          )),
                                          DataCell(Container(
                                            width: width * .35,
                                            color: Colors.white,
                                            height: 40,
                                            child: DropdownBtnSearch(
                                              isAll: false,
                                              // label: 'Chào hỏi cơ bản',
                                              border: false,
                                              listItems: listItemsQuyDinh,
                                              isSearch: true,
                                              search: TextEditingController(),
                                              selectedValue: viPham[i]
                                                  ['ruleId'],
                                              setSelected: (selected) {
                                                viPham[i]['ruleId'] = selected;
                                                print(selected);
                                                setState(() {});
                                              },
                                            ),
                                          )),
                                          DataCell(Container(
                                              width: width * .05,
                                              color: Colors.white,
                                              height: 40,
                                              child: IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      viPham[i]['status'] =
                                                          false;
                                                    });
                                                  },
                                                  icon: Icon(
                                                    Icons.remove,
                                                    color: Colors.red,
                                                  )))),
                                        ])
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 25),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                  onPressed: () {
                                    setState(() {
                                      viPham.add({
                                        "id": null,
                                        "ttsId": int.parse(widget.id!),
                                        "departId": 4,
                                        "violateContent":
                                            TextEditingController(),
                                        "violateDate": null,
                                        "ruleId":
                                            listItemsQuyDinh.first['value'] ??
                                                null,
                                        "isDone": '0',
                                        "status": true
                                      });
                                    });
                                  },
                                  icon: Icon(Icons.add))
                            ],
                          ),
                          SizedBox(
                            height: 150,
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
                                              fontSize: 20.0,
                                              letterSpacing: 2.0),
                                    ),
                                    onPressed: () {
                                      Provider.of<NavigationModel>(context,
                                              listen: false)
                                          .add(
                                              pageUrl:
                                                  "/danh-sach-thuc-tap-sinh");
                                    },
                                    child: Text('Hủy', style: textButton),
                                  ),
                                ),
                                getRule(listRule.data, Role.Sua, context)
                                    ? Container(
                                        margin: EdgeInsets.only(left: 20),
                                        child: TextButton(
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
                                          onPressed: () async {
                                            submitForm();
                                          },
                                          child: Row(
                                            children: [
                                              Text('Lưu', style: textButton),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Container(),
                              ]),
                          Footer()
                        ],
                      ),
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return SelectableText('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const Center(child: CircularProgressIndicator());
            },
          );
        } else if (listRule.hasError) {
          return SelectableText('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class LableWidthCheckbox extends StatefulWidget {
  final List<dynamic> listCheckBox;
  final Function function;
  const LableWidthCheckbox(
      {Key? key, required this.listCheckBox, required this.function})
      : super(key: key);

  @override
  State<LableWidthCheckbox> createState() => _LableWidthCheckboxState();
}

class _LableWidthCheckboxState extends State<LableWidthCheckbox> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 25.0,
      spacing: 5.0,
      children: [
        for (var row in widget.listCheckBox)
          Container(
            width: 600,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Checkbox(
                    checkColor: Colors.white,
                    value: row['value'],
                    onChanged: (value) {
                      setState(() {
                        row['value'] = value!;
                        widget.function(widget.listCheckBox);
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: SelectableText(
                    row['title'],
                    style: TextStyle(
                      color: Color(0xff333333),
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
          ),
      ],
    );
  }
}

class DatePickerInTable extends StatefulWidget {
  String? dateDisplay;
  Function function;
  DatePickerInTable({Key? key, this.dateDisplay, required this.function})
      : super(key: key);

  @override
  State<DatePickerInTable> createState() => _DatePickerTableInState();
}

class _DatePickerTableInState extends State<DatePickerInTable> {
  String? dateDisplay;
  DateTime selectedDate = DateTime.now();
  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2040),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        dateDisplay = DateFormat("dd-MM-yyyy").format(selectedDate.toLocal());
        widget.function(dateDisplay!);
      });
  }

  @override
  // ignore: must_call_super
  void initState() {
    if (widget.dateDisplay != null) dateDisplay = widget.dateDisplay!;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SelectableText(dateDisplay ?? 'Chọn ngày',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(height: 20.0),
        IconButton(
            onPressed: () => _selectDate(context),
            icon: Icon(Icons.date_range),
            color: Colors.blue[400]),
      ],
    );
  }
}
