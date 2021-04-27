import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wave_progress_widget/wave_progress.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'postview.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final Color bgColor = Color(0xFFF2FBFE);
  final Color white = Color(0xFFffffff);
  final Color curtain = Color(0x80ffffff);
  final Color shadow = Color(0xFF505659);
  final Color wavecolor = Color(0xFF97DDFA);
  final Color waveshadow = Color(0xFF83C1BB);
  final Color goalTextColor = Color(0xFF2870A0);
  final Color priceColor = Color(0xFF44AAD6);
  final Color textColor = Color(0xFF332F2E);

  var goal = '2ヶ月以内に５ｋｇ痩せる';
  var wantThingIMG = 'image/display.jpg';
  var wantThing = 'LG 27UL550-W 27型 4K 液晶ディスプレイ';
  var price = 15000;

  var _currentValue = 0.0;
  var saving = 0;
  var gamanPrice;

  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance; 

  final formatter = NumberFormat('#,##0', 'ja_JP');

  var user = FirebaseAuth.instance.currentUser;
  var userEmail;
  var userName;
  var userPhoto;
  var wantThingPrice;
  var wantThingImg;

  QuerySnapshot gamanSnapshot;
  List<DocumentSnapshot> documents = [];

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
    QuerySnapshot goalSnapshot = await FirebaseFirestore.instance.collection('goals').limit(1).where('userName', isEqualTo: userName).get();
    wantThingPrice = goalSnapshot.docs[0].data()['wantThingPrice'].replaceAll(',', '').replaceAll('￥', '');
    wantThingImg = goalSnapshot.docs[0].data()['wantThingImg'];

    gamanSnapshot = await FirebaseFirestore.instance.collection('gamans').where('userName', isEqualTo: userName).get();
    documents = gamanSnapshot.docs;

    setState(() {
      _loading = false;
    });
    print(wantThingImg);
  }

  @override
  Widget build(BuildContext context) {
    _currentValue = (saving.toInt() / int.parse(wantThingPrice)) * 100;

    if (_loading) {
      return Center(
        child: CircularProgressIndicator()
      );
    }

    return Scaffold(
      backgroundColor: bgColor,

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
                      image:NetworkImage(userPhoto),
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
              title: Text('タイムライン'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => PostViewPage()),
                );
              },
            ),
          ],
        ),
      ),

      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('image/SliverAppBar.png'),
                  ),
                ),
                padding: EdgeInsets.only(top: 14.0),
                child: Row(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.all(16.0)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '目標金額',
                          style: TextStyle(
                            color: goalTextColor,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            Text(
                              formatter.format(int.parse(wantThingPrice)),
                              style: TextStyle(
                                color: goalTextColor,
                                fontSize: 30.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '円',
                              style: TextStyle(
                                color: goalTextColor,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w300,
                              )
                            ), 
                          ],
                        ),
                        Padding(padding: EdgeInsets.all(12.0)),
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(4.0)),
                    Container(
                      width: 200.0,
                      height: 180.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.contain,
                          image: NetworkImage(wantThingImg),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Padding(padding: EdgeInsets.all(12.0)),
                    Stack(
                      alignment: Alignment.center,
                      children: <Widget>[
                        Container(
                          width: 320,
                          height: 320,
                          decoration: BoxDecoration(
                            color: white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        WaveProgress(
                          310.0, white, wavecolor, _currentValue
                        ),
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: curtain,
                            shape: BoxShape.circle,
                          )
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '現在の貯金額',
                              style: TextStyle(
                                color: priceColor,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                Text(
                                  formatter.format(saving),
                                  style: TextStyle(
                                    color: priceColor,
                                    fontSize: 45.0,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '円',
                                  style: TextStyle(
                                    color: priceColor,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w300,
                                  )
                                ),
                              ]
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(padding: EdgeInsets.all(12.0)),
                Container(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    '最近の我慢履歴',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    )
                  ),
                ),
                Column(
                  children: documents.map(
                    (document) => Card(
                      margin: EdgeInsets.all(0.5),
                      elevation: 2.0,
                      child: Padding(
                        padding: EdgeInsets.all(7.0),
                        child: ListTile(
                          leading: Container(
                            height: 55.0,
                            width: 55.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              image: DecorationImage(
                                image: NetworkImage(document['userPhotoUrl']),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                document['userName'],
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                document['createdAt'],
                                style: TextStyle(
                                  fontSize: 9.0,
                                  fontWeight: FontWeight.w300,
                                )
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(padding: EdgeInsets.all(3.0)),
                              Text(
                                document['text'],
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                          trailing: Text(
                            document['price'],
                            style: TextStyle(
                              color: priceColor,
                              fontSize: 20.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      )
                    )).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          submitGaman();
        },
        child: Text(
          '+',
          style: TextStyle(
            color: white,
            fontSize: 45.0,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: wavecolor,
      ),
    );
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
      if ((saving + int.parse(gamanPrice)) <= int.parse(wantThingPrice)) {
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
