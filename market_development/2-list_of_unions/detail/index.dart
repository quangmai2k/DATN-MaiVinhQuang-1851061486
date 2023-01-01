import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import 'package:gentelella_flutter/widgets/ui/market_development/2-list_of_unions/detail/payment_history.dart';
import 'package:gentelella_flutter/widgets/ui/market_development/2-list_of_unions/detail/union_information.dart';

import '../../../../../api.dart';
import '../../../../../common/style.dart';
import '../../../../../model/market_development/union.dart';

import '../../../navigation.dart';
import 'access_history.dart';
import 'account_information.dart';
import 'contract_relevant_dossier.dart';
import 'setting_fee.dart';

class UnionManagerDetail extends StatefulWidget {
  final int? id;
  UnionManagerDetail({Key? key, this.id}) : super(key: key);
  @override
  _StateUnionManagerDetail createState() => _StateUnionManagerDetail(id: id);
}

class _StateUnionManagerDetail extends State<UnionManagerDetail> {
  int? id;

  _StateUnionManagerDetail({Key? key, this.id});
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: UnionManagerDetailBody(id: id));
  }
}

class UnionManagerDetailBody extends StatefulWidget {
  final int? id;
  UnionManagerDetailBody({Key? key, this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _UnionManagerDetailBodyState(id: id);
  }
}

class _UnionManagerDetailBodyState extends State<UnionManagerDetailBody> {
  int? id;
  _UnionManagerDetailBodyState({Key? key, this.id});
  UnionObj union = new UnionObj(
      id: 0,
      orgCode: "",
      orgName: "",
      deputy: "",
      duty: "",
      address: "",
      countryCode: "",
      phone: "",
      fax: "",
      email: "",
      contractStatus: 0,
      contractSigningTime: null,
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
      manageFeeId: 0,
      aamSale: 0,
      createdUser: 0,
      createdDate: "",
      chargeCycleDate: 0,
      chargeStartDate: '',
      chargeWarningDate: 0);
  @override
  void initState() {
    super.initState();
    getUnionDetailById(widget.id!);
  }

  getUnionDetailById(int id) async {
    var response = await httpGet("/api/nghiepdoan/get/$id", context);
    var body = jsonDecode(response['body']);

    print(body);
    if (response.containsKey("body")) {
      setState(() {
        union = UnionObj.fromJson(body);
      });
    }
  }

  bool get wantKeepAlive => true; //chuyển sang false thì khi tab sẽ load lại trang

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitlePage(
          listPreTitle: [
            {'url': '/phat-trien-thi-truong', 'title': 'Dashboard'},
            {'url': '/quan-li-nghiep-doan', 'title': 'Quản lý nghiệp đoàn'}
          ],
          content: 'Thông tin nghiệp đoàn',
        ),

        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DefaultTabController(
                  length: 6,
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
                                "Thông tin nghiệp đoàn",
                                style: titleTabbar,
                              )
                            ]),
                            Row(children: [
                              Icon(
                                Icons.book_online_rounded,
                                color: mainColorPage,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Hợp đồng/Hồ sơ liên quan",
                                style: titleTabbar,
                              )
                            ]),
                            Row(children: [
                              Icon(
                                Icons.info_rounded,
                                color: Color(0xff009C87),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Thông tin tài khoản",
                                style: titleTabbar,
                              )
                            ]),
                            Row(children: [
                              Icon(
                                Icons.history_sharp,
                                color: Color(0xff009C87),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Lịch sử tiếp cận",
                                style: titleTabbar,
                              )
                            ]),
                            Row(children: [
                              Icon(
                                Icons.settings,
                                color: Color(0xff009C87),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Cài đặt phí",
                                style: titleTabbar,
                              )
                            ]),
                            Row(children: [
                              Icon(
                                Icons.history_edu,
                                color: Color(0xff009C87),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Lịch sử thanh toán",
                                style: titleTabbar,
                              )
                            ]),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(children: [
                          UnionInformationDetail(union: union),
                          ContractRelevantDossierDetail(union: union),
                          AccountInformationDetail(union: union),
                          AccessHistoryDetail(union: union),
                          SettingFeeDetail(union: union),
                          PaymentHistoryDetail(
                            union: union,
                          ),
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
