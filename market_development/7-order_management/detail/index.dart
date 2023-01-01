import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/style.dart';

import 'package:gentelella_flutter/widgets/ui/market_development/7-order_management/detail/listTTS.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'dart:js' as js;

import '../../../../../api.dart';
import '../../../../../common/format_date.dart';
import '../../../../../common/toast.dart';
import '../../../../../common/widgets_form.dart';
import '../../../../../config.dart';
import '../../../../../model/market_development/order.dart';

import '../../../../forms/market_development/utils/funciton.dart';
import '../xuat_file.dart';
import 'bonus_target.dart';
import 'order_information.dart';

class OrderDetail extends StatelessWidget {
  final int? id;
  OrderDetail({Key? key, this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
      widgetBody: OrderDetailBody(
        id: id,
      ),
    );
  }
}

class OrderDetailBody extends StatefulWidget {
  final int? id;
  OrderDetailBody({Key? key, this.id}) : super(key: key);

  @override
  State<OrderDetailBody> createState() => _OrderDetailBodyState();
}

class _OrderDetailBodyState extends State<OrderDetailBody> {
  Order? order;
  bool isLoading = false;
  getOrderDetailByParentId(int id) async {
    var response = await httpGet("/api/donhang/get/${widget.id}", context);
    var body = jsonDecode(response['body']);

    if (response.containsKey("body")) {
      setState(() {
        order = Order.fromJson(body);

        if (order != null) {
          isLoading = true;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getOrderDetailByParentId(widget.id!);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? SingleChildScrollView(
            child: Column(
              children: [
                TitlePage(
                  listPreTitle: [
                    {'url': '/phat-trien-thi-truong', 'title': 'Dashboard'},
                    {'url': '/quan-li-don-hang', 'title': 'Quản lý đơn hàng'}
                  ],
                  content: '',
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 1,
                  decoration: BoxDecoration(
                    color: colorWhite,
                    boxShadow: [boxShadowContainer],
                    // border: Border(
                    //   bottom: borderTitledPage,
                    // ),
                  ),
                  padding: paddingTitledPage,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Expanded(
                              flex: 1,
                              child: Text(
                                "Chi tiết đơn hàng",
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xff212529),
                                ),
                              )),
                          Expanded(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text("Ngày tạo : ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xff212529),
                                      )),
                                  Text(order!.createdDate != null ? FormatDate.formatDateView(DateTime.tryParse(order!.createdDate.toString())!) : "",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff212529),
                                      )),
                                ],
                              )),
                          Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  Text("Nhân viên xử lý : ",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xff212529),
                                      )),
                                  SizedBox(width: 10),
                                  Text(order!.user!.fullName != null ? order!.user!.fullName : "",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                        color: Color(0xff212529),
                                      )),
                                ],
                              )),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton.icon(
                                  icon: Icon(Icons.file_download, size: 14, color: Colors.white),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15.0,
                                      horizontal: 15.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    backgroundColor: colorOrange,
                                    primary: Theme.of(context).iconTheme.color,
                                    textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                  ),
                                  onPressed: () async {
                                    onLoading(context);
                                    List<Order> listOrderExcell = [];
                                    listOrderExcell.add(order!);
                                    await createExcel(listOrderExcell).whenComplete(() => Navigator.pop(context));
                                  },
                                  label: Text('Xuất file', style: textButton),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton.icon(
                                  icon: Icon(Icons.print, size: 14, color: Colors.white),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15.0,
                                      horizontal: 15.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    backgroundColor: colorOrange,
                                    primary: Theme.of(context).iconTheme.color,
                                    textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                  ),
                                  onPressed: () async {
                                    List<Order> listOrderExcell = [];
                                    listOrderExcell.add(order!);
                                    for (var item in listOrderExcell) {
                                      js.context.callMethod("myPrint", [
                                        item.orderCode,
                                        item.orderName,
                                        item.union!.orgCode,
                                        item.enterprise!.companyCode,
                                        item.workAddress,
                                        item.jobs!.jobName,
                                        item.jobsDetail!.jobName,
                                        item.implementTime,
                                        item.genderRequired,
                                        item.ageFrom,
                                        item.ageTo,
                                        item.ttsRequired,
                                        item.ttsMaleRequired,
                                        item.ttsFemaleRequired,
                                        item.ttsCandidates,
                                        item.ttsMaleCandidates,
                                        item.ttsFemaleCandidates,
                                        item.level!.name,
                                        item.skill,
                                        item.eyeSight,
                                        item.eyeSightGlasses,
                                        item.eyeSightSurgery,
                                        item.heigth,
                                        item.weight,
                                        item.rightHanded,
                                        item.leftHanded,
                                        item.maritalStatus,
                                        item.smoke,
                                        item.drinkAlcohol,
                                        item.tattoo,
                                        item.everSurgery,
                                        item.everCesareanSection,
                                        item.otherHealthRequired,
                                        item.otherHealthRequiredAccept,
                                        item.priorityCases,
                                        item.restrictionCases,
                                        item.recruiMethod,
                                        item.recruiContent,
                                        item.testFormNumber,
                                        getDateView(item.sendListFormDate),
                                        getDateView(item.estimatedInterviewDate),
                                        getDateView(item.estimatedAdmissionDate),
                                        getDateView(item.estimatedEntryDate),
                                        item.firstMonthSubsidy,
                                        item.salary,
                                        item.insurance,
                                        item.livingCost,
                                        item.netMoney,
                                        item.orderUrgent,
                                        item.image,
                                        item.image2,
                                        baseUrl,
                                        item.union!.phapNhan!.image,
                                        item.otherHealthRequiredAccept
                                      ]);
                                    }
                                  },
                                  label: Text('In đơn hàng', style: textButton),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton.icon(
                                  icon: Icon(Icons.arrow_back_ios, size: 14, color: Colors.white),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15.0,
                                      horizontal: 15.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    backgroundColor: colorOrange,
                                    primary: Theme.of(context).iconTheme.color,
                                    textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  label: Text('Trở về', style: textButton),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                    ],
                  ),
                ),
                Container(
                  height: 1000,
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Container(
                          constraints: BoxConstraints.expand(height: 50),
                          padding: EdgeInsets.only(left: 20, right: 20),
                          child: TabBar(
                            isScrollable: true,
                            indicatorColor: mainColorPage,
                            tabs: [
                              Row(children: [
                                Icon(
                                  Icons.list_alt_rounded,
                                  color: mainColorPage,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Thông tin đơn hàng",
                                  style: titleWidget,
                                )
                              ]),
                              Row(children: [
                                Icon(
                                  Icons.list_alt_rounded,
                                  color: mainColorPage,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Chỉ tiêu tính thưởng",
                                  style: titleWidget,
                                )
                              ]),
                              Row(children: [
                                Icon(
                                  Icons.list_alt_rounded,
                                  color: mainColorPage,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Danh sách thực tập sinh thuộc đơn hàng",
                                  style: titleWidget,
                                )
                              ]),
                            ],
                          ),
                        ),
                        Expanded(
                          child: TabBarView(children: [
                            OrderInformation(
                              order: order,
                              isLoading: isLoading,
                            ),
                            BonusTarget(
                              order: order,
                            ),
                            ListTTS(
                              order: order,
                            )
                          ]),
                        )
                      ],
                    ),
                  ),
                ),
                Footer()
              ],
            ),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}
