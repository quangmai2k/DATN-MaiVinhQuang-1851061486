import 'dart:convert';

import 'package:flutter/material.dart';
import '../../../../api.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../common/style.dart';
import 'package:expandable/expandable.dart';

class FormCauHinhThongTin extends StatefulWidget {
  const FormCauHinhThongTin({Key? key}) : super(key: key);

  @override
  State<FormCauHinhThongTin> createState() => _FormCauHinhThongTinState();
}

class _FormCauHinhThongTinState extends State<FormCauHinhThongTin> {
  bool checkArrest = false;
  bool checkArrest2 = false;
  bool display1 = false;
  bool display2 = false;
  bool checkArrest3 = false;
  bool checkForm1 = false;
  bool checkForm2 = false;
  bool checkForm3 = false;
  bool checkForm4 = false;
  String selectedTTCN = '0';
  String selectedHSCN = '0';
  String selectedTTSK = '0';
  String selectedTTTC = '0';
  String selectedTTDT = '0';
  String selectedHSXC = '0';
  String selectedQTLV = '0';
  String selectedTTLH = '0';
  String selectedXNTT = '0';
  String selectedXLHS = '0';
  List<String> itemsTT = [
    'Đã kích hoạt',
    'Chưa kích hoạt',
  ];
  late Future<dynamic> getListFormFuture;
  var listForm = [];
  getListForm() async {
    var response = await httpGet("/api/tts-form/get/page", context);
    if (response.containsKey("body")) {
      setState(() {
        listForm = jsonDecode(response["body"])['content'];
      });
    }
    for (var row in listForm) {
      listFormTts.add({
        'status': row['status'].toString(),
        'id': row['id'],
        'updated': false
      });
    }
    return 0;
  }

  updateHS(row) async {
    var response =
        await httpPut('/api/tts-hoso/put/${row['id']}', row, context);
    if (response.containsKey("body")) {
      if (jsonDecode(response["body"]) == true) {
        titleLog = 'Cập nhật thông tin thành công';
        return "Cập nhật thành công";
      }
    } else
      print('Cập nhật thất bại');
  }

  updateForm(id, status) async {
    var data = {"status": int.parse(status)};
    var response = await httpPut('/api/tts-form/put/$id', data, context);
    if (response.containsKey("body")) {
      if (jsonDecode(response["body"]) == true) {
        return "Cập nhật thành công";
      }
    } else
      titleLogForm = 'Cập nhật thất bại';
  }

  bool isNumber(String string) {
    try {
      int.parse(string);
      return true;
    } catch (e) {
      return false;
    }
  }

  addHS(row) async {
    var response = await httpPost('/api/tts-hoso/post/save', row, context);
    if (isNumber(response['body'])) {
      titleLog = 'Cập nhật thông tin thành công';
      return response['body'];
    } else {
      return null;
    }
  }

  deleteHS(id) async {
    var response = await httpDelete('/api/tts-hoso/del/$id', context);
    print(response);
    if (jsonDecode(response["body"]).containsKey("1")) {
      titleLog = 'Cập nhật thông tin thành công';
    } else {
      titleLog = "Xóa không thành công";
    }
    return response;
  }

  String titleLog = 'Cập nhật thông tin thành công';
  String titleLogForm = "Cập nhật thông tin thành công";
  var listHSC = [];
  var listHoSoChinh = [];
  late Future<dynamic> getListHscFuture;
  getListHSC() async {
    var response = await httpGet(
        "/api/tts-hoso/get/page?filter=fileGroup:0 AND fileGeneric:0", context);
    if (response.containsKey("body")) {
      setState(() {
        listHSC = jsonDecode(response["body"])['content'];
        listHoSoChinh = [];
        for (var row in listHSC) {
          listHoSoChinh.add({
            'id': row['id'],
            'name': row['name'],
            'required': row['required'],
            'fileGroup': row['fileGroup'],
            'fileGeneric': row['fileGeneric'],
            'contentType': row['contentType'],
            'status': true,
            'updated': false
          });
        }
      });
      return 0;
    }
  }

  var listHSK = [];
  var listHoSoKhac = [];
  late Future<dynamic> getListHskFuture;
  getListHSK() async {
    var response = await httpGet(
        "/api/tts-hoso/get/page?filter=fileGroup:1 AND fileGeneric:0", context);
    if (response.containsKey("body")) {
      setState(() {
        listHSK = jsonDecode(response["body"])['content'];
        listHoSoKhac = [];
        for (var row in listHSK) {
          listHoSoKhac.add({
            'id': row['id'],
            'name': row['name'],
            'required': row['required'],
            'fileGroup': row['fileGroup'],
            'fileGeneric': row['fileGeneric'],
            'contentType': row['contentType'],
            'status': true,
            'updated': false
          });
        }
      });
      return 0;
    }
  }

  var listHSXC = [];
  var listHoSoXuatCanh = [];
  late Future<dynamic> getListHsxcFuture;
  getListHSXC() async {
    var response = await httpGet(
        "/api/tts-hoso/get/page?filter=fileGroup:0 AND fileGeneric:1", context);
    if (response.containsKey("body")) {
      setState(() {
        listHSXC = jsonDecode(response["body"])['content'];
        listHoSoXuatCanh = [];
        for (var row in listHSXC) {
          listHoSoXuatCanh.add({
            'id': row['id'],
            'name': row['name'],
            'required': row['required'],
            'fileGroup': row['fileGroup'],
            'fileGeneric': row['fileGeneric'],
            'contentType': row['contentType'],
            'status': true,
            'updated': false
          });
        }
      });
    }
    return 0;
  }

  // var listHoSoChinh;
  // var listHoSoKhac;
  // var listHoSoXuatCanh;
  List<dynamic> listFormTts = [];
  var listItems = [
    {'name': 'Sử dụng', 'value': '1'},
    {'name': 'Không sử dụng', 'value': '0'}
  ];
  late Future<dynamic> loadApp;
  load() async {
    await getListForm();
    await getListHSK();
    await getListHSC();
    await getListHSXC();
    return 0;
  }

  @override
  void initState() {
    loadApp = load();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: loadApp,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SingleChildScrollView(
            controller: ScrollController(),
            child: Column(
              children: [
                ActiveForm(
                  function: () async {
                    for (var row in listFormTts) {
                      if (row['updated'] == true) {
                        await updateForm(row['id'], row['status']);
                      }
                    }
                    await getListForm();
                    showToast(
                      context: context,
                      msg: titleLogForm,
                      color: titleLogForm == 'Cập nhật thông tin thành công'
                          ? Color.fromARGB(136, 72, 238, 67)
                          : Colors.red,
                      icon: titleLogForm == 'Cập nhật thông tin thành công'
                          ? Icon(Icons.done)
                          : Icon(Icons.warning),
                    );
                  },
                  controller: ExpandableController(initialExpanded: true),
                  selectedItem: selectedTTCN,
                  title: 'Cấu hình thông tin cá nhân ',
                  content: Container(
                      child: Column(
                    children: [
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        children: [
                          Text(
                            'Form được sử dụng:',
                            style: titleWidgetBox,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Wrap(
                        runSpacing: 25.0,
                        spacing: 5.0,
                        children: [
                          for (int i = 0; i < listForm.length; i++)
                            Container(
                                child: Row(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: DropdownBtnSearch(
                                    flexDropdown: 3,
                                    label: listForm[i]['formName'],
                                    isAll: false,
                                    isSearch: false,
                                    listItems: listItems,
                                    setSelected: (selected) {
                                      listFormTts[i]['status'] = selected;
                                      listFormTts[i]['updated'] = true;
                                    },
                                    selectedValue: listFormTts[i]['status'],
                                  ),
                                ),
                                Expanded(flex: 8, child: Container())
                              ],
                            ))
                        ],
                      )
                    ],
                  )),
                ),
                ActiveForm(
                  controller: ExpandableController(),
                  selectedItem: selectedHSCN,
                  title: 'Cấu hình hồ sơ cá nhân',
                  content: Container(
                      child: Column(
                    children: [
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        children: [
                          Text(
                            'Nhóm hồ sơ chính',
                            style: titleWidget,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                            child: DataTable(columns: [
                              DataColumn(
                                  label:
                                      Text('Tên nhóm', style: titleTableData)),
                              DataColumn(
                                  label:
                                      Text('Bắt buộc', style: titleTableData)),
                              DataColumn(
                                  label:
                                      Text('Định dạng', style: titleTableData)),
                              DataColumn(
                                  label: InkWell(
                                      onTap: () async {
                                        await showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              ThemMoiHoSo(
                                            titleDialog: 'Thêm mới hồ sơ',
                                            function:
                                                (name, require, contentType) {
                                              setState(() {
                                                listHoSoChinh.add({
                                                  'id': null,
                                                  'name': name,
                                                  'required': require,
                                                  'fileGroup': 0,
                                                  'fileGeneric': 0,
                                                  'contentType': contentType,
                                                  'status': true
                                                });
                                              });
                                              // widget.callBack(listHoSoChinh);
                                            },
                                            // fileGroup: 0,
                                            // fileGeneric: 0,
                                          ),
                                        );
                                      },
                                      child: Icon(Icons.add,
                                          color: Color(0xff009C87), size: 40))),
                            ], rows: <DataRow>[
                              for (var row in listHoSoChinh)
                                if (row['status'] == true)
                                  DataRow(cells: <DataCell>[
                                    DataCell(Text(row['name'])),
                                    DataCell(row['required'] == 1
                                        ? Text('Có')
                                        : Text('Không')),
                                    DataCell(Text(format(row['contentType']))),
                                    DataCell(Row(
                                      children: [
                                        Container(
                                            margin: EdgeInsets.fromLTRB(
                                                10, 0, 0, 0),
                                            child: InkWell(
                                                onTap: () async {
                                                  await showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        ThemMoiHoSo(
                                                      function: (name, require,
                                                          contentType) {
                                                        row['name'] = name;
                                                        row['required'] =
                                                            require;
                                                        row['contentType'] =
                                                            contentType;
                                                        row['updated'] = true;
                                                        setState(() {});
                                                        // widget.callBack(listHoSoChinh);
                                                      },
                                                      titleDialog:
                                                          'Chỉnh sửa hồ sơ',
                                                      row: row,
                                                    ),
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.edit_calendar,
                                                  color: Color(0xff009C87),
                                                ))),
                                        Container(
                                            margin: EdgeInsets.fromLTRB(
                                                10, 0, 0, 0),
                                            child: InkWell(
                                                onTap: () async {
                                                  await showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        XacNhanXoa(
                                                      title:
                                                          'Xác nhận xóa hồ sơ',
                                                      content:
                                                          'Bạn có chắc chắn muốn xóa hồ sơ ${row['name']} không?',
                                                      function: () {
                                                        row['status'] = false;
                                                        setState(() {});
                                                        // widget.callBack(listHoSoChinh);
                                                      },
                                                    ),
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ))),
                                      ],
                                    )),
                                  ])
                            ]),
                          )),
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        children: [
                          Text(
                            'Nhóm hồ sơ khác',
                            style: titleWidget,
                          )
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                            child: DataTable(columns: [
                              DataColumn(
                                  label: Text('Tên', style: titleTableData)),
                              DataColumn(
                                  label:
                                      Text('Bắt buộc', style: titleTableData)),
                              DataColumn(
                                  label:
                                      Text('Định dạng', style: titleTableData)),
                              DataColumn(
                                  label: InkWell(
                                      onTap: () async {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              ThemMoiHoSo(
                                            titleDialog: 'Thêm mới hồ sơ',
                                            function:
                                                (name, require, contentType) {
                                              setState(() {
                                                listHoSoKhac.add({
                                                  'id': null,
                                                  'name': name,
                                                  'required': require,
                                                  'fileGroup': 1,
                                                  'fileGeneric': 0,
                                                  'contentType': contentType,
                                                  'status': true
                                                });
                                                // widget.callBack(listHoSoKhac);
                                              });
                                            },
                                            // fileGroup: 1,
                                            // fileGeneric: 0,
                                          ),
                                        );
                                      },
                                      child: Icon(Icons.add,
                                          color: Color(0xff009C87), size: 40))),
                            ], rows: <DataRow>[
                              for (var row in listHoSoKhac)
                                if (row['status'] == true)
                                  DataRow(cells: <DataCell>[
                                    DataCell(Text(row['name'])),
                                    DataCell(row['required'] == 1
                                        ? Text('Có')
                                        : Text('Không')),
                                    DataCell(Text(format(row['contentType']))),
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
                                                        ThemMoiHoSo(
                                                      function: (name, require,
                                                          contentType) {
                                                        row['name'] = name;
                                                        row['required'] =
                                                            require;
                                                        row['contentType'] =
                                                            contentType;
                                                        row['updated'] = true;
                                                        setState(() {});
                                                        // widget.callBack(listHoSoKhac);
                                                      },
                                                      titleDialog:
                                                          'Chỉnh sửa hồ sơ',
                                                      row: row,
                                                    ),
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.edit_calendar,
                                                  color: Color(0xff009C87),
                                                ))),
                                        Container(
                                            margin: EdgeInsets.fromLTRB(
                                                10, 0, 0, 0),
                                            child: InkWell(
                                                onTap: () async {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        XacNhanXoa(
                                                      title:
                                                          'Xác nhận xóa hồ sơ',
                                                      content:
                                                          'Bạn có chắc chắn muốn xóa hồ sơ ${row['name']} không?',
                                                      function: () {
                                                        row['status'] = false;
                                                        setState(() {});
                                                        // widget.callBack(listHoSoKhac);
                                                      },
                                                    ),
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ))),
                                      ],
                                    )),
                                  ])
                            ]),
                          )),
                        ],
                      ),
                    ],
                  )),
                  function: () async {
                    for (var row in listHoSoChinh) {
                      if (row['status'] == true &&
                          row['id'] != null &&
                          row['updated'] == true) {
                        print('Sửa');
                        var data = {
                          'id': row['id'],
                          'name': row['name'],
                          'required': row['required'],
                          'fileGroup': row['fileGroup'],
                          'fileGeneric': row['fileGeneric'],
                          'contentType': row['contentType'],
                        };
                        await updateHS(data);
                      } else if (row['status'] == true && row['id'] == null) {
                        print('Thêm');

                        var data = {
                          'name': row['name'],
                          'required': row['required'],
                          'fileGroup': row['fileGroup'],
                          'fileGeneric': row['fileGeneric'],
                          'contentType': row['contentType'],
                        };
                        await addHS(data).then((newId) {
                          row['id'] = newId;
                        });
                      } else if (row['id'] != null && row['status'] == false) {
                        print('Xóa');

                        await deleteHS(row['id']);
                      }
                    }
                    for (var row in listHoSoKhac) {
                      if (row['status'] == true &&
                          row['id'] != null &&
                          row['updated'] == true) {
                        print('Sửa');

                        var data = {
                          'id': row['id'],
                          'name': row['name'],
                          'required': row['required'],
                          'fileGroup': row['fileGroup'],
                          'fileGeneric': row['fileGeneric'],
                          'contentType': row['contentType'],
                        };
                        await updateHS(data);
                      } else if (row['status'] == true && row['id'] == null) {
                        print('Thêm');

                        var data = {
                          'name': row['name'],
                          'required': row['required'],
                          'fileGroup': row['fileGroup'],
                          'fileGeneric': row['fileGeneric'],
                          'contentType': row['contentType'],
                        };
                        await addHS(data).then((newId) {
                          row['id'] = newId;
                        });
                      } else if (row['id'] != null && row['status'] == false) {
                        await deleteHS(row['id']);
                      }
                    }
                    await getListHSC();
                    await getListHSK();
                    setState(() {});
                    showToast(
                      context: context,
                      msg: titleLog,
                      color: titleLog == 'Cập nhật thông tin thành công'
                          ? Color.fromARGB(136, 72, 238, 67)
                          : Colors.red,
                      icon: titleLog == 'Cập nhật thông tin thành công'
                          ? Icon(Icons.done)
                          : Icon(Icons.warning),
                    );
                  },
                ),
                ActiveForm(
                    controller: ExpandableController(),
                    selectedItem: selectedTTSK,
                    title: 'Cấu hình thông tin sức khỏe '),
                ActiveForm(
                  controller: ExpandableController(),
                  selectedItem: selectedTTTC,
                  title: 'Thông tin tiến cử/Lịch sử',
                  content: Container(
                      child: Column(
                    children: [
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Checkbox(
                              checkColor: Colors.white,
                              value: display1,
                              onChanged: (value) {
                                setState(() {
                                  display1 = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            flex: 25,
                            child: Text(
                              'Hiển thị lịch sử thi tuyển',
                              style: TextStyle(
                                color: Color(0xff333333),
                                fontSize: 16,
                              ),
                            ),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Checkbox(
                              checkColor: Colors.white,
                              value: display2,
                              onChanged: (value) {
                                setState(() {
                                  display2 = value!;
                                });
                              },
                            ),
                          ),
                          Expanded(
                            flex: 25,
                            child: Text(
                              'Hiển thị lịch sử tiến cử',
                              style: TextStyle(
                                color: Color(0xff333333),
                                fontSize: 16,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  )),
                ),
                ActiveForm(
                    controller: ExpandableController(),
                    selectedItem: selectedTTDT,
                    title: 'Cấu hình thông tin đào tạo '),
                ActiveForm(
                  controller: ExpandableController(),
                  selectedItem: selectedHSXC,
                  title: 'Cấu hình hồ sơ xuất cảnh',
                  content: Container(
                      child: Column(
                    children: [
                      SizedBox(
                        height: 25,
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                            child: DataTable(columns: [
                              DataColumn(
                                  label:
                                      Text('Tên nhóm', style: titleTableData)),
                              DataColumn(
                                  label:
                                      Text('Bắt buộc', style: titleTableData)),
                              DataColumn(
                                  label:
                                      Text('Định dạng', style: titleTableData)),
                              DataColumn(
                                  label: InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              ThemMoiHoSo(
                                            titleDialog: 'Thêm mới hồ sơ',
                                            function:
                                                (name, require, contentType) {
                                              setState(() {
                                                listHoSoXuatCanh.add({
                                                  'id': null,
                                                  'name': name,
                                                  'required': require,
                                                  'fileGroup': 0,
                                                  'fileGeneric': 1,
                                                  'contentType': contentType,
                                                  'status': true
                                                });
                                              });
                                            },
                                          ),
                                        );
                                      },
                                      child: Icon(Icons.add,
                                          color: Color(0xff009C87), size: 40))),
                            ], rows: <DataRow>[
                              for (var row in listHoSoXuatCanh)
                                if (row['status'] == true)
                                  DataRow(cells: <DataCell>[
                                    DataCell(Text(row['name'])),
                                    DataCell(row['required'] == 1
                                        ? Text('Có')
                                        : Text('Không')),
                                    DataCell(Text(format(row['contentType']))),
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
                                                        ThemMoiHoSo(
                                                      function: (name, require,
                                                          contentType) {
                                                        row['name'] = name;
                                                        row['required'] =
                                                            require;
                                                        row['contentType'] =
                                                            contentType;
                                                        row['updated'] = true;
                                                        setState(() {});
                                                      },
                                                      titleDialog:
                                                          'Chỉnh sửa hồ sơ',
                                                      row: row,
                                                    ),
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.edit_calendar,
                                                  color: Color(0xff009C87),
                                                ))),
                                        Container(
                                            margin: EdgeInsets.fromLTRB(
                                                10, 0, 0, 0),
                                            child: InkWell(
                                                onTap: () async {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        XacNhanXoa(
                                                      title:
                                                          'Xác nhận xóa hồ sơ',
                                                      content:
                                                          'Bạn có chắc chắn muốn xóa hồ sơ ${row['name']} không?',
                                                      function: () {
                                                        row['status'] = false;
                                                        setState(() {});
                                                      },
                                                    ),
                                                  );
                                                },
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ))),
                                      ],
                                    )),
                                  ])
                            ]),
                          )),
                        ],
                      ),
                    ],
                  )),
                  function: () async {
                    for (var row in listHoSoXuatCanh) {
                      if (row['status'] == true &&
                          row['id'] != null &&
                          row['updated'] == true) {
                        var data = {
                          'id': row['id'],
                          'name': row['name'],
                          'required': row['required'],
                          'fileGroup': row['fileGroup'],
                          'fileGeneric': row['fileGeneric'],
                          'contentType': row['contentType'],
                        };
                        await updateHS(data);
                      } else if (row['status'] == true && row['id'] == null) {
                        var data = {
                          'name': row['name'],
                          'required': row['required'],
                          'fileGroup': row['fileGroup'],
                          'fileGeneric': row['fileGeneric'],
                          'contentType': row['contentType'],
                        };
                        await addHS(data).then((newId) {
                          row['id'] = newId;
                        });
                      } else if (row['id'] != null && row['status'] == false) {
                        await deleteHS(row['id']);
                      }
                    }
                    await getListHSXC();
                    showToast(
                      context: context,
                      msg: titleLog,
                      color: titleLog == 'Cập nhật thông tin thành công'
                          ? Color.fromARGB(136, 72, 238, 67)
                          : Colors.red,
                      icon: titleLog == 'Cập nhật thông tin thành công'
                          ? Icon(Icons.done)
                          : Icon(Icons.warning),
                    );
                  },
                ),
                ActiveForm(
                    controller: ExpandableController(),
                    selectedItem: selectedQTLV,
                    title: 'Quá trình làm việc'),
                ActiveForm(
                    controller: ExpandableController(),
                    selectedItem: selectedTTLH,
                    title: 'Thông tin liên hệ khẩn'),
                ActiveForm(
                    controller: ExpandableController(),
                    selectedItem: selectedXNTT,
                    title: 'Xác nhận thanh toán'),
                ActiveForm(
                    controller: ExpandableController(),
                    selectedItem: selectedXLHS,
                    title: 'Nhật ký xử lý hồ sơ'),
                SizedBox(
                  height: 25,
                )
              ],
            ),
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

// ignore: must_be_immutable
class ActiveForm extends StatefulWidget {
  String title;
  String selectedItem;
  Widget? content;
  Function? function;
  dynamic controller;
  ActiveForm(
      {Key? key,
      required this.selectedItem,
      required this.title,
      this.content,
      this.function,
      required this.controller})
      : super(key: key);

  @override
  State<ActiveForm> createState() => _ActiveFormState();
}

class _ActiveFormState extends State<ActiveForm> {
  var itemsTT = [
    {'name': 'Đã kích hoạt', 'value': '1'},
    {'name': 'Chưa kích hoạt', 'value': '0'}
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundPage,
      padding:
          EdgeInsets.symmetric(vertical: 15, horizontal: horizontalPaddingPage),
      child: Container(
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: borderRadiusContainer,
          boxShadow: [boxShadowContainer],
          border: borderAllContainerBox,
        ),
        padding: paddingBoxContainer,
        child: ExpandablePanel(
          // controller: widget.controller,
          header: Container(
            margin: EdgeInsets.only(top: 10),
            child: Text(
              widget.title,
              style: titleBox,
            ),
          ),
          collapsed: Container(),
          expanded: Column(children: [
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
                  flex: 5,
                  child: DropdownBtnSearch(
                    label: 'Trạng thái kích hoạt',
                    flexDropdown: 3,
                    listItems: itemsTT,
                    isAll: false,
                    isSearch: false,
                    selectedValue: widget.selectedItem,
                    setSelected: (selected) {
                      widget.selectedItem = selected;
                    },
                  ),
                ),
                Expanded(flex: 8, child: Container())
              ],
            ),
            widget.content ?? Container(),
            SizedBox(
              height: 25,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Container(
                margin: EdgeInsets.only(left: 20, right: horizontalPaddingPage),
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
                    widget.function!();
                  },
                  child: Row(
                    children: [
                      Text('Lưu', style: textButton),
                    ],
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

String format(int i) {
  if (i == 0)
    return 'File';
  else if (i == 1)
    return 'Text';
  else if (i == 2)
    return 'Date';
  else
    return 'Image';
}

// Pop-up thêm mới hồ sơ
// ignore: must_be_immutable
class ThemMoiHoSo extends StatefulWidget {
  String titleDialog;
  dynamic row;
  Function function;

  ThemMoiHoSo({
    Key? key,
    required this.titleDialog,
    this.row,
    required this.function,
  }) : super(key: key);

  @override
  State<ThemMoiHoSo> createState() => _ThemMoiHoSoState();
}

class _ThemMoiHoSoState extends State<ThemMoiHoSo> {
  updateHS(int id, String name, int require, int contentType) async {
    var data = {"name": name, "required": require, "contentType": contentType};

    await httpPut('/api/tts-hoso/put/' + id.toString(), data, context);
  }

  addHS(String name, int require, int fileGroup, int fileGeneric,
      int contentType) async {
    var data = {
      "name": name,
      "required": require,
      'fileGroup': fileGroup,
      'fileGeneric': fileGeneric,
      "contentType": contentType
    };
    // ignore: unused_local_variable
    var responeUpdate =
        await httpPost('/api/tts-hoso/post/save', data, context);
  }

  @override
  // ignore: must_call_super
  void initState() {
    if (widget.row != null) {
      selectedTT = widget.row['required'] == 1 ? 'Bắt buộc' : 'Không bắt buộc';
      ten = TextEditingController(text: widget.row['name']);
      if (widget.row['contentType'] == 0)
        selectedFormat = 'File';
      else if (widget.row['contentType'] == 1)
        selectedFormat = 'Text';
      else if (widget.row['contentType'] == 2)
        selectedFormat = 'Date';
      else if (widget.row['contentType'] == 3) selectedFormat = 'Image';
    }
  }

  int contentType(String selected) {
    if (selected == 'File')
      return 0;
    else if (selected == 'Text')
      return 1;
    else if (selected == 'Date')
      return 2;
    else
      return 3;
  }

  TextEditingController ten = TextEditingController(text: null);
  late String selectedTT = 'Bắt buộc';
  late String selectedFormat = 'File';

  List<String> itemsTT = ['Bắt buộc', 'Không bắt buộc'];
  List<String> itemsFormat = ['File', 'Text', 'Date', 'Image'];
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
        width: 500,
        height: 350,
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
                  height: 280,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          TextFieldValidated(
                            type: 'Text',
                            label: 'Tên nhóm',
                            height: 40,
                            controller: ten,
                            flexLable: 3,
                            flexTextField: 5,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: Text(
                                'Trạng thái',
                                style: titleWidgetBox,
                              )),
                          Expanded(
                            flex: 5,
                            child: Container(
                                // width: MediaQuery.of(context).size.width * 0.15,
                                height: 40,
                                child: Row(
                                  children: [
                                    DropDownButtonWidget(
                                      // widgetBox: Container(),
                                      functionDropDown: (value) {
                                        selectedTT = value!;
                                      },
                                      selectedValues: selectedTT,
                                      listOption: itemsTT,
                                      flexDropDown: 3,
                                    ),
                                  ],
                                )),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              flex: 3,
                              child: Text(
                                'Trạng thái',
                                style: titleWidgetBox,
                              )),
                          Expanded(
                            flex: 5,
                            child: Container(
                                // width: MediaQuery.of(context).size.width * 0.15,
                                height: 40,
                                child: Row(
                                  children: [
                                    DropDownButtonWidget(
                                      // widgetBox: Container(),
                                      functionDropDown: (value) {
                                        selectedFormat = value!;
                                      },
                                      selectedValues: selectedFormat,
                                      listOption: itemsFormat,
                                      flexDropDown: 3,
                                    ),
                                  ],
                                )),
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
            if (ten.text.isEmpty) {
              showToast(
                  context: context,
                  msg: "Yêu cầu nhập đầy đủ các trường",
                  color: Colors.red,
                  icon: Icon(Icons.warning));
            } else {
              if (widget.row != null) {
                widget.function(ten.text, selectedTT == 'Bắt buộc' ? 1 : 0,
                    contentType(selectedFormat));
              } else {
                widget.function(ten.text, selectedTT == 'Bắt buộc' ? 1 : 0,
                    contentType(selectedFormat));
              }
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

// ignore: must_be_immutable
class XacNhanXoa extends StatefulWidget {
  String title;
  String content;
  Function function;
  XacNhanXoa(
      {Key? key,
      required this.title,
      required this.function,
      required this.content})
      : super(key: key);
  @override
  State<XacNhanXoa> createState() => _XacNhanXoaState();
}

class _XacNhanXoaState extends State<XacNhanXoa> {
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
                  widget.title,
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
              widget.content,
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
          onPressed: () async {
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
