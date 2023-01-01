// ignore: duplicate_ignore
// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/kiem_soat/quyet_dinh_xu_phat_update/rule.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../api.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../../../forms/nhan_su/setting-data/duty.dart';
import '../../../forms/nhan_su/setting-data/userAAM.dart';
import '../../navigation.dart';

class ThemMoiCapNhatQDXP extends StatefulWidget {
  final String? id;
  const ThemMoiCapNhatQDXP({Key? key, this.id}) : super(key: key);

  @override
  State<ThemMoiCapNhatQDXP> createState() => _ThemMoiCapNhatQDXPState();
}

class _ThemMoiCapNhatQDXPState extends State<ThemMoiCapNhatQDXP> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: ThemMoiCapNhatQDXPBody(
      id: widget.id,
    ));
  }
}

class ThemMoiCapNhatQDXPBody extends StatefulWidget {
  final String? id;
  const ThemMoiCapNhatQDXPBody({Key? key, this.id}) : super(key: key);

  @override
  State<ThemMoiCapNhatQDXPBody> createState() => _ThemMoiCapNhatQDXPBodyState();
}

class _ThemMoiCapNhatQDXPBodyState extends State<ThemMoiCapNhatQDXPBody> {
  late Future<dynamic> getApi;
  var listItemsDoiTuongPhat = [
    {'name': 'Thực tập sinh', 'value': '0'},
    {'name': 'Nhân viên', 'value': '1'}
  ];
  var listItemsQuyDinh = [];
  var selectedQuyDinh;
  dynamic selectedDoiTuongPhat = '0';
  getQuyDinh() async {
    var listData;
    var response = await httpGet("/api/quydinh/get/page?sort=id", context);
    if (response.containsKey("body")) {
      setState(() {
        listData = jsonDecode(response["body"]);
      });
      listItemsQuyDinh = [];
      for (var row in listData['content']) {
        listItemsQuyDinh
            .add({'value': row['id'].toString(), 'name': row['ruleName']});
      }
      return listData['content'];
    }
    return 0;
  }

  var listQuyetDinh = [{''}];
  callApi() async {
    await getQuyDinh();

    return 0;
  }

  @override
  void initState() {
    getApi = callApi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: getApi,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return SingleChildScrollView(
            child: Container(
                decoration: BoxDecoration(
                  color: colorWhite,
                  borderRadius: borderRadiusContainer,
                  boxShadow: [boxShadowContainer],
                  border: borderAllContainerBox,
                ),
                padding: paddingBoxContainer,
                margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Column(children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Nhập thông tin',
                        style: titleBox,
                      ),
                      Icon(
                        Icons.more_horiz,
                        color: Color(0xff9aa5ce),
                        size: 14,
                      ),
                    ],
                  ),
                  Container(
                    margin: marginTopBottomHorizontalLine,
                    child: Divider(
                      thickness: 1,
                      color: ColorHorizontalLine,
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 30),
                          child: DropdownBtnSearch(
                            isAll: false,
                            label: 'Nhóm quy định',
                            listItems: listItemsQuyDinh,
                            search: TextEditingController(),
                            isSearch: true,
                            selectedValue: selectedQuyDinh,
                            setSelected: (selected) {
                              selectedQuyDinh = selected;
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 100,
                      ),
                      Expanded(
                        child: TextFieldValidatedForm(
                            type: 'Text',
                            label: 'Nội dung vi phạm',
                            height: 40,
                            requiredValue: 1,
                            controller: TextEditingController(),
                            enter: () {}),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                ])),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return Center(child: const CircularProgressIndicator());
      },
    );
  }
}

class TTS {
  int? id;
  String? fullName;
  DateTime? birthDate;
  int? careUser;
  String? nameCareUser;
  int? orderId;
  String? donHang;
  String? ngayTrungTuyen;
  TTS(
      {this.id,
      this.fullName,
      this.birthDate,
      this.careUser,
      this.nameCareUser,
      this.orderId,
      this.donHang,
      this.ngayTrungTuyen});
}

class QuyDinh1 {
  int id;
  String ruleName;
  int? ruleId;
  int? parentId;
  int? object;
  int? fines;
  String? content;
  QuyDinh1(
      {required this.id,
      this.parentId,
      this.ruleId,
      required this.ruleName,
      this.object,
      this.fines,
      this.content});
}

class Quyetdinhxuphat {
  int? quyetDinhCha;
  int? option; //0 là TTS, 1 Cán bộ
  TTS? tts;
  UserAAM? userAAM;
  Duty? vatro;
  QuyDinh1? quyDinhcon;
  String? reason;
  Quyetdinhxuphat(
      {this.quyetDinhCha,
      this.option,
      this.tts,
      this.vatro,
      this.quyDinhcon,
      this.userAAM,
      this.reason});
}
