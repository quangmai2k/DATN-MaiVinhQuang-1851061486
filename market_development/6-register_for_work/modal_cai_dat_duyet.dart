import 'package:flutter/material.dart';

import 'package:gentelella_flutter/common/toast.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/form.dart';
import 'package:provider/provider.dart';

import '../../../../model/model.dart';
import '../../dashboard.dart';

class ModelCaiDatDuyet extends StatefulWidget {
  final Function? func;
  var boxThoiGianTuDongDuyet;
  ModelCaiDatDuyet({Key? key, this.func, this.boxThoiGianTuDongDuyet}) : super(key: key);

  @override
  State<ModelCaiDatDuyet> createState() => _ModelCaiDatDuyetState();
}

class _ModelCaiDatDuyetState extends State<ModelCaiDatDuyet> {
  //===Combobox date
  TextEditingController numberDateController = TextEditingController();
  final _myWidgetState = GlobalKey<TextFieldValidatedMarketState>();

  @override
  void initState() {
    super.initState();
    if (box.get('thoiGianTuDongDuyet') != null) {
      numberDateController.text = (box.get('thoiGianTuDongDuyet') is int) ? box.get('thoiGianTuDongDuyet').toString() : "0";
    } else {
      numberDateController.text = "180";
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
            child: Column(
              children: [Text('Cài đặt thời gian tự động duyệt'), Text('(Tính từ ngày tiếp cận gần nhất)')],
            ),
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
        height: 100,
        width: 600,
        child: SingleChildScrollView(
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
                margin: EdgeInsets.only(top: 10),
                child: TextFieldValidatedMarket(
                  key: _myWidgetState,
                  type: "Number",
                  labe: "Khoảng thời gian (Ngày)",
                  isReverse: false,
                  controller: numberDateController,
                ),
              )
            ],
          ),
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: Divider(
            thickness: 1,
            color: Colors.grey,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 120,
              height: 40,
              child: OutlinedButton(
                  style: ElevatedButton.styleFrom(
                    onPrimary: Color(0xffF77919), // Background color
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('Hủy')),
            ),
            Container(
              width: 120,
              height: 40,
              padding: EdgeInsets.only(left: 20),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Color(0xffF77919),
                  onPrimary: Colors.white, // Background color
                ),
                onPressed: () async {
                  if (_myWidgetState.currentState!.validate()) {
                    widget.func!(numberDateController.text);
                    try {
                      await widget.boxThoiGianTuDongDuyet.put("thoiGianTuDongDuyet", int.parse(numberDateController.text));
                      print("Thái");

                      Provider.of<CaiDatThoiGian>(context, listen: false).number = int.parse(numberDateController.text);
                    } catch (e) {
                      showToast(
                        context: context,
                        msg: "Nhập đúng định dạng số !",
                        color: Color.fromARGB(136, 72, 238, 67),
                        icon: const Icon(Icons.done),
                      );
                      Provider.of<CaiDatThoiGian>(context, listen: false).number = 180;
                      return;
                    }

                    showToast(
                      context: context,
                      msg: "Cài đặt thời gian tự động duyệt thành công !",
                      color: Color.fromARGB(136, 72, 238, 67),
                      icon: const Icon(Icons.done),
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Xác nhận'),
              ),
            )
          ],
        ),
      ],
    );
  }
}
