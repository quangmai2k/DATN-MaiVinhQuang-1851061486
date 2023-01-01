// ignore_for_file: unused_local_variable, unrelated_type_equality_checks

import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../../../forms/nhan_su/setting-data/depart.dart';

class BoPhan extends StatefulWidget {
  const BoPhan({Key? key}) : super(key: key);

  @override
  State<BoPhan> createState() => _BoPhanState();
}

class _BoPhanState extends State<BoPhan> with TickerProviderStateMixin {
  //lấy ra các bộ phận cha
  List<Depart> resultPhongBanCha = [];
  Future<List<Depart>> getPhongBanCha() async {
    var response1 = await httpGet("/api/phongban/get/page?sort=id,asc", context);
    var body = jsonDecode(response1['body']);
    var content = [];
    if (response1.containsKey("body")) {
      setState(() {
        content = body['content'];
        for (var element in content) {
          Depart item = Depart(id: element['id'], departName: element['departName']);
          resultPhongBanCha.add(item);
        }
      });
    }
    return resultPhongBanCha;
  }

  Future<List<Roles>> getRoles() async {
    List<Roles> resultRoles = [];
    var response1 = await httpGet("/api/nhomquyen/get/page?sort=id,asc", context);
    var body = jsonDecode(response1['body']);
    var content = [];
    if (response1.containsKey("body")) {
      setState(() {
        content = body['content'];
        resultRoles = content.map((e) {
          return Roles.fromJson(e);
        }).toList();
        Roles all = Roles(id: 0, roleName: 'Không');
        resultRoles.insert(0, all);
      });
    }
    return resultRoles;
  }

  List<BoPhanClass> listBoPhan = [];
  late Future<List<BoPhanClass>> futureResult;
  Future<List<BoPhanClass>> getBoPhan(Depart departCha) async {
    setState(() {
      listBoPhan = [];
      isSwitched = [];
    });
    var response;
    if (departCha.id == 0) {
      if (find != "")
        response = await httpGet("/api/phongban/get/page?filter=deleted:false $find&sort=id", context);
      else
        response = await httpGet("/api/phongban/get/page?filter=parentId:${departCha.id}$find&sort=id", context);
    } else {
      if (find != "")
        response = await httpGet("/api/phongban/get/page?filter=parentId:${departCha.id}$find&sort=id", context);
      else
        response = await httpGet("/api/phongban/get/page?filter=id:${departCha.id}&sort=id", context);
    }

    if (response.containsKey("body")) {
      var body = jsonDecode(response['body']);
      var content = body['content'];
      if (content.length > 0) {
        for (var element in content) {
          BoPhanClass item = BoPhanClass(
            id: element['id'],
            departName: element['departName'],
            departCode: element['departCode'],
            parentId: element['parentId'],
            defaultPage: element['defaultPage'],
            status: element['status'],
            rolesId: 0,
            rolesName: "",
            statusRoles: false,
            idPBRoles: 0,
          );
          var responseRoles = await httpGet("/api/phongban-nhomquyen/get/page?filter=departId:${item.id}", context);
          if (responseRoles.containsKey("body")) {
            var bodyRolse = jsonDecode(responseRoles['body']);
            var contentRoles = bodyRolse['content'];
            if (contentRoles.length > 0) {
              item.rolesId = contentRoles.first['roleId'];
              item.rolesName = contentRoles.first['nhomquyen']['roleName'];
              item.statusRoles = true;
              item.idPBRoles = contentRoles.first['id'];
            }
          }
          setState(() {
            listBoPhan.add(item);
            if (item.status == 0)
              isSwitched.add(false);
            else
              isSwitched.add(true);
          });
        }
        // if (find == "") {}
        int start = 0;
        while (start < listBoPhan.length) {
          List<BoPhanClass> abc = await getBoPhanCon(listBoPhan[start]);
          setState(() {
            listBoPhan.addAll(abc);
          });
          start += 1;
        }
      }
      return listBoPhan;
    }
    return listBoPhan;
  }

  Future<List<BoPhanClass>> getBoPhanCon(BoPhanClass boPhanClass) async {
    List<BoPhanClass> listPBCha = [];
    var response = await httpGet("/api/phongban/get/page?filter=parentId:${boPhanClass.id}$find", context);
    if (response.containsKey("body")) {
      var body = jsonDecode(response['body']);
      var content;
      content = body['content'];
      if (content.length > 0) {
        for (var element in content) {
          BoPhanClass item = BoPhanClass(
            id: element['id'],
            departName: element['departName'],
            departCode: element['departCode'],
            parentId: element['parentId'],
            parentName: boPhanClass.departName,
            defaultPage: element['defaultPage'],
            status: element['status'],
            rolesId: 0,
            rolesName: "",
            statusRoles: false,
            idPBRoles: 0,
          );
          var responseRoles = await httpGet("/api/phongban-nhomquyen/get/page?filter=departId:${item.id}", context);
          if (responseRoles.containsKey("body")) {
            var bodyRolse = jsonDecode(responseRoles['body']);
            var contentRoles = bodyRolse['content'];
            if (contentRoles.length > 0) {
              item.rolesId = contentRoles.first['roleId'];
              item.rolesName = contentRoles.first['nhomquyen']['roleName'];
              item.statusRoles = true;
              item.idPBRoles = contentRoles.first['id'];
            }
          }
          listPBCha.add(item);
          setState(() {
            if (item.status == 0)
              isSwitched.add(false);
            else
              isSwitched.add(true);
          });
        }
      }
      return listPBCha;
    }

    return listPBCha;
  }

  Depart selectedBP1 = Depart(id: 0, departName: 'Không');
  Future<List<Depart>> getPhongBan() async {
    List<Depart> resultPhongBan = [];
    var response1 = await httpGet("/api/phongban/get/page?sort=id,asc&filter=status:1", context);
    var body = jsonDecode(response1['body']);
    var content = [];
    if (response1.containsKey("body")) {
      setState(() {
        content = body['content'];
        for (var element in content) {
          if (element['id'] > 2) {
            Depart item = Depart(id: element['id'], departName: element['departName']);
            resultPhongBan.add(item);
          }
        }
      });
      Depart all = Depart(id: 0, departName: 'Không');
      resultPhongBan.insert(0, all);
    }
    return resultPhongBan;
  }

  Future<List<Depart>> getPhongBanSearch() async {
    List<Depart> resultPhongBan = [];
    var response1 = await httpGet("/api/phongban/get/page?sort=id,asc", context);
    var body = jsonDecode(response1['body']);
    var content = [];
    if (response1.containsKey("body")) {
      setState(() {
        content = body['content'];
        for (var element in content) {
          if (element['id'] > 2) {
            Depart item = Depart(id: element['id'], departName: element['departName'], departCode: element['departCode']);
            resultPhongBan.add(item);
          }
        }
      });
      Depart all = Depart(id: 0, departName: 'Không');
      resultPhongBan.insert(0, all);
    }
    return resultPhongBan;
  }

  Future<List<Depart>> getPhongBanUpdate(int? id) async {
    print("id:$id");
    List<Depart> resultPhongBan = [];
    var response1 = await httpGet("/api/phongban/get/page?sort=id,asc&filter=id!$id", context);
    var body = jsonDecode(response1['body']);
    var content = [];
    if (response1.containsKey("body")) {
      setState(() {
        content = body['content'];
        for (var element in content) {
          if (element['id'] > 2) {
            Depart item = Depart(id: element['id'], departName: element['departName']);
            resultPhongBan.add(item);
          }
        }
      });
      Depart all = Depart(id: 0, departName: 'Không');
      resultPhongBan.insert(0, all);
    }
    return resultPhongBan;
  }

  Depart selectedBPTK = Depart(id: 0, departName: 'Không');
  bool checkSTT = false;
  bool checkClose = true;
  TextEditingController maBP = TextEditingController();
  TextEditingController tenBP = TextEditingController();
  String find = "";

  void callAPI() async {
    await getPhongBanCha();
    await getBoPhan(selectedBP1);
    setState(() {
      checkSTT = true;
    });
  }

  List<bool> isSwitched = [];

  @override
  void initState() {
    super.initState();
    callAPI();
  }

  @override
  void dispose() {
    maBP.dispose();
    tenBP.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationModel>(
      builder: (context, navigationModel, child) => SingleChildScrollView(
        controller: ScrollController(),
        child: Container(
          padding: paddingBoxContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(
                  color: colorWhite,
                  borderRadius: borderRadiusContainer,
                  boxShadow: [boxShadowContainer],
                  border: borderAllContainerBox,
                ),
                padding: paddingBoxContainer,
                // transform: Matrix4.rotationX(2),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nhập thông tin',
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
                    //   mainAxisAlignment: MainAxisAlignment.start,
                    //   children: [
                    //     TextFieldValidated(
                    //       label: 'Mã phòng ban',
                    //       type: 'None',
                    //       height: 40,
                    //       controller: maBP,
                    //       onChanged: (value) {},
                    //     ),
                    //     SizedBox(width: 100),
                    //     TextFieldValidated(
                    //       label: 'Tên phòng ban',
                    //       type: 'None',
                    //       height: 40,
                    //       controller: tenBP,
                    //       onChanged: (value) {},
                    //     ),
                    //     Expanded(flex: 2, child: Container()),
                    //   ],
                    // ),
                    // SizedBox(
                    //   height: 25,
                    // ),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text('Nhóm', style: titleWidgetBox),
                              ),
                              Expanded(
                                  flex: 5,
                                  child: Container(
                                    color: Colors.white,
                                    width: MediaQuery.of(context).size.width * 0.20,
                                    height: 40,
                                    child: DropdownSearch<Depart>(
                                      mode: Mode.MENU,
                                      maxHeight: 250,
                                      showSearchBox: true,
                                      onFind: (String? filter) => getPhongBanSearch(),
                                      itemAsString: (Depart? u) => (u!.departCode != null) ? "${u.departCode} - ${u.departName}" : "${u.departName}",
                                      dropdownSearchDecoration: styleDropDown,
                                      selectedItem: selectedBPTK,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedBPTK = value!;

                                          // if (selectedBP != -1) getDNTDChiTiet(selectedBP);
                                        });
                                      },
                                    ),
                                  )),
                            ],
                          ),
                        ),
                        SizedBox(width: 100),
                        Expanded(
                          flex: 5,
                          child: Container(),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 20),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20.0,
                                  horizontal: 30.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                primary: Theme.of(context).iconTheme.color,
                                textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                              ),
                              onPressed: () async {
                                find = "";
                                var findMaBP = "";
                                var findTenBP = "";
                                if (maBP.text != "")
                                  findMaBP = "and departCode~'*${maBP.text}*' ";
                                else
                                  findMaBP = "";
                                if (tenBP.text != "")
                                  findTenBP = "and departName~'*${tenBP.text}*' ";
                                else
                                  findTenBP = "";
                                find = findMaBP + findTenBP;
                                print(find);

                                getBoPhan(selectedBPTK);
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text('Tìm kiếm', style: textButton),
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
                                  horizontal: 30.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                primary: Theme.of(context).iconTheme.color,
                                textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                              ),
                              onPressed: () async {
                                String maBPN = "";
                                String tenBPN = "";
                                String pageMacDinh = "";
                                Depart selectedBP1 = Depart(id: 0, departName: 'Không');
                                Roles selectedRoles1 = Roles(id: 0, roleName: 'Không');
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) => AlertDialog(
                                          title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
                                                    'Thêm mới phòng ban',
                                                    style: titleAlertDialog,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () => {Navigator.pop(context)},
                                              icon: Icon(
                                                Icons.close,
                                              ),
                                            ),
                                          ]),
                                          content: Container(
                                            padding: EdgeInsets.only(right: 10, left: 10),
                                            width: 500,
                                            height: 300,
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    TextFieldValidated(
                                                      label: 'Mã phòng ban:',
                                                      type: 'None',
                                                      height: 40,
                                                      requiredValue: 1,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          maBPN = value;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 20),
                                                Row(
                                                  children: [
                                                    TextFieldValidated(
                                                      label: 'Tên phòng ban:',
                                                      type: 'None',
                                                      height: 40,
                                                      requiredValue: 1,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          tenBPN = value;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 20),
                                                Container(
                                                  height: 40,
                                                  // margin: EdgeInsets.only(bottom: 30),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text('Phòng ban:', style: titleWidgetBox),
                                                      ),
                                                      Expanded(
                                                          flex: 5,
                                                          child: Container(
                                                            color: Colors.white,
                                                            width: MediaQuery.of(context).size.width * 0.20,
                                                            height: 40,
                                                            child: DropdownSearch<Depart>(
                                                              mode: Mode.MENU,
                                                              maxHeight: 250,
                                                              showSearchBox: true,
                                                              onFind: (String? filter) => getPhongBan(),
                                                              itemAsString: (Depart? u) => u!.departName,
                                                              dropdownSearchDecoration: styleDropDown,
                                                              selectedItem: selectedBP1,
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  selectedBP1 = value!;
                                                                });
                                                              },
                                                            ),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 20),
                                                Container(
                                                  height: 40,
                                                  // margin: EdgeInsets.only(top: 30),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        flex: 2,
                                                        child: Text('Nhóm quyền:', style: titleWidgetBox),
                                                      ),
                                                      Expanded(
                                                          flex: 5,
                                                          child: Container(
                                                            color: Colors.white,
                                                            width: MediaQuery.of(context).size.width * 0.20,
                                                            height: 40,
                                                            child: DropdownSearch<Roles>(
                                                              mode: Mode.MENU,
                                                              maxHeight: 250,
                                                              showSearchBox: true,
                                                              onFind: (String? filter) => getRoles(),
                                                              itemAsString: (Roles? u) => u!.roleName!,
                                                              dropdownSearchDecoration: styleDropDown,
                                                              selectedItem: selectedRoles1,
                                                              onChanged: (value) {
                                                                setState(() {
                                                                  selectedRoles1 = value!;
                                                                });
                                                              },
                                                            ),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(height: 20),
                                                Row(
                                                  children: [
                                                    TextFieldValidated(
                                                      label: 'Trang mặc định:',
                                                      type: 'None',
                                                      height: 40,
                                                      requiredValue: 1,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          pageMacDinh = value;
                                                        });
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () async {
                                                if (maBPN != "" && tenBPN != "" && pageMacDinh != "") {
                                                  showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) => AlertDialog(
                                                            title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
                                                                      'Xác nhận thêm mới phòng ban',
                                                                      style: titleAlertDialog,
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              IconButton(
                                                                onPressed: () => {Navigator.pop(context)},
                                                                icon: Icon(
                                                                  Icons.close,
                                                                ),
                                                              ),
                                                            ]),
                                                            content: Text("Thêm mới phòng ban: $tenBPN"),
                                                            actions: [
                                                              ElevatedButton(
                                                                onPressed: () async {
                                                                  var body = {
                                                                    "departName": tenBPN,
                                                                    "departCode": maBPN,
                                                                    "parentId": selectedBP1.id,
                                                                    "defaultPage": pageMacDinh,
                                                                    "status": 1
                                                                  };
                                                                  var response = await httpPost("/api/phongban/post/save", body, context);
                                                                  if (response.containsKey('body')) {
                                                                    var responseBody = jsonDecode(response['body']);
                                                                    var check = int.tryParse(responseBody.toString());
                                                                    if (check != null) {
                                                                      if (selectedRoles1.id > 0) {
                                                                        var response1 = await httpPost("/api/phongban-nhomquyen/post/save",
                                                                            {"departId": check, "roleId": selectedRoles1.id}, context);
                                                                        print("response1:$response1");
                                                                      }
                                                                      Navigator.pop(context);
                                                                      Navigator.pop(context);
                                                                      setState(() {
                                                                        listBoPhan.insert(
                                                                            0,
                                                                            BoPhanClass(
                                                                              departCode: maBPN,
                                                                              departName: tenBPN,
                                                                              parentId: selectedBP1.id,
                                                                              defaultPage: pageMacDinh,
                                                                              parentName: selectedBP1.departName,
                                                                              status: 1,
                                                                              rolesId: (selectedRoles1.id != 0) ? selectedRoles1.id : null,
                                                                              rolesName: selectedRoles1.roleName,
                                                                              statusRoles: (selectedRoles1.id != 0) ? true : false,
                                                                            ));
                                                                      });
                                                                      showToast(
                                                                        context: context,
                                                                        msg: "Đã thêm mới một phòng ban và đã kích hoạt",
                                                                        color: mainColorPage,
                                                                        icon: const Icon(Icons.done),
                                                                      );
                                                                    } else
                                                                      showToast(
                                                                        context: context,
                                                                        msg: "Thêm mới lỗi, kiểm tra lại mã và tên phòng ban",
                                                                        color: colorOrange,
                                                                        icon: const Icon(Icons.warning),
                                                                      );
                                                                  } else
                                                                    showToast(
                                                                      context: context,
                                                                      msg: "Thêm mới lỗi",
                                                                      color: colorOrange,
                                                                      icon: const Icon(Icons.warning),
                                                                    );
                                                                },
                                                                child: Text('Lưu'),
                                                                style: ElevatedButton.styleFrom(
                                                                  primary: mainColorPage,
                                                                  onPrimary: colorWhite,
                                                                  minimumSize: Size(100, 40),
                                                                ),
                                                              ),
                                                              ElevatedButton(
                                                                onPressed: () => Navigator.pop(context),
                                                                child: Text('Hủy'),
                                                                style: ElevatedButton.styleFrom(
                                                                  primary: colorOrange,
                                                                  onPrimary: colorWhite,
                                                                  elevation: 3,
                                                                  minimumSize: Size(100, 40),
                                                                ),
                                                              ),
                                                            ],
                                                          ));
                                                } else {
                                                  showToast(
                                                    context: context,
                                                    msg: "Điền đầy đủ thông tin",
                                                    color: colorOrange,
                                                    icon: const Icon(Icons.warning),
                                                  );
                                                }
                                              },
                                              child: Text(
                                                'Lưu',
                                                style: TextStyle(),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                primary: mainColorPage,
                                                onPrimary: colorWhite,
                                                elevation: 3,
                                                minimumSize: Size(100, 40),
                                              ),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(context),
                                              child: Text('Hủy'),
                                              style: ElevatedButton.styleFrom(
                                                primary: colorOrange,
                                                onPrimary: colorWhite,
                                                elevation: 3,
                                                minimumSize: Size(100, 40),
                                              ),
                                            ),
                                          ],
                                        ));
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text('Thêm mới', style: textButton),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              (checkSTT)
                  ? Container(
                      margin: marginTopBoxContainer,
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
                                'Kết quả tìm kiếm: ${listBoPhan.length} phòng ban',
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
                                        showCheckboxColumn: false,
                                        // columnSpacing: 20,
                                        horizontalMargin: 10,
                                        dataRowHeight: 60,
                                        columns: [
                                          DataColumn(label: Text('STT', style: titleTableData)),
                                          DataColumn(label: Text('Mã phòng ban', style: titleTableData)),
                                          DataColumn(label: Text('Tên phòng ban', style: titleTableData)),
                                          DataColumn(label: Text('Nhóm', style: titleTableData)),
                                          DataColumn(label: Text('Trang mặc định', style: titleTableData)),
                                          DataColumn(label: Text('Hành động', style: titleTableData)),
                                        ],
                                        rows: <DataRow>[
                                          for (int i = 0; i < listBoPhan.length; i++)
                                            DataRow(
                                              cells: <DataCell>[
                                                DataCell(Text("${i + 1}")),
                                                DataCell(Text(listBoPhan[i].departCode != null ? "${listBoPhan[i].departCode}" : "")),
                                                DataCell(Text(listBoPhan[i].departName != null ? "${listBoPhan[i].departName}" : "")),
                                                DataCell(Text((listBoPhan[i].parentId != null && listBoPhan[i].parentId != 0)
                                                    ? "${listBoPhan[i].parentName ?? ""}"
                                                    : "")),
                                                DataCell(Text(listBoPhan[i].defaultPage != null ? "${listBoPhan[i].defaultPage}" : "")),
                                                DataCell(
                                                  Row(
                                                    children: [
                                                      Container(
                                                          margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                          child: InkWell(
                                                            onTap: () {
                                                              TextEditingController maBPN =
                                                                  TextEditingController(text: listBoPhan[i].departCode ?? "");
                                                              TextEditingController tenBPN =
                                                                  TextEditingController(text: listBoPhan[i].departName ?? "");
                                                              TextEditingController pageMacDinh =
                                                                  TextEditingController(text: listBoPhan[i].defaultPage ?? "");
                                                              Depart selectedBP2 = Depart(id: 0, departName: 'Không');
                                                              Roles selectedRoles2 = Roles(id: 0, roleName: 'Không');

                                                              setState(() {
                                                                if (listBoPhan[i].parentId! > 0)
                                                                  selectedBP2 = Depart(
                                                                      id: listBoPhan[i].parentId ?? 0, departName: '${listBoPhan[i].parentName}');
                                                                if (listBoPhan[i].rolesId! > 0) {
                                                                  selectedRoles2 =
                                                                      Roles(id: listBoPhan[i].rolesId!, roleName: listBoPhan[i].rolesName);
                                                                }
                                                              });
                                                              int? status = listBoPhan[i].status;
                                                              int ipPhongBan = selectedBP2.id;
                                                              showDialog(
                                                                  context: context,
                                                                  builder: (BuildContext context) => AlertDialog(
                                                                        title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
                                                                                  'Cập nhật phòng ban',
                                                                                  style: titleAlertDialog,
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          IconButton(
                                                                            onPressed: () => {Navigator.pop(context)},
                                                                            icon: Icon(
                                                                              Icons.close,
                                                                            ),
                                                                          ),
                                                                        ]),
                                                                        content: Container(
                                                                          padding: EdgeInsets.only(right: 10, left: 10),
                                                                          width: 500,
                                                                          height: 300,
                                                                          child: Column(
                                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              Row(
                                                                                children: [
                                                                                  TextFieldValidated(
                                                                                    label: 'Mã phòng ban:',
                                                                                    type: 'None',
                                                                                    height: 40,
                                                                                    requiredValue: 1,
                                                                                    controller: maBPN,
                                                                                    onChanged: (value) {},
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              SizedBox(height: 20),
                                                                              Row(
                                                                                children: [
                                                                                  TextFieldValidated(
                                                                                    label: 'Tên phòng ban:',
                                                                                    type: 'None',
                                                                                    height: 40,
                                                                                    requiredValue: 1,
                                                                                    controller: tenBPN,
                                                                                    onChanged: (value) {},
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              SizedBox(height: 20),
                                                                              Container(
                                                                                height: 40,
                                                                                // margin: EdgeInsets.only(bottom: 30),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    Expanded(
                                                                                      flex: 2,
                                                                                      child: Text('Phòng ban:', style: titleWidgetBox),
                                                                                    ),
                                                                                    Expanded(
                                                                                        flex: 5,
                                                                                        child: Container(
                                                                                          color: Colors.white,
                                                                                          width: MediaQuery.of(context).size.width * 0.20,
                                                                                          height: 40,
                                                                                          child: DropdownSearch<Depart>(
                                                                                            mode: Mode.MENU,
                                                                                            maxHeight: 250,
                                                                                            showSearchBox: true,
                                                                                            onFind: (String? filter) =>
                                                                                                getPhongBanUpdate(listBoPhan[i].id),
                                                                                            itemAsString: (Depart? u) => u!.departName,
                                                                                            dropdownSearchDecoration: styleDropDown,
                                                                                            selectedItem: selectedBP2,
                                                                                            onChanged: (value) {
                                                                                              setState(() {
                                                                                                selectedBP2 = value!;
                                                                                              });
                                                                                            },
                                                                                          ),
                                                                                        )),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              SizedBox(height: 20),
                                                                              Container(
                                                                                height: 40,
                                                                                // margin: EdgeInsets.only(top: 30),
                                                                                child: Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                                                  children: [
                                                                                    Expanded(
                                                                                      flex: 2,
                                                                                      child: Text('Nhóm quyền:', style: titleWidgetBox),
                                                                                    ),
                                                                                    Expanded(
                                                                                        flex: 5,
                                                                                        child: Container(
                                                                                          color: Colors.white,
                                                                                          width: MediaQuery.of(context).size.width * 0.20,
                                                                                          height: 40,
                                                                                          child: DropdownSearch<Roles>(
                                                                                            mode: Mode.MENU,
                                                                                            maxHeight: 250,
                                                                                            showSearchBox: true,
                                                                                            onFind: (String? filter) => getRoles(),
                                                                                            itemAsString: (Roles? u) => u!.roleName!,
                                                                                            dropdownSearchDecoration: styleDropDown,
                                                                                            selectedItem: selectedRoles2,
                                                                                            onChanged: (value) {
                                                                                              setState(() {
                                                                                                selectedRoles2 = value!;
                                                                                              });
                                                                                            },
                                                                                          ),
                                                                                        )),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                              SizedBox(height: 20),
                                                                              Row(
                                                                                children: [
                                                                                  TextFieldValidated(
                                                                                    label: 'Trang mặc định:',
                                                                                    type: 'None',
                                                                                    height: 40,
                                                                                    requiredValue: 1,
                                                                                    controller: pageMacDinh,
                                                                                    onChanged: (value) {},
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        actions: [
                                                                          ElevatedButton(
                                                                            onPressed: () async {
                                                                              if (maBPN.text != "" && tenBPN.text != "" && pageMacDinh.text != "") {
                                                                                showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) => AlertDialog(
                                                                                          title: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                              children: [
                                                                                                SizedBox(
                                                                                                  child: Row(
                                                                                                    children: [
                                                                                                      Container(
                                                                                                        width: 40,
                                                                                                        height: 40,
                                                                                                        child:
                                                                                                            Image.asset('assets/images/logoAAM.png'),
                                                                                                        margin: EdgeInsets.only(right: 10),
                                                                                                      ),
                                                                                                      Text(
                                                                                                        'Xác cập nhật phòng ban',
                                                                                                        style: titleAlertDialog,
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                                IconButton(
                                                                                                  onPressed: () => {Navigator.pop(context)},
                                                                                                  icon: Icon(
                                                                                                    Icons.close,
                                                                                                  ),
                                                                                                ),
                                                                                              ]),
                                                                                          content: Text(""),
                                                                                          actions: [
                                                                                            ElevatedButton(
                                                                                              onPressed: () async {
                                                                                                var body = {
                                                                                                  "departName": tenBPN.text,
                                                                                                  "departCode": maBPN.text,
                                                                                                  "parentId": selectedBP2.id,
                                                                                                  "defaultPage": pageMacDinh.text,
                                                                                                  "status": status
                                                                                                };
                                                                                                var response = await httpPut(
                                                                                                    "/api/phongban/put/${listBoPhan[i].id}",
                                                                                                    body,
                                                                                                    context);
                                                                                                if (response.containsKey('body')) {
                                                                                                  var responseBody = jsonDecode(response['body']);
                                                                                                  if (responseBody == true) {
                                                                                                    if (listBoPhan[i].statusRoles == false) {
                                                                                                      if (selectedRoles2.id > 0) {
                                                                                                        print("thêm");
                                                                                                        await httpPost(
                                                                                                            "/api/phongban-nhomquyen/post/save",
                                                                                                            {
                                                                                                              "departId": listBoPhan[i].id,
                                                                                                              "roleId": selectedRoles2.id
                                                                                                            },
                                                                                                            context);
                                                                                                      }
                                                                                                    } else {
                                                                                                      if (selectedRoles2.id > 0) {
                                                                                                        print("sửa");
                                                                                                        await httpPut(
                                                                                                            "/api/phongban-nhomquyen/put/${listBoPhan[i].rolesId}",
                                                                                                            {
                                                                                                              "departId": listBoPhan[i].id,
                                                                                                              "roleId": selectedRoles2.id
                                                                                                            },
                                                                                                            context);
                                                                                                      } else {
                                                                                                        print("xóa");
                                                                                                        var a = await httpDelete(
                                                                                                            "/api/phongban-nhomquyen/del/${listBoPhan[i].idPBRoles}",
                                                                                                            context);
                                                                                                        listBoPhan[i].statusRoles = false;
                                                                                                        print(a);
                                                                                                      }
                                                                                                    }
                                                                                                    Navigator.pop(context);
                                                                                                    Navigator.pop(context);
                                                                                                    setState(() {
                                                                                                      listBoPhan[i] = BoPhanClass(
                                                                                                        departCode: maBPN.text,
                                                                                                        departName: tenBPN.text,
                                                                                                        parentId: selectedBP2.id,
                                                                                                        parentName: selectedBP2.departName,
                                                                                                        defaultPage: pageMacDinh.text,
                                                                                                        status: status,
                                                                                                        rolesId: (selectedRoles2.id != 0)
                                                                                                            ? selectedRoles2.id
                                                                                                            : null,
                                                                                                        rolesName: selectedRoles2.roleName,
                                                                                                        statusRoles:
                                                                                                            (selectedRoles2.id != 0) ? true : false,
                                                                                                      );
                                                                                                    });

                                                                                                    showToast(
                                                                                                      context: context,
                                                                                                      msg: "Cập nhật thành công",
                                                                                                      color: mainColorPage,
                                                                                                      icon: const Icon(Icons.done),
                                                                                                    );
                                                                                                  } else
                                                                                                    showToast(
                                                                                                      context: context,
                                                                                                      msg: "Cập nhật lỗi",
                                                                                                      color: colorOrange,
                                                                                                      icon: const Icon(Icons.warning),
                                                                                                    );
                                                                                                } else
                                                                                                  showToast(
                                                                                                    context: context,
                                                                                                    msg: "Cập nhật lỗi",
                                                                                                    color: colorOrange,
                                                                                                    icon: const Icon(Icons.warning),
                                                                                                  );
                                                                                              },
                                                                                              child: Text('Lưu'),
                                                                                              style: ElevatedButton.styleFrom(
                                                                                                primary: mainColorPage,
                                                                                                onPrimary: colorWhite,
                                                                                                minimumSize: Size(100, 40),
                                                                                              ),
                                                                                            ),
                                                                                            ElevatedButton(
                                                                                              onPressed: () => Navigator.pop(context),
                                                                                              child: Text('Hủy'),
                                                                                              style: ElevatedButton.styleFrom(
                                                                                                primary: colorOrange,
                                                                                                onPrimary: colorWhite,
                                                                                                elevation: 3,
                                                                                                minimumSize: Size(100, 40),
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ));
                                                                              } else {
                                                                                showToast(
                                                                                  context: context,
                                                                                  msg: "Điền đầy đủ thông tin",
                                                                                  color: colorOrange,
                                                                                  icon: const Icon(Icons.warning),
                                                                                );
                                                                              }
                                                                            },
                                                                            child: Text(
                                                                              'Lưu',
                                                                              style: TextStyle(),
                                                                            ),
                                                                            style: ElevatedButton.styleFrom(
                                                                              primary: mainColorPage,
                                                                              onPrimary: colorWhite,
                                                                              elevation: 3,
                                                                              minimumSize: Size(100, 40),
                                                                            ),
                                                                          ),
                                                                          ElevatedButton(
                                                                            onPressed: () => Navigator.pop(context),
                                                                            child: Text('Hủy'),
                                                                            style: ElevatedButton.styleFrom(
                                                                              primary: colorOrange,
                                                                              onPrimary: colorWhite,
                                                                              elevation: 3,
                                                                              minimumSize: Size(100, 40),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ));
                                                            },
                                                            child: Icon(Icons.edit_calendar, color: Color(0xff009C87)),
                                                          )),
                                                      Container(
                                                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                        child: Tooltip(
                                                            message: (isSwitched[i]) ? 'Đã kích hoạt' : 'Chưa kích hoạt',
                                                            textStyle: const TextStyle(fontSize: 15, color: Colors.white),
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(25),
                                                              color: (isSwitched[i]) ? mainColorPage : colorOrange,
                                                            ),
                                                            child: Switch(
                                                              onChanged: (value) async {
                                                                setState(() {
                                                                  isSwitched[i] = value;
                                                                });
                                                                // print("value:$value     i:$i");
                                                                if (isSwitched[i] == false) {
                                                                  var response =
                                                                      await httpPut("/api/phongban/put/${listBoPhan[i].id}", {"status": 0}, context);
                                                                  showToast(
                                                                      context: context,
                                                                      msg: "Đã hủy kích hoạt phòng ban",
                                                                      color: colorOrange,
                                                                      icon: const Icon(Icons.done),
                                                                      timeHint: 1);
                                                                } else {
                                                                  var response =
                                                                      await httpPut("/api/phongban/put/${listBoPhan[i].id}", {"status": 1}, context);
                                                                  showToast(
                                                                      context: context,
                                                                      msg: "Đã kích hoạt phòng ban",
                                                                      color: mainColorPage,
                                                                      icon: const Icon(Icons.done),
                                                                      timeHint: 1);
                                                                }
                                                              },
                                                              value: isSwitched[i],
                                                              activeColor: mainColorPage,
                                                              activeTrackColor: Color(0xfffcccccc),
                                                              inactiveThumbColor: Color.fromARGB(255, 158, 158, 158),
                                                              inactiveTrackColor: Color(0xfffcccccc),
                                                            )),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                // DynamicTablePagging(
                                //   rowCount,
                                //   currentPage,
                                //   rowPerPage,
                                //   pageChangeHandler: (page) {
                                //     setState(() {
                                //       futureResult = getBoPhan(page - 1);
                                //       currentPage = page - 1;
                                //     });
                                //   },
                                //   rowPerPageChangeHandler: (rowPerPage) {
                                //     setState(() {
                                //       this.rowPerPage = rowPerPage!;
                                //       this.firstRow = page * currentPage;
                                //       futureResult = getBoPhan(0);
                                //     });
                                //   },
                                // ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(child: const CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}

class BoPhanClass {
  int? id;
  String? departCode;
  String? departName;
  int? parentId;
  String? parentName;
  String? defaultPage;
  int? status;
  int? rolesId;
  String? rolesName;
  bool? statusRoles;
  int? idPBRoles;
  BoPhanClass({
    Key? key,
    this.id,
    this.departCode,
    this.departName,
    this.parentId,
    this.parentName,
    this.defaultPage,
    this.status,
    this.rolesId,
    this.rolesName,
    this.statusRoles,
    this.idPBRoles,
  });
}
