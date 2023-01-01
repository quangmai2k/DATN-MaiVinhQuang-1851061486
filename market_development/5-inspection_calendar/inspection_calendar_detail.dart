import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/model/market_development/union.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:provider/provider.dart';

import '../../../../../common/style.dart';
import '../../../../../model/model.dart';
import '../../../../api.dart';
import '../../../../common/format_date.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/market_development/lichthisat.dart';

class InspectionCalendarDetail extends StatefulWidget {
  final int? id;
  InspectionCalendarDetail({Key? key, this.id}) : super(key: key);

  @override
  State<InspectionCalendarDetail> createState() => _InspectionCalendarDetailState();
}

class _InspectionCalendarDetailState extends State<InspectionCalendarDetail> {
  late Future<InspectionCalendars> futureInspectionCalendars;
  InspectionCalendars calendars = new InspectionCalendars(
      id: -1,
      orgId: -1,
      dateFrom: "",
      dateTo: "",
      union: new UnionObj(
          id: -1,
          orgCode: "",
          orgName: "",
          deputy: "",
          duty: "",
          address: "",
          countryCode: "",
          phone: "",
          fax: "",
          email: "",
          contractStatus: -1,
          contractSigningTime: "",
          principleContract: "",
          agreementContract: "",
          otherFiles: "",
          contact1: "",
          phone1: "",
          contact2: "",
          phone2: "",
          bankAccount: "",
          bankName: "",
          bankNumber: "",
          bankDepartment: "",
          bankAddress: "",
          arfareFee: 0,
          trainingFee: 0,
          manageFeeId: -1,
          aamSale: 0,
          createdUser: 0,
          createdDate: "",
          chargeStartDate: "",
          chargeCycleDate: 0,
          chargeWarningDate: 0),
      status: 0,
      description: "",
      result: "",
      qty: 0);
  @override
  void initState() {
    super.initState();
    //getListInpectionCanlendarSearchBy(widget.id!);
    futureInspectionCalendars = getListInpectionCanlendarSearchBy(widget.id!);
  }

  Map<int, String> _mapStatusofUnion = {
    0: ' Chờ thực hiện',
    1: ' Đã thị sát',
    2: ' Đã hủy',
  };
  Future<InspectionCalendars> getListInpectionCanlendarSearchBy(int id) async {
    var response;

    response = await httpGet("/api/lichthisat/get/$id", context);

    var body = jsonDecode(response['body']);

    if (response.containsKey("body")) {
      setState(() {
        calendars = InspectionCalendars.fromJson(body);
        // print(listJobsResult);
      });
    }

    return InspectionCalendars.fromJson(body);
  }

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: FutureBuilder<InspectionCalendars>(
            future: futureInspectionCalendars,
            builder: (context, snapshot) {
              return Consumer<NavigationModel>(
                  builder: (context, navigationModel, child) => ListView(
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 1,
                            decoration: BoxDecoration(
                              color: colorWhite,
                              boxShadow: [boxShadowContainer],
                              border: Border(
                                bottom: borderTitledPage,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Home',
                                          style: TextStyle(color: Color(0xff009C87)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 5, right: 5),
                                          child: Text(
                                            '/',
                                            style: TextStyle(
                                              color: Color(0xffC8C9CA),
                                            ),
                                          ),
                                        ),
                                        Text('Lịch thị sát', style: TextStyle(color: Color(0xff009C87))),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text('Lịch thị sát', style: titlePage),
                                  ],
                                ),
                              ],
                            ),
                          ),
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
                                      'Lịch thị sát',
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
                                if (snapshot.hasData)
                                  Container(
                                    child: Column(
                                      children: [
                                        //====
                                        Container(
                                          margin: EdgeInsets.only(top: 20),
                                          child: Row(
                                            children: [
                                              //Start Row 1
                                              Expanded(
                                                  child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      "Nghiệp đoàn: ",
                                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      snapshot.data!.union!.orgName!,
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
                                                      "Trạng thái: ",
                                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Container(
                                                      child: Text(
                                                        _mapStatusofUnion[calendars.status].toString(),
                                                        maxLines: 3,
                                                        softWrap: true,
                                                        style: TextStyle(fontSize: 17),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                            ],
                                          ),
                                        ),
                                        //====
                                        Container(
                                          margin: EdgeInsets.only(top: 40),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      "Từ ngày: ",
                                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Container(
                                                      child: Text(
                                                        getDateViewDayAndHour(calendars.dateFrom),
                                                        style: TextStyle(fontSize: 17),
                                                      ),
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
                                                      "Đến ngày: ",
                                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Container(
                                                      child: Text(
                                                        getDateViewDayAndHour(calendars.dateTo),
                                                        style: TextStyle(fontSize: 17),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                            ],
                                          ),
                                        ),

                                        Container(
                                          margin: EdgeInsets.only(top: 40),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      "Số lượng thành viên đoàn thị sát: ",
                                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 5,
                                                    child: Container(
                                                      child: Text(
                                                        calendars.qty.toString(),
                                                        style: TextStyle(fontSize: 17),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Container(),
                                                  ),
                                                ],
                                              )),
                                            ],
                                          ),
                                        ),

                                        //====
                                        Container(
                                          margin: EdgeInsets.only(top: 40),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      "Mô tả: ",
                                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 5,
                                                    child: Container(
                                                      child: Text(
                                                        calendars.description,
                                                        style: TextStyle(fontSize: 17),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Container(),
                                                  ),
                                                ],
                                              )),
                                            ],
                                          ),
                                        ),
                                        //====
                                        Container(
                                          margin: EdgeInsets.only(top: 40),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                  child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      "Kết quả thị sát: ",
                                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 5,
                                                    child: Container(
                                                      child: Text(
                                                        calendars.result,
                                                        style: TextStyle(fontSize: 17),
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Container(),
                                                  ),
                                                ],
                                              )),
                                            ],
                                          ),
                                        ),
                                        Footer(),
                                      ],
                                    ),
                                  )
                                else if (snapshot.hasError)
                                  Text("")
                                else
                                  Center(
                                    child: CircularProgressIndicator(),
                                  ),
                              ],
                            ),
                          ),
                          //--------------Chân trang--------
                        ],
                      ));
            }));
  }
}
