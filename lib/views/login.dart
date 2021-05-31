import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_gaman_app/views/goalselect.dart';
import '../configs/colors.dart';
import 'mailcheck.dart';

class MyLoginPage extends StatefulWidget {
  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  String loginUserEmail = "";
  String loginUserPassword = "";
  String infoText = "";

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
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32.0),
          child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.all(30.0)),
              TextFormField(
                decoration: InputDecoration(labelText: "メールアドレス"),
                onChanged: (String value) {
                  setState(() {
                    loginUserEmail = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "パスワード（８文字以上）"),
                //　パスワードを見えないように
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    loginUserPassword = value;
                  });
                },
              ),
              Padding(padding: EdgeInsets.all(30.0)),
              ElevatedButton(
                onPressed: () async {
                  try {
                    // メールとパスワードでユーザー登録
                    final FirebaseAuth auth = FirebaseAuth.instance;
                    final UserCredential authResult = await auth.signInWithEmailAndPassword(
                      email: loginUserEmail, password: loginUserPassword,
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
                  } catch (e) {
                    // 登録に失敗した場合
                    setState(() {
                      infoText = "認証NG：{e.message}";
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
    );
  }
}
