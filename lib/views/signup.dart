import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_gaman_app/views/show_progress.dart';
import 'dart:core';
import 'mailcheck.dart';
import '../configs/colors.dart';
import '../models/firebase_error.dart';

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
          'サインアップ',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: AppColor.white,
        shadowColor: AppColor.shadow,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: LayoutBuilder(
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
                        decoration: InputDecoration(
                          labelText: "メールアドレス",
                          hintText: 'chiritsumo@gmail.com'
                        ),
                        controller: emailController,
                        validator: (String value) {
                          return (value != null && !value.contains('@')) ? '正しいメールアドレスを入力してください。' : null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                        maxLength: 15,
                      ),
                      Visibility(
                        visible: isUserNameEmpty,
                        child: Text(
                          "登録するユーザーネームを入力してください。",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      TextFormField(
                        decoration: InputDecoration(labelText: "パスワード（８文字以上）"),
                        //　パスワードを見えないように
                        obscureText: true,
                        controller: passController,
                        maxLength: 30,
                        validator: (String value) {
                          return (value.length < 8) ? '８文字以上にしてください' : null;
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
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
                          if (emailController.text.isNotEmpty && passController.text.isNotEmpty && userNameController.text.isNotEmpty && passController.text == checkPassController.text && passController.text.length > 7) {
                            isEmailEmpty = false;
                            isPassEmpty = false;
                            isUserNameEmpty = false;
                            unmatchPass = false;
                            try {
                              ShowProgress.showProgressDialog(context);
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
                                MaterialPageRoute(builder: (context) => Emailcheck(email: authResult.user.email, pswd: passController.text)),
                              );
                            } on FirebaseAuthException catch (error) {
                              // 登録に失敗した場合
                              setState(() {
                                infoText = FirebaseAuthExceptionHandler.exceptionMessage(FirebaseAuthExceptionHandler.handleException(error));
                              });
                            } on Exception catch (e) {
                              // 登録に失敗した場合
                              setState(() {
                                infoText = "登録NG: $e";
                              });
                            }
                            Navigator.of(context).pop();
                          } else {
                            setState(() {
                              isEmailEmpty = emailController.text.isEmpty;
                              isUserNameEmpty = userNameController.text.isEmpty;
                              isPassEmpty = passController.text.isEmpty;
                              if (passController.text != checkPassController.text) {
                                unmatchPass = true;
                              }
                            });
                          }
                        },
                        child: Text("SignUp"),
                        style: ElevatedButton.styleFrom(
                          primary: AppColor.priceColor,
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
      ),
    );
  }

  Future<String> getDownloadUrl(userPhotoRef) async {
    return await userPhotoRef.getDownloadURL();
  }
}
