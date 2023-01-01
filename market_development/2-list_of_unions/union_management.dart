import 'dart:convert';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/toast.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import 'package:gentelella_flutter/model/market_development/nation.dart';
import 'package:gentelella_flutter/model/market_development/union.dart';
import 'package:gentelella_flutter/model/market_development/user.dart';
import 'package:gentelella_flutter/widgets/ui/market_development/3-enterprise_manager/enterprise_manager.dart';
import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../model/model.dart';
import '../../../forms/market_development/utils/form.dart';
import '../../navigation.dart';

class UnionManager extends StatefulWidget {
  final List<String>? pathSegments;
  SecurityModel? securityModel;
  UnionManager({Key? key, this.pathSegments, this.securityModel}) : super(key: key);

  @override
  _StateUnionManager createState() => _StateUnionManager();
}

class _StateUnionManager extends State<UnionManager> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: UnionManagerBody(
      securityModel: widget.securityModel,
    ));
  }
}

class UnionManagerBody extends StatefulWidget {
  SecurityModel? securityModel;
  UnionManagerBody({Key? key, this.securityModel}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _UnionManagerBodyState();
  }
}

class _UnionManagerBodyState extends State<UnionManagerBody> {
  int? selectedValueDH;
  final String urlAdd = "/them-moi-nghiep-doan";
  final String urlUnionDetail = "/xem-chi-tiet-nghiep-doan";
  Map<int, String> _mapStatusofUnion = {
    -1: ' Tất cả',
    1: ' Cần tiếp cận',
    2: ' Đang tiếp cận',
    3: ' Đã ký hợp đồng',
  };
  List<bool> _selected = [];
  late Future<List<UnionObj>> _futureListUnion;

  var listUnionResult = [];
  List<UnionObj> listUnionObjectResult = [];
  List<Nation> listNationResult = [];
  List<User> listUserResult = [];
  var body = {};
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  bool _setLoading = false;
  Future<List<UnionObj>> getListUnionSearchBy(page, {nameUnion, orgCode, contractStatus}) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response;

    String condition = "";
    if (nameUnion != null) {
      condition += " ( orgName~'*$nameUnion*'";
      condition += " OR orgCode~'*$orgCode*' ) ";
      // requestParam.putIfAbsent('orgCode', () => '$nameUnion');
    }

    if (contractStatus != null) {
      if (contractStatus != -1) {
        condition += " AND contractStatus:$contractStatus";
      }
    }

    String conditionByDepart = "";
    try {
      if (widget.securityModel != null) {
        if (widget.securityModel!.userLoginCurren != null) {
          if (widget.securityModel!.userLoginCurren['teamId'] != null) {
            conditionByDepart += " departId:${widget.securityModel!.userLoginCurren['teamId']}";
          } else {
            conditionByDepart = "";
          }
        }
      }
    } catch (e) {
      print(e);
    }
    if (condition.isNotEmpty) {
      if (conditionByDepart.isNotEmpty) {
        response = await httpGet("/api/nghiepdoan/get/page?page=$page&size=$rowPerPage&filter=$condition AND $conditionByDepart", context);
      } else {
        response = await httpGet("/api/nghiepdoan/get/page?page=$page&size=$rowPerPage&filter=$condition", context);
      }
    } else {
      if (conditionByDepart.isNotEmpty) {
        response = await httpGet("/api/nghiepdoan/get/page?page=$page&size=$rowPerPage&sort=id,desc&filter=$conditionByDepart", context);
      } else {
        response = await httpGet("/api/nghiepdoan/get/page?page=$page&size=$rowPerPage", context);
      }
    }
    var body = jsonDecode(response['body']);
    var content = [];

    if (response.containsKey("body")) {
      setState(() {
        currentPage = page + 1;
        content = body['content'];

        totalElements = body["totalElements"];
        lastRow = totalElements;
        rowCount = totalElements;
        listUnionObjectResult = content.map((e) {
          return UnionObj.fromJson(e);
        }).toList();
        if (listUnionObjectResult.length > 0) {
          // var firstRow = (currentPage) * rowPerPage + 1;
          var lastRow = (currentPage + 1) * rowPerPage;
          if (lastRow > totalElements) {
            lastRow = totalElements;
          }
        }
        _selected = List<bool>.generate(totalElements, (int index) => false);
      });
    }

    return content.map((e) {
      return UnionObj.fromJson(e);
    }).toList();
  }

  Future getAllNation() async {
    var response = await httpGet("/api/quocgia/get/page", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];

        listNationResult = content.map((e) {
          return Nation.fromJson(e);
        }).toList();
      });
    }
  }

  Future getAllUser() async {
    var response = await httpGet("/api/nguoidung/get/page?filter=active:1 AND isBlocked:0 AND isAam:1", context);
    var body = jsonDecode(response['body']);
    var content = [];

    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
        listUserResult = content.map((e) {
          return User.fromJson(e);
        }).toList();
      });
    }
  }

  String getNameByCountryCode(List<Nation> listNation, String countryCode) {
    for (int i = 0; i < listNation.length; i++) {
      if (countryCode == listNation[i].countryCode) return listNation[i].name;
    }
    return "Không có trong quốc gia";
  }

  String getUserNameByAamSale(List<User> listUser, String aamSale) {
    for (int i = 0; i < listUser.length; i++) {
      if (aamSale == listUser[i].id.toString()) return listUser[i].fullName;
    }
    return "No data!";
  }

  String getStatusNameByStatus(int status) {
    String statusName = "";
    switch (status) {
      case -1:
        {
          statusName = "Tất cả";
        }
        break;
      case 0:
        {
          statusName = "Dừng hợp tác";
        }
        break;
      case 1:
        {
          statusName = "Cần tiếp cận";
        }
        break;
      case 2:
        {
          statusName = "Đang tiếp cận";
        }
        break;
      case 3:
        {
          statusName = "Đã ký hợp đồng";
        }
        break;

      default:
        {}
        break;
    }
    return statusName;
  }

  handleClickBtnSearch({nameUnion, orgCode, contractStatus}) {
    setState(() {
      _setLoading = true;
    });

    Future<List<UnionObj>> _futureListUnion1 = getListUnionSearchBy(0, nameUnion: _nameUnionController.text, orgCode: _nameUnionController.text, contractStatus: selectedValueDH);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _futureListUnion = _futureListUnion1;
        _setLoading = false;
      });
    });
  }

  // String titleLog = '';
  deleteNghiepDoan(id) async {
    var response = await httpDelete("/api/nghiepdoan/del/$id", context);

    var body = jsonDecode(response['body']);
    if (body.containsKey("1")) {
      print(body.containsKey);
      showToast(context: context, msg: body['1'], color: Colors.green, icon: Icon(Icons.abc));
    } else {
      showToast(context: context, msg: body['0'], color: Colors.red, icon: Icon(Icons.abc));
    }
  }

  TextEditingController _nameUnionController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _futureListUnion = getListUnionSearchBy(page - 1, nameUnion: "", orgCode: "", contractStatus: -1);
    getAllNation();
    getAllUser();
  }

  @override
  Widget build(BuildContext context) {
    var consumer = Consumer<NavigationModel>(
        builder: (context, navigationModel, child) => FutureBuilder<dynamic>(
              future: userRule('/quan-li-nghiep-doan', context),
              builder: (context, listRule) {
                if (listRule.hasData) {
                  return FutureBuilder<List<UnionObj>>(
                      future: _futureListUnion,
                      builder: (context, snapshot) {
                        return ListView(
                          children: [
                            TitlePage(
                              listPreTitle: [
                                {'url': '/phat-trien-thi-truong', 'title': 'Dashboard'},
                                {'url': '/quan-li-nghiep-doan', 'title': 'Quản lý nghiệp đoàn'}
                              ],
                              content: 'Quản lý nghiệp đoàn',
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
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Expanded(
                                                          child: TextFieldValidatedMarket(
                                                            type: "None",
                                                            labe: "Nghiệp đoàn",
                                                            isReverse: false,
                                                            flexLable: 2,
                                                            flexTextField: 5,
                                                            marginBottom: 0,
                                                            controller: _nameUnionController,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(),
                                                  flex: 1,
                                                ),
                                                Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.start,
                                                      children: [
                                                        Expanded(
                                                          flex: 2,
                                                          child: Text('Trạng thái nghiệp đoàn', style: titleWidgetBox),
                                                        ),
                                                        Expanded(
                                                          flex: 5,
                                                          child: Container(
                                                            // width: MediaQuery.of(context).size.width * 0.15,
                                                            height: 40,
                                                            child: DropdownButtonHideUnderline(
                                                              child: DropdownButton2(
                                                                buttonDecoration: BoxDecoration(border: Border.all(width: 0.5, style: BorderStyle.solid)),
                                                                buttonPadding: EdgeInsets.only(left: 8),
                                                                hint: Text('${_mapStatusofUnion[-1]}', style: TextStyle(fontSize: 16, color: Theme.of(context).hintColor)),
                                                                items: _mapStatusofUnion.entries
                                                                    .map((item) =>
                                                                        DropdownMenuItem<int>(value: item.key, child: Text(item.value, style: const TextStyle(fontSize: 16))))
                                                                    .toList(),
                                                                value: selectedValueDH,
                                                                onChanged: (value) {
                                                                  setState(() {
                                                                    selectedValueDH = value as int?;
                                                                  });
                                                                },
                                                                buttonHeight: 40,
                                                                itemHeight: 40,
                                                              ),
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
                                                          nameUnion: _nameUnionController.text, orgCode: _nameUnionController.text, contractStatus: selectedValueDH);
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
                                                getRule(listRule.data, Role.Them, context)
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
                                                'Danh sách nghiệp đoàn',
                                                style: titleBox,
                                              ),
                                              Text(
                                                'Kết quả tìm kiếm nghiệp đoàn : $totalElements',
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
                                          if (snapshot.hasData)
                                            //Start Datatable
                                            !_setLoading
                                                ? Row(
                                                    children: [
                                                      Expanded(child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                                                        return Center(
                                                            child: SingleChildScrollView(
                                                          scrollDirection: Axis.horizontal,
                                                          child: ConstrainedBox(
                                                            constraints: BoxConstraints(minWidth: constraints.maxWidth),
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
                                                              columns: <DataColumn>[
                                                                DataColumn(
                                                                  label: Text(
                                                                    'STT',
                                                                    style: titleTableData,
                                                                  ),
                                                                ),
                                                                DataColumn(
                                                                  label: Text(
                                                                    'Mã nghiệp đoàn',
                                                                    style: titleTableData,
                                                                  ),
                                                                ),
                                                                DataColumn(
                                                                  label: Text(
                                                                    'Tên nghiệp đoàn',
                                                                    style: titleTableData,
                                                                  ),
                                                                ),
                                                                DataColumn(
                                                                  label: Text(
                                                                    'Quốc gia',
                                                                    style: titleTableData,
                                                                  ),
                                                                ),
                                                                DataColumn(
                                                                  label: Text(
                                                                    'Người đại diện',
                                                                    style: titleTableData,
                                                                  ),
                                                                ),
                                                                DataColumn(
                                                                  label: Text(
                                                                    'Nhân viên AAM',
                                                                    style: titleTableData,
                                                                  ),
                                                                ),
                                                                DataColumn(
                                                                  label: Text(
                                                                    'Trạng thái\n nghiệp đoàn',
                                                                    style: titleTableData,
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
                                                                for (int i = 0; i < listUnionObjectResult.length; i++)
                                                                  DataRow(
                                                                    cells: <DataCell>[
                                                                      DataCell(
                                                                        Container(
                                                                          width: (MediaQuery.of(context).size.width / 10) * 0.2,
                                                                          child: Text("${(currentPage - 1) * rowPerPage + i + 1}"),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        Container(
                                                                          width: (MediaQuery.of(context).size.width / 10) * 0.8,
                                                                          child: Text(
                                                                            listUnionObjectResult[i].orgCode!,
                                                                            softWrap: true,
                                                                            overflow: TextOverflow.ellipsis,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        Container(
                                                                          width: (MediaQuery.of(context).size.width / 10) * 1,
                                                                          child: Text(listUnionObjectResult[i].orgName!),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        Container(
                                                                          width: (MediaQuery.of(context).size.width / 10) * 0.6,
                                                                          child: Text(
                                                                            getNameByCountryCode(listNationResult, listUnionObjectResult[i].countryCode!),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        Container(
                                                                          width: (MediaQuery.of(context).size.width / 10) * 1,
                                                                          child: Text(listUnionObjectResult[i].deputy!),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        Container(
                                                                          width: (MediaQuery.of(context).size.width / 10) * 1,
                                                                          child: Text(
                                                                            getUserNameByAamSale(listUserResult, listUnionObjectResult[i].aamSale.toString()),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataCell(
                                                                        Container(
                                                                          width: (MediaQuery.of(context).size.width / 10) * 1,
                                                                          child: Text(
                                                                            getStatusNameByStatus(listUnionObjectResult[i].contractStatus!),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      DataCell(Row(
                                                                        children: [
                                                                          getRule(listRule.data, Role.Xem, context)
                                                                              ? Container(
                                                                                  margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                                  child: InkWell(
                                                                                    onTap: () {
                                                                                      navigationModel.add(pageUrl: urlUnionDetail + "/" + listUnionObjectResult[i].id.toString());
                                                                                    },
                                                                                    child: Icon(Icons.visibility),
                                                                                  ),
                                                                                )
                                                                              : Container(),
                                                                          getRule(listRule.data, Role.Sua, context)
                                                                              ? Container(
                                                                                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                                  child: Tooltip(
                                                                                    message: listUnionObjectResult[i].contractStatus != 3 ? "" : "Đã ký hợp đồng",
                                                                                    child: InkWell(
                                                                                        onTap: () {
                                                                                          navigationModel.add(pageUrl: "/cap-nhat-nghiep-doan/${listUnionObjectResult[i].id}");
                                                                                        },
                                                                                        child: Icon(
                                                                                          Icons.edit_calendar,
                                                                                          color: Color(0xff009C87),
                                                                                        )),
                                                                                  ))
                                                                              : Container(),
                                                                          getRule(listRule.data, Role.Sua, context)
                                                                              ? Container(
                                                                                  margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                                  child: InkWell(
                                                                                      onTap: () async {
                                                                                        showDialog(
                                                                                          context: context,
                                                                                          builder: (BuildContext context) => XacNhanXoaXiNghiep(
                                                                                            label: "Bạn có muốn xóa nghiệp đoàn này ?",
                                                                                            function: () async {
                                                                                              await deleteNghiepDoan(listUnionObjectResult[i].id);
                                                                                              handleClickBtnSearch();
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
                                                                    selected: _selected[i],
                                                                    onSelectChanged: (bool? value) {
                                                                      setState(() {
                                                                        _selected[i] = value!;
                                                                      });
                                                                    },
                                                                  ),
                                                              ],
                                                            ),
                                                          ),
                                                        ));
                                                      }))
                                                    ],
                                                  )
                                                : Center(
                                                    child: CircularProgressIndicator(),
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
                                                  getListUnionSearchBy(page - 1, nameUnion: _nameUnionController.text, contractStatus: selectedValueDH);
                                                  // currentPage = page - 1;
                                                });
                                              },
                                              rowPerPageChangeHandler: (rowPerPage) {
                                                setState(() {
                                                  this.rowPerPage = rowPerPage!;
                                                  //coding
                                                  this.firstRow = page * currentPage;

                                                  getListUnionSearchBy(0, nameUnion: _nameUnionController.text, contractStatus: selectedValueDH);
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
                      });
                } else if (listRule.hasError) {
                  return Text('${listRule.error}');
                } // By default, show a loading spinner.
                return Center(child: CircularProgressIndicator());
              },
            ));
    return consumer;
  }
}
