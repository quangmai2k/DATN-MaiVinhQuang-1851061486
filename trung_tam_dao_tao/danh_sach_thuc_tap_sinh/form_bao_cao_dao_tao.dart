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

class BaoCaoDaoTao extends StatefulWidget {
  final String? id;
  const BaoCaoDaoTao({Key? key, this.id}) : super(key: key);

  @override
  State<BaoCaoDaoTao> createState() => _BaoCaoDaoTaoState();
}

class _BaoCaoDaoTaoState extends State<BaoCaoDaoTao> {
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
        print("object");
        infoTtsTTDT = checkInfoTtsTTDT[0];
        await getListInfoDTTN(infoTtsTTDT['id']);
        idTtdt = infoTtsTTDT['id'];
        trainedBeforeExam =
            infoTtsTTDT['trainedBeforeExam'] == 1 ? true : false;
        if (infoTtsTTDT['trainedContentBeforeExam'] != null)
          trainedContentBeforeExam.text =
              infoTtsTTDT['trainedContentBeforeExam'];
        if (infoTtsTTDT['basicGreetings'] != null)
          selectedCHCB = infoTtsTTDT['basicGreetings'].toString();
        alphabetScore.text = infoTtsTTDT['alphabetScore'] != null
            ? infoTtsTTDT['alphabetScore'].toString()
            : '';
        if (infoTtsTTDT['alphabet'] != null)
          selectedBCC = infoTtsTTDT['alphabet'].toString();
        if (infoTtsTTDT['n5'] != null)
          selectedDTN5 = infoTtsTTDT['n5'].toString();
        if (infoTtsTTDT['n4'] != null)
          selectedDTN4 = infoTtsTTDT['n4'].toString();
        n4Score.text = infoTtsTTDT['n4Score'] != null
            ? infoTtsTTDT['n4Score'].toString()
            : '';
        n5Score.text = infoTtsTTDT['n5Score'] != null
            ? infoTtsTTDT['n5Score'].toString()
            : '';
        trainedBeforeFlight =
            infoTtsTTDT['trainedBeforeFlight'] == 1 ? true : false;
        if (infoTtsTTDT['trainedContentBeforeFlight'] != null)
          trainedContentBeforeFlight.text =
              infoTtsTTDT['trainedContentBeforeFlight'];
        fileChungChi = infoTtsTTDT['vnuCertificate'];
        setState(() {});
      }
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

  updateTTDT(
      id,
      trainedBeforeExam,
      trainedContentBeforeExam,
      basicGreetings,
      alphabet,
      alphabetScore,
      n5,
      n5Score,
      n4,
      n4Score,
      trainedBeforeFlight,
      trainedContentBeforeFlight,
      fileName) async {
    int trainedAfterExam;
    trainedAfterExam = alphabetScore != '' ? 1 : 0;
    infoTtsTTDT['trainedBeforeExam'] = trainedBeforeExam;
    infoTtsTTDT['trainedContentBeforeExam'] = trainedContentBeforeExam;
    infoTtsTTDT['trainedAfterExam'] = trainedAfterExam;
    infoTtsTTDT['basicGreetings'] = basicGreetings;
    infoTtsTTDT['alphabet'] = alphabet;
    infoTtsTTDT['n5'] = n5;
    infoTtsTTDT['n5Score'] = n5Score;
    infoTtsTTDT['n4'] = n4;
    infoTtsTTDT['n4Score'] = n4Score;
    infoTtsTTDT['trainedBeforeFlight'] = trainedBeforeFlight;
    infoTtsTTDT['trainedContentBeforeFlight'] = trainedContentBeforeFlight;
    infoTtsTTDT['alphabetScore'] = alphabetScore;

    if (fileName != null) {
      infoTtsTTDT["vnuCertificate"] = fileName;
    }
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
    for (var row in daoTaoTiengNhat) {
      if ((row['lessonFrom'].text == '' || !isNumber(row['lessonFrom'].text)) &&
          row['status'] == true) status = false;
      if (row['reportFile'] == null && row['status'] == true) status = false;
      if ((row['lessonTo'].text == '' || !isNumber(row['lessonTo'].text)) &&
          row['status'] == true) status = false;
    }
    if (alphabetScore.text.isNotEmpty && !isNumber(alphabetScore.text)) {
      status = false;
    }
    int valueBool(bool x) {
      if (x == true)
        return 1;
      else
        return 0;
    }

    dynamic parsePoint(point) {
      if (point == '') {
        return null;
      } else {
        return int.parse(point);
      }
    }

    if (status) {
      if (fileChungChi == null || fileChungChi.runtimeType == String) {
        await updateTTDT(
            infoTtsTTDT['id'],
            valueBool(trainedBeforeExam),
            trainedContentBeforeExam.text,
            int.parse(selectedCHCB),
            int.parse(selectedBCC),
            parsePoint(alphabetScore.text),
            int.parse(selectedDTN5),
            parsePoint(n5Score.text),
            int.parse(selectedDTN4),
            parsePoint(n4Score.text),
            valueBool(trainedBeforeFlight),
            trainedContentBeforeFlight.text,
            fileChungChi);
      } else {
        await uploadFile(fileChungChi, context: context).then((data) async {
          await updateTTDT(
              infoTtsTTDT['id'],
              valueBool(trainedBeforeExam),
              trainedContentBeforeExam.text,
              int.parse(selectedCHCB),
              int.parse(selectedBCC),
              parsePoint(alphabetScore.text),
              int.parse(selectedDTN5),
              parsePoint(n5Score.text),
              int.parse(selectedDTN4),
              parsePoint(n4Score.text),
              valueBool(trainedBeforeFlight),
              trainedContentBeforeFlight.text,
              data);
        });
      }

      for (var row in daoTaoTiengNhat) {
        if (row['status'] == true && row['id'] != null) {
          if (row["reportFile"].runtimeType == String) {
            await updateTN(
                row['id'],
                row['academicPerformanceComment'].text,
                row['attitudeComment'].text,
                int.parse(row['lessonFrom'].text),
                int.parse(row['lessonTo'].text),
                dateReverse(row['reportDate']),
                false,
                row['reportFile']);
          } else {
            await uploadFile(row['reportFile'], context: context)
                .then((data) async {
              await updateTN(
                  row['id'],
                  row['academicPerformanceComment'].text,
                  row['attitudeComment'].text,
                  int.parse(row['lessonFrom'].text),
                  int.parse(row['lessonTo'].text),
                  dateReverse(row['reportDate']),
                  false,
                  data);
              print(data);
            });
          }
        } else if (row['status'] == true && row['id'] == null) {
          await uploadFile(row['reportFile'], context: context)
              .then((data) async {
            await addTN(
                row['academicPerformanceComment'].text,
                row['attitudeComment'].text,
                int.parse(row['lessonFrom'].text),
                int.parse(row['lessonTo'].text),
                dateReverse(row['reportDate']),
                data);
          });
        } else if (row['status'] == false && row['id'] != null) {
          await updateTN(
              row['id'],
              row['academicPerformanceComment'].text,
              row['attitudeComment'].text,
              int.parse(row['lessonFrom'].text),
              int.parse(row['lessonTo'].text),
              dateReverse(row['reportDate']),
              true,
              "Đã xóa");
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
    getInfoTtsFuture = getInfoTts();
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    var curentUser =
        Provider.of<SecurityModel>(context, listen: false).userLoginCurren;

    return FutureBuilder<dynamic>(
      future: userRule('/cap-nhat-thong-tin-dao-tao', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return FutureBuilder<dynamic>(
            future: getInfoTtsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (infoTts['lophoc']['giaovienId'] == curentUser['id'] ||
                    curentUser['departId'] == 2 ||
                    curentUser['departId'] == 1 ||
                    (curentUser['departId'] == 7 &&
                        curentUser['vaitro'] != null &&
                        curentUser['vaitro']['level'] >= 2)) {
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
                                  'Đào tạo trước thi tuyển ',
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
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Checkbox(
                                    checkColor: Colors.white,
                                    value: trainedBeforeExam,
                                    onChanged: (value) {
                                      setState(() {
                                        trainedBeforeExam = value!;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  flex: 25,
                                  child: SelectableText(
                                    'Đã đào tạo trước thi tuyển',
                                    style: TextStyle(
                                      color: Color(0xff333333),
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: SelectableText(
                                    'Nội dung đào tạo',
                                    style: titleWidgetBox,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    child: TextField(
                                      minLines: 3,
                                      maxLines: 3,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                      ),
                                      controller: trainedContentBeforeExam,
                                      onChanged: (value) {
                                        print(trainedContentBeforeExam.text);
                                      },
                                      onSubmitted: (value) {
                                        submitForm();
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SelectableText(
                                  'Đào tạo sau trúng tuyển ',
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
                                SelectableText(
                                  '1. Đào tạo cơ bản ',
                                  style: titleBox,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Container(
                                margin: EdgeInsets.only(left: 25),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 5,
                                      child: DropdownBtnSearch(
                                        isAll: false,
                                        label: 'Chào hỏi cơ bản',
                                        listItems: itemsTT,
                                        isSearch: false,
                                        selectedValue: selectedCHCB,
                                        setSelected: (selected) {
                                          selectedCHCB = selected;
                                        },
                                        flexLabel: 3,
                                      ),
                                    ),
                                    Expanded(flex: 8, child: Container())
                                  ],
                                )),
                            SizedBox(
                              height: 25,
                            ),
                            Container(
                                margin: EdgeInsets.only(left: 25),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextFieldValidatedForm(
                                        height: 40,
                                        flexLable: 2,
                                        flexTextField: 1,
                                        label: 'Bảng chữ cái',
                                        type: 'Number',
                                        controller: alphabetScore,
                                        enter: () {
                                          submitForm();
                                        },
                                      ),
                                    ),
                                    Expanded(
                                        flex: 4,
                                        child: Container(
                                          child: Center(
                                            child: SelectableText(
                                              'điểm',
                                              style: titleWidgetBox,
                                            ),
                                          ),
                                        )),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        height: 40,
                                        child: DropdownBtnSearch(
                                          isAll: false,
                                          // label: 'Chào hỏi cơ bản',
                                          listItems: itemsTT,
                                          isSearch: false,
                                          selectedValue: selectedBCC,
                                          setSelected: (selected) {
                                            selectedBCC = selected;
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(flex: 5, child: Container())
                                  ],
                                )),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              children: [
                                SelectableText(
                                  '2. Đào tạo tiếng Nhật ',
                                  style: titleBox,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Column(
                              children: [
                                for (var row in daoTaoTiengNhat)
                                  if (row['status'] == true)
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                margin:
                                                    EdgeInsets.only(left: 25),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    DatePickerBoxVQ(
                                                        isTime: false,
                                                        dateDisplay:
                                                            row['reportDate'],
                                                        selectedDateFunction:
                                                            (day) {
                                                          row['reportDate'] =
                                                              dateReverse(day);
                                                          setState(() {});
                                                        }),
                                                    SizedBox(
                                                      height: 25,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                            child:
                                                                TextFieldValidatedForm(
                                                          height: 40,
                                                          flexLable: 1,
                                                          flexTextField: 1,
                                                          label: 'Bài số',
                                                          type: 'Number',
                                                          controller:
                                                              row['lessonFrom'],
                                                          enter: () {
                                                            submitForm();
                                                          },
                                                          requiredValue: 1,
                                                        )),
                                                        SizedBox(
                                                          width: 25,
                                                        ),
                                                        Expanded(
                                                            child:
                                                                TextFieldValidatedForm(
                                                          height: 40,
                                                          flexLable: 1,
                                                          flexTextField: 1,
                                                          label: 'đến',
                                                          type: 'Number',
                                                          controller:
                                                              row['lessonTo'],
                                                          enter: () {
                                                            submitForm();
                                                          },
                                                          requiredValue: 1,
                                                        )),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 25,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: Center(
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                SelectableText(
                                                                  'Báo cáo',
                                                                  style:
                                                                      titleWidgetBox,
                                                                ),
                                                                Container(
                                                                  margin: EdgeInsets
                                                                      .only(
                                                                          left:
                                                                              5),
                                                                  child:
                                                                      SelectableText(
                                                                    "*",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .red,
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    row['reportFile'] == null
                                                        ? IconButton(
                                                            onPressed:
                                                                () async {
                                                              var file =
                                                                  await FilePicker
                                                                      .platform
                                                                      .pickFiles(
                                                                type: FileType
                                                                    .custom,
                                                                allowedExtensions: [],
                                                                withReadStream:
                                                                    true, //
                                                              );
                                                              // _localPath;
                                                              if (file != null)
                                                                row['reportFile'] =
                                                                    file;
                                                              setState(() {});
                                                            },
                                                            icon: Icon(Icons
                                                                .upload_file),
                                                            color: Colors
                                                                .blue[400],
                                                          )
                                                        : TextButton(
                                                            onPressed:
                                                                () async {
                                                              var file =
                                                                  await FilePicker
                                                                      .platform
                                                                      .pickFiles(
                                                                type: FileType
                                                                    .custom,
                                                                allowedExtensions: [],
                                                                withReadStream:
                                                                    true, //
                                                              );
                                                              // _localPath;
                                                              if (file != null)
                                                                row['reportFile'] =
                                                                    file;

                                                              setState(() {});
                                                            },
                                                            child: Text(
                                                                '${row['reportFile'].runtimeType == String ? row['reportFile'] : row['reportFile']!.files.first.name}'))
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              margin: EdgeInsets.only(
                                                  left: 50, right: 50),
                                              width: 1,
                                              height: 350,
                                              color: ColorHorizontalLine,
                                            ),
                                            Expanded(
                                                flex: 7,
                                                child: Container(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          IconButton(
                                                              onPressed: () {
                                                                setState(() {
                                                                  row['status'] =
                                                                      false;
                                                                });
                                                              },
                                                              icon: Icon(
                                                                Icons.remove,
                                                                color:
                                                                    Colors.red,
                                                              )),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                SelectableText(
                                                              'Nhận xét về học lực',
                                                              style:
                                                                  titleWidgetBox,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 25,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                              child: Container(
                                                            child: TextField(
                                                              controller: row[
                                                                  'academicPerformanceComment'],
                                                              minLines: 3,
                                                              maxLines: 3,
                                                              decoration:
                                                                  InputDecoration(
                                                                border:
                                                                    OutlineInputBorder(),
                                                              ),
                                                              onSubmitted:
                                                                  (value) {
                                                                submitForm();
                                                              },
                                                            ),
                                                          )),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 25,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                            child:
                                                                SelectableText(
                                                              'Nhận xét về thái độ',
                                                              style:
                                                                  titleWidgetBox,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(
                                                        height: 25,
                                                      ),
                                                      Row(
                                                        children: [
                                                          Expanded(
                                                              child: Container(
                                                            child: TextField(
                                                              controller: row[
                                                                  'attitudeComment'],
                                                              minLines: 3,
                                                              maxLines: 3,
                                                              decoration:
                                                                  InputDecoration(
                                                                border:
                                                                    OutlineInputBorder(),
                                                              ),
                                                              onSubmitted:
                                                                  (value) {
                                                                submitForm();
                                                              },
                                                            ),
                                                          )),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                )),
                                          ],
                                        ),
                                        Container(
                                          margin: marginTopBottomHorizontalLine,
                                          child: Divider(
                                            thickness: 1,
                                            color: ColorHorizontalLine,
                                          ),
                                        ),
                                      ],
                                    ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        daoTaoTiengNhat.add({
                                          'id': null,
                                          'reportDate': DateFormat("dd-MM-yyyy")
                                              .format(DateTime.now().toLocal())
                                              .toString(),
                                          'lessonFrom': TextEditingController(),
                                          'lessonTo': TextEditingController(),
                                          'reportFile': null,
                                          'attitudeComment':
                                              TextEditingController(),
                                          'academicPerformanceComment':
                                              TextEditingController(),
                                          'status': true
                                        });
                                      });
                                    },
                                    icon: Icon(Icons.add))
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              children: [
                                SelectableText(
                                  '3. Điểm thi năng lực tiếng Nhật ',
                                  style: titleBox,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Container(
                                margin: EdgeInsets.only(left: 25),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextFieldValidatedForm(
                                        label: 'N5',
                                        height: 40,
                                        type: 'Number',
                                        flexLable: 2,
                                        flexTextField: 1,
                                        controller: n5Score,
                                        enter: () {
                                          submitForm();
                                        },
                                      ),
                                    ),
                                    Expanded(
                                        flex: 3,
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 30),
                                          child: Center(
                                            child: SelectableText(
                                              'điểm',
                                              style: titleWidgetBox,
                                            ),
                                          ),
                                        )),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 30),
                                        child: DropdownBtnSearch(
                                          isAll: false,
                                          // label: 'Chào hỏi cơ bản',
                                          listItems: itemsTT,
                                          isSearch: false,
                                          selectedValue: selectedDTN5,
                                          setSelected: (selected) {
                                            selectedDTN5 = selected;
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(flex: 11, child: Container())
                                  ],
                                )),
                            Container(
                                margin: EdgeInsets.only(left: 25),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextFieldValidatedForm(
                                        label: 'N4',
                                        height: 40,
                                        type: 'Number',
                                        flexLable: 2,
                                        flexTextField: 1,
                                        controller: n4Score,
                                        enter: () {
                                          submitForm();
                                        },
                                      ),
                                    ),
                                    Expanded(
                                        flex: 3,
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 30),
                                          child: Center(
                                            child: SelectableText(
                                              'điểm',
                                              style: titleWidgetBox,
                                            ),
                                          ),
                                        )),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 30),
                                        child: DropdownBtnSearch(
                                          isAll: false,
                                          // label: 'Chào hỏi cơ bản',
                                          listItems: itemsTT,
                                          isSearch: false,
                                          selectedValue: selectedDTN4,
                                          setSelected: (selected) {
                                            selectedDTN4 = selected;
                                          },
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 11,
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 30),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              SelectableText(
                                                'Kết quả thi tuyển chứng chỉ tại ĐHQG',
                                                style: titleWidgetBox,
                                              ),
                                              SizedBox(
                                                width: 25,
                                              ),
                                              fileChungChi == null
                                                  ? IconButton(
                                                      onPressed: () async {
                                                        var file =
                                                            await FilePicker
                                                                .platform
                                                                .pickFiles(
                                                          type: FileType.custom,
                                                          allowedExtensions: [],
                                                          withReadStream:
                                                              true, //
                                                        );
                                                        fileChungChi = file;
                                                        setState(() {});
                                                      },
                                                      icon: Icon(
                                                          Icons.upload_file),
                                                      color: Colors.blue[400],
                                                    )
                                                  : TextButton(
                                                      onPressed: () async {
                                                        var file =
                                                            await FilePicker
                                                                .platform
                                                                .pickFiles(
                                                          type: FileType.custom,
                                                          allowedExtensions: [],
                                                          withReadStream:
                                                              true, //
                                                        );
                                                        // _localPath;
                                                        if (file != null)
                                                          fileChungChi = file;

                                                        setState(() {});
                                                      },
                                                      child: SelectableText(
                                                          '${fileChungChi.runtimeType == String ? fileChungChi == 'null' ? 'Upload' : fileChungChi : fileChungChi!.files.first.name ?? 'Upload'}'))
                                            ],
                                          ),
                                        ))
                                  ],
                                )),
                            Row(
                              children: [
                                SelectableText(
                                  '4. Đào tạo trước xuất cảnh ',
                                  style: titleBox,
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Checkbox(
                                    checkColor: Colors.white,
                                    value: trainedBeforeFlight,
                                    onChanged: (value) {
                                      setState(() {
                                        trainedBeforeFlight = value!;
                                      });
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: SelectableText(
                                    'Đã đào tạo ',
                                    style: TextStyle(
                                      color: Color(0xff333333),
                                      fontSize: 16,
                                    ),
                                  ),
                                  flex: 25,
                                )
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: SelectableText(
                                    'Nội dung chi tiết',
                                    style: titleWidgetBox,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    child: TextField(
                                      minLines: 3,
                                      maxLines: 3,
                                      controller: trainedContentBeforeFlight,
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                      ),
                                      onSubmitted: (value) {
                                        submitForm();
                                      },
                                    ),
                                  ),
                                ),
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 20.0,
                                                horizontal: 10.0,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                              backgroundColor: Color.fromRGBO(
                                                  245, 117, 29, 1),
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
                            Footer(),
                          ],
                        ),
                      ),
                    ),
                  );
                } else
                  return Container(
                    margin: EdgeInsets.only(top: 30),
                    color: backgroundPage,
                    padding: EdgeInsets.symmetric(
                        vertical: 0, horizontal: horizontalPaddingPage),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 1,
                      decoration: BoxDecoration(
                        color: colorWhite,
                        borderRadius: borderRadiusContainer,
                        boxShadow: [boxShadowContainer],
                        border: borderAllContainerBox,
                      ),
                      padding: paddingBoxContainer,
                      child: Center(
                        child: SelectableText(
                          "Bạn không có quyền chỉnh sửa thông tin này",
                          style: TextStyle(fontSize: 24),
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
