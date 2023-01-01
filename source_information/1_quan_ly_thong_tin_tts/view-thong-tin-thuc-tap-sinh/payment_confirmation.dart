import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/ho_so_ngoai/datahsn/tts.dart';

import '../../../../../api.dart';
import '../../../../../common/format_date.dart';
import '../../../../../common/style.dart';

import '../../../../common/style.dart';

class PaymentConfirmation extends StatefulWidget {
  String? idTTS;
  PaymentConfirmation({Key? key, this.idTTS});
  @override
  State<PaymentConfirmation> createState() => PaymentConfirmationStates();
}

class PaymentConfirmationStates extends State<PaymentConfirmation> {
  BoxDecoration boxStyle = BoxDecoration(
    color: Color.fromARGB(137, 255, 255, 255),
    // borderRadius: borderRadiusContainer,
    boxShadow: [boxShadowContainer],
    border: borderAllContainerBox,
  );

  var listPayment = []; //Thông tin thanh toán của thực tập sinh

  getTTSThanhToan() async {
    var infoTts;
    var getInfo = await httpGet("/api/nguoidung/get/info?filter=id:${widget.idTTS}", context);
    if (getInfo.containsKey("body")) {
      setState(() {
        infoTts = jsonDecode(getInfo['body']);
      });
    }
    String query = '';
    if (infoTts['orderId'] != null) {
      query = 'and orderId:${infoTts['orderId']}';
    }
    var response = await httpGet("/api/tts-thanhtoan/get/page?sort=createdDate,desc&filter=ttsId:${widget.idTTS} $query", context);
    if (response.containsKey("body")) {
      setState(() {
        listPayment = jsonDecode(response['body'])['content'] ?? [];
      });
      return listPayment;
    } else {
      throw Exception("failse");
    }
  }

  bool loading = false;
  callApi() async {
    await getTTSThanhToan();
    setState(() {
      loading = true;
    });
  }

  @override
  void initState() {
    callApi();
    super.initState();
  }

  String convertPaid(paid, type) {
    if (type == 1) {
      if (paid == 0)
        return "Chưa đóng tiền";
      else if (paid == 1)
        return "Hoàn thành";
      else if (paid == 2)
        return "Đóng 1 phần";
      else
        return '';
    } else {
      print(paid);
      if (paid == null)
        return 'Chưa đóng tiền';
      else if (paid.split(',').last == '0')
        return 'Đóng toàn bộ';
      else if (paid.split(',').last != '0') return 'Tháng ${paid.split(',').last}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return listPayment.length > 0
        ? loading == true
            ? Container(
                padding: paddingBoxContainer,
                margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 30),
                decoration: BoxDecoration(
                  color: colorWhite,
                  borderRadius: borderRadiusContainer,
                  boxShadow: [boxShadowContainer],
                  border: borderAllContainerBox,
                ),
                child: ListView(
                  controller: ScrollController(),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Xác nhận thanh toán',
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
                    Table(
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      border: TableBorder.all(width: 1.0, color: Color(0xffA8A8A8)),
                      children: [
                        TableRow(
                          children: [
                            Container(
                              color: mainColorPage,
                              width: MediaQuery.of(context).size.width * 1,
                              height: 50.0,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Center(
                                    child: Text('Thu tiền',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: colorWhite,
                                        ))),
                              ),
                            ),
                            Container(
                              color: mainColorPage,
                              width: MediaQuery.of(context).size.width * 1,
                              height: 50.0,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Center(
                                    child: Text('Trạng thái',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: colorWhite,
                                        ))),
                              ),
                            ),
                            Container(
                              color: mainColorPage,
                              width: MediaQuery.of(context).size.width * 1,
                              height: 50.0,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Center(
                                    child: Text('Ngày xác nhận thu',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: colorWhite,
                                        ))),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Center(
                                child: Text(
                                  "Tạm thu trước thi tuyển:",
                                  // style: titleWidgetBox,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Center(
                                child: SelectableText(
                                  convertPaid(listPayment[0]['paidBeforeExam'], 1),
                                  // style: titleWidgetBox,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Center(
                                child: (listPayment[0]['paidBeforeExamDate'] != null)
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SelectableText(
                                            "  Ngày ${FormatDate.formatDateddMMyy(DateTime.parse(listPayment[0]['paidBeforeExamDate']))}",
                                            style: TextStyle(
                                              color: Color(0xff459987),
                                              fontSize: 14,
                                              // fontWeight: w400,
                                            ),
                                          ),
                                        ],
                                      )
                                    : SelectableText("Chưa thu"),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Center(
                                child: Text(
                                  "Thu tiền sau trúng tuyển:",
                                  // style: titleWidgetBox,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Center(
                                child: SelectableText(
                                  convertPaid(listPayment[0]['paidAfterExam'], 1),
                                  // style: titleWidgetBox,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Center(
                                child: (listPayment[0]['paidAfterExamDate'] != null)
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SelectableText(
                                            "  Ngày ${FormatDate.formatDateddMMyy(DateTime.parse(listPayment[0]['paidAfterExamDate']))}",
                                            style: TextStyle(
                                              color: Color(0xff459987),
                                              fontSize: 14,
                                              // fontWeight: w400,
                                            ),
                                          ),
                                        ],
                                      )
                                    : SelectableText("Chưa thu"),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Center(
                                child: Text(
                                  "Đóng tiền ăn:",
                                  // style: titleWidgetBox,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Center(
                                child: SelectableText(
                                  convertPaid(listPayment[0]['paidFood'], 0),
                                  // style: titleWidgetBox,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Center(
                                child: (listPayment[0]['paidFoodDate'] != null)
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SelectableText(
                                            "  Ngày ${FormatDate.formatDateddMMyy(DateTime.parse(listPayment[0]['paidFoodDate']))}",
                                            style: TextStyle(
                                              color: Color(0xff459987),
                                              fontSize: 14,
                                              // fontWeight: w400,
                                            ),
                                          ),
                                        ],
                                      )
                                    : SelectableText("Chưa thu"),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Center(
                                child: Text(
                                  "Đóng tiền học:",
                                  // style: titleWidgetBox,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Center(
                                child: SelectableText(
                                  convertPaid(listPayment[0]['paidTuition'], 1),
                                  // style: titleWidgetBox,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Center(
                                child: (listPayment[0]['paidTuitionDate'] != null)
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SelectableText(
                                            "  Ngày ${FormatDate.formatDateddMMyy(DateTime.parse(listPayment[0]['paidTuitionDate']))}",
                                            style: TextStyle(
                                              color: Color(0xff459987),
                                              fontSize: 14,
                                              // fontWeight: w400,
                                            ),
                                          ),
                                        ],
                                      )
                                    : SelectableText("Chưa thu"),
                              ),
                            ),
                          ],
                        ),
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Center(
                                child: Text(
                                  "Thu tiền trước xuất cảnh:",
                                  // style: titleWidgetBox,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10.0),
                              child: Center(
                                child: SelectableText(
                                  convertPaid(listPayment[0]['paidBeforeFlight'], 1),
                                  // style: titleWidgetBox,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Center(
                                child: (listPayment[0]['paidBeforeFlightDate'] != null)
                                    ? Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          SelectableText(
                                            "  Ngày ${FormatDate.formatDateddMMyy(DateTime.parse(listPayment[0]['paidBeforeFlightDate']))}",
                                            style: TextStyle(
                                              color: Color(0xff459987),
                                              fontSize: 14,
                                              // fontWeight: w400,
                                            ),
                                          ),
                                        ],
                                      )
                                    : SelectableText("Chưa thu"),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ))
            : Center(child: CircularProgressIndicator())
        : Container(
            padding: paddingBoxContainer,
            margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 30),
            decoration: BoxDecoration(
              color: colorWhite,
              borderRadius: borderRadiusContainer,
              boxShadow: [boxShadowContainer],
              border: borderAllContainerBox,
            ),
            child: ListView(
              controller: ScrollController(),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Xác nhận thanh toán',
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
                Center(
                  child: Text('Không có kết quả phù hợp'),
                ),
              ],
            ));
  }
}
