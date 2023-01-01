import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/format_date.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:provider/provider.dart';

import '../../../../../common/style.dart';
import '../../../../../model/model.dart';
import '../../../../api.dart';
import '../../../../model/market_development/lich_su_cong_tac.dart';
import '../../../../model/market_development/lichcongtac.dart';
import '../../../../model/market_development/union.dart';

class RegisterForWorkDetail extends StatefulWidget {
  final int? id;
  RegisterForWorkDetail({Key? key, this.id}) : super(key: key);

  @override
  State<RegisterForWorkDetail> createState() => _RegisterForWorkDetailState();
}

class _RegisterForWorkDetailState extends State<RegisterForWorkDetail> {
  late Future<WorkingSchedule> futureWorkingSchedule;
  late Future<List<LichSuCongTac>> futureLichSuCongTacList;
  List<LichSuCongTac> listLichSuCongTac = [];
  List<UnionObj>? listUnionObjectResult = [];

  Map<int, String> _mapStatus = {1: 'Cần tiếp cận', 2: 'Đang tiếp cận', 3: 'Đã ký hợp đồng'};
  //Chỉ cần lấy những nghiệp đoàn cần tiếp cận
  getListUnionSearchBy({key}) async {
    // var response = await httpGet(
    //     "/api/nghiepdoan/get/page?filter=contractStatus:1", context);
    var response = await httpGet("/api/nghiepdoan/get/page?", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
        listUnionObjectResult = content.map((e) {
          return UnionObj.fromJson(e);
        }).toList();
      });
    }
  }

  String getNameUnion(int id, List<UnionObj> list) {
    for (int i = 0; i < list.length; i++) {
      if (id == list[i].id) {
        return list[i].orgName!;
      }
    }
    return "No data";
  }

  Future<WorkingSchedule> getLichThiSatSearchById(int id) async {
    var response;

    response = await httpGet("/api/lichcongtac/get/$id", context);

    var body = jsonDecode(response['body']);

    if (response.containsKey("body")) {
      return WorkingSchedule.fromJson(body);
    }
    return new WorkingSchedule(id: id, dateFrom: "", dateTo: "", user: null, content: "");
  }

  Future<List<LichSuCongTac>> getListUnionByOnsiteId(int id) async {
    var response;

    response = await httpGet("/api/lichcongtac-nghiepdoan/get/page?filter=onsiteId:$id", context);

    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
        listLichSuCongTac = content.map((e) {
          return LichSuCongTac.fromJson(e);
        }).toList();

        print(listLichSuCongTac);
      });
    }
    return content.map((e) {
      return LichSuCongTac.fromJson(e);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    callApi();
    futureWorkingSchedule = getLichThiSatSearchById(widget.id!);
  }

  callApi() async {
    await getListUnionSearchBy();
    await getListUnionByOnsiteId(widget.id!);
  }

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: Consumer<NavigationModel>(
            builder: (context, navigationModel, child) => FutureBuilder<WorkingSchedule>(
                future: futureWorkingSchedule,
                builder: (context, snapshot) {
                  return ListView(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 1,
                        decoration: BoxDecoration(
                          color: colorWhite,
                          boxShadow: [boxShadowContainer],
                          border: Border(
                            bottom: borderTitledPage,
                          ),
                        ),
                        child: TitlePage(
                          listPreTitle: [
                            {'url': '/phat-trien-thi-truong', 'title': 'Dashboard'},
                            {'url': '/dang-ki-cong-tac', 'title': 'Đăng ký công tác'},
                          ],
                          content: "Đăng ký công tác",
                        ),
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
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Đăng kí công tác',
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
                            if (snapshot.hasData)
                              Container(
                                child: Column(
                                  children: [
                                    //====
                                    Container(
                                      margin: EdgeInsets.only(top: 20),
                                      child: Row(
                                        children: [
                                          //Start Row 1
                                          Expanded(
                                              child: Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  "Mã NV: ",
                                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Text(
                                                  snapshot.data!.user!.userCode,
                                                  style: TextStyle(fontSize: 17),
                                                ),
                                              ),
                                            ],
                                          )),
                                          Expanded(
                                              child: Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  "Tên NV: ",
                                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Container(
                                                  child: Text(
                                                    snapshot.data!.user!.fullName,
                                                    maxLines: 3,
                                                    softWrap: true,
                                                    style: TextStyle(fontSize: 17),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
                                        ],
                                      ),
                                    ),
                                    //====
                                    Container(
                                      margin: EdgeInsets.only(top: 40),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  "Số điện thoại: ",
                                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Container(
                                                  child: Text(
                                                    snapshot.data!.user!.phone,
                                                    style: TextStyle(fontSize: 17),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
                                          Expanded(
                                              child: Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  "Email: ",
                                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Container(
                                                  child: Text(
                                                    snapshot.data!.user!.email,
                                                    style: TextStyle(fontSize: 17),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
                                        ],
                                      ),
                                    ),
                                    for (int i = 0; i < listLichSuCongTac.length; i++)
                                      Container(
                                        margin: EdgeInsets.only(top: 40),
                                        child: Row(
                                          children: [
                                            Expanded(
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
                                                  child: Container(
                                                    child: Text(
                                                      getNameUnion(listLichSuCongTac[i].orgId!, listUnionObjectResult!),
                                                      style: TextStyle(fontSize: 17),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
                                            Expanded(
                                                child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    "Trạng thái: ",
                                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 4,
                                                  child: Container(
                                                    child: Text(
                                                      _mapStatus[
                                                              listLichSuCongTac[i].orgStatusResult != null ? listLichSuCongTac[i].orgStatusResult! : listLichSuCongTac[i].orgStatus]
                                                          .toString(),
                                                      style: TextStyle(fontSize: 17),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
                                          ],
                                        ),
                                      ),

                                    //====
                                    Container(
                                      margin: EdgeInsets.only(top: 40),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  "Từ ngày: ",
                                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Container(
                                                  child: Text(
                                                    snapshot.data!.dateFrom != null ? FormatDate.formatDateView(DateTime.parse(snapshot.data!.dateFrom)) : "No data!",
                                                    style: TextStyle(fontSize: 17),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
                                          Expanded(
                                              child: Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  "Đến ngày: ",
                                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Container(
                                                  child: Text(
                                                    // ignore: unnecessary_null_comparison
                                                    snapshot.data!.dateTo != null ? FormatDate.formatDateView(DateTime.parse(snapshot.data!.dateTo)) : "No data!",
                                                    style: TextStyle(fontSize: 17),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )),
                                        ],
                                      ),
                                    ),
                                    //====
                                    Container(
                                      margin: EdgeInsets.only(top: 40),
                                      child: Row(
                                        children: [
                                          Expanded(
                                              child: Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Text(
                                                  "Nội dung công tác: ",
                                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 5,
                                                child: Container(
                                                  child: Text(
                                                    // ignore: unnecessary_null_comparison
                                                    snapshot.data!.content != null ? snapshot.data!.content.toString() : "",
                                                    style: TextStyle(fontSize: 17),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: Container(),
                                              ),
                                            ],
                                          )),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else if (snapshot.hasError)
                              Text("Fail! ${snapshot.error}")
                            else if (!snapshot.hasData)
                              Center(
                                child: CircularProgressIndicator(),
                              ),
                          ],
                        ),
                      ),
                      Footer()
                    ],
                  );
                })));
  }
}

class TextFieldWidgetLable extends StatelessWidget {
  final String lable;
  const TextFieldWidgetLable({Key? key, required this.lable}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 30),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(lable, style: titleWidgetBox),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      // width: MediaQuery.of(context).size.width * 0.15,
                      color: Colors.white,
                      height: 40,
                      child: TextField(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(0)),
                          ),
                        ),
                      ),
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
    );
  }
}
