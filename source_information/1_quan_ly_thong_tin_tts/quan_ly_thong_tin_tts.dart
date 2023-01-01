// ignore_for_file: must_be_immutable

import 'dart:convert';
import 'dart:html';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/format_date.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../config.dart';
import '../../../../model/market_development/status_tts.dart';
import '../../../../model/model.dart';
import '../../../../common/style.dart';
import '../common_ource_information/common_source_information.dart';
import '../common_ource_information/constant.dart';
import '../common_ource_information/stopprocessing_tts.dart';
import '../setting-data/tts.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:js' as js;

class QuanLyThongTinThucTapSinh extends StatelessWidget {
  final String? statusTTS;
  var userlogin;
  QuanLyThongTinThucTapSinh({Key? key, this.statusTTS, this.userlogin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: QuanlyThongTinTTSBody(
      statusTTS: statusTTS,
      userlogin: userlogin,
    ));
  }
}

class QuanlyThongTinTTSBody extends StatefulWidget {
  String? statusTTS;
  var userlogin;
  QuanlyThongTinTTSBody({Key? key, this.statusTTS, this.userlogin}) : super(key: key);

  @override
  State<QuanlyThongTinTTSBody> createState() => _QuanlyThongTinTTSBodyState();
}

class _QuanlyThongTinTTSBodyState extends State<QuanlyThongTinTTSBody> {
  final String add = '/them-moi-cap-nhat-thuc-tap-sinh';

  // List<dynamic> idSelectedList = [];
  List<InformationTTS> listObjectTTS = [];
  var totalElements = 0;
  var rowPerPage = 10;
  int currentPageDef = 1;

  var rowCount = 0;
  var lastRow = 0;

  //Tìm kiếm thực tập sinh
  var searchRequest = "isTts:1";

  //Lọc nhang những thằng thiếu hồ sơ
  bool iCheckProfile = false;

  bool isCheckCareUser = false;
  bool checkCareUserTemp = false;
  //Lựa chọn những TTS để dừng xử lý tạm thời
  String selectedValueTTS = '';

  //Lấy dữ liệu từ ô nhập tên TTS để tìm kiếm
  TextEditingController fullNameController = TextEditingController();

  //Lấy dữ liệu trạng thái thực tập sinh
  Future<List<StatusTTS>> getTTSStatus() async {
    List<StatusTTS> resultTTS = [];

    var response1 = await httpGet(TTS_TRANG_THAI + "filter=active:1", context);
    var body = jsonDecode(response1['body']);
    var content = [];
    if (response1.containsKey("body")) {
      setState(() {
        content = body['content'];
        resultTTS = content.map((e) {
          return StatusTTS.fromJson(e);
        }).toList();
      });
    }
    StatusTTS all = new StatusTTS(id: -1, statusName: "Tất cả", active: null);
    resultTTS.insert(0, all);
    return resultTTS;
  }

  //update trạng thái thực tập sinh
  updateStatus(InformationTTS objectTTS, status) async {
    objectTTS.ttsStatusId = status;
    var response = await httpPut("/api/nguoidung/put/${objectTTS.id}", objectTTS, context);
    Map datattS = jsonDecode(response['body']);

    if (datattS.containsKey("0")) {
      titleLog = "Xác nhận không thành công";
      showToast(
        context: context,
        msg: titleLog,
        color: Colors.red,
        icon: Icon(Icons.warning),
      );
    }

    if (datattS.containsKey("1")) {
      titleLog = "Xác nhận tư vấn thành công";
      showToast(
        context: context,
        msg: titleLog,
        color: Color.fromARGB(136, 72, 238, 67),
        icon: Icon(Icons.done),
      );
    }
  }

  var viewTTS;

  bool isLoading = false;
  functionIsClickXacNhan(bool value) {
    setState(() {
      isLoading = value;
    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        futureListTTS = pageChange(1);
        isLoading = false;
      });
    });
  }

  //Ngày tìm kiếm
  String? dateFrom;
  String? dateTo;

  //Danh sách thực tập sinh
  late Future<List<InformationTTS>> futureListTTS;

  //Gọi api danh sách thực tập sinh
  List<InformationTTS> listTTS = [];
  List<bool> _selectedDataRow = [];

  //Check null các trường và quyền có thể call api
  bool checkManager() {
    if (widget.userlogin['departId'] != null && ((widget.userlogin['teamId'] != null) || (widget.userlogin['departId'] == 3)) ||
        widget.userlogin['departId'] == 30 ||
        (widget.userlogin['departId'] == 1 || widget.userlogin['departId'] == 2)) {
      return true;
    }
    return false;
  }

  //ToolTip thay đổi theo trạng thái thực tập sinh
  var errorEditTTS = '';

  String dangQuanTam = "ttsStatusId:1 and stopProcessing:0";

  //Call api thực tập sinh
  Future<List<InformationTTS>> pageChange(currentPage) async {
    var content = [];
    String queryRequest = '';
    String thieuHoSo = "";
    //Trạng thái đang quan tâm khi người dung click phần dashboard
    if (widget.statusTTS != null && widget.statusTTS == '1') {
      selectedValueTTS = "1";
    } else {
      queryRequest = "isTts:1";
    }
    //Thiếu hồ sơ
    if (iCheckProfile == true) {
      thieuHoSo = 'and profileDocumentsCompleted:false';
    } else {
      thieuHoSo = '';
    }
    //Tìm kiếm từ ngày đến ngày
    if (queryRequest != '' && dateFrom != null && dateTo != null) {
      queryRequest += "and createdDate >: '$dateFrom' and createdDate <: '$dateTo'";
    } else if (queryRequest != '' && dateFrom != null && dateTo == null) {
      queryRequest += "and createdDate >:'$dateFrom'";
    } else if (queryRequest != "" && dateFrom == null && dateTo != null) {
      queryRequest += "and createdDate <: '$dateTo'";
    } else if (queryRequest == "" && dateFrom != null && dateTo != null) {
      queryRequest += "createdDate >:'$dateFrom' and createdDate <:'$dateTo'";
    } else if (queryRequest == "" && dateFrom == null && dateTo != null) {
      queryRequest += "createdDate <:'$dateTo'";
    } else if (queryRequest == "" && dateFrom != null && dateTo == null) {
      queryRequest += "createdDate >: '$dateFrom'";
    }
    //Tìm kiếm theo tên và mà thực tập sinh
    if (fullNameController.text != "" && queryRequest != "") {
      queryRequest += "and (fullName~'*${fullNameController.text}*' or userCode~'*${fullNameController.text}*')";
    } else if (fullNameController.text != "" && queryRequest == "") {
      queryRequest += "(name~'*${fullNameController.text}*' or userCode~'*${fullNameController.text}*')";
    }
    //Tìm kiếm theo trạng thái thực tập sinh
    if (queryRequest != "" && selectedValueTTS != '') {
      queryRequest += " and ttsStatusId:$selectedValueTTS and stopProcessing:0";
    } else if (queryRequest == "" && selectedValueTTS != '') {
      queryRequest += "ttsStatusId:$selectedValueTTS and stopProcessing:0";
    }

    var phanQuyenXem = '';
    if (widget.userlogin['departId'] == 1 || widget.userlogin['departId'] == 2) {
      phanQuyenXem = "";
    } else {
      if (widget.userlogin['vaitro']['level'] == 2) {
        if (widget.userlogin['departId'] != 3)
          phanQuyenXem = "and nhanvientuyendung.departId:${widget.userlogin['departId']} and not(careUser is null)";
        else
          phanQuyenXem = "and (nhanvientuyendung.departId:${widget.userlogin['departId']} or careUser is null) ";
      }
      if (widget.userlogin['vaitro']['level'] == 1 && widget.userlogin['teamId'] != null) {
        phanQuyenXem = "and nhanvientuyendung.teamId:${widget.userlogin['teamId']}";
      }
      if (widget.userlogin['vaitro']['level'] == 0) {
        phanQuyenXem = "and careUser:${widget.userlogin['id']}";
      }
    }
    //Check những thằng nào thiếu nhân viên quản lí
    if (isCheckCareUser) {
      phanQuyenXem = 'and careUser is null';
    }
    if (checkCareUserTemp) {
      phanQuyenXem = 'and not(careUserTemp is null)';
    }

    //Call api
    var response;
    response = await httpGet(
        API_NGUOI_DUNG +
            "sort=ttsTrangthai.weight,desc&sort=createdDate,desc&size=$rowPerPage&page=${currentPage - 1}&filter=$queryRequest $phanQuyenXem $thieuHoSo and isTts:1 and active:1 ",
        context);

    var body = jsonDecode(response['body']);

    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
        rowCount = body['totalElements'];
        listTTS = content.map((e) {
          return InformationTTS.fromJson(e);
        }).toList();
        _selectedDataRow = List<bool>.generate(rowCount, (int index) => false);
      });
      listObjectTTS.clear();
    }
    return content.map((e) {
      return InformationTTS.fromJson(e);
    }).toList();
  }

  late String titleLog;
  @override
  void initState() {
    super.initState();
    futureListTTS = pageChange(1);
  }

  bool checkTime = true;

  //Check hiển thị theo quyền nhân viên
  bool checkStaffAAM() {
    if ((widget.userlogin['departId'] == 30 || widget.userlogin['departId'] == 31 || widget.userlogin['departId'] == 3) &&
        widget.userlogin['teamId'] != null &&
        widget.userlogin['vaitro'] != null) {
      return true;
    }
    return false;
  }

  //Những trạng thái được chỉnh sửa thông tin thực tập sinh
  bool checkStatusTTSEdit(InformationTTS tts) {
    if ((tts.ttsStatusId != 12) && (tts.stopProcessing == 0 && tts.ttsStatusId != 13)) {
      return true;
    }
    return false;
  }

  //Trạng thái thực tập sinh đang quan tâm thì không hiện qr code
  bool checkStatusNotDisplayed(InformationTTS tts) {
    if (tts.ttsStatusId != null && tts.ttsStatusId! < 3) {
      return true;
    }
    return false;
  }

  //Thực tập sinh được đề xuất tiến cử
  bool checkTTSNomination(InformationTTS tts) {
    if ((tts.stopProcessing == 0 && tts.ttsStatusId != 13) && (tts.ttsStatusId == 3 || tts.ttsStatusId == 14 || tts.ttsStatusId == 4)) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule(QUAN_LY_THONG_TIN_TTS, context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Consumer2<NavigationModel, SecurityModel>(
            builder: (context, navigationModel, user, child) => ListView(
              controller: ScrollController(),
              children: [
                TitlePage(
                  listPreTitle: [
                    {'url': THONG_TIN_NGUON, 'title': 'Dashboard'},
                  ],
                  content: "Quản lý thông tin thực tập sinh",
                  widgetBoxRight: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      (widget.statusTTS == '1')
                          ? TextButton.icon(
                              icon: Icon(Icons.arrow_back_ios, size: 14, color: Colors.white),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 15.0,
                                  horizontal: 15.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                backgroundColor: colorOrange,
                                primary: Theme.of(context).iconTheme.color,
                                textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              label: Text('Trở về', style: textButton),
                            )
                          : Container(),
                    ],
                  ),
                ),
                Container(
                  color: backgroundPage,
                  padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 1,
                        decoration: BoxDecoration(
                          color: colorWhite,
                          borderRadius: borderRadiusContainer,
                          boxShadow: [boxShadowContainer],
                          border: borderAllContainerBox,
                        ),
                        padding: paddingBoxContainer,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Nhập thông tin tìm kiếm',
                                  style: titleBox,
                                ),
                                Icon(
                                  Icons.more_horiz,
                                  color: Color(0xff9aa5ce),
                                  size: 14,
                                ),
                              ],
                            ),
                            //Đường line
                            Container(
                              margin: marginTopBottomHorizontalLine,
                              child: Divider(
                                thickness: 1,
                                color: ColorHorizontalLine,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextFieldValidated(
                                  label: 'TTS',
                                  type: 'none',
                                  height: 40,
                                  hint: "Tên hoặc mã TTS",
                                  controller: fullNameController,
                                  enter: () {
                                    futureListTTS = pageChange(1);
                                  },
                                ),
                                SizedBox(width: 50),
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Expanded(flex: 2, child: Text('Trạng thái TTS', style: titleWidgetBox)),
                                        Expanded(
                                          flex: 5,
                                          child: Container(
                                            color: Colors.white,
                                            width: MediaQuery.of(context).size.width * 0.20,
                                            height: 40,
                                            child: DropdownSearch<StatusTTS>(
                                              // ignore: deprecated_member_use
                                              hint: "Tất cả",
                                              mode: Mode.MENU,
                                              maxHeight: 350,
                                              showSearchBox: true,
                                              onFind: (String? filter) => getTTSStatus(),
                                              itemAsString: (StatusTTS? u) => u!.statusName.toString(),
                                              dropdownSearchDecoration: styleDropDown,
                                              onChanged: (value) {
                                                setState(() {
                                                  // dangQuanTam = "";
                                                  // ignore: unnecessary_statements
                                                  widget.statusTTS = '';
                                                  selectedValueTTS = (value!.id.toString() == "-1") ? "" : value.id.toString();
                                                  print(selectedValueTTS);
                                                  // if (selectedBP != -1) getDNTDChiTiet(selectedBP);
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(flex: 2, child: Container()),
                              ],
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: DatePickerBoxVQ(
                                      requestDayBefore: dateTo,
                                      isTime: false,
                                      label: Text(
                                        'Từ ngày',
                                        style: titleWidgetBox,
                                      ),
                                      dateDisplay: dateFrom,
                                      selectedDateFunction: (day) {
                                        dateFrom = day;
                                        setState(() {});
                                      }),
                                ),
                                SizedBox(width: 50),
                                Expanded(
                                  flex: 3,
                                  child: DatePickerBoxVQ(
                                      requestDayAfter: dateFrom,
                                      isTime: false,
                                      label: Text(
                                        'Đến ngày',
                                        style: titleWidgetBox,
                                      ),
                                      dateDisplay: dateFrom,
                                      selectedDateFunction: (day) {
                                        dateTo = day;
                                        setState(() {});
                                      }),
                                ),
                                Expanded(flex: 2, child: Container()),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 30, 0, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      user.userLoginCurren['departId'] == 1 ||
                                              user.userLoginCurren['departId'] == 2 ||
                                              (user.userLoginCurren['departId'] == 3 &&
                                                  user.userLoginCurren['vaitro'] != null &&
                                                  user.userLoginCurren['vaitro']['level'] == 2)
                                          ? Container(
                                              // margin: EdgeInsets.only(left: 20),
                                              child: CheckBoxWidget(
                                                  isChecked: checkCareUserTemp,
                                                  functionCheckBox: (bool value) {
                                                    setState(() {
                                                      checkCareUserTemp = value;
                                                      futureListTTS = pageChange(1);
                                                    });
                                                  },
                                                  widgetTitle: [
                                                    Text('TTS cần duyệt người xử lý'),
                                                  ]),
                                            )
                                          : Container(),
                                      user.userLoginCurren['departId'] == 1 ||
                                              user.userLoginCurren['departId'] == 2 ||
                                              (user.userLoginCurren['departId'] == 3 &&
                                                  user.userLoginCurren['vaitro'] != null &&
                                                  user.userLoginCurren['vaitro']['level'] == 2)
                                          ? Container(
                                              margin: EdgeInsets.only(left: 10),
                                              child: CheckBoxWidget(
                                                  isChecked: isCheckCareUser,
                                                  functionCheckBox: (bool value) {
                                                    setState(() {
                                                      isCheckCareUser = value;
                                                      print(isCheckCareUser);
                                                      futureListTTS = pageChange(1);
                                                    });
                                                  },
                                                  widgetTitle: [
                                                    Text('TTS cần người xử lý'),
                                                  ]),
                                            )
                                          : Container(),
                                      Container(
                                        margin: EdgeInsets.only(left: 10),
                                        child: CheckBoxWidget(
                                            isChecked: iCheckProfile,
                                            functionCheckBox: (bool value) {
                                              setState(() {
                                                iCheckProfile = value;

                                                futureListTTS = pageChange(1);
                                              });
                                            },
                                            widgetTitle: [
                                              Text('TTS thiếu hồ sơ'),
                                            ]),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        child: TextButton(
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 20.0,
                                              horizontal: 10.0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                            ),
                                            backgroundColor: listObjectTTS.isNotEmpty ? Color.fromRGBO(245, 117, 29, 1) : Colors.grey,
                                            primary: Theme.of(context).iconTheme.color,
                                            textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                                          ),
                                          //----------Show dialong dừng xử lý-----------
                                          onPressed: listObjectTTS.isNotEmpty
                                              ? () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) => StopprocessingTTS(
                                                      titleDialog: 'Tạm dừng xử lý',
                                                      donhangId: null,
                                                      doituong: 0,
                                                      func: functionIsClickXacNhan,
                                                      // listId: idSelectedList,
                                                      ttsId: null,
                                                      hienDanhSach: 1,
                                                      widgetRight: 1,
                                                      informationTTS: listObjectTTS,
                                                    ),
                                                  );
                                                }
                                              : null,
                                          child: Text('Tạm dừng xử lý', style: textButton),
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(left: 20),
                                        child: TextButton.icon(
                                          icon: Icon(
                                            Icons.search,
                                            color: Colors.white,
                                            size: 15,
                                          ),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 20.0,
                                              horizontal: 10.0,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(5.0),
                                            ),
                                            backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                            primary: Theme.of(context).iconTheme.color,
                                            textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                          ),
                                          onPressed: () {
                                            futureListTTS = pageChange(0);
                                          },
                                          label: Row(
                                            children: [
                                              Text('Tìm kiếm', style: textButton),
                                            ],
                                          ),
                                        ),
                                      ),
                                      (getRule(listRule.data, Role.Them, context))
                                          ? Container(
                                              margin: EdgeInsets.only(left: 20),
                                              child: TextButton.icon(
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(
                                                    vertical: 20.0,
                                                    horizontal: 10.0,
                                                  ),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(5.0),
                                                  ),
                                                  backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                                  primary: Theme.of(context).iconTheme.color,
                                                  textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                                                ),
                                                onPressed: () {
                                                  navigationModel.add(pageUrl: THEM_MOI_CAP_NHAT_TTS);
                                                  // print(user.userLoginCurren['id']);
                                                },
                                                icon: Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                                label: Row(
                                                  children: [
                                                    Text('Thêm mới', style: textButton),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder<List<InformationTTS>>(
                        future: futureListTTS,
                        builder: (context, snapshot) {
                          var tableIndex = (currentPageDef - 1) * rowPerPage + 1;

                          if (snapshot.hasData) {
                            return Container(
                              margin: marginTopBoxContainer,
                              decoration: BoxDecoration(
                                color: colorWhite,
                                borderRadius: borderRadiusContainer,
                                boxShadow: [boxShadowContainer],
                                border: borderAllContainerBox,
                              ),
                              padding: paddingBoxContainer,
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Danh sách thực tập sinh',
                                        style: titleBox,
                                      ),
                                      Text(
                                        'Kết quả tìm kiếm: $rowCount',
                                        style: titleBox,
                                      ),
                                    ],
                                  ),
                                  //Đường line
                                  Container(
                                    margin: marginTopBottomHorizontalLine,
                                    child: Divider(
                                      thickness: 1,
                                      color: ColorHorizontalLine,
                                    ),
                                  ),
                                  Container(
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: DataTable(
                                                columnSpacing: 3,
                                                dataTextStyle: const TextStyle(color: Color(0xff313131), fontSize: 14, fontWeight: FontWeight.w500),
                                                showBottomBorder: true,
                                                dataRowHeight: 60,
                                                showCheckboxColumn: true,
                                                dataRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                                                  if (states.contains(MaterialState.selected)) {
                                                    return MaterialStateColor.resolveWith((states) => const Color(0xffeef3ff));
                                                  }
                                                  return MaterialStateColor.resolveWith((states) => Colors.white); // Use the default value.
                                                }),
                                                // showCheckboxColumn: true,
                                                // columnSpacing: 20,
                                                horizontalMargin: 10,
                                                // dataRowHeight: 60,
                                                columns: [
                                                  DataColumn(label: Text('STT', style: titleTableData)),
                                                  DataColumn(
                                                      label: Container(
                                                          width: MediaQuery.of(context).size.width * 0.05,
                                                          child: Text(
                                                            'Mã TTS',
                                                            style: titleTableData,
                                                            maxLines: 2,
                                                            softWrap: true,
                                                            // overflow: TextOverflow.ellipsis,
                                                          ))),
                                                  DataColumn(
                                                      label: Container(
                                                          width: MediaQuery.of(context).size.width * 0.03,
                                                          child: Text(
                                                            'Họ tên',
                                                            style: titleTableData,
                                                            maxLines: 2,
                                                            softWrap: true,
                                                            // overflow: TextOverflow.ellipsis,
                                                          ))),
                                                  DataColumn(
                                                      label: Container(
                                                          width: MediaQuery.of(context).size.width * 0.03,
                                                          child: Text(
                                                            'Giới tính',
                                                            style: titleTableData,
                                                            maxLines: 2,
                                                            softWrap: true,
                                                            // overflow: TextOverflow.ellipsis,
                                                          ))),
                                                  // DataColumn(
                                                  //     label: Container(
                                                  //         width: MediaQuery.of(context).size.width * 0.03,
                                                  //         child: Text(
                                                  //           'Năm sinh',
                                                  //           style: titleTableData,
                                                  //           maxLines: 2,
                                                  //           softWrap: true,
                                                  //           // overflow: TextOverflow.ellipsis,
                                                  //         ))),
                                                  DataColumn(
                                                      label: Container(
                                                          width: MediaQuery.of(context).size.width * 0.09,
                                                          child: Text(
                                                            'Số điện thoại',
                                                            style: titleTableData,
                                                            maxLines: 2,
                                                            softWrap: true,
                                                            // overflow: TextOverflow.ellipsis,
                                                          ))),
                                                  DataColumn(
                                                      label: Container(
                                                          width: MediaQuery.of(context).size.width * 0.06,
                                                          child: Text(
                                                            'Trạng thái TTS',
                                                            style: titleTableData,
                                                            maxLines: 2,
                                                            softWrap: true,
                                                            // overflow: TextOverflow.ellipsis,
                                                          ))),
                                                  DataColumn(
                                                      label: Container(
                                                          width: MediaQuery.of(context).size.width * 0.06,
                                                          child: Text(
                                                            'Cán bộ tư vấn',
                                                            style: titleTableData,
                                                            maxLines: 2,
                                                            softWrap: true,
                                                            // overflow: TextOverflow.ellipsis,
                                                          ))),
                                                  DataColumn(
                                                      label: Container(
                                                          width: MediaQuery.of(context).size.width * 0.06,
                                                          child: Text(
                                                            'Ngày tạo',
                                                            style: titleTableData,
                                                            maxLines: 2,
                                                            softWrap: true,
                                                            // overflow: TextOverflow.ellipsis,
                                                          ))),
                                                  DataColumn(
                                                      label: Container(
                                                          width: MediaQuery.of(context).size.width * 0.09,
                                                          child: Text(
                                                            'Hành động',
                                                            style: titleTableData,
                                                            maxLines: 2,
                                                            softWrap: true,
                                                            // overflow: TextOverflow.ellipsis,
                                                          ))),
                                                ],
                                                rows: <DataRow>[
                                                  for (int i = 0; i < listTTS.length; i++)
                                                    DataRow(
                                                      cells: <DataCell>[
                                                        DataCell(SelectableText("${tableIndex++}")),
                                                        DataCell(
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.05,
                                                            child: SelectableText(listTTS[i].userCode ?? "", style: bangDuLieu),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          (listTTS[i].profileDocumentsCompleted! == false)
                                                              ? Tooltip(
                                                                  message: "TTS thiếu hồ sơ",
                                                                  child: Row(
                                                                    children: [
                                                                      Icon(
                                                                        Icons.warning_amber_rounded,
                                                                        color: Colors.red,
                                                                      ),
                                                                      Container(
                                                                          width: MediaQuery.of(context).size.width * 0.09,
                                                                          child: SelectableText(
                                                                              "${listTTS[i].fullName!} / ${listTTS[i].getYearTTS()}",
                                                                              style: bangDuLieu))
                                                                    ],
                                                                  ),
                                                                )
                                                              : Container(
                                                                  width: MediaQuery.of(context).size.width * 0.1,
                                                                  child: SelectableText(listTTS[i].fullName ?? "", style: bangDuLieu)),
                                                        ),
                                                        DataCell(
                                                          SelectableText(listTTS[i].getGender(), style: bangDuLieu),
                                                        ),
                                                        // DataCell(
                                                        //   SelectableText(listTTS[i].getYearTTS(), style: bangDuLieu),
                                                        // ),
                                                        DataCell(Center(
                                                            child: Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            SelectableText(listTTS[i].phone!, style: bangDuLieu),
                                                            Tooltip(
                                                              message: "Gọi điện",
                                                              child: InkWell(
                                                                  onTap: () async {
                                                                    js.context.callMethod('call', [listTTS[i].phone]);
                                                                  },
                                                                  child: Icon(
                                                                    Icons.phone_in_talk,
                                                                    color: Color.fromARGB(255, 52, 147, 224),
                                                                  )),
                                                            ),
                                                            SizedBox(
                                                              width: 20,
                                                            ),
                                                          ],
                                                        ))),
                                                        DataCell(null != listTTS[i].ttsStatusId
                                                            ? listTTS[i].ttsStatusId == 13
                                                                ? SelectableText(listTTS[i].ttsTrangthai!.statusName!,
                                                                    style: TextStyle(
                                                                      color: Colors.red,
                                                                      fontSize: 14,
                                                                      fontWeight: FontWeight.w400,
                                                                    ))
                                                                : (listTTS[i].stopProcessing == 1)
                                                                    ? SelectableText("Tạm dừng xử lý",
                                                                        style: TextStyle(
                                                                          color: colorOrange,
                                                                          fontSize: 14,
                                                                          fontWeight: FontWeight.w400,
                                                                        ))
                                                                    : SelectableText(listTTS[i].ttsTrangthai!.statusName!, style: bangDuLieu)
                                                            : SelectableText("Không có trạng thái", style: bangDuLieu)),
                                                        DataCell(
                                                          SelectableText(
                                                              (listTTS[i].careUser != null)
                                                                  ? "${listTTS[i].nhanvientuyendung!.fullName}/${listTTS[i].nhanvientuyendung!.userCode}"
                                                                  : "",
                                                              style: bangDuLieu),
                                                        ),
                                                        DataCell(
                                                          SelectableText(FormatDate.formatDateddMMyy(DateTime.parse(listTTS[i].createdDate!))),
                                                        ),
                                                        DataCell(
                                                          Container(
                                                            child: Row(
                                                              children: [
                                                                (getRule(listRule.data, Role.Xem, context))
                                                                    ? Consumer<NavigationModel>(
                                                                        builder: (context, navigationModel, child) => Container(
                                                                          margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                          child: Tooltip(
                                                                            message: TOOLIP_XEM_CHI_TIET,
                                                                            child: InkWell(
                                                                              onTap: () {
                                                                                viewTTS = listTTS[i].id.toString();
                                                                                navigationModel.add(
                                                                                  pageUrl: (VIEW_THONG_TIN_TTS + "/$viewTTS"),
                                                                                );
                                                                              },
                                                                              child: Icon(Icons.visibility),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : Container(),
                                                                (getRule(listRule.data, Role.Sua, context))
                                                                    ? Container(
                                                                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                        child: Tooltip(
                                                                            message: (checkStatusTTSEdit(listTTS[i]) == true)
                                                                                ? "Sửa thông tin"
                                                                                : "Không thể sửa thông tin thực tập sinh",
                                                                            child: InkWell(
                                                                                onTap: (checkStatusTTSEdit(listTTS[i]) == true)
                                                                                    ? () {
                                                                                        Provider.of<NavigationModel>(context, listen: false).add(
                                                                                            pageUrl: THEM_MOI_CAP_NHAT_TTS + "/${listTTS[i].id}");
                                                                                      }
                                                                                    : null,
                                                                                child: Icon(
                                                                                  Icons.edit_calendar,
                                                                                  color: (checkStatusTTSEdit(listTTS[i]) == true)
                                                                                      ? Color(0xff009C87)
                                                                                      : Colors.grey,
                                                                                ))),
                                                                      )
                                                                    : Container(),
                                                                (getRule(listRule.data, Role.Xem, context))
                                                                    ? Container(
                                                                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                        child: (checkStatusNotDisplayed(listTTS[i]) == false)
                                                                            ? Tooltip(
                                                                                message: "QR code",
                                                                                child: InkWell(
                                                                                  onTap: () {
                                                                                    showDialog(
                                                                                      context: context,
                                                                                      builder: (BuildContext context) => AlertDialog(
                                                                                        title: Container(
                                                                                          margin: EdgeInsets.only(bottom: 15),
                                                                                          width: 300,
                                                                                          height: 300,
                                                                                          child: Image.network(
                                                                                              "$baseUrl/api/files/${listTTS[i].qrcodeUrl}"),
                                                                                        ),
                                                                                        actions: [
                                                                                          Row(
                                                                                            mainAxisAlignment: MainAxisAlignment.end,
                                                                                            children: [
                                                                                              ElevatedButton(
                                                                                                onPressed: () {
                                                                                                  Navigator.pop(context);
                                                                                                },
                                                                                                child: Text('Đóng'),
                                                                                                style: ElevatedButton.styleFrom(
                                                                                                  primary: colorOrange,
                                                                                                  onPrimary: colorWhite,
                                                                                                  elevation: 3,
                                                                                                  minimumSize: Size(140, 50),
                                                                                                ),
                                                                                              ),
                                                                                              Padding(
                                                                                                padding: const EdgeInsets.only(right: 10, left: 10),
                                                                                                child: ElevatedButton(
                                                                                                  onPressed: () async {
                                                                                                    if (listTTS[i].qrcodeUrl != '' &&
                                                                                                        listTTS[i].qrcodeUrl != null) {
                                                                                                      String url =
                                                                                                          '$baseUrl/api/files/${listTTS[i].qrcodeUrl}';
                                                                                                      print(url);
                                                                                                      try {
                                                                                                        html.AnchorElement anchorElement =
                                                                                                            html.AnchorElement(href: url);
                                                                                                        anchorElement.download = listTTS[i].qrcodeUrl;
                                                                                                        anchorElement.click();
                                                                                                        // toast('Tải xuống thành công');
                                                                                                        showToast(
                                                                                                          context: context,
                                                                                                          msg: "Tải thành công",
                                                                                                          color: Color.fromARGB(136, 72, 238, 67),
                                                                                                          icon: Icon(Icons.done),
                                                                                                        );
                                                                                                      } catch (e) {
                                                                                                        showToast(
                                                                                                          context: context,
                                                                                                          msg: "tải xuống thất bại",
                                                                                                          color: Colors.red,
                                                                                                          icon: Icon(Icons.warning),
                                                                                                        );
                                                                                                      }
                                                                                                    } else {
                                                                                                      showToast(
                                                                                                        context: context,
                                                                                                        msg: "Không thể tải xuống",
                                                                                                        color: Colors.red,
                                                                                                        icon: Icon(Icons.warning),
                                                                                                      );
                                                                                                    }
                                                                                                  },
                                                                                                  child: Text(
                                                                                                    'Tải QR code',
                                                                                                    style: TextStyle(),
                                                                                                  ),
                                                                                                  style: ElevatedButton.styleFrom(
                                                                                                    primary: colorBlueBtnDialog,
                                                                                                    onPrimary: colorWhite,
                                                                                                    elevation: 3,
                                                                                                    minimumSize: Size(140, 50),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                  child: Icon(
                                                                                    Icons.qr_code,
                                                                                    color: Color.fromRGBO(245, 117, 29, 1),
                                                                                  ),
                                                                                ),
                                                                              )
                                                                            : Container(
                                                                                child: Icon(
                                                                                  Icons.qr_code,
                                                                                  color: colorWhite,
                                                                                ),
                                                                              ))
                                                                    : Container(),
                                                                Container(
                                                                  margin: marginLeftBtn,
                                                                  width: MediaQuery.of(context).size.width * 0.07,
                                                                  child: (checkTTSNomination(listTTS[i]) == true)
                                                                      ? TextButton(
                                                                          style: TextButton.styleFrom(
                                                                            padding: EdgeInsets.only(top: 20, bottom: 20),
                                                                            shape: RoundedRectangleBorder(
                                                                              borderRadius: borderRadiusBtn,
                                                                            ),
                                                                            backgroundColor: backgroundColorBtn,
                                                                            primary: Theme.of(context).iconTheme.color,
                                                                            textStyle: Theme.of(context)
                                                                                .textTheme
                                                                                .caption
                                                                                ?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                                          ),
                                                                          onPressed: () {
                                                                            showDialog(
                                                                              context: context,
                                                                              builder: (BuildContext context) => DialogOrderRecommendation(
                                                                                tTSOffer: listTTS[i],
                                                                                loadDaTa: () {
                                                                                  setState(() {
                                                                                    pageChange(currentPageDef);
                                                                                  });
                                                                                },
                                                                              ),
                                                                            );
                                                                          },
                                                                          child: Row(
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            children: [
                                                                              Text(' Đề xuất tiến cử', style: textButton),
                                                                            ],
                                                                          ),
                                                                        )
                                                                      : (listTTS[i].ttsStatusId == 1 &&
                                                                              (listTTS[i].stopProcessing == 0 && listTTS[i].ttsStatusId != 13))
                                                                          ? TextButton(
                                                                              style: TextButton.styleFrom(
                                                                                padding: EdgeInsets.only(top: 20, bottom: 20),
                                                                                shape: RoundedRectangleBorder(
                                                                                  borderRadius: borderRadiusBtn,
                                                                                ),
                                                                                backgroundColor: backgroundColorBtn,
                                                                                primary: Theme.of(context).iconTheme.color,
                                                                                textStyle: Theme.of(context)
                                                                                    .textTheme
                                                                                    .caption
                                                                                    ?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                                              ),
                                                                              onPressed: () async {
                                                                                showDialog(
                                                                                  context: context,
                                                                                  builder: (BuildContext context) => AlertDialog(
                                                                                    title: Container(
                                                                                      width: MediaQuery.of(context).size.width * 0.5,
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                        children: [
                                                                                          SizedBox(
                                                                                            child: Row(
                                                                                              children: [
                                                                                                Container(
                                                                                                  width: 40,
                                                                                                  height: 40,
                                                                                                  child: Image.asset('images/logoAAM.png'),
                                                                                                  margin: EdgeInsets.only(right: 10),
                                                                                                ),
                                                                                                Text(
                                                                                                  'Xác nhận tư vấn thực tập sinh',
                                                                                                  style: titleAlertDialog,
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    ),
                                                                                    actions: [
                                                                                      ElevatedButton(
                                                                                          style: ElevatedButton.styleFrom(
                                                                                              primary: colorOrange,
                                                                                              onPrimary: colorWhite,
                                                                                              minimumSize: Size(80, 40)),
                                                                                          onPressed: () async {
                                                                                            Navigator.pop(context);
                                                                                          },
                                                                                          child: Text("Hủy")),
                                                                                      ElevatedButton(
                                                                                          style: ElevatedButton.styleFrom(
                                                                                              primary: colorBlueBtnDialog,
                                                                                              onPrimary: colorWhite,
                                                                                              minimumSize: Size(80, 40)),
                                                                                          onPressed: () async {
                                                                                            await updateStatus(listTTS[i], 2);
                                                                                            setState(() {
                                                                                              futureListTTS = pageChange(currentPageDef);
                                                                                            });
                                                                                            Navigator.pop(context);
                                                                                          },
                                                                                          child: Text("Xác nhận"))
                                                                                    ],
                                                                                  ),
                                                                                );
                                                                              },
                                                                              child: Row(
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  Text('Tư vấn TTS', style: textButton),
                                                                                ],
                                                                              ),
                                                                            )
                                                                          : Container(
                                                                              margin: marginLeftBtn,
                                                                            ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                      selected: _selectedDataRow[i],
                                                      onSelectChanged: ((listTTS[i].stopProcessing! == 0 && listTTS[i].ttsStatusId != 13))
                                                          ? (bool? selected) {
                                                              setState(
                                                                () {
                                                                  _selectedDataRow[i] = selected!;

                                                                  if (_selectedDataRow[i]) {
                                                                    listObjectTTS.add(listTTS[i]);
                                                                  } else {
                                                                    listObjectTTS.remove(listTTS[i]);
                                                                  }
                                                                },
                                                              );
                                                            }
                                                          : null,
                                                    )
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        DynamicTablePagging(rowCount, currentPageDef, rowPerPage, pageChangeHandler: (currentPage) {
                                          setState(() {
                                            futureListTTS = pageChange(currentPage);
                                            currentPageDef = currentPage;
                                          });
                                        }, rowPerPageChangeHandler: (rowPerPageChange) {
                                          currentPageDef = 1;
                                          rowPerPage = rowPerPageChange;
                                          futureListTTS = pageChange(currentPageDef);
                                          setState(() {});
                                        })
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Center(
                                child: Padding(
                              padding: EdgeInsets.all(250),
                              child: Text('${snapshot.error}'),
                            ));
                            // Text('${snapshot.error}');
                          }
                          return Center(
                              child: Padding(
                            padding: EdgeInsets.all(250),
                            child: CircularProgressIndicator(),
                          ));
                        },
                      ),
                      Footer(paddingFooter: paddingBoxContainer, marginFooter: EdgeInsets.only(top: 30)),
                    ],
                  ),
                ),
              ],
            ),
          );
          // Text(listRule.data!.title);
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

//----------------------------Dialoog đề xuất tiến cử--------------------------------
class DialogOrderRecommendation extends StatefulWidget {
  final Function? loadDaTa;
  InformationTTS tTSOffer;
  DialogOrderRecommendation({
    Key? key,
    this.loadDaTa,
    required this.tTSOffer,
  }) : super(key: key);
  @override
  State<DialogOrderRecommendation> createState() => _DialogOrderRecommendationState();
}

class _DialogOrderRecommendationState extends State<DialogOrderRecommendation> {
  //-----------Đề xuất tiến cử đơn hàng thực tập sinh ---------------
  bool checkSelected = false;
  List<dynamic> idSelectedListOrder = [];
  List<bool> _selectedDataRowOrder = [];
  var totalElementsOrder = 0;
  var rowPerPageOrder = 5;
  var currentPageOrder = 1;
  var pageOrder = 0;
  var rowCountOrder = 0;
  var lastRowOrder = 0;
  var contentOrder = [];
  String searchRequestOrder = "";
  late Future<dynamic> futureListOrder;
  var listOrder; //Danh sách đơn hàng
  var date = DateTime.now();

  //Load vòng tròn khi đề xuất tiến cử
  Future<void> processing() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(child: const CircularProgressIndicator());
      },
    );
  }

  Future<dynamic> pageChangeRecommendToOrder() async {
    var response;
    if (searchRequestOrder.isEmpty) {
      response = await httpGet(DON_HANG_GET_PAGE + "size=1000&sort=id&filter=orderStatusId:2 and stopProcessing:0 and nominateStatus:0", context);
    } else {
      response = await httpGet(
          DON_HANG_GET_PAGE + "size=1000&filter=$searchRequestOrder and orderStatusId:2 and stopProcessing:0 and nominateStatus:0 &sort=id", context);
    }
    var body = jsonDecode(response['body']);
    if (response.containsKey("body")) {
      setState(
        () {
          contentOrder = body['content'];
          rowCountOrder = body["totalElements"];
          totalElementsOrder = body["totalElements"];
          _selectedDataRowOrder = List<bool>.generate(contentOrder.length, (int index) => false);
        },
      );
      listOrder = body;
      idSelectedListOrder.clear();
      return body;
    } else {
      throw Exception("failse");
    }
  }

  //--Thêm mới id thực tập sinh và đơn hàng
  addOrder(InformationTTS tTS, List<dynamic> idOrder) async {
    for (var element in idOrder) {
      var data = {"orderId": element["id"], "ttsId": tTS.id, "ptttApproval": 0, "qcApproval": 0};
      var response = await httpPost(DON_HANG_TTS_TIEN_CU_POST, data, context);
      Map resultsAdd = jsonDecode(response["body"]);
      if (resultsAdd.containsKey("1")) {
        titleLog = "Tiến cử thành công";
        await httpPost(
            API_THONG_BAO_PHONG_BAN_POST + "4",
            {
              "title": TIEU_DE_THONG_BAO,
              "message": " ${tTS.userCode} được đề xuất tiến cử vào đơn hàng ${element["orderCode"]} lúc ${FormatDate.formatDateDayHours(date)}"
            },
            context);
        if (tTS.id != null && tTS.ttsStatusId != null) {
          // Thêm mới vào lịch sử
          await httpPostDiariStatus(tTS.id!, tTS.ttsStatusId!, 4, 'Tiến cử TTS vào đơn hàng ${element["orderCode"]}', context);
        }
        await updateStatusTTS(tTS);
      } else if (resultsAdd.containsKey("0")) {
        titleLog = "Tiến cử thất bại";
      }
    }
  }

  //--lấy danh sách thực tập sinh đơn hàng được đề xuất tiến cử
  var listSOderRecommend; //Danh sách đơn hàng
  getTTSOderRecommend() async {
    var response = await httpGet(DON_HANG_TTS_TIEN_CU_GET, context);
    var body = jsonDecode(response['body']);
    if (response.containsKey("body")) {
      setState(() {
        listSOderRecommend = body;
      });
    }
  }

  callApi() async {
    futureListOrder = pageChangeRecommendToOrder();
    await getDonHangTTSTienCu();
  }

  @override
  void initState() {
    super.initState();
    callApi();
  }

  var checkId = [];
  var idOrder = [];
  getDonHangTTSTienCu() async {
    var response = await httpGet(DON_HANG_TTS_TIEN_CU_GET + "&filter=ttsId:'${widget.tTSOffer.id}'", context);
    if (response.containsKey('body')) {
      var body = jsonDecode(response['body']);
      setState(() {
        for (var element in body['content']) {
          checkId.add({
            "orderId": element['orderId'],
            "qcApproval": element['qcApproval'],
            "ptttApproval": element['ptttApproval'],
            "active": element['active']
          });
          idOrder.add(element['orderId']);
        }
      });
    }
  }

  //Check xem active còn hiệu lực hay không 
  bool checkActiveTrueFalse(idOder) {
    for (int i = 0; i < checkId.length; i++) {
      if (checkId[i]['orderId'] == idOder) {
        if (checkId[i]['active'] == true) {
          return true;
        } else {
          return false;
        }
      }
    }
    return false;
  }

  //xử lý những trường hợp được đề xuất
  bool getWidgetByConditionIs2(idOder) {
    for (int i = 0; i < checkId.length; i++) {
      if (checkId[i]['orderId'] == idOder) {
        if (checkId[i]['ptttApproval'] == 2 || checkId[i]['qcApproval'] == 2) {
          return true;
        } else {
          return false;
        }
      }
    }
    return false;
  }

  //Cập nhật trạng thái thực tập sinh
  updateStatusTTS(InformationTTS objectTTS) async {
    objectTTS.ttsStatusId = 4;
    await httpPut("/api/nguoidung/put/${objectTTS.id!}", objectTTS, context);
  }

  //--Tìm kiếm đơn hàng
  TextEditingController nameControllerOrder = TextEditingController();
  late String titleLog;

  @override
  Widget build(BuildContext context) {
    return Consumer2<NavigationModel, SecurityModel>(
      builder: (context, navigationModel, user, child) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    child: Image.asset('images/logoAAM.png'),
                    margin: EdgeInsets.only(right: 10),
                  ),
                  Text(
                    'Tiến cử đơn hàng',
                    style: titleAlertDialog,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.close,
              ),
            ),
          ],
        ),
        content: IntrinsicHeight(
          //dùng cái này để tự theo chiều cao của widget bên trong
          child: Column(
            children: [
              Container(
                margin: marginTopBottomHorizontalLine,
                child: Divider(
                  thickness: 1,
                  color: ColorHorizontalLine,
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  children: [
                    Row(
                      children: [
                        TextFieldValidated(
                          label: 'Đơn hàng',
                          hint: "Tên đơn hàng",
                          type: 'none',
                          height: 40,
                          controller: nameControllerOrder,
                          enter: () {
                            searchRequestOrder = "orderName~'*${nameControllerOrder.text}*'";
                            futureListOrder = pageChangeRecommendToOrder();
                          },
                        ),
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          child: TextButton.icon(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: 20.0,
                                horizontal: 10.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                              primary: Theme.of(context).iconTheme.color,
                              textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                            ),
                            onPressed: () {
                              searchRequestOrder = "orderName~'*${nameControllerOrder.text}*'";
                              futureListOrder = pageChangeRecommendToOrder();
                            },
                            icon: Icon(
                              Icons.search_sharp,
                              color: Colors.white,
                              size: 15,
                            ),
                            label: Row(
                              children: [
                                Text('Tìm kiếm', style: textButton),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Container(),
                        ),
                      ],
                    ),
                    //--------------------Bảng đơn hàng dùng để tiến cử--------------------------
                    FutureBuilder(
                      future: futureListOrder,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return Container(
                            // width: MediaQuery.of(context).size.width * 1,
                            margin: marginTopBoxContainer,
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Kết quả tìm kiếm: $rowCountOrder',
                                      style: titleBox,
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: borderAllContainerBox,
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              height: MediaQuery.of(context).size.width * 0.2,
                                              child: SingleChildScrollView(
                                                scrollDirection: Axis.vertical,
                                                child: (rowCountOrder == 0)
                                                    ? Center(
                                                        child: Padding(
                                                        padding: EdgeInsets.all(100),
                                                        child: Text('Không có kết quả tìm kiếm phù hợp'),
                                                      ))
                                                    : DataTable(
                                                        showCheckboxColumn: false,
                                                        columnSpacing: 20,
                                                        horizontalMargin: 10,
                                                        dataRowHeight: 50,
                                                        columns: [
                                                          DataColumn(
                                                              label: Container(
                                                                  width: MediaQuery.of(context).size.width * 0.02,
                                                                  child: Text('STT', style: titleTableData))),
                                                          DataColumn(
                                                              label: Container(
                                                                  width: MediaQuery.of(context).size.width * 0.06,
                                                                  child: Text('Mã Đơn hàng', style: titleTableData))),
                                                          DataColumn(label: Text('Tên đơn hàng', style: titleTableData)),
                                                          DataColumn(label: Text('Mã nghiệp đoàn', style: titleTableData)),
                                                          DataColumn(label: Text('Tên nghiệp đoàn', style: titleTableData)),
                                                          DataColumn(label: Text('Tên xí nghiệp', style: titleTableData)),
                                                          DataColumn(label: Text('Nghành nghề', style: titleTableData)),
                                                          DataColumn(label: Text('Tiến cử', style: titleTableData)),
                                                        ],
                                                        rows: <DataRow>[
                                                          for (int i = 0; i < listOrder["content"].length; i++)
                                                            DataRow(
                                                              cells: <DataCell>[
                                                                DataCell(Container(
                                                                    width: MediaQuery.of(context).size.width * 0.01,
                                                                    child: SelectableText("${1 + i}"))),
                                                                DataCell(
                                                                  Container(
                                                                      width: MediaQuery.of(context).size.width * 0.06,
                                                                      child: SelectableText(listOrder["content"][i]["orderCode"] ?? "",
                                                                          style: bangDuLieu)),
                                                                ),
                                                                DataCell(
                                                                  Container(
                                                                    width: MediaQuery.of(context).size.width * 0.18,
                                                                    child:
                                                                        SelectableText(listOrder["content"][i]["orderName"] ?? "", style: bangDuLieu),
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  Container(
                                                                      width: MediaQuery.of(context).size.width * 0.07,
                                                                      child: SelectableText(listOrder["content"][i]["nghiepdoan"]["orgCode"] ?? "",
                                                                          style: bangDuLieu)),
                                                                ),
                                                                DataCell(
                                                                  Container(
                                                                      width: MediaQuery.of(context).size.width * 0.12,
                                                                      child: SelectableText(listOrder["content"][i]["nghiepdoan"]["orgName"] ?? "",
                                                                          style: bangDuLieu)),
                                                                ),
                                                                DataCell(
                                                                  Container(
                                                                    width: MediaQuery.of(context).size.width * 0.1,
                                                                    child: SelectableText(listOrder["content"][i]["xinghiep"]["companyName"] ?? "",
                                                                        style: bangDuLieu),
                                                                  ),
                                                                ),
                                                                DataCell(
                                                                  Container(
                                                                      width: MediaQuery.of(context).size.width * 0.08,
                                                                      child: SelectableText(listOrder["content"][i]["nganhnghe"]["jobName"] ?? "",
                                                                          style: bangDuLieu)),
                                                                ),
                                                                DataCell(
                                                                  Container(
                                                                    width: MediaQuery.of(context).size.width * 0.06,
                                                                    child: Row(
                                                                      children: [
                                                                        (idOrder.contains(listOrder["content"][i]['id']) &&
                                                                                checkActiveTrueFalse(listOrder["content"][i]['id']) == true)
                                                                            ? (getWidgetByConditionIs2(listOrder["content"][i]['id']) == true)
                                                                                ? Row(
                                                                                    children: [
                                                                                      Text(
                                                                                        "Từ chối",
                                                                                        style: TextStyle(color: Colors.red),
                                                                                      ),
                                                                                      CheckBoxWidget(
                                                                                        isChecked: _selectedDataRowOrder[i],
                                                                                        functionCheckBox: (value) {
                                                                                          setState(
                                                                                            () {
                                                                                              _selectedDataRowOrder[i] = value;
                                                                                              if (_selectedDataRowOrder[i]) {
                                                                                                idSelectedListOrder.add(listOrder["content"][i]);
                                                                                              } else {
                                                                                                idSelectedListOrder.remove(listOrder["content"][i]);
                                                                                              }
                                                                                            },
                                                                                          );
                                                                                        },
                                                                                        widgetTitle: [],
                                                                                      )
                                                                                    ],
                                                                                  )
                                                                                : Text("Đã đề xuất", style: TextStyle(color: Colors.blue))
                                                                            : CheckBoxWidget(
                                                                                isChecked: _selectedDataRowOrder[i],
                                                                                functionCheckBox: (value) {
                                                                                  setState(
                                                                                    () {
                                                                                      _selectedDataRowOrder[i] = value;
                                                                                      if (_selectedDataRowOrder[i]) {
                                                                                        idSelectedListOrder.add(listOrder["content"][i]);
                                                                                      } else {
                                                                                        idSelectedListOrder.remove(listOrder["content"][i]);
                                                                                      }

                                                                                      // print(idSelectedListOrder);
                                                                                      // _selectedDataRowOrder[i] = value!;
                                                                                      // if (_selectedDataRowOrder[i] == true) {
                                                                                      //   checkSelected = true;
                                                                                      // } else {
                                                                                      //   checkSelected = false;
                                                                                      // }
                                                                                    },
                                                                                  );
                                                                                },
                                                                                widgetTitle: [],
                                                                              ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                        ],
                                                      ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return const Center(
                              child: Padding(
                            padding: EdgeInsets.all(100),
                            child: Text('Không có dữ liệu'),
                          ));
                        }
                        return const Center(
                            child: Padding(
                          padding: EdgeInsets.all(100),
                          child: CircularProgressIndicator(),
                        ));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    // textColor: Color(0xFF6200EE),
                    onPressed: () {
                      idSelectedListOrder.clear();
                      Navigator.pop(context);
                    },
                    child: Text('Hủy'),
                    style: ElevatedButton.styleFrom(
                      primary: colorOrange,
                      onPrimary: colorWhite,
                      // shadowColor: Colors.greenAccent,
                      elevation: 3,
                      minimumSize: Size(140, 50),
                      // maximumSize: Size(140, 50), //////// HERE
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10, left: 10),
                    child: ElevatedButton(
                      onPressed: idSelectedListOrder.isNotEmpty
                          ? () async {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                  title: Container(
                                    width: MediaQuery.of(context).size.width * 0.5,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 40,
                                                height: 40,
                                                child: Image.asset('images/logoAAM.png'),
                                                margin: EdgeInsets.only(right: 10),
                                              ),
                                              Text(
                                                'Bạn muốn đề xuất thực tập sinh vào đơn hàng',
                                                style: titleAlertDialog,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  actions: [
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(primary: colorOrange, onPrimary: colorWhite, minimumSize: Size(80, 40)),
                                        onPressed: () async {
                                          Navigator.pop(context);
                                        },
                                        child: Text("Hủy")),
                                    ElevatedButton(
                                        style:
                                            ElevatedButton.styleFrom(primary: colorBlueBtnDialog, onPrimary: colorWhite, minimumSize: Size(80, 40)),
                                        onPressed: () async {
                                          processing();
                                          await addOrder(widget.tTSOffer, idSelectedListOrder);

                                          idSelectedListOrder.clear();
                                          widget.loadDaTa!();

                                          showToast(
                                            context: context,
                                            msg: titleLog,
                                            color: titleLog == "Tiến cử thành công" ? Colors.green : Colors.red,
                                            icon: titleLog == "Tiến cử thành công" ? Icon(Icons.done) : Icon(Icons.warning),
                                          );
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                          Navigator.pop(context);
                                        },
                                        child: Text("Xác nhận"))
                                  ],
                                ),
                              );
                            }
                          : null,
                      child: Text(
                        'Xác nhận',
                        style: TextStyle(),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: colorBlueBtnDialog,
                        onPrimary: colorWhite,
                        // shadowColor: Colors.greenAccent,
                        elevation: 3,
                        // shape: RoundedRectangleBorder(
                        //     borderRadius: BorderRadius.circular(32.0)),
                        minimumSize: Size(140, 50),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              )
            ],
          ),
        ],
      ),
    );
  }
}
