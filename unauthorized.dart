import 'package:flutter/material.dart';

import 'navigation.dart';

class Unauthorized extends StatelessWidget {
  const Unauthorized({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(widgetBody: UnauthorizedBody());
  }
}

class UnauthorizedBody extends StatefulWidget {
  const UnauthorizedBody({Key? key}) : super(key: key);

  @override
  State<UnauthorizedBody> createState() => UunauthorizedBodyState();
}

class UunauthorizedBodyState extends State<UnauthorizedBody> {
  @override
  // ignore: must_call_super
  void initState() {}

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
          child: Text(
        'Bạn không có quyền thực hiện chức năng này',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
      )),
    );
  }
}
