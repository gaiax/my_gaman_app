import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'signup.dart';
import 'login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _fbApp = Firebase.initializeApp();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Yu Gothic',
      ),
      home: FutureBuilder(
        future: _fbApp,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print('You have an error! ${snapshot.error.toString()}');
            return Text('Something went wrong!');
          } else if (snapshot.hasData) {
            return StartPage();
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      )
    );
  }
}

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final Color bgColor = Color(0xFFF2FBFE);
  final Color white = Color(0xFFffffff);
  final Color curtain = Color(0x80ffffff);
  final Color shadow = Color(0xFF505659);
  final Color wavecolor = Color(0xFF97DDFA);
  final Color waveshadow = Color(0xFF83C1BB);
  final Color goalTextColor = Color(0xFF2870A0);
  final Color priceColor = Color(0xFF44AAD6);
  final Color textColor = Color(0xFF332F2E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey),
        title: Text(
          'Gaman App',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: white,
        shadowColor: shadow,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32.0),
          child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.all(30.0)),
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {
                    // 登録後Home画面に遷移
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => MyAuthPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: wavecolor,
                    onPrimary: textColor,
                  ),
                  child: Text("SignUp"),
                ),
              ),
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: () {
                    // 登録後Home画面に遷移
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => MyLoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: wavecolor,
                    onPrimary: textColor,
                  ),
                  child: Text("Login"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
