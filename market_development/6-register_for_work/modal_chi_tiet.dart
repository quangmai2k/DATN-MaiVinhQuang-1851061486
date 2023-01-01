import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/format_date.dart';

import '../../../../common/style.dart';
import '../../../../model/market_development/dangkicongtac.dart';

class showNotification extends StatefulWidget {
  final Function? function;
  final WorkRegistration? lichCongTac;
  showNotification({Key? key, this.function, this.lichCongTac}) : super(key: key);

  @override
  State<showNotification> createState() => _showNotificationState();
}

class _showNotificationState extends State<showNotification> {
  String hienThiNgay(WorkRegistration? lichCongTac) {
    if (lichCongTac != null) {
      if (lichCongTac.dateApproved != null) {
        return FormatDate.formatDateddMMyy(DateTime.parse(lichCongTac.dateApproved!));
      }
    }
    return "Không có ngày duyệt";
  }

  String hienThiLiDo(WorkRegistration? lichCongTac) {
    if (lichCongTac != null) {
      if (lichCongTac.refuseContent != null) {
        return lichCongTac.refuseContent!;
      }
    }
    return "...";
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Column(
        children: [
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 50,
                child: Row(
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
                          Text('Ngày phê duyệt : ${hienThiNgay(widget.lichCongTac)}', style: titleBox),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      child: Row(
                        children: [
                          Text('Lý do(nếu có): ', style: titleBox),
                          Text('${hienThiLiDo(widget.lichCongTac)} ', style: titleBox),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
