import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'home.dart';

class GoalSetPage extends StatefulWidget {
  @override
  _GoalSetPageState createState() => _GoalSetPageState();
}

class _GoalSetPageState extends State<GoalSetPage> {

  final Color bgColor = Color(0xFFDA3D20);
  final Color white = Color(0xFFffffff);
  final Color shadow = Color(0xFF505659);
  final Color wavecolor = Color(0xFF45B5AA);
  final Color waveshadow = Color(0xFF83C1BB);

  var wantThingIMG = 'image/display.jpg';

  var saving = 0;
  var wantThingPrice = 15000;
  var gamanPrice;
  var goalText;
  var wantThing;
  var date;
  var createdAt;

  TextEditingController goalTextController = TextEditingController();
  TextEditingController wantThingController = TextEditingController();

  var user = FirebaseAuth.instance.currentUser;
  var userEmail;
  var userName;
  var userPhoto;

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      userEmail = user.email;
      userName = user.displayName;
      userPhoto = user.photoURL;
    }

    return Scaffold(
      backgroundColor: white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey),
        title: Text(
          'Gaman App',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: white,
        shadowColor: shadow,
      ),

      drawer:Drawer(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Card(
              child: ListTile(
                leading: FlutterLogo(size: 65.0),
                title: Text(userName),
                subtitle: Text(userEmail),
              )
            ),
            Padding(padding: EdgeInsets.all(5.0)),
            ListTile(
              leading: const Icon(Icons.ac_unit_sharp),
              title: Text('testtest'),
            ),
          ],
        ),
      ),

      body: Center(
        child: Container(
          color: white,
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '我慢目的',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w500,
                  color: shadow,
                ),
              ),
              TextField(
                controller: goalTextController,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 40.0),
              Text(
                '欲しいもの',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.w500,
                  color: shadow,
                ),
              ),
              TextField(
                controller: wantThingController,
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Padding(padding: EdgeInsets.all(60.0),),
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
                  color: wavecolor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
      goalText = goalTextController.text;
      wantThing = wantThingController.text;
      date = DateTime.now(); // 現在の日時
      createdAt = DateFormat.yMMMMEEEEd().add_jms().format(date);
      goalTextController =TextEditingController();
      wantThingController = TextEditingController();
    });

    await FirebaseFirestore.instance
      .collection('goals')
      .doc()
      .set({
        'userEmail': userEmail,
        'userName': userName,
        'userPhotoUrl': userPhoto,
        'goalText': goalText,
        'wantThing': wantThing,
        'createdAt' : createdAt,
      });

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }
}
