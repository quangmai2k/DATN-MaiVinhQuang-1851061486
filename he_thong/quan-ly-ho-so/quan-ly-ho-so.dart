// ignore_for_file: unused_local_variable
import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/he_thong/quan-ly-ho-so/sua-ho-so.dart';
import 'package:gentelella_flutter/widgets/ui/he_thong/quan-ly-ho-so/them-moi-ho-so.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../../navigation.dart';

class QuanLyHoSo extends StatefulWidget {
  const QuanLyHoSo({Key? key}) : super(key: key);

  @override
  State<QuanLyHoSo> createState() => _QuanLyHoSoState();
}

class _QuanLyHoSoState extends State<QuanLyHoSo> with TickerProviderStateMixin {
  var idCheck = [];
  int? selectedBP;
  var body = {};
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  var tableIndex = 1;
  List<HoSo> listHoSo = [];
  String find = "";
  Future<List<HoSo>> getListHoSo(page, String find) async {
    listHoSo = [];
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response;
    if (find == "") {
      response = await httpGet("/api/tts-hoso/get/page?size=$rowPerPage&page=$page", context);
    } else {
      response = await httpGet("/api/tts-hoso/get/page?size=$rowPerPage&page=$page&filter=deleted:false $find ", context);
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

        listHoSo = content.map((e) {
          return HoSo.fromJson(e);
        }).toList();
        for (var item in listHoSo) print("item.description:${item.description}");
      });
    }
    return listHoSo;
  }

  TextEditingController tieuDe = TextEditingController();
  int selectedRF = 2;
  Map<int, String> requiredFind = {2: 'T???t c???', 0: 'Kh??ng', 1: 'C??'};
  int selectedFileGroupFind = 2;
  Map<int, String> fileGroupFind = {2: 'T???t c???', 0: 'Ch??nh', 1: 'Kh??c'};
  int selectedFileGenericFind = 3;
  Map<int, String> fileGenericFind = {3: 'T???t c???', 0: 'C?? nh??n', 1: 'Xu???t c???nh', 2: 'Nh??n s???'};
  int selectedContentTypeFind = 4;
  Map<int, String> contentTypeFind = {4: 'T???t c???', 0: 'File', 1: 'V??n b???n', 2: 'Ng??y', 3: '???nh'};
  bool status = false;
  void callAPI() async {
    await getListHoSo(0, find);

    setState(() {
      status = true;
    });
  }

  @override
  void initState() {
    super.initState();
    callAPI();
  }

  @override
  void dispose() {
    tieuDe.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
      widgetBody: Consumer<NavigationModel>(
          builder: (context, navigationModel, child) => SingleChildScrollView(
                controller: ScrollController(),
                child: Column(children: [
                  TitlePage(
                    listPreTitle: [
                      {'url': "/dashboard", 'title': 'Home / H??? th???ng'},
                      // {'url': "/he-thong", 'title': 'H??? th???ng'},
                    ],
                    content: 'Qu???n l?? h??? s??',
                    widgetBoxRight: Row(
                      children: [],
                    ),
                  ),
                  (status)
                      ? Column(
                          children: [
                            Container(
                              padding: paddingBoxContainer,
                              margin: paddingBoxContainer,
                              width: MediaQuery.of(context).size.width * 1,
                              decoration: BoxDecoration(
                                color: colorWhite,
                                borderRadius: borderRadiusContainer,
                                boxShadow: [boxShadowContainer],
                                border: borderAllContainerBox,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Nh???p th??ng tin',
                                        style: titleBox,
                                      ),
                                      Icon(
                                        Icons.more_horiz,
                                        color: Color(0xff9aa5ce),
                                        size: 14,
                                      ),
                                    ],
                                  ),
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
                                        child: TextFieldValidatedForm(
                                          type: 'None',
                                          height: 40,
                                          controller: tieuDe,
                                          label: 'T??n h??? s??:',
                                          flexLable: 2,
                                        ),
                                      ),
                                      SizedBox(width: 100),
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 30),
                                          child: Row(),
                                        ),
                                      ),
                                      Expanded(flex: 1, child: Container()),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 30),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text('B???t bu???c:', style: titleWidgetBox),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Container(
                                                  color: Colors.white,
                                                  width: MediaQuery.of(context).size.width * 0.20,
                                                  // width: MediaQuery.of(context).size.width * 0.15,
                                                  height: 40,
                                                  child: DropdownButtonHideUnderline(
                                                    child: DropdownButton2(
                                                      dropdownMaxHeight: 250,
                                                      hint: Text(
                                                        '${requiredFind[2]}',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      items: requiredFind.entries
                                                          .map((item) => DropdownMenuItem<int>(value: item.key, child: Text(item.value)))
                                                          .toList(),
                                                      value: selectedRF,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedRF = value as int;
                                                        });
                                                      },
                                                      buttonHeight: 40,
                                                      itemHeight: 40,
                                                      dropdownDecoration:
                                                          BoxDecoration(border: Border.all(color: const Color.fromRGBO(216, 218, 229, 1))),
                                                      buttonDecoration: BoxDecoration(border: Border.all(width: 0.5, style: BorderStyle.solid)),
                                                      buttonElevation: 0,
                                                      buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                                                      itemPadding: const EdgeInsets.only(left: 14, right: 14),
                                                      dropdownElevation: 5,
                                                      focusColor: Colors.white,
                                                    ),
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
                                          margin: EdgeInsets.only(bottom: 30),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text('Nh??m:', style: titleWidgetBox),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Container(
                                                  color: Colors.white,
                                                  width: MediaQuery.of(context).size.width * 0.20,
                                                  // width: MediaQuery.of(context).size.width * 0.15,
                                                  height: 40,
                                                  child: DropdownButtonHideUnderline(
                                                    child: DropdownButton2(
                                                      dropdownMaxHeight: 250,
                                                      hint: Text(
                                                        '${fileGroupFind[2]}',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      items: fileGroupFind.entries
                                                          .map((item) => DropdownMenuItem<int>(value: item.key, child: Text(item.value)))
                                                          .toList(),
                                                      value: selectedFileGroupFind,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedFileGroupFind = value as int;
                                                        });
                                                      },
                                                      buttonHeight: 40,
                                                      itemHeight: 40,
                                                      dropdownDecoration:
                                                          BoxDecoration(border: Border.all(color: const Color.fromRGBO(216, 218, 229, 1))),
                                                      buttonDecoration: BoxDecoration(border: Border.all(width: 0.5, style: BorderStyle.solid)),
                                                      buttonElevation: 0,
                                                      buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                                                      itemPadding: const EdgeInsets.only(left: 14, right: 14),
                                                      dropdownElevation: 5,
                                                      focusColor: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(flex: 1, child: Container()),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Container(
                                          margin: EdgeInsets.only(bottom: 30),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text('Lo???i h??? s??:', style: titleWidgetBox),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Container(
                                                  color: Colors.white,
                                                  width: MediaQuery.of(context).size.width * 0.20,
                                                  // width: MediaQuery.of(context).size.width * 0.15,
                                                  height: 40,
                                                  child: DropdownButtonHideUnderline(
                                                    child: DropdownButton2(
                                                      dropdownMaxHeight: 250,
                                                      hint: Text(
                                                        '${fileGenericFind[3]}',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      items: fileGenericFind.entries
                                                          .map((item) => DropdownMenuItem<int>(value: item.key, child: Text(item.value)))
                                                          .toList(),
                                                      value: selectedFileGenericFind,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedFileGenericFind = value as int;
                                                        });
                                                      },
                                                      buttonHeight: 40,
                                                      itemHeight: 40,
                                                      dropdownDecoration:
                                                          BoxDecoration(border: Border.all(color: const Color.fromRGBO(216, 218, 229, 1))),
                                                      buttonDecoration: BoxDecoration(border: Border.all(width: 0.5, style: BorderStyle.solid)),
                                                      buttonElevation: 0,
                                                      buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                                                      itemPadding: const EdgeInsets.only(left: 14, right: 14),
                                                      dropdownElevation: 5,
                                                      focusColor: Colors.white,
                                                    ),
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
                                          margin: EdgeInsets.only(bottom: 30),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Text('Ki???u:', style: titleWidgetBox),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Container(
                                                  color: Colors.white,
                                                  width: MediaQuery.of(context).size.width * 0.20,
                                                  // width: MediaQuery.of(context).size.width * 0.15,
                                                  height: 40,
                                                  child: DropdownButtonHideUnderline(
                                                    child: DropdownButton2(
                                                      dropdownMaxHeight: 250,
                                                      hint: Text(
                                                        '${contentTypeFind[4]}',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                      ),
                                                      items: contentTypeFind.entries
                                                          .map((item) => DropdownMenuItem<int>(value: item.key, child: Text(item.value)))
                                                          .toList(),
                                                      value: selectedContentTypeFind,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedContentTypeFind = value as int;
                                                        });
                                                      },
                                                      buttonHeight: 40,
                                                      itemHeight: 40,
                                                      dropdownDecoration:
                                                          BoxDecoration(border: Border.all(color: const Color.fromRGBO(216, 218, 229, 1))),
                                                      buttonDecoration: BoxDecoration(border: Border.all(width: 0.5, style: BorderStyle.solid)),
                                                      buttonElevation: 0,
                                                      buttonPadding: const EdgeInsets.only(left: 14, right: 14),
                                                      itemPadding: const EdgeInsets.only(left: 14, right: 14),
                                                      dropdownElevation: 5,
                                                      focusColor: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(flex: 1, child: Container()),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(right: 20),
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
                                          onPressed: () async {
                                            find = "";
                                            var nameHS = "";
                                            var requiredHS = "";
                                            var fileGroupHS = "";
                                            var fileGenericHS = "";
                                            var contentTypeHS = "";

                                            if (tieuDe.text != "")
                                              nameHS = "and name~'*${tieuDe.text}*' ";
                                            else
                                              nameHS = "";
                                            if (selectedRF != 2)
                                              requiredHS = " and required:$selectedRF";
                                            else
                                              requiredHS = "";
                                            if (selectedFileGroupFind != 2)
                                              fileGroupHS = " and fileGroup:$selectedFileGroupFind ";
                                            else
                                              fileGroupHS = "";
                                            if (selectedFileGenericFind != 3)
                                              fileGenericHS = " and fileGeneric:$selectedFileGenericFind ";
                                            else
                                              fileGenericHS = "";
                                            if (selectedContentTypeFind != 4)
                                              contentTypeHS = " and contentType:$selectedContentTypeFind ";
                                            else
                                              contentTypeHS = "";
                                            find = nameHS + requiredHS + fileGroupHS + fileGenericHS + contentTypeHS;
                                            print("find:$find");
                                            await getListHoSo(0, find);
                                          },
                                          child: Row(
                                            children: [
                                              Icon(Icons.search, color: colorWhite),
                                              SizedBox(width: 5),
                                              Text('T??m ki???m', style: textButton),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(right: 40),
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
                                          onPressed: () async {
                                            await showDialog(
                                                context: context,
                                                builder: (BuildContext context) => ThemMoiHoSo(
                                                      hoSo: HoSo(),
                                                    ));
                                            await getListHoSo(0, "");
                                          },
                                          child: Row(
                                            children: [
                                              Icon(Icons.add, color: colorWhite),
                                              SizedBox(width: 5),
                                              Text('Th??m m???i', style: textButton),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(
                              color: backgroundPage,
                              padding: EdgeInsets.only(left: 25, right: 25),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 1,
                                // margin: marginTopBoxContainer,
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
                                      children: [
                                        Expanded(
                                            child: Column(
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  'H??? s??',
                                                  style: titleBox,
                                                ),
                                                Icon(
                                                  Icons.more_horiz,
                                                  color: Color(0xff9aa5ce),
                                                  size: 14,
                                                ),
                                              ],
                                            ),
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
                                                        child: DataTable(showCheckboxColumn: false, columnSpacing: 10, columns: [
                                                          DataColumn(label: Text('STT', style: titleTableData)),
                                                          DataColumn(label: Text('T??n h??? s??', style: titleTableData)),
                                                          DataColumn(label: Text('B???t bu???c', style: titleTableData)),
                                                          DataColumn(label: Text('Nh??m', style: titleTableData)),
                                                          DataColumn(label: Text('Lo???i h??? s??', style: titleTableData)),
                                                          DataColumn(label: Text('Lo???i d??? li???u', style: titleTableData)),
                                                          DataColumn(label: Text('H??nh ?????ng', style: titleTableData)),
                                                        ], rows: <DataRow>[
                                                          for (var i = 0; i < listHoSo.length; i++)
                                                            DataRow(
                                                              cells: [
                                                                DataCell(Text(" ${tableIndex + i}")),
                                                                DataCell(Text((listHoSo[i].name != null) ? listHoSo[i].name.toString() : "")),
                                                                DataCell(
                                                                  Text((listHoSo[i].requiredHoso != null)
                                                                      ? (listHoSo[i].requiredHoso == 1)
                                                                          ? "C??"
                                                                          : "Kh??ng"
                                                                      : ""),
                                                                ),
                                                                DataCell(
                                                                  Text((listHoSo[i].fileGroup != null)
                                                                      ? (listHoSo[i].fileGroup == 0)
                                                                          ? "Ch??nh"
                                                                          : "Kh??c"
                                                                      : ""),
                                                                ),
                                                                DataCell(
                                                                  Text((listHoSo[i].fileGeneric != null)
                                                                      ? (listHoSo[i].fileGeneric == 0)
                                                                          ? "C?? nh??n"
                                                                          : (listHoSo[i].fileGeneric == 1)
                                                                              ? "Xu???t c???nh"
                                                                              : (listHoSo[i].fileGeneric == 2)
                                                                                  ? "Nh??n s???"
                                                                                  : ""
                                                                      : ""),
                                                                ),
                                                                DataCell(
                                                                  Text((listHoSo[i].contentType != null)
                                                                      ? (listHoSo[i].contentType == 0)
                                                                          ? "File"
                                                                          : (listHoSo[i].contentType == 1)
                                                                              ? "V??n b???n"
                                                                              : (listHoSo[i].contentType == 2)
                                                                                  ? "Ng??y"
                                                                                  : (listHoSo[i].contentType == 3)
                                                                                      ? "???nh"
                                                                                      : ""
                                                                      : ""),
                                                                ),
                                                                DataCell(Row(
                                                                  children: [
                                                                    Consumer<NavigationModel>(
                                                                      builder: (context, navigationModel, child) => Container(
                                                                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                        child: InkWell(
                                                                            onTap: () async {
                                                                              await showDialog(
                                                                                  context: context,
                                                                                  builder: (BuildContext context) => SuaHoSo(
                                                                                        hoSo: listHoSo[i],
                                                                                      ));
                                                                            },
                                                                            child: Icon(Icons.edit_calendar, color: Color(0xff009C87))),
                                                                      ),
                                                                    ),
                                                                    Consumer<NavigationModel>(
                                                                      builder: (context, navigationModel, child) => Container(
                                                                          margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                          child: InkWell(
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
                                                                                                        child:
                                                                                                            Image.asset('assets/images/logoAAM.png'),
                                                                                                        margin: EdgeInsets.only(right: 10),
                                                                                                      ),
                                                                                                      Text(
                                                                                                        'X??c nh???n x??a ????? ngh??? tuy???n d???ng ',
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
                                                                                          //content
                                                                                          content: Container(
                                                                                            width: 400,
                                                                                            height: 150,
                                                                                            child: Column(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                                              children: [
                                                                                                //???????ng line
                                                                                                Container(
                                                                                                  margin: marginTopBottomHorizontalLine,
                                                                                                  child: Divider(
                                                                                                    thickness: 1,
                                                                                                    color: ColorHorizontalLine,
                                                                                                  ),
                                                                                                ),
                                                                                                Container(
                                                                                                  child: Text(
                                                                                                      'X??a h??? s?? : ${(listHoSo[i].name != null) ? listHoSo[i].name.toString() : ""}'),
                                                                                                ),
                                                                                                //???????ng line
                                                                                                Container(
                                                                                                  margin: marginTopBottomHorizontalLine,
                                                                                                  child: Divider(
                                                                                                    thickness: 1,
                                                                                                    color: ColorHorizontalLine,
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                          //actions
                                                                                          actions: [
                                                                                            ElevatedButton(
                                                                                              onPressed: () => Navigator.pop(context),
                                                                                              child: Text('H???y'),
                                                                                              style: ElevatedButton.styleFrom(
                                                                                                primary: colorOrange,
                                                                                                onPrimary: colorWhite,
                                                                                                elevation: 3,
                                                                                                // minimumSize: Size(100, 40),
                                                                                              ),
                                                                                            ),
                                                                                            ElevatedButton(
                                                                                              onPressed: () async {
                                                                                                var response = await httpDelete(
                                                                                                    "/api/tts-hoso/del/${listHoSo[i].id}", context);
                                                                                                if (response.containsKey("body")) {
                                                                                                  var response1 = jsonDecode(response["body"]);
                                                                                                  if (response1.keys.first == "1") {
                                                                                                    await getListHoSo(currentPage - 1, find);
                                                                                                    Navigator.pop(context);
                                                                                                    showToast(
                                                                                                      context: context,
                                                                                                      msg: "X??a h??? s?? th??nh c??ng",
                                                                                                      color: Color.fromARGB(136, 72, 238, 67),
                                                                                                      icon: const Icon(Icons.done),
                                                                                                    );
                                                                                                  } else {
                                                                                                    showToast(
                                                                                                      context: context,
                                                                                                      msg: "${response1[response1.keys.first]}",
                                                                                                      color: colorOrange,
                                                                                                      icon: const Icon(Icons.warning),
                                                                                                    );
                                                                                                  }
                                                                                                } else {
                                                                                                  showToast(
                                                                                                    context: context,
                                                                                                    msg: "C?? l???i",
                                                                                                    color: colorOrange,
                                                                                                    icon: const Icon(Icons.warning),
                                                                                                  );
                                                                                                }
                                                                                              },
                                                                                              child: Text(
                                                                                                'X??c nh???n',
                                                                                                style: TextStyle(),
                                                                                              ),
                                                                                              style: ElevatedButton.styleFrom(
                                                                                                primary: mainColorPage,
                                                                                                onPrimary: colorWhite,
                                                                                                elevation: 3,
                                                                                                // minimumSize: Size(100, 40),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ));
                                                                              },
                                                                              child: Icon(Icons.delete_outline, color: Colors.red))),
                                                                    ),
                                                                  ],
                                                                )),
                                                              ],
                                                            )
                                                        ]),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              margin: const EdgeInsets.only(right: 50),
                                              child: DynamicTablePagging(
                                                rowCount,
                                                currentPage,
                                                rowPerPage,
                                                pageChangeHandler: (page) {
                                                  setState(() {
                                                    getListHoSo(page - 1, find);
                                                    currentPage = page - 1;
                                                  });
                                                },
                                                rowPerPageChangeHandler: (rowPerPage) {
                                                  setState(() {
                                                    this.rowPerPage = rowPerPage!;
                                                    this.firstRow = page * currentPage;
                                                    getListHoSo(0, find);
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        )),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Center(child: CircularProgressIndicator()),
                  Footer(marginFooter: EdgeInsets.only(top: 5), paddingFooter: EdgeInsets.all(15)),
                  SizedBox(height: 20)
                ]),
              )),
    );
  }
}

class HoSo {
  int? id;
  String? name;
  int? requiredHoso;
  int? fileGroup;
  int? fileGeneric;
  int? contentType;
  String? description;

  HoSo({this.id, this.name, this.requiredHoso, this.fileGroup, this.contentType, this.fileGeneric, this.description});

  factory HoSo.fromJson(Map<dynamic, dynamic> json) {
    return HoSo(
      id: json['id'] ?? 0,
      name: json['name'],
      requiredHoso: json['required'],
      fileGroup: json['fileGroup'],
      fileGeneric: json['fileGeneric'],
      contentType: json['contentType'],
      description: json['description'] ?? "",
    );
  }
}
