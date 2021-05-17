import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wave_progress_widget/wave_progress.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'postview.dart';
import 'setting.dart';
import '../configs/colors.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  var _currentValue = 0.0;
  var saving = 0;
  var gamanPrice;

  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance; 

  final formatter = NumberFormat('#,##0', 'ja_JP');

  var user = FirebaseAuth.instance.currentUser;
  var cloud = FirebaseFirestore.instance;
  var userEmail;
  var userName;
  var userPhoto;
  var wantThingPrice;
  var wantThingImg;
  var goalId;

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
    QuerySnapshot goalSnapshot = await cloud.collection('goals').limit(1).where('userEmail', isEqualTo: userEmail).get();
    wantThingPrice = goalSnapshot.docs[0].data()['wantThingPrice'].replaceAll(',', '').replaceAll('￥', '');
    wantThingImg = goalSnapshot.docs[0].data()['wantThingImg'];
    goalId = goalSnapshot.docs[0].id;

    gamanSnapshot = await cloud.collection('gamans').where('goalId', isEqualTo: goalId).get();
    documents = gamanSnapshot.docs;
    documents.forEach((document) {
      saving = saving + int.parse(document['price']);
    });
    if (saving >= int.parse(wantThingPrice)) {
      saving = int.parse(wantThingPrice);
    }
    _currentValue = (saving / int.parse(wantThingPrice)) * 100; 

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
              title: Text('　タイムライン'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => PostViewPage()),
                );
              },
            ),
            ListTile(
              title: Text('　プロフィール設定'),
              onTap: () async {
                Navigator.of(context).pop();
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => SettingPage()),
                );
                setState(() {
                  user = FirebaseAuth.instance.currentUser;
                  userName = user.displayName;
                  userPhoto = user.photoURL;
                });
              },
            ), 
          ],
        ),
      ),

      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            backgroundColor: wavecolor,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('image/SliverAppBar2.png'),
                  ),
                ),
                padding: EdgeInsets.only(top: 14.0),
                child: Row(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.all(17.0)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '目標金額',
                          style: TextStyle(
                            color: priceColor,
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
                                color: priceColor,
                                fontSize: 30.0,
                                fontWeight: FontWeight.w600,
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
                          ],
                        ),
                        Padding(padding: EdgeInsets.all(12.0)),
                      ],
                    ),
                    Padding(padding: EdgeInsets.all(7.0)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Container(
                          width: 208.0,
                          height: 200.0,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.contain,
                              image: NetworkImage(wantThingImg),
                            ),
                          ),
                        ),
                      ],
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
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                    )
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Column(
                    children: documents.map(
                      (document) => Card(
                        margin: EdgeInsets.all(0.5),
                        elevation: 2.0,
                        child: Padding(
                          padding: EdgeInsets.all(7.0),
                          child: ListTile(
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  document['createdAt'],
                                  style: TextStyle(
                                    fontSize: 12.0,
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
                                    fontSize: 18.0,
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
        backgroundColor: priceColor,
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: submitPressed,
                color: priceColor,
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

    final createdAt = DateFormat.yMMMMEEEEd().add_jms().format(DateTime.now());
    gamanPrice = priceController.text;

    await FirebaseFirestore.instance
      .collection('gamans')
      .doc()
      .set({
        'userEmail': userEmail,
        'userName': userName,
        'userPhotoUrl': userPhoto,
        'price': gamanPrice,
        'text': descriptionController.text,
        'createdAt': createdAt,
        'goalId': goalId, 
      });

    gamanSnapshot = await FirebaseFirestore.instance.collection('gamans').where('goalId', isEqualTo: goalId).get();
    documents = gamanSnapshot.docs;

    setState(() {
      saving = saving + int.parse(gamanPrice);
      if (saving >= int.parse(wantThingPrice)) {
        saving = int.parse(wantThingPrice);
      }
      _currentValue = (saving / int.parse(wantThingPrice)) * 100;
    });
    
    priceController.clear();
    descriptionController.clear();
  }
}
