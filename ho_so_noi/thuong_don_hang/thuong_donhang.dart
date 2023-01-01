import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/style.dart';
import 'package:gentelella_flutter/widgets/ui/ho_so_noi/thuong_don_hang/thuong_donhang_lichsu.dart';
import 'package:gentelella_flutter/widgets/ui/ho_so_noi/thuong_don_hang/thuong_donhang_thongke.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';

import '../../../../common/widgets_form.dart';

class ThuongDonHang extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
      widgetBody: ThuongDonHangBody(),
    );
  }
}

class ThuongDonHangBody extends StatefulWidget {
  ThuongDonHangBody({Key? key}) : super(key: key);

  @override
  State<ThuongDonHangBody> createState() => _ThuongDonHangBodyState();
}

class _ThuongDonHangBodyState extends State<ThuongDonHangBody> with AutomaticKeepAliveClientMixin<ThuongDonHangBody> {
  @override
  bool get wantKeepAlive => true;
  @override
  // ignore: must_call_super
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
          // padding: paddingTitledPage,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TitlePage(
                listPreTitle: [
                  {'url': '/ho-so-noi', 'title': 'Hồ sơ nội'},
                ],
                content: 'Thưởng đơn hàng',
              ),
            ],
          ),
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
                                "Thống kê",
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
                                "Lịch sử",
                                style: titleTabbar,
                              )
                            ]),
                          ],
                        ),
                      ),
                      Expanded(
                        child: TabBarView(children: [
                          ThuongDonHangThongKe(),
                          ThuongDonHangLichSu(),
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
