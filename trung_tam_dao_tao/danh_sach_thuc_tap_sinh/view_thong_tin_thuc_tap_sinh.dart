import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/trung_tam_dao_tao/danh_sach_thuc_tap_sinh/view_thong_tin_dao_tao.dart';
import 'package:provider/provider.dart';

import '../../../../common/style.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../../../forms/thong_tin_nguon/emergency_contact_information_form.dart';
import '../../../forms/thong_tin_nguon/health_form.dart';
import '../../../forms/thong_tin_nguon/personal_information_form/show_personal_information_form/show_information _unskilled_labor_form.dart';
import '../../../forms/thong_tin_nguon/profile_form.dart';
import '../../navigation.dart';

class ViewThongTinThucTapSinh extends StatefulWidget {
  //--id này dùng để lấy id từ trang chủ để view dữ liệu ra.
  final String id;
  const ViewThongTinThucTapSinh({Key? key, required this.id}) : super(key: key);

  @override
  State<ViewThongTinThucTapSinh> createState() =>
      _ViewThongTinThucTapSinhState();
}

class _ViewThongTinThucTapSinhState extends State<ViewThongTinThucTapSinh> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
      widgetBody: Consumer<NavigationModel>(
        builder: (context, navigationModel, child) => Column(
          children: [
            TitlePageWidget(
              content: "TRUNG TÂM ĐÀO TẠO",
              textSpanWidget: [
                TextSpan(
                  text: 'Dashboard',
                  style: breadcrumbsPage,
                  mouseCursor: MaterialStateMouseCursor.clickable,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Provider.of<NavigationModel>(context, listen: false)
                          .add(pageUrl: "/bang-thong-ke-nhanh");
                    },
                ),
                TextSpan(
                  text: 'Danh sách thực tập sinh',
                  style: breadcrumbsPage,
                  mouseCursor: MaterialStateMouseCursor.clickable,
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Provider.of<NavigationModel>(context, listen: false)
                          .add(pageUrl: "/danh-sach-thuc-tap-sinh");
                    },
                ),
                TextSpan(
                  text: "Thông tin đào tạo",
                  style: titlePage,
                ),
              ],
              widgetBoxRight: [
                // Row(
                //   children: [
                //     Expanded(flex: 3, child: Container()),
                //     Expanded(
                //       flex: 5,
                //       child: Container(
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Text('Trạng thái', style: titleWidgetBox),
                //             SizedBox(
                //               width: 25,
                //             ),
                //             Text('Hủy')
                //           ],
                //         ),
                //       ),
                //     ),
                //     Expanded(
                //       flex: 5,
                //       child: Container(
                //         child: Row(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             Text('Nhân viên tuyển dụng', style: titleWidgetBox),
                //             SizedBox(
                //               width: 25,
                //             ),
                //             Text('Đào Như Quỳnh')
                //           ],
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DefaultTabController(
                      length: 8,
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
                                    Icons.list_alt_outlined,
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
                                    Icons.create_new_folder_outlined,
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
                                    Icons.health_and_safety_outlined,
                                    color: mainColorPage,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Sức khỏe",
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
                                    "Tiến cử và lịch sử",
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
                                ]),
                                Row(children: [
                                  Icon(
                                    Icons.directions_bike,
                                    color: Color(0xff009C87),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Quá trình làm việc",
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
                                    "Nhật ký xử lý",
                                    style: titleTabbar,
                                  )
                                ])
                              ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(children: [
                              //----show dữ liệu của lao động phổ thông TTS---
                              ShowInformationUnskilledLaborForm(),
                              //------Hồ sơ cá nhân-------
                              ProfileForm(
                                idTTS: widget.id,
                              ),
                              //------Sức khỏe----
                              HealthForm(
                                idTTS: widget.id,
                              ),
                              //------Tiến cử và lịch sử----
                              Container(
                                child: ViewThongTinDaoTao(id: widget.id),
                              ),
                              Container(
                                child: Text("User Body"),
                              ),
                              //--Thông tin liên hệ khẩn cấp---
                              EmergencyContactInformationForm(idTTS: widget.id),
                              //--------------------
                              Container(
                                child: Text("User Body"),
                              ),
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
          ],
        ),
      ),
    );
  }
}
