import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/form.dart';
import 'package:gentelella_flutter/widgets/ui/market_development/3-enterprise_manager/enterprise_manager.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../model/market_development/job.dart';
import '../../../../model/model.dart';
import 'dart:async';

class CareerManager extends StatefulWidget {
  const CareerManager({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CareerManagerState();
  }
}

class _CareerManagerState extends State<CareerManager> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: CareerManagerBody());
  }
}

class CareerManagerBody extends StatefulWidget {
  const CareerManagerBody({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CareerManagerBodyState();
  }
}

class _CareerManagerBodyState extends State<CareerManagerBody> {
  final String urlAdd = "/them-moi-nganh-nghe";
  final String urlJobDetail = "/quan-li-nganh-nghe/chi-tiet";
  var body = {};
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  bool _setLoading = false;
  TextEditingController titleController = TextEditingController();
  List<Jobs> listJobsResult = [];
  late Future<List<Jobs>> futureListJobs;
  Future<List<Jobs>> getListJobSearchBy(page, {tilte}) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response;
    String condition = "";
    if (tilte != null) {
      condition += "jobName~'*$tilte*'";
    }
    response = await httpGet("/api/nganhnghe/get/page?page=$page&size=$rowPerPage&filter=${condition}", context);

    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        currentPage = page + 1;
        content = body['content'];
        rowCount = body["totalElements"];
        totalElements = body["totalElements"];
        lastRow = totalElements;
        listJobsResult = content.map((e) {
          return Jobs.fromJson(e);
        }).toList();
      });
    }

    return content.map((e) {
      return Jobs.fromJson(e);
    }).toList();
  }

  handleClickBtnSearch({title}) {
    print("clicked");
    setState(() {
      _setLoading = true;
    });

    Future<List<Jobs>> _futureListEnterprise1 = getListJobSearchBy(0, tilte: title);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        futureListJobs = _futureListEnterprise1;
        _setLoading = false;
      });
    });
  }

  deleteNganhNghe(id) async {
    var response = await httpDelete("/api/nganhnghe/del/$id", context);
    print(response);
    var body = jsonDecode(response['body']);
    if (body.containsKey("1")) {
      showToast(context: context, msg: body['1'], color: Colors.green, icon: Icon(Icons.abc));
    } else {
      showToast(context: context, msg: body['0'], color: Colors.red, icon: Icon(Icons.abc));
    }
  }

  void initState() {
    super.initState();
    futureListJobs = getListJobSearchBy(page - 1);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: userRule('/quan-li-nganh-nghe', context),
        builder: (context, listRule) {
          if (listRule.hasData) {
            return Consumer<NavigationModel>(
                builder: (context, navigationModel, child) => FutureBuilder<List<Jobs>>(
                    future: futureListJobs,
                    builder: (context, snapshot) {
                      return ListView(
                        children: [
                          TitlePage(
                            listPreTitle: [
                              {'url': '/phat-trien-thi-truong', 'title': 'Dashboard'},
                              {'url': '/quan-li-nganh-nghe', 'title': 'Quản lý ngành nghề'}
                            ],
                            content: 'Quản lý ngành nghề',
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
                                                flex: 3,
                                                child: Container(
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Expanded(
                                                        flex: 3,
                                                        child: TextFieldValidatedMarket(
                                                            type: "None",
                                                            labe: "Tiêu đề",
                                                            isReverse: false,
                                                            flexLable: 2,
                                                            flexTextField: 6,
                                                            marginBottom: 0,
                                                            controller: titleController),
                                                      ),
                                                      Expanded(
                                                        flex: 1,
                                                        child: Container(),
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
                                                    handleClickBtnSearch(title: titleController.text);
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
                                              'Danh sách ngành nghề',
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
                                        if (snapshot.hasError)
                                          Text('${snapshot.error}')
                                        else if (snapshot.hasData)
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
                                                                    columnSpacing: 5,
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
                                                                          'Tiêu đề',
                                                                          style: titleTableData,
                                                                        ),
                                                                      ),
                                                                      DataColumn(
                                                                        label: Text(
                                                                          'Mô tả',
                                                                          style: titleTableData,
                                                                        ),
                                                                      ),
                                                                      DataColumn(
                                                                        label: Text(
                                                                          'Hành động',
                                                                          style: titleTableData,
                                                                        ),
                                                                      )
                                                                    ],
                                                                    rows: <DataRow>[
                                                                      for (int i = 0; i < listJobsResult.length; i++)
                                                                        DataRow(
                                                                          cells: <DataCell>[
                                                                            DataCell(
                                                                              Container(
                                                                                width: (MediaQuery.of(context).size.width / 10) * 1,
                                                                                child: Text("${(currentPage - 1) * rowPerPage + i + 1}"),
                                                                              ),
                                                                            ),
                                                                            DataCell(
                                                                              Container(
                                                                                width: (MediaQuery.of(context).size.width / 10) * 1,
                                                                                child: Text(listJobsResult[i].jobName != null ? listJobsResult[i].jobName! : "Không có dữ liệu"),
                                                                              ),
                                                                            ),
                                                                            DataCell(
                                                                              Container(
                                                                                width: (MediaQuery.of(context).size.width / 10) * 2,
                                                                                child: Tooltip(
                                                                                    height: 30,
                                                                                    message: listJobsResult[i].description,
                                                                                    verticalOffset: 100,
                                                                                    child: ConstrainedBox(
                                                                                      constraints: BoxConstraints(maxWidth: 200),
                                                                                      child: Text(
                                                                                        listJobsResult[i].description != null ? listJobsResult[i].description! : "Không có mô tả",
                                                                                        overflow: TextOverflow.ellipsis,
                                                                                        maxLines: 3,
                                                                                      ),
                                                                                    )),
                                                                              ),
                                                                            ),
                                                                            DataCell(
                                                                              Row(
                                                                                children: [
                                                                                  getRule(listRule.data, Role.Xem, context)
                                                                                      ? Container(
                                                                                          margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                                          child: InkWell(
                                                                                            onTap: () {
                                                                                              navigationModel.add(
                                                                                                  pageUrl: "/xem-chi-tiet-nganh-nghe/" + listJobsResult[i].id.toString());
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
                                                                                                navigationModel.add(pageUrl: "/cap-nhat-nganh-nghe/${listJobsResult[i].id}");
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
                                                                                                    label: "Bạn có muốn xóa ngành nghề này ?",
                                                                                                    function: () async {
                                                                                                      await deleteNganhNghe(listJobsResult[i].id);
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
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                    ],
                                                                  ))));
                                                    })),
                                                  ],
                                                )
                                              : Center(
                                                  child: CircularProgressIndicator(),
                                                )
                                        else
                                          Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        //End Datatable
                                        Container(
                                          // margin: const EdgeInsets.only(right: 50),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Expanded(
                                                child: DynamicTablePagging(
                                                  rowCount,
                                                  currentPage,
                                                  rowPerPage,
                                                  pageChangeHandler: (page) {
                                                    setState(() {
                                                      getListJobSearchBy(page - 1, tilte: titleController.text);
                                                    });
                                                  },
                                                  rowPerPageChangeHandler: (rowPerPage) {
                                                    setState(() {
                                                      this.rowPerPage = rowPerPage!;
                                                      //coding
                                                      this.firstRow = page * currentPage;

                                                      getListJobSearchBy(0, tilte: titleController.text);
                                                      // getListXiNghiepSearchBy(page - 1);
                                                    });
                                                  },
                                                ),
                                              ),
                                            ],
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
                    }));
          } else if (listRule.hasError) {
            return Text('${listRule.error}');
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
