import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/ho_so_ngoai/donhang/chi_tiet_view.dart';
import 'package:gentelella_flutter/widgets/ui/ho_so_ngoai/donhang/thuondh.dart';
import 'package:gentelella_flutter/common/style.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import '../../../../../api.dart';
import '../../../../../common/format_date.dart';
import '../../../../../common/widgets_form.dart';
import '../../../../../model/market_development/order.dart';

// ignore: must_be_immutable
class ChiTietDonHang extends StatelessWidget {
  String idDonHang;
  ChiTietDonHang({
    Key? key,
    required this.idDonHang,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
      widgetBody: DonHangBody(
        idDH: idDonHang,
      ),
    );
  }
}

class DonHangBody extends StatefulWidget {
  final String idDH;
  DonHangBody({Key? key, required this.idDH}) : super(key: key);

  @override
  State<DonHangBody> createState() => _DonHangBodyState();
}

class _DonHangBodyState extends State<DonHangBody> {
  Order? order;
  bool isLoading = false;
  getOrderDetailByParentId(String idDH) async {
    var response = await httpGet("/api/donhang/get/${widget.idDH}", context);
    var body = jsonDecode(response['body']);

    if (response.containsKey("body")) {
      setState(() {
        order = Order.fromJson(body);
        // print("Thaida ${order}");
        if (order != null) {
          isLoading = true;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getOrderDetailByParentId(widget.idDH);
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Column(
            children: [
              TitlePage(
                listPreTitle: [
                  {'url': '/ho-so-ngoai', 'title': 'Dashboard'},
                  {'url': '/danh-sach-don-hang', 'title': 'Danh sách đơn hàng'},
                ],
                content: "Chi tiết đơn hàng",
              ),
              Container(
                width: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(color: colorWhite, boxShadow: [boxShadowContainer]),
                padding: paddingTitledPage,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: Container()),
                        Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text("Ngày tạo : ",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xff212529),
                                    )),
                                SizedBox(width: 10),
                                Text(order!.createdDate != null ? FormatDate.formatDateView(DateTime.tryParse(order!.createdDate.toString())!) : "",
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xff212529))),
                              ],
                            )),
                        Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Text("Nhân viên xử lý : ", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xff212529))),
                                SizedBox(width: 10),
                                Text(order!.user!.fullName != null ? order!.user!.fullName : "",
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: Color(0xff212529))),
                              ],
                            ))
                      ],
                    ),
                    SizedBox(height: 10),
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
                            constraints: BoxConstraints.expand(height: 50),
                            padding: EdgeInsets.only(left: 20, right: 20),
                            child: TabBar(
                              isScrollable: true,
                              indicatorColor: mainColorPage,
                              tabs: [
                                Row(children: [
                                  Icon(Icons.list_alt_rounded, color: mainColorPage),
                                  SizedBox(width: 10),
                                  Text("Thông tin đơn hàng", style: titleWidget)
                                ]),
                                Row(children: [
                                  Icon(Icons.list_alt_rounded, color: mainColorPage),
                                  SizedBox(width: 10),
                                  Text("Chỉ tiêu tính thưởng", style: titleWidget)
                                ]),
                              ],
                            ),
                          ),
                          Expanded(
                            child: TabBarView(children: [
                              TTCTDonHang(order: order, isLoading: isLoading),
                              ThuongDonHang(idDonHang: widget.idDH),
                            ]),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ))
            ],
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }
}
