import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/widgets/ui/bars.dart';
import 'package:provider/provider.dart';
import '../../../../common/style.dart';
import '../../../../model/model.dart';

class ChinhSuaThongTinCaNhan extends StatefulWidget {
  const ChinhSuaThongTinCaNhan({Key? key}) : super(key: key);

  @override
  State<ChinhSuaThongTinCaNhan> createState() => _ChinhSuaThongTinCaNhanState();
}

class _ChinhSuaThongTinCaNhanState extends State<ChinhSuaThongTinCaNhan> {
  bool handLeft = false;
  bool handRight = false;
  bool? checkRadioBtnSTT;
  bool? checkRadioBtnNA;
  bool? checkRadioBtnBL;
  bool? checkRadioBtnNN;
  bool? checkRadioBtnVisa;
  bool? checkRadioBtnDN;
  bool? checkRadioBtnSex;
  String selectedForm = 'Lao động phổ thông';
  List<String> itemsForm = [
    'Kỹ sư',
    'Lao động phổ thông',
    'Du học',
    'Điều dưỡng'
  ];
  String selectedQuanHe = 'Chưa kết hôn';
  List<String> itemsQuanHe = [
    'Đã kết hôn',
    'Chưa kết hôn',
    'Đã ly hôn',
  ];
  String selectedHocVan = 'Trung học phổ thông';
  List<String> itemsHocVan = [
    'Trung học phổ thông',
    'Cao đẳng',
    'Đại học',
  ];
  String selectedDanToc = 'Kinh';
  List<String> itemsDanToc = ['Kinh', 'Tày', 'Thái', '...'];
  String selectedTonGiao = 'Không';
  List<String> itemsTonGiao = ['Có', 'Không'];

  Map<String, bool> listNganhNghe = {
    'Đóng gói Mayone': false,
    'Nông nghiệp': false,
    'Trồng dâu': false,
    'Đóng gói hàng đông lạnh hải sản': false,
    'Hái dâu': false,
  };
  DateTime selectedDate = DateTime.now();

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  DateTime selectedDateCMND = DateTime.now();

  _selectDateCMND(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDateCMND,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDateCMND = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundPage,
      padding: EdgeInsets.symmetric(
          vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
      child: SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 20),
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SelectableText(
                    'Thông tin sinh viên',
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      flex: 8,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: SelectableText(
                                    "Loại form: ",
                                    style: titleWidgetBox,
                                  )),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  height: 40,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2(
                                      buttonPadding: EdgeInsets.only(left: 10),
                                      buttonDecoration: BoxDecoration(
                                          border: Border.all(
                                              width: 0.5,
                                              style: BorderStyle.solid)),
                                      items: itemsForm
                                          .map((item) =>
                                              DropdownMenuItem<String>(
                                                  value: item,
                                                  child: SelectableText(item,
                                                      style: const TextStyle(
                                                          fontSize: 14))))
                                          .toList(),
                                      value: selectedForm,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedForm = value as String;
                                        });
                                      },
                                      buttonHeight: 40,
                                      itemHeight: 40,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Container(),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: SelectableText(
                                    "Họ và tên: ",
                                    style: titleWidgetBox,
                                  )),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 40,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: SelectableText(
                                    "Ngày sinh: ",
                                    style: titleWidgetBox,
                                  )),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  height: 40,
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 0.5,
                                          style: BorderStyle.solid)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SelectableText(
                                          "${selectedDate.toLocal()}"
                                              .split(' ')[0],
                                          style: sizeTextKhung),
                                      SizedBox(height: 20.0),
                                      IconButton(
                                          onPressed: () => _selectDate(context),
                                          icon: Icon(Icons.date_range),
                                          color: Colors.blue[400]),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(flex: 1, child: Container()),
                              Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: [
                                      Expanded(
                                          flex: 1,
                                          child: SelectableText(
                                            "Tuổi: ",
                                            style: titleWidgetBox,
                                          )),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          height: 40,
                                          child: TextField(
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 3,
                                        child: Container(),
                                      ),
                                    ],
                                  ))
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: SelectableText(
                                    "Địa chỉ: ",
                                    style: titleWidgetBox,
                                  )),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 40,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: SelectableText(
                                    "Giới tính: ",
                                    style: titleWidgetBox,
                                  )),
                              Expanded(
                                  flex: 3,
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: ListTile(
                                        title: const SelectableText('Nam'),
                                        leading: Radio<bool>(
                                          value: true,
                                          groupValue: checkRadioBtnSex,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              checkRadioBtnSex = value;
                                            });
                                          },
                                        ),
                                      )),
                                      Expanded(
                                          child: ListTile(
                                        title: const SelectableText('Nữ'),
                                        leading: Radio<bool>(
                                          value: false,
                                          groupValue: checkRadioBtnSex,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              checkRadioBtnSex = value;
                                            });
                                          },
                                        ),
                                      ))
                                    ],
                                  )),
                              Expanded(flex: 2, child: Container())
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: SelectableText(
                                    "Số CMND/CCCD: ",
                                    style: titleWidgetBox,
                                  )),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 40,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: SelectableText(
                                    "Ngày cấp: ",
                                    style: titleWidgetBox,
                                  )),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.15,
                                  height: 40,
                                  padding: EdgeInsets.only(left: 10),
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: 0.5,
                                          style: BorderStyle.solid)),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SelectableText(
                                          "${selectedDateCMND.toLocal()}"
                                              .split(' ')[0],
                                          style: sizeTextKhung),
                                      SizedBox(height: 20.0),
                                      IconButton(
                                          onPressed: () =>
                                              _selectDateCMND(context),
                                          icon: Icon(Icons.date_range),
                                          color: Colors.blue[400]),
                                    ],
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Container(),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: SelectableText(
                                    "Nơi cấp: ",
                                    style: titleWidgetBox,
                                  )),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 40,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: SelectableText(
                                    "Số điện thoại TTS: ",
                                    style: titleWidgetBox,
                                  )),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 40,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: SelectableText(
                                    "Số điện thoại gia đình: ",
                                    style: titleWidgetBox,
                                  )),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 40,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: SelectableText(
                                    "Email: ",
                                    style: titleWidgetBox,
                                  )),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 40,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: SelectableText(
                                    "Tình trạng hôn nhân: ",
                                    style: titleWidgetBox,
                                  )),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  height: 40,
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton2(
                                      buttonPadding: EdgeInsets.only(left: 10),
                                      buttonDecoration: BoxDecoration(
                                          border: Border.all(
                                              width: 0.5,
                                              style: BorderStyle.solid)),
                                      items: itemsQuanHe
                                          .map((item) =>
                                              DropdownMenuItem<String>(
                                                  value: item,
                                                  child: SelectableText(item,
                                                      style: const TextStyle(
                                                          fontSize: 14))))
                                          .toList(),
                                      value: selectedQuanHe,
                                      onChanged: (value) {
                                        setState(() {
                                          selectedQuanHe = value as String;
                                        });
                                      },
                                      buttonHeight: 40,
                                      itemHeight: 40,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 4,
                                child: Container(),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: SelectableText(
                                    "Trình độ học vấn: ",
                                    style: titleWidgetBox,
                                  )),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 40,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: SelectableText(
                                    "SĐT tuyển dụng: ",
                                    style: titleWidgetBox,
                                  )),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  height: 40,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Container(),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25,
                          ),
                        ],
                      )),
                  Expanded(
                    flex: 2,
                    child: Image.network(
                        'https://scontent.fhan3-3.fna.fbcdn.net/v/t39.30808-6/270013986_2980158962296490_4480668391747260027_n.jpg?_nc_cat=101&ccb=1-7&_nc_sid=8bfeb9&_nc_ohc=9Ua-UwtVXe8AX8F-wAJ&_nc_ht=scontent.fhan3-3.fna&oh=00_AT_wMLSDZSkUqc6sbK17MQygUkgxBPleyYoZilh1DhIs-g&oe=62A914FC'),
                  ),
                  Expanded(flex: 1, child: Container())
                ],
              ),
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: SelectableText(
                            "Trình độ học vấn: ",
                            style: titleWidgetBox,
                          )),
                      Expanded(
                        flex: 2,
                        child: Container(
                          height: 40,
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton2(
                              buttonPadding: EdgeInsets.only(left: 10),
                              buttonDecoration: BoxDecoration(
                                  border: Border.all(
                                      width: 0.5, style: BorderStyle.solid)),
                              items: itemsHocVan
                                  .map((item) => DropdownMenuItem<String>(
                                      value: item,
                                      child: SelectableText(item,
                                          style:
                                              const TextStyle(fontSize: 14))))
                                  .toList(),
                              value: selectedHocVan,
                              onChanged: (value) {
                                setState(() {
                                  selectedHocVan = value as String;
                                });
                              },
                              buttonHeight: 40,
                              itemHeight: 40,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 10,
                        child: Container(),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: SelectableText(
                                  'Dân tộc:',
                                  style: titleWidgetBox,
                                )),
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 40,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    buttonPadding: EdgeInsets.only(left: 10),
                                    buttonDecoration: BoxDecoration(
                                        border: Border.all(
                                            width: 0.5,
                                            style: BorderStyle.solid)),
                                    items: itemsDanToc
                                        .map((item) => DropdownMenuItem<String>(
                                            value: item,
                                            child: SelectableText(item,
                                                style: const TextStyle(
                                                    fontSize: 14))))
                                        .toList(),
                                    value: selectedDanToc,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedDanToc = value as String;
                                      });
                                    },
                                    buttonHeight: 40,
                                    itemHeight: 40,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(flex: 3, child: Container())
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child:
                                    SelectableText('Tôn giáo:', style: titleWidgetBox)),
                            Expanded(
                              flex: 2,
                              child: Container(
                                height: 40,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton2(
                                    buttonPadding: EdgeInsets.only(left: 10),
                                    buttonDecoration: BoxDecoration(
                                        border: Border.all(
                                            width: 0.5,
                                            style: BorderStyle.solid)),
                                    items: itemsTonGiao
                                        .map((item) => DropdownMenuItem<String>(
                                            value: item,
                                            child: SelectableText(item,
                                                style: const TextStyle(
                                                    fontSize: 14))))
                                        .toList(),
                                    value: selectedTonGiao,
                                    onChanged: (value) {
                                      setState(() {
                                        selectedTonGiao = value as String;
                                      });
                                    },
                                    buttonHeight: 40,
                                    itemHeight: 40,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(flex: 3, child: Container())
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: SelectableText(
                                'Có kinh nghiệm sống tập thể:',
                                style: titleWidgetBox,
                              )),
                          Expanded(
                              flex: 5,
                              child: Row(
                                children: [
                                  Expanded(
                                      child: ListTile(
                                    title: const SelectableText('Có'),
                                    leading: Radio<bool>(
                                      value: true,
                                      groupValue: checkRadioBtnSTT,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          checkRadioBtnSTT = value;
                                        });
                                      },
                                    ),
                                  )),
                                  Expanded(
                                      child: ListTile(
                                    title: const SelectableText('Không'),
                                    leading: Radio<bool>(
                                      value: false,
                                      groupValue: checkRadioBtnSTT,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          checkRadioBtnSTT = value;
                                        });
                                      },
                                    ),
                                  ))
                                ],
                              ))
                        ],
                      )),
                      Expanded(
                          child: Row(
                        children: [
                          Expanded(
                              flex: 2,
                              child: SelectableText(
                                'Có biết nấu ăn không:',
                                style: titleWidgetBox,
                              )),
                          Expanded(
                              flex: 5,
                              child: Row(
                                children: [
                                  Expanded(
                                      child: ListTile(
                                    title: const SelectableText('Có'),
                                    leading: Radio<bool>(
                                      value: true,
                                      groupValue: checkRadioBtnNA,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          checkRadioBtnNA = value;
                                        });
                                      },
                                    ),
                                  )),
                                  Expanded(
                                      child: ListTile(
                                    title: const SelectableText('Không'),
                                    leading: Radio<bool>(
                                      value: false,
                                      groupValue: checkRadioBtnNA,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          checkRadioBtnNA = value;
                                        });
                                      },
                                    ),
                                  ))
                                ],
                              ))
                        ],
                      )),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: SelectableText(
                            'Gia đình có tiền sử bệnh lý không?',
                            style: titleWidgetBox,
                          )),
                      Expanded(
                          flex: 3,
                          child: Row(
                            children: [
                              Expanded(
                                  child: ListTile(
                                title: const SelectableText('Có'),
                                leading: Radio<bool>(
                                  value: true,
                                  groupValue: checkRadioBtnBL,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      checkRadioBtnBL = value;
                                    });
                                  },
                                ),
                              )),
                              Expanded(
                                  child: ListTile(
                                title: const SelectableText('Không'),
                                leading: Radio<bool>(
                                  value: false,
                                  groupValue: checkRadioBtnBL,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      checkRadioBtnBL = value;
                                    });
                                  },
                                ),
                              ))
                            ],
                          )),
                      Expanded(flex: 5, child: Container())
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 4,
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: SelectableText(
                                    'Điểm mạnh (Trong tính cách):',
                                    style: titleWidgetBox,
                                  )),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  // width: MediaQuery.of(context).size.width * 0.15,
                                  child: TextField(
                                    minLines: 3,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )),
                      Expanded(flex: 1, child: Container()),
                      Expanded(
                          flex: 4,
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: SelectableText(
                                    'Điểm yếu (Trong tính cách):',
                                    style: titleWidgetBox,
                                  )),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  // width: MediaQuery.of(context).size.width * 0.15,
                                  child: TextField(
                                    minLines: 3,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )),
                      Expanded(flex: 1, child: Container())
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 4,
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: SelectableText(
                                    'Sở thích:',
                                    style: titleWidgetBox,
                                  )),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  // width: MediaQuery.of(context).size.width * 0.15,
                                  child: TextField(
                                    minLines: 3,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )),
                      Expanded(flex: 1, child: Container()),
                      Expanded(
                          flex: 4,
                          child: Row(
                            children: [
                              Expanded(
                                  flex: 3,
                                  child: SelectableText(
                                    'Tự nhận xét về tính cách:',
                                    style: titleWidgetBox,
                                  )),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  // width: MediaQuery.of(context).size.width * 0.15,
                                  child: TextField(
                                    minLines: 3,
                                    maxLines: 3,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          )),
                      Expanded(flex: 1, child: Container())
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: SelectableText(
                            'Chuyên ngành/chuyên môn được đào tạo:',
                            style: titleWidgetBox,
                          )),
                      Expanded(
                        flex: 7,
                        child: Container(
                          // width: MediaQuery.of(context).size.width * 0.15,
                          child: TextField(
                            minLines: 3,
                            maxLines: 3,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      Expanded(flex: 1, child: Container())
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: SelectableText(
                            'Lý do đi Nhật:',
                            style: titleWidgetBox,
                          )),
                      Expanded(
                        flex: 7,
                        child: Container(
                          // width: MediaQuery.of(context).size.width * 0.15,
                          child: TextField(
                            minLines: 3,
                            maxLines: 3,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      Expanded(flex: 1, child: Container())
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: SelectableText(
                                  'Thu nhập bản thân:',
                                  style: titleWidgetBox,
                                )),
                            Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 40,
                                        child: TextField(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        child: Container(
                                            margin: EdgeInsets.only(left: 20),
                                            child: SelectableText('đồng/tháng')))
                                  ],
                                )),
                            Expanded(flex: 3, child: Container())
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: SelectableText('Thu nhập gia đình:',
                                    style: titleWidgetBox)),
                            Expanded(
                                flex: 2,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 40,
                                        child: TextField(
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        child: Container(
                                            margin: EdgeInsets.only(left: 20),
                                            child: SelectableText('đồng/tháng')))
                                  ],
                                )),
                            Expanded(flex: 3, child: Container())
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 2,
                          child: SelectableText(
                            'Anh/chị đã từng ra nước ngoài chưa?',
                            style: titleWidgetBox,
                          )),
                      Expanded(
                          flex: 5,
                          child: Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  title: const SelectableText('Chưa từng'),
                                  leading: Radio<bool?>(
                                    value: true,
                                    groupValue: checkRadioBtnNN,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        checkRadioBtnNN = value;
                                      });
                                    },
                                  ),
                                ),
                              )
                            ],
                          )),
                      Expanded(flex: 1, child: Container())
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 5,
                          child: SelectableText(
                            'Anh/chị đã từng làm thủ tục đăng ký xin VISA đi Nhật lần nào chưa?',
                            style: titleWidgetBox,
                          )),
                      Expanded(
                          flex: 5,
                          child: Row(
                            children: [
                              Expanded(
                                child: ListTile(
                                  title: const SelectableText('Đã đăng ký'),
                                  leading: Radio<bool?>(
                                    value: true,
                                    groupValue: checkRadioBtnVisa,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        checkRadioBtnVisa = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListTile(
                                  title: const SelectableText('Chưa đăng ký'),
                                  leading: Radio<bool?>(
                                    value: false,
                                    groupValue: checkRadioBtnVisa,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        checkRadioBtnVisa = value;
                                      });
                                    },
                                  ),
                                ),
                              )
                            ],
                          )),
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: SelectableText(
                            'Sau 3 năm anh/chị muốn mang bao nhiêu tiền về Việt Nam?',
                            style: titleWidgetBox,
                          )),
                      Expanded(
                          flex: 2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  height: 40,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: Container(
                                      margin: EdgeInsets.only(left: 20),
                                      child: SelectableText('đồng/tháng')))
                            ],
                          )),
                      Expanded(flex: 5, child: Container())
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: SelectableText(
                                  'Điểm cộng dồn:',
                                  style: titleWidgetBox,
                                )),
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 40,
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(flex: 4, child: Container())
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                                flex: 2,
                                child: SelectableText('Điểm IQ:', style: titleWidgetBox)),
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 40,
                                child: TextField(
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(flex: 4, child: Container())
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: SelectableText(
                            'Sau khi hết hạn hợp đồng , về nước Anh/chị sẽ làm gì?',
                            style: titleWidgetBox,
                          )),
                      Expanded(
                        flex: 6,
                        child: Container(
                          // width: MediaQuery.of(context).size.width * 0.15,
                          child: TextField(
                            minLines: 3,
                            maxLines: 3,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ),
                      Expanded(flex: 1, child: Container())
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SelectableText(
                        'QUÁ TRÌNH HỌC TẬP(Yêu cầu khai chính xác, trung thực)',
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
                  TableQTHT(),
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SelectableText(
                        'TÌNH TRẠNG HỌC TẬP',
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
                  TableTTHT(),
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SelectableText(
                        'QUÁ TRÌNH LÀM VIỆC(Yêu cầu khai chính xác, trung thực)',
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
                  TableQTLV(),
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SelectableText(
                        'THÀNH PHẦN GIA ĐÌNH(Yêu cầu khai chính xác, trung thực)',
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
                  TableTPGD(),
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: SelectableText(
                        'Gia đình có đồng ý cho Anh/chị đi thực tập sinh ở Nhật không?',
                        style: titleWidgetBox,
                      )),
                      Expanded(
                          child: Row(
                        children: [
                          Expanded(
                              child: ListTile(
                            title: const SelectableText('Có'),
                            leading: Radio<bool>(
                              value: true,
                              groupValue: checkRadioBtnDN,
                              onChanged: (bool? value) {
                                setState(() {
                                  checkRadioBtnDN = value;
                                });
                              },
                            ),
                          )),
                          Expanded(
                              child: ListTile(
                            title: const SelectableText('Không'),
                            leading: Radio<bool>(
                              value: false,
                              groupValue: checkRadioBtnDN,
                              onChanged: (bool? value) {
                                setState(() {
                                  checkRadioBtnDN = value;
                                });
                              },
                            ),
                          ))
                        ],
                      ))
                    ],
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Container(
                        color: backgroundColor,
                        child: SelectableText(
                          'Tôi xin cam đoan những lời khai trên là hoàn toàn đúng sự thật nếu sai tôi xin chịu trách nghiệm và chấp nhận nộp phạt theo quy định của Công ty',
                          style: titleWidgetBox,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SelectableText(
                        'Ngành nghề mong muốn ',
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
                  LableWidthCheckbox(mapCheckBox: listNganhNghe),
                  SizedBox(
                    height: 50,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
                          textStyle: Theme.of(context)
                              .textTheme
                              .caption
                              ?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                        ),
                        onPressed: () {},
                        child: Text('Hủy', style: textButton),
                      ),
                    ),
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
                          textStyle: Theme.of(context)
                              .textTheme
                              .caption
                              ?.copyWith(fontSize: 20.0, letterSpacing: 2.0),
                        ),
                        onPressed: () {
                          Provider.of<NavigationModel>(context, listen: false)
                              .add(pageUrl: "/them-moi-lop-hoc");
                        },
                        child: Row(
                          children: [
                            Text('Lưu', style: textButton),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ],
              )
            ]),
          )
        ],
      )),
    );
  }
}

class _DataTableQTHT {
  String timeBegin;
  String timeEnd;
  String tenTruong;
  String chuyenNganh;
  String chungChi;
  _DataTableQTHT(this.timeBegin, this.timeEnd, this.tenTruong, this.chuyenNganh,
      this.chungChi);
}

class TableQTHT extends StatefulWidget {
  const TableQTHT({Key? key}) : super(key: key);

  @override
  State<TableQTHT> createState() => _TableQTHTState();
}

class _TableQTHTState extends State<TableQTHT> {
  List<_DataTableQTHT> data = [
    _DataTableQTHT('09/2026', '09/2020', '', 'Cơ khí', ''),
    _DataTableQTHT('09/2026', '09/2020', '', 'Cơ khí', ''),
    _DataTableQTHT('09/2026', '09/2020', '', 'Cơ khí', ''),
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DataTable(
                  // headingRowColor: MaterialStateProperty.all(backgroundColor),
                  columnSpacing: 0,
                  horizontalMargin: 0,
                  columns: [
                    DataColumn(
                        label: Container(
                      child: Expanded(
                          child: SelectableText(
                        'Từ tháng/năm',
                        style: titleTableData,
                        textAlign: TextAlign.center,
                      )),
                    )),
                    DataColumn(
                        label: Container(
                      child: Expanded(
                          child: SelectableText(
                        'Đến tháng/năm',
                        style: titleTableData,
                        textAlign: TextAlign.center,
                      )),
                    )),
                    DataColumn(
                        label: Container(
                      child: Expanded(
                          child: SelectableText(
                        'Tên trường',
                        style: titleTableData,
                        textAlign: TextAlign.center,
                      )),
                    )),
                    DataColumn(
                        label: Container(
                      child: Expanded(
                          child: SelectableText(
                        'Chuyên ngành đào tạo',
                        style: titleTableData,
                        textAlign: TextAlign.center,
                      )),
                    )),
                    DataColumn(
                        label: Container(
                      child: Expanded(
                          child: SelectableText(
                        'Bằng cấp/Chứng chỉ',
                        style: titleTableData,
                        textAlign: TextAlign.center,
                      )),
                    )),
                  ],
                  rows: <DataRow>[
                    for (int i = 0; i < data.length; i++)
                      DataRow(cells: <DataCell>[
                        DataCell(Container(
                          height: 40,
                          child: TextField(
                              textAlign: TextAlign.center,
                              controller: TextEditingController(
                                  text: data[i].timeBegin),
                              decoration: InputDecoration(
                                  hintText: 'Enter something',
                                  border: InputBorder.none)),
                        )),
                        DataCell(Container(
                          height: 40,
                          child: TextField(
                              textAlign: TextAlign.center,
                              controller:
                                  TextEditingController(text: data[i].timeEnd),
                              decoration: InputDecoration(
                                  hintText: 'Enter something',
                                  border: InputBorder.none)),
                        )),
                        DataCell(Container(
                          height: 40,
                          child: TextField(
                              textAlign: TextAlign.center,
                              controller: TextEditingController(
                                  text: data[i].tenTruong),
                              decoration: InputDecoration(
                                  hintText: 'Enter something',
                                  border: InputBorder.none)),
                        )),
                        DataCell(Container(
                          height: 40,
                          child: TextField(
                              textAlign: TextAlign.center,
                              controller: TextEditingController(
                                  text: data[i].chuyenNganh),
                              decoration: InputDecoration(
                                  hintText: 'Enter something',
                                  border: InputBorder.none)),
                        )),
                        DataCell(Container(
                          height: 40,
                          child: TextField(
                              textAlign: TextAlign.center,
                              controller: TextEditingController(
                                  text: data[i].chuyenNganh),
                              decoration: InputDecoration(
                                  hintText: 'Enter something',
                                  border: InputBorder.none)),
                        )),
                      ])
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      data.removeAt(data.length - 1);
                    });
                  },
                  icon: Icon(Icons.remove)),
              IconButton(
                  onPressed: () {
                    setState(() {
                      data.add(_DataTableQTHT('', '', '', '', ''));
                    });
                  },
                  icon: Icon(Icons.add))
            ],
          ),
        ],
      ),
    );
  }
}

class _DataTableTTHT {
  String year;
  String tinhTrang;
  TinhTrangHT? checkValue;
  _DataTableTTHT(this.year, this.tinhTrang) {
    this.year = year;
    this.tinhTrang = tinhTrang;
    if (tinhTrang == "Học sớm") {
      this.checkValue = TinhTrangHT.HocSom;
    } else if (tinhTrang == "Học muộn") {
      this.checkValue = TinhTrangHT.HocMuon;
    }
    if (tinhTrang == "Học lại") {
      this.checkValue = TinhTrangHT.HocLai;
    } else {}
  }
}

enum TinhTrangHT { HocLai, HocSom, HocMuon }

class TableTTHT extends StatefulWidget {
  const TableTTHT({Key? key}) : super(key: key);

  @override
  State<TableTTHT> createState() => _TableTTHTState();
}

class _TableTTHTState extends State<TableTTHT> {
  List<_DataTableTTHT> data = [
    _DataTableTTHT('2016', 'Học lại'),
    _DataTableTTHT('2017', 'Học sớm'),
    _DataTableTTHT('2018', 'Học muộn'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DataTable(
                  // headingRowColor: MaterialStateProperty.all(backgroundColor),
                  columnSpacing: 0,
                  horizontalMargin: 0,
                  columns: [
                    DataColumn(
                        label: Container(
                      child: Expanded(
                          child: SelectableText(
                        'Học muộn',
                        style: titleTableData,
                        textAlign: TextAlign.center,
                      )),
                    )),
                    DataColumn(
                        label: Container(
                      child: Expanded(
                          child: SelectableText(
                        'Học sớm',
                        style: titleTableData,
                        textAlign: TextAlign.center,
                      )),
                    )),
                    DataColumn(
                        label: Container(
                      child: Expanded(
                          child: SelectableText(
                        'Học lại',
                        style: titleTableData,
                        textAlign: TextAlign.center,
                      )),
                    )),
                    DataColumn(
                        label: Container(
                      child: Expanded(
                          child: SelectableText(
                        'Năm học',
                        style: titleTableData,
                        textAlign: TextAlign.center,
                      )),
                    )),
                  ],
                  rows: <DataRow>[
                    for (int i = 0; i < data.length; i++)
                      DataRow(cells: <DataCell>[
                        DataCell(Expanded(
                          child: Center(
                              child: Radio<TinhTrangHT>(
                            groupValue: data[i].checkValue,
                            value: TinhTrangHT.HocMuon,
                            onChanged: (TinhTrangHT? value) {
                              setState(() {
                                data[i].checkValue = value;
                              });
                            },
                          )),
                        )),
                        DataCell(Center(
                            child: Radio<TinhTrangHT>(
                          groupValue: data[i].checkValue,
                          value: TinhTrangHT.HocSom,
                          onChanged: (TinhTrangHT? value) {
                            setState(() {
                              data[i].checkValue = value;
                            });
                          },
                        ))),
                        DataCell(Center(
                            child: Radio<TinhTrangHT>(
                          groupValue: data[i].checkValue,
                          value: TinhTrangHT.HocLai,
                          onChanged: (TinhTrangHT? value) {
                            setState(() {
                              data[i].checkValue = value;
                            });
                          },
                        ))),
                        DataCell(Container(
                          height: 40,
                          child: TextField(
                              textAlign: TextAlign.center,
                              controller:
                                  TextEditingController(text: data[i].year),
                              decoration: InputDecoration(
                                  hintText: 'Enter something',
                                  border: InputBorder.none)),
                        )),
                      ])
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      data.removeAt(data.length - 1);
                    });
                  },
                  icon: Icon(Icons.remove)),
              IconButton(
                  onPressed: () {
                    setState(() {
                      data.add(_DataTableTTHT('', ''));
                    });
                  },
                  icon: Icon(Icons.add))
            ],
          ),
        ],
      ),
    );
  }
}

class _DataTableQTLV {
  String timeBegin;
  String timeEnd;
  String tenCty;
  String noiDung;
  _DataTableQTLV(this.timeBegin, this.timeEnd, this.tenCty, this.noiDung);
}

class TableQTLV extends StatefulWidget {
  const TableQTLV({Key? key}) : super(key: key);

  @override
  State<TableQTLV> createState() => _TableQTLVState();
}

class _TableQTLVState extends State<TableQTLV> {
  List<_DataTableQTLV> data = [
    _DataTableQTLV('04/2021', '06/2022', 'AMM', 'Thợ cơ khí'),
    _DataTableQTLV('04/2021', '06/2022', 'AMM', 'Thợ cơ khí'),
    _DataTableQTLV('04/2021', '06/2022', 'AMM', 'Thợ cơ khí'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DataTable(
                  // headingRowColor: MaterialStateProperty.all(backgroundColor),
                  columnSpacing: 0,
                  horizontalMargin: 0,
                  columns: [
                    DataColumn(
                        label: Container(
                      child: Expanded(
                          child: SelectableText(
                        'Từ tháng/năm',
                        style: titleTableData,
                        textAlign: TextAlign.center,
                      )),
                    )),
                    DataColumn(
                        label: Container(
                      child: Expanded(
                          child: SelectableText(
                        'Đến tháng/năm',
                        style: titleTableData,
                        textAlign: TextAlign.center,
                      )),
                    )),
                    DataColumn(
                        label: Container(
                      child: Expanded(
                          child: SelectableText(
                        'Tên công ty',
                        style: titleTableData,
                        textAlign: TextAlign.center,
                      )),
                    )),
                    DataColumn(
                        label: Container(
                      child: Expanded(
                          child: SelectableText(
                        'Nội dung công việc(Công việc cụ thể đó là)',
                        style: titleTableData,
                        textAlign: TextAlign.center,
                      )),
                    )),
                  ],
                  rows: <DataRow>[
                    for (int i = 0; i < data.length; i++)
                      DataRow(cells: <DataCell>[
                        DataCell(Expanded(
                            child: Container(
                          height: 40,
                          child: TextField(
                              textAlign: TextAlign.center,
                              controller: TextEditingController(
                                  text: data[i].timeBegin),
                              decoration: InputDecoration(
                                  hintText: 'Enter something',
                                  border: InputBorder.none)),
                        ))),
                        DataCell(Container(
                          height: 40,
                          child: TextField(
                              textAlign: TextAlign.center,
                              controller:
                                  TextEditingController(text: data[i].timeEnd),
                              decoration: InputDecoration(
                                  hintText: 'Enter something',
                                  border: InputBorder.none)),
                        )),
                        DataCell(Container(
                          height: 40,
                          child: TextField(
                              textAlign: TextAlign.center,
                              controller:
                                  TextEditingController(text: data[i].tenCty),
                              decoration: InputDecoration(
                                  hintText: 'Enter something',
                                  border: InputBorder.none)),
                        )),
                        DataCell(Container(
                          height: 40,
                          child: TextField(
                              textAlign: TextAlign.center,
                              controller:
                                  TextEditingController(text: data[i].noiDung),
                              decoration: InputDecoration(
                                  hintText: 'Enter something',
                                  border: InputBorder.none)),
                        )),
                      ])
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      data.removeAt(data.length - 1);
                    });
                  },
                  icon: Icon(Icons.remove)),
              IconButton(
                  onPressed: () {
                    setState(() {
                      data.add(_DataTableQTLV('', '', '', ''));
                    });
                  },
                  icon: Icon(Icons.add))
            ],
          ),
        ],
      ),
    );
  }
}

class _DataTableTPGD {
  String name;
  String quanHe;
  String namSinh;
  String ngheNghiep;
  String tinhTrang;
  String visa;
  bool? checkRadioBtnTT;
  bool? checkBoxBtnVisa;
  _DataTableTPGD(this.name, this.quanHe, this.namSinh, this.ngheNghiep,
      this.tinhTrang, this.visa) {
    this.checkRadioBtnTT = tinhTrang == 'Sống chung' ? true : false;
    this.checkBoxBtnVisa = visa == 'Đã từng' ? true : false;
  }
}

class TableTPGD extends StatefulWidget {
  const TableTPGD({Key? key}) : super(key: key);

  @override
  State<TableTPGD> createState() => _TableTPGDState();
}

class _TableTPGDState extends State<TableTPGD> {
  List<_DataTableTPGD> data = [
    _DataTableTPGD(
        'Nguyễn Văn B', 'Bố', '1960', 'Công nhân', 'Sống chung', 'Đã từng'),
    _DataTableTPGD(
        'Nguyễn Thị A', 'Mẹ', '1960', 'Công nhân', 'Sống riêng', 'Chưa từng'),
    _DataTableTPGD(
        'Nguyễn Văn B', 'Bố', '1960', 'Công nhân', 'Sống chung', 'Đã từng'),
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DataTable(
                  // headingRowColor: MaterialStateProperty.all(backgroundColor),
                  columnSpacing: 0,
                  horizontalMargin: 0,
                  columns: [
                    DataColumn(
                        label: Container(
                      child: Expanded(
                          child: SelectableText(
                        'Họ và tên',
                        style: titleTableData,
                        textAlign: TextAlign.center,
                      )),
                    )),
                    DataColumn(
                        label: Container(
                      child: Expanded(
                          child: SelectableText(
                        'Quan hệ',
                        style: titleTableData,
                        textAlign: TextAlign.center,
                      )),
                    )),
                    DataColumn(
                        label: Container(
                      child: Expanded(
                          child: SelectableText(
                        'Năm sinh',
                        style: titleTableData,
                        textAlign: TextAlign.center,
                      )),
                    )),
                    DataColumn(
                        label: Container(
                      child: Expanded(
                          child: SelectableText(
                        'Nghề nghiệp',
                        style: titleTableData,
                        textAlign: TextAlign.center,
                      )),
                    )),
                    DataColumn(
                        label: Container(
                      child: Expanded(
                          child: SelectableText(
                        'Sống chung',
                        style: titleTableData,
                        textAlign: TextAlign.center,
                      )),
                    )),
                    DataColumn(
                        label: Container(
                      child: Expanded(
                          child: SelectableText(
                        'Sống riêng',
                        style: titleTableData,
                        textAlign: TextAlign.center,
                      )),
                    )),
                    DataColumn(
                        label: Container(
                      child: Expanded(
                          child: SelectableText(
                        'Đã từng xin VISA hoặc đã sang Nhật',
                        style: titleTableData,
                        textAlign: TextAlign.center,
                      )),
                    )),
                  ],
                  rows: <DataRow>[
                    for (int i = 0; i < data.length; i++)
                      DataRow(cells: <DataCell>[
                        DataCell(Container(
                          height: 40,
                          child: TextField(
                              textAlign: TextAlign.center,
                              controller: TextEditingController(
                                  text: data[i].ngheNghiep),
                              decoration: InputDecoration(
                                  hintText: 'Enter something',
                                  border: InputBorder.none)),
                        )),
                        DataCell(Container(
                          height: 40,
                          child: TextField(
                              textAlign: TextAlign.center,
                              controller:
                                  TextEditingController(text: data[i].quanHe),
                              decoration: InputDecoration(
                                  hintText: 'Enter something',
                                  border: InputBorder.none)),
                        )),
                        DataCell(Container(
                          height: 40,
                          child: TextField(
                              textAlign: TextAlign.center,
                              controller:
                                  TextEditingController(text: data[i].namSinh),
                              decoration: InputDecoration(
                                  hintText: 'Enter something',
                                  border: InputBorder.none)),
                        )),
                        DataCell(Container(
                          height: 40,
                          child: TextField(
                              textAlign: TextAlign.center,
                              controller: TextEditingController(
                                  text: data[i].ngheNghiep),
                              decoration: InputDecoration(
                                  hintText: 'Enter something',
                                  border: InputBorder.none)),
                        )),
                        DataCell(
                          Center(
                            child: Radio<bool>(
                              value: true,
                              groupValue: data[i].checkRadioBtnTT,
                              onChanged: (bool? value) {
                                setState(() {
                                  data[i].checkRadioBtnTT = value;
                                });
                              },
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Radio<bool>(
                              value: false,
                              groupValue: data[i].checkRadioBtnTT,
                              onChanged: (bool? value) {
                                setState(() {
                                  data[i].checkRadioBtnTT = value;
                                });
                              },
                            ),
                          ),
                        ),
                        DataCell(
                          Center(
                            child: Checkbox(
                              checkColor: Colors.white,
                              value: data[i].checkBoxBtnVisa,
                              onChanged: (value) {
                                setState(() {
                                  data[i].checkBoxBtnVisa = value!;
                                });
                              },
                            ),
                          ),
                        ),
                      ])
                  ],
                ),
              ),
            ],
          ),
          SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      data.removeAt(data.length - 1);
                    });
                  },
                  icon: Icon(Icons.remove)),
              IconButton(
                  onPressed: () {
                    setState(() {
                      data.add(_DataTableTPGD('', '', '', '', '', ''));
                    });
                  },
                  icon: Icon(Icons.add))
            ],
          ),
        ],
      ),
    );
  }
}

class LableWidthCheckbox extends StatefulWidget {
  final Map<String, bool> mapCheckBox;
  const LableWidthCheckbox({Key? key, required this.mapCheckBox})
      : super(key: key);

  @override
  State<LableWidthCheckbox> createState() => _LableWidthCheckboxState();
}

class _LableWidthCheckboxState extends State<LableWidthCheckbox> {
  List<String> title = [];
  List<bool> valuesList = [];

  @override
  void initState() {
    title = widget.mapCheckBox.keys.toList();
    valuesList = widget.mapCheckBox.values.toList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      runSpacing: 25.0,
      spacing: 5.0,
      children: [
        for (int i = 0; i < title.length; i++)
          Container(
            width: 600,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Checkbox(
                    checkColor: Colors.white,
                    value: valuesList[i],
                    onChanged: (value) {
                      setState(() {
                        valuesList[i] = value!;
                      });
                    },
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: SelectableText(
                    title[i],
                    style: TextStyle(
                      color: Color(0xff333333),
                      fontSize: 16,
                    ),
                  ),
                )
              ],
            ),
          ),
      ],
    );
  }
}
