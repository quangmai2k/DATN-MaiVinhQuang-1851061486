import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/model/market_development/phapnhan.dart';

import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:provider/provider.dart';

import '../../../../../common/style.dart';
import '../../../../../model/model.dart';
import '../../../../api.dart';
import '../../../../common/widgets_form.dart';
import '../../../../config.dart';

class PhapNhanDetail extends StatefulWidget {
  final int? id;
  PhapNhanDetail({Key? key, this.id}) : super(key: key);

  @override
  State<PhapNhanDetail> createState() => _PhapNhanDetailState();
}

class _PhapNhanDetailState extends State<PhapNhanDetail> {
  late Future<PhapNhan> futurePhapNhan;
  PhapNhan? phapNhan;
  @override
  void initState() {
    super.initState();
    //getListInpectionCanlendarSearchBy(widget.id!);
    futurePhapNhan = getPhapNhan(widget.id!);
  }

  Future<PhapNhan> getPhapNhan(int id) async {
    var response;

    response = await httpGet("/api/phapnhan/get/$id", context);

    var body = jsonDecode(response['body']);

    if (response.containsKey("body")) {
      setState(() {
        phapNhan = PhapNhan.fromJson(body);
        // print(listJobsResult);
      });
    }

    return PhapNhan.fromJson(body);
  }

  getText(data) {
    try {
      if (data != null) {
        return data.toString();
      }
      return "Chưa có dữ liệu";
    } catch (e) {
      print(e);
    }
    return "Chưa có dữ liệu";
  }

  Widget getImage({id, fileName}) {
    if (fileName == null) {
      return Container();
    }
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2.0, style: BorderStyle.solid),
        ),
        margin: EdgeInsets.only(bottom: 15),
        height: 200,
        width: 200,
        child: Image.network("$baseUrl/api/files/$fileName"));
  }

  Map<int, String> _mapStatus = {
    0: 'Không hoạt động',
    1: 'Hoạt động',
  };
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: FutureBuilder<PhapNhan>(
            future: futurePhapNhan,
            builder: (context, snapshot) {
              return Consumer<NavigationModel>(
                  builder: (context, navigationModel, child) => ListView(
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
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          'Home',
                                          style: TextStyle(color: Color(0xff009C87)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 5, right: 5),
                                          child: Text(
                                            '/',
                                            style: TextStyle(
                                              color: Color(0xffC8C9CA),
                                            ),
                                          ),
                                        ),
                                        Text('Pháp nhân', style: TextStyle(color: Color(0xff009C87))),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text('Pháp nhân', style: titlePage),
                                  ],
                                ),
                              ],
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
                                      'Pháp nhân',
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
                                                      "Tên pháp nhân : ",
                                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      phapNhan != null ? getText(phapNhan!.name) : "Chưa có dữ liệu",
                                                      style: TextStyle(fontSize: 17),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                            ],
                                          ),
                                        ),
                                        //====
                                        Container(
                                          margin: EdgeInsets.only(top: 30),
                                          child: Row(
                                            children: [
                                              //Start Row 1
                                              Expanded(
                                                  child: Row(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      "Trạng thái : ",
                                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      phapNhan!.status != null ? _mapStatus[phapNhan!.status].toString() : "Chưa có dữ liệu",
                                                      style: TextStyle(fontSize: 17),
                                                    ),
                                                  ),
                                                ],
                                              )),
                                            ],
                                          ),
                                        ),
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
                                                      "Hình ảnh : ",
                                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                    ),
                                                  ),
                                                  Expanded(flex: 2, child: phapNhan != null ? getImage(fileName: phapNhan!.image) : Container()),
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(),
                                                  ),
                                                ],
                                              )),
                                            ],
                                          ),
                                        ),

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
                                                      "Mô tả : ",
                                                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Text(
                                                      phapNhan != null ? getText(phapNhan!.description) : "Chưa có dữ liệu",
                                                      style: TextStyle(fontSize: 17),
                                                    ),
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
                                  Text("")
                                else
                                  Center(
                                    child: CircularProgressIndicator(),
                                  ),
                              ],
                            ),
                          ),
                          //--------------Chân trang--------
                          Footer()
                        ],
                      ));
            }));
  }
}
