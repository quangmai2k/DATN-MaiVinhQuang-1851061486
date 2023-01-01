import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/model/market_development/lich_su_thi_tuyen.dart';
import 'package:gentelella_flutter/widgets/ui/market_development/9-list_trainees_recommendation/modal_confirm.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../../common/style.dart';
import '../../../../api.dart';

import '../../../../common/toast.dart';
import '../../../../model/market_development/order.dart';
import '../../../../model/market_development/tss_don_hang.dart';
import '../../../../model/model.dart';
// import '../../market_development/9-list_trainees_recommendation/9_stop_processing.dart';
import '../../market_development/9-list_trainees_recommendation/dungxuly.dart';
// import '9_stop_processing.dart';
// import 'dungxuly.dart';

class ModalDanhSachTTSSauTrungTuyen extends StatefulWidget {
  final int? idOreder;
  final Order order;
  ModalDanhSachTTSSauTrungTuyen({Key? key, this.idOreder, required this.order}) : super(key: key);

  @override
  State<ModalDanhSachTTSSauTrungTuyen> createState() => _ModalDanhSachTTSSauTrungTuyenState();
}

class _ModalDanhSachTTSSauTrungTuyenState extends State<ModalDanhSachTTSSauTrungTuyen> {
  final TextEditingController detail = TextEditingController();
  var listTtsDXL;
  var listTtsDXL1;

  void _showDungXuLyTam() {
    upDateTuChoiTts(String qcNote) async {
      String request = '';

      for (int i = 0; i < idList.length; i++) {
        if (idList[i] != null) {
          request += idList[i].toString();
          if (i < idList.length - 1) {
            request += ',';
          }
        }
      }
      if (idList.isEmpty) request = "0";
      var response = await httpGet("/api/donhang-tts-tiencu/get/page?filter=id in ($request)", context);

      dynamic data = {"qcApproval": 2, "qcNote": qcNote};
      dynamic data1 = {"isTts": 1, "ttsStatusId": 14};
      if (response.containsKey("body")) {
        setState(() {
          listTtsDXL = jsonDecode(response["body"])['content'];
        });
      }
      for (int j = 0; j < listTtsDXL.length; j++) {
        addNotification() async {
          try {
            var data = {
              "title": "Hệ thống thông báo",
              "message": 'Bộ phận Kiểm Soát từ chối TTS mã ' +
                  '${listTtsDXL[j]['nguoidung']['userCode']}' +
                  ' tiến cử vào đơn hàng ${listTtsDXL[j]['donhang']['orderCode']} lúc ${getDateViewDayAndHour(listTtsDXL[j]['createdDate'])}.',
            };
            await httpPost('/api/push/tags/depart_id/3', data, context);
          } catch (_) {
            print("Fail!");
          }
        }

        await addNotification();

        print("id cua tts: ${listTtsDXL[j]['ttsId']}");
        var response2 = await httpGet("/api/donhang-tts-tiencu/get/page?sort=id,desc&filter=ttsId:${listTtsDXL[j]['ttsId']} and qcApproval:0", context);
        var response3 = await httpPut("/api/nguoidung/put/${listTtsDXL[j]['ttsId']}", data1, context);

        if (response2.containsKey("body")) {
          listTtsDXL1 = jsonDecode(response2["body"])['content'];
          print("id la:");
        }
        for (int k = 0; k < listTtsDXL1.length; k++) {
          print("id thu $k");
          print(listTtsDXL1[k]['id'].toString());
          var response0 = await httpPut(Uri.parse('/api/donhang-tts-tiencu/put/${listTtsDXL1[k]['id']}'), data, context);
        }
      }
    }

    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter _setStateTuChoi) => AlertDialog(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                child: Image.asset('images/logoAAM.png'),
                                margin: EdgeInsets.only(right: 10),
                              ),
                              Text(
                                "Từ chối duyệt",
                                // widget.titleDialog,
                                style: titleAlertDialog,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // for (int i = 0; i < resultListNguoiDung.length; i++) idList.remove(resultListNguoiDung[i]["dhttsID"]);

                            setState(() {});
                            // idList.clear();
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.close),
                        ),
                      ],
                    ),
                    content: Container(
                      width: 400,
                      height: 200,
                      child: ListView(
                        children: [
                          Column(
                            children: [
                              Divider(
                                thickness: 1,
                              ),
                              // SizedBox(
                              //   height: 25,
                              // ),
                              Container(
                                height: 150,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                            flex: 3,
                                            child: Text(
                                              'Mô tả lý do',
                                              style: titleWidgetBox,
                                            )),
                                        Expanded(
                                          flex: 5,
                                          child: Container(
                                            // width: MediaQuery.of(context).size.width * 0.15,
                                            height: 60,
                                            child: TextField(
                                              controller: detail,
                                              // onChanged: (String? value) {
                                              //   detail.text = value!;
                                              // },
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    width: 3,
                                                    color: Colors.black,
                                                  ),
                                                  borderRadius: BorderRadius.circular(0.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Divider(
                                thickness: 1,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      ElevatedButton(
                        // textColor: Color(0xFF6200EE),
                        onPressed: () => Navigator.pop(context),
                        child: Text('Hủy'),
                        style: ElevatedButton.styleFrom(
                          primary: colorOrange,
                          onPrimary: colorWhite,
                          elevation: 3,
                          minimumSize: Size(140, 50),
                        ),
                      ),
                      Consumer<NavigationModel>(
                        builder: (context, navigationModel, child) => ElevatedButton(
                          // textColor: Color(0xFF6200EE),
                          onPressed: () async {
                            await upDateTuChoiTts(detail.text);

                            Navigator.pop(context);

                            await handleSearch();
                            detail.clear();
                            print("diep2");
                          },
                          child: Text(
                            'Xác nhận',
                            style: TextStyle(),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: colorBlueBtnDialog,
                            onPrimary: colorWhite,
                            // shadowColor: Colors.greenAccent,
                            elevation: 3,
                            // shape: RoundedRectangleBorder(
                            //     borderRadius: BorderRadius.circular(32.0)),
                            minimumSize: Size(140, 50), // HERE
                          ),
                        ),
                      )
                    ],
                  ));
        });
  }

  String getDateViewDayAndHour(String? date) {
    try {
      if (date == null) {
        return "Không có dữ liệu";
      }
      var inputFormat = DateFormat('yyyy-MM-ddThh:mm:ss');
      var inputDate = inputFormat.parse(date); // <-- dd/MM 24H format
      var outputFormat = DateFormat('HH:mm dd/MM/yyyy');
      var outputDate = outputFormat.format(inputDate);
      return outputDate;
    } catch (e) {}
    return "Không có dữ liệu";
  }

  var list;
  var list2;
  var idList = [];
  updateqcApproval() async {
    for (int i = 0; i < idList.length; i++) {
      print(idList);

      try {
        var data = {"qcApproval": 1};

        var response1 = await httpGet("/api/donhang-tts-tiencu/get/page?filter=id:${idList[i]}", context);
        if (response1.containsKey("body")) {
          list = jsonDecode(response1["body"])['content'];
        }
        for (int j = 0; j < list.length; j++) {
          print("id cua tts: ${list[j]['ttsId']}");
          var response2 = await httpGet("/api/donhang-tts-tiencu/get/page?sort=id,desc&filter=ttsId:${list[j]['ttsId']} and qcApproval:0", context);

          if (response2.containsKey("body")) {
            list2 = jsonDecode(response2["body"])['content'];
          }
          for (int k = 0; k < list2.length; k++) {
            print("id thu $k");
            print(list2[k]['id'].toString());
            // ignore: unused_local_variable
            var response0 = await httpPut(Uri.parse('/api/donhang-tts-tiencu/put/${list2[k]['id']}'), data, context);
          }
        }
      } catch (_) {
        print("Fail!");
      }
    }
  }

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
  @override
  void initState() {
    super.initState();
    futureListTTS = _showMaterialDialog(widget.idOreder, context);
  }

  List<TTSDonHang> listCheckTTSDonHangTienCu = []; // list check tích vào tts
  List<int> listTTSId = []; // list id TTS để truyền sang modal_confirm
  List<int> listTTSDonHang = []; // list id TTS đơn hàng để truyền sang modal_confirm
  List<int> listIdDonHangTtsTienCu = []; // list id TTS đơn hàng thực tập sinh tiến cử
  List<LichSuThiTuyen> listLichSuThiTuyen1 = [];
  Future<List<TTSDonHang>> _showMaterialDialog(idSelectedDonHang, context) async {
    List<dynamic> idTTSList = [];
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }

    var response1 = await httpGet(
        "/api/donhang-tts-tiencu/get/page?filter=orderId:$idSelectedDonHang AND nguoidung.ttsStatusId<12 and nguoidung.ttsStatusId>6 and (nguoidung.stopProcessing:0)",
        context);

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
          listIdDonHangTtsTienCu.add(content[i]['id']);
          listIdDonHangTtsTienCu.add(content[i]['nguoidung']['ttsStatusId']);
        }

        _selectedDataRow = List<bool>.generate(content.length, (int index) => false);
      });
      // listLichSuThiTuyen1 = await getLichSuThiTuyen(idTTSList, context);
      // setState(() {
      //   listLichSuThiTuyen = listLichSuThiTuyen1;
      // });
      print(listLichSuThiTuyen);
    }

    return content.map((e) {
      return TTSDonHang.fromJson(e);
    }).toList();
  }

  handleSearch() {
    setState(() {
      try {
        futureListTTS = _showMaterialDialog(widget.idOreder, context);
        futureListTTS.then((value) {
          listCheckTTSDonHangTienCu.clear();
        });
      } catch (e) {
        print("Lỗi tại đây" + e.toString());
      }
    });

    // Navigator.pop(context);
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
                        Text('Danh sách thực tập sinh sau khi trúng tuyển', style: titleBox),
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
                width: 900,
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
                                                  DataColumn(label: Text('Giới tính', style: titleTableData)),
                                                  DataColumn(label: Text('Trạng thái', style: titleTableData)),
                                                  DataColumn(
                                                    label: Text('Hành động', style: titleTableData),
                                                  ),
                                                ], rows: <DataRow>[
                                                  for (int i = 0; i < snapshot.data!.length; i++)
                                                    DataRow(
                                                      selected: _selectedDataRow[i],
                                                      onSelectChanged: (bool? selected) {
                                                        setState(() {
                                                          listCheckTTSDonHangTienCu.clear();
                                                          listTTSId.clear();
                                                          idList.clear();
                                                          _selectedDataRow[i] = selected!;
                                                          print(_selectedDataRow);
                                                          for (int j = 0; j < _selectedDataRow.length; j++) {
                                                            if (_selectedDataRow[j] == true) {
                                                              listCheckTTSDonHangTienCu.add(snapshot.data![j]);
                                                              listTTSId.add(snapshot.data![j].user!.id);
                                                              listTTSDonHang.add(snapshot.data![j].id);
                                                              idList.add(snapshot.data![j].id);
                                                            }
                                                          }

                                                          // print(listTTSId);
                                                          print(idList);
                                                        });
                                                      },
                                                      cells: <DataCell>[
                                                        DataCell(Text("${i + 1}")),
                                                        DataCell(
                                                          Text(snapshot.data![i].user!.userCode, style: bangDuLieu),
                                                        ),
                                                        DataCell(
                                                          Text(snapshot.data![i].user!.fullName, style: bangDuLieu),
                                                        ),
                                                        DataCell(
                                                          Text(snapshot.data![i].user!.gender == 1 ? "Nam" : "Nữ", style: bangDuLieu),
                                                        ),
                                                        DataCell(
                                                          Text(
                                                              (snapshot.data![i].user!.ttsStatusId == 7)
                                                                  ? "Đã trúng tuyển"
                                                                  : (snapshot.data![i].user!.ttsStatusId == 8)
                                                                      ? "Chờ đào tạo"
                                                                      : (snapshot.data![i].user!.ttsStatusId == 9)
                                                                          ? 'Đang đào tạo'
                                                                          : (snapshot.data![i].user!.ttsStatusId == 10)
                                                                              ? 'Chờ xuất cảnh'
                                                                              : (snapshot.data![i].user!.ttsStatusId == 11)
                                                                                  ? "Đã xuất cảnh"
                                                                                  : '',
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
              // Container(
              //     child: ElevatedButton(
              //   onPressed: listCheckTTSDonHangTienCu.length > 0
              //       ? () {
              //           _showDungXuLyTam();
              //           // handleSearch();
              //           //  print(listCheckTTSDonHangTienCu);
              //           //   showDialog(
              //           //       context: context,
              //           //       builder: ((BuildContext context) => DungXuLyDeXuatTienCu(
              //           //           titleDialog: 'Lý do từ chối', //header bảng trong cùng
              //           //           ttsId: null,
              //           //           donhangId: widget.idOreder,
              //           //           doituong: 0,
              //           //           listId: listTTSId,
              //           //           ListTTSDonHang: listCheckTTSDonHangTienCu,
              //           //           func: handleSearch,
              //           //           order: widget.order)));
              //         }
              //       : null,
              //   //nút bấm dừng xử lý
              //   child: Text(
              //     'Từ chối', // sau khi tích
              //     style: TextStyle(),
              //   ),
              //   style: ElevatedButton.styleFrom(
              //     primary: Color.fromRGBO(245, 117, 29, 1),
              //     onPrimary: Colors.white,
              //     elevation: 3,
              //     minimumSize: Size(140, 50), //////// HERE
              //   ),
              // )),
              // Container(
              //   child: ElevatedButton(
              //     onPressed: listCheckTTSDonHangTienCu.length > 0
              //         ? () async {
              //             // showDialog(
              //             //   context: context,
              //             //   builder: (BuildContext context) => ModelConfirm(
              //             //     label: "Bạn có chắc chắn muốn duyệt thực tập sinh này ?",
              //             //     idSelectedDonHang: widget.idOreder,
              //             //     listCheckTTSDonHangTienCu: listCheckTTSDonHangTienCu,
              //             //     func: handleSearch,
              //             //   ),
              //             // );

              //             await updateqcApproval();

              //             showToast(
              //               context: context,
              //               msg: "Duyệt đơn hàng thành công !",
              //               color: Colors.green,
              //               icon: const Icon(Icons.done),
              //             );
              //             for (int j = 0; j < list.length; j++) {
              //               addNotification() async {
              //                 try {
              //                   var data = {
              //                     "title": " Hệ thống thông báo",
              //                     "message": 'TTS có mã ' +
              //                         '${list[j]['nguoidung']['userCode']}' +
              //                         ' được đề xuất tiến cử vào đơn hàng ${list[j]['donhang']['orderCode']} lúc ${getDateViewDayAndHour(list[j]['createdDate'])}.',
              //                   };
              //                   await httpPost('/api/push/tags/depart_id/5', data, context);
              //                 } catch (_) {
              //                   print("Fail!");
              //                 }
              //               }

              //               await addNotification();
              //               handleSearch();
              //             }
              //           }
              //         : null,
              //     child: Text(
              //       'Duyệt',
              //       style: TextStyle(),
              //     ),
              //     style: ElevatedButton.styleFrom(
              //       primary: Color.fromRGBO(245, 117, 29, 1),
              //       onPrimary: Colors.white,
              //       minimumSize: Size(140, 50), //////// HERE
              //     ),
              //   ),
              // )
            ],
          );
        });
  }
}
