import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';

import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';

class FormQuanLyNguoiDung extends StatefulWidget {
  const FormQuanLyNguoiDung({Key? key}) : super(key: key);

  @override
  State<FormQuanLyNguoiDung> createState() => _FormQuanLyNguoiDungState();
}

class TableUsers {
  String id;
  String name;
  String userName;
  String passWord;
  String email;
  String status;
  String permission;
  String userLink;
  bool selected = false;
  TableUsers(this.id, this.name, this.userName, this.passWord, this.email,
      this.userLink, this.permission, this.status);
}

class _FormQuanLyNguoiDungState extends State<FormQuanLyNguoiDung> {
  late List<TableUsers> listSelectedRow;
  var listUser;
  late int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 10;
  TextEditingController userName = TextEditingController();
  TextEditingController email = TextEditingController();

  late Future<dynamic> getAccountFuture;
  getAccount(currentPage) async {
    String query = '';
    if (selectedUserType != '-1') {
      if (selectedUserType == '0') {
        query = 'and isTts:1';
      } else if (selectedUserType == '1') {
        query = 'and isAam:1';
      } else {
        query = 'and isCtv:1';
      }
    }
    var response = await httpGet(
        "/api/nguoidung/get/page?size=$rowPerPage&page=${currentPage - 1}&filter=(userName~'*${userName.text}*' or fullName~'*${userName.text}*') and email~'*${email.text}*' and userName!'admin' $query",
        context);
    if (response.containsKey("body")) {
      listUser = jsonDecode(response["body"])['content'];
      rowCount = jsonDecode(response["body"])['totalElements'];
      setState(() {});
      return listUser;
    } else
      throw Exception("Error load data");
  }

  dynamic selectedUserType = '-1';
  List<dynamic> itemsUserType = [
    {'name': 'Nhân viên', 'value': '1'},
    {'name': 'Thực tập sinh', 'value': '0'},
    {'name': 'Cộng tác viên', 'value': '2'},
  ];
  @override
  void initState() {
    getAccountFuture = getAccount(1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundPage,
      padding: EdgeInsets.symmetric(
          vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
      child: SingleChildScrollView(
          controller: ScrollController(),
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
                      flex: 8,
                      child: TextFieldValidatedForm(
                          flexLable: 3,
                          controller: userName,
                          type: 'None',
                          label: 'Họ và tên/Tên đăng nhập',
                          height: 40)),
                  SizedBox(
                    width: 100,
                  ),
                  Expanded(
                      flex: 7,
                      child: TextFieldValidatedForm(
                          controller: email,
                          flexLable: 2,
                          type: 'None',
                          label: 'Email',
                          height: 40)),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 8,
                    child: DropdownBtnSearch(
                      isAll: true,
                      flexLabel: 3,
                      label: 'Đối tượng',
                      listItems: itemsUserType,
                      isSearch: false,
                      selectedValue: selectedUserType,
                      setSelected: (selected) {
                        selectedUserType = selected;
                        setState(() {});
                      },
                    ),
                  ),
                  SizedBox(
                    width: 100,
                  ),
                  Expanded(flex: 7, child: Container()),
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
                            ?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                      ),
                      onPressed: () {
                        getAccountFuture = getAccount(1);
                      },
                      child: Row(
                        children: [
                          Text('Tìm kiếm ', style: textButton),
                          const Icon(
                            Icons.near_me,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Container(
                  //   margin: EdgeInsets.only(left: 20),
                  //   child: TextButton(
                  //     style: TextButton.styleFrom(
                  //       padding: const EdgeInsets.symmetric(
                  //         vertical: 20.0,
                  //         horizontal: 10.0,
                  //       ),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(5.0),
                  //       ),
                  //       backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                  //       primary: Theme.of(context).iconTheme.color,
                  //       textStyle: Theme.of(context)
                  //           .textTheme
                  //           .caption
                  //           ?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                  //     ),
                  //     onPressed: () {
                  //       showDialog(
                  //         context: context,
                  //         builder: (BuildContext context) => AddUpdateUser(
                  //           titleDialog: 'Thêm mới người dùng',
                  //           function: () {},
                  //         ),
                  //       );
                  //     },
                  //     child: Row(
                  //       children: [
                  //         Text('Thêm mới', style: textButton),
                  //       ],
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Danh sách người dùng ',
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
                future: getAccountFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var tableIndex = (currentPageDef - 1) * rowPerPage + 1;
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
                                      'ID',
                                      style: titleTableData,
                                    )),
                                    DataColumn(
                                        label: Text('Họ và tên',
                                            style: titleTableData)),
                                    DataColumn(
                                        label: Text('Tên đăng nhập',
                                            style: titleTableData)),
                                    DataColumn(
                                        label: Text('Email',
                                            style: titleTableData)),
                                    DataColumn(
                                        label: Text('Trạng thái',
                                            style: titleTableData)),
                                    DataColumn(
                                        label: Text('Chỉnh sửa',
                                            style: titleTableData)),
                                  ],
                                  rows: <DataRow>[
                                    for (var row in listUser)
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
                                              Text('${tableIndex++}',
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
                                                    row['fullName'] ??
                                                        "No data",
                                                    style: bangDuLieu),
                                              ),
                                            ),
                                            DataCell(
                                              Text(row['userName'] ?? "No data",
                                                  style: bangDuLieu),
                                            ),
                                            DataCell(
                                              Text(
                                                  row['email'] == null ||
                                                          row['email'].isEmpty
                                                      ? "Không có email"
                                                      : row['email'],
                                                  style: bangDuLieu),
                                            ),
                                            DataCell(
                                              Text(
                                                  row['isBlocked'] == 1
                                                      ? "Đã khóa"
                                                      : "Không khóa",
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
                                                              AddUpdateUser(
                                                            row: row,
                                                            titleDialog: 'Sửa',
                                                            function: () {
                                                              getAccountFuture =
                                                                  getAccount(
                                                                      currentPageDef);
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
                        DynamicTablePagging(
                            rowCount, currentPageDef, rowPerPage,
                            pageChangeHandler: (currentPage) {
                          setState(() {
                            getAccountFuture = getAccount(currentPage);
                            currentPageDef = currentPage;
                          });
                        }, rowPerPageChangeHandler: (rowPerPageChange) {
                          currentPageDef = 1;

                          rowPerPage = rowPerPageChange;
                          getAccountFuture = getAccount(currentPageDef);
                          setState(() {});
                        })
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
          )),
    );
  }
}

// Pop-up chỉnh sửa
// ignore: must_be_immutable
class AddUpdateUser extends StatefulWidget {
  String titleDialog;
  dynamic row;
  Function function;
  AddUpdateUser(
      {Key? key, required this.titleDialog, this.row, required this.function})
      : super(key: key);

  @override
  State<AddUpdateUser> createState() => AddUpdateUserState();
}

class AddUpdateUserState extends State<AddUpdateUser> {
  var row;
  var roleUser;
  var role;
  var listRole = [];
  late String titleLog;
  late Future<dynamic> getRoleUserFuture;
  getRole() async {
    var response = await httpGet("/api/nhomquyen/get/page", context);
    if (response.containsKey("body")) {
      role = jsonDecode(response["body"])['content'];
      for (var row in role) {
        listRole.add({
          'id': row['id'],
          'roleName': row['roleName'],
          'value': false,
          'updated': false
        });
      }
      setState(() {});
      return role;
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

  updateUser() async {
    for (var addRole in listRole) {
      if (addRole['updated'] == true) {
        if (addRole['value'] == true) {
          await addRoleUser(addRole['id']);
        } else {
          await deleteRoleUser(addRole['roleUserId']);
        }
      }
    }
    row['isBlocked'] = int.parse(selectedTT);
    if (selectedTT == '1') {
      row['blockedReason'] = blockedReason.text;
    }
    var response =
        await httpPut("/api/nguoidung/put/${row['id']}", row, context);
    print(response);
    if (jsonDecode(response["body"]).containsKey("1")) {
      titleLog = 'Cập nhật dữ liệu thành công';
    } else {
      titleLog = 'Cập nhật thất bại';
    }
    return 0;
  }

  addRoleUser(roleId) async {
    var data = {'userId': row['id'], 'roleId': roleId};
    var response =
        await httpPost("/api/nguoidung-nhomquyen/post/save", data, context);
    if (isNumber(response['body'])) {
      print('Thêm mới dữ liệu thành công');
      return response['body'];
    } else {
      print('Thêm mới thất bại');
    }
    return 0;
  }

  deleteRoleUser(id) async {
    var response =
        await httpDelete("/api/nguoidung-nhomquyen/del/$id", context);
    print("/api/nguoidung-nhomquyen/del/$id");
    print(response);
    if (jsonDecode(response["body"]) == true) {
      print("Xóa thành công");
    } else {
      print("Xóa thất bại");
    }
    return 0;
  }

  getRoleUser() async {
    await getRole();
    var response = await httpGet(
        "/api/nguoidung-nhomquyen/get/page?filter=userId:${row['id']}",
        context);
    if (response.containsKey("body")) {
      roleUser = jsonDecode(response["body"])['content'];
      for (var role in roleUser) {
        for (var row in listRole) {
          if (role['roleId'] == row['id']) {
            row['value'] = true;
            row['roleUserId'] = role['id'];
            break;
          }
        }
      }
      setState(() {});
      return roleUser;
    } else
      throw Exception("Error load data");
  }

  @override
  void initState() {
    super.initState();
    if (widget.row != null) {
      getRoleUserFuture = getRoleUser();
      row = widget.row;
      selectedTT = row['isBlocked'].toString();
      blockedReason.text = row['blockedReason'] ?? '';
    } else {
      getRoleUserFuture = getRole();
    }
  }

  TextEditingController userName = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController blockedReason = TextEditingController();

  String selectedTT = '0';
  List<dynamic> itemsTT = [
    {'name': 'Đã khóa', 'value': '1'},
    {'name': 'Không khóa', 'value': '0'},
  ];

  List<String> itemsStatus = ['Khóa', 'Không khóa'];
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
        width: 750,
        height: 400,
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
                        child: row != null
                            ? Row(
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Tên đăng nhập',
                                        style: titleWidgetBox,
                                      )),
                                  Expanded(
                                      flex: 5, child: Text(row['userName']))
                                ],
                              )
                            : Row(
                                children: [
                                  TextFieldValidated(
                                    type: 'Text',
                                    height: 40,
                                    label: 'Tên đăng nhập',
                                    flexLable: 3,
                                    controller: userName,
                                  ),
                                ],
                              ),
                      ),
                      widget.row != null && widget.row['isAam'] == 1
                          ? Container(
                              margin: EdgeInsets.only(bottom: 30),
                              child: Row(
                                children: [
                                  Text(
                                    'Nhóm quyền',
                                    style: titleWidgetBox,
                                  ),
                                ],
                              ),
                            )
                          : Container(),
                      widget.row != null && widget.row['isAam'] == 1
                          ? Container(
                              margin: EdgeInsets.only(bottom: 30),
                              child: FutureBuilder<dynamic>(
                                future: getRoleUserFuture,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return NhomQuyen(
                                      listRole: listRole,
                                      callBack: (value) {
                                        listRole = value;
                                      },
                                    );
                                  } else if (snapshot.hasError) {
                                    return Text('${snapshot.error}');
                                  }

                                  // By default, show a loading spinner.
                                  return const CircularProgressIndicator();
                                },
                              ))
                          : Container(),
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
                            setState(() {});
                          },
                        ),
                      ),
                      selectedTT == '1'
                          ? Container(
                              margin: EdgeInsets.only(bottom: 30),
                              child: Row(
                                children: [
                                  TextFieldValidated(
                                    type: 'Text',
                                    height: 40,
                                    label: 'Lý do khóa tài khoản',
                                    flexLable: 3,
                                    controller: blockedReason,
                                  ),
                                ],
                              ),
                            )
                          : Container(),
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
            bool validated = true;
            if (selectedTT == '1') {
              if (blockedReason.text.isEmpty) {
                validated = false;
              }
            }
            if (validated == true) {
              await updateUser();
              widget.function();
              showToast(
                context: context,
                msg: titleLog,
                color: titleLog == 'Cập nhật dữ liệu thành công'
                    ? Color.fromARGB(136, 72, 238, 67)
                    : Colors.red,
                icon: titleLog == 'Cập nhật dữ liệu thành công'
                    ? Icon(Icons.done)
                    : Icon(Icons.warning),
              );
              Navigator.pop(context);
            } else {
              showToast(
                context: context,
                msg:
                    'Yêu cầu nhập đủ dữ liệu trước khi thêm mới hoặc chỉnh sửa',
                color: Colors.red,
                icon: const Icon(Icons.warning),
              );
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
class NhomQuyen extends StatefulWidget {
  dynamic listRole;
  Function callBack;
  NhomQuyen({Key? key, this.listRole, required this.callBack})
      : super(key: key);

  @override
  State<NhomQuyen> createState() => _NhomQuyenState();
}

class _NhomQuyenState extends State<NhomQuyen> {
  List<String> title = [];
  List<bool> valuesList = [];
  var listRole;
  @override
  // ignore: must_call_super
  void initState() {
    listRole = widget.listRole;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 25.0,
      spacing: 5.0,
      children: [
        for (var row in listRole)
          Container(
            width: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Checkbox(
                    checkColor: Colors.white,
                    value: row['value'],
                    onChanged: (value) {
                      row['value'] = value;
                      row['updated'] = !row['updated'];
                      widget.callBack(listRole);
                      setState(() {});
                    },
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    row['roleName'],
                    style: TextStyle(
                      color: Color(0xff333333),
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
          ),
      ],
    );
  }
}
