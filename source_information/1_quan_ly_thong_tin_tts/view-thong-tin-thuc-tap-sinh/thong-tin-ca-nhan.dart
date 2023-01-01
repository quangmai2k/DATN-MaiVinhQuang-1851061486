import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/source_information/setting-data/object-tts.dart';
import 'package:intl/intl.dart';

import '../../../../../common/style.dart';
import '../../../../../config.dart';

import 'dart:js' as js;

class ViewTTCN extends StatefulWidget {
  TTS infoTTS;
  ViewTTCN({required this.infoTTS});
  @override
  State<ViewTTCN> createState() => ViewTTCNStates();
}

class ViewTTCNStates extends State<ViewTTCN> {
  static const borderRadiusContainer = BorderRadius.all(
    Radius.elliptical(0, 0),
  );
  final formatTien = new NumberFormat('#,##0', 'en_US');
  @override
  void initState() {
    super.initState();
    // print("widget.infoTTS.avatar:${widget.infoTTS.avatar}");
  }

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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Text(
                      'Thông tin cá nhân tts',
                      style: titleBox,
                    ),
                    SelectableText(
                      "  ${widget.infoTTS.userCode} ",
                      style: TextStyle(color: Colors.red),
                    )
                  ],
                ),
              ),
              SizedBox(width: 50.0),
              Expanded(
                flex: 2,
                child: (widget.infoTTS.recommendUser!.id != null)
                    ? Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Người giới thiệu:',
                              style: titleBox,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 5,
                            child: SelectableText('${widget.infoTTS.recommendUser!.userCode} - ${widget.infoTTS.recommendUser!.fullName}'),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Người giới thiệu:',
                              style: titleBox,
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            flex: 5,
                            child: Text('Không'),
                          ),
                        ],
                      ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '',
                  style: titleBox,
                ),
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
          (widget.infoTTS.ttsForm!.id == 1)
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Loại form:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.ttsForm!.formName != null) ? "${widget.infoTTS.ttsForm!.formName}" : "",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Ngày sinh:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: (widget.infoTTS.birthDate != null)
                                      ? SelectableText(
                                          "${DateFormat("dd/MM/yyyy").format(widget.infoTTS.birthDate!)}",
                                        )
                                      : Row(),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Tuổi:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: (widget.infoTTS.birthDate != null)
                                      ? SelectableText(
                                          "${DateTime.now().year - widget.infoTTS.birthDate!.year}",
                                        )
                                      : Row(),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
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
                                  child: SelectableText((widget.infoTTS.address != null) ? "${widget.infoTTS.address}" : ""),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "SĐT TTS:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      SelectableText((widget.infoTTS.phone != null) ? widget.infoTTS.phone! : "", style: bangDuLieu),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      InkWell(
                                          onTap: () async {
                                            js.context.callMethod('call', [widget.infoTTS.phone]);
                                          },
                                          child: Icon(
                                            Icons.phone_in_talk,
                                            color: Color.fromARGB(255, 52, 147, 224),
                                          )),
                                    ],
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "SĐT gia đình:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText((widget.infoTTS.mobile != null) ? "${widget.infoTTS.mobile}" : ""),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Email:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.email != null) ? "${widget.infoTTS.email}" : "",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Dân tộc:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.dantoc != null && widget.infoTTS.dantoc!.folkName != null)
                                        ? "${widget.infoTTS.dantoc!.folkName}"
                                        : "",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Kinh nghiệm sống tập thể:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: (widget.infoTTS.livedInGroup != null)
                                      ? SelectableText(
                                          (widget.infoTTS.livedInGroup == 1) ? "Có" : "Chưa",
                                        )
                                      : Text(''),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Điểm mạnh (Trong tính cách):",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.personalityTrength != null) ? "${widget.infoTTS.personalityTrength}" : "",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Sở thích:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.hobby != null) ? "${widget.infoTTS.hobby}" : "",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Chuyên ngành được đào tạo:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.specialize != null) ? "${widget.infoTTS.specialize}" : "",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Thu nhập bản thân:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.personalIncome != null) ? "${formatTien.format(widget.infoTTS.personalIncome)} VNĐ/tháng" : "",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Đã từng ra nước ngoài:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.abroadEver != null)
                                        ? (widget.infoTTS.abroadEver == 0)
                                            ? "Chưa"
                                            : "Có"
                                        : "",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Thu nhập mong muốn sau 3 năm:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.desiredIncome3Years != null) ? widget.infoTTS.desiredIncome3Years! : "",
                                  ),
                                ),
                              ],
                            ),
                            (widget.infoTTS.ttsForm!.id != null && widget.infoTTS.ttsForm!.id == 2)
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Thời gian:",
                                            style: titleWidgetBox,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: SelectableText(
                                            (widget.infoTTS.desiredIncome3Years != null) ? "${widget.infoTTS.workTime}" : "",
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Row(),
                            (widget.infoTTS.ttsForm!.id != null && widget.infoTTS.ttsForm!.id == 2)
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            "Địa điểm:",
                                            style: titleWidgetBox,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          child: SelectableText(
                                            (widget.infoTTS.desiredIncome3Years != null) ? "${widget.infoTTS.workAddress}" : "",
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : Row(),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Điểm cộng dồn:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.cumulativePoint != null) ? "${widget.infoTTS.cumulativePoint}" : "",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Thị lực mắt:",
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
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Thị lực mắt phải:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: (widget.infoTTS.rightEyesight != null)
                                      ? SelectableText(
                                          widget.infoTTS.rightEyesight!,
                                        )
                                      : Text(''),
                                ),
                              ],
                            ),
                          ],
                        )),
                    SizedBox(width: 50.0),
                    Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Họ và tên:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.fullName != null) ? "${widget.infoTTS.fullName}" : "",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Giới tính:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.gender != null)
                                        ? (widget.infoTTS.gender == 1)
                                            ? "Nam"
                                            : (widget.infoTTS.gender == 0)
                                                ? "Nữ"
                                                : "Khác"
                                        : "",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Số CMND/CCCD:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.idCardNo != null) ? "${widget.infoTTS.idCardNo}" : "",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Ngày cấp:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.issuedDate != null) ? "${DateFormat("dd/MM/yyyy").format(widget.infoTTS.issuedDate!)}" : "",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Nơi cấp:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.issuedBy != null) ? "${widget.infoTTS.issuedBy}" : "",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Tình trạng hôn nhân:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.maritalStatus != null)
                                        ? (widget.infoTTS.maritalStatus == 0)
                                            ? "Chưa kết hôn"
                                            : (widget.infoTTS.maritalStatus == 1)
                                                ? "Đã kết hôn"
                                                : "Ly hôn"
                                        : "",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Trình độ học vấn:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.trinhDoHocVan != null)
                                        ? (widget.infoTTS.trinhDoHocVan!.name != null)
                                            ? "${widget.infoTTS.trinhDoHocVan!.name}"
                                            : ""
                                        : "",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Tôn giáo:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.tongiao != null)
                                        ? (widget.infoTTS.tongiao!.id != null)
                                            ? (widget.infoTTS.tongiao!.id == 1)
                                                ? "Có"
                                                : "Không"
                                            : ""
                                        : "",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Biết nấu ăn:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: (widget.infoTTS.cook != null)
                                      ? SelectableText(
                                          (widget.infoTTS.cook == 1) ? "Có" : "Không",
                                        )
                                      : Text(''),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Điểm yếu (Trong tính cách):",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.personalityWeakness != null) ? "${widget.infoTTS.personalityWeakness}" : "",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Tự nhận xét về tính cách:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.personalityWeakness != null) ? "${widget.infoTTS.personalityWeakness}" : "",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Lý do đi nhật:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.reasonGoJapan != null) ? "${widget.infoTTS.reasonGoJapan}" : "",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Thu nhập gia đình:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.familyIncome != null) ? "${formatTien.format(widget.infoTTS.familyIncome)} VNĐ/tháng" : "",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Đã từng xin visa đi Nhật:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: (widget.infoTTS.japanVisaApplied != null)
                                      ? SelectableText(
                                          (widget.infoTTS.japanVisaApplied == 0) ? "Chưa" : "Có",
                                        )
                                      : Text(""),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Làm gì khi hết hạn hợp đồng:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.workAfterContractExpired != null) ? "${widget.infoTTS.workAfterContractExpired}" : "",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Điểm IQ:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: SelectableText(
                                    (widget.infoTTS.iqPoint != null) ? "${widget.infoTTS.iqPoint}" : "",
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                                  ? "Cả hai tay"
                                                  : "phải"
                                              : (widget.infoTTS.leftHanded == 1)
                                                  ? "trái"
                                                  : "",
                                        )
                                      : Text(''),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Thị lực mắt trái:",
                                    style: titleWidgetBox,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: (widget.infoTTS.leftEyesight != null)
                                      ? SelectableText(
                                          widget.infoTTS.leftEyesight!,
                                        )
                                      : Text(''),
                                ),
                              ],
                            ),
                          ],
                        )),
                    Expanded(
                        flex: 1,
                        child: (widget.infoTTS.avatar != null && widget.infoTTS.avatar != "")
                            ? Container(
                                margin: EdgeInsets.only(top: 50, left: 30),
                                child: Image.network(
                                  "$baseUrl/api/files/${widget.infoTTS.avatar}",
                                  width: 150,
                                  height: 150,
                                ))
                            : Text(""))
                  ],
                )
              : (widget.infoTTS.ttsForm!.id == 2)
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Loại form:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: SelectableText(
                                        (widget.infoTTS.ttsForm!.formName != null) ? "${widget.infoTTS.ttsForm!.formName}" : "",
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Ngày sinh:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: (widget.infoTTS.birthDate != null)
                                          ? SelectableText(
                                              "${DateFormat("dd/MM/yyyy").format(widget.infoTTS.birthDate!)}",
                                            )
                                          : Row(),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Tuổi:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: (widget.infoTTS.birthDate != null)
                                          ? SelectableText(
                                              "${DateTime.now().year - widget.infoTTS.birthDate!.year}",
                                            )
                                          : Row(),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
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
                                      child: SelectableText((widget.infoTTS.address != null) ? "${widget.infoTTS.address}" : ""),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "SĐT TTS:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          SelectableText((widget.infoTTS.phone != null) ? widget.infoTTS.phone! : "", style: bangDuLieu),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          InkWell(
                                              onTap: () async {
                                                js.context.callMethod('call', [widget.infoTTS.phone]);
                                              },
                                              child: Icon(
                                                Icons.phone_in_talk,
                                                color: Color.fromARGB(255, 52, 147, 224),
                                              )),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "SĐT gia đình:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: SelectableText((widget.infoTTS.mobile != null) ? "${widget.infoTTS.mobile}" : ""),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Email:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: SelectableText(
                                        (widget.infoTTS.email != null) ? "${widget.infoTTS.email}" : "",
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                        SizedBox(width: 50.0),
                        Expanded(
                            flex: 2,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Họ và tên:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: SelectableText(
                                        (widget.infoTTS.fullName != null) ? "${widget.infoTTS.fullName}" : "",
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Giới tính:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: SelectableText(
                                        (widget.infoTTS.gender != null)
                                            ? (widget.infoTTS.gender == 1)
                                                ? "Nam"
                                                : (widget.infoTTS.gender == 0)
                                                    ? "Nữ"
                                                    : "Khác"
                                            : "",
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Số CMND/CCCD:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: SelectableText(
                                        (widget.infoTTS.idCardNo != null) ? "${widget.infoTTS.idCardNo}" : "",
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Ngày cấp:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: SelectableText(
                                        (widget.infoTTS.issuedDate != null) ? "${DateFormat("dd/MM/yyyy").format(widget.infoTTS.issuedDate!)}" : "",
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Nơi cấp:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: SelectableText(
                                        (widget.infoTTS.issuedBy != null) ? "${widget.infoTTS.issuedBy}" : "",
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Tình trạng hôn nhân:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: SelectableText(
                                        (widget.infoTTS.maritalStatus != null)
                                            ? (widget.infoTTS.maritalStatus == 0)
                                                ? "Chưa kết hôn"
                                                : (widget.infoTTS.maritalStatus == 1)
                                                    ? "Đã kết hôn"
                                                    : "Ly hôn"
                                            : "",
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Đã từng xin visa đi Nhật:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: (widget.infoTTS.japanVisaApplied != null)
                                          ? SelectableText(
                                              (widget.infoTTS.japanVisaApplied == 0) ? "Chưa" : "Có",
                                            )
                                          : Text(""),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Thu nhập mong muốn:",
                                        style: titleWidgetBox,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(child: SelectableText((widget.infoTTS.desiredIncome != null) ? "${widget.infoTTS.desiredIncome}" : "")),
                                  ],
                                ),
                                (widget.infoTTS.ttsForm!.id != null && widget.infoTTS.ttsForm!.id == 2)
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Thời gian:",
                                                style: titleWidgetBox,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: SelectableText(
                                                (widget.infoTTS.workTime != null) ? "${widget.infoTTS.workTime}" : "",
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Row(),
                                (widget.infoTTS.ttsForm!.id != null && widget.infoTTS.ttsForm!.id == 2)
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Địa điểm:",
                                                style: titleWidgetBox,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: SelectableText(
                                                (widget.infoTTS.workAddress != null) ? "${widget.infoTTS.workAddress}" : "",
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Row(),
                                (widget.infoTTS.ttsForm!.id != null && widget.infoTTS.ttsForm!.id == 2)
                                    ? Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                "Công việc muốn làm tại Nhật:",
                                                style: titleWidgetBox,
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: SelectableText(
                                                (widget.infoTTS.desiredProfessionJapanDescription != null)
                                                    ? "${widget.infoTTS.desiredProfessionJapanDescription}"
                                                    : "",
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Row(),
                              ],
                            )),
                        Expanded(
                            flex: 1,
                            child: (widget.infoTTS.avatar != null && widget.infoTTS.avatar != "")
                                ? Container(
                                    margin: EdgeInsets.only(top: 50, left: 30),
                                    child: Image.network(
                                      "$baseUrl/api/files/${widget.infoTTS.avatar}",
                                      width: 150,
                                      height: 150,
                                    ))
                                : Text(""))
                      ],
                    )
                  : Row(),
          (widget.infoTTS.ttsForm!.id == 1)
              ? Container(
                  margin: EdgeInsets.only(top: 40),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1),
                  ),
                  child: Column(
                    children: [
                      Container(
                        color: mainColorPage,
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Center(
                            child: Text(
                          "QUÁ TRÌNH HỌC TẬP",
                          style: titleTableData,
                        )),
                      ),
                      Table(
                        border: TableBorder(
                          top: BorderSide(width: 1),
                          horizontalInside: BorderSide(width: 1),
                          verticalInside: BorderSide(width: 1),
                          // borderRadius: BorderRadius.all(Radius.circular(9))
                        ),
                        children: [
                          TableRow(children: [
                            Column(children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text('Từ tháng/năm', style: titleWidgetBox, textAlign: TextAlign.center),
                              SizedBox(
                                height: 10,
                              )
                            ]),
                            Column(children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text('Đến tháng/năm', style: titleWidgetBox, textAlign: TextAlign.center),
                              SizedBox(
                                height: 10,
                              )
                            ]),
                            Column(children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text('Tên Trường', style: titleWidgetBox, textAlign: TextAlign.center),
                              SizedBox(
                                height: 10,
                              )
                            ]),
                            Column(children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text('Chuyên nhành đào tạo', style: titleWidgetBox, textAlign: TextAlign.center),
                              SizedBox(
                                height: 10,
                              )
                            ]),
                            Column(children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text('Bằng cấp/Chứng chỉ', style: titleWidgetBox, textAlign: TextAlign.center),
                              SizedBox(
                                height: 10,
                              )
                            ]),
                          ]),
                          for (var i = 0; i < widget.infoTTS.quaTrinhHocTap!.length; i++)
                            TableRow(children: [
                              Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                                  child: (widget.infoTTS.quaTrinhHocTap![i].dateFrom != null)
                                      ? SelectableText('${DateFormat("MM/yyyy").format(widget.infoTTS.quaTrinhHocTap![i].dateFrom!)}',
                                          textAlign: TextAlign.center)
                                      : Text(''),
                                )
                              ]),
                              Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                                  child: (widget.infoTTS.quaTrinhHocTap![i].dateTo != null)
                                      ? SelectableText('${DateFormat("MM/yyyy").format(widget.infoTTS.quaTrinhHocTap![i].dateTo!)}',
                                          textAlign: TextAlign.center)
                                      : Text(''),
                                )
                              ]),
                              Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                                  child: SelectableText(
                                      (widget.infoTTS.quaTrinhHocTap![i].schoolName != null) ? '${widget.infoTTS.quaTrinhHocTap![i].schoolName}' : '',
                                      textAlign: TextAlign.center),
                                )
                              ]),
                              Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                                  child: SelectableText(
                                      (widget.infoTTS.quaTrinhHocTap![i].specialized != null)
                                          ? '${widget.infoTTS.quaTrinhHocTap![i].specialized}'
                                          : '',
                                      textAlign: TextAlign.center),
                                )
                              ]),
                              Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                                  child: SelectableText(
                                      (widget.infoTTS.quaTrinhHocTap![i].certificate != null)
                                          ? '${widget.infoTTS.quaTrinhHocTap![i].certificate}'
                                          : '',
                                      textAlign: TextAlign.center),
                                )
                              ]),
                            ]),
                        ],
                      ),
                    ],
                  ),
                )
              : (widget.infoTTS.ttsForm!.id == 2)
                  ? Container(
                      margin: EdgeInsets.only(top: 40),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1),
                      ),
                      child: Column(
                        children: [
                          Container(
                              color: mainColorPage,
                              padding: EdgeInsets.only(top: 10, bottom: 10),
                              child: Center(
                                  child: Text(
                                "QUÁ TRÌNH HỌC TẬP ( Từ PTTH trở lên )",
                                style: titleTableData,
                              ))),
                          Table(
                            border: TableBorder(
                              top: BorderSide(width: 1),
                              horizontalInside: BorderSide(width: 1),
                              verticalInside: BorderSide(width: 1),
                              // borderRadius: BorderRadius.all(Radius.circular(9))
                            ),
                            children: [
                              TableRow(children: [
                                Column(children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Khóa học', style: titleWidgetBox, textAlign: TextAlign.center),
                                  SizedBox(
                                    height: 10,
                                  )
                                ]),
                                Column(children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Tên trường', style: titleWidgetBox, textAlign: TextAlign.center),
                                  SizedBox(
                                    height: 10,
                                  )
                                ]),
                                Column(children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Chuyên ngành', style: titleWidgetBox, textAlign: TextAlign.center),
                                  SizedBox(
                                    height: 10,
                                  )
                                ]),
                                Column(children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Địa chỉ', style: titleWidgetBox, textAlign: TextAlign.center),
                                  SizedBox(
                                    height: 10,
                                  )
                                ]),
                              ]),
                              for (var i = 0; i < widget.infoTTS.quaTrinhHocTap!.length; i++)
                                TableRow(children: [
                                  // Column(children: [
                                  //   Padding(
                                  //     padding: const EdgeInsets.only(top: 10, bottom: 10),
                                  //     child: (widget.infoTTS.quaTrinhHocTap![i].dateFrom != null &&
                                  //             widget.infoTTS.quaTrinhHocTap![i].dateTo != null)
                                  //         ? SelectableText(
                                  //             '${DateFormat("yyyy").format(widget.infoTTS.quaTrinhHocTap![i].dateFrom!)}-${DateFormat("yyyy").format(widget.infoTTS.quaTrinhHocTap![i].dateTo!)}',
                                  //             textAlign: TextAlign.center)
                                  //         : Text(''),
                                  //   )
                                  // ]),
                                  Column(children: [
                                    Padding(
                                        padding: const EdgeInsets.only(top: 10, bottom: 10), child: SelectableText('', textAlign: TextAlign.center))
                                  ]),
                                  Column(children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: SelectableText(
                                          (widget.infoTTS.quaTrinhHocTap![i].schoolName != null)
                                              ? '${widget.infoTTS.quaTrinhHocTap![i].schoolName}'
                                              : '',
                                          textAlign: TextAlign.center),
                                    )
                                  ]),
                                  Column(children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: SelectableText(
                                          (widget.infoTTS.quaTrinhHocTap![i].specialized != null)
                                              ? '${widget.infoTTS.quaTrinhHocTap![i].specialized}'
                                              : '',
                                          textAlign: TextAlign.center),
                                    )
                                  ]),
                                  Column(children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: SelectableText(
                                          (widget.infoTTS.quaTrinhHocTap![i].address != null) ? '${widget.infoTTS.quaTrinhHocTap![i].address}' : '',
                                          textAlign: TextAlign.center),
                                    )
                                  ]),
                                ]),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Row(),
          (widget.infoTTS.ttsForm!.id != null)
              ? Container(
                  margin: EdgeInsets.only(top: 40),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1),
                  ),
                  child: Column(
                    children: [
                      Container(
                        color: mainColorPage,
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Center(
                            child: Text(
                          "KINH NGHIỆM LÀM VIỆC",
                          style: titleTableData,
                        )),
                      ),
                      Table(
                        border: TableBorder(
                          top: BorderSide(width: 1),
                          horizontalInside: BorderSide(width: 1),
                          verticalInside: BorderSide(width: 1),

                          // color: Color.fromARGB(255, 0, 0, 0),
                          // style: BorderStyle.solid,
                          // width: 1,
                          // borderRadius: BorderRadius.all(Radius.circular(9))
                        ),
                        children: [
                          TableRow(children: [
                            Column(children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text('Từ tháng/năm', style: titleWidgetBox, textAlign: TextAlign.center),
                              SizedBox(
                                height: 10,
                              )
                            ]),
                            Column(children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text('Đến tháng/năm', style: titleWidgetBox, textAlign: TextAlign.center),
                              SizedBox(
                                height: 10,
                              )
                            ]),
                            Column(children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text('Tên công ty', style: titleWidgetBox, textAlign: TextAlign.center),
                              SizedBox(
                                height: 10,
                              )
                            ]),
                            Column(children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text('Nội dung công việc', style: titleWidgetBox, textAlign: TextAlign.center),
                              SizedBox(
                                height: 10,
                              )
                            ]),
                          ]),
                          for (var i = 0; i < widget.infoTTS.kinhNghiemLamViec!.length; i++)
                            TableRow(children: [
                              Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                                  child: (widget.infoTTS.kinhNghiemLamViec![i].dateFrom != null)
                                      ? SelectableText('${DateFormat("MM/yyyy").format(widget.infoTTS.kinhNghiemLamViec![i].dateFrom!)}',
                                          textAlign: TextAlign.center)
                                      : Text(''),
                                )
                              ]),
                              Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                                  child: (widget.infoTTS.kinhNghiemLamViec![i].dateTo != null)
                                      ? SelectableText('${DateFormat("MM/yyyy").format(widget.infoTTS.kinhNghiemLamViec![i].dateTo!)}',
                                          textAlign: TextAlign.center)
                                      : Text(''),
                                )
                              ]),
                              Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                                  child: SelectableText(
                                      (widget.infoTTS.kinhNghiemLamViec![i].companyName != null)
                                          ? '${widget.infoTTS.kinhNghiemLamViec![i].companyName}'
                                          : "",
                                      textAlign: TextAlign.center),
                                )
                              ]),
                              Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                                  child: SelectableText(
                                      (widget.infoTTS.kinhNghiemLamViec![i].workContent != null)
                                          ? '${widget.infoTTS.kinhNghiemLamViec![i].workContent}'
                                          : "",
                                      textAlign: TextAlign.center),
                                )
                              ]),
                            ]),
                        ],
                      ),
                    ],
                  ),
                )
              : Row(),
          (widget.infoTTS.ttsForm!.id != null)
              ? (widget.infoTTS.ttsForm!.id == 1)
                  ? Container(
                      margin: EdgeInsets.only(top: 40),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1),
                      ),
                      child: Column(
                        children: [
                          Container(
                            color: mainColorPage,
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Center(
                                child: Text(
                              "TÌNH TRẠNG HỌC TẬP",
                              style: titleTableData,
                            )),
                          ),
                          Table(
                            border: TableBorder(
                              top: BorderSide(width: 1),
                              horizontalInside: BorderSide(width: 1),
                              verticalInside: BorderSide(width: 1),
                            ),
                            children: [
                              TableRow(children: [
                                Column(children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Học muộn', style: titleWidgetBox, textAlign: TextAlign.center),
                                  SizedBox(
                                    height: 10,
                                  )
                                ]),
                                Column(children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Học sớm', style: titleWidgetBox, textAlign: TextAlign.center),
                                  SizedBox(
                                    height: 10,
                                  )
                                ]),
                                Column(children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Học lại', style: titleWidgetBox, textAlign: TextAlign.center),
                                  SizedBox(
                                    height: 10,
                                  )
                                ]),
                                Column(children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Năm nào', style: titleWidgetBox, textAlign: TextAlign.center),
                                  SizedBox(
                                    height: 10,
                                  )
                                ]),
                              ]),
                              for (var i = 0; i < widget.infoTTS.tinhTrangHocTap!.length; i++)
                                TableRow(children: [
                                  Column(children: [
                                    Padding(
                                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                                        child: (widget.infoTTS.tinhTrangHocTap![i].lateAdmission == 1)
                                            ? Icon(
                                                Icons.check_circle,
                                                color: Colors.blue,
                                              )
                                            : Icon(Icons.radio_button_unchecked))
                                  ]),
                                  Column(children: [
                                    Padding(
                                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                                        child: (widget.infoTTS.tinhTrangHocTap![i].earlyAdmission == 1)
                                            ? Icon(Icons.check_circle)
                                            : Icon(Icons.radio_button_unchecked))
                                  ]),
                                  Column(children: [
                                    Padding(
                                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                                        child: (widget.infoTTS.tinhTrangHocTap![i].repetitionAdmission == 1)
                                            ? Icon(Icons.check_circle)
                                            : Icon(Icons.radio_button_unchecked))
                                  ]),
                                  Column(children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: SelectableText(
                                          (widget.infoTTS.tinhTrangHocTap![i].yearAdmission != null)
                                              ? '${DateFormat('yyyy').format(DateTime.parse(widget.infoTTS.tinhTrangHocTap![i].yearAdmission!))}'
                                              : "",
                                          textAlign: TextAlign.center),
                                    )
                                  ]),
                                ]),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Row()
              : Row(),
          (widget.infoTTS.ttsForm!.id != null && widget.infoTTS.ttsForm!.id == 2)
              ? Container(
                  margin: EdgeInsets.only(top: 40),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1),
                  ),
                  child: Column(
                    children: [
                      Container(
                        color: mainColorPage,
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Center(
                            child: Text(
                          "BẰNG CẤP CHỨNG CHỈ",
                          style: titleTableData,
                        )),
                      ),
                      Table(
                        border: TableBorder(
                          top: BorderSide(width: 1),
                          horizontalInside: BorderSide(width: 1),
                          verticalInside: BorderSide(width: 1),
                        ),
                        children: [
                          TableRow(children: [
                            Column(children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text('Tháng/Năm', style: titleWidgetBox, textAlign: TextAlign.center),
                              SizedBox(
                                height: 10,
                              )
                            ]),
                            Column(children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text('Bằng cấp chứng chỉ', style: titleWidgetBox, textAlign: TextAlign.center),
                              SizedBox(
                                height: 10,
                              )
                            ]),
                            Column(children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text('Nội dung cấp độ', style: titleWidgetBox, textAlign: TextAlign.center),
                              SizedBox(
                                height: 10,
                              )
                            ]),
                          ]),
                          for (var i = 0; i < widget.infoTTS.trinhDoHocVanKiSu!.length; i++)
                            TableRow(children: [
                              Column(children: [
                                Padding(
                                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                                    child: SelectableText(
                                        (widget.infoTTS.trinhDoHocVanKiSu![i].issueDate != null)
                                            ? '${DateFormat("MM-yyyy").format(widget.infoTTS.trinhDoHocVanKiSu![i].issueDate!)}'
                                            : '',
                                        textAlign: TextAlign.center))
                              ]),
                              Column(children: [
                                Padding(
                                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                                    child: SelectableText(
                                        (widget.infoTTS.trinhDoHocVanKiSu![i].academy != null)
                                            ? '${widget.infoTTS.trinhDoHocVanKiSu![i].academy!.name}'
                                            : '',
                                        textAlign: TextAlign.center))
                              ]),
                              Column(children: [
                                Padding(
                                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                                    child: SelectableText(
                                        (widget.infoTTS.trinhDoHocVanKiSu![i].description != null)
                                            ? '${widget.infoTTS.trinhDoHocVanKiSu![i].description}'
                                            : '',
                                        textAlign: TextAlign.center))
                              ]),
                            ]),
                        ],
                      ),
                    ],
                  ),
                )
              : Row(),
          (widget.infoTTS.ttsForm!.id != null)
              ? (widget.infoTTS.ttsForm!.id == 2)
                  ? Container(
                      margin: EdgeInsets.only(top: 40),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1),
                      ),
                      child: Column(
                        children: [
                          Container(
                            color: mainColorPage,
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Center(
                                child: Text(
                              "KĨ NĂNG MÁY TÍNH VÀ SỬ DỤNG PHẦN MỀM",
                              style: titleTableData,
                            )),
                          ),
                          Table(
                            border: TableBorder(
                              top: BorderSide(width: 1),
                              horizontalInside: BorderSide(width: 1),
                              verticalInside: BorderSide(width: 1),
                            ),
                            children: [
                              TableRow(children: [
                                Column(children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Kĩ năng', style: titleWidgetBox, textAlign: TextAlign.center),
                                  SizedBox(
                                    height: 10,
                                  )
                                ]),
                                Column(children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Kém', style: titleWidgetBox, textAlign: TextAlign.center),
                                  SizedBox(
                                    height: 10,
                                  )
                                ]),
                                Column(children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Trung bình', style: titleWidgetBox, textAlign: TextAlign.center),
                                  SizedBox(
                                    height: 10,
                                  )
                                ]),
                                Column(children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Thành thạo', style: titleWidgetBox, textAlign: TextAlign.center),
                                  SizedBox(
                                    height: 10,
                                  )
                                ]),
                              ]),
                              TableRow(children: [
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: Text('Sử dụng Internet, Email:', textAlign: TextAlign.center))
                                ]),
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: (widget.infoTTS.trinhDoMayTinh != null)
                                          ? (widget.infoTTS.trinhDoMayTinh!.internetEmail == 0)
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: Colors.blue,
                                                )
                                              : Icon(Icons.radio_button_unchecked)
                                          : Icon(Icons.radio_button_unchecked))
                                ]),
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: (widget.infoTTS.trinhDoMayTinh != null)
                                          ? (widget.infoTTS.trinhDoMayTinh!.internetEmail == 1)
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: Colors.blue,
                                                )
                                              : Icon(Icons.radio_button_unchecked)
                                          : Icon(Icons.radio_button_unchecked))
                                ]),
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: (widget.infoTTS.trinhDoMayTinh != null)
                                          ? (widget.infoTTS.trinhDoMayTinh!.internetEmail == 2)
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: Colors.blue,
                                                )
                                              : Icon(Icons.radio_button_unchecked)
                                          : Icon(Icons.radio_button_unchecked))
                                ]),
                              ]),
                              TableRow(children: [
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: Text('Sử dụng phần mềm Word:', textAlign: TextAlign.center))
                                ]),
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: (widget.infoTTS.trinhDoMayTinh != null)
                                          ? (widget.infoTTS.trinhDoMayTinh!.msWord == 0)
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: Colors.blue,
                                                )
                                              : Icon(Icons.radio_button_unchecked)
                                          : Icon(Icons.radio_button_unchecked))
                                ]),
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: (widget.infoTTS.trinhDoMayTinh != null)
                                          ? (widget.infoTTS.trinhDoMayTinh!.msWord == 1)
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: Colors.blue,
                                                )
                                              : Icon(Icons.radio_button_unchecked)
                                          : Icon(Icons.radio_button_unchecked))
                                ]),
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: (widget.infoTTS.trinhDoMayTinh != null)
                                          ? (widget.infoTTS.trinhDoMayTinh!.msWord == 2)
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: Colors.blue,
                                                )
                                              : Icon(Icons.radio_button_unchecked)
                                          : Icon(Icons.radio_button_unchecked))
                                ]),
                              ]),
                              TableRow(children: [
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: Text('Sử dụng phần mềm Excel:', textAlign: TextAlign.center))
                                ]),
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: (widget.infoTTS.trinhDoMayTinh != null)
                                          ? (widget.infoTTS.trinhDoMayTinh!.msExcel == 0)
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: Colors.blue,
                                                )
                                              : Icon(Icons.radio_button_unchecked)
                                          : Icon(Icons.radio_button_unchecked))
                                ]),
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: (widget.infoTTS.trinhDoMayTinh != null)
                                          ? (widget.infoTTS.trinhDoMayTinh!.msExcel == 1)
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: Colors.blue,
                                                )
                                              : Icon(Icons.radio_button_unchecked)
                                          : Icon(Icons.radio_button_unchecked))
                                ]),
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: (widget.infoTTS.trinhDoMayTinh != null)
                                          ? (widget.infoTTS.trinhDoMayTinh!.msExcel == 2)
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: Colors.blue,
                                                )
                                              : Icon(Icons.radio_button_unchecked)
                                          : Icon(Icons.radio_button_unchecked))
                                ]),
                              ]),
                              TableRow(children: [
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: Text('Sử dụng phần mềm CAD:', textAlign: TextAlign.center))
                                ]),
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: (widget.infoTTS.trinhDoMayTinh != null)
                                          ? (widget.infoTTS.trinhDoMayTinh!.autoCad == 0)
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: Colors.blue,
                                                )
                                              : Icon(Icons.radio_button_unchecked)
                                          : Icon(Icons.radio_button_unchecked))
                                ]),
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: (widget.infoTTS.trinhDoMayTinh != null)
                                          ? (widget.infoTTS.trinhDoMayTinh!.autoCad == 1)
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: Colors.blue,
                                                )
                                              : Icon(Icons.radio_button_unchecked)
                                          : Icon(Icons.radio_button_unchecked))
                                ]),
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: (widget.infoTTS.trinhDoMayTinh != null)
                                          ? (widget.infoTTS.trinhDoMayTinh!.autoCad == 2)
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: Colors.blue,
                                                )
                                              : Icon(Icons.radio_button_unchecked)
                                          : Icon(Icons.radio_button_unchecked))
                                ]),
                              ]),
                              TableRow(children: [
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: Text('Sử dụng phần mềm CAM:', textAlign: TextAlign.center))
                                ]),
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: (widget.infoTTS.trinhDoMayTinh != null)
                                          ? (widget.infoTTS.trinhDoMayTinh!.cam == 0)
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: Colors.blue,
                                                )
                                              : Icon(Icons.radio_button_unchecked)
                                          : Icon(Icons.radio_button_unchecked))
                                ]),
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: (widget.infoTTS.trinhDoMayTinh != null)
                                          ? (widget.infoTTS.trinhDoMayTinh!.cam == 1)
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: Colors.blue,
                                                )
                                              : Icon(Icons.radio_button_unchecked)
                                          : Icon(Icons.radio_button_unchecked))
                                ]),
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: (widget.infoTTS.trinhDoMayTinh != null)
                                          ? (widget.infoTTS.trinhDoMayTinh!.cam == 2)
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: Colors.blue,
                                                )
                                              : Icon(Icons.radio_button_unchecked)
                                          : Icon(Icons.radio_button_unchecked))
                                ]),
                              ]),
                              TableRow(children: [
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: Text('Sử dụng phần mềm CATIA:', textAlign: TextAlign.center))
                                ]),
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: (widget.infoTTS.trinhDoMayTinh != null)
                                          ? (widget.infoTTS.trinhDoMayTinh!.catia == 0)
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: Colors.blue,
                                                )
                                              : Icon(Icons.radio_button_unchecked)
                                          : Icon(Icons.radio_button_unchecked))
                                ]),
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: (widget.infoTTS.trinhDoMayTinh != null)
                                          ? (widget.infoTTS.trinhDoMayTinh!.catia == 1)
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: Colors.blue,
                                                )
                                              : Icon(Icons.radio_button_unchecked)
                                          : Icon(Icons.radio_button_unchecked))
                                ]),
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: (widget.infoTTS.trinhDoMayTinh != null)
                                          ? (widget.infoTTS.trinhDoMayTinh!.catia == 2)
                                              ? Icon(
                                                  Icons.check_circle,
                                                  color: Colors.blue,
                                                )
                                              : Icon(Icons.radio_button_unchecked)
                                          : Icon(Icons.radio_button_unchecked))
                                ]),
                              ]),
                              (widget.infoTTS.trinhDoMayTinh != null && widget.infoTTS.trinhDoMayTinh!.otherType == 1)
                                  ? TableRow(children: [
                                      Column(children: [
                                        Padding(
                                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                SelectableText(
                                                  // ${(widget.infoTTS.trinhDoMayTinh != null && widget.infoTTS.trinhDoMayTinh!.otherName != null) ? widget.infoTTS.trinhDoMayTinh!.otherName : ""}'
                                                  'Sử dụng phần mềm khác: ',
                                                  textAlign: TextAlign.center,
                                                ),
                                                SelectableText(
                                                  '${(widget.infoTTS.trinhDoMayTinh != null && widget.infoTTS.trinhDoMayTinh!.otherName != null) ? widget.infoTTS.trinhDoMayTinh!.otherName : ""}',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(color: Colors.blue),
                                                )
                                              ],
                                            )),
                                      ]),
                                      Column(children: [
                                        Padding(
                                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                                            child: (widget.infoTTS.trinhDoMayTinh != null)
                                                ? (widget.infoTTS.trinhDoMayTinh!.otherLevel == 0)
                                                    ? Icon(
                                                        Icons.check_circle,
                                                        color: Colors.blue,
                                                      )
                                                    : Icon(Icons.radio_button_unchecked)
                                                : Icon(Icons.radio_button_unchecked))
                                      ]),
                                      Column(children: [
                                        Padding(
                                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                                            child: (widget.infoTTS.trinhDoMayTinh != null)
                                                ? (widget.infoTTS.trinhDoMayTinh!.otherLevel == 1)
                                                    ? Icon(
                                                        Icons.check_circle,
                                                        color: Colors.blue,
                                                      )
                                                    : Icon(Icons.radio_button_unchecked)
                                                : Icon(Icons.radio_button_unchecked))
                                      ]),
                                      Column(children: [
                                        Padding(
                                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                                            child: (widget.infoTTS.trinhDoMayTinh != null)
                                                ? (widget.infoTTS.trinhDoMayTinh!.otherLevel == 2)
                                                    ? Icon(
                                                        Icons.check_circle,
                                                        color: Colors.blue,
                                                      )
                                                    : Icon(Icons.radio_button_unchecked)
                                                : Icon(Icons.radio_button_unchecked))
                                      ]),
                                    ])
                                  : TableRow(children: [
                                      Column(children: [
                                        Padding(
                                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                                            child: Text('Sử dụng phần mềm khác: ', textAlign: TextAlign.center))
                                      ]),
                                      Column(children: [
                                        Padding(padding: const EdgeInsets.only(top: 10, bottom: 10), child: Icon(Icons.radio_button_unchecked))
                                      ]),
                                      Column(children: [
                                        Padding(padding: const EdgeInsets.only(top: 10, bottom: 10), child: Icon(Icons.radio_button_unchecked))
                                      ]),
                                      Column(children: [
                                        Padding(padding: const EdgeInsets.only(top: 10, bottom: 10), child: Icon(Icons.radio_button_unchecked))
                                      ]),
                                    ]),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Row()
              : Row(),
          (widget.infoTTS.ttsForm!.id != null)
              ? (widget.infoTTS.ttsForm!.id == 2)
                  ? Container(
                      margin: EdgeInsets.only(top: 40),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1),
                      ),
                      child: Column(
                        children: [
                          Container(
                            color: mainColorPage,
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Center(
                                child: Text(
                              "NGOẠI NGỮ",
                              style: titleTableData,
                            )),
                          ),
                          Table(
                            border: TableBorder(
                              top: BorderSide(width: 1),
                              horizontalInside: BorderSide(width: 1),
                              verticalInside: BorderSide(width: 1),
                            ),
                            children: [
                              TableRow(children: [
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: SelectableText("Tiếng Nhật", style: titleWidgetBox, textAlign: TextAlign.center))
                                ]),
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: Row(
                                        children: [
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                (widget.infoTTS.trinhDoNgoaiNgu != null)
                                                    ? (widget.infoTTS.trinhDoNgoaiNgu!.japanese == 4)
                                                        ? Icon(
                                                            Icons.check_circle,
                                                            color: Colors.blue,
                                                          )
                                                        : Icon(Icons.radio_button_unchecked)
                                                    : Icon(Icons.radio_button_unchecked),
                                                SizedBox(width: 5),
                                                SelectableText("N4")
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                (widget.infoTTS.trinhDoNgoaiNgu != null)
                                                    ? (widget.infoTTS.trinhDoNgoaiNgu!.japanese == 3)
                                                        ? Icon(
                                                            Icons.check_circle,
                                                            color: Colors.blue,
                                                          )
                                                        : Icon(Icons.radio_button_unchecked)
                                                    : Icon(Icons.radio_button_unchecked),
                                                SizedBox(width: 5),
                                                SelectableText("N3")
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                (widget.infoTTS.trinhDoNgoaiNgu != null)
                                                    ? (widget.infoTTS.trinhDoNgoaiNgu!.japanese == 2)
                                                        ? Icon(
                                                            Icons.check_circle,
                                                            color: Colors.blue,
                                                          )
                                                        : Icon(Icons.radio_button_unchecked)
                                                    : Icon(Icons.radio_button_unchecked),
                                                SizedBox(width: 5),
                                                SelectableText("N2")
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                (widget.infoTTS.trinhDoNgoaiNgu != null)
                                                    ? (widget.infoTTS.trinhDoNgoaiNgu!.japanese == 1)
                                                        ? Icon(
                                                            Icons.check_circle,
                                                            color: Colors.blue,
                                                          )
                                                        : Icon(Icons.radio_button_unchecked)
                                                    : Icon(Icons.radio_button_unchecked),
                                                SizedBox(width: 5),
                                                SelectableText("N1")
                                              ],
                                            ),
                                          ),
                                        ],
                                      ))
                                ]),
                              ]),
                              TableRow(children: [
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: Text("Tiếng Anh", style: titleWidgetBox, textAlign: TextAlign.center))
                                ]),
                                Column(children: [
                                  Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: Row(
                                        children: [
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                (widget.infoTTS.trinhDoNgoaiNgu != null)
                                                    ? (widget.infoTTS.trinhDoNgoaiNgu!.english == 1)
                                                        ? Icon(
                                                            Icons.check_circle,
                                                            color: Colors.blue,
                                                          )
                                                        : Icon(Icons.radio_button_unchecked)
                                                    : Icon(Icons.radio_button_unchecked),
                                                SizedBox(width: 5),
                                                SelectableText("Lev A")
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                (widget.infoTTS.trinhDoNgoaiNgu != null)
                                                    ? (widget.infoTTS.trinhDoNgoaiNgu!.english == 2)
                                                        ? Icon(
                                                            Icons.check_circle,
                                                            color: Colors.blue,
                                                          )
                                                        : Icon(Icons.radio_button_unchecked)
                                                    : Icon(Icons.radio_button_unchecked),
                                                SizedBox(width: 5),
                                                SelectableText("Lev B")
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Row(
                                              children: [
                                                (widget.infoTTS.trinhDoNgoaiNgu != null)
                                                    ? (widget.infoTTS.trinhDoNgoaiNgu!.english == 3)
                                                        ? Icon(
                                                            Icons.check_circle,
                                                            color: Colors.blue,
                                                          )
                                                        : Icon(Icons.radio_button_unchecked)
                                                    : Icon(Icons.radio_button_unchecked),
                                                SizedBox(width: 5),
                                                SelectableText("Lev C")
                                              ],
                                            ),
                                          ),
                                        ],
                                      ))
                                ]),
                              ]),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Row()
              : Row(),
          (widget.infoTTS.ttsForm!.id == 1)
              ? Container(
                  margin: EdgeInsets.only(top: 40),
                  decoration: BoxDecoration(
                    border: Border.all(width: 1),
                  ),
                  child: Column(
                    children: [
                      Container(
                        color: mainColorPage,
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: Center(
                            child: Text(
                          "THÀNH PHẦN GIA ĐÌNH",
                          style: titleTableData,
                        )),
                      ),
                      Table(
                        border: TableBorder(
                          top: BorderSide(width: 1),
                          horizontalInside: BorderSide(width: 1),
                          verticalInside: BorderSide(width: 1),
                        ),
                        // columnWidths:{7,522},
                        children: [
                          TableRow(children: [
                            Column(children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text('Họ và tên', style: titleWidgetBox, textAlign: TextAlign.center),
                              SizedBox(
                                height: 10,
                              )
                            ]),
                            Column(children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text('Quan hệ', style: titleWidgetBox, textAlign: TextAlign.center),
                              SizedBox(
                                height: 10,
                              )
                            ]),
                            Column(children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text('Năm sinh', style: titleWidgetBox, textAlign: TextAlign.center),
                              SizedBox(
                                height: 10,
                              )
                            ]),
                            Column(children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text('Nghề nghiệp', style: titleWidgetBox, textAlign: TextAlign.center),
                              SizedBox(
                                height: 10,
                              )
                            ]),
                            Column(children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text('Sống chung', style: titleWidgetBox, textAlign: TextAlign.center),
                              SizedBox(
                                height: 10,
                              )
                            ]),
                            Column(children: [
                              SizedBox(
                                height: 10,
                              ),
                              Text('Sống riêng', style: titleWidgetBox, textAlign: TextAlign.center),
                              SizedBox(
                                height: 10,
                              )
                            ]),
                            Column(
                                // mainAxisAlignment: MainAxisAlignment.center,
                                // crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Đã từng xin VISA\nhoặc đã sang Nhật', style: titleWidgetBox, textAlign: TextAlign.center),
                                  SizedBox(
                                    height: 10,
                                  )
                                ]),
                          ]),
                          for (var i = 0; i < widget.infoTTS.thanhPhanGiaDinh!.length; i++)
                            TableRow(children: [
                              Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                                  child: SelectableText(
                                      (widget.infoTTS.thanhPhanGiaDinh![i].fullName != null) ? '${widget.infoTTS.thanhPhanGiaDinh![i].fullName}' : '',
                                      textAlign: TextAlign.center),
                                )
                              ]),
                              Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                                  child: SelectableText(
                                      (widget.infoTTS.thanhPhanGiaDinh![i].relation != null) ? '${widget.infoTTS.thanhPhanGiaDinh![i].relation}' : '',
                                      textAlign: TextAlign.center),
                                )
                              ]),
                              Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                                  child: (widget.infoTTS.thanhPhanGiaDinh![i].birthDate != null)
                                      ? SelectableText('${DateFormat("yyyy").format(widget.infoTTS.thanhPhanGiaDinh![i].birthDate!)}',
                                          textAlign: TextAlign.center)
                                      : Text(''),
                                )
                              ]),
                              Column(children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                                  child: SelectableText(
                                      (widget.infoTTS.thanhPhanGiaDinh![i].job != null) ? '${widget.infoTTS.thanhPhanGiaDinh![i].job}' : '',
                                      textAlign: TextAlign.center),
                                )
                              ]),
                              Column(children: [
                                Padding(
                                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                                    child: (widget.infoTTS.thanhPhanGiaDinh![i].livingTogether == 1)
                                        ? Icon(
                                            Icons.check_circle,
                                            color: Colors.blue,
                                          )
                                        : Icon(Icons.radio_button_unchecked))
                              ]),
                              Column(children: [
                                Padding(
                                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                                    child: (widget.infoTTS.thanhPhanGiaDinh![i].livingTogether == 0)
                                        ? Icon(
                                            Icons.check_circle,
                                            color: Colors.blue,
                                          )
                                        : Icon(Icons.radio_button_unchecked))
                              ]),
                              Column(children: [
                                Padding(
                                    padding: const EdgeInsets.only(top: 10, bottom: 10),
                                    child: (widget.infoTTS.thanhPhanGiaDinh![i].japanVisaApplied == 1)
                                        ? Icon(
                                            Icons.check_circle,
                                            color: Colors.blue,
                                          )
                                        : Icon(Icons.radio_button_unchecked)
                                    // child: Text('${widget.infoTTS.thanhPhanGiaDinh![i].japanVisaApplied}'),
                                    )
                              ]),
                            ]),
                        ],
                      ),
                    ],
                  ),
                )
              : (widget.infoTTS.ttsForm!.id == 2)
                  ? Container(
                      margin: EdgeInsets.only(top: 40),
                      decoration: BoxDecoration(
                        border: Border.all(width: 1),
                      ),
                      child: Column(
                        children: [
                          Container(
                            color: mainColorPage,
                            padding: EdgeInsets.only(top: 10, bottom: 10),
                            child: Center(
                                child: Text(
                              "THÀNH PHẦN GIA ĐÌNH",
                              style: titleTableData,
                            )),
                          ),
                          Table(
                            border: TableBorder(
                              top: BorderSide(width: 1),
                              horizontalInside: BorderSide(width: 1),
                              verticalInside: BorderSide(width: 1),
                            ),
                            // columnWidths:{7,522},
                            children: [
                              TableRow(children: [
                                Column(children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Họ và tên', style: titleWidgetBox, textAlign: TextAlign.center),
                                  SizedBox(
                                    height: 10,
                                  )
                                ]),
                                Column(children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Quan hệ', style: titleWidgetBox, textAlign: TextAlign.center),
                                  SizedBox(
                                    height: 10,
                                  )
                                ]),
                                Column(children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Năm sinh', style: titleWidgetBox, textAlign: TextAlign.center),
                                  SizedBox(
                                    height: 10,
                                  )
                                ]),
                                Column(children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text('Nghề nghiệp', style: titleWidgetBox, textAlign: TextAlign.center),
                                  SizedBox(
                                    height: 10,
                                  )
                                ]),
                              ]),
                              for (var i = 0; i < widget.infoTTS.thanhPhanGiaDinh!.length; i++)
                                TableRow(children: [
                                  Column(children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: SelectableText(
                                          (widget.infoTTS.thanhPhanGiaDinh![i].fullName != null)
                                              ? '${widget.infoTTS.thanhPhanGiaDinh![i].fullName}'
                                              : '',
                                          textAlign: TextAlign.center),
                                    )
                                  ]),
                                  Column(children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: SelectableText(
                                          (widget.infoTTS.thanhPhanGiaDinh![i].relation != null)
                                              ? '${widget.infoTTS.thanhPhanGiaDinh![i].relation}'
                                              : '',
                                          textAlign: TextAlign.center),
                                    )
                                  ]),
                                  Column(children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: (widget.infoTTS.thanhPhanGiaDinh![i].birthDate != null)
                                          ? SelectableText('${DateFormat("yyyy").format(widget.infoTTS.thanhPhanGiaDinh![i].birthDate!)}',
                                              textAlign: TextAlign.center)
                                          : Text(''),
                                    )
                                  ]),
                                  Column(children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 10, bottom: 10),
                                      child: SelectableText(
                                          (widget.infoTTS.thanhPhanGiaDinh![i].job != null) ? '${widget.infoTTS.thanhPhanGiaDinh![i].job}' : '',
                                          textAlign: TextAlign.center),
                                    )
                                  ]),
                                ]),
                            ],
                          ),
                        ],
                      ),
                    )
                  : Row(),
          (widget.infoTTS.ttsForm!.id == 1)
              ? Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(137, 255, 255, 255),
                    borderRadius: borderRadiusContainer,
                    boxShadow: [boxShadowContainer],
                    border: borderAllContainerBox,
                  ),
                  margin: EdgeInsets.only(top: 30),
                  padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Gia đình đồng ý cho Anh/Chị đi thực tập sinh tại nhật không?",
                        style: titleWidgetBox,
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: (widget.infoTTS.familyAgreement == 1)
                              ? Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 10),
                                    Text("Có"),
                                    SizedBox(width: 60),
                                    Icon(Icons.radio_button_unchecked),
                                    SizedBox(width: 10),
                                    Text("Không"),
                                  ],
                                )
                              : (widget.infoTTS.familyAgreement == 0)
                                  ? Row(
                                      children: [
                                        Icon(Icons.radio_button_unchecked),
                                        SizedBox(width: 10),
                                        Text("Có"),
                                        SizedBox(width: 50),
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 10),
                                        Text("Không"),
                                      ],
                                    )
                                  : Row(
                                      children: [
                                        Icon(Icons.radio_button_unchecked),
                                        SizedBox(width: 10),
                                        Text("Có"),
                                        SizedBox(width: 60),
                                        Icon(Icons.radio_button_unchecked),
                                        SizedBox(width: 10),
                                        Text("Không"),
                                      ],
                                    ))
                    ],
                  ))
              : Row(),
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(137, 255, 255, 255),
              borderRadius: borderRadiusContainer,
              boxShadow: [boxShadowContainer],
              border: borderAllContainerBox,
            ),
            margin: EdgeInsets.only(top: 30),
            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Ngành nghề mong muốn:",
                      style: titleWidgetBox,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                (widget.infoTTS.nganhNgheMongMuon!.length > 0)
                    ? Container(
                        height: 150,
                        child: ListView(
                          controller: ScrollController(),
                          children: [
                            Wrap(
                              runSpacing: 25.0,
                              spacing: 100.0,
                              children: [
                                for (var i = 0; i < widget.infoTTS.nganhNgheMongMuon!.length; i++)
                                  Container(width: 200, child: SelectableText("${widget.infoTTS.nganhNgheMongMuon![i].jobName}")),
                              ],
                            ),
                          ],
                        ),
                      )
                    : Text("Chưa có ngành nghề nào"),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(137, 255, 255, 255),
              borderRadius: borderRadiusContainer,
              boxShadow: [boxShadowContainer],
              border: borderAllContainerBox,
            ),
            margin: EdgeInsets.only(top: 30),
            padding: EdgeInsets.only(left: 20, top: 10, bottom: 10, right: 20),
            child: Text(
              "Tôi xin cam đoan những lời khai trên là hoàn toàn đúng sự thật nếu sai tôi xin chịu trách nhiệm và chấp nhận nộp phạt theo quy định của Công ty.",
              style: TextStyle(
                color: Color.fromARGB(255, 255, 0, 0),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
