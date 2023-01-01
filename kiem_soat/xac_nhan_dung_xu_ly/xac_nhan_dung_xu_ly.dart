import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/kiem_soat/xac_nhan_dung_xu_ly/dungxuly_tts.dart';

import '../../../../common/style.dart';
import '../../../../common/widgets_form.dart';
import '../../navigation.dart';
import 'dungxuly_donhang.dart';

class XacNhanDungDuLy extends StatefulWidget {
  const XacNhanDungDuLy({Key? key}) : super(key: key);

  @override
  State<XacNhanDungDuLy> createState() => _XacNhanDungDuLyState();
}

class _XacNhanDungDuLyState extends State<XacNhanDungDuLy> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: XacNhanDungDuLyBody());
  }
}

class XacNhanDungDuLyBody extends StatefulWidget {
  const XacNhanDungDuLyBody({Key? key}) : super(key: key);

  @override
  State<XacNhanDungDuLyBody> createState() => _XacNhanDungDuLyBodyState();
}

class _XacNhanDungDuLyBodyState extends State<XacNhanDungDuLyBody> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitlePage(
          listPreTitle: [
            {'url': '/kiem-soat', 'title': 'Dashboard'},
          ],
          content: "Xác nhận dừng xử lý đơn hàng và thực tập sinh",
        ),
        Flexible(
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
                                "Đơn hàng",
                                style: titleTabbar,
                              )
                            ]),
                            Row(children: [
                              Icon(
                                Icons.list_alt_rounded,
                                color: mainColorPage,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Thực tập sinh",
                                style: titleTabbar,
                              )
                            ]),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(children: [
                          DXL_DH(),
                          DXL_TTS(),
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
    );
  }
}
