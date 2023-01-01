import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/model/market_development/union.dart';
import 'package:gentelella_flutter/model/market_development/user.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';

import 'package:provider/provider.dart';

import '../../../../../api.dart';
import '../../../../../common/dynamic_table.dart';
import '../../../../../common/style.dart';
import '../../../../../model/market_development/lich_su_cong_tac.dart';

import '../../../../../model/model.dart';
import '../../validate_data/validate_data.dart';

class AccessHistoryDetail extends StatefulWidget {
  final UnionObj? union;
  AccessHistoryDetail({Key? key, this.union}) : super(key: key);

  @override
  State<AccessHistoryDetail> createState() => _AccessHistoryDetailState();
}

class _AccessHistoryDetailState extends State<AccessHistoryDetail> {
  DateTime selectedDate = DateTime.now();

  bool get wantKeepAlive => true; //chuyển sang false thì khi tab sẽ load lại trang
  var body = {};
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  List<LichSuCongTac> listWorkingSchedule = [];
  late Future<List<LichSuCongTac>> futureWorkingSchedules;
  Future<List<LichSuCongTac>> getListWorkingScheduleSearchByOrgIdByStatusThan0(int id, page) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response;
    Map<String, String> requestParam = Map();

    String condition = "";

    if (requestParam.isNotEmpty) {
      for (var entry in requestParam.entries) {
        if (entry.key == "orgName") {
          condition += " ( ${entry.key}~'*${entry.value}*'";
        }
        if (entry.key == "orgCode") {
          condition += " OR ${entry.key}~'*${entry.value}*' ) ";
        }
        print("test $condition");
        if (entry.key == "contractStatus") {
          if (entry.value != "-1") {
            condition += " AND ${entry.key}:${entry.value}";
          } else {
            //condition +=
            //" AND ( contractStatus:0 OR contractStatus:1 OR contractStatus:2 OR contractStatus:3 )";
          }
        }
      }

      response = await httpGet("/api/lichcongtac-nghiepdoan/get/page?page=$page&size=$rowPerPage&filter=$condition", context);
    } else {
      response = await httpGet("/api/lichcongtac-nghiepdoan/get/page?page=$page&size=$rowPerPage&sort=id&filter=lichcongtac.status>0 AND orgId:${widget.union!.id}", context);
    }
    var body = jsonDecode(response['body']);
    var content = [];
    // listUnionObjectResult = content.map((e) {
    //   return UnionObj.fromJson(e);
    // }).toList();

    if (response.containsKey("body")) {
      setState(() {
        currentPage = page + 1;
        content = body['content'];

        totalElements = body["totalElements"];
        lastRow = totalElements;
        rowCount = totalElements;
        listWorkingSchedule = content.map((e) {
          return LichSuCongTac.fromJson(e);
        }).toList();

        if (listWorkingSchedule.length > 0) {
          firstRow = (currentPage + 1) * rowPerPage + 1;
          lastRow = (currentPage + 1) * rowPerPage;
          if (lastRow > totalElements) {
            lastRow = totalElements;
          }
        }
      });
    }

    return content.map((e) {
      return LichSuCongTac.fromJson(e);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    futureWorkingSchedules = getListWorkingScheduleSearchByOrgIdByStatusThan0(widget.union!.id!, page);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationModel>(
        builder: (context, navigationModel, child) => FutureBuilder<Object>(
            future: futureWorkingSchedules,
            builder: (context, snapshot) {
              return ListView(
                children: [
                  //==============Danh sách=====
                  Container(
                    width: MediaQuery.of(context).size.width * 1,
                    padding: paddingBoxContainer,
                    margin: marginBoxFormTab,
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
                              'Lịch sử tiếp cận',
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
                        if (snapshot.hasData)
                          //Start Datatable
                          Container(
                              width: MediaQuery.of(context).size.width * 1,
                              child: DataTable(
                                dataTextStyle: const TextStyle(color: Color(0xff313131), fontSize: 14, fontWeight: FontWeight.w500),
                                showBottomBorder: true,
                                dataRowHeight: 60,
                                showCheckboxColumn: true,
                                dataRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                                  if (states.contains(MaterialState.selected)) {
                                    return MaterialStateColor.resolveWith((states) => const Color(0xffeef3ff));
                                  }
                                  return MaterialStateColor.resolveWith((states) => Colors.white); // Use the default value.
                                }),
                                columns: <DataColumn>[
                                  DataColumn(
                                    label: Text(
                                      'STT',
                                      style: titleTableData,
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Nhân viên',
                                      style: titleTableData,
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Từ ngày',
                                      style: titleTableData,
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Đến ngày',
                                      style: titleTableData,
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      'Nội dung làm việc',
                                      style: titleTableData,
                                    ),
                                  ),
                                ],
                                rows: <DataRow>[
                                  for (int i = 0; i < listWorkingSchedule.length; i++)
                                    DataRow(
                                      cells: <DataCell>[
                                        DataCell(
                                          Container(
                                            width: (MediaQuery.of(context).size.width / 10) * 0.1,
                                            child: Text("${(page - 1) * rowPerPage + i + 1}"),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                              width: (MediaQuery.of(context).size.width / 10) * 0.9,
                                              child: Text(checkDataWithUser(
                                                  listWorkingSchedule[i].workingSchedule!.user, listWorkingSchedule[i].workingSchedule!.user?.fullName, "Không có dữ liệu"))),
                                        ),
                                        DataCell(
                                          Container(
                                              width: (MediaQuery.of(context).size.width / 10) * 0.9,
                                              child: Text(getDateView(listWorkingSchedule[i].workingSchedule!.dateFrom.toString()))),
                                        ),
                                        DataCell(
                                          Container(
                                            width: (MediaQuery.of(context).size.width / 10) * 0.9,
                                            child: Text(
                                              getDateView(
                                                listWorkingSchedule[i].workingSchedule!.dateTo.toString(),
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                              width: (MediaQuery.of(context).size.width / 10) * 0.6,
                                              child: Tooltip(
                                                verticalOffset: 100,
                                                height: 30,
                                                message: checkDataValue(listWorkingSchedule[i].workingSchedule!.content).toString(),
                                                child: Text(
                                                  checkDataValue(listWorkingSchedule[i].workingSchedule!.content).toString(),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 3,
                                                ),
                                              )),
                                        ),
                                      ],
                                    ),
                                ],
                              ))
                        else if (snapshot.hasError)
                          Text("Fail! ${snapshot.error}")
                        else if (!snapshot.hasData)
                          Center(
                            child: CircularProgressIndicator(),
                          ),
                        //End Datatable
                        Container(
                          margin: const EdgeInsets.only(right: 50),
                          child: DynamicTablePagging(
                            rowCount,
                            currentPage,
                            rowPerPage,
                            pageChangeHandler: (page) {
                              setState(() {
                                getListWorkingScheduleSearchByOrgIdByStatusThan0(widget.union!.id!, page - 1);
                              });
                            },
                            rowPerPageChangeHandler: (rowPerPage) {
                              setState(() {
                                this.rowPerPage = rowPerPage!;
                                getListWorkingScheduleSearchByOrgIdByStatusThan0(widget.union!.id!, page - 1);
                                this.firstRow = page * currentPage;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }));
  }
}
