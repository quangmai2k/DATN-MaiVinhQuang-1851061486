import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/style.dart';
import '../../../../api.dart';

final String urlThuongDonHang = "/thuong-don-hang";
TextEditingController orderBonus = TextEditingController();
TextEditingController targetBonus = TextEditingController();
var listOrder = {};
var listOrderId = {};

class ThuongDonHang extends StatefulWidget {
  final String idDonHang;
  ThuongDonHang({Key? key, required this.idDonHang}) : super(key: key);

  @override
  State<ThuongDonHang> createState() => _TargetBonusViewState();
}

class _TargetBonusViewState extends State<ThuongDonHang> with AutomaticKeepAliveClientMixin<ThuongDonHang> {
  getOrderTargetBonus() async {
    print("/api/thuong-chitieu-donhang/get/page?filter=approve:1 and orderId:${widget.idDonHang}");
    var response = await httpGet("/api/thuong-chitieu-donhang/get/page?filter=approve:1 and orderId:${widget.idDonHang}", context);
    if (response.containsKey("body")) {
      setState(() {
        listOrderId = jsonDecode(response["body"]);
      });
    }
  }

  callApi() async {
    await getOrderTargetBonus();
  }

  @override
  void initState() {
    super.initState();
    callApi();
  }

  @override
  bool get wantKeepAlive => true;
  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          padding: paddingBoxContainer,
          margin: marginBoxFormTab,
          width: MediaQuery.of(context).size.width * 1,
          height: 600,
          decoration: BoxDecoration(
            color: colorWhite,
            borderRadius: borderRadiusContainer,
            boxShadow: [boxShadowContainer],
            border: borderAllContainerBox,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Thông báo', style: titleBox),
                  Icon(Icons.more_horiz, color: colorIconTitleBox, size: sizeIconTitleBox),
                ],
              ),
              //--------------Đường line-------------
              Container(
                margin: marginTopBottomHorizontalLine,
                child: Divider(thickness: 1, color: ColorHorizontalLine),
              ),
              //------------kết thúc đường line--------
              (listOrderId["content"].isNotEmpty)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 10, bottom: 15),
                          child: Row(
                            children: [
                              SizedBox(width: 10),
                              Expanded(
                                flex: 5,
                                child: Row(
                                  children: [Text("Thưởng chỉ tiêu:         ${listOrderId["content"][0]["targetBonus"]}", style: titleTableData)],
                                ),
                              ),
                              Expanded(flex: 1, child: Text('VND/TTS')),
                              Expanded(flex: 9, child: Container()),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 10, bottom: 15),
                          child: Row(
                            children: [
                              SizedBox(width: 10),
                              Expanded(
                                flex: 5,
                                child: Row(
                                  children: [Text("Thưởng đơn hàng:     ${listOrderId["content"][0]["orderBonus"]}", style: titleTableData)],
                                ),
                              ),
                              Expanded(flex: 1, child: Text('VND/TTS')),
                              Expanded(flex: 9, child: Container()),
                            ],
                          ),
                        ),
                        //
                      ],
                    )
                  : Text("Đơn hàng chưa có thưởng", style: titleTableData),
            ],
          ),
        ),
      ],
    );
  }
}
