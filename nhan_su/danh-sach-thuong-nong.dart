import 'package:flutter/material.dart';
import '../../../common/widgets_form.dart';
import '../ho_so_noi/thuong_chitieu/thuong_chitieu_lichsu.dart';
import '../ho_so_noi/thuong_don_hang/thuong_donhang_lichsu.dart';
import '../navigation.dart';

class DanhSachThuongNong extends StatefulWidget {
  const DanhSachThuongNong({Key? key}) : super(key: key);

  @override
  _DanhSachThuongNongState createState() => _DanhSachThuongNongState();
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _DanhSachThuongNongState extends State<DanhSachThuongNong> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: DanhSachThuongNongBody());
  }
}

class DanhSachThuongNongBody extends StatefulWidget {
  const DanhSachThuongNongBody({Key? key}) : super(key: key);
  @override
  State<DanhSachThuongNongBody> createState() => _DanhSachThuongNongBodyState();
}

class _DanhSachThuongNongBodyState extends State<DanhSachThuongNongBody> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/danh-sach-thuong-nong', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Column(
            children: [
              TitlePage(
                listPreTitle: [
                  {'url': "/nhan-su", 'title': 'Dashboard'},
                ],
                content: 'Chỉ tiêu nguồn',
              ),
              Flexible(child: ThuongChiTieuLichSu()),
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
