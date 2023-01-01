import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/kiem_soat/DanhSachViPham/nhan_vien_vi_pham.dart';
import 'package:gentelella_flutter/widgets/ui/kiem_soat/DanhSachViPham/tts_vi_pham.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';

import '../../../../common/style.dart';
import '../../../../common/widgets_form.dart';

class DanhSachViPham extends StatefulWidget {
  const DanhSachViPham({Key? key}) : super(key: key);

  @override
  State<DanhSachViPham> createState() => _DanhSachViPhamState();
}

class _DanhSachViPhamState extends State<DanhSachViPham> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: DanhSachViPhamBody());
  }
}

class DanhSachViPhamBody extends StatefulWidget {
  const DanhSachViPhamBody({Key? key}) : super(key: key);

  @override
  State<DanhSachViPhamBody> createState() => _DanhSachViPhamBodyState();
}

class _DanhSachViPhamBodyState extends State<DanhSachViPhamBody> {
  @override
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TitlePage(
          listPreTitle: [
            {'url': '/kiem-soat', 'title': 'Dashboard'},
          ],
          content: "Danh sách vi phạm",
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
                                "Nhân viên",
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
                                "TTS",
                                style: titleTabbar,
                              )
                            ]),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(children: [
                          NVViPham(),
                          TTSViPham(),
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
