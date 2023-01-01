import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../api.dart';
import '../../../../../common/style.dart';
import '../../../../../model/market_development/union.dart';
import '../../../../../model/market_development/nation.dart';
import '../../../../../model/market_development/user.dart';
import '../../../../../model/model.dart';

class UnionInformationDetail extends StatefulWidget {
  final UnionObj? union;
  UnionInformationDetail({Key? key, this.union}) : super(key: key);

  @override
  State<UnionInformationDetail> createState() => _UnionInformationDetailState();
}

class _UnionInformationDetailState extends State<UnionInformationDetail> {
  List<User> listUserResult = [];
  List<Nation> listNationResult = [];

  String getStatusNameByStatus(int status) {
    String statusName = "";
    switch (status) {
      case 0:
        {
          statusName = "Dừng hợp tác";
        }
        break;
      case 1:
        {
          statusName = "Cần tiếp cận";
        }
        break;
      case 2:
        {
          statusName = "Đang tiếp cận";
        }
        break;
      case 3:
        {
          statusName = "Đã ký hợp đồng";
        }
        break;

      default:
        {}
        break;
    }
    return statusName;
  }

  String getUserNameByAamSale(List<User> listUser, String aamSale) {
    for (int i = 0; i < listUser.length; i++) {
      if (aamSale == listUser[i].id.toString()) return listUser[i].fullName;
    }
    return "No data!";
  }

  String getNameByCountryCode(List<Nation> listNation, String countryCode) {
    for (int i = 0; i < listNation.length; i++) {
      if (countryCode == listNation[i].countryCode) return listNation[i].name;
    }
    return "Không có trong quốc gia";
  }

  Future getAllUser() async {
    var response = await httpGet("/api/nguoidung/get/page?search=active:1 AND isBlocked:0 AND isAam:0 AND ${widget.union!.aamSale}", context);
    var body = jsonDecode(response['body']);
    var content = [];
    print("body $body");
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
        listUserResult = content.map((e) {
          return User.fromJson(e);
        }).toList();
      });
    }
  }

  Future getAllNation() async {
    var response = await httpGet("/api/quocgia/get/page", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
        listNationResult = content.map((e) {
          return Nation.fromJson(e);
        }).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initData();
  }

  initData() async {
    await getAllUser();
    await getAllNation();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationModel>(
        builder: (context, navigationModel, child) => ListView(
              children: [
                Container(
                  padding: paddingBoxContainer,
                  margin: marginBoxFormTab,
                  width: MediaQuery.of(context).size.width * 1,
                  decoration: BoxDecoration(
                    color: colorWhite,
                    borderRadius: borderRadiusContainer,
                    boxShadow: [boxShadowContainer],
                    border: borderAllContainerBox,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Thông tin nghiệp đoàn',
                            style: titleBox,
                          ),
                          Icon(
                            Icons.more_horiz,
                            color: colorIconTitleBox,
                            size: sizeIconTitleBox,
                          ),
                        ],
                      ),
                      //--------------Đường line-------------
                      Container(
                        child: Divider(
                          thickness: 1,
                          color: ColorHorizontalLine,
                        ),
                      ),
                      //------------kết thúc đường line-------
                      Container(
                        child: Column(
                          children: [
                            //====
                            Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "Tên nghiệp đoàn: ",
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          widget.union!.orgName!,
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ),
                                    ],
                                  )),
                                  Expanded(
                                      child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "Trạng thái: ",
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          getStatusNameByStatus(widget.union!.contractStatus!),
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ),
                                    ],
                                  )),
                                ],
                              ),
                            ),
                            //====
                            //====
                            Container(
                              margin: EdgeInsets.only(top: 30),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "Người đại diện: ",
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          widget.union!.deputy!,
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ),
                                    ],
                                  )),
                                  Expanded(
                                      child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "Thời gian ký: ",
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          widget.union!.contractSigningTime != null ? widget.union!.contractSigningTime! : "Chưa có ngày kí",
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ),
                                    ],
                                  )),
                                ],
                              ),
                            ),
                            //====
                            //====
                            Container(
                              margin: EdgeInsets.only(top: 30),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "Chức vụ: ",
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          widget.union!.duty!,
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ),
                                    ],
                                  )),
                                  Expanded(
                                      child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "Người liên lạc 1: ",
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          widget.union!.contact1!,
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ),
                                    ],
                                  )),
                                ],
                              ),
                            ),
                            //====
                            //====
                            Container(
                              margin: EdgeInsets.only(top: 30),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "Quốc gia: ",
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          getNameByCountryCode(listNationResult, widget.union!.countryCode!),
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ),
                                    ],
                                  )),
                                  Expanded(
                                      child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "Số điện thoại 1: ",
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          widget.union!.phone1!,
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ),
                                    ],
                                  )),
                                ],
                              ),
                            ),
                            //====
                            Container(
                              margin: EdgeInsets.only(top: 30),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "Địa chỉ: ",
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          widget.union!.address!,
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ),
                                    ],
                                  )),
                                  Expanded(
                                      child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "Người liên lạc 2: ",
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          widget.union!.contact2!,
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ),
                                    ],
                                  )),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 30),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "SĐT nghiệp đoàn: ",
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          widget.union!.phone!,
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ),
                                    ],
                                  )),
                                  Expanded(
                                      child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "Số điện thoại 2: ",
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          widget.union!.phone2!,
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ),
                                    ],
                                  )),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 30),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "Fax: ",
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          widget.union!.fax!,
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ),
                                    ],
                                  )),
                                  Expanded(
                                      child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "Nhân viên AAM: ",
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          getUserNameByAamSale(listUserResult, widget.union!.aamSale.toString()),
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ),
                                    ],
                                  )),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 30),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "Email: ",
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          widget.union!.email!,
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ),
                                    ],
                                  )),
                                  Expanded(
                                      child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Container(),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Container(),
                                      ),
                                    ],
                                  )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ));
  }
}
