import 'dart:convert';
import 'package:flutter/material.dart';

import '../../../../../api.dart';
import '../../../../../common/dynamic_table.dart';
import '../../../../../common/format_date.dart';
import '../../../../../common/style.dart';
import '../../../../forms/market_development/utils/funciton.dart';

// ignore: must_be_immutable
class ViewTCVLS extends StatefulWidget {
  String? idTTS;
  ViewTCVLS({Key? key, this.idTTS});
  @override
  State<ViewTCVLS> createState() => ViewTCVLSStates();
}

class ViewTCVLSStates extends State<ViewTCVLS> {
  //Lịch sử thi tuyển
  var rowPerPageLSTT = 10;
  var rowCountLSTT = 0;
  int currentPageDefLSTT = 1;
  late Future<dynamic> futureListLSTT;
  var lisDatatLSTT = []; //Danh sách thực tập sinh

  Future<dynamic> getLSTT(currentPage) async {
    var response =
        await httpGet("/api/tts-lichsu-thituyen/get/page?size=$rowPerPageLSTT&page=${currentPage - 1}&filter=ttsId:${widget.idTTS}", context);
    // var body = jsonDecode(response['body'])['content'] ?? [];
    if (response.containsKey("body")) {
      setState(() {
        // content = body['content'];
        lisDatatLSTT = jsonDecode(response['body'])['content'] ?? [];
        rowCountLSTT = jsonDecode(response['body'])['totalElements'];
        // print(listTrainee);
      });
      return lisDatatLSTT;
    } else {
      throw Exception("failse");
    }
  }

  //Tiến cử đơn hàng
  var rowPerPage = 10;
  var rowCount = 0;
  int currentPageDef = 1;
  late Future<dynamic> futureListTrainee;
  var listTrainee = []; //Danh sách thực tập sinh

  Future<dynamic> pageChange(currentPage) async {
    var response = await httpGet("/api/donhang-tts-tiencu/get/page?size=$rowPerPage&page=${currentPage - 1}&filter=ttsId:${widget.idTTS}", context);
    // var body = jsonDecode(response['body'])['content'] ?? [];
    if (response.containsKey("body")) {
      setState(() {
        // content = body['content'];
        listTrainee = jsonDecode(response['body'])['content'] ?? [];
        rowCount = jsonDecode(response['body'])['totalElements'];
        // print(listTrainee);
      });
      return listTrainee;
    } else {
      throw Exception("failse");
    }
  }

  String examResult(examResult) {
    late String option = "";
    switch (examResult) {
      case 0:
        option = "Chờ thi";
        break;
      case 1:
        option = "Đỗ";
        break;
      case 2:
        option = "Trượt";
        break;
      case 3:
        option = "Dự bị";
        break;
      case 4:
        option = "Bỏ thi";
        break;
      default:
        option = "Chưa có kết quả";
    }
    return option;
  }

  int pagination(int currentPageDefLSTT, int rowPerPageLSTT, int idex) {
    int tableIndex = (currentPageDefLSTT - 1) * rowPerPageLSTT + idex;
    return tableIndex + 1;
  }

  var tableIndex;
  callApi() async {
    await getLSTT(1);
    await pageChange(1);
    setState(() {
      loading = true;
    });
  }

  bool loading = false;
  @override
  void initState() {
    callApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (loading == true)
        ? ListView(
            controller: ScrollController(),
            children: [
              Container(
                padding: paddingBoxContainer,
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
                          'Lịch sử thi tuyển',
                          style: titleBox,
                        ),
                        Text(
                          'Tổng số lần thi tuyển: $rowCountLSTT',
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
                                    DataColumn(
                                        label: Container(
                                            child: Expanded(
                                                child: Text(
                                      'Ngày thi tuyển',
                                      style: titleTableData,
                                      maxLines: 2,
                                      softWrap: true,
                                      // overflow: TextOverflow.ellipsis,
                                    )))),
                                    DataColumn(
                                        label: Container(
                                            child: Expanded(
                                                child: Text(
                                      'Mã đơn hàng',
                                      style: titleTableData,
                                      maxLines: 2,
                                      softWrap: true,
                                      // overflow: TextOverflow.ellipsis,
                                    )))),
                                    DataColumn(
                                        label: Container(
                                            child: Expanded(
                                                child: Text(
                                      'Tên đơn hàng',
                                      style: titleTableData,
                                      maxLines: 2,
                                      softWrap: true,
                                      // overflow: TextOverflow.ellipsis,
                                    )))),
                                    DataColumn(
                                        label: Container(
                                            child: Expanded(
                                                child: Text(
                                      'Kết quả',
                                      style: titleTableData,
                                      maxLines: 2,
                                      softWrap: true,
                                      // overflow: TextOverflow.ellipsis,
                                    )))),
                                  ],
                                  rows: <DataRow>[
                                    for (int i = 0; i < lisDatatLSTT.length; i++)
                                      DataRow(
                                        cells: <DataCell>[
                                          DataCell(SelectableText("${pagination(currentPageDefLSTT, rowPerPageLSTT, i)}")),
                                          DataCell(
                                            Container(
                                              //  Text(FormatDate.formatDateddMMyy(DateTime.parse(listTTS[i]["createdDate"] ?? ""))),
                                              // width: MediaQuery.of(context).size.width * 0.1,
                                              child: lisDatatLSTT[i]["examDate"] != null
                                                  ? SelectableText.rich(
                                                      TextSpan(
                                                        text: getHour(lisDatatLSTT[i]["examDate"]),
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
                                                            text: getDateViewDdMmYyyy(lisDatatLSTT[i]["examDate"]),
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
                                          // DataCell(
                                          //   Container(
                                          //     //  Text(FormatDate.formatDateddMMyy(DateTime.parse(listTTS[i]["createdDate"] ?? ""))),
                                          //     // width: MediaQuery.of(context).size.width * 0.1,
                                          //     child: lisDatatLSTT[i]["examDate"] != null
                                          //         ? SelectableText.rich(
                                          //             TextSpan(
                                          //               text: FormatDate.formatTime(DateTime.parse(lisDatatLSTT[i]["examDate"])),
                                          //               style: TextStyle(
                                          //                 color: Color(0xffFFA726),
                                          //                 fontSize: 14,
                                          //                 // fontWeight: FontWeight.bold,
                                          //               ),
                                          //               children: <TextSpan>[
                                          //                 TextSpan(
                                          //                   text: " / ",
                                          //                   style: TextStyle(
                                          //                     color: Colors.black45,
                                          //                     fontSize: 14,
                                          //                     // fontWeight: w400,
                                          //                   ),
                                          //                 ),
                                          //                 TextSpan(
                                          //                   text: FormatDate.formatDateddMMyy(DateTime.parse(lisDatatLSTT[i]["examDate"])),
                                          //                   style: TextStyle(
                                          //                     color: Color(0xff459987),
                                          //                     fontSize: 14,
                                          //                     // fontWeight: w400,
                                          //                   ),
                                          //                 ),
                                          //               ],
                                          //             ),
                                          //           )
                                          //         : Text(""),
                                          //   ),
                                          // ),
                                          // DataCell(
                                          //   Container(
                                          //     //  Text(FormatDate.formatDateddMMyy(DateTime.parse(listTTS[i]["createdDate"] ?? ""))),
                                          //     // width: MediaQuery.of(context).size.width * 0.1,
                                          //     child: lisDatatLSTT[i]["examDate"] != null
                                          //         ? Row(
                                          //             children: [
                                          //               SelectableText(
                                          //                 FormatDate.formatTime(DateTime.parse(lisDatatLSTT[i]["examDate"])),
                                          //                 style: TextStyle(
                                          //                   color: Color(0xffFFA726),
                                          //                   fontSize: 16,
                                          //                   fontWeight: FontWeight.bold,
                                          //                 ),
                                          //               ),
                                          //               SelectableText(
                                          //                 "  Ngày ${FormatDate.formatDateddMMyy(DateTime.parse(lisDatatLSTT[i]["examDate"]))}",
                                          //                 style: TextStyle(
                                          //                   color: Color(0xff459987),
                                          //                   fontSize: 16,
                                          //                   // fontWeight: w400,
                                          //                 ),
                                          //               ),
                                          //             ],
                                          //           )
                                          //         : Text(""),
                                          //   ),
                                          // ),
                                          DataCell(
                                            Container(
                                              // width: MediaQuery.of(context).size.width * 0.07,
                                              child: SelectableText(
                                                lisDatatLSTT[i]["donhang"]["orderCode"] ?? "",
                                                style: bangDuLieu,
                                                // maxLines: 2,
                                                // softWrap: true,
                                                // overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Container(
                                              // width: MediaQuery.of(context).size.width * 0.07,
                                              child: SelectableText(
                                                lisDatatLSTT[i]["donhang"]["orderName"] ?? "",
                                                style: bangDuLieu,
                                                // maxLines: 2,
                                                // softWrap: true,
                                                // overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Container(
                                              // width: MediaQuery.of(context).size.width * 0.07,
                                              child: SelectableText(
                                                examResult(lisDatatLSTT[i]["examResult"] ?? ""),
                                                style: bangDuLieu,
                                                // maxLines: 2,
                                                // softWrap: true,
                                                // overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          DynamicTablePagging(rowCountLSTT, currentPageDefLSTT, rowPerPageLSTT, pageChangeHandler: (currentPage) {
                            setState(() {
                              futureListLSTT = getLSTT(currentPage);
                              currentPageDefLSTT = currentPage;
                            });
                          }, rowPerPageChangeHandler: (rowPerPageChange) {
                            currentPageDefLSTT = 1;

                            rowPerPageLSTT = rowPerPageChange;
                            futureListLSTT = getLSTT(currentPageDefLSTT);
                            setState(() {});
                          })
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // FutureBuilder(
              //   future: futureListLSTT,
              //   builder: (context, snapshot) {
              //     if (snapshot.hasData) {
              //       // int toolTipLength = MediaQuery.of(context).size.width < 1600 ? 33 : 60;
              //       var tableIndex = (currentPageDefLSTT - 1) * rowPerPageLSTT + 1;
              //       return Container(
              //         padding: paddingBoxContainer,
              //         // margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 30),
              //         // decoration: BoxDecoration(
              //         //   color: colorWhite,
              //         //   borderRadius: borderRadiusContainer,
              //         //   boxShadow: [boxShadowContainer],
              //         //   border: borderAllContainerBox,
              //         // ),
              //         margin: marginTopLeftRightContainer,
              //         decoration: BoxDecoration(
              //           color: colorWhite,
              //           borderRadius: borderRadiusContainer,
              //           boxShadow: [boxShadowContainer],
              //           border: borderAllContainerBox,
              //         ),
              //         child: Column(
              //           children: [
              //             Row(
              //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //               children: [
              //                 Text(
              //                   'Lịch sử thi tuyển',
              //                   style: titleBox,
              //                 ),
              //                 Text(
              //                   'Tổng số lần thi tuyển: $rowCountLSTT',
              //                   style: titleBox,
              //                 ),
              //               ],
              //             ),
              //             //Đường line
              //             Container(
              //               margin: marginTopBottomHorizontalLine,
              //               child: Divider(
              //                 thickness: 1,
              //                 color: ColorHorizontalLine,
              //               ),
              //             ),
              //             Container(
              //               child: Column(
              //                 children: [
              //                   Row(
              //                     children: [
              //                       Expanded(
              //                         child: DataTable(
              //                           showCheckboxColumn: false,
              //                           columnSpacing: 20,
              //                           horizontalMargin: 10,
              //                           dataRowHeight: 60,
              //                           columns: [
              //                             DataColumn(label: Text('STT', style: titleTableData)),
              //                             DataColumn(
              //                                 label: Container(
              //                                     child: Expanded(
              //                                         child: Text(
              //                               'Ngày thi tuyển',
              //                               style: titleTableData,
              //                               maxLines: 2,
              //                               softWrap: true,
              //                               // overflow: TextOverflow.ellipsis,
              //                             )))),
              //                             DataColumn(
              //                                 label: Container(
              //                                     child: Expanded(
              //                                         child: Text(
              //                               'Mã đơn hàng',
              //                               style: titleTableData,
              //                               maxLines: 2,
              //                               softWrap: true,
              //                               // overflow: TextOverflow.ellipsis,
              //                             )))),
              //                             DataColumn(
              //                                 label: Container(
              //                                     child: Expanded(
              //                                         child: Text(
              //                               'Tên đơn hàng',
              //                               style: titleTableData,
              //                               maxLines: 2,
              //                               softWrap: true,
              //                               // overflow: TextOverflow.ellipsis,
              //                             )))),
              //                             DataColumn(
              //                                 label: Container(
              //                                     child: Expanded(
              //                                         child: Text(
              //                               'Kết quả',
              //                               style: titleTableData,
              //                               maxLines: 2,
              //                               softWrap: true,
              //                               // overflow: TextOverflow.ellipsis,
              //                             )))),
              //                           ],
              //                           rows: <DataRow>[
              //                             for (int i = 0; i < lisDatatLSTT.length; i++)
              //                               DataRow(
              //                                 cells: <DataCell>[
              //                                   DataCell(Text("${tableIndex++}")),
              //                                   DataCell(
              //                                     Container(
              //                                       //  Text(FormatDate.formatDateddMMyy(DateTime.parse(listTTS[i]["createdDate"] ?? ""))),
              //                                       // width: MediaQuery.of(context).size.width * 0.1,
              //                                       child: Text(
              //                                         // '${lisDatatLSTT[i]["examDate"]}',
              //                                         // DateFormat("dd/MM/yyyy").format(DateTime.parse(lisDatatLSTT[i]["examDate"] ?? ''),
              //                                         lisDatatLSTT[i]["createdDate"] != null
              //                                             ? "Ngày ${FormatDate.formatDateDayHours(DateTime.parse(lisDatatLSTT[i]["createdDate"]))}"
              //                                             : '',
              //                                         style: TextStyle(color: Colors.blue[400]),
              //                                         maxLines: 2,
              //                                         softWrap: true,
              //                                         // overflow: TextOverflow.ellipsis,
              //                                       ),
              //                                     ),
              //                                   ),
              //                                   DataCell(
              //                                     Container(
              //                                       // width: MediaQuery.of(context).size.width * 0.07,
              //                                       child: Text(
              //                                         lisDatatLSTT[i]["donhang"]["orderCode"] ?? "",
              //                                         style: bangDuLieu,
              //                                         maxLines: 2,
              //                                         softWrap: true,
              //                                         // overflow: TextOverflow.ellipsis,
              //                                       ),
              //                                     ),
              //                                   ),
              //                                   DataCell(
              //                                     Container(
              //                                       // width: MediaQuery.of(context).size.width * 0.07,
              //                                       child: Text(
              //                                         lisDatatLSTT[i]["donhang"]["orderName"] ?? "",
              //                                         style: bangDuLieu,
              //                                         maxLines: 2,
              //                                         softWrap: true,
              //                                         // overflow: TextOverflow.ellipsis,
              //                                       ),
              //                                     ),
              //                                   ),
              //                                   DataCell(
              //                                     Container(
              //                                       // width: MediaQuery.of(context).size.width * 0.07,
              //                                       child: Text(
              //                                         examResult(lisDatatLSTT[i]["examResult"] ?? ""),
              //                                         style: bangDuLieu,
              //                                         maxLines: 2,
              //                                         softWrap: true,
              //                                         // overflow: TextOverflow.ellipsis,
              //                                       ),
              //                                     ),
              //                                   ),
              //                                 ],
              //                               ),
              //                           ],
              //                         ),
              //                       ),
              //                     ],
              //                   ),
              //                   DynamicTablePagging(rowCountLSTT, currentPageDefLSTT, rowPerPageLSTT, pageChangeHandler: (currentPage) {
              //                     setState(() {
              //                       futureListLSTT = getLSTT(currentPage);
              //                       currentPageDefLSTT = currentPage;
              //                     });
              //                   }, rowPerPageChangeHandler: (rowPerPageChange) {
              //                     currentPageDefLSTT = 1;

              //                     rowPerPageLSTT = rowPerPageChange;
              //                     futureListLSTT = getLSTT(currentPageDefLSTT);
              //                     setState(() {});
              //                   })
              //                 ],
              //               ),
              //             ),
              //           ],
              //         ),
              //       );
              //     } else if (snapshot.hasError) {
              //       return Text('${snapshot.error}');
              //     }
              //     return SizedBox(
              //         // child: Center(child: CircularProgressIndicator()),
              //         );
              //   },
              // ),
              Container(
                padding: paddingBoxContainer,
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
                          'Tiến cử đơn hàng',
                          style: titleBox,
                        ),
                        Text(
                          'Tổng số đơn hàng tiến cử: $rowCount',
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
                                    DataColumn(
                                        label: Container(
                                            child: Expanded(
                                                child: Text(
                                      'Mã đơn hàng',
                                      style: titleTableData,
                                      maxLines: 2,
                                      softWrap: true,
                                      // overflow: TextOverflow.ellipsis,
                                    )))),
                                    DataColumn(
                                        label: Container(
                                            child: Expanded(
                                                child: Text(
                                      'Tên đơn hàng',
                                      style: titleTableData,
                                      maxLines: 2,
                                      softWrap: true,
                                      // overflow: TextOverflow.ellipsis,
                                    )))),
                                    DataColumn(
                                        label: Container(
                                            child: Expanded(
                                                child: Text(
                                      'Mã nghiệp đoàn',
                                      style: titleTableData,
                                      maxLines: 2,
                                      softWrap: true,
                                      // overflow: TextOverflow.ellipsis,
                                    )))),
                                    DataColumn(
                                        label: Container(
                                            child: Expanded(
                                                child: Text(
                                      'Tên nghiệp đoàn',
                                      style: titleTableData,
                                      maxLines: 2,
                                      softWrap: true,
                                      // overflow: TextOverflow.ellipsis,
                                    )))),
                                    DataColumn(
                                        label: Container(
                                            child: Expanded(
                                                child: Text(
                                      'Tên xí nghiệp',
                                      style: titleTableData,
                                      maxLines: 2,
                                      softWrap: true,
                                      // overflow: TextOverflow.ellipsis,
                                    )))),
                                    DataColumn(
                                        label: Container(
                                            child: Expanded(
                                                child: Text(
                                      'Ngành nghề',
                                      style: titleTableData,
                                      maxLines: 2,
                                      softWrap: true,
                                      // overflow: TextOverflow.ellipsis,
                                    )))),
                                    DataColumn(
                                        label: Container(
                                            child: Expanded(
                                                child: Text(
                                      'Ngày tiến cử',
                                      style: titleTableData,
                                      maxLines: 2,
                                      softWrap: true,
                                      // overflow: TextOverflow.ellipsis,
                                    )))),
                                  ],
                                  rows: <DataRow>[
                                    for (int i = 0; i < listTrainee.length; i++)
                                      //  tableIndex = i;
                                      DataRow(
                                        cells: <DataCell>[
                                          DataCell(SelectableText("${pagination(currentPageDef, rowPerPage, i)}")),
                                          // DataCell(
                                          //   Container(
                                          //     width: MediaQuery.of(context).size.width * 0.1,
                                          //     child: Text(
                                          //       "${tableIndex++}",
                                          //       style: bangDuLieu,
                                          //       maxLines: 2,
                                          //       softWrap: true,
                                          //       // overflow: TextOverflow.ellipsis,
                                          //     ),
                                          //   ),
                                          // ),
                                          DataCell(
                                            Container(
                                              width: MediaQuery.of(context).size.width * 0.07,
                                              child: SelectableText(
                                                listTrainee[i]["donhang"]["orderCode"] ?? "",
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
                                                listTrainee[i]["donhang"]["orderName"] ?? "",
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
                                                listTrainee[i]["donhang"]["nghiepdoan"]["orgCode"] ?? "",
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
                                                listTrainee[i]["donhang"]["nghiepdoan"]["orgName"] ?? "",
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
                                                listTrainee[i]["donhang"]["xinghiep"]["companyName"], style: bangDuLieu,
                                                // maxLines: 2,
                                                // softWrap: true,
                                                // overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Container(
                                              width: MediaQuery.of(context).size.width * 0.07,
                                              child: SelectableText(
                                                listTrainee[i]["donhang"]["nganhnghe"]["jobName"], style: bangDuLieu,
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
              ),
              // FutureBuilder(
              //   future: futureListTrainee,
              //   builder: (context, snapshot) {
              //     if (snapshot.hasData) {
              //       // int toolTipLength = MediaQuery.of(context).size.width < 1600 ? 33 : 60;
              //       var tableIndex = (currentPageDef - 1) * rowPerPage + 1;
              //       return Container(
              //         padding: paddingBoxContainer,
              //         // margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 30),
              //         // decoration: BoxDecoration(
              //         //   color: colorWhite,
              //         //   borderRadius: borderRadiusContainer,
              //         //   boxShadow: [boxShadowContainer],
              //         //   border: borderAllContainerBox,
              //         // ),
              //         margin: marginTopLeftRightContainer,
              //         decoration: BoxDecoration(
              //           color: colorWhite,
              //           borderRadius: borderRadiusContainer,
              //           boxShadow: [boxShadowContainer],
              //           border: borderAllContainerBox,
              //         ),
              //         child: Column(
              //           children: [
              //             Row(
              //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //               children: [
              //                 Text(
              //                   'Tiến cử đơn hàng',
              //                   style: titleBox,
              //                 ),
              //                 Text(
              //                   'Tổng số đơn hàng tiến cử: $rowCount',
              //                   style: titleBox,
              //                 ),
              //               ],
              //             ),
              //             //Đường line
              //             Container(
              //               margin: marginTopBottomHorizontalLine,
              //               child: Divider(
              //                 thickness: 1,
              //                 color: ColorHorizontalLine,
              //               ),
              //             ),
              //             Container(
              //               child: Column(
              //                 children: [
              //                   Row(
              //                     children: [
              //                       Expanded(
              //                         child: DataTable(
              //                           showCheckboxColumn: false,
              //                           columnSpacing: 20,
              //                           horizontalMargin: 10,
              //                           dataRowHeight: 60,
              //                           columns: [
              //                             DataColumn(label: Text('STT', style: titleTableData)),
              //                             DataColumn(
              //                                 label: Container(
              //                                     child: Expanded(
              //                                         child: Text(
              //                               'Mã đơn hàng',
              //                               style: titleTableData,
              //                               maxLines: 2,
              //                               softWrap: true,
              //                               // overflow: TextOverflow.ellipsis,
              //                             )))),
              //                             DataColumn(
              //                                 label: Container(
              //                                     child: Expanded(
              //                                         child: Text(
              //                               'Tên đơn hàng',
              //                               style: titleTableData,
              //                               maxLines: 2,
              //                               softWrap: true,
              //                               // overflow: TextOverflow.ellipsis,
              //                             )))),
              //                             DataColumn(
              //                                 label: Container(
              //                                     child: Expanded(
              //                                         child: Text(
              //                               'Mã nghiệp đoàn',
              //                               style: titleTableData,
              //                               maxLines: 2,
              //                               softWrap: true,
              //                               // overflow: TextOverflow.ellipsis,
              //                             )))),
              //                             DataColumn(
              //                                 label: Container(
              //                                     child: Expanded(
              //                                         child: Text(
              //                               'Tên nghiệp đoàn',
              //                               style: titleTableData,
              //                               maxLines: 2,
              //                               softWrap: true,
              //                               // overflow: TextOverflow.ellipsis,
              //                             )))),
              //                             DataColumn(
              //                                 label: Container(
              //                                     child: Expanded(
              //                                         child: Text(
              //                               'Tên xí nghiệp',
              //                               style: titleTableData,
              //                               maxLines: 2,
              //                               softWrap: true,
              //                               // overflow: TextOverflow.ellipsis,
              //                             )))),
              //                             DataColumn(
              //                                 label: Container(
              //                                     child: Expanded(
              //                                         child: Text(
              //                               'ngành nghề',
              //                               style: titleTableData,
              //                               maxLines: 2,
              //                               softWrap: true,
              //                               // overflow: TextOverflow.ellipsis,
              //                             )))),
              //                           ],
              //                           rows: <DataRow>[
              //                             for (int i = 0; i < listTrainee.length; i++)
              //                               DataRow(
              //                                 cells: <DataCell>[
              //                                   DataCell(Text("${tableIndex++}")),
              //                                   // DataCell(
              //                                   //   Container(
              //                                   //     width: MediaQuery.of(context).size.width * 0.1,
              //                                   //     child: Text(
              //                                   //       "${tableIndex++}",
              //                                   //       style: bangDuLieu,
              //                                   //       maxLines: 2,
              //                                   //       softWrap: true,
              //                                   //       // overflow: TextOverflow.ellipsis,
              //                                   //     ),
              //                                   //   ),
              //                                   // ),
              //                                   DataCell(
              //                                     Container(
              //                                       width: MediaQuery.of(context).size.width * 0.07,
              //                                       child: Text(
              //                                         listTrainee[i]["donhang"]["orderCode"] ?? "",
              //                                         style: bangDuLieu,
              //                                         maxLines: 2,
              //                                         softWrap: true,
              //                                         // overflow: TextOverflow.ellipsis,
              //                                       ),
              //                                     ),
              //                                   ),
              //                                   DataCell(
              //                                     Container(
              //                                       width: MediaQuery.of(context).size.width * 0.09,
              //                                       child: Text(
              //                                         listTrainee[i]["donhang"]["orderName"] ?? "",
              //                                         style: bangDuLieu,
              //                                         maxLines: 2,
              //                                         softWrap: true,
              //                                         // overflow: TextOverflow.ellipsis,
              //                                       ),
              //                                     ),
              //                                   ),
              //                                   DataCell(
              //                                     Container(
              //                                       width: MediaQuery.of(context).size.width * 0.09,
              //                                       child: Text(
              //                                         listTrainee[i]["donhang"]["nghiepdoan"]["orgCode"] ?? "",
              //                                         style: bangDuLieu,
              //                                         maxLines: 2,
              //                                         softWrap: true,
              //                                         // overflow: TextOverflow.ellipsis,
              //                                       ),
              //                                     ),
              //                                   ),
              //                                   DataCell(
              //                                     Container(
              //                                       width: MediaQuery.of(context).size.width * 0.09,
              //                                       child: Text(
              //                                         listTrainee[i]["donhang"]["nghiepdoan"]["orgName"] ?? "",
              //                                         style: bangDuLieu,
              //                                         maxLines: 2,
              //                                         softWrap: true,
              //                                         // overflow: TextOverflow.ellipsis,
              //                                       ),
              //                                     ),
              //                                   ),
              //                                   DataCell(
              //                                     Container(
              //                                       width: MediaQuery.of(context).size.width * 0.09,
              //                                       child: Text(
              //                                         listTrainee[i]["donhang"]["xinghiep"]["companyName"], style: bangDuLieu,
              //                                         maxLines: 2,
              //                                         softWrap: true,
              //                                         // overflow: TextOverflow.ellipsis,
              //                                       ),
              //                                     ),
              //                                   ),
              //                                   DataCell(
              //                                     Container(
              //                                       width: MediaQuery.of(context).size.width * 0.07,
              //                                       child: Text(
              //                                         listTrainee[i]["donhang"]["nganhnghe"]["jobName"], style: bangDuLieu,
              //                                         maxLines: 2,
              //                                         softWrap: true,
              //                                         // overflow: TextOverflow.ellipsis,
              //                                       ),
              //                                     ),
              //                                   ),
              //                                 ],
              //                               ),
              //                           ],
              //                         ),
              //                       ),
              //                     ],
              //                   ),
              //                   DynamicTablePagging(rowCount, currentPageDef, rowPerPage, pageChangeHandler: (currentPage) {
              //                     setState(() {
              //                       futureListTrainee = pageChange(currentPage);
              //                       currentPageDef = currentPage;
              //                     });
              //                   }, rowPerPageChangeHandler: (rowPerPageChange) {
              //                     currentPageDef = 1;

              //                     rowPerPage = rowPerPageChange;
              //                     futureListTrainee = pageChange(currentPageDef);
              //                     setState(() {});
              //                   })
              //                 ],
              //               ),
              //             ),
              //           ],
              //         ),
              //       );
              //     } else if (snapshot.hasError) {
              //       return Text('${snapshot.error}');
              //     }
              //     return SizedBox(
              //         // child: const Center(child: CircularProgressIndicator()),
              //         );
              //   },
              // ),
            ],
          )
        : Center(child: CircularProgressIndicator());
  }
}
