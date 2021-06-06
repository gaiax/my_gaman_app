import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_gaman_app/views/show_progress.dart';
import '../configs/colors.dart';
import 'goalselect.dart';


class Emailcheck extends StatefulWidget {
   // 呼び出し元Widgetから受け取った後、変更をしないためfinalを宣言。
  final String email;
  Emailcheck({Key key, this.email}) : super(key: key);

  @override
  _Emailcheck createState() => _Emailcheck();
}


class _Emailcheck extends State<Emailcheck> {
  final auth = FirebaseAuth.instance;
  String _sentEmailText;
  String _nocheckText = '';

  @override
  Widget build(BuildContext context) {

    _sentEmailText = '${widget.email}\nに確認メールを送信しました。';

    return Scaffold(
      // メイン画面
      body:Center(
        child:Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
              child: Text(
                _nocheckText,
                style: TextStyle(color: Colors.red),
              ),
            ),

            // 確認メール送信時のメッセージ
            Text(_sentEmailText),

            // 確認メールの再送信ボタン
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 0, 30.0),
              child:ButtonTheme(
                minWidth: 200.0,  
                // height: 100.0,
                child: RaisedButton(
                  // ボタンの形状
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () async {
                    ShowProgress.showProgressDialog(context);
                    await auth.currentUser.sendEmailVerification();
                    Navigator.of(context).pop();
                  },
                  // ボタン内の文字や書式
                  child: Text(
                    '確認メールを再送信',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  textColor: AppColor.white,
                  color: AppColor.shadow,
                ),
              ),
            ),

            // メール確認完了のボタン配置（Home画面に遷移）
            ButtonTheme(
              minWidth: 350.0,  
              // height: 100.0,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),

                onPressed: () async {
                  ShowProgress.showProgressDialog(context);
                  final user = auth.currentUser;
                  await user.reload();
                  final _verify = user.emailVerified; 
                  // Email確認が済んでいる場合は、Home画面へ遷移
                  if (_verify){
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => GoalSelectPage()),
                    );
                  } else {
                    setState(() {
                      _nocheckText = "まだメール確認が完了していません。\n確認メール内のリンクをクリックしてください。";
                    });
                  }
                  Navigator.of(context).pop();
                },
                // ボタン内の文字や書式
                child: Text(
                  'メール確認完了',
                  style: TextStyle(
                    fontWeight: FontWeight.bold
                  ),
                ),
                textColor: AppColor.white,
                color: AppColor.wavecolor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
