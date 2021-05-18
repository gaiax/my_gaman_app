import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../configs/colors.dart';
import '../models/upload_image.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {

  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance; 
  TextEditingController userNameController;

  var user = FirebaseAuth.instance.currentUser;
  var userEmail;
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
    userEmail = user.email;
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
          'プロフィール設定',
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
            )
          ],
        ),
      ),
    );
  }

  void uploadImage() async {
    var image = await UploadImage.getImage(true);
    _loading = true;
    await UploadImage.uploadFile(image, userEmail);
    userPhoto = await storage.ref('userImages/'+userEmail+'.png').getDownloadURL();
    setState(() {
      _loading = false;
    });
  }

  void saveUsers() async {
    await user.updateProfile(displayName: userNameController.text, photoURL: userPhoto);
    await user.reload();
    Navigator.of(context).pop();
  }
}
