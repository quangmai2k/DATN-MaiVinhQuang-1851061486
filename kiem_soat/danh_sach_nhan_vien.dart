import 'dart:convert';

import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/navigation.dart';
import 'package:provider/provider.dart';

import '../../../api.dart';
import '../../../common/style.dart';
import '../../../common/widgets_form.dart';
import '../../../model/model.dart';

String? selectedBoPhan;

class DanhSachNhanVien extends StatefulWidget {
  const DanhSachNhanVien({Key? key}) : super(key: key);

  @override
  State<DanhSachNhanVien> createState() => _DanhSachNhanVienState();
}

class _DanhSachNhanVienState extends State<DanhSachNhanVien> {
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: DanhSachNhanVienBody());
  }
}

class DanhSachNhanVienBody extends StatefulWidget {
  const DanhSachNhanVienBody({Key? key}) : super(key: key);

  @override
  State<DanhSachNhanVienBody> createState() => _DanhSachNhanVienBodyState();
}

class _DanhSachNhanVienBodyState extends State<DanhSachNhanVienBody> {
  int? selectedBP;
  // final TextEditingController _textEditingController = TextEditingController();
  final TextEditingController _nhanVien = TextEditingController();
  final TextEditingController _sdt = TextEditingController();
  final TextEditingController _viTri = TextEditingController();
  final String urlAddNewUpdateSI = "/ho-so-nhan-su-ks";
  String findSearch = "";

  String getGender(dynamic gender) {
    String nameGender = "";
    if (gender != null && gender == 1) {
      nameGender = "Nam";
    } else if (gender != null && gender == 0) {
      nameGender = "Nữ";
    } else if (gender == null) {
      nameGender = "";
    }

    return nameGender;
  }

  bool search = false;
  TextEditingController tenNV = TextEditingController();
  TextEditingController sdt = TextEditingController();
  TextEditingController viTri = TextEditingController();
  String requestName = '';
  String requestSDT = '';
  String requestViTri = '';
  late Future<dynamic> getListTTSFuture;
  var totalElements = 0;
  var firstRow = 0;
  var rowPerPage = 10;
  var currentPage = 0;
  var resultNhanVien = {};
  //var resultPhongBan = {};
  late Future<dynamic> futureListNhanVien;
  Widget paging = Container();

  Future<dynamic> getNhanVien(page, String findSearch) async {
    await getPhongBan();
    print("diep231");
    if (page * rowPerPage > totalElements) {
      page = (1.0 * totalElements / rowPerPage - 1).ceil();
    }

    if (page < 1) {
      page = 0;
    }
    var response;
    if (findSearch == "") {
      response = await httpGet(
          "/api/nguoidung/get/page?page=$page&size=$rowPerPage&filter=isAam:1",
          context);
      // print("trên");
      // print("/api/nguoidung/get/page?page=$page&size=$rowPerPage&filter=isAam:1");
    } else {
      response = await httpGet(
          "/api/nguoidung/get/page?page=$page&size=$rowPerPage&filter=isAam:1 $findSearch",
          context);
      //  print("dưới");
      //   print("/api/nguoidung/get/page?page=$page&size=$rowPerPage&filter=isAam:1 $findSearch");
    }
    if (response.containsKey("body")) {
      setState(() {
        currentPage = page;
        resultNhanVien = jsonDecode(response["body"]);
        totalElements = resultNhanVien["totalElements"];
        //print("totalElements"+totalElements.toString());
      });
    }
    // print(resultNhanVien);

    return resultNhanVien;
  }

  Future<List<Depart>> getPhongBan() async {
    //print("diep2");
    List<Depart> resultPhongBan = [];
    var response1 = await httpGet(
        "/api/phongban/get/page?sort=id,asc&filter=parentId:0 and id>2 and deleted:false",
        context);
    var body = jsonDecode(response1['body']);
    var content = [];
    if (response1.containsKey("body")) {
      setState(() {
        content = body['content'];
        resultPhongBan = content.map((e) {
          return Depart.fromJson(e);
        }).toList();
      });
    }
    Depart all = new Depart(id: 0, departName: "Tất cả");
    resultPhongBan.insert(0, all);
    return resultPhongBan;
  }
  // var ipBp;
  //var timeNeed;
  // //String selectedBP = "";
  // Map<int, String> departName = {0: "Tất cả"};
  // getPhongBan() async {
  //   var response1 = await httpGet("/api/phongban/get/page?sort=id,asc", context);
  //   if (response1.containsKey("body")) {
  //     setState(() {
  //       resultPhongBan = jsonDecode(response1["body"]);
  //       for (int i = 2; i < resultPhongBan["totalElements"]; i++) {
  //         departName[resultPhongBan["content"][i]["id"]] = resultPhongBan["content"][i]["departName"];
  //       }
  //     });
  //   }
  // }

  @override
  void initState() {
    futureListNhanVien = getNhanVien(currentPage, findSearch);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
      future: futureListNhanVien,
      builder: (context, snapshot) {
        var tableIndex = (currentPage) * rowPerPage + 1;
        if (snapshot.hasData) {
          if (resultNhanVien["content"].length > 0) {
            var firstRow = (currentPage) * rowPerPage + 1;
            var lastRow = (currentPage + 1) * rowPerPage;
            if (lastRow > resultNhanVien["totalElements"]) {
              lastRow = resultNhanVien["totalElements"];
            }

            paging = Row(
              children: [
                Expanded(flex: 1, child: Container()),
                const Text("Số dòng trên trang: "),
                DropdownButton<int>(
                  value: rowPerPage,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 2,
                    color: Colors.deepPurpleAccent,
                  ),
                  onChanged: (int? newValue) {
                    setState(() {
                      rowPerPage = newValue!;
                      getNhanVien(currentPage, findSearch);
                    });
                  },
                  items: <int>[2, 5, 10, 25, 50, 100]
                      .map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text("$value"),
                    );
                  }).toList(),
                ),
                Text(
                    "Dòng $firstRow - $lastRow của ${resultNhanVien["totalElements"]}"),
                IconButton(
                    onPressed: firstRow != 1
                        ? () {
                            getNhanVien(currentPage - 1, findSearch);
                          }
                        : null,
                    icon: const Icon(Icons.chevron_left)),
                IconButton(
                    onPressed: lastRow < resultNhanVien["totalElements"]
                        ? () {
                            getNhanVien(currentPage + 1, findSearch);
                          }
                        : null,
                    icon: const Icon(Icons.chevron_right)),
              ],
            );
          }
          return Scaffold(
            body: ListView(children: [
              TitlePage(
                listPreTitle: [
                  {'url': '/kiem-soat', 'title': 'Dashboard'},
                ],
                content: "Danh sách nhân viên",
              ),
              Container(
                color: backgroundPage,
                padding: EdgeInsets.symmetric(
                    vertical: verticalPaddingPage,
                    horizontal: horizontalPaddingPage),
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
                      child: Column(children: [
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
                        Padding(
                          padding: const EdgeInsets.fromLTRB(50, 30, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text('Nhân viên',
                                            style: titleWidgetBox),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Container(
                                          child: TextField(
                                            controller: _nhanVien,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  width: 3,
                                                  color: Colors.black,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 100),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child:
                                            Text('SĐT', style: titleWidgetBox),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Container(
                                          child: TextField(
                                            controller: _sdt,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  width: 3,
                                                  color: Colors.black,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(flex: 2, child: Container()),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(50, 30, 0, 0),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Container(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text('Bộ phận',
                                            style: titleWidgetBox),
                                      ),
                                      Expanded(
                                          flex: 5,
                                          child: Container(
                                            color: Colors.white,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.20,
                                            //height: 40,
                                            child: DropdownSearch<Depart>(
                                              hint: "Tất cả",
                                              mode: Mode.MENU,
                                              maxHeight: 350,
                                              showSearchBox: true,
                                              onFind: (String? filter) =>
                                                  getPhongBan(),
                                              itemAsString: (Depart? u) =>
                                                  u!.departName,
                                              dropdownSearchDecoration:
                                                  styleDropDown,
                                              onChanged: (value) {
                                                setState(() {
                                                  selectedBP = value!.id;
                                                  print(selectedBP);
                                                  //if (selectedBP != -1) getDNTDChiTiet(selectedBP);
                                                });
                                              },
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 100),
                              Expanded(
                                flex: 3,
                                child: Container(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: Text('Vị trí',
                                            style: titleWidgetBox),
                                      ),
                                      Expanded(
                                        flex: 5,
                                        child: Container(
                                          child: TextField(
                                            controller: _viTri,
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                borderSide: BorderSide(
                                                  width: 3,
                                                  color: Colors.black,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(0.0),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(flex: 2, child: Container()),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(50, 50, 20, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                height: 40,
                                margin: EdgeInsets.only(left: 20),
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 15.0,
                                      horizontal: 10.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    backgroundColor:
                                        Color.fromRGBO(245, 117, 29, 1),
                                    primary: Theme.of(context).iconTheme.color,
                                    textStyle: Theme.of(context)
                                        .textTheme
                                        .caption
                                        ?.copyWith(
                                            fontSize: 10.0, letterSpacing: 2.0),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      findSearch = "";
                                      var nhanVien;
                                      var sdt;
                                      var boPhan;
                                      var viTri;
                                      if (_nhanVien.text != "")
                                        nhanVien =
                                            "and fullName~'*${_nhanVien.text}*' or userCode~'*${_nhanVien.text}*' ";
                                      else
                                        nhanVien = "";
                                      if (_sdt.text != "")
                                        sdt = "and phone~'*${_sdt.text}*' ";
                                      else
                                        sdt = "";
                                      if (_viTri.text != "")
                                        viTri =
                                            "and vaitro.name~'*${_viTri.text}*' ";
                                      else
                                        viTri = "";
                                      if (selectedBP != null && selectedBP != 0)
                                        boPhan = "and departId:$selectedBP ";
                                      else
                                        boPhan = "";
                                      findSearch =
                                          nhanVien + sdt + boPhan + viTri;
                                      getNhanVien(0, findSearch);
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Icon(
                                          Icons.search,
                                          color: Colors.white,
                                          size: 15,
                                        ),
                                      ),
                                      Text('Tìm kiếm', style: textButton),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 1,
                margin: marginTopLeftRightContainer,
                decoration: BoxDecoration(
                  color: colorWhite,
                  borderRadius: borderRadiusContainer,
                  boxShadow: [boxShadowContainer],
                  border: borderAllContainerBox,
                ),
                padding: paddingBoxContainer,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Thông tin các nhân viên',
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
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: LayoutBuilder(builder:
                                (BuildContext context,
                                    BoxConstraints constraints) {
                              return Center(
                                  child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: DataTable(
                                        dataTextStyle: const TextStyle(
                                            color: Color(0xff313131),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                        showBottomBorder: true,
                                        dataRowHeight: 60,
                                        dataRowColor: MaterialStateProperty
                                            .resolveWith<Color?>(
                                                (Set<MaterialState> states) {
                                          if (states.contains(
                                              MaterialState.selected)) {
                                            return MaterialStateColor
                                                .resolveWith((states) =>
                                                    const Color(0xffeef3ff));
                                          }
                                          return MaterialStateColor.resolveWith(
                                              (states) => Colors
                                                  .white); // Use the default value.
                                        }),
                                        columns: <DataColumn>[
                                          DataColumn(
                                              label: Text("STT",
                                                  style: titleTableData)),
                                          DataColumn(
                                              label: Column(
                                            children: [
                                              Text("Mã", style: titleTableData),
                                              Text("nhân viên",
                                                  style: titleTableData),
                                            ],
                                          )),
                                          DataColumn(
                                              label: Column(
                                            children: [
                                              Text("Tên",
                                                  style: titleTableData),
                                              Text("nhân viên",
                                                  style: titleTableData),
                                            ],
                                          )),
                                          DataColumn(
                                              label: Text("Ngày sinh",
                                                  style: titleTableData)),
                                          DataColumn(
                                              label: Text("Giới \ntính",
                                                  style: titleTableData)),
                                          DataColumn(
                                              label: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 15),
                                            child: Text("SĐT",
                                                style: titleTableData),
                                          )),
                                          DataColumn(
                                              label: Text("Vị trí",
                                                  style: titleTableData)),
                                          DataColumn(
                                              label: Text("Bộ phận",
                                                  style: titleTableData)),
                                          DataColumn(
                                              label: Text("Thực hiện",
                                                  style: titleTableData))
                                        ],
                                        rows: <DataRow>[
                                          for (int i = 0;
                                              i <
                                                  resultNhanVien["content"]
                                                      .length;
                                              i++)
                                            DataRow(
                                              cells: <DataCell>[
                                                DataCell(Container(
                                                    width:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width /
                                                                10) *
                                                            0.1,
                                                    child: Text(
                                                        "${tableIndex + i}",
                                                        style: bangDuLieu))),
                                                DataCell(Container(
                                                    // width: (MediaQuery.of(context).size.width / 10) * 0.55,
                                                    child: Text(
                                                        resultNhanVien["content"]
                                                                    [i]
                                                                ["userCode"] ??
                                                            "no data",
                                                        style: bangDuLieu))),
                                                DataCell(Container(
                                                    // width: (MediaQuery.of(context).size.width / 10) * 0.5,
                                                    child: Text(
                                                        resultNhanVien["content"]
                                                                    [i]
                                                                ["fullName"] ??
                                                            "no data",
                                                        style: bangDuLieu))),
                                                DataCell(Container(
                                                    width:
                                                        (MediaQuery.of(context)
                                                                    .size
                                                                    .width /
                                                                10) *
                                                            0.55,
                                                    child: Text(
                                                        resultNhanVien["content"]
                                                                    [i]
                                                                ["birthDate"] ??
                                                            "no data",
                                                        style: bangDuLieu))),
                                                DataCell(Container(
                                                    // width: (MediaQuery.of(context).size.width / 10) * 0.22,
                                                    child: Text(
                                                        getGender(resultNhanVien[
                                                                    "content"]
                                                                [i]["gender"] ??
                                                            "ss"),
                                                        style: bangDuLieu))),
                                                DataCell(Container(
                                                    // width: (MediaQuery.of(context).size.width / 10) * 0.45,
                                                    child: Text(
                                                        resultNhanVien[
                                                                    "content"]
                                                                [i]["phone"] ??
                                                            "no data",
                                                        style: bangDuLieu))),
                                                DataCell(Container(
                                                  width: (MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          10) *
                                                      0.35,
                                                  child: Text(
                                                      resultNhanVien["content"]
                                                                          [i][
                                                                      "vaitro"] !=
                                                                  null &&
                                                              resultNhanVien["content"]
                                                                              [i]
                                                                          [
                                                                          "vaitro"]
                                                                      [
                                                                      'name'] !=
                                                                  null
                                                          ? resultNhanVien[
                                                                  "content"][i]
                                                              ["vaitro"]['name']
                                                          : "No data",
                                                      style: bangDuLieu),
                                                )),
                                                DataCell(Container(
                                                  width: (MediaQuery.of(context)
                                                              .size
                                                              .width /
                                                          10) *
                                                      0.8,
                                                  child: Text(
                                                      ((resultNhanVien["content"]
                                                                          [i][
                                                                      "phongban"] !=
                                                                  null &&
                                                              resultNhanVien["content"]
                                                                              [i]
                                                                          ["phongban"]
                                                                      [
                                                                      'departName'] !=
                                                                  null)
                                                          ? resultNhanVien[
                                                                      "content"]
                                                                  [i]["phongban"]
                                                              ['departName']
                                                          : "No data"),
                                                      style: bangDuLieu),
                                                )),
                                                DataCell(
                                                  Container(
                                                    // width: (MediaQuery.of(context).size.width / 10) * 0.15,
                                                    child: Consumer<
                                                        NavigationModel>(
                                                      builder: (context,
                                                              navigationModel,
                                                              child) =>
                                                          Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(left: 20),
                                                        child: InkWell(
                                                          onTap: () {
                                                            navigationModel.add(
                                                                pageUrl:
                                                                    ("/view-hsns" +
                                                                        "/${resultNhanVien["content"][i]["id"]}"));
                                                          },
                                                          child: Icon(
                                                              Icons.visibility),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      )));
                            }))
                          ],
                        ),
                        if (totalElements != 0)
                          paging
                        else
                          Center(
                              child: Text("Không có kết quả phù hợp",
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black,
                                  ))),
                      ],
                    ),
                  ],
                ),
              ),
              Footer()
            ]),
          );
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

class Depart {
  int id;
  String departName;

  Depart({
    required this.id,
    required this.departName,
  });

  factory Depart.fromJson(Map<dynamic, dynamic> json) {
    return Depart(
      id: json['id'] ?? 0,
      departName: json['departName'] ?? "No data!",
    );
  }
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'departName': departName,
    };
  }
}
