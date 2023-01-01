import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gentelella_flutter/api.dart';
import 'package:gentelella_flutter/common/toast.dart';
import 'package:gentelella_flutter/config.dart';
import 'package:provider/provider.dart';
import '../../model/model.dart';
import 'navigation.dart';

class ChangePasswordBody extends StatefulWidget {
  const ChangePasswordBody({Key? key}) : super(key: key);
  @override
  State<ChangePasswordBody> createState() => _ChangePasswordBodyState();
}

class _ChangePasswordBodyState extends State<ChangePasswordBody> {
  final oldpassword = TextEditingController();
  final newpassword = TextEditingController();
  final newpassword1 = TextEditingController();
  double height1 = 50;
  double height2 = 50;
  double height3 = 50;
  String status = "";
  bool check = false;

  bool checkCurrentPasswordValid = true;
  dynamic userLoginCurren;

  // hien pass
  var isHiddenPassword = true;
  var _formKey = GlobalKey<FormState>();

  void _passwordView() {
    if (isHiddenPassword == true) {
      isHiddenPassword = false;
    } else {
      isHiddenPassword = true;
    }
    setState(() {});
  }

  // hien pass
  var isHiddenPassword1 = true;
  void _passwordView1() {
    if (isHiddenPassword1 == true) {
      isHiddenPassword1 = false;
    } else {
      isHiddenPassword1 = true;
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  Widget getAvartar(user) {
    try {
      if (user.userLoginCurren != null) {
        if (user.userLoginCurren['avatar'].isNotEmpty) {
          return CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                "$baseUrl/api/files/${user.userLoginCurren['avatar']}",
              ));
        }
      }
    } catch (e) {
      print(e);
    }

    return Container();
  }

  @override
  void dispose() {
    oldpassword.dispose();
    newpassword.dispose();
    newpassword1.dispose();
    super.dispose();
  }

//---------
  @override
  Widget build(BuildContext context) {
    return HeaderAndNavigation(
      widgetBody: Consumer2<NavigationModel, SecurityModel>(
        builder: (context, navigationModel, user, child) => Container(
          // margin: EdgeInsets.only(bottom: 25),
          color: Color.fromARGB(255, 255, 255, 255),
          padding: EdgeInsets.only(top: 10),
          child: ListView(
            controller: ScrollController(),
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Color(0xffFDCF09),
                          child: Row(
                            children: [getAvartar(user)],
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          user.userLoginCurren != null ? user.userLoginCurren['fullName'].toString() : "",
                          overflow: TextOverflow.fade,
                          style: TextStyle(color: Colors.black87),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                    Container(
                      child: SizedBox(
                        width: 400,
                        child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                          Expanded(
                            child: Divider(
                              color: Color(0xff73879C),
                              height: 30,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(45, 0, 45, 0),
                            child: Text(
                              "Đổi Mật Khẩu",
                              style: TextStyle(
                                fontSize: 30,
                                letterSpacing: -0.8,
                                fontWeight: FontWeight.w500,
                                color: Color(0xff73879C),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              color: Color(0xff73879C),
                              height: 30,
                            ),
                          ),
                        ]),
                      ),
                    ),
                    (check)
                        ? CircularProgressIndicator()
                        : (status != "")
                            ? Padding(
                                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                                child: Center(
                                    child: Text(
                                  "$status",
                                  style: TextStyle(color: (status == "Đổi mật khẩu thành công.") ? Colors.green : Colors.red),
                                )))
                            : Text(""),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0, 20, 0, 15),
                      child: Container(
                        width: 400,
                        height: height1,
                        child: TextFormField(
                          controller: oldpassword,
                          decoration: InputDecoration(
                            hintStyle: TextStyle(color: Color.fromRGBO(158, 158, 158, 1)),
                            border: OutlineInputBorder(),
                            labelText: 'Mật khẩu hiện tại',
                            hintText: 'Nhập mật khẩu',
                          ),
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              setState(() {
                                height1 = 70;
                              });
                              return "Vui lòng nhập mật khẩu";
                            } else {
                              setState(() {
                                height1 = 50;
                              });
                              return null;
                            }
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 15),
                      child: SizedBox(
                        width: 400,
                        height: height2,
                        child: TextFormField(
                          controller: newpassword,
                          // obscureText: isHiddenPassword,
                          decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(),
                            labelText: 'Mật khẩu mới',
                            hintText: 'Nhập mật khẩu mới',
                            suffixIcon: InkWell(
                              onTap: _passwordView,
                              child: isHiddenPassword ? Icon(Icons.visibility_off_outlined) : Icon(Icons.visibility),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              setState(() {
                                height2 = 70;
                              });
                              return "Vui lòng nhập mật khẩu mới";
                            } else {
                              setState(() {
                                height2 = 50;
                              });
                              return null;
                            }
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 20, 0, 40),
                      child: SizedBox(
                        width: 400,
                        height: height3,
                        child: TextFormField(
                          controller: newpassword1,
                          // obscureText: isHiddenPassword1,
                          decoration: InputDecoration(
                            hintStyle: TextStyle(color: Colors.grey),
                            border: OutlineInputBorder(),
                            labelText: 'Xác nhận mật khẩu mới',
                            hintText: 'Nhập lại mật khẩu mới',
                            suffixIcon: InkWell(
                              onTap: _passwordView1,
                              child: isHiddenPassword1 ? Icon(Icons.visibility_off_outlined) : Icon(Icons.visibility),
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              setState(() {
                                height3 = 70;
                              });
                              return "Vui lòng nhập lại mật khẩu mới";
                            } else if (newpassword.text == value) {
                              setState(() {
                                height3 = 50;
                              });
                              return null;
                            } else {
                              setState(() {
                                height3 = 70;
                              });
                              return "Mật khẩu không khớp";
                            }
                          },
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 50,
                          child: OutlinedButton(
                              style: ElevatedButton.styleFrom(
                                onPrimary: Color.fromARGB(255, 50, 157, 244), // Background color
                              ),
                              onPressed: () {
                                showToast(
                                  context: context,
                                  msg: "Đã hủy thay đổi mật khẩu",
                                  color: Color.fromARGB(135, 247, 217, 179),
                                  icon: const Icon(Icons.done),
                                );
                                Navigator.pop(context);
                              },
                              child: Text('Hủy')),
                        ),
                        SizedBox(
                          width: 160,
                        ),
                        Container(
                          width: 120,
                          height: 50,
                          padding: EdgeInsets.only(left: 20),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Color.fromARGB(255, 50, 157, 244),
                              onPrimary: Colors.white, // Background color
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate() && checkCurrentPasswordValid) {}
                              check = true;
                              if ((newpassword.text == newpassword1.text)) {
                                var requestbody = {"oldPassword": oldpassword.text, "newPassword": newpassword.text};
                                var password = await httpPost("/api/nguoidung/change_password", requestbody, context);
                                if (password.containsKey("body")) {
                                  var result = jsonDecode(password["body"]);
                                  print(result.keys.first);

                                  if (result.keys.first == '0') {
                                    setState(() {
                                      status = result['0'];
                                      check = false;
                                    });
                                  } else {
                                    setState(() {
                                      status = result['1'];
                                      check = false;
                                      newpassword.text = "";
                                      oldpassword.text = "";
                                      newpassword1.text = "";
                                      // Navigator.pop(context);
                                    });
                                  }
                                }
                              }
                            },
                            child: Text('Lưu'),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
