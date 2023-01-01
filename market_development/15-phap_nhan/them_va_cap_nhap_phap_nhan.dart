// ignore: duplicate_ignore
// ignore_for_file: must_be_immutable, duplicate_ignore

import 'dart:convert';
import 'dart:typed_data';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:gentelella_flutter/common/toast.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import 'package:gentelella_flutter/model/market_development/phapnhan.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/add/union_information.dart';

import 'package:provider/provider.dart';
import '../../../../api.dart';

import '../../../../common/style.dart';

import '../../../../common/widgets_form.dart';
import '../../../../config.dart';
import '../../../../model/market_development/job.dart';
import '../../../../model/model.dart';
import '../../../forms/market_development/utils/form.dart';
import '../../../ui/navigation.dart';

class FormAddAndUpdatePhapNhan extends StatefulWidget {
  int? id;
  FormAddAndUpdatePhapNhan({Key? key, this.id}) : super(key: key);

  @override
  State<FormAddAndUpdatePhapNhan> createState() => _FormAddAndUpdatePhapNhanState();
}

class _FormAddAndUpdatePhapNhanState extends State<FormAddAndUpdatePhapNhan> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: FormAddAndUpdatePhapNhanBody(id: widget.id));
  }
}

class FormAddAndUpdatePhapNhanBody extends StatefulWidget {
  int? id;
  FormAddAndUpdatePhapNhanBody({Key? key, this.id}) : super(key: key);

  @override
  State<FormAddAndUpdatePhapNhanBody> createState() => _FormAddAndUpdatePhapNhanBodyState();
}

class _FormAddAndUpdatePhapNhanBodyState extends State<FormAddAndUpdatePhapNhanBody> {
  int? selectedTrangThai;
  TextEditingController tenPhanNhanController = TextEditingController();
  TextEditingController moTaPhapNhanController = TextEditingController();

  bool _setLoading = true;
  PhapNhan? phapNhan;
  double? heightErrorTieuDeNganhNghe;
  String? errorTieuDeNganhNghe;

  Future<PhapNhan> getPhapNhan(int id) async {
    var response = await httpGet("/api/phapnhan/get/$id", context);

    var body = jsonDecode(response['body']);

    if (response.containsKey("body")) {
      setState(() {
        phapNhan = PhapNhan.fromJson(body);
        tenPhanNhanController.text = phapNhan!.name!;
        moTaPhapNhanController.text = phapNhan!.description!;
        fileName = phapNhan!.image;
        selectedTrangThai = phapNhan!.status;
      });
    }
    return PhapNhan.fromJson(body);
  }

  Future<int> saveDataPhapNhan(dynamic requestBody) async {
    try {
      var response = await httpPost(Uri.parse('/api/phapnhan/post/save'), requestBody, context); //Tra ve id

      return jsonDecode(response['body']);
    } catch (_) {
      print("Fail!");
    }
    return -1;
  }

  Future<bool> updateDataPhapNhan(dynamic requestBody, int id) async {
    try {
      var response = await httpPut(Uri.parse('/api/phapnhan/put/$id'), requestBody, context); //Tra ve id

      return jsonDecode(response['body']);
    } catch (_) {
      print("Fail!");
    }
    return false;
  }

  Uint8List? bytesImage;

  Map<int, String> _mapStatusofUnion = {
    0: ' Không hoạt động',
    1: ' Hoạt động',
  };

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      getPhapNhan(widget.id!);
    }
  }

  Widget getImage({id, fileName, bytesImage}) {
    if (bytesImage != null) {
      return Image.memory(Uint8List.fromList(bytesImage!));
    }
    if (fileName == null) {
      return Container();
    }
    return Image.network("$baseUrl/api/files/$fileName");
  }

  void dipose() {
    super.dispose();
  }

  String? fileName;

  final _myWidgetTenPhapNhan = GlobalKey<TextFieldValidatedMarketState>();

  final formGlobalKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: userRule('/them-moi-nganh-nghe', context),
        builder: (context, listRule) {
          if (listRule.hasData) {
            return Consumer<NavigationModel>(
                builder: (context, navigationModel, child) => _setLoading
                    ? ListView(
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
                                {'url': '/quan-ly-phap-nhan', 'title': 'Quản lý pháp nhân'},
                                widget.id == null ? {'url': '', 'title': 'Thêm mới'} : {'url': '', 'title': 'Cập nhật'}
                              ],
                              content: widget.id == null ? 'Thêm mới' : 'Cập nhật',
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
                                      'Nhập thông tin pháp nhân',
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
                                    children: [
                                      Expanded(
                                        flex: 5,
                                        child: Container(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              TextFieldValidatedMarket(
                                                flexLable: 1,
                                                flexTextField: 4,
                                                key: _myWidgetTenPhapNhan,
                                                labe: 'Tên pháp nhân',
                                                isReverse: false,
                                                type: 'Text',
                                                controller: tenPhanNhanController,
                                                isShowDau: true,
                                              ),
                                            ], //coloumn --------------------------
                                          ),
                                        ),
                                      ),
                                      Expanded(flex: 1, child: Container())
                                    ],
                                  ),
                                ),

                                Container(
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Row(
                                          children: [
                                            Text('Trạng thái ', style: titleWidgetBox),
                                            Text('* ', style: TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Container(
                                          // width: MediaQuery.of(context).size.width * 0.15,
                                          height: 40,
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton2(
                                              buttonDecoration: BoxDecoration(border: Border.all(width: 0.5, style: BorderStyle.solid)),
                                              buttonPadding: EdgeInsets.only(left: 8),
                                              hint: Text('${_mapStatusofUnion[0]}', style: TextStyle(fontSize: 16, color: Theme.of(context).hintColor)),
                                              items: _mapStatusofUnion.entries
                                                  .map((item) => DropdownMenuItem<int>(value: item.key, child: Text(item.value, style: const TextStyle(fontSize: 16))))
                                                  .toList(),
                                              value: selectedTrangThai,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedTrangThai = value as int?;
                                                });
                                              },
                                              buttonHeight: 40,
                                              itemHeight: 40,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(child: Container())
                                    ],
                                  ),
                                ),

                                Container(
                                  margin: EdgeInsets.only(top: 30),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Container(),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Row(
                                          children: [
                                            Expanded(
                                                flex: 2,
                                                child: Container(
                                                  height: 200,
                                                  width: 200,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.black, width: 2.0, style: BorderStyle.solid),
                                                  ),
                                                  child: getImage(fileName: fileName, bytesImage: bytesImage),
                                                )),
                                            Expanded(
                                              flex: 2,
                                              child: Container(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(flex: 1, child: Container())
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 30),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: Text('Upload hình ảnh', style: titleWidgetBox),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                  child: ElevatedButton(
                                                child: Text('Tải ảnh lên'),
                                                onPressed: () async {
                                                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                                                    type: FileType.custom,
                                                    allowedExtensions: ['png', 'JPEG', 'JPG', 'TIFF', 'GIF'],
                                                    withReadStream: false,
                                                    allowMultiple: false,
                                                  );
                                                  if (result != null) {
                                                    setState(() {
                                                      fileName = result.files.first.name;
                                                      bytesImage = result.files.first.bytes;
                                                      print(bytesImage);
                                                    });
                                                  } else {
                                                    return showToast(
                                                      context: context,
                                                      msg: "File chưa được chọn",
                                                      color: Color.fromRGBO(245, 117, 29, 1),
                                                      icon: const Icon(Icons.info),
                                                    );
                                                  }
                                                },
                                              )),
                                            ),
                                            Expanded(flex: 2, child: Container())
                                          ],
                                        ),
                                      ),
                                      Expanded(flex: 1, child: Container())
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 30),
                                  child: Row(
                                    children: [
                                      Expanded(flex: 1, child: Text("Mô tả", style: titleWidgetBox)),
                                      Expanded(
                                        flex: 4,
                                        child: Container(
                                          child: TextFormField(
                                            controller: moTaPhapNhanController,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(0)),
                                              ),
                                            ),
                                            minLines: 6, // any number you need (It works as the rows for the textarea)
                                            keyboardType: TextInputType.multiline,
                                            maxLines: 6,
                                          ),
                                        ),
                                      ),
                                      Expanded(flex: 1, child: Container()),
                                    ],
                                  ),
                                ),
                                Container(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      getRule(listRule.data, widget.id == null ? Role.Them : Role.Sua, context)
                                          ? Container(
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
                                                  textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                                ),
                                                onPressed: () async {
                                                  int count = 0;
                                                  if (tenPhanNhanController.text.isEmpty) {
                                                    count++;
                                                  }
                                                  if (selectedTrangThai == null) {
                                                    count++;
                                                  }
                                                  if (count > 0) {
                                                    showToast(context: context, msg: "Vui lòng nhập đầy đủ thông tin!", color: Colors.red, icon: Icon(Icons.warning));
                                                    return;
                                                  }
                                                  var fileNameWhenUpload = await uploadFileByte(bytesImage, context: context, fileName: fileName);

                                                  var requestBody = {
                                                    "name": tenPhanNhanController.text,
                                                    "description": moTaPhapNhanController.text,
                                                    "image": fileNameWhenUpload,
                                                    "status": selectedTrangThai == null ? 1 : selectedTrangThai
                                                  };

                                                  if (widget.id != null) {
                                                    bool result = await updateDataPhapNhan(requestBody, widget.id!);
                                                    if (result) {
                                                      showToast(context: context, msg: "Cập nhật thành công !", color: Colors.green, icon: Icon(Icons.supervised_user_circle));
                                                      navigationModel.add(pageUrl: "/quan-ly-phap-nhan");
                                                    } else {
                                                      showToast(context: context, msg: "Thất bại!", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
                                                    }
                                                  } else {
                                                    int result = await saveDataPhapNhan(requestBody);
                                                    if (result != -1) {
                                                      showToast(context: context, msg: "Thêm mới thành công", color: Colors.green, icon: Icon(Icons.supervised_user_circle));
                                                      navigationModel.add(pageUrl: "/quan-ly-phap-nhan");
                                                    } else {
                                                      showToast(context: context, msg: "Thêm mới thất bại!", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
                                                    }
                                                  }
                                                },
                                                child: Row(children: [
                                                  Container(
                                                    // padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8.0),
                                                    child: Text('Lưu', style: textButton),
                                                  ),
                                                ]),
                                              ),
                                            )
                                          : Container(),
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
                                                textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                                              ),
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder: (BuildContext context) => ModelConfirmUnion(url: "/quan-li-nganh-nghe"),
                                                );
                                              },
                                              child: Row(children: [
                                                Container(
                                                    // padding: EdgeInsets.all(8),
                                                    child: Text('Hủy', style: textButton)),
                                              ]))),
                                    ],
                                  ),
                                )
                                //--------------------------------
                              ],
                            ),
                          ),
                          Footer()
                        ],
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ));
          } else if (listRule.hasError) {
            return Text('${listRule.error}');
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
