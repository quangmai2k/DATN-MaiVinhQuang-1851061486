import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/source_information/setting-data/object-tts.dart';
import 'package:intl/intl.dart';

import '../../../../../api.dart';
import '../../../../../common/style.dart';

class ViewSK extends StatefulWidget {
  TTS infoTTS;
  ViewSK({required this.infoTTS});
  @override
  State<ViewSK> createState() => VViewSKStates();
}

class VViewSKStates extends State<ViewSK> {
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
      child: ListView(
        controller: ScrollController(),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sức khỏe',
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
          Container(
            child: (widget.infoTTS.ttsForm!.id == 1)
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            margin: EdgeInsets.only(top: 10, right: 30),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Chiều cao:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.height != null) ? "${widget.infoTTS.height} cm" : "",
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            margin: EdgeInsets.only(top: 10, right: 30),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Mù màu:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: (widget.infoTTS.colorBlind != null)
                                      ? SelectableText(
                                          (widget.infoTTS.colorBlind == 1) ? "Có" : "Không",
                                        )
                                      : Text(''),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            margin: EdgeInsets.only(top: 10, right: 30),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Đã phẫu thuật lần nào chưa?",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: (widget.infoTTS.everSurgery != null)
                                      ? SelectableText(
                                          (widget.infoTTS.everSurgery == 1) ? "Rồi" : "Chưa",
                                        )
                                      : Text(''),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            margin: EdgeInsets.only(top: 10, right: 30),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Có uống rượu, bia không?",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: (widget.infoTTS.drinkAlcohol != null)
                                      ? SelectableText(
                                          (widget.infoTTS.drinkAlcohol == 1) ? "Có" : "Không",
                                        )
                                      : Text(''),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            margin: EdgeInsets.only(top: 10, right: 30),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Khám sức khỏe trước thi tuyển",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: (widget.infoTTS.examHealthCertificate != null && widget.infoTTS.examHealthCertificate != "")
                                      ? TextButton(
                                          onPressed: () {
                                            downloadFile(widget.infoTTS.examHealthCertificate!);
                                          },
                                          child: Text('tải file'),
                                        )
                                      : SelectableText('Chưa có'),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            margin: EdgeInsets.only(top: 10, right: 30),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Khám sức khỏe trước xuất cảnh",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: (widget.infoTTS.flightHealthCertificate != null && widget.infoTTS.flightHealthCertificate != "")
                                      ? TextButton(
                                          onPressed: () {
                                            downloadFile(widget.infoTTS.flightHealthCertificate!);
                                          },
                                          child: Text('tải file'),
                                        )
                                      : SelectableText('Chưa có'),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            margin: EdgeInsets.only(top: 10, right: 30),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Ngày khám SK:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: (widget.infoTTS.examCheckDate != null)
                                      ? SelectableText('${DateFormat("yyyy").format(widget.infoTTS.examCheckDate!)}')
                                      : Text(''),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            margin: EdgeInsets.only(top: 10, right: 30),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Ngày khám lại:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: (widget.infoTTS.flightCheckDate != null)
                                      ? SelectableText('${DateFormat("yyyy").format(widget.infoTTS.flightCheckDate!)}')
                                      : Text(''),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            margin: EdgeInsets.only(top: 10, right: 30),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Ngày xét nghiệm PCR:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: (widget.infoTTS.pcrTestDate != null)
                                      ? Text('${DateFormat("yyyy").format(widget.infoTTS.pcrTestDate!)}')
                                      : Text(''),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )),
                      Expanded(
                          child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            margin: EdgeInsets.only(top: 10, left: 30),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Cân nặng:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.weight != null) ? "${widget.infoTTS.weight} kg" : "",
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            margin: EdgeInsets.only(top: 10, left: 30),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Nhóm máu:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: (widget.infoTTS.bloodGroup != null)
                                      ? SelectableText(
                                          (widget.infoTTS.bloodGroup == 0)
                                              ? "A"
                                              : (widget.infoTTS.bloodGroup == 1)
                                                  ? "B"
                                                  : (widget.infoTTS.bloodGroup == 2)
                                                      ? "AB"
                                                      : "O",
                                        )
                                      : Text(''),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            margin: EdgeInsets.only(top: 10, left: 30),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Có hình xăm không?",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: (widget.infoTTS.tatoo != null)
                                      ? SelectableText(
                                          (widget.infoTTS.tatoo == 1) ? "Có" : "Không",
                                        )
                                      : Text(''),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            margin: EdgeInsets.only(top: 10, left: 30),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Có hút thuốc không?",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: (widget.infoTTS.smoke != null)
                                      ? SelectableText(
                                          (widget.infoTTS.smoke == 1) ? "Có" : "Không",
                                        )
                                      : Text(''),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            margin: EdgeInsets.only(top: 10, left: 30),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Tình trạng sức khỏe:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: (widget.infoTTS.healthStatus != null)
                                      ? SelectableText(
                                          (widget.infoTTS.healthStatus == 1) ? "Xấu" : "Tốt",
                                        )
                                      : Text(''),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            margin: EdgeInsets.only(top: 10, left: 30),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Thông số tiêm Covid:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: (widget.infoTTS.covidInjection != null)
                                      ? SelectableText(
                                          "${widget.infoTTS.covidInjection}",
                                        )
                                      : SelectableText('0'),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            margin: EdgeInsets.only(top: 10, left: 30),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Kết quả SK:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: (widget.infoTTS.examCheckDate != null)
                                      ? (widget.infoTTS.examHealthCheckResult != null)
                                          ? SelectableText(
                                              (widget.infoTTS.examHealthCheckResult == 1) ? "Đạt" : "Không đạt",
                                            )
                                          : Text('')
                                      : Text(""),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            margin: EdgeInsets.only(top: 10, left: 30),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Kết quả sau khi khám lại:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: (widget.infoTTS.flightCheckDate != null)
                                      ? (widget.infoTTS.flightHealthCheckResult != null)
                                          ? SelectableText(
                                              (widget.infoTTS.flightHealthCheckResult == 1) ? "Đạt" : "Không đạt",
                                            )
                                          : Text('')
                                      : Text(''),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: boxStyle,
                            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                            margin: EdgeInsets.only(top: 10, left: 30),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    "Kết quả PCR:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                    child: (widget.infoTTS.pcrTestDate != null)
                                        ? (widget.infoTTS.pcrTestResult != null)
                                            ? SelectableText(
                                                (widget.infoTTS.pcrTestResult == 1) ? "Dương tính" : "Âm tính",
                                              )
                                            : Text('')
                                        : Text('')),
                              ],
                            ),
                          ),
                        ],
                      )),
                    ],
                  )
                : (widget.infoTTS.ttsForm!.id == 2)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: boxStyle,
                                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                margin: EdgeInsets.only(top: 10, right: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Tình trạng sức khỏe:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: (widget.infoTTS.healthStatus != null)
                                          ? SelectableText(
                                              (widget.infoTTS.healthStatus == 1) ? "Xấu" : "Tốt",
                                            )
                                          : Text(''),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: boxStyle,
                                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                margin: EdgeInsets.only(top: 10, right: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Chiều cao:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: SelectableText(
                                        (widget.infoTTS.height != null) ? "${widget.infoTTS.height} cm" : "",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: boxStyle,
                                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                margin: EdgeInsets.only(top: 10, right: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Thị lực:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: (widget.infoTTS.eyeSight != null)
                                          ? SelectableText(
                                              (widget.infoTTS.eyeSight == 0) ? "Không kính" : "Có kính",
                                            )
                                          : Text(''),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: boxStyle,
                                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                margin: EdgeInsets.only(top: 10, right: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Thị lực mắt trái:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: SelectableText(
                                        (widget.infoTTS.leftEyesight != null) ? "${widget.infoTTS.leftEyesight}" : "",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: boxStyle,
                                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                margin: EdgeInsets.only(top: 10, right: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Có uống rượu, bia không?",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: (widget.infoTTS.drinkAlcohol != null)
                                          ? SelectableText(
                                              (widget.infoTTS.drinkAlcohol == 1) ? "Có" : "Không",
                                            )
                                          : Text(''),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: boxStyle,
                                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                margin: EdgeInsets.only(top: 10, right: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Thuận tay:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: (widget.infoTTS.rightHanded != null)
                                          ? SelectableText(
                                              (widget.infoTTS.rightHanded == 1)
                                                  ? (widget.infoTTS.leftHanded == 1)
                                                      ? "cả hai tay"
                                                      : "phải"
                                                  : (widget.infoTTS.leftHanded == 1)
                                                      ? "trái"
                                                      : "",
                                            )
                                          : Text(''),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: boxStyle,
                                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                margin: EdgeInsets.only(top: 10, right: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Khám sức khỏe trước thi tuyển",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: (widget.infoTTS.examHealthCertificate != null && widget.infoTTS.examHealthCertificate != "")
                                          ? TextButton(
                                              onPressed: () {
                                                downloadFile(widget.infoTTS.examHealthCertificate!);
                                              },
                                              child: Text('tải file'),
                                            )
                                          : SelectableText('Chưa có'),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: boxStyle,
                                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                margin: EdgeInsets.only(top: 10, right: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Khám sức khỏe trước xuất cảnh",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: (widget.infoTTS.flightHealthCertificate != null && widget.infoTTS.flightHealthCertificate != "")
                                          ? TextButton(
                                              onPressed: () {
                                                downloadFile(widget.infoTTS.flightHealthCertificate!);
                                              },
                                              child: Text('tải file'),
                                            )
                                          : SelectableText('Chưa có'),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: boxStyle,
                                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                margin: EdgeInsets.only(top: 10, right: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Ngày khám SK:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: (widget.infoTTS.examCheckDate != null)
                                          ? SelectableText('${DateFormat("yyyy").format(widget.infoTTS.examCheckDate!)}')
                                          : Text(''),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: boxStyle,
                                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                margin: EdgeInsets.only(top: 10, right: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Ngày khám lại:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: (widget.infoTTS.flightCheckDate != null)
                                          ? SelectableText('${DateFormat("yyyy").format(widget.infoTTS.flightCheckDate!)}')
                                          : Text(''),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: boxStyle,
                                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                margin: EdgeInsets.only(top: 10, right: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Ngày xét nghiệm PCR:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: (widget.infoTTS.pcrTestDate != null)
                                          ? Text('${DateFormat("yyyy").format(widget.infoTTS.pcrTestDate!)}')
                                          : Text(''),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )),
                          Expanded(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: boxStyle,
                                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                margin: EdgeInsets.only(top: 10, left: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Nhóm máu:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: (widget.infoTTS.bloodGroup != null)
                                          ? SelectableText(
                                              (widget.infoTTS.bloodGroup == 0)
                                                  ? "A"
                                                  : (widget.infoTTS.bloodGroup == 1)
                                                      ? "B"
                                                      : (widget.infoTTS.bloodGroup == 2)
                                                          ? "AB"
                                                          : "O",
                                            )
                                          : Text(''),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: boxStyle,
                                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                margin: EdgeInsets.only(top: 10, left: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Cân nặng:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: SelectableText(
                                        (widget.infoTTS.weight != null) ? "${widget.infoTTS.weight} kg" : "",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: boxStyle,
                                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                margin: EdgeInsets.only(top: 10, left: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Thính lực:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: SelectableText(
                                        (widget.infoTTS.hearing != null) ? "${widget.infoTTS.hearing}" : "",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: boxStyle,
                                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                margin: EdgeInsets.only(top: 10, left: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Thị lực mắt phải:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: SelectableText(
                                        (widget.infoTTS.rightEyesight != null) ? "${widget.infoTTS.rightEyesight}" : "",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: boxStyle,
                                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                margin: EdgeInsets.only(top: 10, left: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Có hút thuốc không?",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: (widget.infoTTS.smoke != null)
                                          ? SelectableText(
                                              (widget.infoTTS.smoke == 1) ? "Có" : "Không",
                                            )
                                          : Text(''),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: boxStyle,
                                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                margin: EdgeInsets.only(top: 10, left: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Bệnh trong quá khứ:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: SelectableText(
                                        (widget.infoTTS.pastPathology != null) ? "${widget.infoTTS.pastPathology}" : "",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: boxStyle,
                                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                margin: EdgeInsets.only(top: 10, left: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Bệnh hiện tại:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: SelectableText(
                                        (widget.infoTTS.currentPathology != null) ? "${widget.infoTTS.currentPathology}" : "",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: boxStyle,
                                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                margin: EdgeInsets.only(top: 10, left: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Thông số tiêm Covid:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: (widget.infoTTS.covidInjection != null)
                                          ? SelectableText(
                                              "${widget.infoTTS.covidInjection}",
                                            )
                                          : SelectableText('0'),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: boxStyle,
                                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                margin: EdgeInsets.only(top: 10, left: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Kết quả SK:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: (widget.infoTTS.examCheckDate != null)
                                          ? (widget.infoTTS.examHealthCheckResult != null)
                                              ? SelectableText(
                                                  (widget.infoTTS.examHealthCheckResult == 1) ? "Đạt" : "Không đạt",
                                                )
                                              : Text('')
                                          : Text(""),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: boxStyle,
                                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                margin: EdgeInsets.only(top: 10, left: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Kết quả sau khi khám lại:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: (widget.infoTTS.flightCheckDate != null)
                                          ? (widget.infoTTS.flightHealthCheckResult != null)
                                              ? SelectableText(
                                                  (widget.infoTTS.flightHealthCheckResult == 1) ? "Đạt" : "Không đạt",
                                                )
                                              : Text('')
                                          : Text(''),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: boxStyle,
                                padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                                margin: EdgeInsets.only(top: 10, left: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Kết quả PCR:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                        child: (widget.infoTTS.pcrTestDate != null)
                                            ? (widget.infoTTS.pcrTestResult != null)
                                                ? SelectableText(
                                                    (widget.infoTTS.pcrTestResult == 1) ? "Dương tính" : "Âm tính",
                                                  )
                                                : Text('')
                                            : Text('')),
                                  ],
                                ),
                              ),
                            ],
                          )),
                        ],
                      )
                    : Row(),
          ),
        ],
      ),
    );
  }
}
