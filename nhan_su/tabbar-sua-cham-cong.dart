// ignore_for_file: must_be_immutable, unused_import, undefined_hidden_name
import 'dart:convert';
import 'dart:html';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/nhan_su/them-moi-cham-cong.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../../../api.dart';
import '../../../common/style.dart';
import '../../../common/toast.dart';
import '../../../config.dart';
import '../../../model/model.dart';
import '../../forms/nhan_su/setting-data/userAAM.dart';
import '../../forms/nhan_su/ver1-cham-cong.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column, Row, Border;

import '../../forms/nhan_su/ver1-update-cham-cong.dart';

class TabBarSuaChamCong extends StatefulWidget {
  var listNVCC;
  TabBarSuaChamCong({this.listNVCC});
  @override
  State<TabBarSuaChamCong> createState() => TabBarSuaChamCongState();
}

class TabBarSuaChamCongState extends State<TabBarSuaChamCong> with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: widget.listNVCC.keys.length, vsync: this);
  DateFormat dateFormat = DateFormat("dd-MMM-yyyy");
  int selectedNV = 0;
  Future<List<UserAAM>> getListUser({lisUserCode}) async {
    List<UserAAM> listUserAAM = [];
    // print("object:$lisUserCode");
    String findUser = "";
    for (var item in lisUserCode) {
      findUser += "or userCode~'*$item*'";
    }
    if (findUser.length > 0) findUser = findUser.substring(3);
    var response2 = await httpGet("/api/nguoidung/get/page?filter=isAam:1&filter=$findUser", context);
    if (response2.containsKey("body")) {
      var body = jsonDecode(response2['body']);
      var content = [];
      setState(() {
        content = body['content'];
        listUserAAM = content.map((e) {
          return UserAAM.fromJson(e);
        }).toList();
      });
    }
    return listUserAAM;
  }

  var listNVCC;
  var userAAM;
  late UserAAM selectedNVAAM;
  @override
  void initState() {
    super.initState();
    listNVCC = widget.listNVCC;
    selectedNVAAM = UserAAM(userCode: "${listNVCC.keys.first}", fullName: "${listNVCC[listNVCC.keys.first][0].fullName}");
  }

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return Container(
      height: 1900,
      child: DefaultTabController(
        length: listNVCC.keys.length,
        initialIndex: selectedNV,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 20, right: 20, top: 20),
              decoration: BoxDecoration(
                color: colorWhite,
                borderRadius: borderRadiusContainer,
                boxShadow: [boxShadowContainer],
                border: borderAllContainerBox,
              ),
              padding: EdgeInsets.only(top: 20, left: 30, right: 30, bottom: 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      // margin: EdgeInsets.only(bottom: 30),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text('Nhân viên:', style: titleWidgetBox),
                          ),
                          Expanded(
                              flex: 5,
                              child: Container(
                                color: Colors.white,
                                width: MediaQuery.of(context).size.width * 0.20,
                                height: 40,
                                child: DropdownSearch<UserAAM>(
                                  // hint: "Chọn",
                                  maxHeight: 250,
                                  mode: Mode.MENU,
                                  showSearchBox: true,
                                  onFind: (String? filter) => getListUser(lisUserCode: listNVCC.keys.toList()),
                                  itemAsString: (UserAAM? u) => u!.fullName.toString() + " - " + u.userCode.toString(),
                                  dropdownSearchDecoration: styleDropDown,
                                  selectedItem: selectedNVAAM,
                                  onChanged: (value) {
                                    for (var i = 0; i < listNVCC.keys.length; i++) {
                                      if (listNVCC.keys.toList()[i] == value?.userCode) {
                                        setState(() {
                                          selectedNV = i;
                                        });
                                        _tabController.index = i;
                                        print(selectedNV);
                                      }
                                    }
                                  },
                                ),
                              )),
                        ],
                      ),
                    ),
                  ),
                  Expanded(flex: 4, child: Container()),
                  SizedBox(width: 25),
                ],
              ),
            ),
            Container(
              // color: Colors.red,
              margin: EdgeInsets.only(left: 20, right: 20, top: 20),
              constraints: BoxConstraints.expand(height: 50),
              padding: EdgeInsets.only(left: 20, right: 20),
              child: TabBar(
                onTap: (value) {
                  print(value);
                  setState(() {
                    selectedNVAAM =
                        UserAAM(userCode: "${listNVCC.keys.toList()[value]}", fullName: "${listNVCC[listNVCC.keys.toList()[value]][0].fullName}");
                  });
                },
                isScrollable: true,
                indicatorColor: mainColorPage,
                controller: _tabController,
                tabs: [
                  for (var element in listNVCC.keys)
                    (listNVCC[element][0].short > 0)
                        ? Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: mainColorPage,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "${listNVCC[element][0].fullName}\n${listNVCC[element][0].userCode}",
                                style: titleTabbar,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(color: Color.fromARGB(255, 250, 181, 91), borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: Text(
                                    "${listNVCC[element][0].short}",
                                    style: TextStyle(color: colorWhite, fontSize: 10),
                                  ),
                                ),
                              )
                            ],
                          )
                        : Row(
                            children: [
                              Icon(
                                Icons.person,
                                color: mainColorPage,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                "${listNVCC[element][0].fullName}\n${listNVCC[element][0].userCode}",
                                style: titleTabbar,
                              ),
                            ],
                          )
                ],
              ),
            ),
            Expanded(
              child: TabBarView(controller: _tabController, children: [
                for (var element in listNVCC.keys)
                  UpdateVer1CC(
                    timeKeepingData: listNVCC[element],
                    callBack: (value) {
                      setState(() {});
                    },
                  ),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
