
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';

import '../../../../api.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';

class QuanLyDichVu extends StatefulWidget {
  const QuanLyDichVu({Key? key}) : super(key: key);

  @override
  State<QuanLyDichVu> createState() => _QuanLyDichVuState();
}

class _QuanLyDichVuState extends State<QuanLyDichVu> {
  var checkActive = false;
  late Future<dynamic> getServiceFuture;
  getService() async {
    var response = await httpGet("/api/scheduler/list", context);
    if (response.containsKey("body")) {
      if (response['body'] == 'true') {
        print(response['body']);
        checkActive = true;
        return 0;
      } else {
        return 0;
      }
    }
  }

  String titleLog = '';
  updateService() async {
    var response = await httpGet(
        "/api/scheduler/${checkActive == true ? 'start' : 'stop'}", context);
    if (response.containsKey("body")) {
      if (response['body'] == 'true') {
        titleLog = 'Cập nhật thay đổi thành công';
        return 0;
      } else {
        titleLog = 'Cập nhật thay đổi thất bại';
        return 0;
      }
    }
  }

  @override
  // ignore: must_call_super
  void initState() {
    getServiceFuture = getService();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: getServiceFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Container(
            color: backgroundPage,
            padding: EdgeInsets.symmetric(
                vertical: verticalPaddingPage,
                horizontal: horizontalPaddingPage),
            child: SingleChildScrollView(
                controller: ScrollController(),
                child: Container(
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
                          'Quản lý dịch vụ',
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
                          flex: 1,
                          child: CupertinoSwitch(
                            value: checkActive,
                            onChanged: (value) {
                              setState(() {
                                checkActive = value;
                              });
                            },
                          ),
                        ),
                        Expanded(
                            flex: 9,
                            child: Text(
                              "Dịch vụ quét thực tập sinh tự động",
                              style: titleWidgetBox,
                            ))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 20),
                          child: TextButton(
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
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .caption
                                  ?.copyWith(
                                      fontSize: 10.0, letterSpacing: 2.0),
                            ),
                            onPressed: () async {
                              await showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    ConfirmUpdate(
                                        title: "Xác nhận thay đổi",
                                        content:
                                            "Bạn có chắc chắn muốn thực hiện thay đổi",
                                        function: () async {
                                          await updateService();
                                          Navigator.pop(context);
                                        }),
                              );
                              showToast(
                                context: context,
                                msg: titleLog,
                                color:
                                    titleLog == 'Cập nhật thay đổi thành công'
                                        ? Color.fromARGB(136, 72, 238, 67)
                                        : Colors.red,
                                icon: titleLog == 'Cập nhật thay đổi thành công'
                                    ? Icon(Icons.done)
                                    : Icon(Icons.warning),
                              );
                            },
                            child: Row(
                              children: [
                                Text('Lưu thay đổi', style: textButton),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ]),
                )),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return Center(child: const CircularProgressIndicator());
      },
    );
  }
}
