import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';

import 'package:universal_html/html.dart';

import 'package:pdf/widgets.dart' as pw;
// import 'package:file_saver/file_saver.dart';
import 'package:printing/printing.dart';

import '../../../../model/market_development/nghiepdoan_tts_xuat_canh.dart';
import '../../../../model/market_development/user.dart';

Future<void> xuatFileDoc(List<NghiepDoanThucTapSinhXuatCanh> listUnionObjectResult, Map<int, List<User>> mapNhomNghiepDoan) async {
  final doc = pw.Document();
  final image = await WidgetWraper.fromWidget(widget: _renderBody(), constraints: const BoxConstraints(maxHeight: 1200, maxWidth: 700));

  doc.addPage(pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Container(
            child: pw.Image(image),
          ),
        );
      }));
  // final PdfDocument document = doc.document;
  final Uint8List bytes = await doc.save();
  // MimeType type = MimeType.PDF;
  // FileSaver.instance.saveFile('thaiCongChua.pdf', Uint8List.fromList(bytes), '',
  //     mimeType: type);
  AnchorElement(href: 'data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}')
    ..setAttribute('download', 'doc.pdf')
    ..click();
}

_renderBody() {
  return Container(
    // color: Colors.blue[100],
    child: Column(
      children: [_renderHeader(), _renderTable(), _renderContent()],
    ),
  );
}

_renderHeader() {
  return Container(
    padding: EdgeInsets.only(right: 20, bottom: 20),
    child: Column(
      children: [
        _renderText('BM- QT/TCKT-06-01', Alignment.centerRight),
        _renderText('請求書', Alignment.center),
        _renderText('No : SM 01', Alignment.centerRight),
        _renderText('Date : 2022年09月26日', Alignment.centerRight)
      ],
    ),
  );
}

_renderContent() {
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(flex: 1, child: _renderText('要件 :', Alignment.center)),
                Expanded(flex: 2, child: _renderText('請求書 ', Alignment.centerLeft)),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(flex: 1, child: _renderText('送付枚数 :', Alignment.center)),
                Expanded(flex: 2, child: _renderText('04枚 (本紙含)', Alignment.centerLeft)),
              ],
            ),
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(flex: 1, child: _renderText('至急！', Alignment.center)),
                Expanded(flex: 2, child: _renderText('ご確認ください ', Alignment.centerLeft)),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(flex: 1, child: _renderText('ご返信ください :', Alignment.center)),
                Expanded(flex: 2, child: _renderText('ご参考まで', Alignment.centerLeft)),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(
        height: 10,
      ),
      Container(
          width: 600,
          child: Container(
            decoration: BoxDecoration(border: Border.all(width: 0.5, color: Colors.black)),
            child: Text(
              '貴社、ますますご清栄のこととお喜び申し上げます。早速ですが下記の書類を送付いたしますので、ご査収のほど宜しくお願い致します。',
              textAlign: TextAlign.center,
            ),
          )),
      const SizedBox(
        height: 10,
      ),
      _renderText(
          'ベトナム社会主義共和国・AAM国際人材株式会社と企業技術研修協同組合との外国人技能実習事業に関する協定書を参照すると監理団体（企業技術研修協同組合）は協定書の規定に基づく送出し機関による技能実習生の管理費・渡航費を、送出し機関に対して支払うものとするとあります。下記の通り請求申し上げます。ご不明な点等ございましたら、お気軽にお問い合わせ下さい。',
          Alignment.centerLeft),
      const SizedBox(
        height: 10,
      ),
      Container(
        padding: EdgeInsets.only(left: 20),
        alignment: Alignment.topLeft,
        child: Text(
          '請求金額 :¥1.165.224円',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      _renderText('（詳細については、添付ファイルにてご確認をお願いします。）', Alignment.topLeft),
      _renderText('本書面到達後、2022年9月30日までに上記の金額を以下の金融機関にお振込下さい。', Alignment.topLeft),
      _renderText('銀行名 : Military Commercial Joint Stock Bank (MB Bank)  My Dinh Branch', Alignment.topLeft),
      _renderText('住所  : 1th Floor & 2nd Floor, HH4 SongDa Twin Tower, Pham Hung Road, Nam Tu Liem, Ha Noi.', Alignment.topLeft),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(flex: 1, child: _renderText('口座番号（円):', Alignment.center)),
                Expanded(flex: 2, child: _renderText('0001400599438 ', Alignment.centerLeft)),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(flex: 1, child: _renderText('SWIFT BIC code :', Alignment.center)),
                Expanded(flex: 2, child: _renderText('MSCBVNVX', Alignment.centerLeft)),
              ],
            ),
          ),
        ],
      ),
      _renderText('口座名: AAM INTERNATIONAL HUMAN SUPPLY DEVELOPMENT JOINT STOCK COMPANY', Alignment.topLeft),
      _renderText('受取人住所:7th Floor (Office Building), Building Golden Field My Dinh, No.24 Nguyen Co Thach, My Dinh 2 Ward, Nam Tu Liem, Ha Noi, Viet Nam.', Alignment.topLeft),
      Container(
        alignment: Alignment.centerRight,
        child: _renderText('AAM国際人材株式会社', Alignment.centerRight),
      )
    ],
  );
}

_renderTable() {
  return Table(
    border: TableBorder.all(color: Colors.black),
    children: [
      TableRow(children: [_renderText('送信先', Alignment.center), _renderText('発信元', Alignment.center)]),
      TableRow(children: [
        Row(children: [
          Expanded(
            flex: 1,
            child: _renderText('日付', Alignment.center),
          ),
          _renderVerticalDivider(20),
          Expanded(
            flex: 2,
            child: _renderText('2021年09月26日', Alignment.center),
          ),
        ]),
        Row(children: [
          Expanded(
            flex: 1,
            child: _renderText('名前', Alignment.center),
          ),
          _renderVerticalDivider(20),
          Expanded(
            flex: 2,
            child: _renderText('AAM 国際人材株式会社', Alignment.center),
          ),
        ]),
      ]),
      TableRow(children: [
        Row(children: [
          Expanded(
            flex: 1,
            child: _renderText('協同組合名', Alignment.center),
          ),
          _renderVerticalDivider(20),
          Expanded(
            flex: 2,
            child: _renderText('企業技術研修協同組合', Alignment.center),
          ),
        ]),
        Row(children: [
          Expanded(
            flex: 1,
            child: _renderText('FAX番号', Alignment.center),
          ),
          _renderVerticalDivider(20),
          Expanded(
            flex: 2,
            child: _renderText('', Alignment.center),
          ),
        ]),
      ]),
      TableRow(children: [
        Row(children: [
          Expanded(
            flex: 1,
            child: _renderText('ご 担 当 者', Alignment.center),
          ),
          _renderVerticalDivider(20),
          Expanded(
            flex: 2,
            child: _renderText('長居 様', Alignment.center),
          ),
        ]),
        Row(children: [
          Expanded(
            flex: 1,
            child: _renderText('電話番号', Alignment.center),
          ),
          _renderVerticalDivider(20),
          Expanded(
            flex: 2,
            child: _renderText('(+84) 24 7300 7768', Alignment.center),
          ),
        ])
      ]),
      TableRow(children: [
        Container(
          height: 140,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: _renderText('FAX 番号', Alignment.center),
              ),
              _renderVerticalDivider(140),
              Expanded(
                flex: 2,
                child: _renderText('(+81)87-814-5592', Alignment.center),
              ),
            ],
          ),
        ),
        Container(
          child: Column(children: [
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _renderText('住 所', Alignment.center),
                ),
                _renderVerticalDivider(120),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    child: _renderText('7THFLOOR, BUILDING GOLDEN FIELD, NO.24 NGUYEN CO THACH, MY DINH 2, NAM TU LIEM, HA NOI, VIET NAM.', Alignment.topLeft),
                  ),
                )
              ],
            ),
            const Divider(
              height: 0.5,
              color: Colors.black,
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _renderText('E-MAIL', Alignment.center),
                ),
                _renderVerticalDivider(20),
                Expanded(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsets.only(left: 10),
                    child: _renderText('huyennt@aamhr.com.vn', Alignment.topLeft),
                  ),
                )
              ],
            )
          ]),
        ),
      ]),
    ],
  );
}

_renderVerticalDivider(height) {
  return Container(
    height: height,
    child: VerticalDivider(
      width: 0.5,
      color: Colors.black,
    ),
  );
}

_renderText(text, alignment) {
  return Container(
    alignment: alignment,
    child: Text(
      text,
    ),
  );
}
