import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/model/market_development/lich_su_thi_tuyen.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';
import 'package:gentelella_flutter/widgets/ui/market_development/9-list_trainees_recommendation/modal_confirm.dart';
import 'package:provider/provider.dart';

import '../../../../../common/style.dart';
import '../../../../api.dart';

import '../../../../model/market_development/order.dart';
import '../../../../model/market_development/tss_don_hang.dart';
import '../../../../model/model.dart';
import 'tuchoi.dart';
import 'dungxuly.dart';

class ModalDanhSachTTSTienCuDonHang extends StatefulWidget {
  final int? idOreder;
  final Order order;
  ModalDanhSachTTSTienCuDonHang({Key? key, this.idOreder, required this.order}) : super(key: key);

  @override
  State<ModalDanhSachTTSTienCuDonHang> createState() => _ModalDanhSachTTSTienCuDonHangState();
}

class _ModalDanhSachTTSTienCuDonHangState extends State<ModalDanhSachTTSTienCuDonHang> {
  var body = {};
  var page = 1;
  var rowPerPage = 5;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  var selectedDataTable = {};
  List<bool> _selectedDataRow = [];
  List<LichSuThiTuyen> listLichSuThiTuyen = [];
  late Future<List<TTSDonHang>> futureListTTS;

  List<TTSDonHang> listTTSDonHangObject = [];
  @override
  void initState() {
    super.initState();
    futureListTTS = _showMaterialDialog(widget.idOreder, context);
  }

  List<TTSDonHang> listCheckTTSDonHangTienCu = []; // list check tích vào tts
  List<int> listTTSId = []; // list id TTS để truyền sang modal_confirm
  List<int> listTTSDonHang = []; // list id TTS đơn hàng để truyền sang modal_confirm
  List<int> listIdDonHangTtsTienCu = []; // list id TTS đơn hàng thực tập sinh tiến cử

  Future<List<TTSDonHang>> _showMaterialDialog(idSelectedDonHang, context) async {
    await httpDelete("/api/donhang-tts-tiencu/del/all?filter=qcApproval:0 and ptttApproval:0 and nguoidung.isTts:1  and nguoidung.ttsStatusId in (13,14)", context);

    List<dynamic> idTTSList = [];
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }

    var response1 = await httpGet("/api/donhang-tts-tiencu/get/page?sort=id,desc&filter=orderId:$idSelectedDonHang and qcApproval:1 and nguoidung.isTts:1 ", context);

    var body = jsonDecode(response1['body']);

    var content = [];
    List<TTSDonHang> listTtsDonHangTemp = [];
    if (response1.containsKey("body")) {
      setState(() {
        listTTSDonHangObject.clear();
        currentPage = page + 1;
        content = body['content'];
        rowCount = body["totalElements"];
        totalElements = body["totalElements"];
        lastRow = totalElements;
        listTtsDonHangTemp = content.map((e) {
          return TTSDonHang.fromJson(e);
        }).toList();

        Map<int, TTSDonHang> map = new Map();
        for (var item in listTtsDonHangTemp) {
          if (!map.containsKey(item.user!.id)) {
            idTTSList.add(item.user!.id);
            map.putIfAbsent(item.user!.id, () => item);
          } else {
            DateTime dateTimeTtsInMap = DateTime.parse(map[item.user!.id]!.createdDate.toString());
            DateTime dateTimeTtsNew = DateTime.parse(item.createdDate.toString());
            if (dateTimeTtsInMap.isBefore(dateTimeTtsNew)) {
              map[item.user!.id] = item;
            }
          }
        }
        listTTSDonHangObject.addAll(map.values);
        _selectedDataRow = List<bool>.generate(listTTSDonHangObject.length, (int index) => false);
      });
      listLichSuThiTuyen = await getLichSuThiTuyen(idTTSList, context);
      // setState(() {
      //   listLichSuThiTuyen = listLichSuThiTuyen1;
      // });
      // print(listLichSuThiTuyen);
    }

    return content.map((e) {
      return TTSDonHang.fromJson(e);
    }).toList();
  }

  String getExamTimeByTtsId(int idTTS, int idOrder, List<LichSuThiTuyen> list) {
    for (int i = 0; i < list.length; i++) {
      try {
        if (idTTS == list[i].ttsId && idOrder == list[i].orderId) {
          return list[i].examTimes.toString();
        }
      } catch (e) {
        print(e);
      }
    }
    return "0";
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

  handleSearch() async {
    setState(() {
      try {
        listCheckTTSDonHangTienCu.clear();
      } catch (e) {
        print("Lỗi tại đây" + e.toString());
      }
      futureListTTS = _showMaterialDialog(widget.idOreder, context);
    });

    // Navigator.pop(context);
  }

  getStatus(stopProcessing, status, ptttAproval) {
    if (ptttAproval == 2) {
      return "Từ chối";
    }
    if (ptttAproval == 0) {
      return "Chờ duyệt";
    }
    if (ptttAproval == 1) {
      return "Đã duyệt";
    }
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
    return FutureBuilder<List<TTSDonHang>>(
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
                      children: [
                        Text('Danh sách thực tập sinh đề xuất tiến cử', style: titleBox),
                      ],
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // btnDungXuLy.button = false;
                  },
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            //Bảng chot ds
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
                              child: ListView(
                                padding: const EdgeInsets.all(16),
                                children: [
                                  LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
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
                                                  for (int i = 0; i < listTTSDonHangObject.length; i++)
                                                    DataRow(
                                                      selected: _selectedDataRow[i],
                                                      onSelectChanged: listTTSDonHangObject[i].user!.status!.id == 4 &&
                                                              listTTSDonHangObject[i].ptttApproval == 0 &&
                                                              listTTSDonHangObject[i].ptttApproval != 2 &&
                                                              listTTSDonHangObject[i].user!.stopProcessing != 1
                                                          ? (bool? selected) {
                                                              setState(() {
                                                                listCheckTTSDonHangTienCu.clear();
                                                                listTTSId.clear();
                                                                _selectedDataRow[i] = selected!;
                                                                print(_selectedDataRow);
                                                                for (int j = 0; j < _selectedDataRow.length; j++) {
                                                                  if (_selectedDataRow[j] == true) {
                                                                    listCheckTTSDonHangTienCu.add(listTTSDonHangObject[j]);
                                                                    listTTSId.add(listTTSDonHangObject[j].user!.id);
                                                                    listTTSDonHang.add(listTTSDonHangObject[j].id);
                                                                  }
                                                                }
                                                                print(listTTSId);
                                                              });
                                                            }
                                                          : null,
                                                      cells: <DataCell>[
                                                        DataCell(Text("${i + 1}")),
                                                        DataCell(
                                                          Text(listTTSDonHangObject[i].user!.userCode, style: bangDuLieu),
                                                        ),
                                                        DataCell(
                                                          Text(listTTSDonHangObject[i].user!.fullName, style: bangDuLieu),
                                                        ),
                                                        DataCell(
                                                          Text(getDateView(listTTSDonHangObject[i].user!.birthDate), style: bangDuLieu),
                                                        ),
                                                        DataCell(
                                                          Text(listTTSDonHangObject[i].user!.gender == 1 ? "Nam" : "Nữ", style: bangDuLieu),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                              getStatus(listTTSDonHangObject[i].user!.stopProcessing, listTTSDonHangObject[i].user!.status!.id,
                                                                      listTTSDonHangObject[i].ptttApproval)
                                                                  .toString(),
                                                              style: bangDuLieu),
                                                        ),
                                                        DataCell(
                                                          Text(getExamTimeByTtsId(listTTSDonHangObject[i].user!.id, listTTSDonHangObject[i].orderID!, listLichSuThiTuyen),
                                                              style: bangDuLieu),
                                                        ),
                                                        DataCell(
                                                          Row(
                                                            children: [
                                                              Container(
                                                                  child: InkWell(
                                                                      onTap: () {
                                                                        Provider.of<NavigationModel>(context, listen: false)
                                                                            .add(pageUrl: "/view-thong-tin-thuc-tap-sinh/${snapshot.data![i].user!.id}");
                                                                      },
                                                                      child: Icon(Icons.visibility))),
                                                            ],
                                                          ),
                                                        ),
                                                        //
                                                      ],
                                                    ),
                                                ]))));
                                  }),
                                ],
                              ),
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
            actions: [
              Container(
                  child: ElevatedButton(
                onPressed: listCheckTTSDonHangTienCu.length > 0
                    ? () {
                        showDialog(
                            context: context,
                            builder: ((BuildContext context) => ModalDungXuLy(
                                  titleDialog: 'Lý do dừng xử lý', //header bảng trong cùng
                                  ttsId: null,
                                  donhangId: widget.idOreder,
                                  doituong: 0,
                                  listId: listTTSId,
                                  ListTTSDonHang: listCheckTTSDonHangTienCu,
                                  func: handleSearch,
                                )));
                      }
                    : null,
                //nút bấm dừng xử lý
                child: Text(
                  'Dừng xử lý', // sau khi tích
                  style: TextStyle(),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromRGBO(245, 117, 29, 1),
                  onPrimary: Colors.white,
                  elevation: 3,
                  minimumSize: Size(140, 50), //////// HERE
                ),
              )),
              Container(
                  child: ElevatedButton(
                onPressed: listCheckTTSDonHangTienCu.length > 0
                    ? () {
                        print(listCheckTTSDonHangTienCu);
                        showDialog(
                            context: context,
                            builder: ((BuildContext context) => DungXuLyDeXuatTienCu(
                                titleDialog: 'Lý do từ chối', //header bảng trong cùng
                                ttsId: null,
                                donhangId: widget.idOreder,
                                doituong: 0,
                                listId: listTTSId,
                                ListTTSDonHang: listCheckTTSDonHangTienCu,
                                func: handleSearch,
                                order: widget.order)));
                      }
                    : null,
                //nút bấm dừng xử lý
                child: Text(
                  'Từ chối', // sau khi tích
                  style: TextStyle(),
                ),
                style: ElevatedButton.styleFrom(
                  primary: Color.fromRGBO(245, 117, 29, 1),
                  onPrimary: Colors.white,
                  elevation: 3,
                  minimumSize: Size(140, 50), //////// HERE
                ),
              )),
              Container(
                child: ElevatedButton(
                  onPressed: listCheckTTSDonHangTienCu.length > 0
                      ? () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => ModelConfirm(
                              label: "Bạn có chắc chắn muốn duyệt thực tập sinh này ?",
                              idSelectedDonHang: widget.idOreder,
                              listCheckTTSDonHangTienCu: listCheckTTSDonHangTienCu,
                              func: handleSearch,
                              order: widget.order,
                            ),
                          );
                        }
                      : null,
                  child: Text(
                    'Duyệt',
                    style: TextStyle(),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromRGBO(245, 117, 29, 1),
                    onPrimary: Colors.white,
                    minimumSize: Size(140, 50), //////// HERE
                  ),
                ),
              )
            ],
          );
        });
  }
}
