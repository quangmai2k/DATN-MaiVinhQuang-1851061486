import 'package:flutter/material.dart';
import 'package:gentelella_flutter/model/model.dart';
import 'package:gentelella_flutter/widgets/ui/trung_tam_dao_tao/danh_sach_thuc_tap_sinh/form_thong_tin_dao_tao.dart';
import 'package:provider/provider.dart';

import '../../../../common/style.dart';
import '../../../../common/widgets_form.dart';
import '../../navigation.dart';
import 'form_bao_cao_dao_tao.dart';

Color borderBlack = Colors.black54;

class ThemMoiCapNhatTTS extends StatelessWidget {
  final String? id;
  const ThemMoiCapNhatTTS({Key? key, this.id}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: ThemMoiCapNhatTTSBody(
      id: id,
    ));
  }
}

class ThemMoiCapNhatTTSBody extends StatefulWidget {
  final String? id;
  const ThemMoiCapNhatTTSBody({Key? key, this.id}) : super(key: key);

  @override
  State<ThemMoiCapNhatTTSBody> createState() => _ThemMoiCapNhatTTSBodyState();
}

class _ThemMoiCapNhatTTSBodyState extends State<ThemMoiCapNhatTTSBody> {
  String selectedValue = 'Testim-Grid';
  Map<String, bool> listCheckBoxValue = {
    'Override default configurations': false,
    'Override Base Url': false,
  };
  List<String> itemsGrid = [
    'Testim-Grid 1',
    'Testim-Grid 2',
    'Testim-Grid 3',
  ];
  DateTime selectedDate = DateTime.now();
  @override
  Widget build(BuildContext context) {
    var curentUser =
        Provider.of<SecurityModel>(context, listen: false).userLoginCurren;
    var listTab = [];
    var listPage = [];
    if (curentUser['departId'] == 1 ||
        curentUser['departId'] == 2 ||
        (curentUser['departId'] == 7 &&
            curentUser['vaitro'] != null &&
            curentUser['vaitro']['level'] >= 2)) {
      listTab.add(
        Row(children: [
          Icon(
            Icons.school,
            color: Color(0xff009C87),
          ),
          SizedBox(width: 10),
          Text(
            "Thông tin đào tạo",
            style: titleTabbar,
          )
        ]),
      );
      listPage.add(
        ThongTinDaoTao(
          id: widget.id,
        ),
      );
    }
    if (curentUser['departId'] == 1 ||
        curentUser['departId'] == 2 ||
        (curentUser['departId'] == 7 &&
            curentUser['vaitro'] != null &&
            curentUser['vaitro']['level'] >= 0 &&
            curentUser['vaitro']['level'] != 1)) {
      listTab.add(
        Row(children: [
          Icon(
            Icons.book,
            color: Color(0xff009C87),
          ),
          SizedBox(width: 10),
          Text(
            "Báo cáo học tập",
            style: titleTabbar,
          )
        ]),
      );
      listPage.add(
        BaoCaoDaoTao(
          id: widget.id,
        ),
      );
    }
    print(listTab);
    return Consumer<NavigationModel>(
        builder: (context, navigationModel, child) => Column(children: [
              TitlePage(
                listPreTitle: [
                  {'url': '/bang-thong-ke-nhanh', 'title': 'Dashboard'},
                  {
                    'url': '/danh-sach-thuc-tap-sinh',
                    'title': 'Danh sách thực tập sinh'
                  }
                ],
                content:
                    "${widget.id == null ? 'Thêm mới' : 'Cập nhật'} thông tin đào tạo",
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
                        length: listTab.length,
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
                                  for (var row in listTab) row,
                                ],
                              ),
                            ),
                            Expanded(
                              child: TabBarView(children: [
                                for (var row in listPage) row,
                              ]),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]));
  }
}
