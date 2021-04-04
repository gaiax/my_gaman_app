import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home.dart';

class MyAuthPage extends StatefulWidget {
  @override
  _MyAuthPageState createState() => _MyAuthPageState();
}

class _MyAuthPageState extends State<MyAuthPage> {
  String newUserEmail = "";
  String newUserPassword = "";
  String infoText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    newUserEmail = value;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "パスワード（８文字以上）"),
                //　パスワードを見えないように
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    newUserPassword = value;
                  });
                },
              ),
              Padding(padding: EdgeInsets.all(30.0)),
              RaisedButton(
                onPressed: () async {
                  try {
                    // メールとパスワードでユーザー登録
                    final FirebaseAuth auth = FirebaseAuth.instance;
                    await auth.createUserWithEmailAndPassword(
                      email: newUserEmail, password: newUserPassword,
                    );

                    // 登録後Home画面に遷移
                    await Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  } catch (e) {
                    // 登録に失敗した場合
                    setState(() {
                      infoText = "登録NG：{e.message}";
                    });
                  }
                },
                child: Text("SignUp"),
              ),
              Text(infoText)
            ],
          ),
        ),
      ),
    );
  }
}
