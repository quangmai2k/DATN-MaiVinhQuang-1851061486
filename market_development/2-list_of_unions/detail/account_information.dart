import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../../../common/style.dart';
import '../../../../../model/market_development/union.dart';
import '../../../../../model/model.dart';

class AccountInformationDetail extends StatefulWidget {
  final UnionObj? union;
  AccountInformationDetail({Key? key, this.union}) : super(key: key);

  @override
  State<AccountInformationDetail> createState() => _AccountInformationDetailState();
}

class _AccountInformationDetailState extends State<AccountInformationDetail> {
  DateTime selectedDate = DateTime.now();

  String selectedNation = "Nhật Bản";
  String selectedStatus = "Đã kí hợp đồng";
  String selectedStaff = "Tất cả";
  List<String> listNation = ['Nhật Bản', 'Đài Loan'];

  List<String> listStatus = ['Cần tiếp cận', 'Đang tiếp cận', 'Đã ký hợp đồng'];

  List<String> listStaff = [
    'Nguyễn Văn A',
    'Nguyễn Văn A',
    'Nguyễn Văn A',
  ];

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
                            'Thông tin tài khoản',
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
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "Tên chủ tài khoản: ",
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          widget.union!.bankAccount!,
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
                                        child: Text(
                                          "Ngân hàng: ",
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          widget.union!.bankName!,
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
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "Số tài khoản: ",
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          widget.union!.bankNumber!,
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
                                        child: Text(
                                          "Chi nhánh: ",
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Text(
                                          widget.union!.bankDepartment!,
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
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              "Địa chỉ ngân hàng: ",
                                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Text(
                                              widget.union!.bankAddress!,
                                              style: TextStyle(fontSize: 17),
                                            ),
                                          ),
                                        ],
                                      )),
                                  Expanded(
                                      flex: 1,
                                      child: Row(
                                        children: [
                                          Expanded(flex: 1, child: Container()),
                                          Expanded(flex: 3, child: Container()),
                                        ],
                                      ))
                                ],
                              ),
                            ),
                            //====
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
