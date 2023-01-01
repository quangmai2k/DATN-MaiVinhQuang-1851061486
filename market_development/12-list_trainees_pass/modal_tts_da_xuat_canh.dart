import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/model/market_development/user.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';
import 'package:gentelella_flutter/widgets/ui/market_development/12-list_trainees_pass/modal_confirm.dart';
import 'package:gentelella_flutter/widgets/ui/market_development/12-list_trainees_pass/stopprocessing.dart';
import 'package:provider/provider.dart';
import '../../../../../common/style.dart';
import '../../../../api.dart';
import '../../../../model/market_development/order.dart';
import '../../../../model/model.dart';

class ModalDanhSachTTSDaXuatCanh extends StatefulWidget {
  final int? idOreder;
  final Function? function;
  final Order order;
  ModalDanhSachTTSDaXuatCanh({Key? key, this.idOreder, this.function, required this.order}) : super(key: key);

  @override
  State<ModalDanhSachTTSDaXuatCanh> createState() => _ModalDanhSachTTSDaXuatCanhState();
}

class _ModalDanhSachTTSDaXuatCanhState extends State<ModalDanhSachTTSDaXuatCanh> {
  var body = {};
  var page = 1;
  var rowPerPage = 5;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  var selectedDataTable = {};
  List<bool> _selectedDataRow = [];
  List<bool> listSelected = [];
  @override
  void initState() {
    super.initState();

    futureListTTS = _showMaterialDialog(widget.idOreder, context);
  }

//list TTSDonHang
  List<User> listCheckTTSDonHang = [];

  //list TTSDonHang
  List<User> listCheckTTSDonHangAllThuocDonHang = [];
  // List<User> listUser
  late Future<List<User>> futureListTTS;
//end list TTSDonHang

  List<int> listTTSId = [];
  String? url = "/danh-sach-tts-da-xuat-canh";
  List<int> listTTSDonHang = [];

  Future<List<User>> _showMaterialDialog(idSelectedDonHang, context) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }

    var response1 =
        await httpGet("/api/nguoidung/get/page?filter=orderId:$idSelectedDonHang and isTts:1 and ttsStatusId:11 and (stopProcessing:0 or stopProcessing is null )", context);

    var body = jsonDecode(response1['body']);
    var content = [];
    if (response1.containsKey("body")) {
      setState(() {
        currentPage = page + 1;
        content = body['content'];
        rowCount = body["totalElements"];
        totalElements = body["totalElements"];
        lastRow = totalElements;
//check click danh sasch cac o checkbox
        _selectedDataRow = List<bool>.generate(content.length, (int index) => false);
//ket thuc check click danh sasch cac o checkbox
      });
    }
    return content.map((e) {
      return User.fromJson(e);
    }).toList();
  }

  closePopup() {
    setState(() {
      listCheckTTSDonHang.clear();
      futureListTTS = _showMaterialDialog(widget.idOreder, context);
    });

    widget.function!();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<User>>(
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
                      children: [Text('Danh sách thực tập sinh đã xuất cảnh', style: titleBox), Text("")],
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
                                  DataTable(showCheckboxColumn: true, columnSpacing: 20, columns: [
                                    DataColumn(label: Text('STT', style: titleTableData)),
                                    DataColumn(label: Text('Mã TTS', style: titleTableData)),
                                    DataColumn(label: Text('Họ tên TTS', style: titleTableData)),
                                    DataColumn(label: Text('Giới tính', style: titleTableData)),
                                    DataColumn(label: Text('Ngày sinh', style: titleTableData)),
                                    DataColumn(label: Text('Ngày xuất cảnh', style: titleTableData)),
                                    DataColumn(
                                      label: Text('Hành động', style: titleTableData),
                                    ),
                                  ], rows: <DataRow>[
                                    for (int i = 0; i < snapshot.data!.length; i++)
                                      DataRow(
                                        selected: _selectedDataRow[i],
                                        onSelectChanged: (bool? selected) {
                                          setState(() {
                                            listCheckTTSDonHang.clear();
                                            _selectedDataRow[i] = selected!;
                                            for (int j = 0; j < _selectedDataRow.length; j++) {
                                              if (_selectedDataRow[j]) {
                                                listCheckTTSDonHang.add(snapshot.data![j]);
                                                listTTSId.add(snapshot.data![j].id);
                                                listTTSDonHang.add(snapshot.data![j].id);
                                              }
                                            }

                                            print(listCheckTTSDonHang);
                                            print(snapshot.data![i].id);
                                          });
                                        },
                                        cells: <DataCell>[
                                          DataCell(Text("${i + 1}")),
                                          DataCell(
                                            Text(snapshot.data![i].userCode, style: bangDuLieu),
                                          ),
                                          DataCell(
                                            Text(snapshot.data![i].fullName, style: bangDuLieu),
                                          ),
                                          DataCell(
                                            Text(snapshot.data![i].gender == 0 ? "Nam" : "Nữ", style: bangDuLieu),
                                          ),
                                          DataCell(
                                            Text(getDateView(snapshot.data![i].birthDate), style: bangDuLieu),
                                          ),
                                          DataCell(
                                            Text(snapshot.data![i].departureDate != null ? getDateView(snapshot.data![i].departureDate) : "Không có dữ liệu", style: bangDuLieu),
                                          ),
                                          DataCell(Row(
                                            children: [
                                              Container(
                                                  child: InkWell(
                                                      onTap: () {
                                                        Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/view-thong-tin-thuc-tap-sinh/${snapshot.data![i].id}");
                                                      },
                                                      child: Icon(Icons.visibility))),
                                            ],
                                          )),
                                          //
                                        ],
                                      ),
                                  ]),
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
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                      margin: EdgeInsets.fromLTRB(400, 0, 10, 0),
                      child: ElevatedButton(
                        onPressed: listCheckTTSDonHang.length > 0
                            ? () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) => ModelConfirm12(
                                    label: "Bạn có chắc chắn thực tập sinh này đã hoàn thành ?",
                                    listTts: listCheckTTSDonHang,
                                    url: url,
                                    orderId: widget.idOreder,
                                    func: closePopup,
                                  ),
                                );
                              }
                            : null,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Xác nhận hoàn thành',
                              style: TextStyle(),
                            ),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromRGBO(245, 117, 29, 1),
                          onPrimary: Colors.white,
                          minimumSize: Size(140, 50), //////// HERE
                        ),
                      )),
                  ElevatedButton(
                    onPressed: listCheckTTSDonHang.length > 0
                        ? () {
                            showDialog(
                                context: context,
                                builder: ((BuildContext context) => Stopprocessing12(
                                      titleDialog: 'Lý do', //header bảng trong cùng
                                      listTts: listCheckTTSDonHang,
                                      func: closePopup,
                                      orderId: widget.idOreder,
                                    )));
                          }
                        : null,
                    //nút bấm dừng xử lý
                    child: Text(
                      'Dừng xử lý',
                      style: TextStyle(),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromRGBO(245, 117, 29, 1),
                      onPrimary: Colors.white,
                      elevation: 3,
                      minimumSize: Size(140, 50), //////// HERE
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }
}
