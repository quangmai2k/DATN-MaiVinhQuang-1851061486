// ignore_for_file: unused_local_variable
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/nhan_su/sua-cham-cong.dart';
import 'package:gentelella_flutter/widgets/ui/nhan_su/view-cham-cong.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../api.dart';
import '../../../common/dynamic_table.dart';
import '../../../common/style.dart';
import '../../../common/toast.dart';
import '../../../common/widgets_form.dart';
import '../../../model/model.dart';
import '../navigation.dart';

class ChamCong extends StatefulWidget {
  const ChamCong({Key? key}) : super(key: key);

  @override
  _ChamCongState createState() => _ChamCongState();
}

class _ChamCongState extends State<ChamCong> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: ChamCongBody());
  }
}

class ChamCongBody extends StatefulWidget {
  const ChamCongBody({Key? key}) : super(key: key);
  @override
  State<ChamCongBody> createState() => _ChamCongBodyState();
}

class _ChamCongBodyState extends State<ChamCongBody> {
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  var tableIndex = 1;

  var resultTimekeeping = {};
  var listTimekeeping;
  String findCC = "";
  String checkTime = "";

  getTimekeeping(int page, String findCC) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response1;
    if (findCC == "")
      response1 = await httpGet("/api/chamcong/get/page?size=$rowPerPage&page=$page&filter=deleted:false", context);
    else
      response1 = await httpGet("/api/chamcong/get/page?size=$rowPerPage&page=$page&filter=deleted:false $findCC", context);
    var content = [];
    if (response1.containsKey("body")) {
      resultTimekeeping = jsonDecode(response1["body"]);
      setState(() {
        currentPage = page + 1;
        content = resultTimekeeping['content'];
        rowCount = resultTimekeeping["totalElements"];
        totalElements = resultTimekeeping["totalElements"];
        lastRow = totalElements;
        // print(content);
      });
      rowCount = resultTimekeeping['totalElements'];
      if (content.length > 0) {
        var firstRow = (currentPage) * rowPerPage + 1;
        var lastRow = (currentPage + 1) * rowPerPage;
        if (lastRow > totalElements) {
          lastRow = totalElements;
        }
        tableIndex = (currentPage - 1) * rowPerPage + 1;
      }
      return resultTimekeeping;
    }
    return resultTimekeeping;
  }

  @override
  void initState() {
    super.initState();
    listTimekeeping = getTimekeeping(0, findCC);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/cham-cong', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Consumer2<NavigationModel, SecurityModel>(
            builder: (context, navigationModel, user, child) => ListView(
              controller: ScrollController(),
              children: [
                TitlePage(
                  listPreTitle: [
                    {'url': "/nhan-su", 'title': 'Dashboard'},
                  ],
                  content: 'Chấm công',
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 1,
                  decoration: BoxDecoration(
                    color: colorWhite,
                    borderRadius: borderRadiusContainer,
                    boxShadow: [boxShadowContainer],
                    border: borderAllContainerBox,
                  ),
                  padding: paddingBoxContainer,
                  margin: EdgeInsets.only(top: 20, left: 25, right: 25),
                  child: (user.userLoginCurren['departId'] == 2 ||
                          user.userLoginCurren['departId'] == 1 ||
                          (user.userLoginCurren['vaitro'] != null && user.userLoginCurren['vaitro']['level'] > 0))
                      ? Column(
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
                                SizedBox(width: 50),
                                Expanded(
                                  flex: 3,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text('Tháng:', style: titleWidgetBox),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Container(
                                            padding: EdgeInsets.only(left: 8),
                                            decoration: BoxDecoration(border: Border.all(width: 0.5, style: BorderStyle.solid)),
                                            child: MonthPickerLimit(
                                                pickTime: (checkTime != "")
                                                    ? DateTime(
                                                        int.parse(checkTime.substring(0, 4)),
                                                        int.parse(
                                                          checkTime.substring(5),
                                                        ))
                                                    : null,
                                                callBack: (value) async {
                                                  setState(() {
                                                    if (value != "")
                                                      checkTime = value;
                                                    else
                                                      checkTime = "";
                                                    print(checkTime);
                                                  });
                                                })

                                            // MonthPickerLimit(
                                            //   callBack: (value) {
                                            //       checkTime = value;
                                            //     print(checkTime);
                                            //   },
                                            // )
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 100),
                                Expanded(flex: 5, child: Text('')),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(30, 0, 0, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  //tìm kiếm
                                  getRule(listRule.data, Role.Xem, context)
                                      ? Container(
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
                                              String time = "";
                                              time = "and timekeepingMonth~'*$checkTime*'";
                                              // print(time);
                                              getTimekeeping(0, time);
                                              //  showToast(
                                              //         context: context,
                                              //         msg: "Chưa tìm kiếm được nhé (^.^)",
                                              //         color: colorOrange,
                                              //         icon: Icon(Icons.close),
                                              //       );
                                            },
                                            child: Row(
                                              children: [
                                                Icon(Icons.search, color: colorWhite),
                                                SizedBox(width: 5),
                                                Text('Tìm kiếm', style: textButton),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(),
                                  getRule(listRule.data, Role.Them, context)
                                      ? Container(
                                          margin: marginLeftBtn,
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(
                                                vertical: 20.0,
                                                horizontal: 10.0,
                                              ),
                                              backgroundColor: backgroundColorBtn,
                                              primary: Theme.of(context).iconTheme.color,
                                              textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                            ),
                                            onPressed: () {
                                              Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/them-moi-cham-cong");
                                            },
                                            child: Row(
                                              children: [
                                                Icon(Icons.add, color: colorWhite),
                                                SizedBox(width: 5),
                                                Text('Thêm mới', style: textButton),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Center(
                          child: Text(
                          "Không có quyền truy cập vào tính năng này",
                          style: titleTableData,
                        )),
                ),
                if (user.userLoginCurren['departId'] == 2 ||
                    user.userLoginCurren['departId'] == 1 ||
                    (user.userLoginCurren['vaitro'] != null && user.userLoginCurren['vaitro']['level'] > 0))
                  Container(
                    color: backgroundPage,
                    padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
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
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Thông tin chấm công',
                                        style: titleBox,
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
                                  FutureBuilder(
                                    future: listTimekeeping,
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Row(
                                          children: [
                                            Expanded(
                                                child: DataTable(
                                              showCheckboxColumn: false,
                                              columns: [
                                                DataColumn(label: Text('STT', style: titleTableData)),
                                                DataColumn(label: Text('Tháng', style: titleTableData)),
                                                DataColumn(label: Text('File tổng hợp bảng chấm công', style: titleTableData)),
                                                DataColumn(label: Text('Hành động', style: titleTableData)),
                                              ],
                                              rows: <DataRow>[
                                                for (int i = 0; i < resultTimekeeping["content"].length; i++)
                                                  DataRow(
                                                    cells: <DataCell>[
                                                      DataCell(Text(" ${tableIndex + i}", style: bangDuLieu)),
                                                      DataCell(
                                                        Text(
                                                            "${DateFormat('MM-yyyy').format(DateTime.parse('${resultTimekeeping['content'][i]['timekeepingMonth'].toString()}-01').toLocal())}",
                                                            style: bangDuLieu),
                                                      ),
                                                      DataCell(
                                                        TextButton(
                                                            onPressed: (resultTimekeeping["content"][i]["fileEditedLatest"] != null)
                                                                ? () {
                                                                    downloadFile(resultTimekeeping["content"][i]["fileEditedLatest"]);
                                                                  }
                                                                : null,
                                                            child: Text(
                                                                (resultTimekeeping["content"][i]["fileEditedLatest"] != null) ? "Tải file" : "",
                                                                style: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic))),
                                                      ),
                                                      DataCell(Row(
                                                        children: [
                                                          getRule(listRule.data, Role.Xem, context)
                                                              ? Consumer<NavigationModel>(
                                                                  builder: (context, navigationModel, child) => Container(
                                                                      margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                      child: InkWell(
                                                                          onTap: () {
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                  builder: (context) => ViewCCBody(
                                                                                      idCC: resultTimekeeping["content"][i]["id"].toString())),
                                                                            );
                                                                          },
                                                                          child: Icon(Icons.visibility))),
                                                                )
                                                              : Text(""),
                                                          getRule(listRule.data, Role.Sua, context)
                                                              ? Consumer<NavigationModel>(
                                                                  builder: (context, navigationModel, child) => Container(
                                                                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                      child: InkWell(
                                                                          onTap: () {
                                                                            Navigator.push(
                                                                              context,
                                                                              MaterialPageRoute(
                                                                                  builder: (context) => UpdateTimeKeeping(
                                                                                      idCC: resultTimekeeping["content"][i]["id"].toString())),
                                                                            );
                                                                          },
                                                                          child: Icon(
                                                                            Icons.edit_calendar,
                                                                            color: Color(0xff009C87),
                                                                          ))),
                                                                )
                                                              : Text(""),
                                                          getRule(listRule.data, Role.Xoa, context)
                                                              ? Consumer<NavigationModel>(
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
                                                                                                    child: Image.asset('assets/images/logoAAM.png'),
                                                                                                    margin: EdgeInsets.only(right: 10),
                                                                                                  ),
                                                                                                  Text(
                                                                                                    'Xác nhận xóa file chấm công',
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
                                                                                            //đường line
                                                                                            Container(
                                                                                              margin: marginTopBottomHorizontalLine,
                                                                                              child: Divider(
                                                                                                thickness: 1,
                                                                                                color: ColorHorizontalLine,
                                                                                              ),
                                                                                            ),
                                                                                            Container(
                                                                                              child: Text(
                                                                                                  'Xóa file chấm công tháng: ${resultTimekeeping["content"][i]['timekeepingMonth'].toString().substring(5, 7)}/${resultTimekeeping["content"][i]['timekeepingMonth'].toString().substring(0, 4)}'),
                                                                                            ),
                                                                                            //đường line
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
                                                                                          child: Text('Hủy'),
                                                                                          style: ElevatedButton.styleFrom(
                                                                                            primary: colorOrange,
                                                                                            onPrimary: colorWhite,
                                                                                            elevation: 3,
                                                                                            minimumSize: Size(100, 40),
                                                                                          ),
                                                                                        ),
                                                                                        ElevatedButton(
                                                                                          onPressed: () async {
                                                                                            // print(resultTimekeeping["content"][i]['id']);
                                                                                            var response = await httpDelete(
                                                                                                "/api/chamcong/del/${resultTimekeeping["content"][i]['id']}",
                                                                                                context);
                                                                                            print(response['body']);
                                                                                            await getTimekeeping(currentPage - 1, findCC);

                                                                                            Navigator.pop(context);
                                                                                            showToast(
                                                                                              context: context,
                                                                                              msg:
                                                                                                  "Xóa đề file chấm công tháng ${resultTimekeeping["content"][i]['timekeepingMonth'].toString().substring(5, 7)}/${resultTimekeeping["content"][i]['timekeepingMonth'].toString().substring(0, 4)} thành công",
                                                                                              color: Color.fromARGB(136, 72, 238, 67),
                                                                                              icon: const Icon(Icons.done),
                                                                                            );
                                                                                          },
                                                                                          child: Text(
                                                                                            'Xác nhận',
                                                                                            style: TextStyle(),
                                                                                          ),
                                                                                          style: ElevatedButton.styleFrom(
                                                                                            primary: mainColorPage,
                                                                                            onPrimary: colorWhite,
                                                                                            elevation: 3,
                                                                                            minimumSize: Size(100, 40),
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ));
                                                                          },
                                                                          child: Icon(Icons.delete_outline, color: Colors.red))),
                                                                )
                                                              : Text(""),
                                                        ],
                                                      )),
                                                      //
                                                    ],
                                                  )
                                              ],
                                            )),
                                          ],
                                        );
                                      } else if (snapshot.hasError) {
                                        return Text('${snapshot.error}');
                                      }
                                      // By default, show a loading spinner.
                                      return const CircularProgressIndicator();
                                    },
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(right: 50),
                                    child: DynamicTablePagging(
                                      rowCount,
                                      currentPage,
                                      rowPerPage,
                                      pageChangeHandler: (page) {
                                        setState(() {
                                          getTimekeeping(page - 1, findCC);
                                          currentPage = page - 1;
                                        });
                                      },
                                      rowPerPageChangeHandler: (rowPerPage) {
                                        setState(() {
                                          this.rowPerPage = rowPerPage!;
                                          this.firstRow = page * currentPage;
                                          getTimekeeping(0, findCC);
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
                Footer(marginFooter: EdgeInsets.only(top: 5), paddingFooter: EdgeInsets.all(15)),
                SizedBox(height: 20)
              ],
            ),
          );
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
