import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';

import 'package:flutter/material.dart';
import 'package:gentelella_flutter/common/toast.dart';
import 'package:gentelella_flutter/common/widgets_form.dart';
import 'package:gentelella_flutter/widgets/forms/market_development/utils/form.dart';
import 'package:gentelella_flutter/widgets/ui/market_development/6-register_for_work/modal_phe_duyet.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';

import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/format_date.dart';
import '../../../../common/style.dart';

import '../../../../model/market_development/dangkicongtac.dart';
import '../../../../model/market_development/lich_su_cong_tac.dart';
import '../../../../model/market_development/union.dart';
import '../../../../model/model.dart';
import 'dart:async';

import '../../dashboard.dart';
import '../3-enterprise_manager/enterprise_manager.dart';
import 'modal_cai_dat_duyet.dart';
import 'modal_chi_tiet.dart';

class RegisterForWork extends StatefulWidget {
  const RegisterForWork({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RegisterForWorkState();
  }
}

class _RegisterForWorkState extends State<RegisterForWork> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: RegisterForWorkBody());
  }
}

class RegisterForWorkBody extends StatefulWidget {
  const RegisterForWorkBody({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _RegisterForWorkBodyState();
  }
}

class _RegisterForWorkBodyState extends State<RegisterForWorkBody> {
  var body = {};
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  bool _setLoading = false;
  List<WorkRegistration> listWorkRegistration = [];
  List<WorkRegistration> listWorkRegistrationSelected = [];
  List<UnionObj>? listUnionObjectResult = [];
  List<LichSuCongTac> listLichSuCongTac = [];
  late Future<List<WorkRegistration>> futureListWorkRegistration;
  List<bool> _selected = [];
  List<bool> _selectedTrue = [];
  int? selectedUnion;
  TextEditingController staffController = TextEditingController();

  int numberTime = 180;

  Map<int, String> _mapStatusPheDuyet = {
    0: ' Chưa duyệt',
    1: ' Đã duyệt',
    2: ' Đã hoàn thành',
    3: ' Từ chối',
  };

  Future<List<WorkRegistration>> getListWorkRegistrationBySearch(page, {orgId, userName}) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response;
    Map<String, dynamic> requestParam = Map();
    String condition = "";

    if (userName != null) {
      condition += " ( nguoidung.userCode~'*$userName*' ";
      condition += " OR nguoidung.userName~'*$userName*' ";
      condition += " OR nguoidung.fullName~'*$userName*' ) ";
    }
    if (orgId != null && orgId != -1) {
      condition += " AND chitiet.orgId:'$orgId'  ";
    }

    response = await httpGet("/api/lichcongtac/get/page?page=$page&size=$rowPerPage&filter=$condition", context);

    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        currentPage = page + 1;
        content = body['content'];
        rowCount = body["totalElements"];
        totalElements = body["totalElements"];
        lastRow = totalElements;
        listWorkRegistration = content.map((e) {
          return WorkRegistration.fromJson(e);
        }).toList();
        _selected = List<bool>.generate(listWorkRegistration.length, (int index) => false);
      });
    }

    return content.map((e) {
      return WorkRegistration.fromJson(e);
    }).toList();
  }

  Future<List<UnionObj>> getListUnionSearchBy({key}) async {
    var response = await httpGet("/api/nghiepdoan/get/page?filter", context);
    var body = jsonDecode(response['body']);
    List<UnionObj> listUnionObj = [];
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
        listUnionObj = content.map((e) {
          return UnionObj.fromJson(e);
        }).toList();
      });
    }
    UnionObj union = new UnionObj(id: -1, orgName: "Tất cả");
    listUnionObj.insert(0, union);
    return listUnionObj;
  }

  handleClickBtnSearch({orgId, userName}) {
    print("clicked");
    setState(() {
      _setLoading = true;
    });

    Future<List<WorkRegistration>> _futureLichThiSat = getListWorkRegistrationBySearch(0, orgId: orgId, userName: userName);
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        futureListWorkRegistration = _futureLichThiSat;
        _setLoading = false;
      });
    });
  }

  clickBtnXacNhan(value) {
    setState(() {
      try {
        numberTime = int.parse(value);
      } on Exception catch (_) {
        print('never reached');
      }
    });
  }

  hanldeXacNhanDuyet() {
    setState(() {
      _setLoading = true;
    });
    Future<List<WorkRegistration>> _futureAfterUpdate = getListWorkRegistrationBySearch(page - 1);

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        futureListWorkRegistration = _futureAfterUpdate;
        _setLoading = false;
      });
    });
  }

  deleteLichCongTac(id) async {
    var response = await httpDelete("/api/lichcongtac/del/$id", context);
    print(response);
    var body = jsonDecode(response['body']);
    if (body) {
      showToast(context: context, msg: "Xóa thành công lịch công tác ! ", color: Colors.green, icon: Icon(Icons.abc));
    } else {
      showToast(context: context, msg: "Thất bại ! ", color: Colors.red, icon: Icon(Icons.abc));
    }
  }

  Future getDanhSachLichSuCongTacTheoLichCongTacId() async {
    var response = await httpGet("/api/lichcongtac-nghiepdoan/get/page?sort=id,desc", context);
    var body = jsonDecode(response['body']);
    var content = [];
    if (response.containsKey("body")) {
      setState(() {
        content = body['content'];
        listLichSuCongTac = content
            .map((e) {
              return LichSuCongTac.fromJson(e);
            })
            .toList()
            .reversed
            .toList();
      });
    }
    return content.map((e) {
      return LichSuCongTac.fromJson(e);
    }).toList();
  }

  int demNghiepDoanTrongListLichSuCongTac(List<LichSuCongTac> list, int onsiteId) {
    int count = 0;
    for (int i = 0; i < list.length; i++) {
      if (onsiteId == list[i].onsiteId) {
        count++;
      }
    }
    return count;
  }

  @override
  void initState() {
    super.initState();
    getDanhSachLichSuCongTacTheoLichCongTacId();
    futureListWorkRegistration = getListWorkRegistrationBySearch(page - 1);
  }

  bool hienThiNutBam(int status) {
    if (status == 3 || status == 1) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: userRule('/dang-ki-cong-tac', context),
        builder: (context, listRule) {
          if (listRule.hasData) {
            return Consumer3<NavigationModel, CaiDatThoiGian, SecurityModel>(
                builder: (context, navigationModel, numberTime, securityModel, child) => FutureBuilder<List<WorkRegistration>>(
                    future: futureListWorkRegistration,
                    builder: (context, snapshot) {
                      return ListView(
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
                                {'url': '/dang-ki-cong-tac', 'title': 'Đăng ký công tác'},
                              ],
                              content: "Đăng ký công tác",
                            ),
                          ),
                          Container(
                              color: backgroundPage,
                              padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: MediaQuery.of(context).size.width * 1,
                                    decoration: BoxDecoration(
                                      color: colorWhite,
                                      borderRadius: borderRadiusContainer,
                                      boxShadow: [boxShadowContainer],
                                      border: borderAllContainerBox,
                                    ),
                                    padding: paddingBoxContainer,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Nhập thông tin',
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
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 4,
                                              child: Container(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      child: TextFieldValidatedMarket(
                                                        type: "None",
                                                        labe: "Nhân viên",
                                                        isReverse: false,
                                                        flexLable: 2,
                                                        flexTextField: 5,
                                                        controller: staffController,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 6,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  getRule(listRule.data, Role.Sua, context)
                                                      ? Container(
                                                          margin: EdgeInsets.only(left: 20, bottom: 30),
                                                          child: ElevatedButton(
                                                            style: ElevatedButton.styleFrom(
                                                              primary: Color(0xffFF7F10),
                                                              minimumSize: Size(140, 45),
                                                            ),
                                                            onPressed: () {
                                                              showDialog(
                                                                context: context,
                                                                builder: (BuildContext context) => ModelCaiDatDuyet(
                                                                  func: clickBtnXacNhan,
                                                                  boxThoiGianTuDongDuyet: box,
                                                                ),
                                                              );
                                                            },
                                                            child: Text("Cài đặt thời gian tự động duyệt"),
                                                          ),
                                                        )
                                                      : Container(),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 4,
                                              child: Container(
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: Text('Nghiệp đoàn', style: titleWidgetBox),
                                                    ),
                                                    Expanded(
                                                      flex: 5,
                                                      child: Container(
                                                        color: Colors.white,
                                                        width: MediaQuery.of(context).size.width * 1,
                                                        height: 40,
                                                        child: DropdownSearch<UnionObj>(
                                                          mode: Mode.MENU,
                                                          showSearchBox: true,
                                                          onFind: (String? filter) => getListUnionSearchBy(key: filter),
                                                          itemAsString: (UnionObj? u) => u!.orgName! + "(${u.orgCode != null ? u.orgCode.toString() : ""})",
                                                          dropdownSearchDecoration: styleDropDown,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              selectedUnion = value!.id;
                                                              print(selectedUnion);
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 6,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  (securityModel.userLoginCurren['vaitro'] == null || securityModel.userLoginCurren['vaitro']['level'] == 1) &&
                                                          getRule(listRule.data, Role.Sua, context)
                                                      ? Container(
                                                          margin: EdgeInsets.only(left: 20),
                                                          child: TextButton.icon(
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
                                                              textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                                                            ),
                                                            onPressed: () {
                                                              if (listWorkRegistrationSelected.isNotEmpty) {
                                                                showDialog(
                                                                  context: context,
                                                                  builder: (BuildContext context) => ModelPheDuyet(
                                                                    listWorkRegistrationSelected: listWorkRegistrationSelected,
                                                                    func: hanldeXacNhanDuyet,
                                                                  ),
                                                                );
                                                              } else {
                                                                showToast(
                                                                    context: context,
                                                                    msg: "Vui lòng chọn ít nhất một bản ghi",
                                                                    color: Color.fromARGB(255, 223, 248, 174),
                                                                    icon: Icon(Icons.warning));
                                                              }
                                                            },
                                                            icon: Icon(
                                                              Icons.done,
                                                              color: Colors.white,
                                                              size: 15,
                                                            ),
                                                            label: Row(
                                                              children: [
                                                                Text('Phê duyệt', style: textButton),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      : Container(),
                                                  Container(
                                                    margin: EdgeInsets.only(left: 20),
                                                    child: TextButton.icon(
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
                                                        textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                                                      ),
                                                      onPressed: () async {
                                                        print(securityModel.userLoginCurren);
                                                        await handleClickBtnSearch(orgId: selectedUnion, userName: staffController.text);
                                                      },
                                                      icon: Transform.rotate(
                                                        angle: 270,
                                                        child: Icon(
                                                          Icons.search,
                                                          color: Colors.white,
                                                          size: 15,
                                                        ),
                                                      ),
                                                      label: Row(
                                                        children: [
                                                          Text('Tìm kiếm ', style: textButton),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    margin: EdgeInsets.only(left: 20),
                                                    child: TextButton.icon(
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
                                                        textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                                                      ),
                                                      onPressed: () {
                                                        navigationModel.add(pageUrl: "/them-moi-lich-cong-tac");
                                                      },
                                                      icon: Icon(
                                                        Icons.add,
                                                        color: Colors.white,
                                                        size: 15,
                                                      ),
                                                      label: Row(
                                                        children: [
                                                          Text('Thêm mới', style: textButton),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width * 1,
                                    margin: marginTopBoxContainer,
                                    decoration: BoxDecoration(
                                      color: colorWhite,
                                      borderRadius: borderRadiusContainer,
                                      boxShadow: [boxShadowContainer],
                                      border: borderAllContainerBox,
                                    ),
                                    padding: paddingBoxContainer,
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Đăng ký công tác',
                                              style: titleBox,
                                            ),
                                            Icon(
                                              Icons.more_horiz,
                                              color: colorIconTitleBox,
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
                                        if (snapshot.hasData)
                                          //Start Datatable
                                          !_setLoading
                                              ? Container(child: LayoutBuilder(builder: (BuildContext context, BoxConstraints constraints) {
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
                                                          columnSpacing: 5,
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
                                                                'Mã NV',
                                                                style: titleTableData,
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: Text(
                                                                'Tên NV',
                                                                style: titleTableData,
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: Text(
                                                                'Từ ngày',
                                                                style: titleTableData,
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: Text(
                                                                'Đến ngày',
                                                                style: titleTableData,
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: Text(
                                                                'Số lượng nghiệp đoàn',
                                                                style: titleTableData,
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: Text(
                                                                'Trạng thái phê duyệt',
                                                                style: titleTableData,
                                                              ),
                                                            ),
                                                            DataColumn(
                                                              label: Text(
                                                                'Thao tác',
                                                                style: titleTableData,
                                                              ),
                                                            ),
                                                          ],
                                                          rows: <DataRow>[
                                                            for (int i = 0; i < listWorkRegistration.length; i++)
                                                              DataRow(
                                                                cells: <DataCell>[
                                                                  DataCell(Text("${i + 1}")),
                                                                  DataCell(Text(listWorkRegistration[i].user!.userCode)),
                                                                  DataCell(Text(listWorkRegistration[i].user!.fullName)),
                                                                  DataCell(Text(FormatDate.formatDateView(DateTime.parse(listWorkRegistration[i].dateFrom)))),
                                                                  DataCell(Text(FormatDate.formatDateView(DateTime.parse(listWorkRegistration[i].dateTo)))),
                                                                  DataCell(Center(
                                                                    child: Text(
                                                                      demNghiepDoanTrongListLichSuCongTac(listLichSuCongTac, listWorkRegistration[i].id).toString(),
                                                                    ),
                                                                  )),
                                                                  DataCell(Container(
                                                                    child: InkWell(
                                                                      onTap: () {
                                                                        showDialog(
                                                                          context: context,
                                                                          builder: (BuildContext context) => showNotification(
                                                                            lichCongTac: listWorkRegistration[i],
                                                                          ),
                                                                        );
                                                                      },
                                                                      child: Text(
                                                                        "${_mapStatusPheDuyet[listWorkRegistration[i].status].toString()}",
                                                                        style: hienThiNutBam(listWorkRegistration[i].status) ? textButtonTable : null,
                                                                      ),
                                                                    ),
                                                                  )),
                                                                  DataCell(Row(
                                                                    children: [
                                                                      getRule(listRule.data, Role.Xem, context)
                                                                          ? Container(
                                                                              margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                              child: InkWell(
                                                                                onTap: () {
                                                                                  navigationModel.add(
                                                                                      pageUrl: "/xem-chi-tiet-lich-cong-tac/" + listWorkRegistration[i].id.toString());
                                                                                },
                                                                                child: Icon(Icons.visibility),
                                                                              ),
                                                                            )
                                                                          : Container(),
                                                                      getRule(listRule.data, Role.Sua, context)
                                                                          ? Container(
                                                                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                              child: InkWell(
                                                                                  onTap: listWorkRegistration[i].status != 3 && listWorkRegistration[i].status != 2
                                                                                      ? () {
                                                                                          navigationModel.add(pageUrl: "/cap-nhat-lich-cong-tac/${listWorkRegistration[i].id}");
                                                                                        }
                                                                                      : () {
                                                                                          showToast(
                                                                                              context: context,
                                                                                              msg: "Không cho phép cập nhật khi trạng thái là từ chối hoặc đã hoàn thành !",
                                                                                              color: Colors.red,
                                                                                              icon: Icon(Icons.warning));
                                                                                        },
                                                                                  child: Icon(
                                                                                    Icons.edit_calendar,
                                                                                    color: listWorkRegistration[i].status != 3 && listWorkRegistration[i].status != 2
                                                                                        ? Color(0xff009C87)
                                                                                        : Colors.grey,
                                                                                  )))
                                                                          : Container(),
                                                                      getRule(listRule.data, Role.Xoa, context)
                                                                          ? Container(
                                                                              margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                                              child: InkWell(
                                                                                  onTap: listWorkRegistration[i].status != 3 && listWorkRegistration[i].status != 2
                                                                                      ? () {
                                                                                          showDialog(
                                                                                            context: context,
                                                                                            builder: (BuildContext context) => XacNhanXoaXiNghiep(
                                                                                              label: "Bạn có muốn xóa lịch công tác này ?",
                                                                                              function: () async {
                                                                                                await deleteLichCongTac(listWorkRegistration[i].id);
                                                                                                await handleClickBtnSearch();
                                                                                              },
                                                                                            ),
                                                                                          );
                                                                                        }
                                                                                      : () {
                                                                                          showDialog(
                                                                                            context: context,
                                                                                            builder: (BuildContext context) => XacNhanXoaXiNghiep(
                                                                                              label: "Bạn có muốn xóa lịch công tác này ?",
                                                                                              function: () async {
                                                                                                await deleteLichCongTac(listWorkRegistration[i].id);
                                                                                                await handleClickBtnSearch();
                                                                                              },
                                                                                            ),
                                                                                          );
                                                                                        },
                                                                                  child: Icon(
                                                                                    Icons.delete,
                                                                                    color: listWorkRegistration[i].status != 3 && listWorkRegistration[i].status != 2
                                                                                        ? Colors.red
                                                                                        : Colors.grey,
                                                                                  )))
                                                                          : Container(),
                                                                    ],
                                                                  )),
                                                                ],
                                                                selected: _selected[i],
                                                                onSelectChanged: (bool? value) {
                                                                  setState(() {
                                                                    listWorkRegistrationSelected.clear();
                                                                    _selectedTrue.clear();

                                                                    _selected[i] = value!;
                                                                    if (listWorkRegistration[i].status != 0 && listWorkRegistration[i].status != 3) {
                                                                      showToast(
                                                                          context: context,
                                                                          msg: "Không cho phép Xóa khi trạng thái là từ chối hoặc đã hoàn thành !",
                                                                          color: Color.fromARGB(135, 247, 217, 179),
                                                                          icon: Icon(Icons.abc));
                                                                      _selected[i] = false;
                                                                    }
                                                                    for (int i = 0; i < _selected.length; i++) {
                                                                      if (_selected[i] == true) {
                                                                        _selectedTrue.add(_selected[i]);
                                                                        listWorkRegistrationSelected.add(listWorkRegistration[i]);
                                                                      }
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                          ],
                                                        )),
                                                  ));
                                                }))
                                              : Center(
                                                  child: CircularProgressIndicator(),
                                                )
                                        else if (snapshot.hasError)
                                          Text("Fail! ${snapshot.error}")
                                        else if (!snapshot.hasData)
                                          Center(
                                            child: CircularProgressIndicator(),
                                          ),
                                        Container(
                                          margin: const EdgeInsets.only(right: 50),
                                          child: DynamicTablePagging(
                                            rowCount,
                                            currentPage,
                                            rowPerPage,
                                            pageChangeHandler: (page) {
                                              setState(() {
                                                getListWorkRegistrationBySearch(page - 1, orgId: selectedUnion, userName: staffController.text);
                                                currentPage = page - 1;
                                              });
                                            },
                                            rowPerPageChangeHandler: (rowPerPage) {
                                              setState(() {
                                                this.rowPerPage = rowPerPage!;

                                                this.firstRow = page * currentPage;
                                                getListWorkRegistrationBySearch(page - 1, orgId: selectedUnion, userName: staffController.text);
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                          Footer()
                        ],
                      );
                    }));
          } else if (listRule.hasError) {
            return Text('${listRule.error}');
          }
          return Center(child: CircularProgressIndicator());
        });
  }
}
