import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../../common/dynamic_table.dart';
import '../../../../forms/market_development/utils/funciton.dart';
import '../../../../../api.dart';
import '../../../../../common/style.dart';
import '../../../../../model/market_development/QuaTrinhLamViec.dart';
import '../../../../../model/market_development/phongban.dart';
import '../../../../../model/market_development/quydinh.dart';

// ignore: must_be_immutable
class WorkingProcess extends StatefulWidget {
  String? idTTS;

  int? orderId;
  WorkingProcess({Key? key, this.idTTS, this.orderId}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _WorkingProcessState();
  }
}

class _WorkingProcessState extends State<WorkingProcess> {
  var body = {};
  var page = 1;
  // var rowPerPage = 5;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  // var rowCount = 0;
  var currentPage = 1;

  bool isValidateForm = false;
  DateTime? violateDate;
  bool _setLoading = false;

  late Future<List<QuaTrinhLamViec1>> futureNoiDungViPham;
  // Future<List<QuaTrinhLamViec1>> getNoiDungViPham() async {
  //   if (page * rowPerPage > totalElements) {
  //     page = (1.0 * totalElements / rowPerPage - 1).ceil();
  //   }
  //   if (page < 1) {
  //     page = 0;
  //   }
  //   var response;

  //   String condition = "";

  //   response = await httpGet("/api/tts-quatrinhlamviec/get/page?filter=ttsId:${widget.idTTS}", context);

  //   var body = jsonDecode(response['body']);
  //   var content = [];
  //   if (response.containsKey("body")) {
  //     setState(() {
  //       currentPage = page + 1;
  //       content = body['content'];
  //       rowCount = body["totalElements"];
  //       totalElements = body["totalElements"];
  //       lastRow = totalElements;
  //     });
  //   }
  //   return content.map((e) {
  //     return QuaTrinhLamViec1.fromJson(e);
  //   }).toList();
  // }
  var rowPerPage = 10;
  var rowCount = 0;
  int currentPageDef = 1;

  Future<List<QuaTrinhLamViec1>> getNoiDungViPham(currentPage) async {
    var response = await httpGet("/api/tts-quatrinhlamviec/get/page?size=$rowPerPage&page=${currentPage - 1}&filter=ttsId:${widget.idTTS}", context);
    // var body = jsonDecode(response['body'])['content'] ?? [];
    var listTrainee = []; //Danh sách thực tập sinh
    if (response.containsKey("body")) {
      setState(() {
        // content = body['content'];
        listTrainee = jsonDecode(response['body'])['content'] ?? [];
        rowCount = jsonDecode(response['body'])['totalElements'];
        print(listTrainee);
      });
      return listTrainee.map((e) {
        return QuaTrinhLamViec1.fromJson(e);
      }).toList();
    } else {
      throw Exception("failse");
    }
  }

  Future<List<QuyDinh>> getDanhSachQuyDinh() async {
    var response;

    response = await httpGet("/api/quydinh/get/page", context);

    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      content = body['content'];
      setState(() {
        listQuyDinh = content.map((e) {
          return QuyDinh.fromJson(e);
        }).toList();
      });
    }
    return content.map((e) {
      return QuyDinh.fromJson(e);
    }).toList();
  }

  Future<List<PhongBans>> getDanhSachPhongBan() async {
    var response;

    response = await httpGet("/api/phongban/get/page", context);

    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      content = body['content'];
    }
    return content.map((e) {
      return PhongBans.fromJson(e);
    }).toList();
  }

  loadDataWhenSubmit() {
    setState(() {
      _setLoading = true;
    });

    Future<List<QuaTrinhLamViec1>> futureNoiDungViPham1 = getNoiDungViPham(1);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        futureNoiDungViPham = futureNoiDungViPham1;
        _setLoading = false;
      });
    });
  }

  List<QuyDinh> listQuyDinh = [];

  String getRuleNameQuyDinh(List<QuyDinh> listQuyDinh, int id) {
    for (int i = 0; i < listQuyDinh.length; i++) {
      print("thai" + listQuyDinh[i].id.toString());
      if (id.toString().trim() == listQuyDinh[i].id.toString().trim()) {
        print("sss");
        return listQuyDinh[i].ruleName;
      }
    }
    return "Không có dữ liệu";
  }

  bool loading = false;

  @override
  void initState() {
    futureNoiDungViPham = getNoiDungViPham(1);
    super.initState();
    initData();
  }

  initData() async {
    await getDanhSachQuyDinh();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: ScrollController(),
      children: [
        FutureBuilder<List<QuaTrinhLamViec1>>(
          future: futureNoiDungViPham,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              // int toolTipLength = MediaQuery.of(context).size.width < 1600 ? 33 : 60;
              var tableIndex = (currentPageDef - 1) * rowPerPage + 1;
              return Container(
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
                          'Quá trình làm việc tại nghiệp đoàn',
                          style: titleBox,
                        ),
                        Text(
                          'Tổng số quá trình: $rowCount',
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
                                        'Tên quy định',
                                        style: titleTableData,
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Nội dung phát sinh',
                                        style: titleTableData,
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Kết quả xử lý',
                                        style: titleTableData,
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Ngày phát sinh',
                                        style: titleTableData,
                                      ),
                                    ),
                                    DataColumn(
                                      label: Text(
                                        'Ngày xử lý',
                                        style: titleTableData,
                                      ),
                                    ),
                                  ],
                                  rows: <DataRow>[
                                    for (int i = 0; i < snapshot.data!.length; i++)
                                      DataRow(
                                        cells: <DataCell>[
                                          DataCell(Text("${tableIndex++}")),
                                          DataCell(Text(getRuleNameQuyDinh(listQuyDinh, snapshot.data![i].violateId!))),
                                          DataCell(Text(snapshot.data![i].issuedContent.toString())),
                                          DataCell(Text(snapshot.data![i].handleResult ?? "")),
                                          DataCell(Text(getDateView(snapshot.data![i].issuedDate))),
                                          DataCell(Text(getDateView(snapshot.data![i].handleDate))),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          DynamicTablePagging(rowCount, currentPageDef, rowPerPage, pageChangeHandler: (currentPage) {
                            setState(() {
                              futureNoiDungViPham = getNoiDungViPham(currentPage);
                              currentPageDef = currentPage;
                            });
                          }, rowPerPageChangeHandler: (rowPerPageChange) {
                            currentPageDef = 1;

                            rowPerPage = rowPerPageChange;
                            futureNoiDungViPham = getNoiDungViPham(currentPageDef);
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
    );
  }
}
