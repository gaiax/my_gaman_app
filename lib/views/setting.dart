import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_gaman_app/main.dart';
import 'login.dart';
import '../configs/colors.dart';
import '../models/upload_image.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  TextEditingController userNameController;

  var cloud = FirebaseFirestore.instance;
  var user = FirebaseAuth.instance.currentUser;
  var userId;
  var userName;
  var userPhoto;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      setData();
    }
    userNameController = TextEditingController(text: userName);
  }

  void setData() async {
    userId = user.uid;
    userName = user.displayName;
    userPhoto = user.photoURL;

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    if (_loading) {
      return Center(
        child: CircularProgressIndicator()
      );
    }

    return Scaffold(
      backgroundColor: AppColor.bgColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey),
        title: Text(
          'アカウント設定',
          style: TextStyle(
            color:AppColor.textColor,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: AppColor.white,
        shadowColor: AppColor.shadow,
      ),

      body: Container(
        color: AppColor.bgColor,
        margin: EdgeInsets.only(top: 30),
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            GestureDetector(
              onTap: uploadImage,
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  Container(
                    height: 55.0,
                    width: 55.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: NetworkImage(userPhoto),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    width: 55.0,
                    height: 55.0,
                    decoration: BoxDecoration(
                      color: AppColor.curtain,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  Text(
                    '+',
                    style: TextStyle(
                      color: AppColor.textColor,
                      fontSize: 40.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Padding(padding: EdgeInsets.all(10.0)),
            Text(
              'ユーザー名',
              style: TextStyle(
                color: AppColor.shadow,
                fontSize: 14.0,
                fontWeight: FontWeight.w200,
              ),
            ),
            TextField(
              controller: userNameController,
              style: TextStyle(
                color: AppColor.textColor,
                fontSize: 18.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            Padding(padding: EdgeInsets.all(15.0)),
            Container(
              alignment: Alignment.bottomRight,
              child: ElevatedButton(
                onPressed: saveUsers,
                child: Text("保存"),
                style: ElevatedButton.styleFrom(
                  primary: AppColor.wavecolor,
                  onPrimary: AppColor.textColor,
                ),
              ),
            ),
            SizedBox(height: 30.0),
            SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('確認'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text('本当に削除しますか？'),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: const Text('OK'),
                            onPressed: deleteUser,
                          ),
                        ],
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: AppColor.wavecolor,
                  onPrimary: AppColor.textColor,
                ),
                child: Text("アカウント削除"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void deleteUser() async {
    try {
      await FirebaseAuth.instance.currentUser.delete();
      await Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => StartPage()),
        (_) => false
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('注意'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('再度ログインする必要があります。'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => MyLoginPage()),
                    );
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  void uploadImage() async {
    var image = await UploadImage.getImage(true);
    _loading = true;
    userPhoto = await UploadImage.uploadFile(image, userId);
    setState(() {
      _loading = false;
    });
  }

  void saveUsers() async {
    await user.updateProfile(displayName: userNameController.text, photoURL: userPhoto);
    await user.reload();

    await cloud
      .collection('users')
      .doc(userId)
      .update({
        'userName': userNameController.text,
        'userPhotoUrl': userPhoto,
      });
    Navigator.of(context).pop();
  }
}
