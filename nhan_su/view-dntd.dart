import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../api.dart';
import '../../../common/style.dart';
import '../../../common/toast.dart';
import '../../../common/widgets_form.dart';
import '../../../model/model.dart';
import '../../forms/nhan_su/setting-data/detailed-recruitment.dart';
import '../../ui/navigation.dart';

class ViewDNTDBody extends StatefulWidget {
  final String idTTDNTD;

  const ViewDNTDBody({Key? key, required this.idTTDNTD}) : super(key: key);

  @override
  State<ViewDNTDBody> createState() => _ViewDNTDBodyState();
}

class _ViewDNTDBodyState extends State<ViewDNTDBody> {
  TextEditingController approveNote = TextEditingController();
  final currencyFormat = new NumberFormat("#,##0", "en_US");
  List<DetailedRecruitment> listRecruitResult = [];
  late Future<List<DetailedRecruitment>> futureListRecruit;

  Future<List<DetailedRecruitment>> getDNTDChiTiet() async {
    var response = await httpGet("/api/tuyendung-chitiet/get/page?filter=tuyendungId:${widget.idTTDNTD}", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];

        listRecruitResult = content.map((e) {
          return DetailedRecruitment.fromJson(e);
        }).toList();

        // print(resultTTDNTDChiTiet);
      });
    }
    return listRecruitResult;
  }

  upDateApprove(int id, int approve, String approveNote, int status, int approver) async {
    var requestBody = {
      "approver": approver,
      "approve": approve,
      "approveNote": approveNote,
      "status": status,
    };
    var response6 = await httpPut("/api/tuyendung/put/$id", requestBody, context);

    if (response6.containsKey("body")) {
      print('update thành công');
      setState(() {});
    }
  }

  @override
  void initState() {
    futureListRecruit = getDNTDChiTiet();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: FutureBuilder<dynamic>(
      future: userRule('/view-dntd', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return Consumer2<NavigationModel, SecurityModel>(
            builder: (context, navigationModel, user, child) => Container(
              child: ListView(
                controller: ScrollController(),
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TitlePage(
                        listPreTitle: [
                          {'url': "/nhan-su", 'title': 'Dashboard'},
                          {'url': "/de-nghi-tuyen-dung-chuc-nang", 'title': 'Đề nghị tuyển dụng'},
                        ],
                        content: 'Thông tin',
                      ),
                      //thông tin
                      (listRecruitResult.length > 0)
                          ? Container(
                              width: MediaQuery.of(context).size.width * 1,
                              padding: paddingTitledPage,
                              margin: EdgeInsets.only(right: 30, top: 30, left: 30, bottom: 30),
                              decoration: BoxDecoration(
                                color: colorWhite,
                                boxShadow: [boxShadowContainer],
                                border: Border(
                                  bottom: borderTitledPage,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Thông tin chi tiết',
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
                                    padding: const EdgeInsets.fromLTRB(80, 30, 0, 30),
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
                                                  flex: 1,
                                                  child: Text('Tiêu đề:', style: titleWidgetBox),
                                                ),
                                                Expanded(
                                                  flex: 5,
                                                  child: Container(child: Text(listRecruitResult[0].title)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(flex: 1, child: Container()),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(80, 0, 0, 30),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            child: Row(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: Text('Mô tả:', style: titleWidgetBox),
                                                ),
                                                Expanded(
                                                  flex: 5,
                                                  child: Container(
                                                    child: Text(listRecruitResult[0].description),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(flex: 1, child: Container()),
                                      ],
                                    ),
                                  ),
                                  Table(
                                    // defaultColumnWidth: FixedColumnWidth(120.0),

                                    border: TableBorder.all(
                                        color: Color.fromARGB(255, 158, 158, 158),
                                        style: BorderStyle.solid,
                                        width: 2,
                                        borderRadius: BorderRadius.all(Radius.circular(9))),
                                    children: [
                                      TableRow(children: [
                                        Column(children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('STT', style: titleWidgetBox, textAlign: TextAlign.center),
                                          SizedBox(
                                            height: 10,
                                          )
                                        ]),
                                        Column(children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('Phòng ban', style: titleWidgetBox, textAlign: TextAlign.center),
                                          SizedBox(
                                            height: 10,
                                          )
                                        ]),
                                        Column(children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('Vị trí', style: titleWidgetBox, textAlign: TextAlign.center),
                                          SizedBox(
                                            height: 10,
                                          )
                                        ]),
                                        Column(children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('Số lượng cần tuyển', style: titleWidgetBox, textAlign: TextAlign.center),
                                          SizedBox(
                                            height: 10,
                                          )
                                        ]),
                                        Column(children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('Thời gian cần', style: titleWidgetBox, textAlign: TextAlign.center),
                                          SizedBox(
                                            height: 10,
                                          )
                                        ]),
                                        Column(children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('Mức lương', style: titleWidgetBox, textAlign: TextAlign.center),
                                          SizedBox(
                                            height: 10,
                                          )
                                        ]),
                                        Column(children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Text('JD file', style: titleWidgetBox, textAlign: TextAlign.center),
                                          SizedBox(
                                            height: 10,
                                          )
                                        ]),
                                      ]),
                                      for (var i = 0; i < listRecruitResult.length; i++)
                                        TableRow(children: [
                                          Column(children: [
                                            Padding(
                                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                                              child: Text('${i + 1}'),
                                            )
                                          ]),
                                          Column(children: [
                                            Padding(
                                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                                              child: Text(
                                                '${listRecruitResult[i].nameDepart}',
                                                textAlign: TextAlign.center,
                                              ),
                                            )
                                          ]),
                                          Column(children: [
                                            Padding(
                                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                                              child: Text('${listRecruitResult[i].nameDuty}', textAlign: TextAlign.center),
                                            )
                                          ]),
                                          Column(children: [
                                            Padding(
                                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                                              child: Text('${listRecruitResult[i].qty}', textAlign: TextAlign.center),
                                            )
                                          ]),
                                          Column(children: [
                                            Padding(
                                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                                              child: Text(
                                                  "${DateFormat('MM-yyyy').format(DateTime.parse(listRecruitResult[i].timeNeeded.toString()))}",
                                                  textAlign: TextAlign.center),
                                            ),
                                          ]),
                                          Column(children: [
                                            Padding(
                                              padding: const EdgeInsets.only(top: 10, bottom: 10),
                                              child: Text('${listRecruitResult[i].salary}'),
                                            )
                                          ]),
                                          Column(children: [
                                            (listRecruitResult[i].jdFile != "")
                                                ? IconButton(
                                                    onPressed: () {
                                                      downloadFile(listRecruitResult[i].jdFile!);
                                                    },
                                                    icon: Icon(
                                                      Icons.download,
                                                      color: Colors.blue,
                                                    ))
                                                : Text("")
                                          ]),
                                        ]),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(30, 30, 0, 30),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        (user.userLoginCurren['departId'] == 2 || user.userLoginCurren['departId'] == 1)
                                            ? Container(
                                                margin: EdgeInsets.only(left: 20),
                                                child: TextButton(
                                                  style: TextButton.styleFrom(
                                                    padding: const EdgeInsets.symmetric(
                                                      vertical: 20.0,
                                                      horizontal: 20.0,
                                                    ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(5.0),
                                                    ),
                                                    backgroundColor:
                                                        ((listRecruitResult[0].appRove) == 0) ? Color.fromRGBO(245, 117, 29, 1) : Color(0xfffcccccc),
                                                    primary: Theme.of(context).iconTheme.color,
                                                    textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                  ),
                                                  // onPressed: () {},
                                                  onPressed: ((listRecruitResult[0].appRove) == 0)
                                                      ? () {
                                                          // xử lý nút phê duyệt

                                                          showDialog(
                                                              context: context,
                                                              builder: (BuildContext context) {
                                                                var id = widget.idTTDNTD;

                                                                return AlertDialog(
                                                                  title: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
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
                                                                            'Phê duyệt đề nghị tuyển dụng ',
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
                                                                  ]),
                                                                  //content
                                                                  content: Container(
                                                                    width: 700,
                                                                    height: 300,
                                                                    child: ListView(
                                                                      children: [
                                                                        Column(
                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            //đường line
                                                                            Container(
                                                                              margin: marginTopBottomHorizontalLine,
                                                                              child: Divider(
                                                                                thickness: 1,
                                                                                color: ColorHorizontalLine,
                                                                              ),
                                                                            ),
                                                                            Container(
                                                                              height: 150,
                                                                              child: Text(
                                                                                'Xác nhận phê duyệt .... đề nghị tuyển dụng',
                                                                                style: titleWidgetBox,
                                                                              ),
                                                                            ),
                                                                            //đường line
                                                                            Container(
                                                                              margin: marginTopBottomHorizontalLine,
                                                                              child: Divider(
                                                                                thickness: 1,
                                                                                color: ColorHorizontalLine,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),

                                                                  //actions
                                                                  actions: [
                                                                    ElevatedButton(
                                                                      onPressed: () {
                                                                        print(widget.idTTDNTD);
                                                                        // print(resultTTDNTDChiTiet['tuyendung']['approve']);
                                                                        showDialog(
                                                                            context: context,
                                                                            builder: (BuildContext context) => AlertDialog(
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
                                                                                                'Phê duyệt đề nghị tuyển dụng ',
                                                                                                style: titleAlertDialog,
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                        IconButton(
                                                                                          onPressed: () =>
                                                                                              {Navigator.pop(context), Navigator.pop(context)},
                                                                                          icon: Icon(
                                                                                            Icons.close,
                                                                                          ),
                                                                                        ),
                                                                                      ]),
                                                                                  //content
                                                                                  content: Container(
                                                                                    width: 700,
                                                                                    height: 300,
                                                                                    child: ListView(
                                                                                      children: [
                                                                                        Column(
                                                                                          mainAxisAlignment: MainAxisAlignment.start,
                                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                                          children: [
                                                                                            //đường line
                                                                                            Container(
                                                                                              margin: marginTopBottomHorizontalLine,
                                                                                              child: Divider(
                                                                                                thickness: 1,
                                                                                                color: ColorHorizontalLine,
                                                                                              ),
                                                                                            ),
                                                                                            Container(
                                                                                              height: 150,
                                                                                              child: Column(
                                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                                                children: [
                                                                                                  Row(
                                                                                                    children: [
                                                                                                      Text('Lý do:', style: titleWidgetBox),
                                                                                                      Text("*",
                                                                                                          style: TextStyle(
                                                                                                            color: Colors.red,
                                                                                                            fontSize: 16,
                                                                                                          )),
                                                                                                    ],
                                                                                                  ),
                                                                                                  SizedBox(
                                                                                                    height: 20,
                                                                                                  ),
                                                                                                  TextField(
                                                                                                    controller: approveNote,
                                                                                                    maxLines: 5,
                                                                                                    minLines: 3,
                                                                                                    decoration: InputDecoration(
                                                                                                      border: OutlineInputBorder(
                                                                                                        borderRadius:
                                                                                                            BorderRadius.all(Radius.circular(0)),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                            //đường line
                                                                                            Container(
                                                                                              margin: marginTopBottomHorizontalLine,
                                                                                              child: Divider(
                                                                                                thickness: 1,
                                                                                                color: ColorHorizontalLine,
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  //actions
                                                                                  actions: [
                                                                                    ElevatedButton(
                                                                                      onPressed: () => Navigator.pop(context),
                                                                                      child: Text('Hủy'),
                                                                                      style: ElevatedButton.styleFrom(
                                                                                        primary: colorIconTitleBox,
                                                                                        onPrimary: colorWhite,
                                                                                        elevation: 3,
                                                                                        minimumSize: Size(140, 50),
                                                                                      ),
                                                                                    ),
                                                                                    ElevatedButton(
                                                                                      onPressed: () {
                                                                                        if (approveNote.text != "") {
                                                                                          print(approveNote.text);
                                                                                          upDateApprove(int.parse(widget.idTTDNTD.toString()), 2,
                                                                                              approveNote.text, 0, user.userLoginCurren['id']);
                                                                                          Provider.of<NavigationModel>(context, listen: false)
                                                                                              .add(pageUrl: "/de-nghi-tuyen-dung-chuc-nang");
                                                                                          showToast(
                                                                                            context: context,
                                                                                            msg: "Đã từ chối đề nghị tuyển dụng",
                                                                                            color: colorOrange,
                                                                                            icon: const Icon(Icons.done),
                                                                                          );
                                                                                        } else
                                                                                          showToast(
                                                                                            context: context,
                                                                                            msg: "Nhập lý do từ chối",
                                                                                            color: colorOrange,
                                                                                            icon: const Icon(Icons.warning),
                                                                                          );
                                                                                      },
                                                                                      child: Text(
                                                                                        'Xác nhận',
                                                                                        style: TextStyle(),
                                                                                      ),
                                                                                      style: ElevatedButton.styleFrom(
                                                                                        primary: mainColorPage,
                                                                                        onPrimary: colorWhite,
                                                                                        elevation: 3,
                                                                                        minimumSize: Size(140, 50),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ));
                                                                      },
                                                                      // Navigator.pop(context),
                                                                      child: Text('Từ chối'),
                                                                      style: ElevatedButton.styleFrom(
                                                                        primary: colorIconTitleBox,
                                                                        onPrimary: colorWhite,
                                                                        elevation: 3,
                                                                        minimumSize: Size(140, 50),
                                                                      ),
                                                                    ),
                                                                    ElevatedButton(
                                                                      onPressed: () {
                                                                        upDateApprove(int.parse(widget.idTTDNTD.toString()), 1, "Đã phê duyệt", 1,
                                                                            user.userLoginCurren['id']);
                                                                        Provider.of<NavigationModel>(context, listen: false)
                                                                            .add(pageUrl: "/de-nghi-tuyen-dung-chuc-nang");
                                                                        print("đã duyệt");
                                                                        showToast(
                                                                          context: context,
                                                                          msg: "Đã phê duyệt đề nghị tuyển dụng",
                                                                          color: Color.fromARGB(136, 72, 238, 67),
                                                                          icon: const Icon(Icons.done),
                                                                        );
                                                                      },
                                                                      child: Text(
                                                                        'Duyệt',
                                                                        style: TextStyle(),
                                                                      ),
                                                                      style: ElevatedButton.styleFrom(
                                                                        primary: mainColorPage,
                                                                        onPrimary: colorWhite,
                                                                        elevation: 3,
                                                                        minimumSize: Size(140, 50),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                );
                                                              });
                                                        }
                                                      : null,
                                                  child: Row(
                                                    children: [
                                                      Text('Phê duyệt', style: textButton),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : Container(),
                                        Container(
                                            margin: EdgeInsets.only(left: 20),
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(
                                                  vertical: 20.0,
                                                  horizontal: 20.0,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(5.0),
                                                ),
                                                backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                                primary: Theme.of(context).iconTheme.color,
                                                textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                              ),
                                              onPressed: () => {Navigator.pop(context)},
                                              child: Text('Trở về', style: textButton),
                                            )),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                ],
                              ),
                            )
                          : Center(child: CircularProgressIndicator()),
                    ],
                  ),
                  Footer(marginFooter: EdgeInsets.only(top: 5), paddingFooter: EdgeInsets.all(15)),
                  SizedBox(height: 20)
                ],
              ),
            ),
          );
        } else if (listRule.hasError) {
          return Text('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    ));
  }
}
