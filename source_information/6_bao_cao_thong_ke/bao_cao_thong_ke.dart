// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/ho_so_noi/thuong_chitieu/thuong_chitieu_lichsu.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:gentelella_flutter/widgets/ui/source_information/6_bao_cao_thong_ke/xuat-file-bao-cao-thong-ke.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../../../../common/style.dart';
import '../common_ource_information/constant.dart';

class BaoCaoThongKeTTN extends StatelessWidget {
  const BaoCaoThongKeTTN({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: BaoCaoThongKeTTNBody());
  }
}

class BaoCaoThongKeTTNBody extends StatefulWidget {
  const BaoCaoThongKeTTNBody({Key? key}) : super(key: key);

  @override
  State<BaoCaoThongKeTTNBody> createState() => _BaoCaoThongKeTTNBodyState();
}

class _BaoCaoThongKeTTNBodyState extends State<BaoCaoThongKeTTNBody> {
  final String urlAddNewUpdateSI = "quan-ly-thong-tin-thuc-tap-sinh/add-new-update";

  String? dateFrom;
  String? dateTo;
  final oCcy = new NumberFormat("#,##0", "en_US");

  List<ThongKeTien> thongKeTien = [];
  Future historyPayCTV() async {
    String findNgay = "";
    if (dateTo != null) {
      var dateToNew = dateTo.toString().substring(6) + dateTo.toString().substring(2, 6) + dateTo.toString().substring(0, 2);
      dateTo = DateFormat("dd-MM-yyyy").format(DateTime.parse(dateToNew).add(const Duration(days: 1)));
      if (dateFrom != null)
        findNgay = "payDate >: '$dateFrom' and payDate <: '$dateTo'";
      else
        findNgay = "payDate <: '$dateTo'";
    } else {
      if (dateFrom != null)
        findNgay = "payDate >: '$dateFrom'";
      else
        findNgay = "";
    }
    var response = await httpGet("/api/ctv-lichsu-thanhtoan/get/page?sort=ttsId&filter=$findNgay", context);
    if (response.containsKey("body")) {
      var body = jsonDecode(response['body']);
      var content = body['content'];
      setState(() {
        thongKeTien = [];
        if (content.length > 0) {
          checkSttXuatFile = true;
          thongKeTien.add(ThongKeTien(
              maCTV: content[0]['congtacvien']['userCode'], hoTen: content[0]['congtacvien']['fullName'], tongTien: content[0]['totalAmount']));
          int idThongKe = 0;
          if (content.length > 1) {
            for (var i = 1; i < content.length; i++) {
              if (content[i]['ttsId'] == content[i - 1]['ttsId']) {
                thongKeTien[idThongKe].tongTien = (thongKeTien[idThongKe].tongTien! + content[i]['totalAmount']) as int?;
              } else {
                thongKeTien.add(ThongKeTien(
                    maCTV: content[i]['congtacvien']['userCode'], hoTen: content[i]['congtacvien']['fullName'], tongTien: content[i]['totalAmount']));
                idThongKe += 1;
              }
            }
            for (var i = 0; i < thongKeTien.length; i++) {
              print("ma:${thongKeTien[i].maCTV}");
              print("hoTen:${thongKeTien[i].hoTen}");
              print("tongTien:${thongKeTien[i].tongTien}");
              print("==========================");
            }
          }
        } else
          checkSttXuatFile = false;
      });
      return body;
    } else {
      throw Exception("failse");
    }
  }

  bool checkSttXuatFile = false;
  bool checkStt = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule(BAO_CAO_THONG_KE_TTN, context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Consumer<NavigationModel>(
            builder: (context, navigationModel, child) => ListView(
              controller: ScrollController(),
              children: [
                //---------- Breadcrumbs----------------
                TitlePage(
                  listPreTitle: [
                    {'url': '/thong-tin-nguon', 'title': 'Dashboard'},
                  ],
                  content: "Báo cáo thống kê",
                ),
                //----------end Breadcrumbs----------------
                Container(
                  color: backgroundPage,
                  padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 1,
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
                            //--Đường line
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
                                  child: DatePickerBoxVQ(
                                      requestDayBefore: dateTo,
                                      isTime: false,
                                      label: Text(
                                        'Từ ngày',
                                        style: titleWidgetBox,
                                      ),
                                      dateDisplay: dateFrom,
                                      selectedDateFunction: (day) {
                                        dateFrom = day;
                                        print(dateFrom);
                                        setState(() {});
                                      }),
                                ),
                                SizedBox(width: 50),
                                Expanded(
                                  flex: 3,
                                  child: DatePickerBoxVQ(
                                      requestDayAfter: dateFrom,
                                      isTime: false,
                                      label: Text(
                                        'Đến ngày',
                                        style: titleWidgetBox,
                                      ),
                                      dateDisplay: dateFrom,
                                      selectedDateFunction: (day) {
                                        dateTo = day;
                                        print(dateTo);
                                        setState(() {});
                                      }),
                                ),
                                Expanded(flex: 2, child: Container()),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(30, 30, 0, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  //tìm kiếm
                                  Container(
                                    margin: EdgeInsets.only(left: 20),
                                    child: TextButton.icon(
                                      icon: Icon(
                                        Icons.search,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 20.0,
                                          horizontal: 10.0,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5.0),
                                        ),
                                        backgroundColor: (dateTo != null || dateFrom != null) ? Color.fromRGBO(245, 117, 29, 1) : Color(0xfffcccccc),
                                        primary: Theme.of(context).iconTheme.color,
                                        textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                      ),
                                      onPressed: (dateTo != null || dateFrom != null)
                                          ? () {
                                              setState(() {
                                                historyPayCTV();
                                                checkStt = true;
                                              });
                                            }
                                          : null,
                                      label: Row(
                                        children: [
                                          Text('Tìm kiếm', style: textButton),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: marginLeftBtn,
                                    child: TextButton.icon(
                                      icon: Icon(
                                        Icons.file_copy_rounded,
                                        color: Colors.white,
                                        size: 15,
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: paddingBtn,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: borderRadiusBtn,
                                        ),
                                        backgroundColor: (checkSttXuatFile) ? backgroundColorBtn : Color(0xfffcccccc),
                                        primary: Theme.of(context).iconTheme.color,
                                        textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                      ),
                                      onPressed: (checkSttXuatFile)
                                          ? () async {
                                              xuatFileBaoCaoThongKe(thongKeTien);
                                            }
                                          : null,
                                      label: Row(
                                        children: [
                                          Text('Xuất file', style: textButton),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      (checkStt)
                          ? Container(
                              margin: marginTopBoxContainer,
                              decoration: BoxDecoration(
                                color: colorWhite,
                                borderRadius: borderRadiusContainer,
                                boxShadow: [boxShadowContainer],
                                border: borderAllContainerBox,
                              ),
                              padding: paddingBoxContainer,
                              child: Column(children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Báo cáo thống kê',
                                      style: titleBox,
                                    ),
                                    Text(
                                      'Kết quả tìm kiếm: ${thongKeTien.length}',
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
                                              showCheckboxColumn: true,
                                              columnSpacing: 20,
                                              horizontalMargin: 10,
                                              dataRowHeight: 60,
                                              columns: [
                                                DataColumn(label: Text('STT', style: titleTableData)),
                                                DataColumn(label: Text('Mã CTV', style: titleTableData)),
                                                DataColumn(label: Text('Họ tên', style: titleTableData)),
                                                DataColumn(label: Text('Tổng tiền', style: titleTableData)),
                                              ],
                                              rows: <DataRow>[
                                                for (int i = 0; i < thongKeTien.length; i++)
                                                  DataRow(
                                                    cells: <DataCell>[
                                                      DataCell(Text("${i + 1}")),
                                                      DataCell(
                                                        Text("${thongKeTien[i].maCTV}", style: bangDuLieu),
                                                      ),
                                                      DataCell(
                                                        Text("${thongKeTien[i].hoTen}", style: bangDuLieu),
                                                      ),
                                                      DataCell(
                                                        Text("${oCcy.format(thongKeTien[i].tongTien)} VND", style: bangDuLieu),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ]),
                            )
                          : Container(),
                      Footer(paddingFooter: paddingBoxContainer, marginFooter: EdgeInsets.only(top: 30)),
                    ],
                  ),
                ),
              ],
            ),
          );
          // Text(listRule.data!.title);
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }
        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

class ThongKeTien {
  String? maCTV;
  String? hoTen;
  int? tongTien;
  ThongKeTien({Key? key, this.maCTV, this.hoTen, this.tongTien});
}
