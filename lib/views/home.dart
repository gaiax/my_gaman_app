import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'waveprogress.dart';
import '../configs/colors.dart';

class HomePage extends StatefulWidget {
  @override
  HomePage(this.goalId);
  final String goalId;
  _HomePageState createState() => _HomePageState(goalId);
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
  var userId;
  var userName;
  var userPhoto;
  var wantThingPrice;
  var wantThingImg;
  var wantThingText;
  var goalId;
  var _url;

  _HomePageState(this.goalId);
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
    userId = user.uid;
    DocumentSnapshot goalSnapshot = await cloud.collection('goals').doc(goalId).get();
    wantThingPrice = goalSnapshot['wantThingPrice'].replaceAll(',', '').replaceAll('￥', '');
    wantThingImg = goalSnapshot['wantThingImg'];
    wantThingText = goalSnapshot['goalText'];
    _url = goalSnapshot['wantThingUrl'];

    gamanSnapshot = await cloud.collection('gamans').where('goalId', isEqualTo: goalId).orderBy('createdAt', descending: true).get();
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
      backgroundColor: AppColor.bgColor,
      resizeToAvoidBottomInset: true,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            iconTheme: IconThemeData(color: Colors.grey),
            expandedHeight: 200.0,
            backgroundColor: AppColor.wavecolor,
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
                padding: EdgeInsets.all(3.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      Padding(padding: EdgeInsets.all(14.0)),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            '目標金額',
                            style: TextStyle(
                              color: AppColor.priceColor,
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
                                  color: AppColor.priceColor,
                                  fontSize: 28.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '円',
                                style: TextStyle(
                                  color: AppColor.priceColor,
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w300,
                                )
                              ), 
                            ],
                          ),
                          Padding(padding: EdgeInsets.all(12.0)),
                        ],
                      ),
                      Padding(padding: EdgeInsets.all(16.0)),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Container(
                            width: 200.0,
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
                          width: 310,
                          height: 310,
                          decoration: BoxDecoration(
                            color: AppColor.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        WaveProgress(
                          300.0, AppColor.white, AppColor.wavecolor, _currentValue
                        ),
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: AppColor.curtain,
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
                                color: AppColor.priceColor,
                                fontSize: 16.0,
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
                                    color: AppColor.priceColor,
                                    fontSize: 38.0,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '円',
                                  style: TextStyle(
                                    color: AppColor.priceColor,
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
                      color: AppColor.textColor,
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
                        child: InkWell(
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('我慢削除'),
                                  content: Text('この我慢を削除しますか？'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: const Text('OK'),
                                      onPressed: () {
                                        deleteGaman(document.id);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all(7.0),
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    document['date'],
                                    style: TextStyle(
                                      fontSize: 11.0,
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
                                      color: AppColor.textColor,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Text(
                                document['price'],
                                style: TextStyle(
                                  color: AppColor.priceColor,
                                  fontSize: 19.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      
      floatingActionButton: (saving < int.parse(wantThingPrice)) ? FloatingActionButton(
        onPressed: () {
          submitGaman();
        },
        child: Container(
          alignment: Alignment.center,
          child: Text(
            '＋',
            style: TextStyle(
              color: AppColor.white,
              fontSize: 40.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        backgroundColor: AppColor.priceColor,
      ) : null,
    );
  }

  void submitGaman() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      builder: (BuildContext context) => GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Container(
            padding: MediaQuery.of(context).viewInsets,
            child: Container(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    '価格',
                    style: TextStyle(
                      fontSize: 20.0,
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
                            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w500, color: AppColor.textColor),
                          ),
                          SizedBox(height: 24.0),
                        ],
                      ),
                      Flexible(
                        child: TextFormField(
                          controller: priceController,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400,
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          maxLength: 6,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18.0),
                  Text(
                    '内容',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.w500,
                      color: AppColor.shadow,
                    ),
                  ),
                  TextField(
                    controller: descriptionController,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: InputDecoration(
                      hintText: '(例)買い食いを我慢した！',
                      hintStyle: TextStyle(fontSize: 16.0,),
                    ),
                    maxLength: 20,
                  ),
                  Padding(padding: EdgeInsets.all(40.0),),
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
                      color: AppColor.priceColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void submitPressed() async {
    Navigator.pop(context);

    if(priceController.text != '' && descriptionController.text != '') {
      final time = DateTime.now();
      final createdAt = Timestamp.fromDate(time);
      final date = DateFormat('yyyy-MM-dd HH:mm').format(time).toString();
      gamanPrice = priceController.text;

      await cloud
        .collection('gamans')
        .doc()
        .set({
          'userId': userId,
          'price': gamanPrice,
          'text': descriptionController.text,
          'createdAt': createdAt,
          'date': date,
          'goalId': goalId, 
        });
      gamanSnapshot = await cloud.collection('gamans').where('goalId', isEqualTo: goalId).orderBy('createdAt', descending: true).get();
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

      if (saving >= int.parse(wantThingPrice)) {
        await cloud.collection('goals').doc(goalId).update({'achieve': true});
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('目標達成！'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Image.network(wantThingImg),
                    Text('おめでとうございます！実質貯金が貯まりました。'),
                    (_url != null) ? Text('商品ページへ遷移しますか？') : Container(),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    (_url != null) ? _launchURL() : Container();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  void _launchURL() async {
    if(_url == null) {
      errorDialog();
    } else {
      await canLaunch(_url) ? await launch(_url) : errorDialog();
    }
  }

  void deleteGaman(String id) async {
    await cloud.collection('gamans').doc(id).delete();
    gamanSnapshot = await cloud.collection('gamans').where('goalId', isEqualTo: goalId).orderBy('createdAt', descending: true).get();
    setState(() {
      documents = gamanSnapshot.docs;
      saving = 0;
      documents.forEach((document) {
        saving = saving + int.parse(document['price']);
      });
      _currentValue = (saving / int.parse(wantThingPrice)) * 100;
    });
  }

  void errorDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('エラーが起こりました。'),
          content: Text('欲しいモノのURLが見つかりません。直接アクセスしてください。'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
