import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import 'package:gentelella_flutter/model/model.dart';
import 'package:intl/intl.dart';
import "package:collection/collection.dart";

import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../navigation.dart';

class ThemMoiPhongKyTuc extends StatefulWidget {
  final String? id;
  const ThemMoiPhongKyTuc({Key? key, this.id}) : super(key: key);

  @override
  State<ThemMoiPhongKyTuc> createState() => _ThemMoiPhongKyTucState();
}

class _ThemMoiPhongKyTucState extends State<ThemMoiPhongKyTuc> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: ThemMoiPhongKyTucBody(
      id: widget.id,
    ));
  }
}

class ThemMoiPhongKyTucBody extends StatefulWidget {
  final String? id;
  const ThemMoiPhongKyTucBody({Key? key, this.id}) : super(key: key);

  @override
  State<ThemMoiPhongKyTucBody> createState() => _ThemMoiPhongKyTucBodyState();
}

class _ThemMoiPhongKyTucBodyState extends State<ThemMoiPhongKyTucBody> {
  late Future<dynamic> getListTTSFuture;
  var listTtsTC;
  var listGVCN = [];
  var listDataCTDT = [];
  late int rowCount = 0;
  int currentPage = 1;
  int rowPerPage = 10;
  dynamic selectedValueGVCN;
  dynamic selectedValueCTDT;
  bool checkText = false;
  bool isEmpty = false;
  dynamic listItemsCTDT = [];
  dynamic listItemsGVCN = [];
  TextEditingController roomName = TextEditingController();
  TextEditingController capacity = TextEditingController();

  TextEditingController searchCTDT = TextEditingController();
  TextEditingController searchGVCN = TextEditingController();

  var listTts;
  late String titleLog;
  //Lấy ra danh sách thực tập sinh có trong lớp
  var room;
  int count = 0;
  //Lấy ra thông tin của lớp học
  getRoomInfo() async {
    var response = await httpGet("/api/kytucxa/get/${widget.id}", context);
    var getCount = await httpGet(
        "/api/kytucxa-chitiet/get/page?filter=dormId:${widget.id} and status:1",
        context);
    if (getCount.containsKey("body")) {
      count = jsonDecode(getCount["body"])['totalElements'];
      print(count);
    }
    if (response.containsKey("body")) {
      room = jsonDecode(response["body"]);
      roomName.text = room['name'];
      capacity.text = room['capacity'].toString();
      seletedGender = room['gender'].toString();
      return room;
    }
  }

  String seletedGender = '0';
  List<dynamic> itemsGender = [
    {'name': 'Nữ', 'value': '0'},
    {'name': 'Nam', 'value': '1'},
  ];
  Future<dynamic> notId() async {
    return {};
  }

  addRoom() async {
    var data = {
      "name": roomName.text,
      "capacity": int.parse(capacity.text),
      "gender": int.parse(seletedGender),
      "status": 0
    };
    var response = await httpPost('/api/kytucxa/post/save', data, context);
    if (isNumber(response['body'])) {
      titleLog = 'Thêm mới dữ liệu thành công';
      return response['body'];
    } else {
      titleLog = 'Thêm mới dữ liệu thất bại';
    }
  }

  submitForm() async {
    if (widget.id == null) {
      await addRoom();
      showToast(
        context: context,
        msg: titleLog,
        color: titleLog == "Thêm mới dữ liệu thành công"
            ? Color.fromARGB(136, 72, 238, 67)
            : Colors.red,
        icon: titleLog == "Thêm mới dữ liệu thành công"
            ? Icon(Icons.done)
            : Icon(Icons.warning),
      );
    } else {
      room['name'] = roomName.text;
      room['capacity'] = int.parse(capacity.text);
      room['gender'] = int.parse(seletedGender);
      var response =
          await httpPut('/api/kytucxa/put/${widget.id}', room, context);
      if (response['body'] == "true") {
        titleLog = 'Cập nhật dữ liệu thành công';
      } else {
        titleLog = 'Cập nhật thất bại';
      }

      showToast(
        context: context,
        msg: titleLog,
        color: titleLog == "Cập nhật dữ liệu thành công"
            ? Color.fromARGB(136, 72, 238, 67)
            : Colors.red,
        icon: titleLog == "Cập nhật dữ liệu thành công"
            ? Icon(Icons.done)
            : Icon(Icons.warning),
      );
    }
  }

  bool isNumber(String string) {
    try {
      int.parse(string);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  void initState() {
    if (widget.id != null) {
      getListTTSFuture = getRoomInfo();
    } else {
      getListTTSFuture = notId();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/them-moi-chinh-sua-ky-tuc', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return FutureBuilder<dynamic>(
            future: getListTTSFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView(
                  children: [
                    TitlePage(
                      listPreTitle: [
                        {'url': '/bang-thong-ke-nhanh', 'title': 'Dashboard'},
                        {
                          'url': '/quan-ly-ky-tuc-xa',
                          'title': 'Quản lý phòng ký túc xá'
                        }
                      ],
                      content: widget.id == null
                          ? "Thêm mới phòng ký túc"
                          : "Cập nhật phòng ký túc",
                    ),
                    Container(
                      color: backgroundPage,
                      padding: EdgeInsets.symmetric(
                          vertical: verticalPaddingPage,
                          horizontal: horizontalPaddingPage),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 20),
                              width: MediaQuery.of(context).size.width * 1,
                              decoration: BoxDecoration(
                                color: colorWhite,
                                borderRadius: borderRadiusContainer,
                                boxShadow: [boxShadowContainer],
                                border: borderAllContainerBox,
                              ),
                              padding: paddingBoxContainer,
                              child: Column(children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SelectableText(
                                      'Nhập thông tin ',
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
                                  children: [
                                    Expanded(
                                        flex: 4,
                                        child: TextFieldValidatedForm(
                                          label: 'Tên phòng',
                                          height: 40,
                                          type: 'Text',
                                          controller: roomName,
                                          flexLable: 2,
                                          enter: () {},
                                          requiredValue: 1,
                                        )),
                                    // Expanded(child: Container(), flex: 5),
                                    SizedBox(
                                      width: 150,
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 40),
                                        child: DropdownBtnSearch(
                                          isAll: false,
                                          label: 'Giới tính',
                                          listItems: itemsGender,
                                          isSearch: false,
                                          selectedValue: seletedGender,
                                          setSelected: (selected) {
                                            seletedGender = selected;
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 25,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                        flex: 4,
                                        child: TextFieldValidatedForm(
                                          label: 'Số người tối đa',
                                          height: 40,
                                          type: 'Number',
                                          controller: capacity,
                                          flexLable: 2,
                                          enter: () {},
                                          requiredValue: 1,
                                        )),
                                    SizedBox(
                                      width: 150,
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Container(),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 25,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    getRule(
                                            listRule.data,
                                            widget.id == null
                                                ? Role.Them
                                                : Role.Sua,
                                            context)
                                        ? Container(
                                            margin: EdgeInsets.only(left: 20),
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  vertical: 20.0,
                                                  horizontal: 10.0,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0),
                                                ),
                                                backgroundColor: Color.fromRGBO(
                                                    245, 117, 29, 1),
                                                primary: Theme.of(context)
                                                    .iconTheme
                                                    .color,
                                                textStyle: Theme.of(context)
                                                    .textTheme
                                                    .caption
                                                    ?.copyWith(
                                                        fontSize: 20.0,
                                                        letterSpacing: 2.0),
                                              ),
                                              onPressed: () async {
                                                if (roomName.text.isEmpty ||
                                                    capacity.text.isEmpty ||
                                                    !isNumber(capacity.text)) {
                                                  showToast(
                                                    context: context,
                                                    msg:
                                                        "Hãy nhập đủ và đúng dữ liệu yêu cầu",
                                                    color: Colors.red,
                                                    icon: Icon(Icons.warning),
                                                  );
                                                } else {
                                                  if (widget.id != null &&
                                                      count > 0 &&
                                                      seletedGender !=
                                                          room['gender']
                                                              .toString()) {
                                                    showToast(
                                                      context: context,
                                                      msg:
                                                          "Hãy xóa thực tập sinh ra khỏi phòng trước khi đổi giới tính",
                                                      color: Colors.red,
                                                      icon: Icon(Icons.warning),
                                                    );
                                                  } else if (widget.id !=
                                                          null &&
                                                      count > 0 &&
                                                      int.parse(capacity.text) <
                                                          count) {
                                                    showToast(
                                                      context: context,
                                                      msg:
                                                          "Số lượng trong phòng đang vượt quá số lượng nhập vào",
                                                      color: Colors.red,
                                                      icon: Icon(Icons.warning),
                                                    );
                                                  } else {
                                                    await submitForm();

                                                    Provider.of<NavigationModel>(
                                                            context,
                                                            listen: false)
                                                        .add(
                                                            pageUrl:
                                                                "/quan-ly-ky-tuc-xa");
                                                  }
                                                }
                                              },
                                              child: Row(
                                                children: [
                                                  Text("Lưu",
                                                      style: textButton),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  ],
                                )
                              ]),
                            ),
                          ]),
                    ),
                    Footer()
                  ],
                );
              } else if (snapshot.hasError) {
                return SelectableText('${snapshot.error}');
              }

              // By default, show a loading spinner.
              return const Center(child: CircularProgressIndicator());
            },
          );
        } else if (listRule.hasError) {
          return SelectableText('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}
