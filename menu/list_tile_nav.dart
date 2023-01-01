// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../model/model.dart';
import '../../../common/style.dart';

class TitleNavBar extends StatefulWidget {
  final IconData iconExpansionTile;
  final String titleExpansionTile;
  final NavigationModel navigationModel;
  final dynamic listMenu;
  const TitleNavBar(
      {Key? key,
      required this.iconExpansionTile,
      required this.titleExpansionTile,
      required this.navigationModel,
      required this.listMenu})
      : super(key: key);

  @override
  State<TitleNavBar> createState() => _TitleNavBarState();
}

class _TitleNavBarState extends State<TitleNavBar> {
  dynamic _listTitle = [];
  bool checkShow = false;
  late String currentPath;
  @override
  void initState() {
    // TODO: implement initState
    currentPath = getUrl2();
    for (var row
        in Provider.of<SecurityModel>(context, listen: false).listMenu) {
      if (row['isMenu'] == 1 &&
          row['isGroup'] == 1 &&
          row['navigation'] == "/$currentPath") {
        Provider.of<SecurityModel>(context, listen: false)
            .storage
            .setItem("currentState", row['id']);
        Provider.of<SecurityModel>(context, listen: false)
            .storage
            .getItem("currentState");
      }
    }
    checkExpanded();
  }

  String getUrl2() {
    if (Provider.of<NavigationModel>(context, listen: false).currentUrl !=
        null) {
      String url =
          Provider.of<NavigationModel>(context, listen: false).currentUrl!;
      String path = url.split("/")[1];
      return "$path";
    } else {
      var url = window.location.href;
      String path = url.split("/")[4];
      return path;
    }
  }

  checkExpanded() {
    for (var row in widget.listMenu)
      if (row['id'] ==
          Provider.of<SecurityModel>(context, listen: false)
              .storage
              .getItem("currentState")) {
        setState(() {
          checkShow = true;
        });

        break;
      } else {
        setState(() {
          checkShow = false;
        });
      }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double parrent = 280;
    double daddy = 200;
    double fontSize = 16;
    if (width > 1900) {
      parrent = 290;
      daddy = 220;
      fontSize = 16;
    } else if (width > 1600) {
      parrent = 235;
      daddy = 180;
    } else if (width > 1000) {
      parrent = 200;
      daddy = 150;
      fontSize = 16;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.fromLTRB(20, 5, 20, 5),
          decoration: BoxDecoration(
            color: checkShow ? Colors.white : Color(0xff459A88),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextButton.icon(
            icon: Icon(
              widget.iconExpansionTile,
              color: checkShow ? Color(0xff459A88) : Colors.white,
            ),
            label: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 15, 20, 15),
                  child: SizedBox(
                    width: daddy,
                    child: Text(
                      widget.titleExpansionTile,
                      style: TextStyle(
                          color: checkShow ? Color(0xff459A88) : Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ),
                Icon(
                  checkShow ? Icons.expand_less : Icons.expand_more,
                  color: checkShow ? Color(0xff459A88) : Colors.white,
                )
              ],
            ),
            onPressed: () {
              checkShow = !checkShow;
              setState(() {});
            },
          ),
        ),
        Container(
            margin: EdgeInsets.fromLTRB(28, 0, 0, 0),
            decoration: BoxDecoration(
              border: Border(left: BorderSide(width: 1, color: Colors.grey)),
            ),
            child: Container(
              child: checkShow
                  ? Column(
                      children: [
                        for (var row in widget.listMenu)
                          Container(
                              margin:
                                  EdgeInsets.only(right: 20, top: 5, bottom: 5),
                              decoration: BoxDecoration(
                                color: Color(0xff459A88),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: TextButton(
                                onPressed: () {
                                  widget.navigationModel
                                      .add(pageUrl: row['navigation']);
                                },
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: parrent,
                                      child: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            30, 10, 0, 10),
                                        child: Text(
                                          "${row['moduleName']}",
                                          overflow: TextOverflow.fade,
                                          style: TextStyle(
                                            color: Provider.of<SecurityModel>(
                                                            context,
                                                            listen: false)
                                                        .storage
                                                        .getItem(
                                                            "currentState") ==
                                                    row['id']
                                                ? Colors.orange[400]
                                                : Colors.white,
                                            fontWeight: Provider.of<
                                                                SecurityModel>(
                                                            context,
                                                            listen: false)
                                                        .storage
                                                        .getItem(
                                                            "currentState") ==
                                                    row['id']
                                                ? FontWeight.w600
                                                : FontWeight.w500,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ))
                      ],
                    )
                  : Container(),
            ))
      ],
    );
  }
}

// class TitleNav extends StatefulWidget {
//   final String name;
//   final Function? redirectUrl;
//   final Color? color;
//   final FontWeight? fontWeight;
//   TitleNav(
//       {Key? key,
//       required this.name,
//       this.redirectUrl,
//       this.color,
//       this.fontWeight})
//       : super(key: key);

//   @override
//   State<TitleNav> createState() => _TitleNavState();
// }

// class _TitleNavState extends State<TitleNav> {
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: SizedBox(width: 12),
//       title: Text(
//         widget.name,
//         style: TextStyle(
//           color: widget.color,
//           fontWeight: widget.fontWeight ?? FontWeight.w500,
//         ),
//       ),
//       onTap: () async {
//         setState(() {
//           if (widget.redirectUrl != null) {
//             widget.redirectUrl!();
//             _customTileExpanded = true;
//           }
//         });
//       },
//     );
//   }
// }
