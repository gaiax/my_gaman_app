import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wave_progress_widget/wave_progress.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final Color bgColor = Color(0xFFDA3D20);
  final Color white = Color(0xFFffffff);
  final Color shadow = Color(0xFF505659);
  final Color wavecolor = Color(0xFF45B5AA);
  final Color waveshadow = Color(0xFF83C1BB);

  var goal = '2ヶ月以内に５ｋｇ痩せる';
  var wantThingIMG = 'image/display.jpg';
  var wantThing = 'LG 27UL550-W 27型 4K 液晶ディスプレイ';

  var _currentValue = 0.0;
  var saving = 0;
  var wantThingPrice = 15000;
  var gamanPrice;

  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance; 

  var user = FirebaseAuth.instance.currentUser;
  var userEmail;
  var userName;
  var userPhoto;
  var userPhotoRef;
  var userPhotoUrl;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      setData();
    }
  }

  void setData() async {
    userEmail = user.email;
    userName = user.displayName;
    userPhoto = user.photoURL;
    userPhotoRef = storage.ref(userPhoto);
    await getDownloadUrl();
    print(userPhotoUrl);

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    _currentValue = (saving.toInt() / wantThingPrice.toInt()) * 100;

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
                leading: Container(
                  height: 65.0,
                  width: 65.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image:NetworkImage(userPhotoUrl),
                    ),
                  ),
                ),
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
          padding: EdgeInsets.only(top: 5.0),
          margin: EdgeInsets.only(bottom: 18.0, left: 15.0, right: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(padding: EdgeInsets.all(6.0)),
              RaisedButton(
                onPressed: () {},
                color: white,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                ),
                elevation: 8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.all(7.0)),
                    Text(
                      'GOAL',
                      style: TextStyle(
                        fontSize: 30.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Center(
                      child: Text(
                        goal,
                        style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 150.0,
                          height: 100.0,
                          child: Image.asset(wantThingIMG),
                        ),
                        Flexible(
                          child: Text(
                            wantThing,
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(7.0)),
                  ],
                ),
              ),
              Padding(padding: EdgeInsets.all(12.0)),
              Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  WaveProgress(
                    300.0, waveshadow, wavecolor, _currentValue
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Align(
                        alignment: Alignment(-0.1, 0.0),
                        child: Text(
                          '￥' + saving.toString(),
                          style: TextStyle(
                            fontSize: 40.0,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment(0.6, 1.0),
                        child: Text(
                          '/ ￥' + wantThingPrice.toString(),
                          style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Padding(padding: EdgeInsets.all(12.0)),
              ButtonTheme(
                minWidth:130.0,
                height: 50.0,
                child: RaisedButton(
                  child: Text(
                    'GAMAN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  color: wavecolor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: submitGaman,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> getDownloadUrl() async {
    userPhotoUrl = await userPhotoRef.getDownloadURL();
  }

  void submitGaman() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      builder: (BuildContext context) => Container(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '価格',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w500,
                color: shadow,
              ),
            ),
            TextField(
              controller: priceController,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w400,
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 40.0),
            Text(
              '内容',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w500,
                color: shadow,
              ),
            ),
            TextField(
              controller: descriptionController,
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
    );
  }

  void submitPressed() async {
    Navigator.pop(context);
    setState(() {
      gamanPrice = priceController.text;
      if ((saving + int.parse(gamanPrice)) <= wantThingPrice) {
        saving += int.parse(gamanPrice);
      }
    });

    final createdAt = DateFormat.yMMMMEEEEd().add_jms().format(DateTime.now());

    await FirebaseFirestore.instance
      .collection('gamans')
      .doc()
      .set({
        'userEmail': userEmail,
        'userName': userName,
        'userPhotoUrl': userPhoto,
        'price': gamanPrice,
        'text': descriptionController.text,
        'createdAt' : createdAt,
      });

    priceController.clear();
    descriptionController.clear();
  }
}
