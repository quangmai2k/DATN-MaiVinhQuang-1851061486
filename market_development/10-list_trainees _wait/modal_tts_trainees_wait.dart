import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/model/market_development/lich_su_thi_tuyen.dart';

import 'package:gentelella_flutter/widgets/ui/market_development/10-list_trainees%20_wait/modal_tts_cho_thi_tuyen_stopprocessing.dart';
import 'package:provider/provider.dart';
import '../../../../../common/style.dart';
import '../../../../api.dart';

import '../../../../model/market_development/order.dart';
import '../../../../model/market_development/tss_don_hang.dart';
import '../../../../model/model.dart';
import '../../../forms/market_development/utils/funciton.dart';

class ModalDanhSachTTSChoThiTuyen extends StatefulWidget {
  final int? idOreder;
  final Order order;
  ModalDanhSachTTSChoThiTuyen({Key? key, this.idOreder, required this.order}) : super(key: key);

  @override
  State<ModalDanhSachTTSChoThiTuyen> createState() => _ModalDanhSachTTSChoThiTuyenState();
}

class _ModalDanhSachTTSChoThiTuyenState extends State<ModalDanhSachTTSChoThiTuyen> {
  var body = {};
  var page = 1;
  var rowPerPage = 5;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  var selectedDataTable = {};
  List<bool> _selectedDataRow = [];
  List<LichSuThiTuyen> listLichSuThiTuyenSelected = [];
  late Future<List<LichSuThiTuyen>> futureListTTS;
  @override
  void initState() {
    super.initState();
    futureListTTS = _showMaterialDialog(widget.idOreder, context);
  }

  List<TTSDonHang> listCheckTTSDonHang = [];
  List<int> listTTSId = [];
  List<int> listTTSDonHang = [];

  List<LichSuThiTuyen> getListLichSuThiTuyenByExamTime(List<LichSuThiTuyen> listLichSuThiTuyen) {
    List<LichSuThiTuyen> listLichSuThiTuyenResult = [];
    Map<int, LichSuThiTuyen> mapLichSuThiTuyen = {};
    for (int i = 0; i < listLichSuThiTuyen.length; i++) {
      if (!mapLichSuThiTuyen.containsKey(listLichSuThiTuyen[i].ttsId)) {
        mapLichSuThiTuyen.putIfAbsent(listLichSuThiTuyen[i].ttsId!, () => listLichSuThiTuyen[i]);
      } else {
        if (mapLichSuThiTuyen[listLichSuThiTuyen[i].ttsId]!.examTimes! < listLichSuThiTuyen[i].examTimes! && listLichSuThiTuyen[i].examResult! > 0) {
          mapLichSuThiTuyen[listLichSuThiTuyen[i].ttsId!] = listLichSuThiTuyen[i];
        }
      }
    }
    if (mapLichSuThiTuyen.isNotEmpty) {
      listLichSuThiTuyenResult.addAll(mapLichSuThiTuyen.values);
    }

    for (var item in listLichSuThiTuyenResult) {
      print("${item.user!.fullName}  -- ${item.examTimes} ");
    }
    // print(listLichSuThiTuyenResult);
    return listLichSuThiTuyenResult;
  }

  Future<List<LichSuThiTuyen>> _showMaterialDialog(idSelectedDonHang, context) async {
    List<dynamic> idTTSList = [];
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    // String condition = "";

    // var response1 = await httpGet(
    //     "/api/tts-lichsu-thituyen/get/page?filter=orderId:$idSelectedDonHang and thuctapsinh.ttsStatusId:6 and (thuctapsinh.stopProcessing:0 or thuctapsinh.stopProcessing is null ) and thuctapsinh.isTts:1",
    //     context);

    var response1 = await httpGet("/api/tts-lichsu-thituyen/get/page?filter=orderId:$idSelectedDonHang and thuctapsinh.isTts:1", context);

    var body = jsonDecode(response1['body']);

    var content = [];
    if (response1.containsKey("body")) {
      setState(() {
        currentPage = page + 1;
        content = body['content'];
        rowCount = body["totalElements"];
        totalElements = body["totalElements"];
        lastRow = totalElements;

        for (int i = 0; i < content.length; i++) {
          idTTSList.add(content[i]['ttsId']);
        }

        _selectedDataRow = List<bool>.generate(content.length, (int index) => false);
      });
    }
    return getListLichSuThiTuyenByExamTime(content.map((e) {
      return LichSuThiTuyen.fromJson(e);
    }).toList());
  }

  Future<List<LichSuThiTuyen>> getLichSuThiTuyen(List<dynamic> idTTSList, context) async {
    String condition = "";
    if (idTTSList.isNotEmpty) {
      for (int i = 0; i < idTTSList.length; i++) {
        if (i == 0) {
          condition += "${idTTSList[i]}";
        } else {
          condition += ",${idTTSList[i]}";
        }
      }
    } else {
      return [];
    }

    var response = await httpGet("/api/tts-lichsu-thituyen/get/page?filter=ttsId in($condition) ", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
      });
    }
    return content.map((e) {
      return LichSuThiTuyen.fromJson(e);
    }).toList();
  }

  handleSearch() {
    setState(() {
      listLichSuThiTuyenSelected.clear();
      futureListTTS = _showMaterialDialog(widget.idOreder, context);
    });

    // Navigator.pop(context);
  }

  getStatus(stopProcessing, status) {
    if (stopProcessing == 1) {
      return "Tạm dừng xử lý";
    }
    if (status == 4) {
      return "Đề xuất tiến cử";
    }
    if (status == 5) {
      return "Đã tiến cử";
    }
    if (status == 6) {
      return "Chờ thi tuyển";
    }
    if (status == 7) {
      return "Đã trúng tuyển";
    }
    if (status == 8) {
      return "Chờ đào tạo";
    }
    if (status == 9) {
      return "Đang đào tạo";
    }
    if (status == 10) {
      return "Chờ xuất cảnh";
    }
    if (status == 11) {
      return "Đã xuất cảnh";
    }
    if (status == 12) {
      return "Đã hoàn thành";
    }
    if (status == 13) {
      return "Dừng xử lý";
    }
    if (status == 14) {
      return "Chờ tiến cử lại";
    }
    if (status == 15) {
      return "Dự bị";
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<LichSuThiTuyen>>(
        future: futureListTTS,
        builder: (context, snapshot) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      child: Image.asset('assets/images/logoAAM.png'),
                      margin: EdgeInsets.only(right: 10),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [Text('Danh sách thực tập sinh chờ thi tuyển', style: titleBox), Text("")],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            content: Container(
                width: 1200,
                height: 400,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        child: Text(
                          widget.order.orderName.toString(),
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
                        ),
                      ),
                      Container(
                        margin: marginTopBottomHorizontalLine,
                        child: Divider(
                          thickness: 1,
                          color: ColorHorizontalLine,
                        ),
                      ),
                      if (snapshot.hasData)
                        Column(
                          children: [
                            Container(
                              height: 350,
                              child: ListView(padding: const EdgeInsets.all(16), children: [
                                LayoutBuilder(builder: (context, BoxConstraints constraints) {
                                  return Center(
                                      child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: ConstrainedBox(
                                              constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                              child: DataTable(showCheckboxColumn: true, columnSpacing: 20, columns: [
                                                DataColumn(label: Text('STT', style: titleTableData)),
                                                DataColumn(label: Text('Mã TTS', style: titleTableData)),
                                                DataColumn(label: Text('Họ tên TTS', style: titleTableData)),
                                                DataColumn(label: Text('Ngày sinh', style: titleTableData)),
                                                DataColumn(label: Text('Giới tính', style: titleTableData)),
                                                DataColumn(label: Text('Trạng thái', style: titleTableData)),
                                                DataColumn(label: Text('Số lần thi tuyển', style: titleTableData)),
                                                DataColumn(
                                                  label: Text('Hành động', style: titleTableData),
                                                ),
                                              ], rows: <DataRow>[
                                                for (int i = 0; i < snapshot.data!.length; i++)
                                                  DataRow(
                                                    selected: _selectedDataRow[i],
                                                    onSelectChanged: snapshot.data![i].user!.status!.id == 6 && snapshot.data![i].user!.stopProcessing != 1
                                                        ? (bool? selected) {
                                                            setState(() {
                                                              listCheckTTSDonHang.clear();
                                                              listLichSuThiTuyenSelected.clear();
                                                              _selectedDataRow[i] = selected!;

                                                              for (int j = 0; j < _selectedDataRow.length; j++) {
                                                                if (_selectedDataRow[j]) {
                                                                  listLichSuThiTuyenSelected.add(snapshot.data![j]);
                                                                  listTTSId.add(snapshot.data![j].user!.id);
                                                                  listTTSDonHang.add(snapshot.data![j].id);
                                                                }
                                                              }
                                                            });
                                                          }
                                                        : null,
                                                    cells: <DataCell>[
                                                      DataCell(Text("${i + 1}")),
                                                      DataCell(
                                                        Text(snapshot.data![i].user!.userCode, style: bangDuLieu),
                                                      ),
                                                      DataCell(
                                                        Text(snapshot.data![i].user!.fullName, style: bangDuLieu),
                                                      ),
                                                      DataCell(
                                                        Text(getDateView(snapshot.data![i].user!.birthDate), style: bangDuLieu),
                                                      ),
                                                      DataCell(
                                                        Text(snapshot.data![i].user!.gender == 1 ? "Nam" : "Nữ", style: bangDuLieu),
                                                      ),
                                                      DataCell(
                                                        Text(getStatus(snapshot.data![i].user!.stopProcessing, snapshot.data![i].user!.status!.id).toString(), style: bangDuLieu),
                                                      ),
                                                      DataCell(
                                                        Text(snapshot.data![i].examTimes.toString(), style: bangDuLieu),
                                                      ),
                                                      DataCell(Row(
                                                        children: [
                                                          Container(
                                                              child: InkWell(
                                                                  onTap: () {
                                                                    Provider.of<NavigationModel>(context, listen: false)
                                                                        .add(pageUrl: "/view-thong-tin-thuc-tap-sinh/${snapshot.data![i].user!.id}");
                                                                  },
                                                                  child: Icon(Icons.visibility))),
                                                        ],
                                                      )),
                                                      //
                                                    ],
                                                  ),
                                              ]))));
                                }),
                              ]),
                            ),
                            Container()
                          ],
                        )
                      else if (snapshot.hasError)
                        Text('${snapshot.error}')
                      else
                        const Center(child: CircularProgressIndicator())
                    ],
                  ),
                )),
            actions: <Widget>[
              Container(
                  child: ElevatedButton(
                onPressed: listLichSuThiTuyenSelected.length > 0
                    ? () {
                        showDialog(
                            context: context,
                            builder: ((BuildContext context) => DungXuLyChoThiTuyen(
                                  titleDialog: 'Lý do',
                                  ttsId: null,
                                  donhangId: widget.idOreder,
                                  doituong: 0,
                                  listId: listTTSId,
                                  listLichSuThiTuyen: listLichSuThiTuyenSelected,
                                  func: handleSearch,
                                )));
                      }
                    : null,
                child: Text(
                  'Dừng xử lý',
                  style: TextStyle(),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromRGBO(245, 117, 29, 1),
                  onPrimary: Colors.white,
                  elevation: 3,
                  minimumSize: Size(140, 50),
                ),
              ))
            ],
          );
        });
  }
}
