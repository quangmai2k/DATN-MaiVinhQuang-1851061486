

import 'package:flutter/material.dart';

import 'package:gentelella_flutter/widgets/ui/he_thong/OmiCRM/danh_sach_khach_hang.dart';
import 'package:gentelella_flutter/widgets/ui/he_thong/OmiCRM/danh_sach_nhanh_vien.dart';
import 'package:gentelella_flutter/widgets/ui/he_thong/OmiCRM/lich_su_cuoc_goi.dart';

import 'package:provider/provider.dart';

import '../../../../../common/style.dart';

import '../../../../model/model.dart';
import '../../navigation.dart';

class OmiCRM extends StatelessWidget {
  const OmiCRM({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: OmiCRMBody());
  }
}

class OmiCRMBody extends StatefulWidget {
  const OmiCRMBody({Key? key}) : super(key: key);

  @override
  State<OmiCRMBody> createState() => _OmiCRMBodyState();
}

class _OmiCRMBodyState extends State<OmiCRMBody> {


  @override
  void initState() {
  }

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
                      Text('OmiCRM', style: titlePage),
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
                                  isScrollable: true,
                                  indicatorColor: mainColorPage,
                                  tabs: [
                                    Row(children: [
                                      Icon(
                                        Icons.directions_car,
                                        color: mainColorPage,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Lịch sử cuộc gọi",
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
                                        "Danh sách khách hàng",
                                        style: titleTabbar,
                                      )
                                    ]),
                                    
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TabBarView(children: [
                                  Container(
                                    child: LichSuCuocGoi(),
                                  ),
                                  Container(
                                    child: DanhSachKhachHang(),
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
