import 'dart:convert';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import 'package:gentelella_flutter/widgets/ui/he_thong/cai_dat_thuc_tap_sinh/form_cau_hinh_thong_tin_tts.dart';
import 'package:provider/provider.dart';

import '../../../../api.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../model/model.dart';
import '../../navigation.dart';

// ignore: must_be_immutable
class ThemMoiChuongTrinh extends StatefulWidget {
  String? id;
  ThemMoiChuongTrinh({Key? key, this.id}) : super(key: key);

  @override
  State<ThemMoiChuongTrinh> createState() => _ThemMoiChuongTrinhState();
}

class _ThemMoiChuongTrinhState extends State<ThemMoiChuongTrinh> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
        widgetBody: ThemMoiChuongTrinhBody(
      id: widget.id,
    ));
  }
}

// ignore: must_be_immutable
class ThemMoiChuongTrinhBody extends StatefulWidget {
  String? id;
  ThemMoiChuongTrinhBody({Key? key, this.id}) : super(key: key);

  @override
  State<ThemMoiChuongTrinhBody> createState() => _ThemMoiChuongTrinhBodyState();
}

class _ThemMoiChuongTrinhBodyState extends State<ThemMoiChuongTrinhBody> {
  late Future<dynamic> getCtdtFuture;
  late Future<dynamic> getListCtdtFuture;
  late Future<dynamic> updateFuture;
  late Future<dynamic> addFuture;
  late String titleLog;
  dynamic listItemsCTDT = [];
  var curentCtdt;
  TextEditingController searchCTDT = TextEditingController();
  Future<dynamic> getCTDT() async {
    var response =
        await httpGet("/api/daotao-chuongtrinh/get/${widget.id}", context);
    if (response.containsKey("body")) {
      curentCtdt = jsonDecode(response["body"]);
      print(curentCtdt);

      setState(() {
        textCTDT.text = curentCtdt['name'] ?? "";
        textTGDT.text = curentCtdt['courseTime'] ?? "";
        textSBG.text = curentCtdt['lecturesTotal'].toString() == "null"
            ? ""
            : curentCtdt['lecturesTotal'].toString();
        curentCtdt['displayScore'] == 1
            ? _checkPoint = true
            : _checkPoint = false;
        curentCtdt['showPassResult'] == 1
            ? _checkResult = true
            : _checkResult = false;
      });
      return curentCtdt;
    } else
      throw Exception('False to load data');
  }

  Future<dynamic> updateCTDT(String name, int parentId, String? courseTime,
      int? lecturesTotal, int displayScore, int showPassResult) async {
    if (fileBaiGiang == null || fileBaiGiang.runtimeType == String) {
      curentCtdt["name"] = name;
      curentCtdt["parentId"] = parentId;
      curentCtdt["courseTime"] = courseTime;
      curentCtdt["lecturesTotal"] = lecturesTotal;
      curentCtdt["displayScore"] = displayScore;
      curentCtdt["showPassResult"] = showPassResult;
      print(curentCtdt);
      var response = await httpPut(
          '/api/daotao-chuongtrinh/put/${widget.id}', curentCtdt, context);
      if (response['body'] == 'true') {
        titleLog = 'C???p nh???t d??? li???u th??nh c??ng';
      } else {
        titleLog = 'C???p nh???t th???t b???i';
      }
      return titleLog;
    } else {
      await uploadFile(fileBaiGiang, context: context).then((value) async {
        curentCtdt["name"] = name;
        curentCtdt["parentId"] = parentId;
        curentCtdt["courseTime"] = courseTime;
        curentCtdt["lecturesTotal"] = lecturesTotal;
        curentCtdt["displayScore"] = displayScore;
        curentCtdt["showPassResult"] = showPassResult;
        if (value != 'null') {
          curentCtdt['fileUrl'] = value;
        }
        var response = await httpPut(
            '/api/daotao-chuongtrinh/put/${widget.id}', curentCtdt, context);
        print(response);
        if (response['body'] == 'true') {
          titleLog = 'C???p nh???t d??? li???u th??nh c??ng';
        } else {
          titleLog = 'C???p nh???t th???t b???i';
        }
        return titleLog;
      });
    }
  }

  bool isNumber(String string) {
    try {
      int.parse(string);
      return true;
    } catch (e) {
      return false;
    }
  }

  var newId;
  Future<dynamic> addCTDT(String name, int parentId, String? courseTime,
      int? lecturesTotal, int displayScore, int showPassResult) async {
    if (fileBaiGiang == null || fileBaiGiang.runtimeType == String) {
      var data = {
        "name": name,
        "parentId": parentId,
        "courseTime": courseTime,
        "lecturesTotal": lecturesTotal,
        "displayScore": displayScore,
        "showPassResult": showPassResult,
      };
      var response =
          await httpPost('/api/daotao-chuongtrinh/post/save', data, context);
      if (isNumber(response['body'])) {
        titleLog = 'Th??m m???i d??? li???u th??nh c??ng';
        newId = response['body'];
        return response['body'];
      } else {
        titleLog = 'Th??m m???i th???t b???i';
      }
    } else {
      await uploadFile(fileBaiGiang, context: context).then((value) async {
        var data = {
          "name": name,
          "parentId": parentId,
          "courseTime": courseTime,
          "lecturesTotal": lecturesTotal,
          "displayScore": displayScore,
          "showPassResult": showPassResult,
        };
        if (value != 'null') {
          data['fileUrl'] = value;
        }
        var response =
            await httpPost('/api/daotao-chuongtrinh/post/save', data, context);
        if (isNumber(response['body'])) {
          titleLog = 'Th??m m???i d??? li???u th??nh c??ng';
          newId = response['body'];
          return response['body'];
        } else {
          titleLog = 'Th??m m???i th???t b???i';
        }
      });
    }
  }

  Future<dynamic> getListCTDT() async {
    var listData = {};

    var response = await httpGet(
        "/api/daotao-chuongtrinh/get/page?filter=parentId:0", context);
    if (response.containsKey("body")) {
      setState(() {
        listData = jsonDecode(response["body"]);
      });
      listItemsCTDT.add({'value': '0', 'name': '---'});
      for (var row in listData['content']) {
        if (widget.id != null) {
          if (row['id'] != int.parse(widget.id!)) {
            listItemsCTDT
                .add({'value': row['id'].toString(), 'name': row['name']});
          }
        } else
          listItemsCTDT
              .add({'value': row['id'].toString(), 'name': row['name']});
      }
      return listData['content'];
    }
  }

  var listAllCtdt = [];
  getAllListCTDT() async {
    var response = await httpGet("/api/daotao-chuongtrinh/get/page", context);
    if (response.containsKey("body")) {
      setState(() {
        var listCheck = jsonDecode(response["body"])['content'];
        for (var row in listCheck) {
          if (widget.id != null) {
            if (row['id'] != int.parse(widget.id!)) {
              print('aa');
              listAllCtdt.add(row);
            }
          } else {
            listAllCtdt.add(row);
          }
        }
      });
      return 0;
    }
  }

  bool checkExists(name, parentId) {
    bool check = false;
    for (var row in listAllCtdt) {
      if (row['name'].trim() == name.trim() && row['parentId'] == parentId) {
        check = true;
        break;
      }
    }
    return check;
  }

  Future<dynamic> getClone() async {
    var listData = {};
    return listData;
  }

  var fileBaiGiang;
  int checkRequire = 1;

  @override
  void initState() {
    print(DateTime.tryParse("02-11-2022, 05:30"));
    if (widget.id != null) {
      getCtdtFuture = getCTDT();
      getCtdtFuture.then((value) {
        selectedValue = value['parentId'].toString();
        checkRequire = selectedValue == '0' ? 1 : 0;
        fileBaiGiang = value['fileUrl'];
      });
    } else
      getCtdtFuture = getClone();
    getAllListCTDT();
    getListCtdtFuture = getListCTDT();
    super.initState();
  }

  TextEditingController textCTDT = TextEditingController();
  TextEditingController textTGDT = TextEditingController();
  TextEditingController textSBG = TextEditingController();

  bool _checkPoint = false;
  bool _checkResult = false;
  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.blue;
    }
    return Colors.red;
  }

  Future<void> submit() async {
    var name, parentId, courseTime, lecturesTotal, displayScore, showPassResult;
    name = textCTDT.text;
    parentId = int.parse(selectedValue);
    if (textTGDT.text != '')
      courseTime = textTGDT.text;
    else
      courseTime = null;
    if (textSBG.text != '')
      lecturesTotal = int.parse(textSBG.text);
    else
      lecturesTotal = null;
    displayScore = _checkPoint == true ? 1 : 0;
    showPassResult = _checkResult == true ? 1 : 0;
    if (((textTGDT.text == '' || textSBG.text == '') && selectedValue == '0') ||
        textCTDT.text == '') {
      showToast(
        context: context,
        msg: 'Y??u c???u nh???p ????? d??? li???u tr?????c khi th??m m???i ho???c ch???nh s???a',
        color: Colors.red,
        icon: const Icon(Icons.warning),
      );
    } else if (checkExists(textCTDT.text, int.parse(selectedValue))) {
      showToast(
        context: context,
        msg: 'Ch????ng tr??nh ????o t???o ???? t???n t???i',
        color: Colors.red,
        icon: const Icon(Icons.warning),
      );
    } else {
      if (widget.id != null) {
        await updateCTDT(name, parentId, courseTime, lecturesTotal,
            displayScore, showPassResult);

        Provider.of<NavigationModel>(context, listen: false)
            .add(pageUrl: "/quan-ly-chuong-trinh-dao-tao");
        showToast(
          context: context,
          msg: titleLog,
          color: titleLog == "C???p nh???t d??? li???u th??nh c??ng"
              ? Color.fromARGB(136, 72, 238, 67)
              : Colors.red,
          icon: titleLog == "C???p nh???t d??? li???u th??nh c??ng"
              ? Icon(Icons.done)
              : Icon(Icons.warning),
        );
      } else {
        await addCTDT(name, parentId, courseTime, lecturesTotal, displayScore,
            showPassResult);
        Provider.of<NavigationModel>(context, listen: false)
            .add(pageUrl: "/quan-ly-chuong-trinh-dao-tao");
        showToast(
          context: context,
          msg: titleLog,
          color: titleLog == "Th??m m???i d??? li???u th??nh c??ng"
              ? Color.fromARGB(136, 72, 238, 67)
              : Colors.red,
          icon: titleLog == "Th??m m???i d??? li???u th??nh c??ng"
              ? Icon(Icons.done)
              : Icon(Icons.warning),
        );
      }
    }
    setState(() {});
  }

  dynamic selectedCategory = '0';
  dynamic selectedValue = '0';

  List<String> itemsCategory = ['Nh??m ch??nh'];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: userRule('/them-moi-cap-nhat-chuong-trinh-dao-tao', context),
      builder: (context, listRule) {
        if (listRule.hasData) {
          return FutureBuilder<dynamic>(
            future: getCtdtFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return ListView(
                  children: [
                    TitlePage(
                      listPreTitle: [
                        {'url': '/bang-thong-ke-nhanh', 'title': 'Dashboard'},
                        {
                          'url': '/quan-ly-chuong-trinh-dao-tao',
                          'title': 'Qu???n l?? ch????ng tr??nh ????o t???o'
                        }
                      ],
                      content: widget.id == null
                          ? "Th??m m???i ch????ng tr??nh ????o t???o"
                          : "C???p nh???t ch????ng tr??nh ????o t???o",
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 1,
                      // margin: marginTopBoxContainer,
                      padding: paddingBoxContainer,
                      child: Container(
                        margin: EdgeInsets.only(top: 20),
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
                              SelectableText(
                                'Nh???p th??ng tin ',
                                style: titleBox,
                              ),
                              Icon(
                                Icons.more_horiz,
                                color: Color(0xff9aa5ce),
                                size: 14,
                              ),
                            ],
                          ),
                          //???????ng line
                          Container(
                            margin: marginTopBottomHorizontalLine,
                            child: Divider(
                              thickness: 1,
                              color: ColorHorizontalLine,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                  child: TextFieldValidatedForm(
                                height: 40,
                                label: 'T??n ch????ng tr??nh ????o t???o/B??i gi???ng',
                                type: 'Text',
                                controller: textCTDT,
                                flexLable: 8,
                                flexTextField: 10,
                                enter: () {
                                  submit();
                                },
                                requiredValue: 1,
                              )),
                              Expanded(
                                  child: Row(
                                children: [
                                  SizedBox(
                                    width: 100,
                                  ),
                                  Expanded(
                                    child: TextFieldValidatedForm(
                                      height: 40,
                                      label: 'Th???i gian ????o t???o',
                                      type: 'Text',
                                      controller: textTGDT,
                                      flexLable: 2,
                                      flexTextField: 4,
                                      require: checkRequire == 1 ? false : true,
                                      requiredValue: checkRequire,
                                      enter: () {
                                        submit();
                                      },
                                    ),
                                  ),
                                ],
                              )),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 40),
                                  child: FutureBuilder<dynamic>(
                                    future: getListCtdtFuture,
                                    builder: (context, listCTDT) {
                                      if (listCTDT.hasData) {
                                        return Container(
                                          color: Colors.white,
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25,
                                          height: 40,
                                          child: DropdownBtnSearch(
                                            isAll: false,
                                            label: 'Thu???c danh m???c',
                                            flexLabel: 8,
                                            flexDropdown: 10,
                                            listItems: listItemsCTDT,
                                            search: searchCTDT,
                                            isSearch: true,
                                            selectedValue: selectedValue,
                                            setSelected: (selected) {
                                              selectedValue = selected;
                                              if (selectedValue == '0') {
                                                checkRequire = 1;
                                              } else {
                                                checkRequire = 0;
                                              }
                                              setState(() {});
                                            },
                                          ),
                                        );
                                      } else if (listCTDT.hasError) {
                                        return SelectableText(
                                            '${listCTDT.error}');
                                      }

                                      // By default, show a loading spinner.
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Row(
                                children: [
                                  SizedBox(
                                    width: 100,
                                  ),
                                  Expanded(
                                    child: TextFieldValidatedForm(
                                      controller: textSBG,
                                      height: 40,
                                      label: 'S??? l?????ng b??i gi???ng',
                                      flexLable: 2,
                                      flexTextField: 4,
                                      type: 'Number',
                                      require: checkRequire == 1 ? false : true,
                                      requiredValue: checkRequire,
                                      enter: () {
                                        submit();
                                      },
                                    ),
                                  ),
                                ],
                              ))
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(bottom: 30),
                                  child: Row(children: [
                                    Expanded(
                                        flex: 8,
                                        child: Text(
                                          "File b??i gi???ng",
                                          style: titleWidgetBox,
                                        )),
                                    Expanded(
                                        flex: 10,
                                        child: TextButton(
                                          onPressed: () async {
                                            var file = await FilePicker.platform
                                                .pickFiles(
                                              type: FileType.custom,
                                              allowedExtensions: [],
                                              withReadStream: true, //
                                            );
                                            fileBaiGiang = file;

                                            setState(() {});
                                          },
                                          child: fileBaiGiang == null
                                              ? Icon(Icons.upload_file)
                                              : Text(
                                                  "${fileBaiGiang.runtimeType == String ? fileBaiGiang : fileBaiGiang!.files.first.name}"),
                                        ))
                                  ]),
                                ),
                              ),
                              Expanded(
                                  child: Row(
                                children: [
                                  SizedBox(
                                    width: 100,
                                  ),
                                  Expanded(child: Container()),
                                ],
                              ))
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Checkbox(
                                  checkColor: Colors.white,
                                  value: _checkPoint,
                                  onChanged: (value) {
                                    setState(() {
                                      _checkPoint = value!;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: SelectableText(
                                  'Hi???n th??? ??i???m',
                                  style: TextStyle(
                                    color: Color(0xff333333),
                                    fontSize: 16,
                                  ),
                                ),
                                flex: 25,
                              )
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 1,
                                child: Checkbox(
                                  checkColor: Colors.white,
                                  value: _checkResult,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      _checkResult = value!;
                                    });
                                  },
                                ),
                              ),
                              Expanded(
                                child: SelectableText(
                                  'Hi???n th??? k???t qu??? (?????t/Kh??ng ?????t)',
                                  style: TextStyle(
                                    color: Color(0xff333333),
                                    fontSize: 16,
                                  ),
                                ),
                                flex: 25,
                              )
                            ],
                          ),

                          SizedBox(
                            height: 25,
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
                                    backgroundColor: Colors.grey,
                                    primary: Theme.of(context).iconTheme.color,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .caption
                                        ?.copyWith(
                                            fontSize: 10.0, letterSpacing: 2.0),
                                  ),
                                  onPressed: () {
                                    Provider.of<NavigationModel>(context,
                                            listen: false)
                                        .add(
                                            pageUrl:
                                                "/quan-ly-chuong-trinh-dao-tao");
                                    setState(() {});
                                  },
                                  child: Row(
                                    children: [
                                      Text('H???y', style: textButton),
                                    ],
                                  ),
                                ),
                              ),
                              widget.id == null
                                  ? getRule(listRule.data, Role.Them, context)
                                      ? Container(
                                          margin: EdgeInsets.only(left: 20),
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 20.0,
                                                horizontal: 10.0,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                              backgroundColor: Color.fromRGBO(
                                                  245, 117, 29, 1),
                                              primary: Theme.of(context)
                                                  .iconTheme
                                                  .color,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  ?.copyWith(
                                                      fontSize: 10.0,
                                                      letterSpacing: 2.0),
                                            ),
                                            onPressed: () async {
                                              submit();
                                            },
                                            child: Row(
                                              children: [
                                                Text('L??u', style: textButton),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container()
                                  : getRule(listRule.data, Role.Sua, context)
                                      ? Container(
                                          margin: EdgeInsets.only(left: 20),
                                          child: TextButton(
                                            style: TextButton.styleFrom(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                vertical: 20.0,
                                                horizontal: 10.0,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                              backgroundColor: Color.fromRGBO(
                                                  245, 117, 29, 1),
                                              primary: Theme.of(context)
                                                  .iconTheme
                                                  .color,
                                              textStyle: Theme.of(context)
                                                  .textTheme
                                                  .caption
                                                  ?.copyWith(
                                                      fontSize: 10.0,
                                                      letterSpacing: 2.0),
                                            ),
                                            onPressed: () async {
                                              submit();
                                            },
                                            child: Row(
                                              children: [
                                                Text('L??u', style: textButton),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Container(),
                            ],
                          )
                        ]),
                      ),
                    ),
                    Footer()
                  ],
                );
              } else if (snapshot.hasError) {
                return SelectableText('${snapshot.error}');
              }
              // By default, show a loading spinner.
              return const Center(child: CircularProgressIndicator());
            },
          );
        } else if (listRule.hasError) {
          return SelectableText('${listRule.error}');
        }

        // By default, show a loading spinner.
        return Center(child: CircularProgressIndicator());
      },
    );
  }
}

//Pop-up th??nh c??ng
class Successful extends StatefulWidget {
  final String title;
  const Successful({Key? key, required this.title}) : super(key: key);

  @override
  State<Successful> createState() => _SuccessfulState();
}

class _SuccessfulState extends State<Successful> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  child: Image.asset('images/logoAAM.png'),
                  margin: EdgeInsets.only(right: 10),
                ),
                SelectableText(
                  widget.title,
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
    );
  }
}

// getFileSize( file) async {
//     var file = File(filepath);
//     int bytes = await file.length();
//     if (bytes <= 0) return "0 B";
//     const suffixes = ["B", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
//     var i = (log(bytes) / log(1024)).floor();
//     return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + ' ' + suffixes[i];
// }
double getFileSize(file) {
  int sizeInBytes = file.lengthSync();
  double sizeInMb = sizeInBytes / (1024 * 1024);
  return sizeInMb;
}
