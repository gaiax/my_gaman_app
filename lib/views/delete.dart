import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:my_gaman_app/views/reset_password.dart';
import 'package:my_gaman_app/views/show_progress.dart';
import '../configs/colors.dart';
import '../main.dart';
import '../models/firebase_error.dart';

class DeleteLoginPage extends StatefulWidget {
  @override
  _DeleteLoginPageState createState() => _DeleteLoginPageState();
}

class _DeleteLoginPageState extends State<DeleteLoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  String infoText = "";
  var cloud = FirebaseFirestore.instance;
  var isEmailEmpty = false;
  var isPassEmpty = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey),
        title: Text(
          'アカウント削除',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: AppColor.white,
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
                        decoration: InputDecoration(labelText: "メールアドレス"),
                        controller: emailController,
                      ),
                      Visibility(
                        visible: isEmailEmpty,
                        child: Text(
                          "アカウントのメールアドレスを入力してください。",
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
                      SizedBox(height: 10),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: InkWell (
                          child: Text(
                            'パスワードを忘れましたか？',
                            style: TextStyle(color: AppColor.priceColor),
                          ),
                          onTap: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => ResetPassPage()),
                            );
                          },
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(30.0)),
                      ElevatedButton(
                        onPressed: () async {
                          if (emailController.text.isNotEmpty && passController.text.isNotEmpty) {
                            try {
                              ShowProgress.showProgressDialog(context);

                              final FirebaseAuth auth = FirebaseAuth.instance;
                              final currentUser = auth.currentUser;

                              if (currentUser.email == emailController.text) {
                                final UserCredential authResult = await auth.signInWithEmailAndPassword(
                                  email: emailController.text, password: passController.text,
                                );
                                final userId = authResult.user.uid;
                                final gamans = await cloud.collection('gamans').where('userId', isEqualTo: userId).get();
                                final gamandocs = gamans.docs;
                                gamandocs.forEach((gamandoc) async {
                                  await cloud.collection('gamans').doc(gamandoc.id).delete();
                                });

                                final goals = await cloud.collection('goals').where('userId', isEqualTo: userId).get();
                                final goaldocs = goals.docs;
                                goaldocs.forEach((goaldoc) async {
                                  await cloud.collection('goals').doc(goaldoc.id).delete();
                                });

                                firebase_storage.ListResult result = await firebase_storage.FirebaseStorage.instance.ref('user/'+userId).listAll();
                                result.items.forEach((firebase_storage.Reference ref) async {
                                  await ref.delete();
                                });
                                result.prefixes.forEach((firebase_storage.Reference ref) async {
                                  if (ref.name == userId) {
                                    await ref.delete();
                                  }
                                });

                                await cloud.collection('users').doc(userId).delete();
                                
                                await auth.currentUser.delete();

                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(builder: (context) => StartPage()),
                                  (_) => false
                                );
                              } else {
                                setState(() {
                                  infoText = 'ログインメールアドレスを間違っています。';
                                });
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
                            Navigator.of(context).pop();
                          } else {
                            setState(() {
                              isEmailEmpty = emailController.text.isEmpty;
                              isPassEmpty = passController.text.isEmpty;
                            });
                          }
                        },
                        child: Text("アカウント削除"),
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
      ),
    );
  }
}
