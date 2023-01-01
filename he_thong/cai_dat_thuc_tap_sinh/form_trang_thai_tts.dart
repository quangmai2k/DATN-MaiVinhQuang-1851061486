import 'dart:convert';


import 'package:flutter/material.dart';
import '../../../../api.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';

class QuyenTrangThai {
  String trangThai;
  bool form1 = false;
  bool form2 = false;
  bool form3 = false;
  QuyenTrangThai(this.trangThai);
}

enum Status { KichHoat, ChuaKichHoat }

class FormTrangThaiTTS extends StatefulWidget {
  const FormTrangThaiTTS({Key? key}) : super(key: key);

  @override
  State<FormTrangThaiTTS> createState() => _FormTrangThaiTTSState();
}

class _FormTrangThaiTTSState extends State<FormTrangThaiTTS> {
  var listStatus;
  var listStatusTable = [];
  late Future<dynamic> getListStatusFuture;
  getListStatus() async {
    var response = await httpGet("/api/tts-trangthai/get/page", context);
    if (response.containsKey("body")) {
      listStatus = jsonDecode(response["body"])['content'];
      listStatusTable = [];
      for (var row in listStatus) {
        listStatusTable.add({
          'id': row['id'],
          "statusName": TextEditingController(text: row["statusName"]),
          "active": row['active'] == 0 ? false : true,
          "updated": false
        });
      }
      return listStatusTable;
    } else
      throw Exception('False to load data');
  }

  String titleLog = 'Cập nhật dữ liệu thành công';
  updateStatusTts(id, active, name) async {
    var data = {"active": active, 'statusName': name};
    var response = await httpPut('/api/tts-trangthai/put/$id', data, context);
    if (response['body'] == "true") {
      print('Cập nhật dữ liệu thành công');
    } else {
      titleLog = 'Cập nhật thất bại';
    }
    return titleLog;
  }

  @override
  // ignore: must_call_super
  void initState() {
    getListStatusFuture = getListStatus();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: ScrollController(),
      child: Column(children: [
        Container(
          color: backgroundPage,
          padding: EdgeInsets.symmetric(
              vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
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
                      'Danh sách trạng thái thực tập sinh',
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
                Row(
                  children: [
                    Expanded(
                        child: FutureBuilder<dynamic>(
                      future: getListStatusFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return DataTable(
                              columnSpacing: 1,
                              showCheckboxColumn: false,
                              columns: [
                                DataColumn(
                                    label: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.03,
                                  child: Text(
                                    'STT',
                                    style: titleTableData,
                                  ),
                                )),
                                DataColumn(
                                    label: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.2,
                                  child: Text('Tên trạng thái',
                                      style: titleTableData),
                                )),
                                DataColumn(
                                    label: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                  child:
                                      Text('Kích hoạt', style: titleTableData),
                                )),
                                DataColumn(
                                    label: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                  child: Text('Không kích hoạt',
                                      style: titleTableData),
                                )),
                              ],
                              rows: <DataRow>[
                                for (var row in listStatusTable)
                                  DataRow(
                                    cells: [
                                      DataCell(Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.03,
                                          child: Text("${row['id']}"))),
                                      DataCell(Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        height: 40,
                                        child: TextField(
                                          decoration: InputDecoration(
                                              border: InputBorder.none),
                                          controller: row['statusName'],
                                          onSubmitted: (value) {},
                                        ),
                                      )),
                                      DataCell(ListTile(
                                        // title: const Text('Nam'),
                                        leading: Radio<bool>(
                                          value: true,
                                          groupValue: row['active'],
                                          onChanged: (bool? value) {
                                            setState(() {
                                              row['active'] = value;
                                              row['updated'] = true;
                                            });
                                          },
                                        ),
                                      )),
                                      DataCell(ListTile(
                                        // title: const Text('Nam'),
                                        leading: Radio<bool>(
                                          value: false,
                                          groupValue: row['active'],
                                          onChanged: (bool? value) {
                                            setState(() {
                                              row['active'] = value;
                                              row['updated'] = true;
                                            });
                                          },
                                        ),
                                      )),
                                    ],
                                  )
                              ]);
                        } else if (snapshot.hasError) {
                          return Text('${snapshot.error}');
                        }

                        // By default, show a loading spinner.
                        return Center(child: const CircularProgressIndicator());
                      },
                    )),
                  ],
                ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
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
                          textStyle: Theme.of(context)
                              .textTheme
                              .caption
                              ?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                        ),
                        onPressed: () async {
                          bool validated = true;
                          for (var row in listStatusTable) {
                            if (row['statusName'].text.isEmpty) {
                              validated = false;
                            }
                          }
                          if (validated == true) {
                            for (var row in listStatusTable) {
                              if (row['updated'] == true) {
                                await updateStatusTts(
                                    row['id'],
                                    row['active'] == true ? 1 : 0,
                                    row['statusName'].text);
                              }
                            }

                            getListStatusFuture = getListStatus();
                            showToast(
                              context: context,
                              msg: titleLog,
                              color: titleLog == "Cập nhật dữ liệu thành công"
                                  ? Color.fromARGB(136, 72, 238, 67)
                                  : Colors.red,
                              icon: titleLog == "Cập nhật dữ liệu thành công"
                                  ? Icon(Icons.done)
                                  : Icon(Icons.warning),
                            );
                          } else {
                            showToast(
                              context: context,
                              msg: 'Tên trạng thái không được để trống',
                              color: Colors.red,
                              icon: const Icon(Icons.warning),
                            );
                          }
                        },
                        child: Row(
                          children: [
                            Text('Lưu', style: textButton),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

class PhongBan {
  String name;
  bool view;
  bool add;
  bool edit;
  bool delete;
  PhongBan(this.name, this.view, this.add, this.edit, this.delete);
}

class TablePhongBan extends StatefulWidget {
  const TablePhongBan({Key? key}) : super(key: key);

  @override
  State<TablePhongBan> createState() => _TablePhongBanState();
}

class _TablePhongBanState extends State<TablePhongBan> {
  List<PhongBan> listPhongBan = [
    PhongBan('Nhân sự', true, true, true, false),
    PhongBan('Tuyển dụng', true, true, true, true),
    PhongBan('Đào tạo', true, true, true, false),
  ];
  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: [
        DataColumn(label: Text('Phòng ban', style: titleTableData)),
        DataColumn(label: Text('Xem', style: titleTableData)),
        DataColumn(label: Text('Thêm', style: titleTableData)),
        DataColumn(label: Text('Sửa', style: titleTableData)),
        DataColumn(label: Text('Xóa', style: titleTableData)),
      ],
      rows: [
        for (int i = 0; i < listPhongBan.length; i++)
          DataRow(cells: [
            DataCell(Text(listPhongBan[i].name)),
            DataCell(
              Checkbox(
                checkColor: Colors.white,
                value: listPhongBan[i].view,
                onChanged: (value) {
                  setState(() {
                    listPhongBan[i].view = value!;
                  });
                },
              ),
            ),
            DataCell(
              Checkbox(
                checkColor: Colors.white,
                value: listPhongBan[i].add,
                onChanged: (value) {
                  setState(() {
                    listPhongBan[i].add = value!;
                  });
                },
              ),
            ),
            DataCell(
              Checkbox(
                checkColor: Colors.white,
                value: listPhongBan[i].edit,
                onChanged: (value) {
                  setState(() {
                    listPhongBan[i].edit = value!;
                  });
                },
              ),
            ),
            DataCell(
              Checkbox(
                checkColor: Colors.white,
                value: listPhongBan[i].delete,
                onChanged: (value) {
                  setState(() {
                    listPhongBan[i].delete = value!;
                  });
                },
              ),
            ),
          ])
      ],
    );
  }
}
