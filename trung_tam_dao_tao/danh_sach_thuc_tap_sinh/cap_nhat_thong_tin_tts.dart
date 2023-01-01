import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/model/model.dart';
import 'package:gentelella_flutter/widgets/ui/trung_tam_dao_tao/danh_sach_thuc_tap_sinh/form_thong_tin_dao_tao.dart';
import 'package:provider/provider.dart';

import '../../../../common/style.dart';
import '../../navigation.dart';

Color borderBlack = Colors.black54;

class CapNhatThongTinTTS extends StatelessWidget {
  const CapNhatThongTinTTS({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: CapNhatThongTinTTSBody());
  }
}

class CapNhatThongTinTTSBody extends StatefulWidget {
  const CapNhatThongTinTTSBody({Key? key}) : super(key: key);

  @override
  State<CapNhatThongTinTTSBody> createState() => _CapNhatThongTinTTSBodyState();
}

class _CapNhatThongTinTTSBodyState extends State<CapNhatThongTinTTSBody> {
  final String urlAddNewUpdateSI =
      "quan-ly-thong-tin-thuc-tap-sinh/add-new-update";

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
    return Consumer<NavigationModel>(
        builder: (context, navigationModel, child) => Column(children: [
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
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
                            Text('Trung tâm đào tạo',
                                style: TextStyle(color: Color(0xff009C87))),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('Thêm mới - Cập nhật', style: titlePage),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Cán bộ tuyển dụng', style: titleWidgetBox),
                              SizedBox(
                                width: 25,
                              ),
                              Container(
                                color: Colors.white,
                                width: MediaQuery.of(context).size.width * 0.20,
                                height: 40,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    isExpanded: true,
                                    hint: Row(
                                      children: [
                                        Text(
                                          selectedValue,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    items: itemsGrid
                                        .map((item) => DropdownMenuItem<String>(
                                              value: item,
                                              child: Text(
                                                item,
                                              ),
                                            ))
                                        .toList(),
                                    // value: selectedValue,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedValue = value as String;
                                      });
                                    },
                                    dropdownDecoration: BoxDecoration(
                                        border: Border.all(
                                            color: const Color.fromRGBO(
                                                216, 218, 229, 1))),
                                    buttonDecoration: BoxDecoration(
                                        border: Border.all(
                                            width: 0.5,
                                            style: BorderStyle.solid)),
                                    buttonElevation: 0,
                                    buttonPadding: const EdgeInsets.only(
                                        left: 14, right: 14),
                                    itemPadding: const EdgeInsets.only(
                                        left: 14, right: 14),
                                    dropdownElevation: 5,
                                    focusColor: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: marginLeftBtn,
                          child: TextButton(
                            style: TextButton.styleFrom(
                              padding: paddingBtn,
                              shape: RoundedRectangleBorder(
                                borderRadius: borderRadiusBtn,
                              ),
                              backgroundColor: backgroundColorBtn,
                              primary: Theme.of(context).iconTheme.color,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .caption
                                  ?.copyWith(
                                      fontSize: 10.0, letterSpacing: 2.0),
                            ),
                            onPressed: () {
                              navigationModel.add(pageUrl: urlAddNewUpdateSI);
                            },
                            child: Row(
                              children: [
                                Text('Lưu', style: textButton),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
                        length: 4,
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
                                      Icons.directions_car,
                                      color: mainColorPage,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Thông tin cá nhân",
                                      style: titleTabbar,
                                    )
                                  ]),
                                  Row(children: [
                                    Icon(
                                      Icons.directions_transit,
                                      color: mainColorPage,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Hồ sơ cá nhân",
                                      style: titleTabbar,
                                    )
                                  ]),
                                  Row(children: [
                                    Icon(
                                      Icons.directions_bike,
                                      color: Color(0xff009C87),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Thông tin đào tạo",
                                      style: titleTabbar,
                                    )
                                  ]),
                                  Row(children: [
                                    Icon(
                                      Icons.directions_bike,
                                      color: Color(0xff009C87),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "Thông tin liên hệ khẩn cấp",
                                      style: titleTabbar,
                                    )
                                  ])
                                ],
                              ),
                            ),
                            Expanded(
                              child: TabBarView(children: [
                                Container(),
                                Container(
                                  child: Text("User Body"),
                                ),
                                ThongTinDaoTao(),
                                Container(
                                  child: Text("User Body"),
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
            ]));
  }
}
