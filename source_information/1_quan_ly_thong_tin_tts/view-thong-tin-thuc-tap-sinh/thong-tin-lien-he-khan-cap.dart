import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/source_information/setting-data/object-tts.dart';

import '../../../../../common/style.dart';
import '../../../../common/style.dart';

class ViewTTLHKC extends StatefulWidget {
  TTS infoTTS;
  ViewTTLHKC({required this.infoTTS});
  @override
  State<ViewTTLHKC> createState() => ViewTTLHKCStates();
}

class ViewTTLHKCStates extends State<ViewTTLHKC> {
  BoxDecoration boxStyle = BoxDecoration(
    color: Color.fromARGB(137, 255, 255, 255),
    // borderRadius: borderRadiusContainer,
    boxShadow: [boxShadowContainer],
    border: borderAllContainerBox,
  );
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: paddingBoxContainer,
      margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 30),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: borderRadiusContainer,
        boxShadow: [boxShadowContainer],
        border: borderAllContainerBox,
      ),
      child: (widget.infoTTS.lienHeKhanCap != null)
          ? ListView(
              controller: ScrollController(),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Thông tin liên hệ khẩn cấp',
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
                      flex: 1,
                      child: Container(),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          Container(
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            margin: EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Facebook:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.lienHeKhanCap!.facebook != null) ? "${widget.infoTTS.lienHeKhanCap!.facebook}" : "",
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            margin: EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Skype:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.lienHeKhanCap!.skype != null) ? "${widget.infoTTS.lienHeKhanCap!.skype}" : "",
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            margin: EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Họ và Tên:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.lienHeKhanCap!.name != null) ? "${widget.infoTTS.lienHeKhanCap!.name}" : "",
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 10),
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Quan hệ:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.lienHeKhanCap!.relation != null) ? "${widget.infoTTS.lienHeKhanCap!.relation}" : "",
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 10),
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Số điện thoại:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.lienHeKhanCap!.phone != null) ? "${widget.infoTTS.lienHeKhanCap!.phone}" : "",
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(bottom: 10),
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Địa chỉ:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.lienHeKhanCap!.address != null) ? "${widget.infoTTS.lienHeKhanCap!.address}" : "",
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                  ],
                )
              ],
            )
          : Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Thông tin liên hệ khẩn cấp',
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
                  child: Text("Không có thông tin"),
                ),
              ],
            ),
    );
  }
}
