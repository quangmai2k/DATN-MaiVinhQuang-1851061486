import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_charts/charts.dart';

import '../../../common/style.dart';
import '../../../model/type.dart';

class PhatTrienThiTruong extends StatelessWidget {
  final double heightBox = 100;
  const PhatTrienThiTruong({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ignore: non_constant_identifier_names
    List<CTVienMoi> _CTVMoi = [
      CTVienMoi('Đơn hàng 1 có lịch thi tuyển vào ngày 01/04/2022', 'nguyen van phuc', 1),
      CTVienMoi('Đơn hàng 1 có lịch thi tuyển vào ngày 01/04/2022', 'nguyen van phuc', 2),
      CTVienMoi('Đơn hàng 1 có lịch thi tuyển vào ngày 01/04/2022', 'nguyen van phuc', 3),
      CTVienMoi('Đơn hàng 1 có lịch thi tuyển vào ngày 01/04/2022', 'nguyen van phuc', 4),
      CTVienMoi('Đơn hàng 1 có lịch thi tuyển vào ngày 01/04/2022 Đơn hàng 1 có lịch thi tuyển vào ngày 01/04/2022', 'nguyen van phuc', 5)
    ];
    // ignore: unused_local_variable
    double screenheight = MediaQuery.of(context).size.height;
    double screenwidth = MediaQuery.of(context).size.width;

    return Material(
      //chú ý thêm material nếu không code sẽ lỗi
      child: ListView(
        children: [
          Container(
            color: backgroundPage,
            padding: EdgeInsets.symmetric(vertical: verticalPaddingPage, horizontal: horizontalPaddingPage),
            // margin: EdgeInsets.only(top: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phát triển thị trường', /*style: tenDanhSach*/
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width: screenwidth / 4,
                        height: heightBox,
                        decoration: BoxDecoration(
                          // borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: colorWhite,
                          // border: Border.all(
                          //   width: 1,
                          //   // color: Color.fromARGB(255, 194, 194, 194),
                          //   color: Color(0xffD4D6D8),
                          // ),
                          borderRadius: BorderRadius.all(
                            Radius.elliptical(20, 20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xffE7EAF1).withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 0), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Container(
                                    width: screenwidth / 20,
                                    height: screenwidth / 20,
                                    decoration: BoxDecoration(
                                      color: Color(0xff7D00B5),
                                      // border: Border.all(
                                      //     color: Colors.blue, width: 1),
                                      borderRadius: BorderRadius.all(
                                        Radius.elliptical(10, 10),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.account_balance_wallet_outlined,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: SizedBox(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'TTS Đang quan tâm',
                                          style: TextStyle(
                                            color: Color(0xff7F838B),
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          "1000",
                                          style: TextStyle(
                                            color: Color(0xff141B2B),
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 30),
                        width: screenwidth / 4,
                        height: heightBox,
                        decoration: BoxDecoration(
                          // borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: Colors.white,
                          // border: Border.all(
                          //   width: 1,
                          //   // color: Color.fromARGB(255, 194, 194, 194),
                          //   color: Color(0xffD4D6D8),
                          // ),
                          borderRadius: BorderRadius.all(
                            Radius.elliptical(20, 20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xffE7EAF1).withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 0), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Color(0xff265ED6),
                                      // border: Border.all(
                                      //     color: Colors.blue, width: 1),
                                      borderRadius: BorderRadius.all(
                                        Radius.elliptical(10, 10),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.ad_units_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: SizedBox(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Chương trình khuyến mãi',
                                          style: TextStyle(
                                            color: Color(0xff7F838B),
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 8,
                                        ),
                                        Text(
                                          "1000",
                                          style: TextStyle(
                                            color: Color(0xff141B2B),
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  //biểu đồ
                  children: [
                    Expanded(
                      flex: 5,
                      child: PieChart(),
                    ),
                    //thông báo
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: EdgeInsets.all(30),
                        margin: EdgeInsets.only(top: 30, left: 30),
                        width: MediaQuery.of(context).size.width * 1,
                        height: 470,
                        // margin: EdgeInsets.fromLTRB(30, 40, 0, 0),
                        decoration: BoxDecoration(
                          // borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: colorWhite,
                          // border: Border.all(
                          //   width: 1,
                          //   // color: Color.fromARGB(255, 194, 194, 194),
                          //   color: Color(0xffD4D6D8),
                          // ),
                          borderRadius: BorderRadius.all(
                            Radius.elliptical(20, 20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xffE7EAF1).withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 0), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Thông báo lịch thi tuyển',
                                  style: TextStyle(
                                    color: Color(
                                      0xff212529,
                                    ),
                                    fontSize: 20,
                                  ),
                                ),
                                Icon(
                                  Icons.notifications,
                                  color: Color(0xff009C87),
                                )
                              ],
                            ),
                            Column(
                              children: [
                                for (int j = 0; j < _CTVMoi.length; j++)
                                  Container(
                                    padding: EdgeInsets.only(
                                      top: 18,
                                      bottom: 18,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          width: 1,
                                          color: Color(0xffC8C9CA),
                                        ),
                                      ),
                                    ),
                                    child: InkWell(
                                      // onHover: (value) => Colors.red,
                                      child: Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(left: 10),
                                            child: Container(
                                                width: 30,
                                                height: 30,
                                                decoration: BoxDecoration(
                                                  color: Color(0xffF577C74),
                                                  // border: Border.all(
                                                  //     color: Colors.blue,
                                                  //     width: 1),
                                                  borderRadius: BorderRadius.all(
                                                    Radius.elliptical(10, 10),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '#${_CTVMoi[j].sTT.toString()}',
                                                    // '${}',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(color: Colors.white, fontSize: 15),
                                                  ),
                                                )),
                                          ),
                                          SizedBox(width: 20),
                                          Flexible(
                                            child: Text(
                                              _CTVMoi[j].tenCTV,
                                              maxLines: 2,
                                              softWrap: false,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: (() {}),
                                    ),
                                  ),
                                Container(
                                  margin: EdgeInsets.only(top: 18),
                                  child: TextButton(
                                    onPressed: () {},
                                    child: Text(
                                      'Xem tất cả các thông báo ',
                                      style: TextStyle(
                                        color: Color(0xffF577C74),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                /////////////////////
                Row(
                  //biểu đồ
                  children: [
                    // Expanded(
                    //   flex: 6,
                    //   // child: PieChart(),
                    //   child: BieuDo(),
                    // ),
                    // //thông báo
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: EdgeInsets.all(30),
                        margin: EdgeInsets.only(top: 30, left: 30),
                        width: MediaQuery.of(context).size.width * 1,
                        height: 450,
                        decoration: BoxDecoration(
                          // borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: colorWhite,
                          // border: Border.all(
                          //   width: 1,
                          //   // color: Color.fromARGB(255, 194, 194, 194),
                          //   color: Color(0xffD4D6D8),
                          // ),
                          borderRadius: BorderRadius.all(
                            Radius.elliptical(20, 20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xffE7EAF1).withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: Offset(0, 0), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Cộng tác viên mới',
                                  style: TextStyle(
                                    color: Color(
                                      0xff212529,
                                    ),
                                    fontSize: 20,
                                    // fontWeight: FontWeight.w500,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    'Xem thêm...',
                                    style: TextStyle(
                                      color: Color(0xff009C87),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            //-------------------------------
                            Container(
                              width: MediaQuery.of(context).size.width * 1,
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
                              // decoration: BoxDecoration(
                              //   border: Border.all(
                              //     width: 1,
                              //     color: Color(0xff51B4D5),
                              //   ),
                              // ),
                              child: Column(
                                children: [
                                  DataTable(
                                    columns: <DataColumn>[
                                      DataColumn(
                                        label: Text(
                                          'STT',
                                          style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Tên CTV',
                                          style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      DataColumn(
                                        label: Text(
                                          'Mã CTV',
                                          style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                    rows: const <DataRow>[
                                      DataRow(
                                        cells: <DataCell>[
                                          DataCell(Text('1')),
                                          DataCell(Text('Nguyễn Van Phúc')),
                                          DataCell(Text('456789')),
                                        ],
                                      ),
                                      DataRow(
                                        cells: <DataCell>[
                                          DataCell(Text('2')),
                                          DataCell(Text('Bùi Hồng Trang')),
                                          DataCell(Text('34568')),
                                        ],
                                      ),
                                      DataRow(
                                        cells: <DataCell>[
                                          DataCell(Text('3')),
                                          DataCell(Text('Hồng Đỗ')),
                                          DataCell(Text('12345')),
                                        ],
                                      ),
                                      DataRow(
                                        cells: <DataCell>[
                                          DataCell(Text('4')),
                                          DataCell(Text('Kiều Chinh')),
                                          DataCell(Text('5667')),
                                        ],
                                      ),
                                      DataRow(
                                        cells: <DataCell>[
                                          DataCell(Text('5')),
                                          DataCell(Text('Lại Thị Yến')),
                                          DataCell(Text('67798')),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//------------Biểu đồ tròn trạng thái TTS----

class PieChart extends StatefulWidget {
  const PieChart({Key? key}) : super(key: key);

  @override
  State<PieChart> createState() => _PieChartState();
}

class _PieChartState extends State<PieChart> {
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      margin: EdgeInsets.only(top: 30),
      width: MediaQuery.of(context).size.width * 1,
      height: 470,
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.all(
          Radius.elliptical(20, 20),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xffE7EAF1).withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trạng thái TTS',
            style: TextStyle(
              color: Color(
                0xff212529,
              ),
              fontSize: 20,
            ),
          ),
          Expanded(
            child: SfCircularChart(
              tooltipBehavior: _tooltipBehavior,
              legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
              // title: ChartTitle(text: 'Trạng thái TTS', alignment: Alignment.topLeft),
              series: <CircularSeries>[
                // Render pie chart
                PieSeries<ChartDataP, String>(
                  enableTooltip: true,
                  dataSource: [
                    // Bind data source
                    ChartDataP('Đang quan tâm', 35),
                    ChartDataP('Đã trúng tuyển', 28),
                    ChartDataP('Đã tư vấn', 34),
                    ChartDataP('Đã khai form', 32),
                    ChartDataP('Đã xuất cảnh', 40)
                  ],
                  xValueMapper: (ChartDataP data, _) => data.x,
                  yValueMapper: (ChartDataP data, _) => data.y,
                  // name: 'Data',
                  dataLabelSettings: DataLabelSettings(isVisible: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChartDataP {
  ChartDataP(this.x, this.y, [this.color]);
  final String x;
  final double y;
  final Color? color;
}
