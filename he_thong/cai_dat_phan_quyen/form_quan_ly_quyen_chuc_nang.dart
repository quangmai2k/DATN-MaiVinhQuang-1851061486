import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import "package:collection/collection.dart";

import '../../../../api.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';

import '../../../../common/style.dart';

class FormQuanLyQuyenChucNang extends StatefulWidget {
  const FormQuanLyQuyenChucNang({Key? key}) : super(key: key);

  @override
  State<FormQuanLyQuyenChucNang> createState() =>
      _FormQuanLyQuyenChucNangState();
}

class _FormQuanLyQuyenChucNangState extends State<FormQuanLyQuyenChucNang> {
  var listFeature;
  late Future<dynamic> getListFeature;
  var listItemsFeature = [];
  dynamic selectedFeature = '-1';
  getFeature() async {
    await getParentFeature();
    String query = '';
    if (selectedStatus != '-1') {
      query += 'and status:$selectedStatus';
    }
    if (selectedFeature != '-1') {
      query += ' and id:$selectedFeature';
    }
    var response = await httpGet(
        "/api/chucnang/get/page?sort=parentId&filter=parentId:0 $query ",
        context);
    if (response.containsKey("body")) {
      listFeature = jsonDecode(response["body"])['content'];
      for (var row in listFeature) {
        listItemsFeature
            .add({'name': row['moduleName'], 'value': row['id'].toString()});
      }
      setState(() {});
      return listFeature;
    } else
      throw Exception("Error load data");
  }

  var listParentFeature;
  getParentFeature() async {
    var response =
        await httpGet("/api/chucnang/get/page?filter=parentId!0", context);
    if (response.containsKey("body")) {
      listParentFeature = jsonDecode(response["body"])['content'];
      setState(() {});
      return listParentFeature;
    } else
      throw Exception("Error load data");
  }

  List<dynamic> itemsStatus = [
    {'name': 'Đã kích hoạt', 'value': '1'},
    {'name': 'Chưa kích hoạt', 'value': '0'},
  ];
  String selectedStatus = '-1';
  @override
  void initState() {
    super.initState();
    getListFeature = getFeature();
  }

  TextEditingController moduleName = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: getListFeature,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          int i = 1;
          var finalListFeature = [];
          for (var row in listFeature) {
            finalListFeature.add(row);
            for (var feature in listParentFeature) {
              if (row['id'] == feature['parentId']) {
                finalListFeature.add(feature);
              }
            }
          }
          return SingleChildScrollView(
            controller: ScrollController(),
            child: Container(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 7,
                          child: Row(
                            children: [
                              Expanded(
                                flex: 7,
                                child: DropdownBtnSearch(
                                  isAll: true,
                                  flexLabel: 3,
                                  label: 'Nhóm chức năng',
                                  listItems: listItemsFeature,
                                  isSearch: true,
                                  search: TextEditingController(),
                                  selectedValue: selectedFeature,
                                  setSelected: (selected) {
                                    selectedFeature = selected;
                                    setState(() {});
                                  },
                                ),
                              ),
                            ],
                          )),
                      SizedBox(
                        width: 100,
                      ),
                      Expanded(
                          flex: 10,
                          child: DropdownBtnSearch(
                            isAll: true,
                            flexLabel: 3,
                            label: 'Trạng thái',
                            listItems: itemsStatus,
                            isSearch: false,
                            selectedValue: selectedStatus,
                            setSelected: (selected) {
                              selectedStatus = selected;
                              setState(() {});
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
                            getListFeature = getFeature();
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
                                builder: (BuildContext context) =>
                                    ThemMoiChucNang(
                                        function: () {
                                          getListFeature = getFeature();
                                        },
                                        titleDialog: 'Chỉnh sửa nhóm quyền'));
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
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Danh sách chức năng',
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
                  Row(
                    children: [
                      Expanded(
                          child: DataTable(columnSpacing: 5, columns: [
                        DataColumn(
                            label: Container(
                                width: MediaQuery.of(context).size.width * 0.03,
                                child: Text('STT', style: titleTableData))),
                        DataColumn(
                            label: Text('Chức năng', style: titleTableData)),
                        DataColumn(
                            label: Text('Hiển thị ngoài menu',
                                style: titleTableData)),
                        DataColumn(label: Text('Url', style: titleTableData)),
                        DataColumn(
                            label: Text('Trạng thái', style: titleTableData)),
                        DataColumn(label: Text('Sửa', style: titleTableData)),
                      ], rows: <DataRow>[
                        for (var row in finalListFeature)
                          DataRow(cells: <DataCell>[
                            DataCell(Container(
                                width: MediaQuery.of(context).size.width * 0.03,
                                child: Text('${i++}'))),
                            DataCell(Container(
                              margin: row['parentId'] == 0
                                  ? EdgeInsets.only(left: 0)
                                  : EdgeInsets.only(left: 30),
                              child: Text(
                                "${row['parentId'] == 0 ? '' : '- '} ${row['moduleName']}",
                                style: TextStyle(
                                    fontWeight: row['parentId'] == 0
                                        ? FontWeight.bold
                                        : FontWeight.normal),
                              ),
                            )),
                            DataCell(Text(row['isMenu'] == 0 ? "Không" : 'Có')),
                            DataCell(Text(row['navigation'])),
                            DataCell(Text(row['status'] == 0
                                ? "Chưa kích hoạt"
                                : "Đã kích hoạt")),
                            DataCell(Row(
                              children: [
                                Container(
                                    margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                    child: InkWell(
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  ThemMoiChucNang(
                                                      function: () {
                                                        getListFeature =
                                                            getFeature();
                                                      },
                                                      row: row,
                                                      titleDialog:
                                                          'Chỉnh sửa chức năng'));
                                        },
                                        child: Icon(
                                          Icons.edit_calendar,
                                          color: Color(0xff009C87),
                                        ))),
                              ],
                            )),
                          ]),
                      ])),
                    ],
                  )
                ]),
              ),
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

// Pop-up thêm mới hồ sơ
// ignore: must_be_immutable
class ThemMoiChucNang extends StatefulWidget {
  String titleDialog;
  dynamic row;
  Function function;
  ThemMoiChucNang(
      {Key? key, this.row, required this.titleDialog, required this.function})
      : super(key: key);

  @override
  State<ThemMoiChucNang> createState() => _ThemMoiChucNangState();
}

class _ThemMoiChucNangState extends State<ThemMoiChucNang> {
  String selectedIsGroup = '0';
  bool isMenu = false;
  List<dynamic> itemsIsGroup = [
    {'name': 'Chức năng', 'value': '1'},
    {'name': 'Nhóm chức năng', 'value': '0'},
  ];
  List<dynamic> itemsStatus = [
    {'name': 'Đã kích hoạt', 'value': '1'},
    {'name': 'Chưa kích hoạt', 'value': '0'},
  ];
  late String selectedStatus;
  var listFeature;
  var itemsFeatureDropdown = [];
  late String selectedRole;
  late Future<dynamic> getFeatureFuture;
  var listCheckExitst;
  getFeature() async {
    await getRole();
    if (widget.row != null) await getRoleFeature();
    var response = await httpGet(
        "/api/chucnang/get/page?sort=id&filter=parentId:0", context);
    var checkExitst = await httpGet("/api/chucnang/get/page", context);
    // print(checkExitst);
    if (checkExitst.containsKey("body")) {
      listCheckExitst = jsonDecode(checkExitst["body"])['content'];
      // print(jsonDecode(response["body"]));
    }
    if (widget.row != null) {
      for (var row in listCheckExitst) {
        if (row['id'] == widget.row['id']) {
          listCheckExitst.remove(row);
          print('Có xóa');
          break;
        }
      }
    }
    if (response.containsKey("body")) {
      listFeature = jsonDecode(response["body"])['content'];
      itemsFeatureDropdown = [];
      itemsFeatureDropdown.add({'name': '---', 'value': '0'});
      for (var row in listFeature) {
        itemsFeatureDropdown
            .add({'name': row['moduleName'], 'value': row['id'].toString()});
      }
      if (widget.row != null) {
        selectedRole = widget.row['parentId'].toString();
        selectedIsGroup = widget.row['isGroup'].toString();
        isMenu = widget.row['isMenu'] == 1 ? true : false;
        selectedStatus = widget.row['status'].toString();
        name.text = widget.row['moduleName'] ?? '';
        detail.text = widget.row['description'] ?? '';
        navigation.text = widget.row['navigation'] ?? '';
        order.text = widget.row['ord'].toString();
        code.text = widget.row['moduleCode'] ?? '';
        selectedValue = widget.row['params'];
        setState(() {});
      } else {
        selectedStatus = '0';
        selectedRole = '0';
        selectedIsGroup = '1';
        setState(() {});
      }
      return itemsFeatureDropdown;
    } else
      throw Exception("Error load data");
  }

  var listRole;
  var listRoleGroup = [];
  getRole() async {
    var response =
        await httpGet("/api/nhomquyen/get/page?filter=status:1", context);
    if (response.containsKey("body")) {
      listRole = jsonDecode(response["body"])['content'];
      for (var row in listRole) {
        listRoleGroup.add({
          'id': row['id'],
          'roleName': row['roleName'],
          'status': false,
          1: false,
          2: false,
          3: false,
          4: false,
          5: false,
          'updated': false
        });
      }
      return listRole;
    } else
      throw Exception("Error load data");
  }

  var listRoleFuture;
  getRoleFeature() async {
    var response = await httpGet(
        "/api/nhomquyen-chucnang/get/page?filter=moduleId:${widget.row['id']}",
        context);
    if (response.containsKey("body")) {
      listRoleFuture = jsonDecode(response["body"])['content'];
      var listRoleFutureGroupBy =
          groupBy(listRoleFuture, (dynamic obj) => obj['roleId']);
      for (var row in listRoleGroup) {
        if (listRoleFutureGroupBy[row['id']] != null) {
          row['status'] = true;
          for (var permission in listRoleFutureGroupBy[row['id']]!) {
            if (permission['permissionId'] != null)
              row[permission['permissionId']] = true;
          }
        }
      }
      // for (var roleFuture in listRoleFuture) {
      //   for (var role in listRoleGroup) {
      //     if (roleFuture['roleId'] == role['id']) {
      //       role['status'] = true;
      //       role['roleFeatureId'] = roleFuture['id'];
      //       break;
      //     }
      //   }
      // }
      return listRole;
    } else
      throw Exception("Error load data");
  }

  noId() async {
    await getRole();

    return 0;
  }

  bool isNumber(String string) {
    try {
      int.parse(string);
      return true;
    } catch (e) {
      return false;
    }
  }

  addRoleFeature(data) async {
    var response =
        await httpPost("/api/nhomquyen-chucnang/post/saveAll", data, context);
    if (isNumber(response['body'])) {
      print('Thêm mới dữ liệu thành công');
      return response['body'];
    } else {
      print('Thêm mới thất bại');
    }
    return 0;
  }

  deleteRoleFeature() async {
    var response = await httpDelete(
        "/api/nhomquyen-chucnang/del/all?filter=moduleId:${widget.row['id']}",
        context);
    if (jsonDecode(response["body"]) == true) {
      print("Xóa thành công");
    } else {
      print("Xóa thất bại");
    }
    return 0;
  }

  String titleLog = '';
  updateFeature() async {
    var row = widget.row;
    row['moduleCode'] = code.text;
    row['isGroup'] = int.parse(selectedIsGroup);
    row['status'] = int.parse(selectedStatus);
    row['isMenu'] = isMenu ? 1 : 0;
    row['parentId'] = int.parse(selectedRole);
    row['moduleName'] = name.text;
    row['description'] = detail.text;
    row['params'] = selectedValue;
    if (selectedIsGroup == '1') {
      row['navigation'] = navigation.text;
      row['ord'] = isMenu ? int.parse(order.text) : 0;
    } else {
      row['ord'] = 0;
    }
    var response =
        await httpPut("/api/chucnang/put/${row['id']}", row, context);
    if (response['body'] == "true") {
      titleLog = 'Cập nhật dữ liệu thành công';
    } else {
      titleLog = 'Cập nhật thất bại';
    }
  }

  var newId;
  addFeature() async {
    var row = {
      'isGroup': int.parse(selectedIsGroup),
      'status': int.parse(selectedStatus),
      'isMenu': isMenu ? 1 : 0,
      'parentId': int.parse(selectedRole),
      'moduleName': name.text,
      'description': detail.text,
      'navigation': navigation.text,
      'moduleCode': code.text,
      'ord': isMenu ? int.parse(order.text) : 0
    };
    row['params'] = selectedValue;

    var response = await httpPost("/api/chucnang/post/save", row, context);
    if (isNumber(response['body'])) {
      newId = response['body'];
      titleLog = 'Thêm mới dữ liệu thành công';
      return response['body'];
    } else {
      titleLog = 'Thêm mới thất bại';
    }
  }

  IconData iconMenuByParams(iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'moving_outlined':
        return Icons.moving_outlined;
      case 'folder_copy_outlined':
        return Icons.folder_copy_outlined;
      case 'supervisor_account_outlined':
        return Icons.supervisor_account_outlined;
      case 'school_outlined':
        return Icons.school_outlined;
      case 'manage_accounts_outlined':
        return Icons.manage_accounts_outlined;
      case 'trending_up_outlined':
        return Icons.trending_up_outlined;
      case 'payments_outlined':
        return Icons.payments_outlined;
      case 'group_add_outlined':
        return Icons.group_add_outlined;
      case 'settings_outlined':
        return Icons.settings_outlined;
      case 'people_outline_sharp':
        return Icons.people_outline_sharp;
      case 'ac_unit_outlined':
        return Icons.ac_unit_outlined;
      case 'flight':
        return Icons.flight;
      default:
        return Icons.star;
    }
  }

  var listItems = [
    {'name': 'home', 'value': 'home'},
    {'name': 'moving_outlined', 'value': 'moving_outlined'},
    {'name': 'folder_copy_outlined', 'value': 'folder_copy_outlined'},
    {
      'name': 'supervisor_account_outlined',
      'value': 'supervisor_account_outlined'
    },
    {'name': 'school_outlined', 'value': 'school_outlined'},
    {'name': 'manage_accounts_outlined', 'value': 'manage_accounts_outlined'},
    {'name': 'trending_up_outlined', 'value': 'trending_up_outlined'},
    {'name': 'payments_outlined', 'value': 'payments_outlined'},
    {'name': 'group_add_outlined', 'value': 'group_add_outlined'},
    {'name': 'settings_outlined', 'value': 'settings_outlined'},
    {'name': 'people_outline_sharp', 'value': 'people_outline_sharp'},
    {'name': 'home_outlined', 'value': 'home_outlined'},
    {'name': 'ac_unit_outlined', 'value': 'ac_unit_outlined'},
    {'name': 'flight', 'value': 'flight'},
  ];
  @override
  // ignore: must_call_super
  void initState() {
    getFeatureFuture = getFeature();
    setState(() {});
  }

  TextEditingController name = TextEditingController();
  TextEditingController detail = TextEditingController();
  TextEditingController navigation = TextEditingController();
  TextEditingController order = TextEditingController();
  TextEditingController code = TextEditingController();
  dynamic selectedValue = 'ac_unit_outlined';
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: getFeatureFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
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
              width: 800,
              height: 660,
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
                              child: DropdownBtnSearch(
                                isAll: false,
                                flexLabel: 3,
                                label: 'Kiểu',
                                listItems: itemsIsGroup,
                                isSearch: false,
                                selectedValue: selectedIsGroup,
                                setSelected: (selected) {
                                  selectedIsGroup = selected;
                                  setState(() {});
                                },
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: TextFieldValidatedForm(
                                  label: 'Tên chức năng',
                                  type: 'Text',
                                  height: 40,
                                  controller: name,
                                ))
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 30),
                              child: DropdownBtnSearch(
                                isAll: false,
                                flexLabel: 3,
                                label: 'Nhóm chức năng',
                                listItems: itemsFeatureDropdown,
                                isSearch: true,
                                search: TextEditingController(),
                                selectedValue: selectedRole,
                                setSelected: (selected) {
                                  selectedRole = selected;
                                  setState(() {});
                                },
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: TextFieldValidatedForm(
                                  label: 'Code',
                                  type: 'Text',
                                  height: 40,
                                  controller: code,
                                ))
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: TextFieldValidatedForm(
                                  height: 40,
                                  type: 'None',
                                  label: 'Mô tả',
                                  controller: detail,
                                ))
                              ],
                            ),
                            selectedIsGroup == '1'
                                ? Row(
                                    children: [
                                      Expanded(
                                          child: TextFieldValidatedForm(
                                        height: 40,
                                        type: 'Text',
                                        label: 'Url',
                                        controller: navigation,
                                      ))
                                    ],
                                  )
                                : Container(),

                            selectedIsGroup == '1' && isMenu == true
                                ? Row(
                                    children: [
                                      Expanded(
                                          child: TextFieldValidatedForm(
                                        height: 40,
                                        type: 'Number',
                                        label: 'Thứ tự hiển thị',
                                        controller: order,
                                      ))
                                    ],
                                  )
                                : Container(),
                            Container(
                              margin: EdgeInsets.only(bottom: 30),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 40,
                                    child: Checkbox(
                                      checkColor: Colors.white,
                                      value: isMenu,
                                      onChanged: (value) {
                                        setState(() {
                                          isMenu = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  Expanded(
                                      child: Text(
                                    'Hiển thị ngoài menu',
                                    style: titleWidgetBox,
                                  ))
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 30),
                              child: DropdownBtnSearch(
                                isAll: false,
                                flexLabel: 3,
                                label: 'Trạng thái',
                                listItems: itemsStatus,
                                isSearch: false,
                                selectedValue: selectedStatus,
                                setSelected: (selected) {
                                  selectedStatus = selected;
                                  setState(() {});
                                },
                              ),
                            ),
                            isMenu
                                ? Row(
                                    children: [
                                      Expanded(
                                          flex: 3,
                                          child: Text(
                                            "Icon",
                                            style: titleWidgetBox,
                                          )),
                                      Expanded(
                                          flex: 5,
                                          child: Container(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.25,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                            ),
                                            height: 40,
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton2(
                                                hint: Text("Chọn thông tin"),
                                                isExpanded: true,
                                                items: [
                                                  for (var row in listItems)
                                                    DropdownMenuItem<String>(
                                                      value: row['value'],
                                                      child: Icon(
                                                          iconMenuByParams(
                                                              row['name'])),
                                                    )
                                                ],
                                                value: selectedValue,
                                                onChanged: (value) {
                                                  selectedValue = value;
                                                  setState(() {});
                                                },
                                                dropdownDecoration:
                                                    BoxDecoration(
                                                        border: Border.all(
                                                            color: const Color
                                                                    .fromRGBO(
                                                                216,
                                                                218,
                                                                229,
                                                                1))),
                                                buttonDecoration: BoxDecoration(
                                                    border: Border.all(
                                                        width: 1,
                                                        color: Colors.black)),
                                                buttonElevation: 0,
                                                buttonPadding:
                                                    const EdgeInsets.only(
                                                        left: 14, right: 14),
                                                itemPadding:
                                                    const EdgeInsets.only(
                                                        left: 14, right: 14),
                                                dropdownElevation: 5,
                                                focusColor: Colors.white,
                                                dropdownMaxHeight: 300,
                                              ),
                                            ),
                                          ))
                                    ],
                                  )
                                : Container(),
                            SizedBox(
                              height: 25,
                            ),
                            Container(
                              margin: EdgeInsets.only(bottom: 30),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Nhóm quyền',
                                        style: titleWidgetBox,
                                      )),
                                ],
                              ),
                            ),
                            DataTable(columns: [
                              DataColumn(
                                  label: Text('Nhóm quyền',
                                      style: titleTableData)),
                              DataColumn(
                                  label: Text('Xem', style: titleTableData)),
                              DataColumn(
                                  label: Text('Sửa', style: titleTableData)),
                              DataColumn(
                                  label: Text('Xóa', style: titleTableData)),
                              DataColumn(
                                  label: Text('Thêm', style: titleTableData)),
                              DataColumn(
                                  label:
                                      Text('Thực thi', style: titleTableData)),
                            ], rows: <DataRow>[
                              for (var row in listRoleGroup)
                                DataRow(cells: <DataCell>[
                                  DataCell(Row(
                                    children: [
                                      Text(row['roleName'] ?? 'nodata'),
                                    ],
                                  )),
                                  DataCell(
                                    Checkbox(
                                      checkColor: Colors.white,
                                      value: row[1],
                                      onChanged: (value) {
                                        setState(() {
                                          row[1] = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  DataCell(
                                    Checkbox(
                                      checkColor: Colors.white,
                                      value: row[2],
                                      onChanged: (value) {
                                        setState(() {
                                          row[2] = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  DataCell(
                                    Checkbox(
                                      checkColor: Colors.white,
                                      value: row[3],
                                      onChanged: (value) {
                                        setState(() {
                                          row[3] = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  DataCell(
                                    Checkbox(
                                      checkColor: Colors.white,
                                      value: row[4],
                                      onChanged: (value) {
                                        setState(() {
                                          row[4] = value!;
                                        });
                                      },
                                    ),
                                  ),
                                  DataCell(
                                    Checkbox(
                                      checkColor: Colors.white,
                                      value: row[5],
                                      onChanged: (value) {
                                        setState(() {
                                          row[5] = value!;
                                        });
                                      },
                                    ),
                                  )
                                ])
                            ]),
                            // Container(
                            //     margin: EdgeInsets.only(bottom: 30),
                            //     child: Row(
                            //       children: [
                            //         Expanded(
                            //             child: TableNhomQuyen(
                            //                 listNhomQuyen: widget.listNhomQuyen)),
                            //       ],
                            //     ))
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
                  bool checkExitst = true;
                  bool validated = true;
                  bool checkUrl = true;
                  if (selectedIsGroup == '1') {
                    for (var row in listCheckExitst) {
                      if (row['navigation'] == navigation.text) {
                        checkExitst = false;
                        break;
                      }
                    }
                  }
                  if (selectedIsGroup == '1' &&
                      navigation.text.isNotEmpty &&
                      navigation.text[0] != '/') {
                    checkUrl = false;
                  }
                  if (selectedIsGroup == '1') {
                    if (name.text.isEmpty ||
                        code.text.isEmpty ||
                        navigation.text.isEmpty) {
                      validated = false;
                    }
                    if (isMenu && order.text.isEmpty) {
                      validated = false;
                    }
                    if (!isMenu) {
                      order.text = '0';
                    }
                    if (!isNumber(order.text)) {
                      validated = false;
                    }
                  } else {
                    order.text = '0';
                    if (name.text.isEmpty || code.text.isEmpty) {
                      validated = false;
                    }
                  }
                  if (validated == false) {
                    showToast(
                      context: context,
                      msg:
                          'Yêu cầu nhập đủ dữ liệu trước khi thêm mới hoặc chỉnh sửa',
                      color: Colors.red,
                      icon: const Icon(Icons.warning),
                    );
                  } else if (checkExitst == false) {
                    showToast(
                      context: context,
                      msg: 'URL đã tồn tại',
                      color: Colors.red,
                      icon: const Icon(Icons.warning),
                    );
                  } else if (checkUrl == false) {
                    showToast(
                      context: context,
                      msg: 'URL phải bắt đầu bằng "/"',
                      color: Colors.red,
                      icon: const Icon(Icons.warning),
                    );
                  } else if (validated == true &&
                      checkExitst == true &&
                      checkUrl == true) {
                    if (widget.row != null) {
                      var listAddAll = [];
                      for (var row in listRoleGroup) {
                        if (row[1] == true) {
                          listAddAll.add({
                            'moduleId': widget.row['id'],
                            'roleId': row['id'],
                            'permissionId': 1
                          });
                        }
                        if (row[2] == true) {
                          listAddAll.add({
                            'moduleId': widget.row['id'],
                            'roleId': row['id'],
                            'permissionId': 2
                          });
                        }
                        if (row[3] == true) {
                          listAddAll.add({
                            'moduleId': widget.row['id'],
                            'roleId': row['id'],
                            'permissionId': 3
                          });
                        }
                        if (row[4] == true) {
                          listAddAll.add({
                            'moduleId': widget.row['id'],
                            'roleId': row['id'],
                            'permissionId': 4
                          });
                        }
                        if (row[5] == true) {
                          listAddAll.add({
                            'moduleId': widget.row['id'],
                            'roleId': row['id'],
                            'permissionId': 5
                          });
                        }
                      }
                      await deleteRoleFeature();
                      await addRoleFeature(listAddAll);
                      await updateFeature();
                    } else {
                      await addFeature();
                      var listAddAll = [];
                      if (newId != null)
                        for (var row in listRoleGroup) {
                          if (row[1] == true) {
                            listAddAll.add({
                              'moduleId': newId,
                              'roleId': row['id'],
                              'permissionId': 1
                            });
                          }
                          if (row[2] == true) {
                            listAddAll.add({
                              'moduleId': newId,
                              'roleId': row['id'],
                              'permissionId': 2
                            });
                          }
                          if (row[3] == true) {
                            listAddAll.add({
                              'moduleId': newId,
                              'roleId': row['id'],
                              'permissionId': 3
                            });
                          }
                          if (row[4] == true) {
                            listAddAll.add({
                              'moduleId': newId,
                              'roleId': row['id'],
                              'permissionId': 4
                            });
                          }
                          if (row[5] == true) {
                            listAddAll.add({
                              'moduleId': newId,
                              'roleId': row['id'],
                              'permissionId': 5
                            });
                          }
                        }
                      await addRoleFeature(listAddAll);
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
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return Center(child: const CircularProgressIndicator());
      },
    );
  }
}
