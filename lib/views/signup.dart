import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:core';
import 'mailcheck.dart';
import '../configs/colors.dart';

class MyAuthPage extends StatefulWidget {
  @override
  _MyAuthPageState createState() => _MyAuthPageState();
}

class _MyAuthPageState extends State<MyAuthPage> {
  var newUserEmail = "";
  var newUserPassword = "";
  var checkPassword = "";
  var infoText = "";
  var infoText1 = "";
  var infoText2 = "";
  var infoText3 = "";
  var infoText4 = "";
  var userName = "";
  var userPhotoUrl = "";

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
                    newUserEmail = value;
                    infoText1 = "";
                  });
                },
              ),
              Text(
                infoText1,
                style: TextStyle(color: Colors.red),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "ユーザーネーム"),
                onChanged: (String value) {
                  setState(() {
                    userName = value;
                    infoText2 = "";
                  });
                },
              ),
              Text(
                infoText2,
                style: TextStyle(color: Colors.red),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "パスワード（８文字以上）"),
                //　パスワードを見えないように
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    newUserPassword = value;
                    infoText3 = "";
                  });
                },
              ),
              Text(
                infoText3,
                style: TextStyle(color: Colors.red),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "パスワード（確認）"),
                //　パスワードを見えないように
                obscureText: true,
                onChanged: (String value) {
                  setState(() {
                    checkPassword = value;
                    if (newUserPassword == checkPassword) {
                      infoText4 = "";
                    } else {
                      infoText4 = "パスワードが違います。";
                    }
                  });
                },
              ),
              Text(
                infoText4,
                style: TextStyle(color: Colors.red),
              ),
              Padding(padding: EdgeInsets.all(30.0)),
              ElevatedButton(
                onPressed: () async {
                  if (newUserEmail != "" && newUserPassword != "" && userName != "" && newUserPassword == checkPassword) {
                    try {
                      // メールとパスワードでユーザー登録
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final UserCredential authResult = await auth.createUserWithEmailAndPassword(
                        email: newUserEmail, password: newUserPassword,
                      );

                      await auth.currentUser.sendEmailVerification();

                      final User user = authResult.user;

                      final time = DateTime.now();
                      final createdAt = Timestamp.fromDate(time);

                      final FirebaseStorage storage = FirebaseStorage.instance;
                      var photo = storage.ref().child('userPhoto.png').fullPath;
                      var photoRef = storage.ref(photo);
                      userPhotoUrl = await getDownloadUrl(photoRef);
                      
                      await user.updateProfile(displayName: userName, photoURL: userPhotoUrl);
                      await user.reload();

                      await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .set({
                          'userId': user.uid,
                          'userName': userName,
                          'userPhotoUrl': userPhotoUrl,
                          'createdAt' : createdAt,
                        });
                      
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => Emailcheck(email: newUserEmail)),
                      );
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
                      if (newUserEmail == "") {
                        infoText1 = "登録するメールアドレスを入力してください。";
                      } 

                      if (userName == "") {
                        infoText2 = "登録するユーザーネームを入力してください。";
                      } 

                      if (newUserPassword == "") {
                        infoText3 = "パスワードを設定してください";
                      } 
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
  Future<String> getDownloadUrl(userPhotoRef) async {
    return await userPhotoRef.getDownloadURL();
  }
}
