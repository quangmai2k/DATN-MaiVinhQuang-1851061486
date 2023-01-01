import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/format_date.dart';

import 'package:provider/provider.dart';

import '../../../../../api.dart';
import '../../../../../common/dynamic_table.dart';
import '../../../../../common/style.dart';
import '../../../../../model/market_development/currency.dart';
import '../../../../../model/market_development/fee.dart';
import '../../../../../model/market_development/setting_detail.dart';
import '../../../../../model/market_development/union.dart';
import '../../../../../model/model.dart';

import '../../../../forms/market_development/add/detail_caidatphi.dart';

class SettingFeeDetail extends StatefulWidget {
  final UnionObj? union;
  SettingFeeDetail({Key? key, this.union}) : super(key: key);

  @override
  State<SettingFeeDetail> createState() => _SettingFeeDetailState();
}

class _SettingFeeDetailState extends State<SettingFeeDetail> {
  late Future<List<ManageFee>> _fuutureListManager;
  List<ManageFee> _listManageFee = [];
  late List<SettingFeeDetails> listSettingFeeDetail;
  var body = {};
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;

  bool isChecked = false;

  Future<List<ManageFee>> getManageFeeSearchBy(page) async {
    List<ManageFee> futureListManageFee = [];
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response = await httpGet("/api/phiquanly/get/page?page=$page&size=$rowPerPage&sort=id,desc", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        currentPage = page;
        content = body['content'];
        rowCount = body["totalElements"];
        totalElements = body["totalElements"];
        lastRow = totalElements;
        content = body['content'];

        futureListManageFee = content.map((e) {
          return ManageFee.fromJson(e);
        }).toList();
        _listManageFee = futureListManageFee;
        if (_listManageFee.length > 0) {
          //var firstRow = (currentPage) * rowPerPage + 1;
          var lastRow = (currentPage + 1) * rowPerPage;
          if (lastRow > totalElements) {
            lastRow = totalElements;
          }
        }
      });
    }
    return futureListManageFee;
  }

  getMoneyNameById(List<Currency> list, int id) {
    for (int i = 0; i < list.length; i++) {
      if (id.toString() == list[i].id.toString()) {
        return list[i].name;
      }
    }
    return "No data!";
  }

  @override
  void initState() {
    super.initState();

    _fuutureListManager = getManageFeeSearchBy(page - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationModel>(
        builder: (context, navigationModel, child) => ListView(
              children: [
                Container(
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
                            'Cài đặt phí',
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Container(
                                padding: paddingBoxContainer,
                                margin: marginTopBoxContainer,
                                width: MediaQuery.of(context).size.width * 1,
                                height: 200,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Phí vé máy bay:",
                                                style: titleBox,
                                              ),
                                              flex: 1,
                                            ),
                                            Expanded(
                                              child: Text(
                                                widget.union!.arfareFee.toString(),
                                                // style: titleBox,
                                              ),
                                              flex: 3,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Container(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Phí đào tạo:",
                                                style: titleBox,
                                              ),
                                              flex: 1,
                                            ),
                                            Expanded(
                                              child: Text(
                                                widget.union!.trainingFee.toString(),
                                                // style: titleBox,
                                              ),
                                              flex: 3,
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            //right
                            Expanded(
                              flex: 5,
                              child: Container(
                                padding: paddingBoxContainer,
                                margin: marginTopBoxContainer,
                                width: MediaQuery.of(context).size.width * 1,
                                height: 200,
                                decoration: BoxDecoration(
                                  color: colorWhite,
                                  borderRadius: borderRadiusContainer,
                                  boxShadow: [boxShadowContainer],
                                  border: borderAllContainerBox,
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              'Cài đặt nhắc thu phí',
                                              style: titleBox,
                                              maxLines: 1,
                                              softWrap: false,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Icon(
                                            Icons.more_horiz,
                                            color: colorIconTitleBox,
                                            size: sizeIconTitleBox,
                                          ),
                                        ],
                                      ),
                                      //Đường line
                                      Container(
                                        margin: marginTopBottomHorizontalLine,
                                        child: Divider(
                                          thickness: 2,
                                          color: ColorHorizontalLine,
                                        ),
                                      ),
                                      Container(
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Ngày bắt đầu nhắc hẹn : ",
                                                style: titleBox,
                                                maxLines: 2,
                                                softWrap: false,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                widget.union!.chargeStartDate == null
                                                    ? "Chưa xác định"
                                                    : FormatDate.formatDateView(DateTime.parse(widget.union!.chargeStartDate.toString())),
                                                maxLines: 2,
                                                softWrap: false,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(top: 20),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                "Khoảng thời gian : ",
                                                style: titleBox,
                                                maxLines: 2,
                                                softWrap: false,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                (widget.union!.chargeCycleDate != null ? widget.union!.chargeCycleDate.toString() + " tháng" : "Chưa xác định"),
                                                maxLines: 2,
                                                softWrap: false,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
                  child: FutureBuilder<List<ManageFee>>(
                      future: _fuutureListManager,
                      builder: (context, snapshot) {
                        return Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Cài đặt phí',
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
                            //Start
                            //Start Datatable
                            if (snapshot.hasData)
                              Container(
                                  width: MediaQuery.of(context).size.width * 0.9,
                                  margin: const EdgeInsets.only(top: 30, left: 50, right: 50, bottom: 20),
                                  child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                                    return Center(
                                        child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: ConstrainedBox(
                                          constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                          child: DataTable(
                                            dataTextStyle: const TextStyle(color: Color(0xff313131), fontSize: 14, fontWeight: FontWeight.w500),
                                            showBottomBorder: true,
                                            dataRowHeight: 60,
                                            showCheckboxColumn: false,
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
                                                  'Mã nhóm phí',
                                                  style: titleTableData,
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Biên bản thỏa thuận',
                                                  style: titleTableData,
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Áp dụng',
                                                  style: titleTableData,
                                                ),
                                              ),
                                              DataColumn(
                                                label: Text(
                                                  'Thao tác',
                                                  style: titleTableData,
                                                ),
                                              ),
                                            ],
                                            rows: <DataRow>[
                                              for (int i = _listManageFee.length - 1; i > -1; i--)
                                                DataRow(
                                                  cells: <DataCell>[
                                                    DataCell(Text("${(currentPage) * rowPerPage + _listManageFee.length - i}")),
                                                    DataCell(Text("${_listManageFee[i].manageFeeCode}")),
                                                    DataCell(
                                                      (_listManageFee[i].confirmDoc == null || _listManageFee[i].confirmDoc == "null" || _listManageFee[i].confirmDoc == "")
                                                          ? Text("Chưa có biên bản")
                                                          : MouseRegion(
                                                              cursor: SystemMouseCursors.click,
                                                              child: GestureDetector(
                                                                child: Text("${_listManageFee[i].confirmDoc}",
                                                                    style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue)),
                                                                onTap: () async {
                                                                  downloadFile(_listManageFee[i].confirmDoc.toString());
                                                                },
                                                              ),
                                                            ),
                                                    ),
                                                    DataCell(
                                                      Container(
                                                        color: Colors.grey,
                                                        width: 100,
                                                        child: TextButton(
                                                            style: TextButton.styleFrom(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(5.0),
                                                              ),
                                                              backgroundColor: _listManageFee[i].id == widget.union!.manageFeeId ? Color(0xffF77919) : Colors.grey,
                                                              primary: Theme.of(context).iconTheme.color,
                                                            ),
                                                            onPressed: () {},
                                                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                                                              Text('Áp dụng', style: textButton),
                                                            ])),
                                                      ),
                                                    ),
                                                    DataCell(Row(
                                                      children: [
                                                        Consumer<NavigationModel>(
                                                          builder: (context, navigationModel, child) => Container(
                                                            margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                            child: InkWell(
                                                              onTap: () {
                                                                setState(() {
                                                                  showDialog(
                                                                    context: context,
                                                                    builder: (BuildContext context) => ShowModelFeeManagerDetails(id: _listManageFee[i].id),
                                                                  );
                                                                });
                                                              },
                                                              child: Icon(Icons.visibility),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )),
                                                  ],
                                                ),
                                            ],
                                          )),
                                    ));
                                  }))
                            else if (snapshot.hasError)
                              Text("Fail! ${snapshot.error}")
                            else
                              Center(
                                child: CircularProgressIndicator(),
                              ),
                            // End Datatable
                            Container(
                              margin: const EdgeInsets.only(right: 50),
                              child: DynamicTablePagging(
                                rowCount,
                                currentPage + 1,
                                rowPerPage,
                                pageChangeHandler: (page) {
                                  setState(() {
                                    getManageFeeSearchBy(page - 1);
                                  });
                                },
                                rowPerPageChangeHandler: (rowPerPage) {
                                  setState(() {
                                    this.rowPerPage = rowPerPage!;
                                    //coding
                                    this.firstRow = page * currentPage;
                                    getManageFeeSearchBy(page - 1);
                                  });
                                },
                              ),
                            ),
                          ],
                        );
                      }),
                ),
              ],
            ));
  }
}
