// ignore_for_file: must_be_immutable

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../config.dart';
import '../../../../model/model.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:js' as js;

import '../common_ource_information/common_source_information.dart';
import '../common_ource_information/constant.dart';
import '../setting-data/tts.dart';

class QuanLyCTV extends StatelessWidget {
  var userlogin;

  QuanLyCTV({Key? key, this.userlogin}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: QuanLyCTVBody(
      userlogin: userlogin,
    ));
  }
}

class QuanLyCTVBody extends StatefulWidget {
  var userlogin;
  QuanLyCTVBody({Key? key, this.userlogin}) : super(key: key);

  @override
  State<QuanLyCTVBody> createState() => _QuanLyCTVBodyState();
}

class _QuanLyCTVBodyState extends State<QuanLyCTVBody> {
  //--Lấy ngày tháng
  String? dateFrom;
  String? dateTo;

  TextEditingController nameCTVController = TextEditingController();
  TextEditingController phoneCTVController = TextEditingController();

  String condition = ""; //Tình trạng
  late int rowCount = 0;
  int currentPageDef = 1;
  int rowPerPage = 10;
  var searchRequest = "";
  var historyGT;
  List<InformationTTS> listTrainee = []; //Danh sách cộng tác viên
  late Future<List<InformationTTS>> futureListCTV;
  Future<List<InformationTTS>> pageChange(currentPage) async {
    var content = [];
    if (widget.userlogin['teamId'] != null ||
        (widget.userlogin['departId'] == 3 && widget.userlogin['vaitro'] != null && widget.userlogin['vaitro']['level'] == 2) ||
        (widget.userlogin['departId'] != null && (widget.userlogin['departId'] == 1 || widget.userlogin['departId'] == 2))) {
      //Gọi để xem những thực tập sinh nào đã xuất cảnh
      var gioiThieu = await httpGet("/api/nguoidung/get/page?filter=isTts:1 and ttsStatusId:11", context);
      if (gioiThieu.containsKey("body")) {
        historyGT = jsonDecode(gioiThieu["body"])['content'];
      }
      //Phân quyền xem dữ liệu theo phòng ban à quyền admin chủ tịch giám đốc
      var phanQuyenXem;
      if (widget.userlogin['departId'] == 1 ||
          widget.userlogin['departId'] == 2 ||
          (widget.userlogin['departId'] == 3 && widget.userlogin['vaitro'] != null && widget.userlogin['vaitro']['level'] == 2)) {
        phanQuyenXem = "";
      } else {
        if (widget.userlogin['departId'] == 3 &&
            widget.userlogin['vaitro'] != null &&
            (widget.userlogin['vaitro']['level'] == 0 || widget.userlogin['vaitro']['level'] == 1)) {
          phanQuyenXem = "and nhanvientuyendung.teamId:${widget.userlogin['teamId']}";
        }
      }

      var response = await httpGet(
          API_NGUOI_DUNG +
              "size=$rowPerPage&page=${currentPage - 1}&filter= (fullName~'*${nameCTVController.text}*' or userCode~'*${nameCTVController.text}*')  and phone~'*${phoneCTVController.text}*' $phanQuyenXem and isCtv:1 and active:1 $searchRequest&sort=createdDate,desc",
          context);
      var body = jsonDecode(response['body']);
      if (response.containsKey("body")) {
        setState(() {
          content = body['content'];
          rowCount = body["totalElements"];
          listTrainee = content.map((e) {
            return InformationTTS.fromJson(e);
          }).toList();
        });
      }
    }
    return content.map((e) {
      return InformationTTS.fromJson(e);
    }).toList();
  }

  bool checkSelected = false;

  //xóa cộng tác viên
  deleteCTV(idCTV) async {
    var res = await httpDelete('/api/nguoidung/del/ctv/$idCTV', context);
    Map body = jsonDecode(res["body"]);

    if (body.containsKey("1")) {
      showToast(context: context, msg: "${body["1"]}", color: Colors.green, icon: Icon(Icons.supervised_user_circle));
    } else {
      showToast(context: context, msg: "${body["0"]}", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
    }
  }

  //Check ctv chưa chưa có nhân viên chăm sóc
  bool isCheckCareUser = false;

  var optionListTTSStatus = {"-1": "Tất cả"};
  String? idTTSRecommend;
  //--cập nhật trạng thái thực tập sinh khi dừng xử lý học
  updateStatus(id, status) async {
    var requestBody = {"isTts": 1, "ttsStatusId": status};
    await httpPut("/api/nguoidung/put/$id", requestBody, context);
  }

  searchFunction() {
    searchRequest = "";

    if (isCheckCareUser == true) {
      searchRequest += "and careUser is null";
    }

    if (dateFrom != null && dateTo != null) {
      searchRequest += "and createdDate>:'$dateFrom' and createdDate<:'$dateTo'";
    } else if (dateFrom != null && dateTo == null) {
      searchRequest += "and createdDate>:'$dateFrom'";
    } else if (dateFrom == null && dateTo != null) {
      searchRequest += "and createdDate<:'$dateTo'";
    }
    futureListCTV = pageChange(1);
  }

  @override
  void initState() {
    super.initState();
    futureListCTV = pageChange(1);
  }

  int getCountTtsXC(id) {
    int count = 0;
    if (historyGT != null)
      for (var row in historyGT) {
        if (row['recommendUser'] == id) {
          count++;
        }
      }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule(QUAN_LY_CTV, context),
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
                  content: 'Quản lý cộng tác viên',
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
                                  'Nhập thông tin',
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
                                  label: 'CTV',
                                  type: 'none',
                                  height: 40,
                                  controller: nameCTVController,
                                  hint: "Tên hoặc mã CTV",
                                  enter: () {
                                    searchFunction();
                                  },
                                ),
                                SizedBox(width: 50),
                                TextFieldValidated(
                                  label: 'SDT',
                                  type: 'Phone',
                                  height: 40,
                                  hint: "Số điện thoại cộng tác viên",
                                  controller: phoneCTVController,
                                  enter: () {
                                    searchFunction();
                                  },
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
                                  user.userLoginCurren['vaitro'] != null && user.userLoginCurren['vaitro']['level'] == 2
                                      ? Container(
                                          child: CheckBoxWidget(
                                              isChecked: isCheckCareUser,
                                              functionCheckBox: (bool value) {
                                                setState(() {
                                                  isCheckCareUser = value;
                                                  searchFunction();
                                                  // futureListTTS = pageChange(1);
                                                });
                                              },
                                              widgetTitle: [
                                                Text('CTV cần người xử lý'),
                                              ]),
                                        )
                                      : Container(),
                                  //dừng xử lý nút
                                  Row(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(left: 20),
                                        child: TextButton.icon(
                                          icon: Icon(
                                            Icons.account_tree_outlined,
                                            color: Colors.white,
                                            size: 15,
                                          ),
                                          style: TextButton.styleFrom(
                                            padding: paddingBtn,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: borderRadiusBtn,
                                            ),
                                            backgroundColor: backgroundColorBtn,
                                            primary: Theme.of(context).iconTheme.color,
                                            textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                          ),
                                          onPressed: () {
                                            Provider.of<NavigationModel>(context, listen: false).add(pageUrl: "/tinh-thuong-ctv");
                                          },
                                          label: Row(
                                            children: [
                                              Text('Tính thưởng', style: textButton),
                                            ],
                                          ),
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
                                            padding: paddingBtn,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: borderRadiusBtn,
                                            ),
                                            backgroundColor: backgroundColorBtn,
                                            primary: Theme.of(context).iconTheme.color,
                                            textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                          ),
                                          onPressed: () {
                                            searchFunction();
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
                                              margin: marginLeftBtn,
                                              child: TextButton.icon(
                                                icon: Icon(
                                                  Icons.add,
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                                style: TextButton.styleFrom(
                                                  padding: paddingBtn,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: borderRadiusBtn,
                                                  ),
                                                  backgroundColor: backgroundColorBtn,
                                                  primary: Theme.of(context).iconTheme.color,
                                                  textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                ),
                                                onPressed: () {
                                                  navigationModel.add(pageUrl: "/them-moi-cong-tac-vien");
                                                },
                                                label: Text('Thêm mới', style: textButton),
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder<List<InformationTTS>>(
                        future: futureListCTV,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            // int toolTipLength = MediaQuery.of(context).size.width < 1600 ? 33 : 60;
                            var tableIndex = (currentPageDef - 1) * rowPerPage + 1;
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
                                        'Thông tin cộng tác viên',
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
                                                showCheckboxColumn: true,
                                                columnSpacing: 0,
                                                dataRowHeight: MediaQuery.of(context).size.width < 1600 ? 78 : 63,
                                                columns: [
                                                  DataColumn(label: Text('STT', style: titleTableData)),
                                                  DataColumn(
                                                      label: Container(
                                                          width: MediaQuery.of(context).size.width * 0.09,
                                                          child: Text(
                                                            'Mã CTV',
                                                            style: titleTableData,
                                                            maxLines: 2,
                                                            softWrap: true,
                                                            // overflow: TextOverflow.ellipsis,
                                                          ))),
                                                  DataColumn(
                                                      label: Container(
                                                          width: MediaQuery.of(context).size.width * 0.09,
                                                          child: Text(
                                                            'Họ tên',
                                                            style: titleTableData,
                                                            maxLines: 2,
                                                            softWrap: true,
                                                            // overflow: TextOverflow.ellipsis,
                                                          ))),
                                                  DataColumn(
                                                      label: Container(
                                                          width: MediaQuery.of(context).size.width * 0.05,
                                                          child: Text(
                                                            'Giới tính',
                                                            style: titleTableData,
                                                            maxLines: 2,
                                                            softWrap: true,
                                                            // overflow: TextOverflow.ellipsis,
                                                          ))),
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
                                                          width: MediaQuery.of(context).size.width * 0.09,
                                                          child: Text(
                                                            'Nhân viên tuyển dụng',
                                                            style: titleTableData,
                                                            maxLines: 2,
                                                            softWrap: true,
                                                            // overflow: TextOverflow.ellipsis,
                                                          ))),
                                                  DataColumn(
                                                      label: Container(
                                                          width: MediaQuery.of(context).size.width * 0.09,
                                                          child: Text(
                                                            'Phòng ban ',
                                                            style: titleTableData,
                                                            maxLines: 2,
                                                            softWrap: true,
                                                            // overflow: TextOverflow.ellipsis,
                                                          ))),
                                                  DataColumn(
                                                      label: Container(
                                                          width: MediaQuery.of(context).size.width * 0.09,
                                                          child: Text(
                                                            'Số TTS đã xuất cảnh',
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
                                                  for (int i = 0; i < listTrainee.length; i++)
                                                    DataRow(
                                                      cells: <DataCell>[
                                                        DataCell(
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.03,
                                                            child: SelectableText(
                                                              "${tableIndex++}",
                                                              style: bangDuLieu,
                                                              // maxLines: 2,
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.09,
                                                            child: SelectableText(
                                                              listTrainee[i].userCode ?? "",
                                                              style: bangDuLieu,
                                                              // maxLines: 2,
                                                              // textAlign: TextAlign.center,

                                                              // softWrap: true,
                                                              // overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.09,
                                                            child: SelectableText(
                                                              listTrainee[i].fullName ?? "",
                                                              style: bangDuLieu,
                                                              // maxLines: 2,
                                                              // textAlign: TextAlign.center,

                                                              // softWrap: true,
                                                              // overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),

                                                        DataCell(
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.05,
                                                            child: SelectableText(
                                                              listTrainee[i].getGender(),
                                                              style: bangDuLieu,
                                                              // maxLines: 2,
                                                              // softWrap: true,
                                                              // overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),

                                                        DataCell(Row(
                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                          children: [
                                                            Container(
                                                                width: MediaQuery.of(context).size.width * 0.06,
                                                                child: SelectableText(listTrainee[i].phone!, style: bangDuLieu)),
                                                            Tooltip(
                                                              message: "Gọi điện",
                                                              child: InkWell(
                                                                  onTap: () async {
                                                                    js.context.callMethod('call', [listTrainee[i].phone.toString()]);
                                                                  },
                                                                  child: Icon(
                                                                    Icons.phone_in_talk,
                                                                    color: Color.fromARGB(255, 52, 147, 224),
                                                                  )),
                                                            ),
                                                          ],
                                                        )),

                                                        DataCell(
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.09,
                                                            child: SelectableText(
                                                              (listTrainee[i].nhanvientuyendung != null &&
                                                                      listTrainee[i].nhanvientuyendung!.fullName! != '' &&
                                                                      listTrainee[i].nhanvientuyendung!.userCode! != "")
                                                                  ? "${listTrainee[i].nhanvientuyendung!.fullName!}/${listTrainee[i].nhanvientuyendung!.userCode!}"
                                                                  : '',
                                                              style: bangDuLieu,
                                                              // maxLines: 2,
                                                              // softWrap: true,
                                                              // overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.09,
                                                            child: SelectableText(
                                                              (listTrainee[i].nhanvientuyendung != null &&
                                                                      listTrainee[i].nhanvientuyendung!.doinhom != null &&
                                                                      listTrainee[i].nhanvientuyendung!.doinhom!.departName != null)
                                                                  ? "${listTrainee[i].nhanvientuyendung!.doinhom!.departName!}"
                                                                  : '',

                                                              style: bangDuLieu,
                                                              // maxLines: 2,
                                                              // softWrap: true,
                                                              // overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                        DataCell(
                                                          Container(
                                                            width: MediaQuery.of(context).size.width * 0.09,
                                                            child: SelectableText(
                                                              getCountTtsXC(listTrainee[i].id).toString(),
                                                              style: bangDuLieu,
                                                              // maxLines: 2,
                                                              // softWrap: true,
                                                              // overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ),
                                                        ),

                                                        DataCell(
                                                          Row(
                                                            children: [
                                                              (getRule(listRule.data, Role.Xem, context))
                                                                  ? Container(
                                                                      child: Tooltip(
                                                                      message: TOOLIP_XEM_CHI_TIET,
                                                                      child: InkWell(
                                                                          onTap: () {
                                                                            Provider.of<NavigationModel>(context, listen: false)
                                                                                .add(pageUrl: URL_XEM_CHI_TIET_THONG_TIN + "/${listTrainee[i].id}");
                                                                          },
                                                                          child: Icon(Icons.visibility)),
                                                                    ))
                                                                  : Container(),
                                                              (getRule(listRule.data, Role.Sua, context))
                                                                  ? (user.userLoginCurren['departId'] == 1 || user.userLoginCurren['departId'] == 2)
                                                                      ? Container(
                                                                          margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                          child: Tooltip(
                                                                            //Ceck quyền admin
                                                                            message: "Sửa thông tin",

                                                                            child: InkWell(
                                                                                onTap: () {
                                                                                  Provider.of<NavigationModel>(context, listen: false)
                                                                                      .add(pageUrl: URL_CAP_NHAT_CTV + "/${listTrainee[i].id}");
                                                                                },
                                                                                child: Icon(Icons.edit_calendar, color: Color(0xff009C87))),
                                                                          ),
                                                                        )
                                                                      : Container(
                                                                          margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                          child: Tooltip(
                                                                            //Ceck quyền admin
                                                                            message:
                                                                                // (listTrainee[i].careUser == null ||
                                                                                //         (listTrainee[i].careUser != null &&
                                                                                //             user.userLoginCurren['id'] == listTrainee[i].careUser) ||
                                                                                //         (user.userLoginCurren['vaitro'] != null &&
                                                                                //             user.userLoginCurren['vaitro']['level'] == 1))
                                                                                // ?
                                                                                "Sửa thông tin",
                                                                            // : "Bạn không có quyền",

                                                                            child: InkWell(
                                                                                onTap:
                                                                                    // (listTrainee[i].careUser == null ||
                                                                                    //         (listTrainee[i].careUser != null &&
                                                                                    //             user.userLoginCurren['id'] == listTrainee[i].careUser) ||
                                                                                    //         (user.userLoginCurren['vaitro'] != null &&
                                                                                    //             (user.userLoginCurren['vaitro']['level'] == 1 ||
                                                                                    //                 user.userLoginCurren['vaitro']['level'] == 2)))
                                                                                    //     ?
                                                                                    () {
                                                                                  Provider.of<NavigationModel>(context, listen: false)
                                                                                      .add(pageUrl: URL_CAP_NHAT_CTV + "/${listTrainee[i].id}");
                                                                                },
                                                                                // : null,
                                                                                child: Icon(
                                                                                  Icons.edit_calendar,
                                                                                  color:
                                                                                      // (listTrainee[i].careUser == null ||
                                                                                      //         (listTrainee[i].careUser != null &&
                                                                                      //             user.userLoginCurren['id'] ==
                                                                                      //                 listTrainee[i].careUser) ||
                                                                                      //         (user.userLoginCurren['vaitro']['level'] == 1 ||
                                                                                      //             user.userLoginCurren['vaitro']['level'] == 2))
                                                                                      // ?
                                                                                      Color(0xff009C87),
                                                                                  // : Colors.grey,
                                                                                )),
                                                                          ),
                                                                        )
                                                                  : Container(),
                                                              // Xóa cộng tác viên
                                                              (getRule(listRule.data, Role.Xoa, context))
                                                                  ? Container(
                                                                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                      child: Tooltip(
                                                                        message: TOOLIP_XOA_NGUOI_DUNG + " cộng tác viên",
                                                                        child: InkWell(
                                                                            onTap: () {
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
                                                                                                'Bạn muốn xóa vĩnh viễn cộng tác viên?',
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
                                                                                          await deleteCTV(listTrainee[i].id);
                                                                                          setState(() {
                                                                                            futureListCTV = pageChange(currentPageDef);
                                                                                          });
                                                                                          Navigator.pop(context);
                                                                                        },
                                                                                        child: Text("Xác nhận"))
                                                                                  ],
                                                                                ),
                                                                              );
                                                                            },
                                                                            child: Icon(
                                                                              Icons.delete,
                                                                              color: Colors.red,
                                                                            )),
                                                                      ))
                                                                  : Container(),
                                                              //Mã QR Code
                                                              (getRule(listRule.data, Role.Xem, context))
                                                                  ? Container(
                                                                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                      child: Tooltip(
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
                                                                                  child:
                                                                                      Image.network("$baseUrl/api/files/${listTrainee[i].qrcodeUrl}"),
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
                                                                                            if (listTrainee[i].qrcodeUrl != '' &&
                                                                                                listTrainee[i].qrcodeUrl != null) {
                                                                                              String url =
                                                                                                  '$baseUrl/api/files/${listTrainee[i].qrcodeUrl}';
                                                                                              try {
                                                                                                html.AnchorElement anchorElement =
                                                                                                    html.AnchorElement(href: url);
                                                                                                anchorElement.download = listTrainee[i].qrcodeUrl;
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
                                                                      ),
                                                                    )
                                                                  : Container()
                                                            ],
                                                          ),
                                                        ),
                                                        //
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        DynamicTablePagging(rowCount, currentPageDef, rowPerPage, pageChangeHandler: (currentPage) {
                                          setState(() {
                                            futureListCTV = pageChange(currentPage);
                                            currentPageDef = currentPage;
                                          });
                                        }, rowPerPageChangeHandler: (rowPerPageChange) {
                                          currentPageDef = 1;
                                          rowPerPage = rowPerPageChange;
                                          futureListCTV = pageChange(currentPageDef);
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
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

//---------------DialogNotification--------------
class DialogNotification extends StatefulWidget {
  // final Widget contentDialog;
  const DialogNotification({
    Key? key,
  }) : super(key: key);
  @override
  State<DialogNotification> createState() => _DialogNotificationState();
}

class _DialogNotificationState extends State<DialogNotification> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
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
                    'Dừng xử lý ',
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
      ),
    );
  }
}
