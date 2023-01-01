import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import 'package:intl/intl.dart';

import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';

class DanhSachKhachHang extends StatefulWidget {
  const DanhSachKhachHang({Key? key}) : super(key: key);

  @override
  State<DanhSachKhachHang> createState() => _DanhSachKhachHangState();
}

class _DanhSachKhachHangState extends State<DanhSachKhachHang> {
  var listLSCG;
  late int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 10;
  late Future<dynamic> getLSCGFuture;
  getLSCG(curentPage) async {
    var response = await httpGetCall(
        '/api/contacts/list?page=$curentPage&size=$rowPerPage', context);
    if (response.containsKey("body")) {
      setState(() {
        listLSCG = response['body']['items'];
        rowCount = response['body']['total_items'];
      });
    }
    return 0;
  }

  deleteContact(id) async {
    var response = await httpDeleteCall("/api/contacts/delete/$id", context);
    return 0;
  }

  dynamic getData(listData, code) {
    for (var row in listData) {
      if (row['field_code'] == code) {
        if (row['value'].isNotEmpty) return row['value'].first;
      }
    }
    return {};
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
                            'Danh sách khách hàng',
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
                                      child: Text('Mã khách hàng',
                                          style: titleTableData),
                                    )),
                                    DataColumn(
                                        label: Container(
                                      child: Text('Tên khách hàng',
                                          style: titleTableData),
                                    )),
                                    DataColumn(
                                        label: Container(
                                      child: Text('Giới tính',
                                          style: titleTableData),
                                    )),
                                    DataColumn(
                                        label: Container(
                                      child: Text('Số điện thoại',
                                          style: titleTableData),
                                    )),
                                    DataColumn(
                                        label: Container(
                                      child: Text('Hành động',
                                          style: titleTableData),
                                    )),
                                  ],
                                      rows: <DataRow>[
                                    for (var row in listLSCG)
                                      DataRow(cells: <DataCell>[
                                        DataCell(Text('${tableIndex++}',
                                            style: bangDuLieu)),
                                        DataCell(Text(
                                            getData(row['attribute_structure'],
                                                        'ref_code')[
                                                    'display_value'] ??
                                                '',
                                            style: bangDuLieu)),
                                        DataCell(Text(
                                            getData(row['attribute_structure'],
                                                        'full_name')[
                                                    'display_value'] ??
                                                '',
                                            style: bangDuLieu)),
                                        DataCell(Text(
                                            getData(row['attribute_structure'],
                                                            'gender')[
                                                        'display_value'] ==
                                                    'male'
                                                ? 'Nam'
                                                : getData(
                                                                row[
                                                                    'attribute_structure'],
                                                                'gender')[
                                                            'display_value'] ==
                                                        'female'
                                                    ? 'Nữ'
                                                    : 'Không xác định',
                                            style: bangDuLieu)),
                                        DataCell(Text(
                                            getData(row['attribute_structure'],
                                                        'phone_number')[
                                                    'display_value'] ??
                                                '',
                                            style: bangDuLieu)),
                                        DataCell(Row(
                                          children: [
                                            Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    10, 0, 0, 0),
                                                child: InkWell(
                                                  onTap: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            ConfirmUpdate(
                                                                title:
                                                                    "Xác nhận",
                                                                function:
                                                                    () async {
                                                                  await deleteContact(
                                                                      row['_id']);
                                                                  print(row[
                                                                      'id']);
                                                                  getLSCGFuture =
                                                                      getLSCG(
                                                                          currentPageDef);

                                                                  showToast(
                                                                      context:
                                                                          context,
                                                                      msg:
                                                                          "Xóa thông tin thành công",
                                                                      color: Colors
                                                                          .green,
                                                                      icon: Icon(
                                                                          Icons
                                                                              .done));
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                content:
                                                                    "Bạn có chắc chắn muốn xóa thông tin liên hệ của người dùng này"));
                                                  },
                                                  child: Icon(
                                                    Icons.delete_outline,
                                                    color: Colors.red,
                                                  ),
                                                ))
                                          ],
                                        )),
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
