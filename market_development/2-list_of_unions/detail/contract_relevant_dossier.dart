import 'package:flutter/material.dart';
import 'package:gentelella_flutter/api.dart';
import 'package:provider/provider.dart';

import '../../../../../common/style.dart';
import '../../../../../model/market_development/union.dart';
import '../../../../../model/model.dart';

class ContractRelevantDossierDetail extends StatefulWidget {
  final UnionObj? union;
  ContractRelevantDossierDetail({Key? key, this.union}) : super(key: key);

  @override
  State<ContractRelevantDossierDetail> createState() => _ContractRelevantDossierDetailState();
}

class _ContractRelevantDossierDetailState extends State<ContractRelevantDossierDetail> {
  DateTime selectedDate = DateTime.now();

  Map<String, bool> listCheckBoxValue = {
    'Override default configurations': false,
    'Override Base Url': false,
  };

  String selectedNation = "Nhật Bản";
  String selectedStatus = "Đã kí hợp đồng";
  String selectedStaff = "Tất cả";
  List<String> listNation = ['Nhật Bản', 'Đài Loan'];

  List<String> listStatus = ['Cần tiếp cận', 'Đang tiếp cận', 'Đã ký hợp đồng'];

  List<String> listStaff = [
    'Nguyễn Văn A',
    'Nguyễn Văn A',
    'Nguyễn Văn A',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationModel>(
        builder: (context, navigationModel, child) => ListView(
              children: [
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
                            'Hợp đồng/Hồ sơ liên quan',
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
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            "Hợp đồng nguyên tắc :",
                                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 2,
                                            child: widget.union != null
                                                ? (widget.union?.principleContract != null
                                                    ? GestureDetector(
                                                        child: Text(
                                                          widget.union!.principleContract!,
                                                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color.fromARGB(255, 66, 190, 243)),
                                                        ),
                                                        onTap: () async {
                                                          downloadFile(widget.union!.principleContract.toString());
                                                        },
                                                      )
                                                    : Text("Chưa có dữ liệu"))
                                                : Text("Chưa có dữ liệu")),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 5,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            "Hợp đồng thỏa thuận riêng : ",
                                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 2,
                                            child: widget.union != null
                                                ? (widget.union?.agreementContract != null
                                                    ? GestureDetector(
                                                        child: Text(
                                                          widget.union!.agreementContract!,
                                                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color.fromARGB(255, 66, 190, 243)),
                                                        ),
                                                        onTap: () async {
                                                          downloadFile(widget.union!.agreementContract.toString());
                                                        },
                                                      )
                                                    : Text("Chưa có dữ liệu"))
                                                : Text("Chưa có dữ liệu")
                                            //  Text(
                                            //   widget.union!.agreementContract!,
                                            //   style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color.fromARGB(255, 66, 190, 243)),
                                            // ),
                                            ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 20),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 5,
                                      child: Row(
                                        children: [
                                          Expanded(
                                            flex: 1,
                                            child: Text(
                                              "Một số loại hồ sơ khác :",
                                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
                                            ),
                                          ),
                                          Expanded(
                                              flex: 2,
                                              child: widget.union != null
                                                  ? (widget.union?.otherFiles != null
                                                      ? GestureDetector(
                                                          child: Text(
                                                            widget.union!.otherFiles!,
                                                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color.fromARGB(255, 66, 190, 243)),
                                                          ),
                                                          onTap: () async {
                                                            downloadFile(widget.union!.otherFiles.toString());
                                                          },
                                                        )
                                                      : Text("Chưa có dữ liệu"))
                                                  : Text("Chưa có dữ liệu")
                                              // Text(
                                              //   widget.union!.otherFiles!,
                                              //   style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color.fromARGB(255, 66, 190, 243)),
                                              // ),
                                              ),
                                        ],
                                      )),
                                  Expanded(
                                    flex: 5,
                                    child: Container(),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ));
  }
}
