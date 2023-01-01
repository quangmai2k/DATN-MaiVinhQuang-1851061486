import 'package:flutter/material.dart';
import 'package:gentelella_flutter/model/model.dart';
import 'package:provider/provider.dart';
import '../../api.dart';
import '../../common/toast.dart';

class ResetPasswordPage extends StatelessWidget {
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
                                  image: AssetImage("assets/images/bg-top-right.png"),
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
                                        style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 30.0),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        padding: EdgeInsets.only(top: 30),
                                        child: Text(
                                          'CÔNG TY CỔ PHẦN PHÁT TRIỂN',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 50.0),
                                        ),
                                      ),
                                    ),
                                    Flexible(
                                      child: Container(
                                        child: Text(
                                          'CUNG ỨNG NHÂN LỰC QUỐC TẾ AAM',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 50.0),
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
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.only(bottom: 30),
                            child: Image.asset("assets/images/logoAAM.png"),
                          ),
                          Container(
                            child: SizedBox(
                              width: 400,
                              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                                Expanded(
                                  flex: 10,
                                  child: Text(
                                    "Đặt lại mật khẩu của bạn",
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
                            child: ResetPasswordForm(),
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
      ),
    );
  }
}

class ResetPasswordForm extends StatefulWidget {
  const ResetPasswordForm({Key? key}) : super(key: key);
  @override
  _ResetPasswordFormState createState() => _ResetPasswordFormState();
}

class _ResetPasswordFormState extends State<ResetPasswordForm> {
  get fToast => null;

  @override
  void initState() {
    super.initState();
    getToken();
  }

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  var token;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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

  void getToken() {
    String fullUrl = Uri.base.toString();
    var x = fullUrl.split("/");
    var url = Uri.parse("/" + x[x.length - 1]);
    token = url.queryParameters['token'];
  }

  void reset() async {
    String resetPassword = "";
    // if (Provider.of<SecurityModel>(context, listen: false).authenticated ==
    //     true) {
    //   Provider.of<SecurityModel>(context, listen: false).logout();
    // }
    if (token == null) {
      showToast(context: context, msg: "Lỗi không xác định !", color: Colors.orangeAccent, icon: Icon(Icons.warning));
      print("Chua co token");
    } else {
      String pw = _passwordController.text;
      String confirmPw = _confirmPasswordController.text;
      if (pw == "" || confirmPw == "")
        showToast(context: context, msg: "Không được để trống !", color: Colors.orangeAccent, icon: Icon(Icons.warning));
      else if (pw != confirmPw)
        showToast(context: context, msg: "Mật khẩu phải trùng nhau !", color: Colors.orangeAccent, icon: Icon(Icons.warning));
      else {
        resetPassword = pw;
        var rq = {
          "token": token,
          "resetPassword": resetPassword,
        };
        var response = await httpPost("/api/nguoidung/reset_password", rq, context);
        if (response["body"] == "Cập nhật mật khẩu thành công!") {
          showToast(context: context, msg: response["body"], color: Colors.greenAccent, icon: Icon(Icons.done_all));
          onLoading(context);
          await Future.delayed(Duration(milliseconds: 500));
          Navigator.of(context).pop(true);
          Provider.of<NavigationModel>(context, listen: false).clear();
        } else
          showToast(context: context, msg: response['body'], color: Colors.orangeAccent, icon: Icon(Icons.warning));
        print(response["body"]);
        print("Da reset");
      }
    }
  }

//---------
  @override
  Widget build(BuildContext context) {
    return Consumer<NavigationModel>(
      builder: (context, navigationModel, child) => Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                  child: SizedBox(
                    width: 400,
                    height: 50,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: isHiddenPassword,
                      onFieldSubmitted: (value) {
                        reset();
                      },
                      decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(),
                        labelText: 'Mật khẩu mới',
                        // hintText: 'Nhập mật khẩu mới',
                        suffixIcon: InkWell(
                          onTap: _passwordView,
                          child: isHiddenPassword ? Icon(Icons.visibility_off_outlined) : Icon(Icons.visibility),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
              child: SizedBox(
                width: 400,
                height: 50,
                child: TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: isHiddenPassword,
                  onFieldSubmitted: (value) {
                    reset();
                  },
                  decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    labelText: 'Nhập lại mật khẩu mới',
                    // hintText: 'Xác nhận mật khẩu mới',
                    suffixIcon: InkWell(
                      onTap: _passwordView,
                      child: isHiddenPassword ? Icon(Icons.visibility_off_outlined) : Icon(Icons.visibility),
                    ),
                  ),
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
                      child: const Text('Đặt lại'),
                    ),
                    onPressed: () {
                      reset();
                    },
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
    );
  }
}
