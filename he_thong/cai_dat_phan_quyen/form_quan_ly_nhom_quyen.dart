import 'dart:convert';

import 'package:flutter/material.dart';
import "package:collection/collection.dart";

import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';

import '../../../../common/style.dart';
import '../../../forms/market_development/utils/funciton.dart';

class FormQuanLyNhomQuyen extends StatefulWidget {
  const FormQuanLyNhomQuyen({Key? key}) : super(key: key);

  @override
  State<FormQuanLyNhomQuyen> createState() => _FormQuanLyNhomQuyenState();
}

class _FormQuanLyNhomQuyenState extends State<FormQuanLyNhomQuyen> {
  var listRole;
  late int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 10;
  late Future<dynamic> getRoleFuture;
  var listRoleGroup = [];
  var listCheckUpdate = [];
  getRole() async {
    var response = await httpGet(
        "/api/nhomquyen/get/page?filter=roleName!'Admin'", context);
    if (response.containsKey("body")) {
      listRole = jsonDecode(response["body"])['content'];
      setState(() {});
      return listRole;
    } else
      throw Exception("Error load data");
  }

  bool isNumber(String string) {
    try {
      int.parse(string);
      return true;
    } catch (e) {
      return false;
    }
  }

  String titleLog = 'Cập nhật dữ liệu thành công';

  @override
  void initState() {
    getRoleFuture = getRole();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int index = 1;
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            color: backgroundPage,
            padding: EdgeInsets.symmetric(
                vertical: verticalPaddingPage,
                horizontal: horizontalPaddingPage),
            child: Container(
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
                      'Nhập thông tin ',
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
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //   children: [
                //     Expanded(
                //         flex: 7,
                //         child: Row(
                //           children: [
                //             Expanded(
                //               flex: 7,
                //               child: TextFieldValidatedForm(
                //                   flexLable: 2,
                //                   type: 'None',
                //                   label: 'Tên chức năng',
                //                   controller: moduleName,
                //                   height: 40),
                //             ),
                //           ],
                //         )),
                //     SizedBox(
                //       width: 100,
                //     ),
                //     Expanded(
                //         flex: 10,
                //         child: Container(
                //           margin: EdgeInsets.only(bottom: 30),
                //           child: DropdownBtnSearch(
                //             isAll: true,
                //             flexLabel: 3,
                //             label: 'Trạng thái',
                //             listItems: itemsStatus,
                //             isSearch: false,
                //             selectedValue: selectedStatus,
                //             setSelected: (selected) {
                //               selectedStatus = selected;
                //               setState(() {});
                //             },
                //           ),
                //         )),
                //   ],
                // ),
                SizedBox(
                  height: 25,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      child: TextButton.icon(
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
                              ?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                        ),
                        onPressed: () {
                          // getListFeature = getFeature();
                        },
                        icon: Transform.rotate(
                          angle: 270,
                          child: Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 15,
                          ),
                        ),
                        label: Row(
                          children: [
                            Text('Tìm kiếm ', style: textButton),
                          ],
                        ),
                      ),
                    ),
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
                              ?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) => ThemMoiNhomQuyen(
                              titleDialog: 'Thêm mới nhóm quyền',
                              function: () {
                                getRoleFuture = getRole();
                              },
                            ),
                          );
                        },
                        child: Row(
                          children: [
                            Text('Thêm mới', style: textButton),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Danh sách nhóm quyền',
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
                FutureBuilder<dynamic>(
                  future: getRoleFuture,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DataTable(
                                    showCheckboxColumn: false,
                                    columnSpacing:
                                        MediaQuery.of(context).size.width < 1600
                                            ? 10
                                            : 15,
                                    columns: [
                                      DataColumn(
                                          label: Text(
                                        'STT',
                                        style: titleTableData,
                                      )),
                                      DataColumn(
                                          label: Text('Mã nhóm quyền',
                                              style: titleTableData)),
                                      DataColumn(
                                          label: Text('Tên nhóm quyền',
                                              style: titleTableData)),
                                      DataColumn(
                                          label: Text('Mô tả',
                                              style: titleTableData)),
                                      DataColumn(
                                          label: Text('Trạng thái',
                                              style: titleTableData)),
                                      DataColumn(
                                          label: Text('Hành động',
                                              style: titleTableData)),
                                    ],
                                    rows: <DataRow>[
                                      for (var row in listRole)
                                        DataRow(
                                            // selected: users[i].selected,
                                            // onSelectChanged: (value) {
                                            //   setState(() {
                                            //     users[i].selected = value!;
                                            //     if (users[i].selected) {
                                            //       listSelectedRow.add(users[i]);
                                            //     } else {
                                            //       listSelectedRow.remove(users[i]);
                                            //     }
                                            //   });
                                            // },
                                            cells: <DataCell>[
                                              DataCell(
                                                Text('${index++}',
                                                    style: bangDuLieu),
                                              ),
                                              DataCell(
                                                Container(
                                                  width: MediaQuery.of(context)
                                                              .size
                                                              .width <
                                                          1600
                                                      ? MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.09
                                                      : MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.13,
                                                  child: Text(
                                                      row['roleKey'] ?? "",
                                                      style: bangDuLieu),
                                                ),
                                              ),
                                              DataCell(
                                                Text(row['roleName'] ?? "",
                                                    style: bangDuLieu),
                                              ),
                                              DataCell(
                                                Text(row['description'] ?? '',
                                                    style: bangDuLieu),
                                              ),
                                              DataCell(
                                                Text(
                                                    row['status'] != 1
                                                        ? "Không kích hoạt"
                                                        : "Đã kích hoạt",
                                                    style: bangDuLieu),
                                              ),
                                              DataCell(
                                                Container(
                                                    margin: EdgeInsets.fromLTRB(
                                                        10, 0, 0, 0),
                                                    child: InkWell(
                                                        onTap: () {
                                                          showDialog(
                                                            context: context,
                                                            builder: (BuildContext
                                                                    context) =>
                                                                ThemMoiNhomQuyen(
                                                              row: row,
                                                              titleDialog:
                                                                  'Chỉnh sửa nhóm quyền',
                                                              function: () {
                                                                getRoleFuture =
                                                                    getRole();
                                                              },
                                                            ),
                                                          );
                                                        },
                                                        child: Icon(
                                                          Icons.edit_calendar,
                                                          color:
                                                              Color(0xff009C87),
                                                        ))),
                                              ),
                                            ])
                                    ]),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return Text('${snapshot.error}');
                    }

                    // By default, show a loading spinner.
                    return const CircularProgressIndicator();
                  },
                )
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
class XacNhanThayDoi extends StatefulWidget {
  Function function;
  XacNhanThayDoi({Key? key, required this.function}) : super(key: key);

  @override
  State<XacNhanThayDoi> createState() => _XacNhanThayDoiState();
}

class _XacNhanThayDoiState extends State<XacNhanThayDoi> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
                  'Xác nhận cập nhật nhóm quyền',
                  style: titleAlertDialog,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
          ),
        ],
      ),
      content: Container(
        height: 100,
        width: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: Divider(
                thickness: 1,
              ),
            ),
            Text(
              'Bạn có chắc chắn muốn cập nhật các nhóm quyền không',
            ),
            Padding(
              padding: const EdgeInsets.all(0),
              child: Divider(
                thickness: 1,
              ),
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
            // shadowColor: Colors.greenAccent,
            elevation: 3,
            // shape: Border.all(width: 1,color: Colors.red);
            // side: BorderSide(
            //   width: 1,
            //   color: Colors.black87,
            // ),
            minimumSize: Size(140, 50),
            // maximumSize: Size(140, 50), //////// HERE
          ),
        ),
        ElevatedButton(
          // textColor: Color(0xFF6200EE),
          onPressed: () {
            widget.function();
            Navigator.pop(context);
          },
          child: Text(
            'Đồng ý',
            style: TextStyle(),
          ),
          style: ElevatedButton.styleFrom(
            primary: colorBlueBtnDialog,
            onPrimary: colorWhite,
            // shadowColor: Colors.greenAccent,
            elevation: 3,
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(32.0)),
            minimumSize: Size(140, 50), //////// HERE
          ),
        ),
      ],
    );
  }
}

// Pop-up thêm mới hồ sơ
// ignore: must_be_immutable
class ThemMoiNhomQuyen extends StatefulWidget {
  String titleDialog;
  dynamic row;
  Function function;
  ThemMoiNhomQuyen(
      {Key? key, required this.titleDialog, this.row, required this.function})
      : super(key: key);

  @override
  State<ThemMoiNhomQuyen> createState() => _ThemMoiNhomQuyenState();
}

class _ThemMoiNhomQuyenState extends State<ThemMoiNhomQuyen> {
  @override
  // ignore: must_call_super
  var listRole;
  getRole() async {
    String query = '';
    if (widget.row != null) {
      query = 'id!${widget.row['id']}';
    }
    var response =
        await httpGet("/api/nhomquyen/get/page?filter=$query", context);
    if (response.containsKey("body")) {
      listRole = jsonDecode(response["body"])['content'];
      return listRole;
    } else
      throw Exception("Error load data");
  }

  void initState() {
    if (widget.row != null) {
      tenNhom.text = widget.row['roleName'] ?? '';
      moTa.text = widget.row['description'] ?? '';
      maNhom.text = widget.row['roleKey'] ?? '';
      selectedTT = widget.row['status'] == 1 ? '1' : '0';
    }
    getRole();
  }

  String titleLog = '';
  updateRole() async {
    var data = widget.row;
    data['roleName'] = tenNhom.text;
    data['roleKey'] = maNhom.text;
    data['status'] = int.parse(selectedTT);
    data['description'] = moTa.text;
    var response =
        await httpPut("/api/nhomquyen/put/${data['id']}", data, context);
    print(response);
    if (response['body'] == "true") {
      titleLog = 'Cập nhật dữ liệu thành công';
    } else {
      titleLog = 'Cập nhật thất bại';
    }
  }

  addRole() async {
    var data = {};
    data['roleName'] = tenNhom.text;
    data['roleKey'] = maNhom.text;
    data['status'] = int.parse(selectedTT);
    data['description'] = moTa.text;
    data['parentId'] = 0;
    var response = await httpPost("/api/nhomquyen/post/save", data, context);
    print(response);
    if (isNumber(response['body'])) {
      titleLog = 'Thêm mới dữ liệu thành công';
      return response['body'];
    } else {
      titleLog = 'Thêm mới thất bại';
    }
  }

  TextEditingController tenNhom = TextEditingController();
  TextEditingController moTa = TextEditingController();
  TextEditingController maNhom = TextEditingController();

  // late DateTime selectedDate;
  String selectedTT = '0';
  List<dynamic> itemsTT = [
    {'name': 'Chưa kích hoạt', 'value': '0'},
    {'name': 'Đã kích hoạt', 'value': '1'},
  ];
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
                  widget.titleDialog,
                  style: titleAlertDialog,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
          ),
        ],
      ),
      content: Container(
        width: 600,
        height: 450,
        child: ListView(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                SizedBox(
                  height: 25,
                ),
                Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        margin: EdgeInsets.only(bottom: 30),
                        child: TextFieldValidatedForm(
                            type: 'Text',
                            label: 'Mã nhóm quyền',
                            height: 40,
                            controller: maNhom,
                            flexLable: 3,
                            enter: () {}),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 30),
                        child: TextFieldValidatedForm(
                            type: 'Text',
                            label: 'Tên nhóm quyền',
                            height: 40,
                            controller: tenNhom,
                            flexLable: 3,
                            enter: () {}),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 30),
                        child: Row(
                          children: [
                            Expanded(
                                flex: 3,
                                child: Text(
                                  'Mô tả',
                                  style: titleWidgetBox,
                                )),
                            Expanded(
                              flex: 5,
                              child: Container(
                                // width: MediaQuery.of(context).size.width * 0.15,
                                child: TextField(
                                  controller: moTa,
                                  minLines: 3,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 30),
                        child: DropdownBtnSearch(
                          isAll: false,
                          flexLabel: 3,
                          label: 'Trạng thái',
                          listItems: itemsTT,
                          isSearch: false,
                          selectedValue: selectedTT,
                          setSelected: (selected) {
                            selectedTT = selected;
                          },
                        ),
                      ),
                    ],
                  ),
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
            // shadowColor: Colors.greenAccent,
            elevation: 3,
            // shape: Border.all(width: 1,color: Colors.red);
            // side: BorderSide(
            //   width: 1,
            //   color: Colors.black87,
            // ),
            minimumSize: Size(140, 50),
            // maximumSize: Size(140, 50), //////// HERE
          ),
        ),
        ElevatedButton(
          // textColor: Color(0xFF6200EE),
          onPressed: () async {
            bool validate = true;
            bool checkExitst = true;
            for (var row in listRole) {
              if (maNhom.text.toLowerCase() == row['roleKey'].toLowerCase()) {
                checkExitst = false;
                break;
              }
            }
            if (maNhom.text.isEmpty || tenNhom.text.isEmpty) {
              validate = false;
            }
            if (validate == false) {
              showToast(
                context: context,
                msg: 'Hãy điền đầy đủ thông tin',
                color: Colors.red,
                icon: const Icon(Icons.warning),
              );
            } else if (checkExitst == false) {
              showToast(
                context: context,
                msg: 'Mã nhóm quyền đã tồn tại',
                color: Colors.red,
                icon: const Icon(Icons.warning),
              );
            } else {
              await showDialog(
                context: context,
                builder: (BuildContext context) => ConfirmUpdate(
                  function: () async {
                    if (widget.row != null) {
                      await updateRole();
                    } else {
                      await addRole();
                    }
                    widget.function();
                    showToast(
                      context: context,
                      msg: titleLog,
                      color: titleLog == 'Cập nhật dữ liệu thành công' ||
                              titleLog == 'Thêm mới dữ liệu thành công'
                          ? Color.fromARGB(136, 72, 238, 67)
                          : Colors.red,
                      icon: titleLog == 'Cập nhật dữ liệu thành công' ||
                              titleLog == 'Thêm mới dữ liệu thành công'
                          ? Icon(Icons.done)
                          : Icon(Icons.warning),
                    );
                    Navigator.pop(context);
                  },
                  content: widget.row == null
                      ? 'Bạn có chắc chắn muốn thêm mới nhóm quyền'
                      : 'Bạn có chắc chắn muốn chỉnh sửa nhóm quyền',
                  title: widget.row == null
                      ? 'Thêm mới nhóm quyền'
                      : 'Cập nhật nhóm quyền',
                ),
              );
              Navigator.pop(context);
            }
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
            minimumSize: Size(140, 50), //////// HERE
          ),
        ),
      ],
    );
  }
}

class ChucNang {
  String name;
  bool view;
  bool add;
  bool edit;
  bool delete;
  ChucNang(this.name, this.view, this.add, this.edit, this.delete);
}

// ignore: must_be_immutable
class TableChucNang extends StatefulWidget {
  List<ChucNang> listChucNang;
  TableChucNang({Key? key, required this.listChucNang}) : super(key: key);

  @override
  State<TableChucNang> createState() => _TableChucNangState();
}

class _TableChucNangState extends State<TableChucNang> {
  @override
  Widget build(BuildContext context) {
    return DataTable(columns: [
      DataColumn(label: Text('Chức năng', style: titleTableData)),
      DataColumn(label: Text('Xem', style: titleTableData)),
      DataColumn(label: Text('Thêm', style: titleTableData)),
      DataColumn(label: Text('Sửa', style: titleTableData)),
      DataColumn(label: Text('Xóa', style: titleTableData)),
    ], rows: [
      for (int i = 0; i < widget.listChucNang.length; i++)
        DataRow(cells: [
          DataCell(Text(widget.listChucNang[i].name)),
          DataCell(
            Checkbox(
              checkColor: Colors.white,
              value: widget.listChucNang[i].view,
              onChanged: (value) {
                setState(() {
                  widget.listChucNang[i].view = value!;
                });
              },
            ),
          ),
          DataCell(
            Checkbox(
              checkColor: Colors.white,
              value: widget.listChucNang[i].add,
              onChanged: (value) {
                setState(() {
                  widget.listChucNang[i].add = value!;
                });
              },
            ),
          ),
          DataCell(
            Checkbox(
              checkColor: Colors.white,
              value: widget.listChucNang[i].edit,
              onChanged: (value) {
                setState(() {
                  widget.listChucNang[i].edit = value!;
                });
              },
            ),
          ),
          DataCell(
            Checkbox(
              checkColor: Colors.white,
              value: widget.listChucNang[i].delete,
              onChanged: (value) {
                setState(() {
                  widget.listChucNang[i].delete = value!;
                });
              },
            ),
          )
        ])
    ]);
  }
}
