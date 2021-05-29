import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'mailcheck.dart';
import '../configs/colors.dart';

class MyAuthPage extends StatefulWidget {
  @override
  _MyAuthPageState createState() => _MyAuthPageState();
}

class _MyAuthPageState extends State<MyAuthPage> {
  var newUserEmail = "";
  var newUserPassword = "";
  var infoText = "";
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
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: "ユーザーネーム"),
                onChanged: (String value) {
                  setState(() {
                    userName = value;
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
              ElevatedButton(
                onPressed: () async {
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
                    
                      // 登録後Home画面に遷移
                      await Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => Emailcheck(email: newUserEmail, pswd: newUserPassword)
                      ),
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
  Future<String> getDownloadUrl(userPhotoRef) async {
    return await userPhotoRef.getDownloadURL();
  }
}
