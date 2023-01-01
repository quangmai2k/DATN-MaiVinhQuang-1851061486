import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/he_thong/cai_dat_nguoi_dung/form_quan_ly_nguoi_dung.dart';
import 'package:provider/provider.dart';

import '../../../../common/style.dart';
import '../../../../model/model.dart';
import '../../navigation.dart';

class CaiDatNguoiDung extends StatelessWidget {
  const CaiDatNguoiDung({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: CaiDatNguoiDungBody());
  }
}

class CaiDatNguoiDungBody extends StatefulWidget {
  const CaiDatNguoiDungBody({Key? key}) : super(key: key);

  @override
  State<CaiDatNguoiDungBody> createState() => _CaiDatNguoiDungBodyState();
}

class _CaiDatNguoiDungBodyState extends State<CaiDatNguoiDungBody> {
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
                      Text('Cài đặt người dùng', style: titlePage),
                    ],
                  ),
                ),
                Expanded(child: FormQuanLyNguoiDung()),
              ],
            ));
  }
}
