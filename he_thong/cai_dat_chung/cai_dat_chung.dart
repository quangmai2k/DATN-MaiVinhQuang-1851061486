import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/he_thong/cai_dat_chung/gui_thong_bao.dart';
import 'package:gentelella_flutter/widgets/ui/he_thong/cai_dat_chung/quan_ly_dich_vu_chay_tu_dong.dart';

import 'package:provider/provider.dart';

import '../../../../../common/style.dart';
import '../../../../../model/model.dart';
import '../../navigation.dart';

class CaiDatChung extends StatelessWidget {
  const CaiDatChung({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: CaiDatChungBody());
  }
}

class CaiDatChungBody extends StatefulWidget {
  const CaiDatChungBody({Key? key}) : super(key: key);

  @override
  State<CaiDatChungBody> createState() => _CaiDatChungBodyState();
}

class _CaiDatChungBodyState extends State<CaiDatChungBody> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationModel>(
        builder: (context, navigationModel, child) => Column(
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
                  child: Column(
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
                          Text('Hệ thống',
                              style: TextStyle(color: Color(0xff009C87))),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text('Cài đặt chung', style: titlePage),
                    ],
                  ),
                ),
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
                                  // key: ,
                                  isScrollable: true,
                                  indicatorColor: mainColorPage,
                                  tabs: [
                                    Row(children: [
                                      Icon(
                                        Icons.group,
                                        color: mainColorPage,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Gửi thông báo",
                                        style: titleTabbar,
                                      )
                                    ]),
                                    Row(children: [
                                      Icon(
                                        Icons.group,
                                        color: mainColorPage,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Quản lý dịch vụ chạy tự động",
                                        style: titleTabbar,
                                      )
                                    ]),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TabBarView(children: [
                                  Container(
                                    child: FormGuiThongBao(),
                                  ),
                                  Container(
                                    child: QuanLyDichVu(),
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
              ],
            ));
  }
}
