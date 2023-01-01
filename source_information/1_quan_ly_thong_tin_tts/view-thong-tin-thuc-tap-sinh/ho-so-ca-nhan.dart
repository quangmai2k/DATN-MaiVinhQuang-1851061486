import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/api.dart';
import 'package:intl/intl.dart';

import '../../../../../common/style.dart';
import '../../../../common/style.dart';

class ViewHSCN extends StatefulWidget {
  String ttsId;
  ViewHSCN({required this.ttsId});
  @override
  State<ViewHSCN> createState() => ViewHSCNStates();
}

class ViewHSCNStates extends State<ViewHSCN> {
  Map<dynamic, dynamic> listHoSoChung = {};
  Map<dynamic, dynamic> listHoSoKhac = {};
  Map<dynamic, TextEditingController> controllerText = {};
  getHoSo() async {
    // filter=fileGeneric:1
    var response = await httpGet("/api/tts-hoso/get/page?filter=fileGeneric:0", context);
    if (response.containsKey("body")) {
      var body = jsonDecode(response["body"]);
      var content = body['content'];
      for (var element in content) {
        if (element['fileGroup'] == 0) {
          // listHoSoChung[element['id']] = [element['name'], element['required'], element['contentType'], "", 0, false, 0];
          listHoSoChung[element['id']] = {
            "tenHoSo": element['name'],
            "required": element['required'],
            "contentType": element['contentType'],
            "idHSCT": 0,
            "value": element['value'],
            "received": false,
            "delete": false
          };
          controllerText[element['id']] = TextEditingController();
        } else {
          // listHoSoKhac[element['id']] = [element['name'], element['required'], element['contentType'], "", 0, false, 0];
          listHoSoKhac[element['id']] = {
            "tenHoSo": element['name'],
            "required": element['required'],
            "contentType": element['contentType'],
            "idHSCT": 0,
            "value": element['value'],
            "received": false,
            "check": false
          };
          controllerText[element['id']] = TextEditingController();
        }
      }
    }
  }

  Map<String, dynamic> listHoSoChiTiet = {};
  getDataUpdateHoSo() async {
    var response = await httpGet("/api/tts-hoso-chitiet/get/page?filter=ttsId:${widget.ttsId}", context);
    if (response.containsKey("body")) {
      var body = jsonDecode(response["body"]);
      var content = body['content'];
      for (var element in content) {
        if (listHoSoChung.containsKey(element['hosoId'])) {
          if (listHoSoChung[element['hosoId']]["contentType"] == 0 || listHoSoChung[element['hosoId']]["contentType"] == 3)
            listHoSoChung[element['hosoId']]["value"] = element['fileUrl'] ?? "";
          else {
            listHoSoChung[element['hosoId']]["value"] = element['content'] ?? "";
            controllerText[element['hosoId']]!.text = listHoSoChung[element['hosoId']]["value"] ?? "";
          }
          listHoSoChung[element['hosoId']]['idHSCT'] = element['id'];
          listHoSoChung[element['hosoId']]['check'] = true;
          listHoSoChung[element['hosoId']]['received'] = (element['received'] == 0) ? false : true;
        }
        if (listHoSoKhac.containsKey(element['hosoId'])) {
          if (listHoSoKhac[element['hosoId']]["contentType"] == 0 || listHoSoKhac[element['hosoId']]["contentType"] == 3)
            listHoSoKhac[element['hosoId']]["value"] = element['fileUrl'] ?? "";
          else {
            listHoSoKhac[element['hosoId']]["value"] = element['content'] ?? "";
            controllerText[element['hosoId']]!.text = listHoSoKhac[element['hosoId']]["value"] ?? "";
          }
          listHoSoKhac[element['hosoId']]['idHSCT'] = element['id'];
          listHoSoKhac[element['hosoId']]['check'] = true;
          listHoSoKhac[element['hosoId']]['received'] = (element['received'] == 0) ? false : true;
        }
      }
    }
  }

  bool checkState = false;
  callAPi() async {
    await getHoSo();

    await getDataUpdateHoSo();
    setState(() {
      checkState = true;
    });
  }

  @override
  void initState() {
    super.initState();
    callAPi();
  }

  @override
  void dispose() {
    super.dispose();
    for (var element in controllerText.keys) controllerText[element]?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (checkState)
        ? Container(
            padding: paddingBoxContainer,
            // margin: marginBoxFormTab,
            margin: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 30),
            width: MediaQuery.of(context).size.width * 1,
            decoration: BoxDecoration(
              color: colorWhite,
              borderRadius: borderRadiusContainer,
              boxShadow: [boxShadowContainer],
              border: borderAllContainerBox,
            ),
            child: ListView(
              controller: ScrollController(),
              // mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Hồ sơ chung',
                      style: titleBox,
                    ),
                  ],
                ),
                Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Wrap(
                          runSpacing: 25.0,
                          spacing: 100.0,
                          // alignment : WrapAlignment .center,
                          children: [
                            for (var key in listHoSoChung.keys)
                              Container(
                                width: 600,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Checkbox(
                                        hoverColor: Colors.white,
                                        mouseCursor: MouseCursor.uncontrolled,
                                        focusColor: Colors.white,
                                        value: (listHoSoChung[key]['received']),
                                        onChanged: (value) {
                                          setState(() {});
                                        },
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: SelectableText(
                                              "${listHoSoChung[key]["tenHoSo"]}",
                                              style: TextStyle(
                                                color: Color(0xff333333),
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                          (listHoSoChung[key]["required"] == 1)
                                              ? Text(
                                                  "*",
                                                  style: TextStyle(color: Colors.red),
                                                )
                                              : Text("")
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                        flex: 4,
                                        child: (listHoSoChung[key]["contentType"] == 0 || listHoSoChung[key]["contentType"] == 3)
                                            ? TextButton(
                                                child: (listHoSoChung[key]["value"] == null || listHoSoChung[key]["value"] == "")
                                                    ? Text("")
                                                    : Text('Tải file'),
                                                onPressed: (listHoSoChung[key]["value"] == null || listHoSoChung[key]["value"] == "")
                                                    ? null
                                                    : () async {
                                                        downloadFile(listHoSoChung[key]["value"]);
                                                      },
                                              )
                                            : (listHoSoChung[key]["contentType"] == 1)
                                                ? Container(
                                                    height: 40,
                                                    child: (listHoSoChung[key]["value"] != "")
                                                        ? TextField(
                                                            enabled: false,
                                                            decoration: InputDecoration(
                                                              contentPadding: const EdgeInsets.fromLTRB(10, 7, 5, 0),
                                                              filled: true,
                                                              fillColor: Colors.white,
                                                              focusedBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(0),
                                                              ),
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(0),
                                                              ),
                                                            ),
                                                            controller: TextEditingController(text: listHoSoChung[key]["value"]),
                                                          )
                                                        : Text(""),
                                                  )
                                                : Container(
                                                    height: 40,
                                                    child: (listHoSoChung[key]["value"] != "" && listHoSoChung[key]["value"] != null)
                                                        ? TextField(
                                                            enabled: false,
                                                            decoration: InputDecoration(
                                                              contentPadding: const EdgeInsets.fromLTRB(10, 7, 5, 0),
                                                              filled: true,
                                                              fillColor: Colors.white,
                                                              focusedBorder: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(0),
                                                              ),
                                                              border: OutlineInputBorder(
                                                                borderRadius: BorderRadius.circular(0),
                                                              ),
                                                            ),
                                                            controller: TextEditingController(
                                                                text: (listHoSoChung[key]["value"] != null && listHoSoChung[key]["value"] != "")
                                                                    ? (DateFormat("dd-MM-yyyy").format(DateTime.parse(listHoSoChung[key]["value"])))
                                                                    : ""),
                                                          )
                                                        : Text(""),
                                                  )),
                                  ],
                                ),
                              ),
                            // SizedBox(height: 30,),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 30),
                  child: Column(
                    children: [
                      Container(
                        margin: marginTopBottomHorizontalLine,
                        child: Divider(
                          thickness: 1,
                          color: ColorHorizontalLine,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Hồ sơ khác',
                            style: titleBox,
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Wrap(
                              runSpacing: 25.0,
                              spacing: 100.0,
                              // alignment : WrapAlignment .center,
                              children: [
                                for (var key in listHoSoKhac.keys)
                                  Container(
                                    width: 600,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Checkbox(
                                            hoverColor: Colors.white,
                                            mouseCursor: MouseCursor.uncontrolled,
                                            focusColor: Colors.white,
                                            value: (listHoSoKhac[key]['received']),
                                            onChanged: (value) {
                                              setState(() {});
                                            },
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Row(
                                            children: [
                                              Flexible(
                                                child: SelectableText(
                                                  "${listHoSoKhac[key]["tenHoSo"]}",
                                                  style: TextStyle(
                                                    color: Color(0xff333333),
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              ),
                                              (listHoSoKhac[key]["required"] == 1)
                                                  ? Text(
                                                      "*",
                                                      style: TextStyle(color: Colors.red),
                                                    )
                                                  : Text("")
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                            flex: 4,
                                            child: (listHoSoKhac[key]["contentType"] == 0 || listHoSoKhac[key]["contentType"] == 3)
                                                ? TextButton(
                                                    child: (listHoSoKhac[key]["value"] == null || listHoSoKhac[key]["value"] == "")
                                                        ? Text("")
                                                        : Text('Tải file'),
                                                    onPressed: (listHoSoKhac[key]["value"] == null || listHoSoKhac[key]["value"] == "")
                                                        ? null
                                                        : () async {
                                                            downloadFile(listHoSoKhac[key]["value"]);
                                                          },
                                                  )
                                                : (listHoSoKhac[key]["contentType"] == 1)
                                                    ? Container(
                                                        height: 40,
                                                        child: (listHoSoKhac[key]["value"] != "")
                                                            ? TextField(
                                                                enabled: false,
                                                                decoration: InputDecoration(
                                                                  contentPadding: const EdgeInsets.fromLTRB(10, 7, 5, 0),
                                                                  filled: true,
                                                                  fillColor: Colors.white,
                                                                  focusedBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(0),
                                                                  ),
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(0),
                                                                  ),
                                                                ),
                                                                controller: TextEditingController(text: listHoSoKhac[key]["value"]),
                                                              )
                                                            : Text(""),
                                                      )
                                                    : Container(
                                                        height: 40,
                                                        child: (listHoSoKhac[key]["value"] != "")
                                                            ? TextField(
                                                                enabled: false,
                                                                decoration: InputDecoration(
                                                                  contentPadding: const EdgeInsets.fromLTRB(10, 7, 5, 0),
                                                                  filled: true,
                                                                  fillColor: Colors.white,
                                                                  focusedBorder: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(0),
                                                                  ),
                                                                  border: OutlineInputBorder(
                                                                    borderRadius: BorderRadius.circular(0),
                                                                  ),
                                                                ),
                                                                controller: TextEditingController(
                                                                    text: (listHoSoKhac[key]["value"] != null && listHoSoKhac[key]["value"] != "")
                                                                        ? (DateFormat("dd-MM-yyyy")
                                                                            .format(DateTime.parse(listHoSoKhac[key]["value"])))
                                                                        : ""),
                                                              )
                                                            : Text(""),
                                                      )),
                                      ],
                                    ),
                                  ),
                                // SizedBox(height: 30,),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 30,
              ),
              CircularProgressIndicator(),
            ],
          );
  }
}
