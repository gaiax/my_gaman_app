import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_gaman_app/views/show_progress.dart';
import '../configs/colors.dart';
import 'goalselect.dart';


class Emailcheck extends StatefulWidget {
   // 呼び出し元Widgetから受け取った後、変更をしないためfinalを宣言。
  final String email;
  final String pswd;
  Emailcheck({Key key, this.email, this.pswd}) : super(key: key);

  @override
  _Emailcheck createState() => _Emailcheck();
}


class _Emailcheck extends State<Emailcheck> {
  final auth = FirebaseAuth.instance;
  String _sentEmailText;
  String _nocheckText = '';
  String infoText = '';

  @override
  Widget build(BuildContext context) {

    _sentEmailText = '${widget.email}\nに確認メールを送信しました。';

    return Scaffold(
      // メイン画面
      body:Center(
        child:Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 確認メール送信時のメッセージ
            Text(_sentEmailText),
            Padding(
              padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
              child: Text(
                infoText,
                style: TextStyle(color: Colors.red),
              ),
            ),

            // 確認メールの再送信ボタン
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 30.0),
              child: SizedBox(
                width: 200.0,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      ShowProgress.showProgressDialog(context);
                      await auth.currentUser.sendEmailVerification();
                      Navigator.of(context).pop();
                    } on FirebaseAuthException {
                      Navigator.of(context).pop();
                      setState(() {
                        infoText = '確認メールの送信上限に達しました。\nしばらく経ってからお試しください。';
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    primary: AppColor.shadow,
                    onPrimary: AppColor.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    '確認メールを再送信',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            
            // メール確認完了のボタン配置（Home画面に遷移）
            SizedBox(
              width: 350.0,
              child: ElevatedButton(
                onPressed: () async {
                  ShowProgress.showProgressDialog(context);
                  final UserCredential authResult = await auth.signInWithEmailAndPassword(
                    email: widget.email, password: widget.pswd,
                  );
                  final user = authResult.user;
                  await user.reload();
                  final _verify = user.emailVerified; 
                  // Email確認が済んでいる場合は、Home画面へ遷移
                  if (_verify){
                    await Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => GoalSelectPage()),
                      (_) => false,
                    );
                  } else {
                    setState(() {
                      _nocheckText = "まだメール確認が完了していません。\n確認メール内のリンクをクリックしてください。";
                    });
                  }
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  primary: AppColor.wavecolor,
                  onPrimary: AppColor.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'メール確認完了',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
              child: Text(
                _nocheckText,
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
