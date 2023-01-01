import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:gentelella_flutter/widgets/forms/market_development/utils/form.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import '../../../../../api.dart';
import '../../../../../common/toast.dart';
import '../../../../../model/market_development/order.dart';

class ModelGuiMail extends StatefulWidget {
  final Order? order;
  ModelGuiMail({Key? key, this.order}) : super(key: key);

  @override
  State<ModelGuiMail> createState() => _ModelGuiMailState();
}

class _ModelGuiMailState extends State<ModelGuiMail> {
  @override
  void initState() {
    super.initState();
    _emailController.text = widget.order!.union!.email!;
  }

  TextEditingController _emailController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();

  String? fileName;
  bool _setLoading = false;
  bool _validate = false;
  dynamic file;

  double? heightErrorTieuDe;
  String? errorTieuDe;

  double? heightErrorNoiDung;
  String? errorNoiDung;

  final _myWidgetTieuDe = GlobalKey<TextFieldValidatedMarketState>();
  final _myWidgetNoiDung = GlobalKey<TextFieldValidatedMarketState>();
  bool _hienQuaTrinh = false;
  double _phanTram = 0.0;
  String _ketQua = "Đang gửi mail.Vui lòng đợi chút!";
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _titleController.dispose();
    _contentController.dispose();
  }

  Future selectedFile() async {
    var image = await FilePicker.platform.pickFiles(
      withReadStream: true,
    );

    setState(() {
      file = image;
      if (image!.files.length > 0) {
        fileName = image.files.first.name;
        print(fileName);
      }
    });
  }

  sendEmail(dynamic requestBody) async {
    try {
      print("OOOOO");
      Map<String, String> headers = {'content-type': 'application/json'};
      var finalRequestBody = jsonEncode(requestBody);
      print("Duma $requestBody");
      var response = await httpPost(Uri.parse('/api/utils/post/mail'), requestBody, context);
      //Tra ve id
      print("11111");

      return response['body'].toString();
    } catch (e) {
      print("Fail! $e");
    }
    return "Gửi mail thất bại";
  }

  int countErrorWhenSubmit() {
    int count = 0;
    if (_contentController.text.isEmpty) {
      count++;
    }
    if (_titleController.text.isEmpty) {
      count++;
    }
    return count;
  }

  final formGlobalKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            flex: 5,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              height: 70,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 5,
                    child: SizedBox(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Container(
                              width: 50,
                              height: 50,
                              child: Image.asset('images/logoAAM.png'),
                              margin: EdgeInsets.only(right: 10),
                            ),
                          ),
                          Expanded(flex: 4, child: Text('Gửi email')),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      content: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          height: 1000,
          child: Form(
            key: formGlobalKey,
            child: ListView(
              children: [
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: TextFieldValidatedMarket(
                            type: "Text",
                            labe: "Email nghiệp đoàn",
                            isReverse: false,
                            controller: _emailController,
                          ),
                        ),
                        Expanded(flex: 1, child: Container()),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: TextFieldValidatedMarket(
                            key: _myWidgetTieuDe,
                            type: "Text",
                            labe: "Tiêu đề",
                            isReverse: false,
                            controller: _titleController,
                          ),
                        ),
                        Expanded(flex: 1, child: Container()),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: TextFieldValidatedMarket(
                            hint: "Nhập nội dung  ",
                            key: _myWidgetNoiDung,
                            height: 100,
                            type: "Text",
                            labe: "Nội dung",
                            isReverse: false,
                            controller: _contentController,
                          ),
                        ),
                        Expanded(flex: 1, child: Container()),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Text(
                              "Chọn file tải lên",
                              style: TextStyle(fontWeight: FontWeight.w800),
                            )),
                        Expanded(
                            flex: 5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.upload_file),
                                  tooltip: 'Upload file',
                                  onPressed: () async {
                                    selectedFile();
                                    print("123");
                                  },
                                ),
                                file != null
                                    ? Expanded(flex: 1, child: Text(fileName!))
                                    : _validate
                                        ? Expanded(
                                            flex: 1,
                                            child: Text(
                                              "Vui lòng chọn file !",
                                              style: TextStyle(color: Colors.red, fontSize: 14),
                                            ),
                                          )
                                        : Text(""),
                              ],
                            )),
                      ],
                    ),
                    _hienQuaTrinh
                        ? Row(
                            children: [
                              Expanded(
                                child: new LinearPercentIndicator(
                                  animation: true,
                                  lineHeight: 20.0,
                                  animationDuration: 2500,
                                  percent: _phanTram,
                                  center: Text(_ketQua),
                                  linearStrokeCap: LinearStrokeCap.roundAll,
                                  progressColor: Colors.green,
                                ),
                              ),
                            ],
                          )
                        : Container()

                    // _setLoading
                    //     ? Row(
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: [
                    //           Expanded(
                    //               flex: 1,
                    //               child: Center(
                    //                 child: Column(
                    //                   children: [CircularProgressIndicator(), Text("Vui lòng đợi chút !")],
                    //                 ),
                    //               ))
                    //         ],
                    //       )
                    //     : Container(),
                  ],
                )
              ],
            ),
          )),
      actions: <Widget>[
        ElevatedButton(
          // textColor: Color(0xFF6200EE),
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Hủy',
            style: TextStyle(),
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.black,
            onPrimary: Colors.white,
            // shadowColor: Colors.greenAccent,
            elevation: 3,
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(32.0)),
            minimumSize: Size(140, 50), //////// HERE
          ),
        ),
        ElevatedButton(
          // textColor: Color(0xFF6200EE),
          onPressed: () async {
            int countSelected = 0;
            _myWidgetTieuDe.currentState!.validate();
            _myWidgetNoiDung.currentState!.validate();
            if (formGlobalKey.currentState!.validate()) {
              formGlobalKey.currentState!.save();

              setState(() {
                _setLoading = true;
                _hienQuaTrinh = true;
              });
              var resultFile = await uploadFile(file, context: context);
              print("123");
              var requestEmail = {
                "mailTo": _emailController.text,
                "title": _titleController.text,
                "content": _contentController.text,
                "attachFiles": [resultFile]
              };
              print(requestEmail);
              if (countErrorWhenSubmit() == 0 && countSelected == 0) {
                var result = await sendEmail(requestEmail);
                print(result);
                if (result != -1) {
                  showToast(context: context, msg: result.toString(), color: Colors.green, icon: Icon(Icons.supervised_user_circle));
                  setState(() {
                    _setLoading = true;
                    _hienQuaTrinh = true;
                    _ketQua = result.toString();
                    _phanTram = _phanTram + (1 - _phanTram);
                  });
                  return;
                } else {
                  showToast(context: context, msg: result.toString(), color: Colors.red, icon: Icon(Icons.supervised_user_circle));
                  setState(() {
                    _ketQua = result.toString();
                    _setLoading = false;
                  });
                }
              }
            }
            if (file == null) {
              setState(() {
                _validate = true;
              });
            } else {
              _validate = false;
            }
          },
          child: Text(
            'Xác nhận',
            style: TextStyle(),
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.orange[400],
            onPrimary: Colors.white,
            // shadowColor: Colors.greenAccent,
            elevation: 3,
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(32.0)),
            minimumSize: Size(140, 50), //////// HERE
          ),
        ),
      ],
    );
  }
}
