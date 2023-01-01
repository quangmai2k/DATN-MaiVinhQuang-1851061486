import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gentelella_flutter/model/model.dart';

import 'package:provider/provider.dart';
import '../../api.dart';
import '../../common/toast.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late Widget form;
  refresh() {
    setState(() {
      form = ForgotPasswordForm(
        notifyParent: rollback,
      );
    });
  }

  rollback() {
    setState(() {
      form = LoginForm(notifyParent: refresh);
    });
  }

  @override
  void initState() {
    super.initState();
    form = LoginForm(notifyParent: refresh);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationModel>(
      builder: (context, navigationModel, child) => Scaffold(
        body: Center(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(
                                      "assets/images/bg-top-right.png"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                alignment: Alignment.center,
                                color: Colors.black.withOpacity(0.3),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'HỆ THỐNG QUẢN LÝ NGHIỆP VỤ XUẤT KHẨU LAO ĐỘNG',
                                        style: TextStyle(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 30.0),
                                      ),
                                    ),
                                    // Công Ty Cổ Phần Phát Triển Cung Ứng Nhân Lực Quốc Tế Aam
                                    Flexible(
                                      child: Container(
                                        padding: EdgeInsets.only(top: 30),
                                        child: Text(
                                          'CÔNG TY CỔ PHẦN PHÁT TRIỂN',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 50.0),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        child: Text(
                                          'CUNG ỨNG NHÂN LỰC QUỐC TẾ AAM',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 50.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(flex: 2, child: form),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordForm extends StatefulWidget {
  final Function() notifyParent;
  const ForgotPasswordForm({Key? key, required this.notifyParent})
      : super(key: key);
  @override
  _ForgotPasswordFormState createState() => _ForgotPasswordFormState();
}

class _ForgotPasswordFormState extends State<ForgotPasswordForm> {
  get fToast => null;

  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  handleForgotPassword() async {
    onLoading(context);
    String email = _emailController.text;
    if (email.isNotEmpty) {
      var rq = {"resetEmail": email, "resetUrl": null};
      var response =
          await httpPost("/api/nguoidung/forgot_password", rq, context);
      await Future.delayed(Duration(milliseconds: 500));
      Navigator.of(context).pop(true);
      print(response["body"]);
      var thongbao = jsonDecode(response["body"]);
      print(thongbao["0"]);
      if (thongbao["0"] != null)
        showToast(
            context: context,
            msg: thongbao["0"],
            color: Colors.orangeAccent,
            icon: Icon(Icons.close));
      if (thongbao["1"] != null) {
        showToast(
            context: context,
            msg: thongbao["1"],
            color: Colors.greenAccent,
            icon: Icon(Icons.close));
        widget.notifyParent();
        // Navigator.pop(context);
      }
      if (thongbao["message"] != null)
        showToast(
            context: context,
            msg:
                "Quá trình xử lý đang gặp sự cố vui lòng nhập đúng email đã đăng kí trên hệ thống!",
            color: Colors.orangeAccent,
            icon: Icon(Icons.close));
    } else {
      Navigator.of(context).pop(true);
      showToast(
          context: context,
          msg: "Email không được để trống!",
          color: Colors.orangeAccent,
          icon: Icon(Icons.close));
    }
  }

//---------
  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationModel>(
      builder: (context, navigationModel, child) => Padding(
        padding: const EdgeInsets.only(left: 10.0, right: 10),
        child: Container(
          height: MediaQuery.of(context).size.height * 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * .2,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        onPressed: () {
                          widget.notifyParent();
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 30),
                    child: Image.asset("assets/images/logoAAM.png"),
                  ),
                  Container(
                    child: SizedBox(
                      width: 400,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Expanded(
                              flex: 10,
                              child: Text(
                                "HỆ THỐNG QUẢN LÍ NGHIỆP VỤ XUẤT KHẨU LAO ĐỘNG",
                                style: TextStyle(
                                  fontSize: 15,
                                  letterSpacing: -0.8,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xff73879C),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ]),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                          child: SizedBox(
                            width: 400,
                            height: 50,
                            child: TextFormField(
                              autofocus: true,
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                    color: Color.fromRGBO(158, 158, 158, 1)),
                                border: OutlineInputBorder(),
                                labelText: 'Email',
                                hintText: 'Enter Your Email',
                              ),
                              onFieldSubmitted: (value) {
                                handleForgotPassword();
                              },
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 15, 25, 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Center(
                                child: TextButton(
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: const Text('Huỷ'),
                                  ),
                                  onPressed: () {
                                    widget.notifyParent();
                                  },
                                ),
                              ),
                              Center(
                                child: ElevatedButton(
                                  child: Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: const Text('Gửi'),
                                  ),
                                  onPressed: () {
                                    handleForgotPassword();
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Text(
                        'Copyright © 2022 - AAM',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xff73879C),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      /////
    );
  }
}

class LoginForm extends StatefulWidget {
  final Function() notifyParent;
  const LoginForm({Key? key, required this.notifyParent}) : super(key: key);
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  get fToast => null;

  handleLogin() async {
    var password = _passwordController.text;

    var loginRequest = {
      "userName": _usernameController.text.toString().trim(),
      "password": password,
    };
    var loginResponse =
        await httpPost("/api/nguoidung/app-login", loginRequest, context);
    if (loginResponse.containsKey("body") &&
        jsonDecode(loginResponse["body"]).containsKey("1")) {
      Provider.of<SecurityModel>(context, listen: false).setAuthorization(
          authorization: jsonDecode(loginResponse["body"])["1"],
          userName: _usernameController.text);
      Provider.of<NavigationModel>(context, listen: false).clear();
    } else {
      showToast(
          context: context,
          msg: jsonDecode(loginResponse["body"])["0"].toString(),
          color: Colors.red,
          icon: Icon(Icons.supervised_user_circle));
    }
  }

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

// hien pass
  bool isHiddenPassword = true;
  void _passwordView() {
    if (isHiddenPassword == true) {
      isHiddenPassword = false;
    } else {
      isHiddenPassword = true;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool checkSubmitButton() {
    if (_usernameController.text.isNotEmpty &&
        _usernameController.text.isNotEmpty) {
      return true;
    }
    return false;
  }

//---------
  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationModel>(
      builder: (context, navigationModel, child) => Container(
        height: MediaQuery.of(context).size.height * 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.only(top: 60),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 30),
                    child: Image.asset("assets/images/logoAAM.png"),
                  ),
                  Container(
                    child: SizedBox(
                      width: 400,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Expanded(
                              flex: 10,
                              child: Text(
                                "HỆ THỐNG QUẢN LÍ NGHIỆP VỤ XUẤT KHẨU LAO ĐỘNG",
                                style: TextStyle(
                                  fontSize: 15,
                                  letterSpacing: -0.8,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xff73879C),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ]),
                    ),
                  ),
                  Form(
                    child: AutofillGroup(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                              child: SizedBox(
                                width: 400,
                                height: 50,
                                child: TextFormField(
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [AutofillHints.email],
                                  controller: _usernameController,
                                  onChanged: (value) {},
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                        color:
                                            Color.fromRGBO(158, 158, 158, 1)),
                                    border: OutlineInputBorder(),
                                    labelText: 'Tài khoản',
                                    hintText: 'Enter Your Name',
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                              child: SizedBox(
                                width: 400,
                                height: 50,
                                child: TextFormField(
                                  autofillHints: const [AutofillHints.password],
                                  controller: _passwordController,
                                  obscureText: isHiddenPassword,
                                  onFieldSubmitted: (value) {
                                    handleLogin();
                                  },
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: OutlineInputBorder(),
                                    labelText: 'Mật khẩu',
                                    hintText: 'Enter Your Password',
                                    suffixIcon: InkWell(
                                      onTap: _passwordView,
                                      child: isHiddenPassword
                                          ? Icon(Icons.visibility_off_outlined)
                                          : Icon(Icons.visibility),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(0, 5, 0, 5),
                              child: Container(
                                width: 400,
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  child: Text(
                                    "Quên mật khẩu?",
                                    style: TextStyle(
                                        color: Color(0xff73879C), fontSize: 15),
                                  ),
                                  onTap: () {
                                    widget.notifyParent();
                                  },
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Center(
                                  child: ElevatedButton(
                                    child: Padding(
                                      padding: const EdgeInsets.all(15.0),
                                      child: const Text('Đăng nhập'),
                                    ),
                                    onPressed: () {
                                      handleLogin();
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30.0),
                        child: Text(
                          'Copyright © 2022 - AAM',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xff73879C),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
