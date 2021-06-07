import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'views/signup.dart';
import 'views/login.dart';
import 'views/goalselect.dart';
import 'views/mailcheck.dart';
import 'configs/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  //final UserState userState = UserState();
  final user = FirebaseAuth.instance.currentUser;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ちりつも',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Yu Gothic',
      ),
      home: (user != null && user.emailVerified) ? GoalSelectPage() : (user != null && !user.emailVerified) ? Emailcheck(email: user.email) : StartPage(),
    );
  }
}

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey),
        title: Text(
          'ちりつも',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: AppColor.white,
        shadowColor: AppColor.shadow,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(32.0),
          child: Column(
            children: <Widget>[
              Padding(padding: EdgeInsets.all(30.0)),
              SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: () {
                    // 登録後Home画面に遷移
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => MyAuthPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: AppColor.wavecolor,
                    onPrimary: AppColor.textColor,
                  ),
                  child: Text("SignUp"),
                ),
              ),
              SizedBox(
                width: 250,
                child: ElevatedButton(
                  onPressed: () {
                    // 登録後Home画面に遷移
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => MyLoginPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    primary: AppColor.wavecolor,
                    onPrimary: AppColor.textColor,
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
