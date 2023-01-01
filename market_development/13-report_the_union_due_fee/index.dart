import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/market_development/13-report_the_union_due_fee/statistical.dart';
import '../../../../common/style.dart';

import '../../../../common/widgets_form.dart';
import '../../../../model/market_development/union.dart';
import '../../navigation.dart';
import 'management_fee_collection.dart';

class ReportUnionDueFee extends StatefulWidget {
  const ReportUnionDueFee({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ReportUnionDueFeeState();
  }
}

class _ReportUnionDueFeeState extends State<ReportUnionDueFee> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
      widgetBody: ReportUnionDueFeeBody(),
    );
  }
}

class ReportUnionDueFeeBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ReportUnionDueFeeBodyState();
  }
}

class _ReportUnionDueFeeBodyState extends State<ReportUnionDueFeeBody> {
  List<UnionObj> listUnionObjectResult = [];
  //a
  getDataFromWigdetChild(value) {
    print("thaida $value");
    setState(() {
      listUnionObjectResult = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
          child: TitlePage(
            listPreTitle: [
              {'url': '/phat-trien-thi-truong', 'title': 'Dashboard'},
              {'url': '/bao-cao-cac-nghiep-doan-den-han-thu-phi', 'title': 'Báo cáo nghiệp đoàn đến hạn thu phí'}
            ],
            content: 'Báo cáo nghiệp đoàn đến hạn thu phí',
          ),
        ),

        //----------Tabbar---------------
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DefaultTabController(
                  length: 2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        // color: Colors.red,
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
                                "Thống kê",
                                style: titleTabbar,
                              )
                            ]),
                            Row(children: [
                              Icon(
                                Icons.directions_transit,
                                color: mainColorPage,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Thu phí quản lý",
                                style: titleTabbar,
                              )
                            ]),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(children: [
                          Statistical(
                            func: getDataFromWigdetChild,
                          ),
                          ManagerFee(),
                        ]),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        //---------Kết thúc tabbar
      ],
    );
  }
}
