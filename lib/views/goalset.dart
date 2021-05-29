import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:my_gaman_app/views/goalselect.dart';
import 'package:universal_html/controller.dart';
import 'goalset_manual.dart';
import '../models/upload_image.dart';
import '../configs/colors.dart';

class GoalSetPage extends StatefulWidget {
  @override
  _GoalSetPageState createState() => _GoalSetPageState();
}

class _GoalSetPageState extends State<GoalSetPage> {

  TextEditingController goalTextController = TextEditingController();
  TextEditingController wantThingController = TextEditingController();

  var user = FirebaseAuth.instance.currentUser;
  var userId;

  bool _loading = true;

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
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.white,
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
              ),
              SizedBox(height: 20.0),
              Text(
                '欲しいもの',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                  color: AppColor.shadow,
                ),
              ),
              Text(
                '※ Amazon商品リンクを貼り付けてください.（セール商品は対象外です.）',
                style: TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.w500,
                  color: AppColor.shadow,
                ),
              ),
              TextField(
                controller: wantThingController,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Padding(padding: EdgeInsets.all(30.0),),
              Container(
                alignment: Alignment.bottomRight,
                padding: EdgeInsets.all(10.0),
                child: RaisedButton(
                  child: Text(
                    '登録',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onPressed: submitPressed,
                  color: AppColor.wavecolor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Padding(padding: EdgeInsets.all(30.0)),
              ButtonTheme(
                minWidth: 200.0,  
                // height: 100.0,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: () async {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => GoalSetManualPage()),
                    );
                  },
                  child: Text(
                    '手動で登録する',
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  textColor: AppColor.white,
                  color: AppColor.shadow,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submitPressed() async {
    setState(() {
      _loading = true;
    });
    final time = DateTime.now();
    final createdAt = Timestamp.fromDate(time);
    final date = DateFormat('yyyy-MM-dd HH:mm').format(time).toString();

    try {
      final controller = WindowController();
      await controller.openHttp(
        uri: Uri.parse(wantThingController.text),
      );
      final imgContainer = controller.window.document.querySelector("#imgTagWrapperId");
      final wantThingAmazonImg = imgContainer.querySelectorAll("img").first.getAttribute("src");
      final wantThingPrice = controller.window.document.querySelectorAll("span.priceBlockBuyingPriceString").first.text;
      
      final wantThingImg = await UploadImage.uploadAmazonImg(wantThingAmazonImg, userId, date);

      await FirebaseFirestore.instance
        .collection('goals')
        .doc()
        .set({
          'userId': userId,
          'goalText': goalTextController.text,
          'wantThingUrl': wantThingController.text,
          'wantThingImg': wantThingImg,
          'wantThingPrice': wantThingPrice,
          'createdAt' : createdAt,
          'date': date,
          'achieve': false,
        });
    } catch(e) {
      return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('エラー'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('欲しいモノ情報が取得できませんでした。'),
                  Text('手動で登録してください。'),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => GoalSetManualPage()),
                  );
                },
              ),
            ],
          );
        },
      );
    }

    goalTextController.clear();
    wantThingController.clear();

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => GoalSelectPage()),
    );

    _loading = false;
  }
}
