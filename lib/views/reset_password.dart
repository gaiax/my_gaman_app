import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_gaman_app/models/firebase_error.dart';
import '../configs/colors.dart';
import '../main.dart';
import 'login.dart';

class ResetPassPage extends StatefulWidget {
  @override
  _ResetPassPageState createState() => _ResetPassPageState();
}

class _ResetPassPageState extends State<ResetPassPage> {
  TextEditingController emailController = TextEditingController();
  String infoText = "";
  var isEmailEmpty = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey),
        title: Text(
          'ちりつも',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: AppColor.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(32.0),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(labelText: "メールアドレス"),
                      controller: emailController,
                    ),
                    Visibility(
                      visible: isEmailEmpty,
                      child: Text(
                        "登録したメールアドレスを入力してください。",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(30.0)),
                    ElevatedButton(
                      onPressed: () async {
                        if (emailController.text.isNotEmpty) {
                          isEmailEmpty = false;
                          try {
                            final FirebaseAuth auth = FirebaseAuth.instance;
                            await auth.sendPasswordResetEmail(email: emailController.text);
                            if (auth.currentUser != null) {
                              await auth.signOut();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => MyLoginPage()),
                                (_) => false,
                              );
                            } else {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => StartPage()),
                                (_) => false,
                              );
                            }
                          } on FirebaseAuthException catch (error) {
                            // 登録に失敗した場合
                            setState(() {
                              infoText = FirebaseAuthExceptionHandler.exceptionMessage(FirebaseAuthExceptionHandler.handleException(error));
                            });
                          } on Exception catch (e) {
                            // 登録に失敗した場合
                            setState(() {
                              infoText = "認証NG: $e";
                            });
                          }
                        } else {
                          setState(() {
                            isEmailEmpty = emailController.text.isEmpty;
                          });
                        }
                      },
                      child: Text("パスワード再設定メールを送信"),
                      style: ElevatedButton.styleFrom(
                        primary: AppColor.shadow,
                        onPrimary: AppColor.white,
                      ),
                    ),
                    Text(
                      infoText,
                      style: TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
