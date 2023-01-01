// ignore_for_file: unused_local_variable, unrelated_type_equality_checks, unused_element
import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/he_thong/cai_dat_bo_phan/them_moi_vi_tri.dart';
import 'package:provider/provider.dart';
import '../../../../api.dart';
import '../../../../common/dynamic_table.dart';
import '../../../../common/style.dart';
import '../../../../common/toast.dart';
import '../../../../common/widgets_form.dart';
import '../../../../model/model.dart';
import '../../../forms/nhan_su/setting-data/depart.dart';
import 'cap_nhat_vi_tri.dart';

class ViTri extends StatefulWidget {
  const ViTri({Key? key}) : super(key: key);

  @override
  State<ViTri> createState() => _ViTriState();
}

class _ViTriState extends State<ViTri> with TickerProviderStateMixin {
  var page = 1;
  var rowPerPage = 10;
  var totalElements = 0;
  var firstRow = 1, lastRow = 0;
  var rowCount = 0;
  var currentPage = 1;
  var tableIndex = 1;
  List<ViTriClass> listViTri = [];
  Future<List<ViTriClass>> getViTri(page) async {
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }
    if (page < 1) {
      page = 0;
    }
    var response = await httpGet("/api/vaitro/get/page?filter=deleted:false $find&sort=id,desc&size=$rowPerPage&page=$page", context);
    if (response.containsKey("body")) {
      var body = jsonDecode(response['body']);
      var content;
      listViTri = [];
      isSwitched = [];
      content = body['content'];
      currentPage = page + 1;
      if (content.length > 0) {
        for (var element in content) {
          ViTriClass item = ViTriClass(
            id: element['id'],
            name: element['name'],
            departId: element['departId'],
            level: element['level'],
            status: element['status'],
            departName: element['phongban'] != null ? element['phongban']['departName'] : "",
          );
          // if (element['parentId'] >= 0) {
          //   // print("bo phan cha:${element['parentId']}");
          //   for (var element1 in resultPhongBanCha) {
          //     if (element1.id == item.parentId) {
          //       item.parentName = element1.departName;
          //       break;
          //     }
          //   }
          // }
          listViTri.add(item);
          if (element['status'] == 1)
            isSwitched.add(true);
          else
            isSwitched.add(false);
        }
      }
      rowCount = body['totalElements'];
      totalElements = body["totalElements"];
      lastRow = totalElements;
      setState(() {});
      rowCount = body['totalElements'];
      if (content.length > 0) {
        var firstRow = (currentPage) * rowPerPage + 1;
        var lastRow = (currentPage + 1) * rowPerPage;
        if (lastRow > totalElements) {
          lastRow = totalElements;
        }
        tableIndex = (currentPage - 1) * rowPerPage + 1;
        // print(tableIndex);
      }
      return listViTri;
    }
    return listViTri;
  }

  Depart selectedBP1 = Depart(id: 0, departName: 'Tất cả');
  Future<List<Depart>> getPhongBan() async {
    List<Depart> resultPhongBan = [];

    var response1 = await httpGet("/api/phongban/get/page?sort=id,asc&filter=status:1 and parentId:0", context);
    var body = jsonDecode(response1['body']);
    var content = [];
    if (response1.containsKey("body")) {
      setState(() {
        content = body['content'];
        for (var element in content) {
          if (element['id'] > 2) {
            Depart item = Depart(id: element['id'], departName: element['departName']);
            resultPhongBan.add(item);
          }
        }
      });
      Depart all = Depart(id: 0, departName: 'Tất cả');
      resultPhongBan.insert(0, all);
    }
    return resultPhongBan;
  }

  bool checkSTT = false;
  bool checkClose = true;
  TextEditingController tenVT = TextEditingController();
  String find = "";

  void callAPI() async {
    // await getPhongBanCha();
    await getViTri(page);
    setState(() {
      checkSTT = true;
    });
  }

  List<bool> isSwitched = [];

  @override
  void initState() {
    super.initState();
    callAPI();
  }

  @override
  void dispose() {
    tenVT.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationModel>(
      builder: (context, navigationModel, child) => SingleChildScrollView(
        controller: ScrollController(),
        child: Container(
          padding: paddingBoxContainer,
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
                // transform: Matrix4.rotationX(2),
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
                        TextFieldValidated(
                          label: 'Vị trí:',
                          type: 'None',
                          height: 40,
                          controller: tenVT,
                          onChanged: (value) {},
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        SizedBox(width: 100),
                        Expanded(
                          flex: 3,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text('Phòng ban:', style: titleWidgetBox),
                              ),
                              Expanded(
                                  flex: 5,
                                  child: Container(
                                    color: Colors.white,
                                    width: MediaQuery.of(context).size.width * 0.20,
                                    height: 40,
                                    child: DropdownSearch<Depart>(
                                      mode: Mode.MENU,
                                      maxHeight: 250,
                                      showSearchBox: true,
                                      onFind: (String? filter) => getPhongBan(),
                                      itemAsString: (Depart? u) => u!.departName,
                                      dropdownSearchDecoration: styleDropDown,
                                      selectedItem: selectedBP1,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedBP1 = value!;
                                          // if (selectedBP != -1) getDNTDChiTiet(selectedBP);
                                        });
                                      },
                                    ),
                                  )),
                            ],
                          ),
                        ),
                       Expanded(flex: 2,child: Container(),)
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 25, 0, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            margin: EdgeInsets.only(left: 20),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20.0,
                                  horizontal: 30.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                primary: Theme.of(context).iconTheme.color,
                                textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                              ),
                              onPressed: () async {
                                find = "";
                                var findTenVt = "";
                                var findTenBP = "";
                                if (tenVT.text != "")
                                  findTenVt = "and name~'*${tenVT.text}*' ";
                                else
                                  findTenVt = "";
                                if (selectedBP1.id != 0)
                                  findTenBP = "and departId:${selectedBP1.id} ";
                                else
                                  findTenBP = "";
                                find = findTenVt + findTenBP;
                                print(find);
                                getViTri(0);
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text('Tìm kiếm', style: textButton),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 20),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20.0,
                                  horizontal: 30.0,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0),
                                ),
                                backgroundColor: Color.fromRGBO(245, 117, 29, 1),
                                primary: Theme.of(context).iconTheme.color,
                                textStyle: Theme.of(context).textTheme.caption?.copyWith(fontSize: 10.0, letterSpacing: 2.0),
                              ),
                              onPressed: () async {
                                await showDialog(context: context, builder: (BuildContext context) => ThemMoiViTri());
                                await getViTri(page - 1);
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
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
              ),
              (checkSTT)
                  ? Container(
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
                                'Vị trí',
                                style: titleBox,
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
                          Container(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: DataTable(
                                        showCheckboxColumn: false,
                                        // columnSpacing: 20,
                                        horizontalMargin: 10,
                                        dataRowHeight: 60,
                                        columns: [
                                          DataColumn(label: Text('STT', style: titleTableData)),
                                          DataColumn(label: Text('Vị trí', style: titleTableData)),
                                          DataColumn(label: Text('Phòng ban', style: titleTableData)),
                                          DataColumn(label: Text('Hành động', style: titleTableData)),
                                        ],
                                        rows: <DataRow>[
                                          for (int i = 0; i < listViTri.length; i++)
                                            DataRow(
                                              cells: <DataCell>[
                                                DataCell(Text("${tableIndex + i}")),
                                                // ignore: unnecessary_null_comparison
                                                DataCell(Text(listViTri[i].name != null ? "${listViTri[i].name}" : "")),
                                                DataCell(Text(listViTri[i].departName != "" ? "${listViTri[i].departName}" : "")),
                                                DataCell(
                                                  Row(
                                                    children: [
                                                      Container(
                                                          margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                          child: InkWell(
                                                            onTap: () async {
                                                              await showDialog(
                                                                  context: context,
                                                                  builder: (BuildContext context) => CapNhatViTri(data: listViTri[i]));
                                                              await getViTri(page - 1);
                                                            },
                                                            child: Icon(Icons.edit_calendar, color: Color(0xff009C87)),
                                                          )),
                                                      Container(
                                                        margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                                        child: Tooltip(
                                                            message: (isSwitched[i]) ? 'Đã kích hoạt' : 'Chưa kích hoạt',
                                                            textStyle: const TextStyle(fontSize: 15, color: Colors.white),
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(25),
                                                              color: (isSwitched[i]) ? mainColorPage : colorOrange,
                                                            ),
                                                            child: Switch(
                                                              onChanged: (value) async {
                                                                setState(() {
                                                                  isSwitched[i] = value;
                                                                });
                                                                // print("value:$value     i:$i");
                                                                if (isSwitched[i] == false) {
                                                                  var response =
                                                                      await httpPut("/api/vaitro/put/${listViTri[i].id}", {"status": 0}, context);
                                                                  showToast(
                                                                      context: context,
                                                                      msg: "Đã hủy kích hoạt vị trí",
                                                                      color: colorOrange,
                                                                      icon: const Icon(Icons.done),
                                                                      timeHint: 1);
                                                                } else {
                                                                  var response =
                                                                      await httpPut("/api/vaitro/put/${listViTri[i].id}", {"status": 1}, context);
                                                                  showToast(
                                                                      context: context,
                                                                      msg: "Đã kích hoạt vị trí",
                                                                      color: mainColorPage,
                                                                      icon: const Icon(Icons.done),
                                                                      timeHint: 1);
                                                                }
                                                              },
                                                              value: isSwitched[i],
                                                              activeColor: mainColorPage,
                                                              activeTrackColor: Color(0xfffcccccc),
                                                              inactiveThumbColor: Color.fromARGB(255, 158, 158, 158),
                                                              inactiveTrackColor: Color(0xfffcccccc),
                                                            )),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                DynamicTablePagging(
                                  rowCount,
                                  currentPage,
                                  rowPerPage,
                                  pageChangeHandler: (page) {
                                    setState(() {
                                      getViTri(page - 1);
                                      currentPage = page - 1;
                                    });
                                  },
                                  rowPerPageChangeHandler: (rowPerPage) {
                                    setState(() {
                                      this.rowPerPage = rowPerPage!;
                                      this.firstRow = page * currentPage;
                                      getViTri(0);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Center(child: const CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}

class ViTriClass {
  int id;
  String name;
  int departId;
  String departName;
  int level;
  int status;
  ViTriClass(
      {Key? key, required this.id, required this.name, required this.departId, required this.level, required this.status, required this.departName});
}
