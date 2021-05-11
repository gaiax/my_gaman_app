import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'home.dart';
import 'package:universal_html/controller.dart';
import '../configs/colors.dart';

class GoalSetPage extends StatefulWidget {
  @override
  _GoalSetPageState createState() => _GoalSetPageState();
}

class _GoalSetPageState extends State<GoalSetPage> {

  TextEditingController goalTextController = TextEditingController();
  TextEditingController wantThingController = TextEditingController();

  var user = FirebaseAuth.instance.currentUser;
  var userEmail;
  var userName;
  var userPhoto;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      userEmail = user.email;
      userName = user.displayName;
      userPhoto = user.photoURL;
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
    final createdAt = DateFormat.yMMMMEEEEd().add_jms().format(DateTime.now());

    final controller = WindowController();
    await controller.openHttp(
      uri: Uri.parse(wantThingController.text),
    );

    final imgContainer = controller.window.document.querySelector("#imgTagWrapperId");
    final wantThingImg = imgContainer.querySelectorAll("img").first.getAttribute("src");
    final wantThingPrice = controller.window.document.querySelectorAll("span.priceBlockBuyingPriceString").first.text;

    await FirebaseFirestore.instance
      .collection('goals')
      .doc()
      .set({
        'userEmail': userEmail,
        'userName': userName,
        'userPhotoUrl': userPhoto,
        'goalText': goalTextController.text,
        'wantThingImg': wantThingImg,
        'wantThingPrice': wantThingPrice,
        'createdAt' : createdAt,
      });

    goalTextController.clear();
    wantThingController.clear();

    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }
}
