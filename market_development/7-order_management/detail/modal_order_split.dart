import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';

import 'package:flutter/material.dart';

import 'package:gentelella_flutter/widgets/forms/market_development/utils/funciton.dart';

import '../../../../../api.dart';
import '../../../../../common/style.dart';
import '../../../../../common/toast.dart';

import '../../../../../model/market_development/user.dart';
import '../../../../../model/market_development/xinghiep.dart';

class ModalOrderSplit extends StatefulWidget {
  final dynamic orderCopy;
  final int? id;
  final List<User>? listTTSDonHang;
  final Function? func;
  ModalOrderSplit({Key? key, this.orderCopy, this.id, this.listTTSDonHang, this.func}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ModalOrderSplitState();
  }
}

class _ModalOrderSplitState extends State<ModalOrderSplit> {
  int? _selectedEnterprise;
  bool isValidateForm = false;
  Future<List<Enterprise>> getListEnterpriseByOrgId(int orgId) async {
    List<Enterprise> list = [];
    var response;
    Map<String, String> requestParam = Map();

    response = await httpGet("/api/xinghiep/get/page?sort=id&filter=orgId:${orgId}", context);

    var body = jsonDecode(response['body']);
    var content = [];

    if (response.containsKey("body")) {
      content = body['content'];
    }
    list = content.map((e) {
      return Enterprise.fromJson(e);
    }).toList();

    return list;
  }

  Future<int> saveTtsDonHangCopy(dynamic requestBody) async {
    try {
      var response = await httpPost(Uri.parse('/api/donhang/post/save'), requestBody, context); //Tra ve id
      var idAdd = jsonDecode(response['body']).toString();
      if (isNumber(idAdd)) {
        return int.parse(idAdd);
      }
    } catch (_) {
      print("Fail!");
    }
    return -1;
  }

  Future<bool> updateTtsDonhang(dynamic requestBody, int id) async {
    try {
      var response = await httpPut(Uri.parse('/api/donhang-tts-tiencu/put/$id'), requestBody, context); //Tra ve id
      if (jsonDecode(response['body']) == true) {
        return true;
      } else {
        return false;
      }
    } catch (_) {
      print("Fail!");
    }
    return false;
  }

  Future<bool> putNguoiDung(int id, requestBody, context) async {
    try {
      var response = await httpPut("/api/nguoidung/put/$id", requestBody, context);
      var body = jsonDecode(response['body']);
      if (body.containsKey("1")) {
        return true;
      }
    } catch (e) {
      print("Fail! ${e}");
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
  }

  hanleMoveEnterprise(dynamic requestBody, List<User> listTtsDonHang) async {
    print(requestBody);
    int resultSave = await saveTtsDonHangCopy(requestBody);
    int countUpdateSucces = 0;
    if (resultSave != -1) {
      for (int i = 0; i < listTtsDonHang.length; i++) {
        var requestUpdate = {"orderId": resultSave, "isTts": 1};
        bool resultUpdate = await putNguoiDung(listTtsDonHang[i].id, requestUpdate, context);
        if (resultUpdate) {
          countUpdateSucces++;
        }
      }
    }
    if (countUpdateSucces == listTtsDonHang.length) {
      showToast(context: context, msg: "Chuyển thành công !", color: Colors.green, icon: Icon(Icons.supervised_user_circle));
      widget.func!();
      Navigator.pop(context);
    } else {
      showToast(context: context, msg: "Thất bại!", color: Colors.red, icon: Icon(Icons.supervised_user_circle));
      widget.func!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Image.asset(
            "assets/images/logoAAM.png",
            width: 30,
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Text('Chuyển TTS sang xí nghiệp mới'),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close)),
            ),
          )
        ],
      ),
      content: Container(
        height: 120,
        width: 600,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ),
            Container(
              child: Column(
                children: [
                  Container(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text('Xí nghiệp', style: titleBox),
                                ),
                                Expanded(
                                  flex: 5,
                                  child: Container(
                                    color: Colors.white,
                                    // width: MediaQuery.of(context).size.width * 0.15,
                                    height: 40,
                                    child: DropdownSearch<Enterprise>(
                                      mode: Mode.MENU,
                                      showSearchBox: true,
                                      onFind: (String? filter) => getListEnterpriseByOrgId(widget.orderCopy["orgId"]!),
                                      itemAsString: (Enterprise? u) => u!.companyName,
                                      emptyBuilder: (context, String? value) {
                                        return const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          child: Align(alignment: Alignment.center, child: Text("Không có dữ liệu !")),
                                        );
                                      },
                                      dropdownSearchDecoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.all(8),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedEnterprise = value!.id;

                                          print(_selectedEnterprise);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    child: isValidateForm
                        ? Text(
                            "Vui lòng chọn xí nghiệp !",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                              fontStyle: FontStyle.italic,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        : null,
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
              child: Divider(
                thickness: 1,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          // textColor: Color(0xFF6200EE),
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Hủy',
            style: TextStyle(),
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.transparent,
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
          onPressed: () {
            if (widget.orderCopy['companyId'] != null) {
              widget.orderCopy['companyId'] = _selectedEnterprise;
            }
            if (widget.orderCopy['nominateStatus'] != null) {
              widget.orderCopy['nominateStatus'] = 1;
            }

            if (_selectedEnterprise != null) {
              setState(() {
                isValidateForm = false;
              });
            } else {
              setState(() {
                isValidateForm = true;
              });
            }
            if (isValidateForm == false) {
              hanleMoveEnterprise(widget.orderCopy, widget.listTTSDonHang!);
            }
          },
          child: Text(
            'Chuyển',
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
