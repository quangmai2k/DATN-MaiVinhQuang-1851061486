import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../common/style.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../../navigation.dart';
import 'bo_phan.dart';
import 'vi_tri.dart';

class CaiDatBoPhan extends StatefulWidget {
  const CaiDatBoPhan({Key? key}) : super(key: key);

  @override
  State<CaiDatBoPhan> createState() => _CaiDatBoPhanState();
}

class _CaiDatBoPhanState extends State<CaiDatBoPhan> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
      widgetBody: Consumer<NavigationModel>(
          builder: (context, navigationModel, child) => SingleChildScrollView(
                controller: ScrollController(),
                child: Column(children: [
                  TitlePage(
                    listPreTitle: [
                      {'url': "/dashboard", 'title': 'Home / Hệ thống'},
                      // {'url': "/he-thong", 'title': 'Hệ thống'},
                    ],
                    content: 'Cài đặt phòng ban',
                    widgetBoxRight: Row(
                      children: [],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 1000,
                    child: DefaultTabController(
                      length: 2,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            // color: Colors.red,
                            constraints: BoxConstraints.expand(height: 30),
                            padding: EdgeInsets.only(left: 20, right: 40),
                            child: TabBar(
                              isScrollable: true,
                              indicatorColor: mainColorPage,
                              tabs: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.groups,
                                      color: mainColorPage,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "Phòng ban",
                                      style: titleTabbar,
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.supervised_user_circle,
                                      color: mainColorPage,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "Vị trí",
                                      style: titleTabbar,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(children: [
                              BoPhan(),
                              ViTri(),
                              // BoPhan(),
                            ]),
                          )
                        ],
                      ),
                    ),
                  ),
                  Footer(marginFooter: EdgeInsets.only(top: 5), paddingFooter: EdgeInsets.all(15)),
                  SizedBox(height: 20)
                ]),
              )),
    );
  }
}
