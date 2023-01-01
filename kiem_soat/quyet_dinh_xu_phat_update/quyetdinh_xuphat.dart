import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/kiem_soat/quyet_dinh_xu_phat_update/lich_su_phat.dart';
import 'package:gentelella_flutter/widgets/ui/kiem_soat/quyet_dinh_xu_phat_update/them_quyetdinh_xuphat.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import '../../../../common/style.dart';
import '../../../../common/widgets_form.dart';

class QuyetDinhXuPhat extends StatefulWidget {
  bool? add;
  QuyetDinhXuPhat({this.add, Key? key}) : super(key: key);

  @override
  State<QuyetDinhXuPhat> createState() => _QuyetDinhXuPhatState();
}

class _QuyetDinhXuPhatState extends State<QuyetDinhXuPhat> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: QuyetDinhXuPhatBody(
      add: widget.add,
    ));
  }
}

class QuyetDinhXuPhatBody extends StatefulWidget {
  bool? add;
  QuyetDinhXuPhatBody({this.add, Key? key}) : super(key: key);

  @override
  State<QuyetDinhXuPhatBody> createState() => _QuyetDinhXuPhatBodyState();
}

class _QuyetDinhXuPhatBodyState extends State<QuyetDinhXuPhatBody> {
  @override
  // bool get wantKeepAlive =>
  //     true;
  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/quyet-dinh-xu-phat', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          print(widget.add == true ? 1 : 0);
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
                        Padding(
                          padding: EdgeInsets.only(left: 5, right: 5),
                          child: Text(
                            '/',
                            style: TextStyle(
                              color: Color(0xffC8C9CA),
                            ),
                          ),
                        ),
                        Text('Kiểm soát',
                            style: TextStyle(color: Color(0xff009C87))),
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
                        initialIndex: widget.add == true ? 1 : 0,
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
                                LSPhat(),
                                ThemQuyetDinhXuPhat(),
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
