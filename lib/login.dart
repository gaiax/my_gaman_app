import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home.dart';

class MyLoginPage extends StatefulWidget {
  @override
  _MyLoginPageState createState() => _MyLoginPageState();
}

class _MyLoginPageState extends State<MyLoginPage> {
  String loginUserEmail = "";
  String loginUserPassword = "";
  String infoText = "";

  final Color bgColor = Color(0xFFF2FBFE);
  final Color white = Color(0xFFffffff);
  final Color curtain = Color(0x80ffffff);
  final Color shadow = Color(0xFF505659);
  final Color wavecolor = Color(0xFF97DDFA);
  final Color waveshadow = Color(0xFF83C1BB);
  final Color goalTextColor = Color(0xFF2870A0);
  final Color priceColor = Color(0xFF44AAD6);
  final Color textColor = Color(0xFF332F2E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey),
        title: Text(
          'Gaman App',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: white,
        shadowColor: shadow,
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
                    await auth.signInWithEmailAndPassword(
                      email: loginUserEmail, password: loginUserPassword,
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
                child: Text("Login"),
                style: ElevatedButton.styleFrom(
                  primary: wavecolor,
                  onPrimary: textColor,
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
