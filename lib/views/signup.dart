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
  var infoText = "";
  var userPhotoUrl = "";
  TextEditingController emailController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController checkPassController = TextEditingController();
  var isEmailEmpty = false;
  var isUserNameEmpty = false;
  var isPassEmpty = false;
  var unmatchPass = false;

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
                controller: emailController,
              ),
              Visibility(
                visible: isEmailEmpty,
                child: Text(
                  "登録するメールアドレスを入力してください。",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "ユーザーネーム"),
                controller: userNameController,
              ),
              Visibility(
                visible: isUserNameEmpty,
                child: Text(
                  "登録するユーザーネームを入力してください。",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "パスワード（８文字以上推奨）"),
                //　パスワードを見えないように
                obscureText: true,
                controller: passController,
              ),
              Visibility(
                visible: isPassEmpty,
                child: Text(
                  "パスワードを設定してください。",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "パスワード（確認）"),
                //　パスワードを見えないように
                obscureText: true,
                controller: checkPassController,
              ),
              Visibility(
                visible: unmatchPass,
                child: Text(
                 "パスワードが違います。",
                  style: TextStyle(color: Colors.red),
                ),
              ),
              Padding(padding: EdgeInsets.all(30.0)),
              ElevatedButton(
                onPressed: () async {
                  if (emailController.text.isNotEmpty && passController.text.isNotEmpty && userNameController.text.isNotEmpty && passController.text == checkPassController.text) {
                    try {
                      // メールとパスワードでユーザー登録
                      final FirebaseAuth auth = FirebaseAuth.instance;
                      final UserCredential authResult = await auth.createUserWithEmailAndPassword(
                        email: emailController.text, password: passController.text,
                      );

                      await auth.currentUser.sendEmailVerification();

                      final User user = authResult.user;

                      final time = DateTime.now();
                      final createdAt = Timestamp.fromDate(time);

                      final FirebaseStorage storage = FirebaseStorage.instance;
                      var photo = storage.ref().child('userPhoto.png').fullPath;
                      var photoRef = storage.ref(photo);
                      userPhotoUrl = await getDownloadUrl(photoRef);
                      
                      await user.updateProfile(displayName: userNameController.text, photoURL: userPhotoUrl);
                      await user.reload();

                      await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .set({
                          'userId': user.uid,
                          'userName': userNameController.text,
                          'userPhotoUrl': userPhotoUrl,
                          'createdAt' : createdAt,
                        });
                      
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => Emailcheck(email: userNameController.text)),
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
                    isEmailEmpty = emailController.text.isEmpty;
                    isUserNameEmpty = userNameController.text.isEmpty;
                    isPassEmpty = passController.text.isEmpty;
                    if (passController.text != checkPassController.text) {
                      unmatchPass = true;
                    }
                    setState(() {});
                  }
                },
                child: Text("SignUp"),
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
  Future<String> getDownloadUrl(userPhotoRef) async {
    return await userPhotoRef.getDownloadURL();
  }
}
