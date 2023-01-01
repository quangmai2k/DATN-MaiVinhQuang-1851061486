import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';

import '../../../../common/style.dart';

class LichSuCuocGoi extends StatefulWidget {
  const LichSuCuocGoi({Key? key}) : super(key: key);

  @override
  State<LichSuCuocGoi> createState() => _LichSuCuocGoiState();
}

class _LichSuCuocGoiState extends State<LichSuCuocGoi> {
  var listLSCG;
  late int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 10;
  late Future<dynamic> getLSCGFuture;
  getLSCG(curentPage) async {
    var response = await httpGetCall(
        '/api/call_transaction/list?from_date=${(DateTime.now().subtract(Duration(days: 3)).millisecondsSinceEpoch / 1000).round()}&to_date=${(DateTime.now().millisecondsSinceEpoch / 1000).round()}&page=$curentPage&size=$rowPerPage',
        context);
    if (response.containsKey("body")) {
      setState(() {
        listLSCG = response['body']['items'];
        rowCount = response['body']['total_items'];
      });
    }
    return 0;
  }

  String duration(time) {
    return "${time ~/ 60 < 10 ? '0' : ''}${time ~/ 60}:${time ~/ 60 < 10 ? '0' : ''}${time % 60}";
  }

  String readTimestamp(int timestamp) {
    var now = DateTime.now();
    var format = DateFormat('HH:mm a');
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var diff = now.difference(date);
    var time = '';
    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = format.format(date);
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' DAY AGO';
      } else {
        time = diff.inDays.toString() + ' DAYS AGO';
      }
    } else {
      if (diff.inDays == 7) {
        time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
      } else {
        time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
      }
    }
    return time;
  }

  @override
  void initState() {
    getLSCGFuture = getLSCG(1);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: getLSCGFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var tableIndex = (currentPageDef - 1) * rowPerPage + 1;
          return SingleChildScrollView(
            child: Column(children: [
              Container(
                color: backgroundPage,
                padding: EdgeInsets.symmetric(
                    vertical: verticalPaddingPage,
                    horizontal: horizontalPaddingPage),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nhật ký cuộc gọi',
                            style: titleBox,
                          ),
                          Icon(
                            Icons.more_horiz,
                            color: colorIconTitleBox,
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
                      Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  child: DataTable(
                                      columnSpacing: 1,
                                      showCheckboxColumn: false,
                                      columns: [
                                    DataColumn(
                                        label: Container(
                                      child: Text(
                                        'STT',
                                        style: titleTableData,
                                      ),
                                    )),
                                    DataColumn(
                                        label: Container(
                                      child: Text('Tên khách hàng',
                                          style: titleTableData),
                                    )),
                                    DataColumn(
                                        label: Container(
                                      child: Text('Số điện thoại',
                                          style: titleTableData),
                                    )),
                                    DataColumn(
                                        label: Container(
                                      child: Text('Thời gian cuộc gọi',
                                          style: titleTableData),
                                    )),
                                    DataColumn(
                                        label: Container(
                                      child: Text('Ngày gọi',
                                          style: titleTableData),
                                    )),
                                    DataColumn(
                                        label: Container(
                                      child: Text('Trạng thái',
                                          style: titleTableData),
                                    )),
                                    DataColumn(
                                        label: Container(
                                      child: Text('Loại cuộc gọi',
                                          style: titleTableData),
                                    )),
                                  ],
                                      rows: <DataRow>[
                                    for (var row in listLSCG)
                                      DataRow(cells: <DataCell>[
                                        DataCell(Text('${tableIndex++}',
                                            style: bangDuLieu)),
                                        DataCell(Text(
                                            row['customer'] != null
                                                ? row['customer']
                                                        ['full_name'] ??
                                                    'Chưa có thông tin'
                                                : 'Chưa có thông tin',
                                            style: bangDuLieu)),
                                        DataCell(Text(
                                            row['direction'] == 'outbound'
                                                ? row['destination_number']
                                                : row['source_number'],
                                            style: bangDuLieu)),
                                        DataCell(Text(duration(row['bill_sec']),
                                            style: TextStyle(
                                                color: row['bill_sec'] == 0
                                                    ? Colors.red
                                                    : Colors.green))),
                                        DataCell(Row(
                                          children: [
                                            Text(
                                              DateFormat('HH:mm  dd-MM-yyyy')
                                                  .format(DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          row['created_date'])),
                                            ),
                                          ],
                                        )),
                                        DataCell(Text(
                                            row['disposition'] == 'cancelled'
                                                ? "Không trả lời"
                                                : "Trả lời",
                                            style: bangDuLieu)),
                                        DataCell(Text(
                                            row['direction'] == 'outbound'
                                                ? 'Cuộc gọi đi'
                                                : row['direction'] == 'inbound'
                                                    ? 'Cuộc gọi đến'
                                                    : 'Gọi nội bộ',
                                            style: bangDuLieu)),
                                      ])
                                  ])),
                            ],
                          ),
                          DynamicTablePagging(
                              rowCount, currentPageDef, rowPerPage,
                              pageChangeHandler: (currentPage) {
                            setState(() {
                              getLSCGFuture = getLSCG(currentPage);
                              currentPageDef = currentPage;
                            });
                          }, rowPerPageChangeHandler: (rowPerPageChange) {
                            currentPageDef = 1;

                            rowPerPage = rowPerPageChange;
                            getLSCGFuture = getLSCG(currentPageDef);
                            setState(() {});
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return Center(child: const CircularProgressIndicator());
      },
    );
  }
}
