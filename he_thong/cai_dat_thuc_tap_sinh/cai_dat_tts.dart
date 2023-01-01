import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/he_thong/cai_dat_thuc_tap_sinh/form_cau_hinh_thong_tin_tts.dart';
import 'package:gentelella_flutter/widgets/ui/he_thong/cai_dat_thuc_tap_sinh/form_trang_thai_tts.dart';
import 'package:provider/provider.dart';

import '../../../../common/style.dart';
import '../../../../model/model.dart';
import '../../navigation.dart';

class CaiDatTTS extends StatelessWidget {
  const CaiDatTTS({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: CaiDatTTSBody());
  }
}

class CaiDatTTSBody extends StatefulWidget {
  const CaiDatTTSBody({Key? key}) : super(key: key);

  @override
  State<CaiDatTTSBody> createState() => _CaiDatTTSBodyState();
}

class _CaiDatTTSBodyState extends State<CaiDatTTSBody> {
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
                      Text('Cài đặt thực tập sinh', style: titlePage),
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
                                        Icons.group,
                                        color: mainColorPage,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Cấu hình thông tin",
                                        style: titleTabbar,
                                      )
                                    ]),
                                    Row(children: [
                                      Icon(
                                        Icons.person,
                                        color: mainColorPage,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Trạng thái TTS",
                                        style: titleTabbar,
                                      )
                                    ]),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: TabBarView(children: [
                                  Container(
                                    child: FormCauHinhThongTin(),
                                  ),
                                  Container(
                                    child: FormTrangThaiTTS(),
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
