import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:my_gaman_app/main.dart';
import 'package:my_gaman_app/views/reset_password.dart';
import 'login.dart';
import '../configs/colors.dart';
import '../models/upload_image.dart';
import '../views/show_progress.dart';

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
  var imagePath;
  File newImage;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      setData();
    }
  }

  void setData() async {
    userId = user.uid;
    DocumentSnapshot userData = await cloud.collection('users').doc(userId).get();
    userName = await userData['userName'];
    userPhoto = await userData['userPhotoUrl'];
    userNameController = TextEditingController(text: userName);

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
      ),

      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child:  ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Container(
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
                                image: (newImage == null) ? NetworkImage(userPhoto) : FileImage(newImage),
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
                    TextFormField(
                      controller: userNameController,
                      style: TextStyle(
                        color: AppColor.textColor,
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLength: 15,
                      validator: (String value) {
                        return (value == '') ? 'ユーザー名を入力してください。' : null;
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                    ),
                    Padding(padding: EdgeInsets.all(15.0)),
                    Container(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: (userNameController.text.isNotEmpty) ? saveUsers : null,
                        child: Text("保存"),
                        style: ElevatedButton.styleFrom(
                          primary: AppColor.priceColor,
                          onPrimary: AppColor.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 40.0),
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
                                      Text('パスワード再設定メールを送信します。'),
                                      Text('再設定後、再ログインが必要です。'),
                                      Text('よろしいですか？'),
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) => ResetPassPage()),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          primary: AppColor.shadow,
                          onPrimary: AppColor.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("パスワード再設定"),
                      ),
                    ),
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
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('OK'),
                                    onPressed: () {
                                      deleteUser();
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          primary: AppColor.shadow,
                          onPrimary: AppColor.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text("アカウント削除"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void deleteUser() async {
    try {
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
                    Navigator.of(context).pop();
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
    ShowProgress.showProgressDialog(context);
    imagePath = await UploadImage.getImage(true);
    if (imagePath != null) {
      newImage = File(imagePath);
    }
    Navigator.of(context).pop();
    setState(() {});
  }

  void saveUsers() async {
    if (userNameController.text.isNotEmpty && userNameController.text.length < 16) {
      setState(() {
        _loading = true;
      });
      if (imagePath != null) {
        userPhoto = await UploadImage.uploadFile(imagePath, userId);
        await user.updatePhotoURL(userPhoto);
      }
      await user.updateDisplayName(userNameController.text);
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
}
