import 'dart:convert';
import 'dart:html';
import "package:collection/collection.dart";
import 'dart:js' as js;

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/api.dart';
import 'package:gentelella_flutter/common/style.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import 'package:gentelella_flutter/config.dart';
import 'package:gentelella_flutter/model/model.dart';
import 'package:gentelella_flutter/widgets/ui/menu/list_tile_nav.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../config.dart';

class HeaderAndNavigation extends StatefulWidget {
  final Widget widgetBody;
  const HeaderAndNavigation({Key? key, required this.widgetBody})
      : super(key: key);

  @override
  State<HeaderAndNavigation> createState() => _HeaderAndNavigationState();
}

class _HeaderAndNavigationState extends State<HeaderAndNavigation> {
  String getFirstWord(String? text) {
    try {
      if (text != null) {
        return text.isNotEmpty
            ? text.trim().split(' ').map((l) => l[0]).take(2).join()
            : '';
      }
    } catch (e) {
      print("Ex" + e.toString());
    }
    return '';
  }

  String getFirsText(String? text) {
    try {
      if (text != null) {
        return text.isNotEmpty ? text.trim().split(' ')[0] : "";
      }
    } catch (e) {
      print("Ex" + e.toString());
    }
    return '';
  }

  var listNavigation;
  var listMenu = [];
  var listGroup = [];
  var listGroupBy;
  String currentPath = '';
  @override
  void initState() {
    currentPath = getUrl2();
    for (var row
        in Provider.of<SecurityModel>(context, listen: false).listMenu) {
      if (row['isMenu'] == 1 &&
          row['isGroup'] == 1 &&
          row['navigation'] == "/$currentPath") {
        Provider.of<SecurityModel>(context, listen: false)
            .storage
            .setItem("currentState", row['id']);
        Provider.of<SecurityModel>(context, listen: false)
            .storage
            .getItem("currentState");
      }
    }
    // getNavigation();
  }

  // IconData iconMenu(menuCode) {
  //   switch (menuCode) {
  //     case 'DMD':
  //       return Icons.moving_outlined;
  //     case 'IP':
  //       return Icons.folder_copy_outlined;
  //     case 'FGP':
  //       return Icons.supervisor_account_outlined;
  //     case 'EDU':
  //       return Icons.school_outlined;
  //     case 'CTL':
  //       return Icons.manage_accounts_outlined;
  //     case 'JMD':
  //       return Icons.trending_up_outlined;
  //     case 'ACCT':
  //       return Icons.payments_outlined;
  //     case 'HR':
  //       return Icons.group_add_outlined;
  //     case 'SYSTEM':
  //       return Icons.settings_outlined;
  //     default:
  //       return Icons.ac_unit_outlined;
  //   }
  // }
  String ruleName(departId, level) {
    if (departId == 1) {
      return 'Quản trị viên';
    } else if (departId == 2) {
      return 'Chủ tịch';
    } else if (departId == 7) {
      if (level == 0) {
        return 'Giáo viên';
      } else if (level == 1) {
        return 'Kế toán';
      } else if (level == 2) {
        return 'Quản lý';
      } else if (level == 3) {
        return 'Hiệu trường';
      }
    } else {
      if (level == 0) {
        return 'Nhân viên';
      } else if (level == 1) {
        return 'Trưởng phòng';
      } else if (level == 2) {
        return 'Giám đốc';
      }
    }
    return 'Không xác định';
  }

//Lấy loại icon cho menu
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
      case 'flight':
        return Icons.flight;
      default:
        return Icons.star;
    }
  }

  Widget getAvartar(user) {
    try {
      if (user.userLoginCurren != null) {
        if (user.userLoginCurren['avatar'].isNotEmpty) {
          return CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                "$baseUrl/api/files/${user.userLoginCurren['avatar']}",
              ));
        }
      }
    } catch (e) {
      // print(e);
    }

    return Container();
  }

  dynamic channel;
  String getUrl2() {
    if (Provider.of<NavigationModel>(context, listen: false).currentUrl !=
        null) {
      String url =
          Provider.of<NavigationModel>(context, listen: false).currentUrl!;
      String path = url.split("/")[1];
      return "$path";
    } else {
      var url = window.location.href;
      String path = url.split("/")[4];
      return path;
    }
  }

  bool checkShow = true;

  bool showMenu = true;
  late double widthMenu;
  late double widthContent;
  String? noti;
  var appBarHeight = AppBar().preferredSize.height;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    Size size = MediaQuery.of(context).size;
    int flexMenu = 2;

    if (showMenu == true) {
      if (width > 1600) {
        flexMenu = 2;
      } else if (width > 1000) {
        flexMenu = 3;
      }
    } else {
      flexMenu = 0;
    }
    widthMenu = width * flexMenu * 0.1;

    return Material(
      child: Consumer2<NavigationModel, SecurityModel>(
          builder: (context, navigationModel, user, child) {
        try {
          if (Provider.of<SecurityModel>(context, listen: false)
                  .userLoginCurren !=
              null)
            js.context.callMethod("initCall", [
              Provider.of<SecurityModel>(context, listen: false)
                  .userLoginCurren['departId']
            ]);
        } catch (e) {}
        try {
          js.context.callMethod("initOneSignal", []);
        } catch (e) {
          print(e);
        }
        try {
          if (Provider.of<SecurityModel>(context, listen: false)
                  .userLoginCurren !=
              null) {
            var user = Provider.of<SecurityModel>(context, listen: false)
                .userLoginCurren;
            js.context.callMethod("addUserTag", [
              user['id'],
              user['userCode'],
              user['userName'],
              user['phone'],
              user['email'],
              user['departId'],
              user['teamId'],
              user['vaitro'] != null ? user['vaitro']['level'] : 0,
            ]);
          }
        } catch (e) {}
        listMenu = [];
        listGroup = [];
        for (var row in user.listMenu) {
          if (row['isMenu'] == 1) {
            if (row['parentId'] == 0) {
              listMenu.add(row);
            } else {
              listGroup.add(row);
            }
          }
        }
        listGroupBy = groupBy(listGroup, (dynamic obj) => obj['parentId']);
        return Scaffold(
            body: Container(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: flexMenu,
                    child: Container(
                      decoration: BoxDecoration(
                        boxShadow: [boxShadowContainer],
                        // borderRadius: BorderRadius.only(
                        //     bottomRight: Radius.circular(10),
                        //     bottomLeft: Radius.circular(10)),
                        border: Border.all(width: 0, color: Color(0xffDADADA)),
                        color: Color(0xff459A88),
                      ),
                      // margin: EdgeInsets.only(right: 10),
                      width: widthMenu,
                      child: widthMenu != 0
                          ? Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(top: 20),
                                    child: SingleChildScrollView(
                                      controller: ScrollController(),
                                      child: Column(
                                        children: <Widget>[
                                          //Trang chủ
                                          for (var row in listMenu)
                                            if (row['isGroup'] == 1)
                                              Container(
                                                margin: EdgeInsets.fromLTRB(
                                                    20, 5, 20, 5),
                                                decoration: BoxDecoration(
                                                  color: Color(0xff459A88),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                child: TextButton.icon(
                                                  icon: Icon(
                                                    iconMenuByParams(
                                                        row['params']),
                                                    color: Provider.of<SecurityModel>(
                                                                    context,
                                                                    listen:
                                                                        false)
                                                                .storage
                                                                .getItem(
                                                                    "currentState") ==
                                                            row['id']
                                                        ? Colors.orange[400]
                                                        : Colors.white,
                                                  ),
                                                  label: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                6, 15, 20, 15),
                                                        child: Text(
                                                          row['moduleName'],
                                                          style: TextStyle(
                                                              color: Provider.of<SecurityModel>(
                                                                              context,
                                                                              listen:
                                                                                  false)
                                                                          .storage
                                                                          .getItem(
                                                                              "currentState") ==
                                                                      row['id']
                                                                  ? Colors.orange[
                                                                      400]
                                                                  : Colors
                                                                      .white,
                                                              fontSize: 16,
                                                              fontWeight: "/$currentPath" ==
                                                                      row[
                                                                          'navigation']
                                                                  ? FontWeight
                                                                      .w600
                                                                  : FontWeight
                                                                      .w500),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  onPressed: () {
                                                    navigationModel.add(
                                                        pageUrl:
                                                            row['navigation']);
                                                  },
                                                ),
                                              )
                                            else
                                              TitleNavBar(
                                                listMenu:
                                                    listGroupBy[row['id']] !=
                                                            null
                                                        ? listGroupBy[row['id']]
                                                        : [],
                                                iconExpansionTile:
                                                    iconMenuByParams(
                                                        row['params']),
                                                titleExpansionTile:
                                                    row['moduleName'],
                                                navigationModel:
                                                    navigationModel,
                                              ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                    ),
                  ),
                  Expanded(
                    flex: flexMenu == 2 ? 8 : 11,
                    child: Column(
                      children: [
                        Expanded(
                            flex: flexMenu == 2 ? 8 : 11,
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: borderRadiusContainer,
                                  boxShadow: [boxShadowContainer],
                                  border: borderAllContainerBox,
                                ),
                                child: widget.widgetBody)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(70.0),
              child: Container(
                decoration: BoxDecoration(
                  // border: Border(
                  //   bottom: BorderSide(
                  //     width: 2,
                  //     color: Color(0xff459A88),
                  //   ),
                  // ),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color:
                          Color.fromARGB(255, 187, 185, 185).withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 5,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Custom drawer icon
                    AppBar(
                      automaticallyImplyLeading: false,
                      leading: Builder(
                        builder: (BuildContext context) {
                          return IconButton(
                            icon: Icon(
                              showMenu ? Icons.menu_open_outlined : Icons.menu,
                              size: 22,
                              color: Color(
                                  0xff459A88), // Change Custom Drawer Icon Color
                            ),
                            onPressed: () {
                              showMenu = !showMenu;
                              setState(() {});
                            },
                            tooltip: MaterialLocalizations.of(context)
                                .openAppDrawerTooltip,
                          );
                        },
                      ),
                      backgroundColor: Colors.transparent, // 1
                      elevation: 0,
                      title: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.asset(
                              "assets/images/logoAAM.png",
                              width: 45,
                              height: 45,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            'HỆ THỐNG QUẢN LÝ NGHIỆP VỤ XUẤT KHẨU LAO ĐỘNG',
                            style: TextStyle(
                              color: Color(0xffF77919),
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                      actions: <Widget>[
                        MenuPopupTest(),
                        SizedBox(
                          width: 20,
                        ),
                        PopupMenuButton<String>(
                          tooltip: 'Thông tin cá nhân',
                          offset: Offset(0.0, appBarHeight + 8),
                          child: SizedBox(
                            width: size.width * 0.11,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Color(0xffFDCF09),
                                  child: Row(
                                    children: [getAvartar(user)],
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(
                                    user.userLoginCurren != null
                                        ? user.userLoginCurren['fullName']
                                            .toString()
                                        : "",
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(color: Colors.black87),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                              ],
                            ),
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              enabled: false,
                              child: Container(
                                decoration: const BoxDecoration(
                                    border: Border(bottom: BorderSide())),
                                child: Column(
                                  children: [
                                    TextButton(
                                      style: TextButton.styleFrom(
                                        padding:
                                            EdgeInsets.fromLTRB(10, 20, 0, 20),
                                        minimumSize: Size(50, 30),
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Color(0xffFDCF09),
                                            child: Row(
                                              children: [getAvartar(user)],
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 20,
                                          ),
                                          Text(
                                            user.userLoginCurren != null
                                                ? user
                                                    .userLoginCurren['fullName']
                                                    .toString()
                                                : "",
                                            overflow: TextOverflow.fade,
                                            maxLines: 1,
                                            style: titleWidgetBox,
                                          )
                                        ],
                                      ),
                                      onPressed: () {
                                        navigationModel.add(
                                            pageUrl:
                                                "/view-hsns/${user.userLoginCurren['id']}");
                                      },
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          bottom: 20, top: 10),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                              flex: 2,
                                              child: Text(
                                                'Chức vụ:',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.black,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              )),
                                          Expanded(
                                              flex: 5,
                                              child: Text(
                                                  user.userLoginCurren[
                                                              'vaitro'] !=
                                                          null
                                                      ? user.userLoginCurren[
                                                          'vaitro']['name']
                                                      : 'Không xác định',
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w600)))
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            const PopupMenuItem(
                              enabled: false,
                              child: Text(
                                'Cài đặt',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.blueGrey,
                                ),
                              ),
                              padding: EdgeInsets.fromLTRB(30, 0, 30, 0),
                            ),
                            PopupMenuItem(
                              child: ListTile(
                                leading: Container(
                                    width: 30,
                                    height: 30,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                        color:
                                            Color.fromARGB(235, 209, 209, 209)),
                                    child: Icon(Icons.key)),
                                contentPadding: const EdgeInsets.all(0),
                                hoverColor: Colors.transparent,
                                title: const Text(
                                  'Đổi mật khẩu',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                onTap: (() {
                                  Provider.of<NavigationModel>(context,
                                          listen: false)
                                      .add(pageUrl: "/change-password");
                                }),
                              ),
                              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                            ),
                            PopupMenuItem(
                              child: ListTile(
                                leading: Container(
                                    width: 30,
                                    height: 30,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                        color:
                                            Color.fromARGB(235, 209, 209, 209)),
                                    child: Icon(Icons.logout)),
                                contentPadding: const EdgeInsets.all(0),
                                hoverColor: Colors.transparent,
                                title: const Text(
                                  'Đăng xuất',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                onTap: (() {
                                  Provider.of<NavigationModel>(context,
                                          listen: false)
                                      .add(pageUrl: "/login-page");
                                  Future.delayed(
                                      const Duration(milliseconds: 500), () {
                                    user.logout();
                                  });
                                }),
                              ),
                              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ));
      }),
    );
  }
}

// ignore: must_be_immutable
class ThongBao extends StatefulWidget {
  String? title;
  ThongBao({Key? key, required this.title}) : super(key: key);
  @override
  State<ThongBao> createState() => _ThongBaoState();
}

class _ThongBaoState extends State<ThongBao> {
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
                  'Xác nhận xóa chương trình đào tạo',
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
              widget.title!,
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

class MenuPopupTest extends StatefulWidget {
  const MenuPopupTest({Key? key}) : super(key: key);

  @override
  State<MenuPopupTest> createState() => _MenuPopupTestState();
}

class _MenuPopupTestState extends State<MenuPopupTest> {
  var listNotification;
  late Future<dynamic> getNotificationFuture;
  getNotification() async {
    String now = DateFormat("dd-MM-yyyy")
        .format(DateTime.now().subtract(const Duration(days: 7)));

    var response = await httpGet(
        "/api/pm/adm/${Provider.of<SecurityModel>(context, listen: false).userLoginCurren['id']}",
        context);
    if (response.containsKey("body")) {
      listNotification = jsonDecode(response['body']);
      setState(() {});
      // print(listNotification);
      return listNotification;
    } else
      return 0;
  }

  @override
  // ignore: must_call_super
  void initState() {
    getNotificationFuture = getNotification();
  }

  @override
  Widget build(BuildContext context) {
    var appBarHeight = AppBar().preferredSize.height;

    return FutureBuilder<dynamic>(
      future: getNotificationFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Theme(
            data: Theme.of(context).copyWith(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
            child: PopupMenuButton(
              elevation: 6,
              tooltip: 'Hiển thị thông báo',
              // splashRadius: null,
              offset: Offset(0.0, appBarHeight),
              // onSelected: (item) {},
              constraints: BoxConstraints(
                  minWidth: 2.0 * 56.0,
                  maxWidth: MediaQuery.of(context).size.width,
                  maxHeight: 450),
              child: SizedBox(
                width: 65,
                height: 65,
                child: Center(
                  child: Stack(
                    children: <Widget>[
                      Icon(
                        Icons.notifications,
                        size: 22,
                        color: Color(0xff459A88),
                      ),
                      Positioned(
                        right: 0,
                        child: new Container(
                          padding: EdgeInsets.all(1),
                          decoration: new BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints: BoxConstraints(
                            minWidth: 7,
                            minHeight: 10,
                          ),
                          child: new Text(
                            '',
                            style: new TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              itemBuilder: (context) {
                getNotificationFuture = getNotification();
                return [
                  const PopupMenuItem(
                    enabled: false,
                    child: Text(
                      'Thông báo',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  ),
                  for (var row in listNotification)
                    PopupMenuItem(
                      onTap: () {},
                      child: Container(
                        height: 80,
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Color(0xff459A88),
                                  borderRadius: BorderRadius.circular(100)),
                              child: Center(
                                child: Icon(
                                  Icons.notifications,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 350,
                                  child: Text(
                                    row['message'],
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "${displayTimeStamp(row['createdDate'])}   ${dateReverse(displayDateTimeStamp(row['createdDate']))}",
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ],
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.all(0),
                                //   child: Divider(
                                //     thickness: 0.5,
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ];
              },
            ),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return Center(child: Container());
      },
    );
  }
}

class PopupThongBao extends StatefulWidget {
  final String message;
  final Function callBack;
  const PopupThongBao({Key? key, required this.message, required this.callBack})
      : super(key: key);

  @override
  State<PopupThongBao> createState() => _PopupThongBaoState();
}

class _PopupThongBaoState extends State<PopupThongBao> {
  String? message;
  @override
  void initState() {
    message = widget.message;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (message != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              boxShadow: [boxShadowContainer],
              color: Color(0xff459A88),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Icon(
                    Icons.notifications,
                    size: 22,
                    color: Colors.white,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 20, 10),
                  child: Text(
                    "$message",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: Colors.white),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    message = null;
                    setState(() {});
                    widget.callBack();
                  },
                  icon: Icon(Icons.close),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }
}
