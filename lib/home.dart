import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wave_progress_widget/wave_progress.dart';
import 'dart:math';

import 'signup.dart';
import 'login.dart';

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

  var username = 'USERNAME';
  var email = 'email-address';

  var _currentValue = 0.0;
  var saving = 0;
  var wantThingPrice = 15000;

  final controller = TextEditingController();
  final controller2 = TextEditingController();
  var gaman_price;
  var gaman_text;

  @override
  Widget build(BuildContext context) {
    _currentValue = (saving.toInt() / wantThingPrice.toInt()) * 100;
    return Scaffold(
      backgroundColor: bgColor,
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
                title: Text(username),
                subtitle: Text(email),
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
              Text(
                'GOAL:',
                style: TextStyle(
                  fontSize: 35.0,
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
              ButtonTheme(
                height: 30.0,
                child: RaisedButton(
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  color: Colors.white,
                  shape: CircleBorder(
                    side: BorderSide(
                      color: wavecolor,
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                  onPressed: (){},
                ),
              ),
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
              Padding(padding: EdgeInsets.all(5.0)),
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

  void submitGaman() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) => Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Padding(padding: EdgeInsets.all(6.0)),
            Text(
              'PRICE',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w500,
                color: shadow,
              ),
            ),
            TextField(
              controller: controller,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
              keyboardType: TextInputType.number,
            ),
            Padding(padding: EdgeInsets.all(20.0)),
            Text(
              'DESCRIPTION',
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w500,
                color: shadow,
              ),
            ),
            TextField(
              controller: controller2,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
            Padding(padding: EdgeInsets.all(50.0),),
            Align(
              alignment: Alignment.bottomRight,
              child: RaisedButton(
                child: Text(
                  'SUBMIT',
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

  void submitPressed() {
    setState(() {
      gaman_price = controller.text;
      saving += int.parse(gaman_price);
      gaman_text = controller2.text;
    });
  }
}
