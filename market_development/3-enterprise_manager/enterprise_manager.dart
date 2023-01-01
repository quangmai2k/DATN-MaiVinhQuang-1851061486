import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/toast.dart';
import 'package:gentelella_flutter/model/market_development/user.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/form.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:provider/provider.dart';

import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/market_development/union.dart';
import '../../../../model/market_development/xinghiep.dart';
import '../../../../model/model.dart';

class EnterpriseManager extends StatefulWidget {
  final int? id;
  EnterpriseManager({Key? key, this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EnterpriseManagerState();
  }
}

class _EnterpriseManagerState extends State<EnterpriseManager> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: EnterpriseManagerBody(id: widget.id));
  }
}

class EnterpriseManagerBody extends StatefulWidget {
  int? id;
  EnterpriseManagerBody({Key? key, this.id}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _EnterpriseManagerBodyState();
  }
}

class _EnterpriseManagerBodyState extends State<EnterpriseManagerBody> {
  final String urlAdd = "/them-moi-xi-nghiep";
  int? selectedValueDH;
  TextEditingController _xiNghiepController = TextEditingController();
  var body = {};
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  final TextEditingController textEditingController = TextEditingController();
  List<UnionObj>? listUnionObjectResult = [];
  List<Enterprise>? listEnterpriseResult = [];
  late List<User>? listUser = [];
  bool _setLoading = false;
  bool _setLoading1 = false;
  late Future<List<Enterprise>> _futureListEnterprise;
  Future<List<Enterprise>> getListXiNghiepSearchBy(page, {orgId, companyCode, companyName}) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response;
    Map<String, String> requestParam = Map();
    String condition = "";

    if (companyCode != null) {
      condition += "  ( companyCode~'*$companyCode*'  ";
      condition += "  OR companyName~'*$companyCode*' ) ";
    }
    if (orgId != null) {
      requestParam.putIfAbsent('orgId', () => '$orgId');
      condition += " AND  orgId:$orgId";
    }

    if (condition.isNotEmpty) {
      response = await httpGet("/api/xinghiep/get/page?page=$page&size=$rowPerPage&sort=id,desc&filter=$condition", context);
    } else {
      response = await httpGet("/api/xinghiep/get/page?page=$page&size=$rowPerPage&sort=id,desc", context);
    }

    var body = jsonDecode(response['body']);
    var content = [];

    if (response.containsKey("body")) {
      setState(() {
        currentPage = page + 1;
        content = body['content'];
        rowCount = body["totalElements"];
        totalElements = body["totalElements"];
        lastRow = totalElements;
        listEnterpriseResult = content.map((e) {
          return Enterprise.fromJson(e);
        }).toList();
        if (listEnterpriseResult!.length > 0) {
          // var firstRow = (currentPage) * rowPerPage + 1;
          var lastRow = (currentPage + 1) * rowPerPage;
          if (lastRow > totalElements) {
            lastRow = totalElements;
          }
        }
        // _selected = List<bool>.generate(totalElements, (int index) => false);
      });
    }

    return content.map((e) {
      return Enterprise.fromJson(e);
    }).toList();
  }

  String getUnionByOrgId(List<UnionObj> list, int orgId) {
    for (var item in list) {
      if (item.id.toString() == orgId.toString()) {
        return item.orgName!;
      }
    }
    return "No data!";
  }

  Future<List<UnionObj>> getListUnionSearchBy() async {
    var response;

    response = await httpGet("/api/nghiepdoan/get/page?sort=id", context);

    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        // currentPage = page + 1;
        content = body['content'];
        // rowCount = body["totalElements"];
        // totalElements = body["totalElements"];
        // lastRow = totalElements;
        listUnionObjectResult = content.map((e) {
          return UnionObj.fromJson(e);
        }).toList();
        UnionObj firtsUnionObj = new UnionObj(id: null, orgName: "Tất cả", orgCode: "");
        listUnionObjectResult?.insert(0, firtsUnionObj);
      });
    }

    return content.map((e) {
      return UnionObj.fromJson(e);
    }).toList();
  }

  Future<List<User>> getAllUserIsDaXuatCanhAndTrungTuyen() async {
    var response;

    response = await httpGet("/api/nguoidung/get/page?filter=isTts:1 AND (ttsStatusId:7 OR ttsStatusId:11) AND ttsTrangthai.active:1", context);

    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        // currentPage = page + 1;
        content = body['content'];
        // rowCount = body["totalElements"];
        // totalElements = body["totalElements"];
        // lastRow = totalElements;
        listUser = content.map((e) {
          return User.fromJson(e);
        }).toList();
      });
    }

    return content.map((e) {
      return User.fromJson(e);
    }).toList();
  }

  handleClickBtnSearch({orgId, companyCode, companyName}) {
    print("clicked");
    setState(() {
      _setLoading = true;
    });

    Future<List<Enterprise>> _futureListEnterprise1 = getListXiNghiepSearchBy(0, orgId: orgId, companyCode: companyCode, companyName: companyName);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _futureListEnterprise = _futureListEnterprise1;
        _setLoading = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _futureListEnterprise = getListXiNghiepSearchBy(page - 1);
    initData();
  }

  initData() async {
    setState(() {
      _setLoading1 = false;
    });
    await getListUnionSearchBy();
    await getAllUserIsDaXuatCanhAndTrungTuyen();
    setState(() {
      _setLoading1 = true;
    });
  }

  int countTTSDaXuatCanh(int id, List<User> list) {
    int count = 0;
    for (int i = 0; i < listUser!.length; i++) {
      if (id.toString() == list[i].order?.enterprise?.id.toString() && list[i].ttsStatusId == 11) {
        count++;
      }
    }
    return count;
  }

  int countTTSTrungTuyen(int id, List<User> list) {
    int count = 0;
    for (int i = 0; i < listUser!.length; i++) {
      if (id.toString() == list[i].order?.enterprise?.id.toString() && list[i].ttsStatusId == 7) {
        count++;
      }
    }
    return count;
  }

  String titleLog = '';
  deleteXiNghiep(id) async {
    var response = await httpDelete("/api/xinghiep/del/$id", context);
    print(response);
    var body = jsonDecode(response['body']);
    if (body.containsKey("1")) {
      showToast(context: context, msg: body['1'], color: Colors.green, icon: Icon(Icons.abc));
    } else {
      showToast(context: context, msg: body['0'], color: Colors.red, icon: Icon(Icons.abc));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: userRule('/quan-li-xi-nghiep', context),
        builder: (context, listRule) {
          if (listRule.hasData) {
            return Consumer<NavigationModel>(
                builder: (context, navigationModel, child) => _setLoading1
                    ? FutureBuilder<List<Enterprise>>(
                        future: _futureListEnterprise,
                        builder: (context, snapshot) {
                          return ListView(
                            children: [
                              TitlePage(
                                listPreTitle: [
                                  {'url': '/phat-trien-thi-truong', 'title': 'Dashboard'},
                                  {'url': '/quan-li-xi-nghiep', 'title': 'Quản lý xí nghiệp'}
                                ],
                                content: 'Quản lý xí nghiệp',
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
                                          child: Column(children: [
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
                                            Padding(
                                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        children: [
                                                          Expanded(
                                                            flex: 2,
                                                            child: Text('Nghiệp đoàn', style: titleWidgetBox),
                                                          ),
                                                          Expanded(
                                                            flex: 5,
                                                            child: Container(
                                                              color: Colors.white,
                                                              width: MediaQuery.of(context).size.width * 0.20,
                                                              height: 40,
                                                              child: DropdownSearch<UnionObj>(
                                                                mode: Mode.MENU,
                                                                showSearchBox: true,
                                                                items: listUnionObjectResult!,
                                                                itemAsString: (UnionObj? u) => u!.orgName! + "${u.orgCode!.isNotEmpty ? "(${u.orgCode!})" : ""}",
                                                                selectedItem: listUnionObjectResult!.first,
                                                                dropdownSearchDecoration: styleDropDown,
                                                                emptyBuilder: (context, String? value) {
                                                                  return const Padding(
                                                                    padding: EdgeInsets.symmetric(horizontal: 10),
                                                                    child: Align(alignment: Alignment.center, child: Text("Không có dữ liệu !")),
                                                                  );
                                                                },
                                                                onChanged: (value) {
                                                                  setState(() {
                                                                    selectedValueDH = value?.id;
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 100),
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.start,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Expanded(
                                                            child: TextFieldValidatedMarket(
                                                              type: "None",
                                                              labe: "Xí nghiệp",
                                                              height: 40,
                                                              isReverse: false,
                                                              flexLable: 2,
                                                              flexTextField: 5,
                                                              controller: _xiNghiepController,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(flex: 2, child: Container()),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                                padding: const EdgeInsets.fromLTRB(50, 50, 20, 0),
                                                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                                                  Container(
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
                                                        handleClickBtnSearch(
                                                          orgId: selectedValueDH,
                                                          companyCode: _xiNghiepController.text,
                                                          companyName: _xiNghiepController.text,
                                                        );
                                                      },
                                                      icon: Transform.rotate(
                                                        angle: 270,
                                                        child: Icon(
                                                          Icons.search,
                                                          color: Colors.white,
                                                          size: 15,
                                                        ),
                                                      ),
                                                      label: Row(
                                                        children: [
                                                          Text('Tìm kiếm ', style: textButton),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  getRule(listRule.data, Role.Xem, context)
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
                                                              navigationModel.add(pageUrl: urlAdd);
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
                                                ])),
                                          ])),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 1,
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
                                                  'Danh sách xí nghiệp',
                                                  style: titleBox,
                                                ),
                                                Icon(
                                                  Icons.more_horiz,
                                                  color: colorIconTitleBox,
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
                                            //coding
                                            if (snapshot.hasData)
                                              //Start Datatable
                                              Row(
                                                children: [
                                                  Expanded(child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                                                    return Center(
                                                        child: SingleChildScrollView(
                                                      scrollDirection: Axis.horizontal,
                                                      child: ConstrainedBox(
                                                        constraints: BoxConstraints(minWidth: constraints.maxWidth),
                                                        child: DataTable(
                                                          columnSpacing: 5,
                                                          dataTextStyle: const TextStyle(color: Color(0xff313131), fontSize: 14, fontWeight: FontWeight.w500),
                                                          showBottomBorder: true,
                                                          dataRowHeight: 60,
                                                          showCheckboxColumn: false,
                                                          dataRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                                                            if (states.contains(MaterialState.selected)) {
                                                              return MaterialStateColor.resolveWith((states) => const Color(0xffeef3ff));
                                                            }
                                                            return MaterialStateColor.resolveWith((states) => Colors.white); // Use the default value.
                                                          }),
                                                          columns: <DataColumn>[
                                                            DataColumn(
                                                              label: Text(
                                                                'STT',
                                                                style: titleTableData,
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: Text(
                                                                'Mã xí nghiệp',
                                                                style: titleTableData,
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: Text(
                                                                'Tên xí nghiệp',
                                                                style: titleTableData,
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: Text(
                                                                'Nghiệp đoàn',
                                                                style: titleTableData,
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: Flexible(
                                                                child: Text(
                                                                  'Số TTS \ntrúng tuyển',
                                                                  style: titleTableData,
                                                                ),
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: Flexible(
                                                                child: Text(
                                                                  'Số TTS \nxuất cảnh',
                                                                  style: titleTableData,
                                                                ),
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: Text(
                                                                'Hành động',
                                                                style: titleTableData,
                                                              ),
                                                            ),
                                                          ],
                                                          rows: <DataRow>[
                                                            for (int i = 0; i < listEnterpriseResult!.length; i++)
                                                              DataRow(
                                                                cells: <DataCell>[
                                                                  DataCell(Container(
                                                                      width: (MediaQuery.of(context).size.width / 10) * 0.15,
                                                                      child: Text("${(currentPage - 1) * rowPerPage + i + 1}"))),
                                                                  DataCell(Container(child: Text(listEnterpriseResult![i].companyCode))),
                                                                  DataCell(
                                                                    Text(listEnterpriseResult![i].companyName).toString().length < 90
                                                                        ? Container(
                                                                            width: 200,
                                                                            child: Text(listEnterpriseResult![i].companyName),
                                                                          )
                                                                        : ConstrainedBox(
                                                                            constraints: BoxConstraints(maxWidth: 200),
                                                                            child: Text(listEnterpriseResult![i].companyName, overflow: TextOverflow.ellipsis),
                                                                          ),
                                                                  ),
                                                                  DataCell(Text(getUnionByOrgId(listUnionObjectResult!, listEnterpriseResult![i].orgId))),
                                                                  DataCell(Center(
                                                                    child: Text(countTTSTrungTuyen(listEnterpriseResult![i].id, listUser!).toString()),
                                                                  )),
                                                                  DataCell(Center(
                                                                    child: Text(countTTSDaXuatCanh(listEnterpriseResult![i].id, listUser!).toString()),
                                                                  )),
                                                                  DataCell(Row(
                                                                    children: [
                                                                      getRule(listRule.data, Role.Xem, context)
                                                                          ? Container(
                                                                              margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                              child: InkWell(
                                                                                onTap: () {
                                                                                  navigationModel.add(pageUrl: "/xem-chi-tiet-xi-nghiep/" + listEnterpriseResult![i].id.toString());
                                                                                },
                                                                                child: Icon(Icons.visibility),
                                                                              ),
                                                                            )
                                                                          : Container(),
                                                                      getRule(listRule.data, Role.Sua, context)
                                                                          ? Container(
                                                                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                              child: InkWell(
                                                                                  onTap: () {
                                                                                    navigationModel.add(pageUrl: "/cap-nhat-xi-nghiep/${listEnterpriseResult![i].id}");
                                                                                  },
                                                                                  child: Icon(
                                                                                    Icons.edit_calendar,
                                                                                    color: Color(0xff009C87),
                                                                                  )))
                                                                          : Container(),
                                                                      getRule(listRule.data, Role.Xoa, context)
                                                                          ? Container(
                                                                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                              child: InkWell(
                                                                                  onTap: () async {
                                                                                    showDialog(
                                                                                      context: context,
                                                                                      builder: (BuildContext context) => XacNhanXoaXiNghiep(
                                                                                        label: "Bạn có muốn xóa xí nghiệp này ?",
                                                                                        function: () async {
                                                                                          await deleteXiNghiep(listEnterpriseResult![i].id);
                                                                                          await handleClickBtnSearch();
                                                                                        },
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                  child: Icon(
                                                                                    Icons.delete_outlined,
                                                                                    color: Colors.red,
                                                                                  )))
                                                                          : Container(),
                                                                    ],
                                                                  )),
                                                                ],
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                    ));
                                                  }))
                                                ],
                                              )
                                            else if (snapshot.hasError)
                                              Text("Fail! ${snapshot.error}")
                                            else if (!snapshot.hasData)
                                              Center(
                                                child: CircularProgressIndicator(),
                                              ),
                                            //End Datatable
                                            Container(
                                              margin: const EdgeInsets.only(right: 50),
                                              child: DynamicTablePagging(
                                                rowCount,
                                                currentPage,
                                                rowPerPage,
                                                pageChangeHandler: (page) {
                                                  setState(() {
                                                    getListXiNghiepSearchBy(page - 1,
                                                        orgId: selectedValueDH, companyCode: _xiNghiepController.text, companyName: _xiNghiepController.text);
                                                    //currentPage = page - 1;
                                                  });
                                                },
                                                rowPerPageChangeHandler: (rowPerPage) {
                                                  setState(() {
                                                    this.rowPerPage = rowPerPage!;
                                                    //coding
                                                    this.firstRow = page * currentPage;
                                                    print('pk ${rowPerPage}');
                                                    getListXiNghiepSearchBy(0,
                                                        orgId: selectedValueDH, companyCode: _xiNghiepController.text, companyName: _xiNghiepController.text);
                                                  });
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Footer(),
                                    ],
                                  )),
                            ],
                          );
                        },
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ));
          } else if (listRule.hasError) {
            return Text('${listRule.error}');
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}

class XacNhanXoaXiNghiep extends StatefulWidget {
  Function function;
  String? title;
  String? label;
  String? labelBtnOrange;
  String? labelBtnBlue;
  XacNhanXoaXiNghiep({Key? key, required this.function, this.label, this.labelBtnOrange, this.title}) : super(key: key);
  @override
  State<XacNhanXoaXiNghiep> createState() => _XacNhanXoaXiNghiepState();
}

class _XacNhanXoaXiNghiepState extends State<XacNhanXoaXiNghiep> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  child: Image.asset('assets/images/logoAAM.png'),
                  margin: EdgeInsets.only(right: 10),
                ),
                Text(
                  widget.title != null ? widget.title! : "Xác nhận xóa ?",
                  style: titleAlertDialog,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
          ),
        ],
      ),
      content: Container(
        height: 100,
        width: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.all(0),
              child: Divider(
                thickness: 1,
              ),
            ),
            Text(
              widget.label != null ? widget.label! : "Bạn có chắc chắn muốn hủy chức năng này?",
            ),
            Padding(
              padding: const EdgeInsets.all(0),
              child: Divider(
                thickness: 1,
              ),
            ),
          ],
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Hủy'),
          style: ElevatedButton.styleFrom(
            primary: widget.labelBtnOrange != null ? Colors.white : colorOrange,
            onPrimary: widget.labelBtnOrange != null ? Colors.black : colorWhite,
            elevation: 3,
            minimumSize: Size(140, 50),
            // maximumSize: Size(140, 50), //////// HERE
          ),
        ),
        ElevatedButton(
          // textColor: Color(0xFF6200EE),
          onPressed: () async {
            widget.function();
            Navigator.pop(context);
          },
          child: Text(
            widget.labelBtnOrange != null ? 'Đã gửi' : 'Đồng ý',
            style: TextStyle(),
          ),
          style: ElevatedButton.styleFrom(
            primary: colorBlueBtnDialog,
            onPrimary: colorWhite,
            // shadowColor: Colors.greenAccent,
            elevation: 3,
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(32.0)),
            minimumSize: Size(140, 50), //////// HERE
          ),
        ),
      ],
    );
  }
}
