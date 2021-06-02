import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_gaman_app/views/goalselect.dart';
import '../configs/colors.dart';
import 'mailcheck.dart';

class MyLoginPage extends StatefulWidget {
  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  String infoText = "";
  var isEmailEmpty = false;
  var isPassEmpty = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey),
        title: Text(
          'Gaman App',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: AppColor.white,
        shadowColor: AppColor.shadow,
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
                    Padding(padding: EdgeInsets.all(30.0)),
                    TextFormField(
                      decoration: InputDecoration(labelText: "メールアドレス"),
                      controller: emailController,
                    ),
                    Visibility(
                      visible: isEmailEmpty,
                      child: Text(
                        "ログインメールアドレスを入力してください。",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextFormField(
                      decoration: InputDecoration(labelText: "パスワード"),
                      //　パスワードを見えないように
                      obscureText: true,
                      controller: passController,
                    ),
                    Visibility(
                      visible: isPassEmpty,
                      child: Text(
                        "パスワードを入力してください。",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(30.0)),
                    ElevatedButton(
                      onPressed: () async {
                        if (emailController.text.isNotEmpty && passController.text.isNotEmpty) {
                          try {
                            // メールとパスワードでユーザー登録
                            final FirebaseAuth auth = FirebaseAuth.instance;
                            final UserCredential authResult = await auth.signInWithEmailAndPassword(
                              email: emailController.text, password: passController.text,
                            );

                            final user = authResult.user;
                            await user.reload();
                            final _verify = user.emailVerified; 
                            // Email確認が済んでいる場合は、Home画面へ遷移
                            if (_verify){
                              // 登録後Home画面に遷移
                              await Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(builder: (context) => GoalSelectPage()),
                                (_) => false,
                              );
                            } else {
                              await user.sendEmailVerification();
                              await Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => Emailcheck(email: user.email)),
                              );
                            }
                          } on PlatformException catch (error) {
                            // 登録に失敗した場合
                            setState(() {
                              infoText = "登録NG：${error.message}";
                            });
                          } on Exception catch (e) {
                            // 登録に失敗した場合
                            setState(() {
                              infoText = "登録NG: $e";
                            });
                          }
                        } else {
                          setState(() {
                            isEmailEmpty = emailController.text.isEmpty;
                            isPassEmpty = passController.text.isEmpty;
                          });
                        }
                      },
                      child: Text("Login"),
                      style: ElevatedButton.styleFrom(
                        primary: AppColor.wavecolor,
                        onPrimary: AppColor.textColor,
                      ),
                    ),
                    Text(infoText)
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
