import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:provider/provider.dart';

import '../../../../../common/style.dart';
import '../../../../../model/model.dart';
import '../../../../api.dart';
import '../../../../model/market_development/job.dart';

class CareerManagerDetail extends StatefulWidget {
  final int? id;
  CareerManagerDetail({Key? key, this.id}) : super(key: key);

  @override
  State<CareerManagerDetail> createState() => _CareerManagerDetailState();
}

class _CareerManagerDetailState extends State<CareerManagerDetail> {
  Jobs? job;
  Jobs? jobParent;
  List<Jobs> listJobByParentId = [];
  late Future getTTT;
  bool _setLoading = false;
  Future getJobDetailById(int id) async {
    var response = await httpGet("/api/nganhnghe/get/$id", context);
    var body = jsonDecode(response['body']);
    if (response.containsKey("body")) {
      setState(() {
        job = Jobs.fromJson(body);
      });
    }
    return job;
  }

  getJobDetailParent(int? parentId) async {
    var response = await httpGet("/api/nganhnghe/get/page?filter=id:$parentId ", context);
    var body = jsonDecode(response['body']);
    var content = [];
    print(body);
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
        jobParent = content
            .map((e) {
              return Jobs.fromJson(e);
            })
            .toList()
            .first;
      });
    }
  }

  getJobDetailChild(int? parentId) async {
    var response = await httpGet("/api/nganhnghe/get/page?filter=parentId:$parentId ", context);
    var body = jsonDecode(response['body']);
    var content = [];
    print(body);
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
        listJobByParentId = content.map((e) {
          return Jobs.fromJson(e);
        }).toList();
        print(listJobByParentId);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    callApi();
  }

  callApi() async {
    setState(() {
      _setLoading = false;
    });
    var job = await getJobDetailById(widget.id!);

    //N?? l?? th???ng cha
    if (job.parentId == 0) {
      // await getJobDetailByParentId(job.parentId);
      await getJobDetailChild(job.id);
    } else {
      //Con

      await getJobDetailParent(job.parentId);
    }
    // } else {
    //   await getJobDetailByParentId(job.id);
    // }
    setState(() {
      _setLoading = true;
    });
  }

  String getJobDetailByParentIdStr(List<Jobs> list) {
    String cv = "";
    if (list.length == 0) {
      return "Kh??ng c?? th??ng tin c???a c??ng vi???c c??? th???";
    }
    for (int i = 0; i < list.length; i++) {
      cv += "-${list[i].jobName} \n";
    }
    return cv;
  }

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
      widgetBody: Consumer<NavigationModel>(
        builder: (context, navigationModel, child) => _setLoading
            ? ListView(
                children: [
                  TitlePage(
                    listPreTitle: [
                      {'url': '/phat-trien-thi-truong', 'title': 'Dashboard'},
                      {'url': '/quan-li-nganh-nghe', 'title': 'Qu???n l?? ng??nh ngh???'}
                    ],
                    content: 'Qu???n l?? ng??nh ngh???',
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
                              'Th??ng tin ng??nh ngh???',
                              style: titleBox,
                            ),
                            Icon(
                              Icons.more_horiz,
                              color: colorIconTitleBox,
                              size: sizeIconTitleBox,
                            ),
                          ],
                        ),
                        //--------------???????ng line-------------
                        Container(
                          child: Divider(
                            thickness: 1,
                            color: ColorHorizontalLine,
                          ),
                        ),
                        //------------k???t th??c ???????ng line-------
                        Container(
                          child: Column(
                            children: [
                              //====
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              "Ng??nh ngh??? : ",
                                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 3,
                                            child: Text(
                                              job!.jobName!,
                                              style: TextStyle(fontSize: 17),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Container(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              //====
                              Container(
                                margin: EdgeInsets.only(top: 30),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            "C??ng vi???c c??? th???: ",
                                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            child: Text(
                                              getJobDetailByParentIdStr(listJobByParentId),
                                              style: TextStyle(fontSize: 17),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Container(),
                                        ),
                                      ],
                                    )),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 30),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        "M?? t???: ",
                                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Container(
                                        // padding: EdgeInsets.only(top: 40),
                                        child: Text(
                                          job!.description ?? "Kh??ng c?? m?? t???",
                                          maxLines: 10,
                                          softWrap: true,
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Footer(),
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }
}
