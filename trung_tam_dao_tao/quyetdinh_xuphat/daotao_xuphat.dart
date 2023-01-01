import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/kiem_soat/quyet_dinh_xu_phat_update/lich_su_phat.dart';
import 'package:gentelella_flutter/widgets/ui/kiem_soat/quyet_dinh_xu_phat_update/them_quyetdinh_xuphat.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:gentelella_flutter/widgets/ui/trung_tam_dao_tao/quyetdinh_xuphat/them_daotao_xuphat.dart';
import '../../../../common/style.dart';
import '../../../../common/widgets_form.dart';
import 'lichsu_daotao_xuphat.dart';

class DaoTaoXuPhat extends StatefulWidget {
  const DaoTaoXuPhat({Key? key}) : super(key: key);

  @override
  State<DaoTaoXuPhat> createState() => _DaoTaoXuPhatState();
}

class _DaoTaoXuPhatState extends State<DaoTaoXuPhat> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: DaoTaoXuPhatBody());
  }
}

class DaoTaoXuPhatBody extends StatefulWidget {
  const DaoTaoXuPhatBody({Key? key}) : super(key: key);

  @override
  State<DaoTaoXuPhatBody> createState() => _DaoTaoXuPhatBodyState();
}

class _DaoTaoXuPhatBodyState extends State<DaoTaoXuPhatBody> {
  @override
  // bool get wantKeepAlive =>
  //     true;
  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/quyet-dinh-xu-phat-dao-tao', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
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
                padding: paddingTitledPage,
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
                      ],
                    ),
                    SizedBox(height: 10),
                    Text('Quyết định xử phạt', style: titlePage),
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
                                      "Danh sách quyết định xử phạt",
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
                                      "Tạo quyết định xử phạt",
                                      style: titleTabbar,
                                    )
                                  ]),
                                ],
                              ),
                            ),
                            Expanded(
                              child: TabBarView(children: [
                                LichSuDaoTaoXuPhat(),
                                ThemDaoTaoXuPhat(),
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
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
