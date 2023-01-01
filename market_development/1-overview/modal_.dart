import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/style.dart';

import 'package:provider/provider.dart';

import '../../../../../api.dart';
import '../../../../../common/toast.dart';
import '../../../../../model/market_development/order.dart';
import '../../../../../model/market_development/thong_tin_dao_tao_tieng_nhat.dart';

import '../../../../../model/market_development/user.dart';
import '../../../../../model/model.dart';
import '../../../../config.dart';
import 'model_gui_email.dart';
import 'package:http/http.dart' as http;

// ignore: must_be_immutable
class ModelDanhSach extends StatefulWidget {
  Function? func;
  int? orderId;
  Order? order;
  ModelDanhSach({Key? key, this.orderId, this.order}) : super(key: key);

  @override
  State<ModelDanhSach> createState() => _ModelDanhSachState();
}

class _ModelDanhSachState extends State<ModelDanhSach> {
  bool _setLoading = false;

  List<ThongTinDaoTaoTiengNhat> listThongTinDaoTaoTiengNhat = [];
  late Future<List<ThongTinDaoTaoTiengNhat>> futureListThongTinDaoTaoTiengNhat;
  Future<List<User>> getListUserByOrderId(int id) async {
    var response = await httpGet("/api/nguoidung/get/page?filter=isTts:1 AND orderId:${id}", context);

    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
      });
    }

    return content.map((e) {
      return User.fromJson(e);
    }).toList();
  }

  Future<List<ThongTinDaoTaoTiengNhat>> getThongTinDaoTaoTiengNhat(List<User> listUser) async {
    if (listUser.isNotEmpty) {
      String condition = "";

      for (int i = 0; i < listUser.length; i++) {
        if (i == 0) {
          condition += " ${listUser[i].id} ";
        } else {
          condition += " ,${listUser[i].id} ";
        }
      }
      var response = await httpGet("/api/tts-thongtindaotao-tiengnhat/get/page?filter=ttsId in (${condition})", context);

      var body = jsonDecode(response['body']);
      var content = [];
      if (response.containsKey("body")) {
        setState(() {
          content = body['content'];
        });
      }

      return content.map((e) {
        return ThongTinDaoTaoTiengNhat.fromJson(e);
      }).toList();
    }
    return [];
  }

  initData() async {
    if (widget.orderId != null) {
      setState(() {
        _setLoading = true;
      });
      List<User> listUser = await getListUserByOrderId(widget.orderId!);

      if (listUser.length > 0) {
        List<ThongTinDaoTaoTiengNhat> listThongTinDaoTaoTiengNhat1 = await getThongTinDaoTaoTiengNhat(listUser);
        setState(() {
          listThongTinDaoTaoTiengNhat = listThongTinDaoTaoTiengNhat1;
        });
      }

      setState(() {
        _setLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    initData();
  }

  downLoadFileZip(List<ThongTinDaoTaoTiengNhat> listThongTinDaoTao) async {
    List<String> listFileName = [];
    if (listThongTinDaoTao.length > 0) {
      for (var item in listThongTinDaoTao) {
        listFileName.add(item.reportFile!);
      }
    } else {
      showToast(context: context, msg: "Không có file để tải về !", color: Color.fromARGB(135, 247, 217, 179), icon: Icon(Icons.supervised_user_circle));
      return;
    }
    try {
      var securityModel = Provider.of<SecurityModel>(context, listen: false);
      Map<String, String> headers = {'content-type': 'application/json'};
      if (securityModel.authorization != null) {
        headers["Authorization"] = "aam " + securityModel.authorization!;
      }

      var finalRequestBody = json.encode(listFileName);
      var response = await http.post(Uri.parse('$baseUrl/api/utils/files/zip'), headers: headers, body: finalRequestBody); //Tra ve id

      final _base64 = base64Encode(response.bodyBytes);
      final anchor = AnchorElement(href: 'data:application/octet-stream;base64,$_base64')..target = 'blank';

      anchor.download = "file.zip";

      // trigger download
      document.body!.append(anchor);
      anchor.click();
      anchor.remove();
      return;
    } catch (e) {
      print("Fail! ${e}");
    }
    return "Tải file không thành công !";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Container(
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
                            child: Image.asset('assets/images/logoAAM.png'),
                            margin: EdgeInsets.only(right: 10),
                          ),
                        ),
                        Expanded(
                          flex: 4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Danh sách thực tập sinh thuộc đơn hàng "' + widget.order!.orderName + '"',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                              ),
                              // Center(child: Text(widget.order!.orderName)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          height: 1000,
          child: ListView(
            children: [
              //DataTable(),
              //Start Datatable
              !_setLoading
                  ? Container(
                      width: MediaQuery.of(context).size.width * 1,
                      child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
                        return Center(
                            child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(minWidth: constraints.maxWidth),
                            child: DataTable(
                              dataTextStyle: const TextStyle(color: Color(0xff313131), fontSize: 14, fontWeight: FontWeight.w500),
                              showBottomBorder: true,
                              dataRowHeight: 60,
                              showCheckboxColumn: true,
                              dataRowColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
                                if (states.contains(MaterialState.selected)) {
                                  return MaterialStateColor.resolveWith((states) => const Color(0xffeef3ff));
                                }
                                return MaterialStateColor.resolveWith((states) => Colors.white); // Use the default value.
                              }),
                              columns: <DataColumn>[
                                DataColumn(
                                  label: Text(
                                    'STT',
                                    style: titleTableData,
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Mã TTS',
                                    style: titleTableData,
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'Tên TTS',
                                    style: titleTableData,
                                  ),
                                ),
                                DataColumn(
                                  label: Text(
                                    'File báo cáo kết quả',
                                    style: titleTableData,
                                  ),
                                ),
                              ],
                              rows: <DataRow>[
                                for (int i = 0; i < listThongTinDaoTaoTiengNhat.length; i++)
                                  DataRow(
                                    cells: <DataCell>[
                                      DataCell(Text("${i + 1}")),
                                      DataCell(Text(listThongTinDaoTaoTiengNhat[i].user!.userCode)),
                                      DataCell(Text(listThongTinDaoTaoTiengNhat[i].user!.fullName)),
                                      DataCell(Container(
                                        child: GestureDetector(
                                          child: Text(listThongTinDaoTaoTiengNhat[i].reportFile!, style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue)),
                                          onTap: () async {
                                            downloadFile(listThongTinDaoTaoTiengNhat[i].reportFile.toString());
                                          },
                                        ),
                                      ))
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ));
                      }))
                  : Center(
                      child: CircularProgressIndicator(),
                    )
            ],
          )),
      actions: <Widget>[
        ElevatedButton(
          // textColor: Color(0xFF6200EE),
          onPressed: () async {
            var responve = await downLoadFileZip(listThongTinDaoTaoTiengNhat);
          },
          child: Text(
            'Tải về',
            style: TextStyle(),
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.white,
            onPrimary: Colors.black,
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
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ModelGuiMail(
                    order: widget.order,
                  );
                });
          },
          child: Text(
            'Gửi',
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
