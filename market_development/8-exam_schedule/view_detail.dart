import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/toast.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import 'modal_ket_thuc_thi_tuyen.dart';
import 'modal_xac_nhan_ket_qua.dart';

class ViewLTT extends StatefulWidget {
  final String idLTT;
  const ViewLTT({Key? key, required this.idLTT}) : super(key: key);

  @override
  State<ViewLTT> createState() => _ViewLTTState();
}

enum doTruot { Do, Truot, DuBi, BoThi, KhongChon }

class _ViewLTTState extends State<ViewLTT> {
  var resultLTTChiTiet = {};
  var listTTS;
  var firstRow = 0;
  late Future futureLTTChiTiet;
  late Future futureListLTT;
  bool isChecked = false;
  var orderIdLTT;
  var rowPerPage = 50;
  var rowCount = 0;
  int currentPageDef = 1;
  List<doTruot> _character = [];

  List<doTruot> _characterUpdate = [];
  getLTTChiTiet() async {
    return resultLTTChiTiet;
  }

  void initState() {
    super.initState();

    futureListLTT = getListLTT(1);
  }

  Future<List<dynamic>> getListLichSuThiTuyenByExamTime(List<dynamic> listLichSuThiTuyen) async {
    List<dynamic> listLichSuThiTuyenResultFinal = [];
    List<dynamic> listLichSuThiTuyenResult = [];
    Map<int, dynamic> mapLichSuThiTuyen = {};

    if (listLichSuThiTuyen.isNotEmpty) {
      for (int i = 0; i < listLichSuThiTuyen.length; i++) {
        if (!mapLichSuThiTuyen.containsKey(listLichSuThiTuyen[i]['ttsId'])) {
          mapLichSuThiTuyen.putIfAbsent(listLichSuThiTuyen[i]['ttsId'], () => listLichSuThiTuyen[i]);
        } else {
          if (mapLichSuThiTuyen[listLichSuThiTuyen[i]['ttsId']]['examTimes'] < listLichSuThiTuyen[i]['examTimes']! && listLichSuThiTuyen[i]['examTimes'] > 0) {
            mapLichSuThiTuyen[listLichSuThiTuyen[i]['ttsId']] = listLichSuThiTuyen[i];
          }
        }
      }
      if (mapLichSuThiTuyen.isNotEmpty) {
        listLichSuThiTuyenResult.addAll(mapLichSuThiTuyen.values);
      }
      if (listLichSuThiTuyenResult.isNotEmpty) {
        for (int i = 0; i < listLichSuThiTuyenResult.length; i++) {
          if (listLichSuThiTuyenResult[i]["examResult"] == 0 &&
              (listLichSuThiTuyenResult[i]["thuctapsinh"]["ttsStatusId"] == 14 || listLichSuThiTuyenResult[i]["thuctapsinh"]["ttsStatusId"] == 13)) {
            await httpDelete("/api/tts-lichsu-thituyen/del/${listLichSuThiTuyenResult[i]['id']}", context);
          } else {
            listLichSuThiTuyenResultFinal.add(listLichSuThiTuyenResult[i]);
          }
        }
      }
    }

    return listLichSuThiTuyenResultFinal;
  }

  Future getListLTT(currentPage) async {
    var response = await httpGet("/api/lichthituyen/get/${widget.idLTT}", context);

    if (response.containsKey("body")) {
      resultLTTChiTiet = jsonDecode(response["body"]);
      orderIdLTT = resultLTTChiTiet["orderId"];
    }

    // var response1 = await httpGet(
    //     "/api/tts-lichsu-thituyen/get/page?page=$page&size=$rowPerPage&sort=id&filter=orderId:$orderIdLTT AND qcApproval:1 AND ptttApproval:1 AND donhang.closeNominateUser is not null",
    //     context);
    var response1;
    if (resultLTTChiTiet['status'] == 1) {
      //Đã kết thúc thi tuyển
      response1 = await httpGet(
          "/api/tts-lichsu-thituyen/get/page?page=${currentPage - 1}&size=$rowPerPage&sort=id&filter=orderId:$orderIdLTT  AND donhang.closeNominateUser is not null  AND thuctapsinh.isTts:1",
          context);
    } else {
      response1 = await httpGet(
          "/api/tts-lichsu-thituyen/get/page?page=${currentPage - 1}&size=$rowPerPage&sort=id&filter=orderId:$orderIdLTT  AND donhang.closeNominateUser is not null  AND thuctapsinh.isTts:1",
          context);
      // response1 = await httpGet(
      //     "/api/tts-lichsu-thituyen/get/page?page=${currentPage - 1}&size=$rowPerPage&sort=id&filter=orderId:$orderIdLTT  AND donhang.closeNominateUser is not null AND (thuctapsinh.stopProcessing:0 or thuctapsinh.stopProcessing is null ) AND thuctapsinh.ttsStatusId:6 ",
      //     context);
    }

    print("/api/tts-lichsu-thituyen/get/page?page=${currentPage - 1}&size=$rowPerPage&sort=id&filter=orderId:$orderIdLTT  AND donhang.closeNominateUser is not null ");

    if (response1.containsKey("body")) {
      listTTS = jsonDecode(response1["body"]);
      listTTS['content'] = await getListLichSuThiTuyenByExamTime(listTTS['content']);
      setState(() {
        rowCount = listTTS["totalElements"];

        if (resultLTTChiTiet['status'] == 1) {
          for (int i = 0; i < listTTS['content'].length; i++) {
            if (listTTS['content'][i]['examResult'] == 1) {
              _character.add(doTruot.Do);
            } else if (listTTS['content'][i]['examResult'] == 2) {
              _character.add(doTruot.Truot);
            } else if (listTTS['content'][i]['examResult'] == 3) {
              _character.add(doTruot.DuBi);
            } else if (listTTS['content'][i]['examResult'] == 4) {
              _character.add(doTruot.BoThi);
            } else {
              _character.add(doTruot.KhongChon);
            }
          }
        } else {
          for (int i = 0; i < listTTS['content'].length; i++) {
            if (listTTS['content'][i]['examResult'] == 1) {
              _character.add(doTruot.Do);
            } else if (listTTS['content'][i]['examResult'] == 2) {
              _character.add(doTruot.Truot);
            } else if (listTTS['content'][i]['examResult'] == 3) {
              _character.add(doTruot.DuBi);
            } else if (listTTS['content'][i]['examResult'] == 4) {
              _character.add(doTruot.BoThi);
            } else {
              _character.add(doTruot.KhongChon);
            }
          }
          _characterUpdate.addAll(_character);
          //_character = List.generate(listTTS["content"].length, (index) => doTruot.KhongChon);
        }
      });
    }
    return 0;
  }

  String getMess(stopProcessing, fullName) {
    if (resultLTTChiTiet["status"] == 1) {
      return "Không cập nhập khi kết thúc thi tuyển";
    }
    if (stopProcessing == 1) {
      return "TTS ${fullName} đang tạm dừng xử lý";
    }
    return "";
  }

  bool isDisable(stopProcessing) {
    if (resultLTTChiTiet["status"] == 1) {
      return false;
    } else if (stopProcessing == 1) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: FutureBuilder<dynamic>(
      future: userRule('/xem-chi-tiet-lich-thi-tuyen', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Consumer<NavigationModel>(
            builder: (context, navigationModel, child) => ListView(
              controller: ScrollController(),
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 1,
                  decoration: BoxDecoration(
                    color: colorWhite,
                    boxShadow: [boxShadowContainer],
                    border: Border(
                      bottom: borderTitledPage,
                    ),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Home',
                                style: TextStyle(color: Color(0xff009C87)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 5, right: 5),
                                child: Text(
                                  '/',
                                  style: TextStyle(
                                    color: Color(0xffC8C9CA),
                                  ),
                                ),
                              ),
                              Text('Phát triển thị trường / Lịch thi tuyển', style: TextStyle(color: Color(0xff009C87))),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text('View Lịch Thi Tuyển', style: titlePage),
                        ],
                      ),
                      TextButton.icon(
                        icon: Icon(Icons.arrow_back_ios, size: 14, color: Colors.white),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 15.0,
                            horizontal: 15.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          backgroundColor: colorOrange,
                          primary: Theme.of(context).iconTheme.color,
                          textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        label: Text('Trở về', style: textButton),
                      ),
                    ],
                  ),
                ),
                FutureBuilder(
                  future: futureListLTT,
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
                                  'Chi tiết',
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
                              child: Divider(
                                thickness: 1,
                                color: ColorHorizontalLine,
                              ),
                            ),
                            //------------kết thúc đường line-------
                            Container(
                              margin: EdgeInsets.only(top: 30),
                              child: Column(
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      //Start Row 1
                                      Expanded(
                                          child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: SelectableText("Nghiệp đoàn:", style: titleWidgetBox),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: SelectableText(
                                              resultLTTChiTiet["donhang"]["nghiepdoan"]["orgName"] != null ? resultLTTChiTiet["donhang"]["nghiepdoan"]["orgName"] : " ",
                                              style: TextStyle(fontSize: 16),
                                            ),
                                          ),
                                        ],
                                      )),
                                      SizedBox(
                                        width: 30,
                                      ),
                                      Expanded(
                                          child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: SelectableText("Đơn hàng:", style: titleWidgetBox),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              child: SelectableText(
                                                resultLTTChiTiet["donhang"]["orderName"] != null ? resultLTTChiTiet["donhang"]["orderName"] : " ",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: Text("Xí nghiệp:", style: titleWidgetBox),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              child: SelectableText(
                                                resultLTTChiTiet["donhang"]["xinghiep"]["companyName"] != null ? resultLTTChiTiet["donhang"]["xinghiep"]["companyName"] : " ",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                      SizedBox(
                                        width: 30,
                                      ),
                                      Expanded(
                                          child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: SelectableText("Công ty :", style: titleWidgetBox),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              child: SelectableText(
                                                resultLTTChiTiet["donhang"]["nghiepdoan"]["phongban"] != null
                                                    ? resultLTTChiTiet["donhang"]["nghiepdoan"]["phongban"]['departName'] != null
                                                        ? resultLTTChiTiet["donhang"]["nghiepdoan"]["phongban"]['departName']
                                                        : ''
                                                    : " ",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: SelectableText("Địa điểm:", style: titleWidgetBox),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              child: SelectableText(
                                                resultLTTChiTiet["address"] != null ? resultLTTChiTiet["address"] : " ",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                      SizedBox(
                                        width: 30,
                                      ),
                                      Expanded(child: Container()),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                          child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: SelectableText("Thời gian thi tuyển:", style: titleWidgetBox),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              child: SelectableText(
                                                getDateViewDayAndHour(resultLTTChiTiet["examDate"]),
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                      SizedBox(
                                        width: 30,
                                      ),
                                      Expanded(
                                          child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 2,
                                            child: SelectableText("Hình thức thi tuyển:", style: titleWidgetBox),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                              child: SelectableText(
                                                resultLTTChiTiet["examMethod"] != null
                                                    ? (resultLTTChiTiet["examMethod"].toString() == "0" ? "Thi tuyển trực tiếp" : "Thi tuyển online")
                                                    : "",
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: SelectableText("Thông tin đoàn phỏng vấn:", style: titleWidgetBox),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                child: SelectableText(
                                                  resultLTTChiTiet["examGroup"] != null ? resultLTTChiTiet["examGroup"] : " ",
                                                  style: TextStyle(fontSize: 16),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 30,
                                      ),
                                      Expanded(
                                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.start, children: [
                                          Expanded(
                                            flex: 2,
                                            child: SelectableText("Nội dung thi tuyển:", style: titleWidgetBox),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Container(
                                                child: SelectableText(
                                              resultLTTChiTiet["content"] != null ? resultLTTChiTiet["content"] : " ",
                                              style: TextStyle(fontSize: 16),
                                            )),
                                          )
                                        ]),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            //====
                          ],
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
                getRule(listRule.data, Role.Sua, context)
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(0, 40, 22, 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              margin: EdgeInsets.only(right: 10),
                              child: Tooltip(
                                message: (resultLTTChiTiet["status"] != 1 && _character.length > 0) ? "" : "",
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20.0,
                                      horizontal: 10.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    backgroundColor: (resultLTTChiTiet["status"] != 1 && _character.length > 0) ? Color.fromRGBO(245, 117, 29, 1) : Colors.grey,
                                    primary: Theme.of(context).iconTheme.color,
                                    textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                  ),
                                  onPressed: (resultLTTChiTiet["status"] != 1 && _character.length > 0)
                                      ? () {
                                          print(_character);
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) => ShowNotification(
                                              listDoTruot: _character,
                                              listDoTruotUpdate: _characterUpdate,
                                              listTTSLSTT: listTTS["content"],
                                              idLtt: int.parse(widget.idLTT),
                                              examDate: resultLTTChiTiet["examDate"],
                                            ),
                                          );
                                        }
                                      : null,
                                  child: Row(
                                    children: [
                                      Text('Cập nhật kết quả', style: textButton),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              child: Tooltip(
                                message: resultLTTChiTiet["status"] != 1 ? "Không được phép kết thúc thi tuyển" : "",
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20.0,
                                      horizontal: 10.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    backgroundColor: (resultLTTChiTiet["status"] != 1 && _character.length > 0) ? Color.fromRGBO(245, 117, 29, 1) : Colors.grey,
                                    primary: Theme.of(context).iconTheme.color,
                                    textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                  ),
                                  onPressed: (resultLTTChiTiet["status"] != 1 && _character.length > 0)
                                      ? () async {
                                          await showDialog(
                                            context: context,
                                            builder: (BuildContext context) => ModalKetThucThiTuyen(
                                              listDoTruot: _character,
                                              listTTT: listTTS["content"],
                                              idLtt: int.parse(widget.idLTT),
                                              resultLTTChiTiet: resultLTTChiTiet,
                                              listDoTruotUpdate: _characterUpdate,
                                              examDate: resultLTTChiTiet["examDate"],
                                            ),
                                          );
                                        }
                                      : null,
                                  child: Row(
                                    children: [
                                      Text('Kết thúc thi tuyển', style: textButton),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(),
                FutureBuilder(
                  future: futureListLTT,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      var tableIndex = (currentPageDef - 1) * rowPerPage + 1;

                      return Column(
                        children: [
                          Container(
                            padding: paddingBoxContainer,
                            margin: marginBoxFormTab1,
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
                                  children: [
                                    Expanded(child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                                      return Center(
                                          child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                          child: DataTable(
                                            showCheckboxColumn: true,
                                            columns: [
                                              DataColumn(label: Text('STT', style: titleTableData)),
                                              DataColumn(label: Text('Họ và tên', style: titleTableData)),
                                              DataColumn(label: SizedBox(width: 100, child: Text('Số điện thoại', style: titleTableData))),
                                              DataColumn(label: Text('Đỗ', style: titleTableData)),
                                              DataColumn(label: Text('Trượt', style: titleTableData)),
                                              DataColumn(label: Text('Dự bị', style: titleTableData)),
                                              DataColumn(label: Text('Bỏ thi', style: titleTableData)),
                                            ],
                                            rows: <DataRow>[
                                              if (listTTS["content"].length != 0)
                                                for (int i = 0; i < listTTS["content"].length; i++)
                                                  DataRow(cells: <DataCell>[
                                                    DataCell(Text("${tableIndex + i}")),
                                                    DataCell(
                                                      Tooltip(
                                                          message:
                                                              getMess(listTTS["content"][i]["thuctapsinh"]["stopProcessing"], listTTS["content"][i]["thuctapsinh"]['fullName']),
                                                          child: SelectableText(
                                                              listTTS["content"][i]["thuctapsinh"]["fullName"].toString() +
                                                                  " \n(" +
                                                                  listTTS["content"][i]["thuctapsinh"]["userCode"].toString() +
                                                                  ")"
                                                                      "\n" +
                                                                  getDateView(listTTS["content"][i]["thuctapsinh"]["birthDate"].toString()) +
                                                                  "",
                                                              style: bangDuLieu)),
                                                    ),
                                                    DataCell(
                                                      Container(
                                                        child: Tooltip(
                                                            message:
                                                                getMess(listTTS["content"][i]["thuctapsinh"]["stopProcessing"], listTTS["content"][i]["thuctapsinh"]['fullName']),
                                                            child: SelectableText(listTTS["content"][i]["thuctapsinh"]["phone"].toString(), style: bangDuLieu)),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      ListTile(
                                                        leading: Tooltip(
                                                          message:
                                                              getMess(listTTS["content"][i]["thuctapsinh"]["stopProcessing"], listTTS["content"][i]["thuctapsinh"]['fullName']),
                                                          child: Radio<doTruot>(
                                                            value: doTruot.Do,
                                                            groupValue: _character[i],
                                                            onChanged: isDisable(listTTS["content"][i]["thuctapsinh"]["stopProcessing"])
                                                                ? (doTruot? value) {
                                                                    setState(() {
                                                                      _character[i] = value!;
                                                                      print(_character);
                                                                    });
                                                                  }
                                                                : null,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      ListTile(
                                                        leading: Tooltip(
                                                          message:
                                                              getMess(listTTS["content"][i]["thuctapsinh"]["stopProcessing"], listTTS["content"][i]["thuctapsinh"]['fullName']),
                                                          child: Radio<doTruot>(
                                                            value: doTruot.Truot,
                                                            groupValue: _character[i],
                                                            onChanged: isDisable(listTTS["content"][i]["thuctapsinh"]["stopProcessing"])
                                                                ? (doTruot? value) {
                                                                    setState(() {
                                                                      _character[i] = value!;
                                                                      print(_character);
                                                                    });
                                                                  }
                                                                : null,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      ListTile(
                                                        leading: Tooltip(
                                                          message:
                                                              getMess(listTTS["content"][i]["thuctapsinh"]["stopProcessing"], listTTS["content"][i]["thuctapsinh"]['fullName']),
                                                          child: Radio<doTruot>(
                                                            value: doTruot.DuBi,
                                                            groupValue: _character[i],
                                                            onChanged: isDisable(listTTS["content"][i]["thuctapsinh"]["stopProcessing"])
                                                                ? (doTruot? value) {
                                                                    setState(() {
                                                                      _character[i] = value!;
                                                                      print(_character);
                                                                    });
                                                                  }
                                                                : null,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    DataCell(
                                                      ListTile(
                                                        leading: Tooltip(
                                                          message:
                                                              getMess(listTTS["content"][i]["thuctapsinh"]["stopProcessing"], listTTS["content"][i]["thuctapsinh"]['fullName']),
                                                          child: Radio<doTruot>(
                                                            value: doTruot.BoThi,
                                                            groupValue: _character[i],
                                                            onChanged: isDisable(listTTS["content"][i]["thuctapsinh"]["stopProcessing"])
                                                                ? (doTruot? value) {
                                                                    setState(() {
                                                                      _character[i] = value!;
                                                                      print(_character);
                                                                    });
                                                                  }
                                                                : null,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ])
                                            ],
                                          ),
                                        ),
                                      ));
                                    })),
                                  ],
                                ),
                                if (rowCount != 0)
                                  DynamicTablePagging(rowCount, currentPageDef, rowPerPage, pageChangeHandler: (currentPage) {
                                    setState(() {
                                      futureListLTT = getListLTT(currentPage);
                                      currentPageDef = currentPage;
                                      print(currentPageDef);
                                    });
                                  }, rowPerPageChangeHandler: (rowPerPageChange) {
                                    rowPerPage = rowPerPageChange;
                                    futureListLTT = getListLTT(currentPageDef);
                                    setState(() {});
                                  })
                                else
                                  Center(
                                      child: Text("Không có bản ghi nào!",
                                          style: TextStyle(
                                            fontSize: 17,
                                          ))),
                              ],
                            ),
                          ),
                          Footer()
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }
                    // By default, show a loading spinner.
                    return const Center(child: CircularProgressIndicator());
                  },
                ),
              ],
            ),
          );
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    ));
  }
}
