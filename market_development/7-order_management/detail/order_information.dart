import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/format_date.dart';
import 'package:gentelella_flutter/common/style.dart';
import 'package:gentelella_flutter/model/market_development/order.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';

import 'package:group_radio_button/group_radio_button.dart';

import '../../../../../config.dart';

class OrderInformation extends StatefulWidget {
  final Order? order;
  final bool? isLoading;
  OrderInformation({Key? key, this.order, this.isLoading}) : super(key: key);

  @override
  State<OrderInformation> createState() => _OrderInformationState();
}

class _OrderInformationState extends State<OrderInformation> {
  //==============Table start

  bool idNam = false;
  bool idNu = false;
  bool idTHPT = false;
  bool idCDDH = false;
  bool idLeft = false;
  bool idRight = false;

  bool _isChuaKetHon = false;
  bool _isDaKetHon = false;
  List<Map<int, String>> _statusMarried = [
    {0: "Chưa kết hôn"},
    {1: "Đã kết hôn"},
  ];
  Map<int, String> _isMarried = {0: "Chưa kết hôn"};

  List<Map<int, String>> _statusSmoke = [
    {0: ""},
    {1: ""},
  ];
  Map<int, String> _isSmoke = {0: ""};
  //Phan trang

  //checked uống thuốc

  List<Map<int, String>> _statusUongThuoc = [
    {0: ""},
    {1: ""},
  ];
  Map<int, String> _isUongThuoc = {0: ""};

  //checked Có hình xăm

  List<Map<int, String>> _statusGotATattoo = [
    {0: ""},
    {1: ""},
  ];
  Map<int, String> _isGotATattoo = {0: ""};

  //checked Đã từng phẩu thuật

  List<Map<int, String>> _statusEverHadSurgery = [
    {0: ""},
    {1: ""},
  ];
  Map<int, String> _isEverHadSurgery = {0: ""};

  //checked Đã từng phẩu thuật mổ đẻ

  List<Map<int, String>> _statusEverHadACaesareanSection = [
    {0: ""},
    {1: ""},
  ];
  Map<int, String> _isEverHadACaesareanSection = {0: ""};
  //checked Yêu cầu khác
  TextEditingController _otherRequirementsController = TextEditingController();

  List<Map<int, String>> _statusOtherRequirements = [
    {0: ""},
    {1: ""},
  ];
  Map<int, String> _isOtherRequirements = {0: ""};

  var searchRequest = {};
  var rowCount = 5;
  var currentPage = 1;
  var resultList = [];
  var rowPerPage = 5;
  var firstRow = 1, lastRow = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      if (widget.order!.genderRequired == 2) {
        idNam = true;
        idNu = true;
      } else if (widget.order!.genderRequired == 1) {
        idNu = true;
      } else if (widget.order!.genderRequired == 0) {
        idNam = true;
      }

      idLeft = widget.order!.leftHanded == 1 ? true : false;
      idRight = widget.order!.rightHanded == 1 ? true : false;

      // if (widget.order!.maritalStatus == 1) {
      //   _isMarried = _statusMarried[1];
      // } else {
      //   _isMarried = _statusMarried[0];
      // }

      if (widget.order!.maritalStatus == 2) {
        _isDaKetHon = true;
        _isChuaKetHon = true;
      } else if (widget.order!.maritalStatus == 1) {
        _isDaKetHon = true;
        _isChuaKetHon = false;
        //_isMarried = _statusMarried[1]; //Đã kết hôn
      } else {
        //_isMarried = _statusMarried[0]; //Chưa kết hôn
        _isDaKetHon = false;
        _isChuaKetHon = true;
      }

      if (widget.order!.smoke == 1) {
        _isSmoke = _statusSmoke[0];
      } else {
        _isSmoke = _statusSmoke[1];
      }

      if (widget.order!.drinkAlcohol == 1) {
        _isUongThuoc = _statusUongThuoc[0];
      } else {
        _isUongThuoc = _statusUongThuoc[1];
      }

      if (widget.order!.tattoo == 1) {
        _isGotATattoo = _statusGotATattoo[0];
      } else {
        _isGotATattoo = _statusGotATattoo[1];
      }

      if (widget.order!.everSurgery == 1) {
        _isEverHadSurgery = _statusEverHadSurgery[0];
      } else {
        _isEverHadSurgery = _statusEverHadSurgery[1];
      }

      if (widget.order!.everCesareanSection == 1) {
        _isEverHadACaesareanSection = _statusEverHadACaesareanSection[0];
      } else {
        _isEverHadACaesareanSection = _statusEverHadACaesareanSection[1];
      }
      _otherRequirementsController.text =
          widget.order!.otherHealthRequired.toString();

      if (widget.order!.otherHealthRequiredAccept == 1) {
        _isOtherRequirements = _statusOtherRequirements[0];
      } else {
        _isOtherRequirements = _statusOtherRequirements[1];
      }
    });
  }

  Widget getImage({id, fileName}) {
    String imageUrl = "";
    if (id != null) {
      if (fileName == null) {
        if (widget.order!.id != 0) {
          imageUrl = "$baseUrl/api/files/${widget.order!.image}";
        }
      } else {
        imageUrl = "$baseUrl/api/files/$fileName";
      }
    } else {
      if (fileName != null && fileName != "null") {
        imageUrl = "$baseUrl/api/files/$fileName";
      }
    }
    if (fileName == null || fileName == "null" || fileName == "") {
      return Container();
    }
    return Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: Colors.black, width: 2.0, style: BorderStyle.solid),
        ),
        margin: EdgeInsets.only(bottom: 15),
        width: 300,
        height: 200,
        child: Image.network(imageUrl));
  }

  getValueFromCheckedKetHon(isCheckChuaKetHon, isCheckDaKetHon) {
    if (isCheckChuaKetHon && isCheckDaKetHon) {
      return 2;
    }
    if (isCheckChuaKetHon) {
      return 0;
    } else {
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        widget.isLoading!
            ? Container(
                padding: EdgeInsets.all(10),
                margin: marginBoxFormTab,
                width: MediaQuery.of(context).size.width * 1,
                decoration: BoxDecoration(
                  color: colorWhite,
                  borderRadius: borderRadiusContainer,
                  boxShadow: [boxShadowContainer],
                  border: borderAllContainerBox,
                ),
                child: Column(
                  children: [
                    widget.order!.orderUrgent == 1
                        ? Row(children: [
                            Container(
                              margin: EdgeInsets.fromLTRB(20, 10, 0, 0),
                              child: Text(
                                '*Xử lý gấp',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ])
                        : Container(),
                    widget.order!.nominateStatus == 1
                        ? Row(children: [
                            Container(
                              margin: EdgeInsets.fromLTRB(20, 10, 0, 0),
                              child: Text(
                                '*Dừng tiến cử cho đơn hàng',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ])
                        : Container(),
                    SizedBox(height: 5),
                    Center(
                      child: Text(
                        widget.order!.orderName,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      color: backgroundPage,
                      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Container(
                              padding: paddingBoxContainer,
                              margin: marginTopBoxContainer,
                              width: MediaQuery.of(context).size.width * 1,
                              decoration: BoxDecoration(
                                color: colorWhite,
                                borderRadius: borderRadiusContainer,
                                boxShadow: [boxShadowContainer],
                                border: borderAllContainerBox,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Thời hạn hợp đồng lao động :',
                                        style: titleBox,
                                      ),
                                      Text(
                                        "${widget.order!.implementTime}",
                                        style: titleBox,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            flex: 5,
                            child: Container(
                              padding: paddingBoxContainer,
                              margin: marginTopBoxContainer,
                              width: MediaQuery.of(context).size.width * 1,
                              decoration: BoxDecoration(
                                color: colorWhite,
                                borderRadius: borderRadiusContainer,
                                boxShadow: [boxShadowContainer],
                                border: borderAllContainerBox,
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Ngày phỏng vấn :',
                                        style: titleBox,
                                      ),
                                      Text(
                                        widget.order!.estimatedInterviewDate !=
                                                null
                                            ? FormatDate.formatDateView(
                                                DateTime.tryParse(widget.order!
                                                    .estimatedInterviewDate
                                                    .toString())!)
                                            : "",
                                        style: titleBox,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: backgroundPage,
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Container(
                              // padding: paddingBoxContainer,
                              margin: marginTopBoxContainer,
                              height: 500,
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
                                  Container(
                                    padding: EdgeInsets.fromLTRB(10, 15, 0, 15),
                                    width:
                                        MediaQuery.of(context).size.width * 1,
                                    color: Color(0xfffcdcb2),
                                    child: Text(
                                      'I. THÔNG TIN ĐƠN HÀNG',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                            top: 20, bottom: 15, left: 20),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                          '1.1: Nghiệp đoàn',
                                                          style:
                                                              fontSize16W800)),
                                                  Expanded(
                                                    flex: 5,
                                                    child: Text(
                                                        widget.order!.union !=
                                                                null
                                                            ? widget.order!
                                                                .union!.orgName
                                                                .toString()
                                                            : "",
                                                        style: fontSize16W400),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                            top: 20, bottom: 15, left: 20),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                          '1.2: Xí nghiệp tiếp nhận',
                                                          style:
                                                              fontSize16W800)),
                                                  Expanded(
                                                    flex: 5,
                                                    child: Text(
                                                        widget.order!
                                                                    .enterprise !=
                                                                null
                                                            ? widget
                                                                .order!
                                                                .enterprise!
                                                                .companyName
                                                                .toString()
                                                            : "",
                                                        style: fontSize16W400),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                            top: 20, bottom: 15, left: 20),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                          '1.3: Địa điểm làm việc',
                                                          style:
                                                              fontSize16W800)),
                                                  Expanded(
                                                    flex: 5,
                                                    child: Text(
                                                        widget.order != null
                                                            ? widget.order!
                                                                .workAddress
                                                                .toString()
                                                            : "",
                                                        style: fontSize16W400),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                            top: 20, bottom: 15, left: 20),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                          '1.4: Ngành nghề xin visa',
                                                          style:
                                                              fontSize16W800)),
                                                  Expanded(
                                                    flex: 5,
                                                    child: Text(
                                                        widget.order != null
                                                            ? widget.order!
                                                                .jobs!.jobName
                                                                .toString()
                                                            : "",
                                                        style: fontSize16W400),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                            top: 20, bottom: 15, left: 20),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                          '1.5: Mô tả công việc cụ thể',
                                                          style:
                                                              fontSize16W800)),
                                                  Expanded(
                                                    flex: 5,
                                                    child: Text(
                                                        widget.order != null
                                                            ? widget.order!
                                                                        .jobsDetail !=
                                                                    null
                                                                ? widget
                                                                    .order!
                                                                    .jobsDetail!
                                                                    .jobName
                                                                    .toString()
                                                                : ""
                                                            : "",
                                                        style: fontSize16W400),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            flex: 5,
                            child: Container(
                              // padding: paddingBoxContainer,
                              margin: marginTopBoxContainer,
                              height: 500,
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
                                  Container(
                                    padding: EdgeInsets.fromLTRB(10, 15, 0, 15),
                                    width:
                                        MediaQuery.of(context).size.width * 1,
                                    color: Color(0xfffcdcb2),
                                    child: Text(
                                      'II. THÔNG TIN TUYỂN DỤNG',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                            top: 20, bottom: 15, left: 20),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                          '2.1: Giới tính',
                                                          style:
                                                              fontSize16W800)),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Row(
                                                      children: [
                                                        Checkbox(
                                                          checkColor: Colors
                                                              .greenAccent,
                                                          activeColor:
                                                              Colors.red,
                                                          value: this.idNam,
                                                          onChanged: null,
                                                        ),
                                                        SizedBox(width: 10),
                                                        Text('Nam',
                                                            style:
                                                                fontSize16W400),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Row(
                                                      children: [
                                                        Checkbox(
                                                          checkColor: Colors
                                                              .greenAccent,
                                                          activeColor:
                                                              Colors.red,
                                                          value: this.idNu,
                                                          onChanged: null,
                                                        ),
                                                        SizedBox(width: 10),
                                                        Text('Nữ',
                                                            style:
                                                                fontSize16W400),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container()),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                            top: 20, bottom: 15, left: 20),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                          '2.2: Độ tuổi',
                                                          style:
                                                              fontSize16W800)),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Row(
                                                      children: [
                                                        Text('Từ',
                                                            style:
                                                                fontSize16W400),
                                                        SizedBox(width: 10),
                                                        Text(
                                                            '${widget.order!.ageFrom} tuổi',
                                                            style:
                                                                fontSize16W400),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Row(
                                                      children: [
                                                        Text('Đến',
                                                            style:
                                                                fontSize16W400),
                                                        SizedBox(width: 10),
                                                        Text(
                                                            '${widget.order!.ageTo} tuổi',
                                                            style:
                                                                fontSize16W400),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container()),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                            top: 20, bottom: 15, left: 20),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                          '2.3: Số lượng',
                                                          style:
                                                              fontSize16W800)),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                            '${widget.order!.ttsRequired}',
                                                            style:
                                                                fontSize16W400),
                                                        SizedBox(width: 10),
                                                        Text('Thi tuyển',
                                                            style:
                                                                fontSize16W400),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                            '${widget.order!.ttsMaleRequired}',
                                                            style:
                                                                fontSize16W400),
                                                        SizedBox(width: 10),
                                                        Text('Nam',
                                                            style:
                                                                fontSize16W400),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                            '${widget.order!.ttsFemaleRequired}',
                                                            style:
                                                                fontSize16W400),
                                                        SizedBox(width: 10),
                                                        Text('Nữ',
                                                            style:
                                                                fontSize16W400),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                            top: 20, bottom: 15, left: 20),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      flex: 2,
                                                      child: Container()),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                            '${widget.order!.ttsCandidates}',
                                                            style:
                                                                fontSize16W400),
                                                        SizedBox(width: 10),
                                                        Text('Trúng tuyển',
                                                            style:
                                                                fontSize16W400),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                            '${widget.order!.ttsMaleCandidates}',
                                                            style:
                                                                fontSize16W400),
                                                        SizedBox(width: 10),
                                                        Text('Nam',
                                                            style:
                                                                fontSize16W400),
                                                      ],
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 1,
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                            '${widget.order!.ttsFemaleCandidates}',
                                                            style:
                                                                fontSize16W400),
                                                        SizedBox(width: 10),
                                                        Text('Nữ',
                                                            style:
                                                                fontSize16W400),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                            top: 20, bottom: 15, left: 20),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                          '2.4: Trình độ : ',
                                                          style:
                                                              fontSize16W800)),
                                                  Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                          widget.order!.level !=
                                                                  null
                                                              ? widget.order!
                                                                  .level!.name
                                                              : "No data!",
                                                          style:
                                                              fontSize16W400)),
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container()),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                            top: 20, bottom: 15, left: 20),
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                          '2.5: Yêu cầu tay nghề',
                                                          style:
                                                              fontSize16W800)),
                                                  Expanded(
                                                    flex: 5,
                                                    child: Text(
                                                        widget.order!.skill
                                                            .toString(),
                                                        style: fontSize16W400),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: backgroundPage,
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Container(
                              // padding: paddingBoxContainer,
                              margin: marginTopBoxContainer,
                              height: 850,
                              decoration: BoxDecoration(
                                color: colorWhite,
                                borderRadius: borderRadiusContainer,
                                boxShadow: [boxShadowContainer],
                                border: borderAllContainerBox,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding:
                                          EdgeInsets.fromLTRB(10, 15, 0, 15),
                                      width:
                                          MediaQuery.of(context).size.width * 1,
                                      color: Color(0xfffcdcb2),
                                      child: Text(
                                        'III. YÊU CẦU SỨC KHỎE',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 20, bottom: 15, left: 20),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                            '3.1: Thị lực',
                                                            style:
                                                                fontSize16W800)),
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                          '${widget.order!.eyeSight}',
                                                          style:
                                                              fontSize16W400),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 10, bottom: 15, left: 30),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                        child: Text(
                                                            'Đối với TTS đeo kính: ',
                                                            style:
                                                                fontSize16W400)),
                                                    Expanded(
                                                        child: Text(
                                                            '${widget.order!.eyeSightGlasses}',
                                                            style:
                                                                fontSize16W400)),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    EdgeInsets.only(top: 10),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                        child: Text(
                                                            'Đối với TTS cam kết mổ mắt: ',
                                                            style:
                                                                fontSize16W400)),
                                                    Expanded(
                                                        child: Text(
                                                            '${widget.order!.eyeSightSurgery}',
                                                            style:
                                                                fontSize16W400)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 20, bottom: 15, left: 20),
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                            '3.2: Thể lực',
                                                            style:
                                                                fontSize16W800)),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Row(
                                                        children: [
                                                          Text('Chiều cao',
                                                              style:
                                                                  fontSize16W400),
                                                          SizedBox(width: 5),
                                                          Text(
                                                              ' ${widget.order!.heigth} cm',
                                                              style:
                                                                  fontSize16W400),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Row(
                                                        children: [
                                                          Text('Cân nặng',
                                                              style:
                                                                  fontSize16W400),
                                                          SizedBox(width: 5),
                                                          Text(
                                                              '> ${widget.order!.weight} kg',
                                                              style:
                                                                  fontSize16W400),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 20, bottom: 15, left: 20),
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                            '3.3: Tay thuận',
                                                            style:
                                                                fontSize16W800)),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Row(
                                                        children: [
                                                          Checkbox(
                                                            checkColor: Colors
                                                                .greenAccent,
                                                            activeColor:
                                                                Colors.red,
                                                            value: this.idLeft,
                                                            onChanged: null,
                                                          ),
                                                          SizedBox(width: 10),
                                                          Text('Tay trái',
                                                              style:
                                                                  fontSize16W400),
                                                        ],
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 2,
                                                      child: Row(
                                                        children: [
                                                          Checkbox(
                                                            checkColor: Colors
                                                                .greenAccent,
                                                            activeColor:
                                                                Colors.red,
                                                            value: this.idRight,
                                                            onChanged: null,
                                                          ),
                                                          SizedBox(width: 10),
                                                          Text('Tay phải',
                                                              style:
                                                                  fontSize16W400),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        //Start Tình trạng hôn nhân
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 20, bottom: 15, left: 20),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 2,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                          '3.4: Tình trạng hôn nhân',
                                                          style: titleBox),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                  flex: 2,
                                                  child: Row(
                                                    children: [
                                                      Checkbox(
                                                        checkColor:
                                                            Colors.greenAccent,
                                                        activeColor: Colors.red,
                                                        value: _isChuaKetHon,
                                                        onChanged: null,
                                                      ),
                                                      SizedBox(width: 10),
                                                      Text("Chưa kết hôn",
                                                          style:
                                                              fontSize16W400),
                                                    ],
                                                  )),
                                              Expanded(
                                                  flex: 2,
                                                  child: Row(
                                                    children: [
                                                      Checkbox(
                                                        checkColor:
                                                            Colors.greenAccent,
                                                        activeColor: Colors.red,
                                                        value: _isDaKetHon,
                                                        onChanged: null,
                                                      ),
                                                      SizedBox(width: 10),
                                                      Text("Đã kết hôn",
                                                          style:
                                                              fontSize16W400),
                                                    ],
                                                  )),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 20, bottom: 15, left: 20),
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                          '3.5: Yêu cầu khác',
                                                          style: titleBox),
                                                    ),
                                                    Expanded(
                                                        flex: 3,
                                                        child: Text('Nhận form',
                                                            style:
                                                                titleWidgetBox)),
                                                    Expanded(
                                                      flex: 3,
                                                      child: Text(
                                                          'Không nhận form',
                                                          style:
                                                              titleWidgetBox),
                                                    ),
                                                    Expanded(
                                                        flex: 1,
                                                        child: Container()),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 10, bottom: 15, left: 30),
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 2,
                                                        child: Text('Hút thuốc',
                                                            style: TextStyle(
                                                                fontSize: 16))),
                                                    Expanded(
                                                      flex: 2,
                                                      child: RadioGroup<
                                                          Map<int,
                                                              String>>.builder(
                                                        direction:
                                                            Axis.horizontal,
                                                        groupValue: _isSmoke,
                                                        onChanged: null,
                                                        items: _statusSmoke,
                                                        itemBuilder: (item) =>
                                                            RadioButtonBuilder(
                                                          item.values.first,
                                                          textPosition:
                                                              RadioButtonTextPosition
                                                                  .left,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Container()),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 10, bottom: 15, left: 30),
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 2,
                                                        child: Text('Uống rượu',
                                                            style: TextStyle(
                                                                fontSize: 16))),
                                                    Expanded(
                                                      flex: 2,
                                                      child: RadioGroup<
                                                          Map<int,
                                                              String>>.builder(
                                                        direction:
                                                            Axis.horizontal,
                                                        groupValue:
                                                            _isUongThuoc,
                                                        onChanged: null,
                                                        items: _statusUongThuoc,
                                                        itemBuilder: (item) =>
                                                            RadioButtonBuilder(
                                                          item.values.first,
                                                          textPosition:
                                                              RadioButtonTextPosition
                                                                  .left,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Container()),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 10, bottom: 15, left: 30),
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                            'Có hình xăm',
                                                            style: TextStyle(
                                                                fontSize: 16))),
                                                    Expanded(
                                                      flex: 2,
                                                      child: RadioGroup<
                                                          Map<int,
                                                              String>>.builder(
                                                        direction:
                                                            Axis.horizontal,
                                                        groupValue:
                                                            _isGotATattoo,
                                                        onChanged: null,
                                                        items:
                                                            _statusGotATattoo,
                                                        itemBuilder: (item) =>
                                                            RadioButtonBuilder(
                                                          item.values.first,
                                                          textPosition:
                                                              RadioButtonTextPosition
                                                                  .left,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Container()),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 10, bottom: 15, left: 30),
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                            'Đã từng phẫu thuật',
                                                            style: TextStyle(
                                                                fontSize: 16))),
                                                    Expanded(
                                                      flex: 2,
                                                      child: RadioGroup<
                                                          Map<int,
                                                              String>>.builder(
                                                        direction:
                                                            Axis.horizontal,
                                                        groupValue:
                                                            _isEverHadSurgery,
                                                        onChanged: null,
                                                        items:
                                                            _statusEverHadSurgery,
                                                        itemBuilder: (item) =>
                                                            RadioButtonBuilder(
                                                          item.values.first,
                                                          textPosition:
                                                              RadioButtonTextPosition
                                                                  .left,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Container()),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 10, bottom: 15, left: 30),
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                            'Đẫ từng mổ đẻ(Form nữ)',
                                                            style: TextStyle(
                                                                fontSize: 16))),
                                                    Expanded(
                                                      flex: 2,
                                                      child: RadioGroup<
                                                          Map<int,
                                                              String>>.builder(
                                                        direction:
                                                            Axis.horizontal,
                                                        groupValue:
                                                            _isEverHadACaesareanSection,
                                                        onChanged: null,
                                                        items:
                                                            _statusEverHadACaesareanSection,
                                                        itemBuilder: (item) =>
                                                            RadioButtonBuilder(
                                                          item.values.first,
                                                          textPosition:
                                                              RadioButtonTextPosition
                                                                  .left,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Container()),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              top: 10, bottom: 15, left: 30),
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                        flex: 2,
                                                        child: Text(
                                                            'Khác: ${widget.order!.otherHealthRequired}',
                                                            style: TextStyle(
                                                                fontSize: 16))),
                                                    Expanded(
                                                      flex: 2,
                                                      child: RadioGroup<
                                                          Map<int,
                                                              String>>.builder(
                                                        direction:
                                                            Axis.horizontal,
                                                        groupValue:
                                                            _isOtherRequirements,
                                                        onChanged: null,
                                                        items:
                                                            _statusOtherRequirements,
                                                        itemBuilder: (item) =>
                                                            RadioButtonBuilder(
                                                          item.values.first,
                                                          textPosition:
                                                              RadioButtonTextPosition
                                                                  .left,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                        flex: 2,
                                                        child: Container()),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            flex: 5,
                            child: Container(
                              // padding: paddingBoxContainer,
                              margin: marginTopBoxContainer,
                              height: 850,
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
                                  Container(
                                    padding: EdgeInsets.fromLTRB(10, 15, 0, 15),
                                    width:
                                        MediaQuery.of(context).size.width * 1,
                                    color: Color(0xfffcdcb2),
                                    child: Text(
                                      'IV. YÊU CẦU ĐẶC BIỆT',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 750,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 20, bottom: 15, left: 20),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text('Các trường hợp ưu tiên:',
                                                    style: fontSize16W800),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 20, bottom: 15, left: 30),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                          flex: 4,
                                                          child: Text(
                                                              '${widget.order!.priorityCases.toString()}',
                                                              style:
                                                                  fontSize16W400)),
                                                      Expanded(
                                                          flex: 2,
                                                          child: Container()),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 50, bottom: 15, left: 20),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    'Chú ý trường hợp không/Hạn chế tiếp nhận:',
                                                    style: fontSize16W800),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 20, bottom: 15, left: 30),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                          flex: 5,
                                                          child: Text(
                                                              '${widget.order!.restrictionCases.toString()}',
                                                              style:
                                                                  fontSize16W400)),
                                                      Expanded(
                                                          flex: 2,
                                                          child: Container()),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: backgroundPage,
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Container(
                              // padding: paddingBoxContainer,
                              margin: marginTopBoxContainer,
                              height: 400,
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
                                  Container(
                                    padding: EdgeInsets.fromLTRB(10, 15, 0, 15),
                                    width:
                                        MediaQuery.of(context).size.width * 1,
                                    color: Color(0xfffcdcb2),
                                    child: Text(
                                      'V. HÌNH THỨC VÀ NỘI DUNG THI TUYỂN',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 300,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 20, bottom: 15, left: 20),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                          flex: 4,
                                                          child: Text(
                                                              '5.1: Hình thức thi tuyển',
                                                              style:
                                                                  fontSize16W800)),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Text(
                                                            widget.order!
                                                                        .recruiMethod ==
                                                                    1
                                                                ? "Thi tuyển online"
                                                                : "Thi tuyển trực tiếp",
                                                            style:
                                                                fontSize16W400),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 20, bottom: 15, left: 20),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.only(
                                                    top: 20,
                                                    bottom: 15,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                          flex: 4,
                                                          child: Text(
                                                              '5.2: Nội dung thi tuyển cần chuẩn bị :',
                                                              style:
                                                                  fontSize16W800)),
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                    widget.order!.recruiContent
                                                        .toString(),
                                                    style: fontSize16W400),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            flex: 5,
                            child: Container(
                              // padding: paddingBoxContainer,
                              margin: marginTopBoxContainer,
                              height: 400,
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
                                  Container(
                                    padding: EdgeInsets.fromLTRB(10, 15, 0, 15),
                                    width:
                                        MediaQuery.of(context).size.width * 1,
                                    color: Color(0xfffcdcb2),
                                    child: Text(
                                      'VI. LỊCH THI TUYỂN',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 300,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 20, bottom: 15, left: 20),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                              '6.1: Số form cần test',
                                                              style:
                                                                  fontSize16W800)),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 20),
                                                            child: Text(
                                                                widget.order!
                                                                    .testFormNumber
                                                                    .toString(),
                                                                style:
                                                                    fontSize16W400)),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 20, bottom: 15, left: 20),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                              '6.2: Ngày gửi list và form cho đối tác',
                                                              style:
                                                                  fontSize16W800)),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 20),
                                                          child: Text(
                                                              getDateView(widget
                                                                  .order!
                                                                  .sendListFormDate),
                                                              style:
                                                                  fontSize16W400),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 20, bottom: 15, left: 20),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                              '6.3: Ngày thi tuyển',
                                                              style:
                                                                  fontSize16W800)),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 20),
                                                          child: Text(
                                                              getDateView(widget
                                                                  .order!
                                                                  .estimatedInterviewDate),
                                                              style:
                                                                  fontSize16W400),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 20, bottom: 15, left: 20),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                              '6.4: Ngày nhập học',
                                                              style:
                                                                  fontSize16W800)),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 20),
                                                          child: Text(
                                                              getDateView(widget
                                                                  .order!
                                                                  .estimatedAdmissionDate),
                                                              style:
                                                                  fontSize16W400),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 20, bottom: 15, left: 20),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                              '6.5: Lịch nhập cảnh dự kiến',
                                                              style:
                                                                  fontSize16W800)),
                                                      Expanded(
                                                        flex: 5,
                                                        child: Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 20),
                                                          child: Text(
                                                              getDateView(widget
                                                                  .order!
                                                                  .estimatedEntryDate),
                                                              style:
                                                                  fontSize16W400),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: backgroundPage,
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Container(
                              // padding: paddingBoxContainer,
                              margin: marginTopBoxContainer,
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
                                  Container(
                                    padding: EdgeInsets.fromLTRB(10, 15, 0, 15),
                                    width:
                                        MediaQuery.of(context).size.width * 1,
                                    color: Color(0xfffcdcb2),
                                    child: Text(
                                      'VII. QUYỀN LỢI VÀ MỨC LƯƠNG THỰC TẬP SINH',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 500,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 20, bottom: 15, left: 20),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                          flex: 5,
                                                          child: Text(
                                                              '7.1: Trợ cấp tháng đầu: ',
                                                              style:
                                                                  fontSize16W800)),
                                                      Expanded(
                                                        flex: 7,
                                                        child: Text(
                                                            widget.order!
                                                                .firstMonthSubsidy
                                                                .toString(),
                                                            style:
                                                                fontSize16W400),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 20, bottom: 15, left: 20),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                          flex: 5,
                                                          child: Text(
                                                              '7.2: Lương cơ bản',
                                                              style:
                                                                  fontSize16W800)),
                                                      Expanded(
                                                        flex: 7,
                                                        child: Text(
                                                            widget.order!.salary
                                                                .toString(),
                                                            style:
                                                                fontSize16W400),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 20, bottom: 15, left: 20),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 5,
                                                        child: Text(
                                                            '7.3: Các loại bảo hiểm :',
                                                            style:
                                                                fontSize16W800),
                                                      ),
                                                      Expanded(
                                                        flex: 7,
                                                        child: Text(
                                                            widget.order!
                                                                .insurance
                                                                .toString(),
                                                            style:
                                                                fontSize16W400),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 20, bottom: 15, left: 20),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 5,
                                                        child: Text(
                                                            '7.4: Tiền điện, nước, wifi',
                                                            style:
                                                                fontSize16W800),
                                                      ),
                                                      Expanded(
                                                        flex: 7,
                                                        child: Text(
                                                            widget.order!
                                                                .livingCost
                                                                .toString(),
                                                            style:
                                                                fontSize16W400),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 20, bottom: 15, left: 20),
                                            child: Row(
                                              children: [
                                                Flexible(
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                          flex: 5,
                                                          child: Text(
                                                              '7.5: Thực lĩnh',
                                                              style:
                                                                  fontSize16W800)),
                                                      Expanded(
                                                        flex: 7,
                                                        child: Text(
                                                            widget
                                                                .order!.netMoney
                                                                .toString(),
                                                            style:
                                                                fontSize16W400),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            flex: 5,
                            child: Container(
                              // padding: paddingBoxContainer,
                              margin: marginTopBoxContainer,
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
                                  Container(
                                    padding: EdgeInsets.fromLTRB(10, 15, 0, 15),
                                    width:
                                        MediaQuery.of(context).size.width * 1,
                                    color: Color(0xfffcdcb2),
                                    child: Text(
                                      'VIII. CHỈ HIỂN THỊ NỘI BỘ',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 500,
                                    child: SingleChildScrollView(
                                      child: Column(
                                        children: [
                                          Container(
                                            margin: EdgeInsets.only(top: 20),
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 30,
                                                ),
                                                Expanded(
                                                  flex: 8,
                                                  child: Text(
                                                    "8.1.Hình ảnh",
                                                    style: fontSize16W800,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 30,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 20),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: getImage(
                                                      id: widget.order!.id,
                                                      fileName:
                                                          widget.order!.image),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.only(top: 20),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: getImage(
                                                      id: widget.order!.id,
                                                      fileName:
                                                          widget.order!.image2),
                                                ),
                                                Expanded(
                                                  flex: 1,
                                                  child: Container(),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 20, bottom: 15, left: 20),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.only(
                                                    top: 20,
                                                    bottom: 15,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                          flex: 4,
                                                          child: Text(
                                                              '8.2: Nội dung thi tuyển cần chuẩn bị :',
                                                              style:
                                                                  fontSize16W800)),
                                                    ],
                                                  ),
                                                ),
                                                Text(
                                                    widget.order!.description
                                                        .toString(),
                                                    style: fontSize16W400),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ],
    );
  }
}
