import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/style.dart';

import '../../../../../api.dart';
import '../../../../../model/market_development/order.dart';

class BonusTarget extends StatefulWidget {
  final Order? order;
  BonusTarget({Key? key, this.order}) : super(key: key);

  @override
  State<BonusTarget> createState() => _BonusTargetState();
}

class _BonusTargetState extends State<BonusTarget> {
  var listOrderId = {};
  getOrderTargetBonus() async {
    print("/api/thuong-chitieu-donhang/get/page?filter=approve:1 and orderId:${widget.order!.id}");
    var response = await httpGet("/api/thuong-chitieu-donhang/get/page?filter=approve:1 and orderId:${widget.order!.id}", context);
    if (response.containsKey("body")) {
      setState(() {
        listOrderId = jsonDecode(response["body"]);
      });
    }
  }

  bool _setLoading = false;
  @override
  void initState() {
    super.initState();
    callApi();
  }

  callApi() async {
    await getOrderTargetBonus();
    setState(() {
      _setLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _setLoading
        ? ListView(
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
                        Text(
                          'Thông báo',
                          style: titleBox,
                        ),
                        Icon(
                          Icons.more_horiz,
                          color: colorIconTitleBox,
                          size: sizeIconTitleBox,
                        ),
                      ],
                    ),
                    //--------------Đường line-------------
                    Container(
                      margin: marginTopBottomHorizontalLine,
                      child: Divider(
                        thickness: 1,
                        color: ColorHorizontalLine,
                      ),
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
                                        children: [
                                          Text(
                                            "Thưởng chỉ tiêu:         ${listOrderId["content"][0]["targetBonus"]}",
                                            style: titleTableData,
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Text('VND/TTS'),
                                    ),
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
                                    Expanded(
                                      flex: 1,
                                      child: Text('VND/TTS'),
                                    ),
                                    Expanded(flex: 9, child: Container()),
                                  ],
                                ),
                              ),
                              //
                            ],
                          )
                        : Text(
                            "Đơn hàng chưa có thưởng",
                            style: titleTableData,
                          ),
                  ],
                ),
              ),
            ],
          )
        : Center(
            child: Center(child: CircularProgressIndicator()),
          );
  }
}
