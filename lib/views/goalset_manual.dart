import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:my_gaman_app/views/goalselect.dart';
import '../models/upload_image.dart';
import '../configs/colors.dart';

class GoalSetManualPage extends StatefulWidget {
  @override
  _GoalSetManualPageState createState() => _GoalSetManualPageState();
}

class _GoalSetManualPageState extends State<GoalSetManualPage> {

  TextEditingController goalTextController = TextEditingController();
  TextEditingController wantThingController = TextEditingController();

  var user = FirebaseAuth.instance.currentUser;
  var userId;

  var wantThingImg;

  bool _loading = true;
  bool isGoalEmpty = false;
  bool isPriceEmpty = false;
  bool isWantThingImgEmpty = false;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      userId = user.uid;
    }
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
      backgroundColor: AppColor.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey),
        title: Text(
          '目的手動設定',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: AppColor.white,
        shadowColor: AppColor.shadow,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Container(
                color: AppColor.white,
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '我慢目的',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: AppColor.shadow,
                      ),
                    ),
                    TextField(
                      controller: goalTextController,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLength: 15,
                      decoration: InputDecoration(
                        hintText: '(例)旅行に行きたい！',
                      ),
                    ),
                    Visibility(
                      visible: isGoalEmpty,
                      child: Text(
                        "我慢目的を入力してください。",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      '欲しいものの値段',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: AppColor.shadow,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Text(
                              '￥ ',
                              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: AppColor.textColor),
                            ),
                            SizedBox(height: 24.0),
                          ],
                        ),
                        Flexible(
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: wantThingController,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLength: 7,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: isPriceEmpty,
                      child: Text(
                        "欲しいものの値段を入力してください。",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      '欲しいものの画像',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: AppColor.shadow,
                      ),
                    ),
                    GestureDetector(
                      onTap: uploadImage,
                      child: (wantThingImg != null) ? Container(
                        height: 200.0,
                        width: 150.0,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: FileImage(File(wantThingImg)),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ) : Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          Container(
                            width: 200.0,
                            height: 150.0,
                            decoration: BoxDecoration(
                              color: AppColor.shadow,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          Text(
                            '+',
                            style: TextStyle(
                              color: AppColor.white,
                              fontSize: 40.0,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: isWantThingImgEmpty,
                      child: Text(
                        "欲しいものの画像を選択してください。",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(20.0),),
                    Container(
                      alignment: Alignment.bottomRight,
                      padding: EdgeInsets.all(10.0),
                      child: SizedBox(
                        child: ElevatedButton(
                          onPressed: submitPressed,
                          style: ElevatedButton.styleFrom(
                            primary: AppColor.priceColor,
                            onPrimary: AppColor.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            '登録',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(30.0)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void uploadImage() async {
    setState(() {
      _loading = true;
    });
    wantThingImg = await UploadImage.getImage(true);
    setState(() {
      _loading = false;
    });
  }

  void submitPressed() async {
    if (goalTextController.text.isNotEmpty && wantThingController.text.isNotEmpty && wantThingImg != null) {
      setState(() {
        _loading = true;
      });
      final time = DateTime.now();
      final createdAt = Timestamp.fromDate(time);
      final date = DateFormat('yyyy-MM-dd HH:mm').format(time).toString();

      final wantThingImgUrl = await UploadImage.uploadWantImg(wantThingImg, userId, date);

      await FirebaseFirestore.instance
        .collection('goals')
        .doc()
        .set({
          'userId': userId,
          'goalText': goalTextController.text,
          'wantThingUrl': null,
          'wantThingImg': wantThingImgUrl,
          'wantThingPrice': wantThingController.text,
          'createdAt' : createdAt,
          'date': date,
          'achieve': false,
        });

      goalTextController.clear();
      wantThingController.clear();

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => GoalSelectPage()),
      );

      _loading = false;
    } else {
      setState(() {
        isGoalEmpty = goalTextController.text.isEmpty;
        isPriceEmpty = wantThingController.text.isEmpty;
        if (wantThingImg == null) {
          isWantThingImgEmpty = true; 
        } else {
          isWantThingImgEmpty = false;
        }
      });
    }
  }
}
