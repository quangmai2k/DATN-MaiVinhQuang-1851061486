import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';

import 'package:provider/provider.dart';

import '../../../../../common/style.dart';
import '../../../../../model/model.dart';
import '../../../../api.dart';
import '../../../../model/market_development/job.dart';
import '../../../../model/market_development/union.dart';
import '../../../../model/market_development/xinghiep.dart';

class EnterpriseManagerDetail extends StatefulWidget {
  final int? id;
  EnterpriseManagerDetail({Key? key, this.id}) : super(key: key);

  @override
  State<EnterpriseManagerDetail> createState() => _EnterpriseManagerDetailState();
}

class _EnterpriseManagerDetailState extends State<EnterpriseManagerDetail> {
  DateTime selectedDate = DateTime.now();

  Map<String, bool> listCheckBoxValue = {
    'Override default configurations': false,
    'Override Base Url': false,
  };

  List<UnionObj>? listUnionObjectResult = [];
  String? tenQuocGia;
  Enterprise enterprise = new Enterprise(id: -1, companyCode: "", companyName: "", orgId: -1, address: "", job: "", description: "", status: -1, createdUser: 0, createdDate: "");
  getEnterpriseDetailById(int id) async {
    var response = await httpGet("/api/xinghiep/get/$id", context);
    var body = jsonDecode(response['body']);

    if (response.containsKey("body")) {
      setState(() {
        enterprise = Enterprise.fromJson(body);
        tenQuocGia = body['quocgia'] != null
            ? body['quocgia']['name'] != null
                ? body['quocgia']['name']
                : ""
            : "";
      });
    }
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
        // print("thaida ${listUnionObjectResult.toString()}");
      });
    }

    return content.map((e) {
      return UnionObj.fromJson(e);
    }).toList();
  }

  List<Jobs> listJobsResult = [];
  Future getListJobSearchBy() async {
    try {
      var response;
      if (enterprise.job.isEmpty) {
        return;
      }
      response = await httpGet("/api/nganhnghe/get/page?sort=id&filter=id in (${enterprise.job})", context);
      var body = jsonDecode(response['body']);
      var content = [];
      if (response.containsKey("body")) {
        setState(() {
          content = body['content'];

          listJobsResult = content.map((e) {
            return Jobs.fromJson(e);
          }).toList();
        });
      }
    } catch (e) {
      print(e);
    }
  }

  String getNameByListJob(List<Jobs> list) {
    String t = "";
    for (int i = 0; i < list.length; i++) {
      if (i == 0) {
        t += "- " + list[i].jobName! + "\n";
      } else {
        t += "- ${list[i].jobName} \n";
      }
    }
    return t;
  }

  getUnionNameByOrgId(List<UnionObj> list, int id) {
    for (int i = 0; i < list.length; i++) {
      if (id.toString() == list[i].id.toString()) {
        return list[i].orgName;
      }
    }
    return "No data!";
  }

  @override
  void initState() {
    super.initState();
    initData();
    //getListUnionSearchBy().then((value) => getEnterpriseDetailById(widget.id!)).then((value) => getListJobSearchBy());
  }

  bool _isSetLoading = false;
  initData() async {
    await getListUnionSearchBy();
    await getEnterpriseDetailById(widget.id!);
    await getListJobSearchBy();
    setState(() {
      _isSetLoading = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: Consumer<NavigationModel>(
            builder: (context, navigationModel, child) => ListView(
                  children: [
                    TitlePage(
                      listPreTitle: [
                        {'url': '/phat-trien-thi-truong', 'title': 'Dashboard'},
                        {'url': '/quan-li-xi-nghiep', 'title': 'Quản lý xí nghiệp'}
                      ],
                      content: 'Quản lý xí nghiệp',
                    ),
                    Container(
                      padding: paddingBoxContainer,
                      margin: marginBoxFormTab,
                      width: MediaQuery.of(context).size.width * 1,
                      decoration: BoxDecoration(
                        color: colorWhite,
                        borderRadius: borderRadiusContainer,
                        boxShadow: [boxShadowContainer],
                        border: borderAllContainerBox,
                      ),
                      child: _isSetLoading
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Thông tin xí nghiệp',
                                      style: titleBox,
                                    ),
                                    Icon(
                                      Icons.more_horiz,
                                      color: colorIconTitleBox,
                                      size: sizeIconTitleBox,
                                    ),
                                  ],
                                ),
                                //--------------Đường line-------------
                                Container(
                                  child: Divider(
                                    thickness: 1,
                                    color: ColorHorizontalLine,
                                  ),
                                ),
                                //------------kết thúc đường line-------
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: Container(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(top: 30),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                        "Xí nghiệp: ",
                                                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                        enterprise.companyName,
                                                        style: TextStyle(fontSize: 17),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(top: 50),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                        "Nghiệp đoàn: ",
                                                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                        getUnionNameByOrgId(listUnionObjectResult!, enterprise.orgId),
                                                        style: TextStyle(fontSize: 17),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Container(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(top: 30),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                        "Địa chỉ: ",
                                                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                        enterprise.address,
                                                        style: TextStyle(fontSize: 17),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.only(top: 50),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Text(
                                                        "Quốc gia: ",
                                                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                        tenQuocGia.toString(),
                                                        style: TextStyle(fontSize: 17),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 50),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              "Ngành nghề: ",
                                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (listJobsResult.isNotEmpty)
                                        Container(
                                          margin: EdgeInsets.only(top: 30),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Container(),
                                              ),
                                              Expanded(
                                                flex: 9,
                                                child: Table(
                                                  // defaultColumnWidth: FixedColumnWidth(120.0),
                                                  columnWidths: {
                                                    0: FixedColumnWidth(40.0), // fixed to 100 width
                                                    1: FlexColumnWidth(),
                                                  },
                                                  border: TableBorder.all(
                                                    color: Color.fromARGB(255, 158, 158, 158),
                                                    style: BorderStyle.solid,
                                                    width: 2,
                                                  ),
                                                  children: [
                                                    TableRow(children: [
                                                      Column(children: [
                                                        SizedBox(
                                                          height: 10,
                                                          width: 10,
                                                        ),
                                                        Text('STT', style: titleWidgetBox),
                                                        SizedBox(
                                                          height: 10,
                                                        )
                                                      ]),
                                                      Column(children: [
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text('Tên ngành nghề', style: titleWidgetBox),
                                                        SizedBox(
                                                          height: 10,
                                                        )
                                                      ]),
                                                    ]),
                                                    for (var i = 0; i < listJobsResult.length; i++)
                                                      TableRow(children: [
                                                        Column(children: [
                                                          Padding(
                                                            padding: const EdgeInsets.only(top: 10, bottom: 10),
                                                            child: Text('${i + 1}'),
                                                          )
                                                        ]),
                                                        Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                                          listJobsResult[i].parentId == 0
                                                              ? Padding(
                                                                  padding: const EdgeInsets.only(top: 10, bottom: 10, left: 10),
                                                                  child: Text(
                                                                    '${listJobsResult[i].jobName}',
                                                                    style: TextStyle(fontWeight: FontWeight.w800),
                                                                  ),
                                                                )
                                                              : Padding(
                                                                  padding: const EdgeInsets.only(top: 10, bottom: 10, left: 30),
                                                                  child: Text('${listJobsResult[i].jobName}'),
                                                                )
                                                        ]),
                                                      ]),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Container(),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        Container(
                                          margin: EdgeInsets.only(top: 30),
                                          child: Row(
                                            children: [
                                              Expanded(flex: 1, child: Container()),
                                              Expanded(
                                                  flex: 9,
                                                  child: Container(
                                                      height: 40,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                          width: 1,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                      child: Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Expanded(
                                                            child: Text(
                                                              "Không có dữ liệu ngành nghề !",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(fontWeight: FontWeight.w700),
                                                            ),
                                                          ),
                                                        ],
                                                      ))),
                                              Expanded(flex: 1, child: Container()),
                                            ],
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 50),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text(
                                          "Mô tả: ",
                                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 9,
                                        child: Container(
                                          child: Text(
                                            enterprise.description,
                                            maxLines: 3,
                                            softWrap: true,
                                            style: TextStyle(fontSize: 17),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            )
                          : Center(
                              child: CircularProgressIndicator(),
                            ),
                    ),
                    Footer(),
                  ],
                )));
  }
}
