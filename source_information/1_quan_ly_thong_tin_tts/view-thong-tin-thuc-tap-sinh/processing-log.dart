import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/forms/nhan_su/setting-data/userAAM.dart';

import '../../../../../api.dart';
import '../../../../../common/dynamic_table.dart';
import '../../../../../common/format_date.dart';
import '../../../../../common/style.dart';
import '../../../../forms/market_development/utils/funciton.dart';

// ignore: must_be_immutable
class ProcessingLog extends StatefulWidget {
  String? idTTS;
  ProcessingLog({Key? key, this.idTTS});
  @override
  State<ProcessingLog> createState() => ProcessingLogStates();
}

class ProcessingLogStates extends State<ProcessingLog> {
  var rowPerPage = 10;
  var rowCount = 0;
  int currentPageDef = 1;
  late Future<dynamic> futureListTrainee;
  var listTrainee = []; //Danh sách thực tập sinh

  Future<dynamic> pageChange(currentPage) async {
    var response = await httpGet("/api/tts-nhatky/get/page?size=$rowPerPage&page=${currentPage - 1}&filter=ttsId:${widget.idTTS}", context);
    // var body = jsonDecode(response['body'])['content'] ?? [];
    if (response.containsKey("body")) {
      setState(() {
        listTrainee = jsonDecode(response['body'])['content'] ?? [];
        rowCount = jsonDecode(response['body'])['totalElements'];
        // print(listTrainee);
      });
      for (var element in listTrainee) {
        element['userAAM'] = await getCreatUser(element['createdUser']);
      }
      return listTrainee;
    } else {
      throw Exception("failse");
    }
  }

  Future<UserAAM> getCreatUser(int idUser) async {
    UserAAM user = UserAAM();
    var response1 = await httpGet("/api/nguoidung/get/page?filter=id:$idUser", context);
    if (response1.containsKey("body")) {
      var kp = jsonDecode(response1['body'])['content'].first;
      user.userCode = kp['userCode'] ?? "";
      user.fullName = kp['fullName'] ?? "";
    }
    return user;
  }

  bool loading = false;
  @override
  void initState() {
    futureListTrainee = pageChange(1);
    setState(() {
      loading = true;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (loading == true)
        ? ListView(
            controller: ScrollController(),
            children: [
              FutureBuilder(
                future: futureListTrainee,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // int toolTipLength = MediaQuery.of(context).size.width < 1600 ? 33 : 60;
                    var tableIndex = (currentPageDef - 1) * rowPerPage + 1;
                    return Container(
                      padding: paddingBoxContainer,
                      // margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 30),
                      // decoration: BoxDecoration(
                      //   color: colorWhite,
                      //   borderRadius: borderRadiusContainer,
                      //   boxShadow: [boxShadowContainer],
                      //   border: borderAllContainerBox,
                      // ),
                      margin: marginTopLeftRightContainer,
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
                                'Nhật ký xử lý',
                                style: titleBox,
                              ),
                              Text(
                                'Tổng số lượng xử lý: $rowCount',
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
                                        columnSpacing: 5,
                                        horizontalMargin: 10,
                                        dataRowHeight: 60,
                                        columns: [
                                          DataColumn(label: Text('STT', style: titleTableData)),
                                          DataColumn(
                                              label: Container(
                                                  child: Expanded(
                                                      child: Text(
                                            'Trạng thái trước xử lý',
                                            style: titleTableData,
                                            maxLines: 2,
                                            softWrap: true,
                                            // overflow: TextOverflow.ellipsis,
                                          )))),
                                          DataColumn(
                                              label: Container(
                                                  child: Expanded(
                                                      child: Text(
                                            'Trạng thái sau xử lý',
                                            style: titleTableData,
                                            maxLines: 2,
                                            softWrap: true,
                                            // overflow: TextOverflow.ellipsis,
                                          )))),
                                          DataColumn(
                                              label: Container(
                                                  child: Expanded(
                                                      child: Text(
                                            'Nội dung xử lý',
                                            style: titleTableData,
                                            maxLines: 2,
                                            softWrap: true,
                                            // overflow: TextOverflow.ellipsis,
                                          )))),
                                          DataColumn(
                                              label: Container(
                                                  child: Expanded(
                                                      child: Text(
                                            'Người xử lý',
                                            style: titleTableData,
                                            maxLines: 2,
                                            softWrap: true,
                                            // overflow: TextOverflow.ellipsis,
                                          )))),
                                          DataColumn(
                                              label: Container(
                                                  child: Expanded(
                                                      child: Text(
                                            'Ngày giờ xử lý',
                                            style: titleTableData,
                                            maxLines: 2,
                                            softWrap: true,
                                            // overflow: TextOverflow.ellipsis,
                                          )))),
                                        ],
                                        rows: <DataRow>[
                                          for (int i = 0; i < listTrainee.length; i++)
                                            DataRow(
                                              cells: <DataCell>[
                                                DataCell(SelectableText("${tableIndex++}")),
                                                DataCell(
                                                  Container(
                                                    width: MediaQuery.of(context).size.width * 0.07,
                                                    child: SelectableText(
                                                      listTrainee[i]["trangthai_truoc"]["statusName"] ?? "",
                                                      style: bangDuLieu,
                                                      // maxLines: 2,
                                                      // softWrap: true,
                                                      // overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                    width: MediaQuery.of(context).size.width * 0.09,
                                                    child: SelectableText(
                                                      listTrainee[i]["trangthai_sau"]["statusName"] ?? "",
                                                      style: bangDuLieu,
                                                      // maxLines: 2,
                                                      // softWrap: true,
                                                      // overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                    width: MediaQuery.of(context).size.width * 0.09,
                                                    child: SelectableText(
                                                      listTrainee[i]["content"].toString(),
                                                      style: bangDuLieu,
                                                      // maxLines: 2,
                                                      // softWrap: true,
                                                      // overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                    width: MediaQuery.of(context).size.width * 0.09,
                                                    child: SelectableText(
                                                      "${listTrainee[i]["userAAM"].userCode} - ${listTrainee[i]["userAAM"].fullName}",
                                                      style: bangDuLieu,
                                                      // maxLines: 2,
                                                      // softWrap: true,
                                                      // overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ),
                                                DataCell(
                                                  Container(
                                                    //  Text(FormatDate.formatDateddMMyy(DateTime.parse(listTTS[i]["createdDate"] ?? ""))),
                                                    // width: MediaQuery.of(context).size.width * 0.1,
                                                    child: listTrainee[i]["createdDate"] != null
                                                        ? SelectableText.rich(
                                                            TextSpan(
                                                              text: getHour(listTrainee[i]["createdDate"]),
                                                              style: TextStyle(
                                                                color: Color(0xffFFA726),
                                                                fontSize: 14,
                                                                // fontWeight: FontWeight.bold,
                                                              ),
                                                              children: <TextSpan>[
                                                                TextSpan(
                                                                  text: " / ",
                                                                  style: TextStyle(
                                                                    color: Colors.black45,
                                                                    fontSize: 14,
                                                                    // fontWeight: w400,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text: getDateViewDdMmYyyy(listTrainee[i]["createdDate"]),
                                                                  style: TextStyle(
                                                                    color: Color(0xff459987),
                                                                    fontSize: 14,
                                                                    // fontWeight: w400,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                        : Text(""),
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                DynamicTablePagging(rowCount, currentPageDef, rowPerPage, pageChangeHandler: (currentPage) {
                                  setState(() {
                                    futureListTrainee = pageChange(currentPage);
                                    currentPageDef = currentPage;
                                  });
                                }, rowPerPageChangeHandler: (rowPerPageChange) {
                                  currentPageDef = 1;

                                  rowPerPage = rowPerPageChange;
                                  futureListTrainee = pageChange(currentPageDef);
                                  setState(() {});
                                })
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Text('${snapshot.error}');
                  }
                  return SizedBox(
                      // child: const Center(child: CircularProgressIndicator()),
                      );
                },
              ),
            ],
          )
        : Center(child: CircularProgressIndicator());
  }
}
