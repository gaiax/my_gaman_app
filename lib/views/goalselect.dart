import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:my_gaman_app/views/goalset.dart';
import '../configs/colors.dart';
import 'home.dart';
import 'postview.dart';
import 'setting.dart';
import 'package:my_gaman_app/main.dart';

class GoalSelectPage extends StatefulWidget {
  @override
  _GoalSelectPageState createState() => _GoalSelectPageState();
}

class _GoalSelectPageState extends State<GoalSelectPage> {

  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance; 

  var user = FirebaseAuth.instance.currentUser;
  var userId;
  var userEmail;
  var userName;
  var userPhoto;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      setData();
    }
  }

  void setData() async {
    userId = user.uid;
    userEmail = user.email;
    userName = user.displayName;
    userPhoto = user.photoURL;

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
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey),
        title: Text(
          '目的一覧',
          style: TextStyle(
            color:AppColor.textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppColor.white,
        shadowColor: AppColor.shadow,
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
              title: Text('　アカウント設定'),
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
            ListTile(
              title: Text(''),
            ),
            ListTile(
              title: Text('　サインアウト'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
                await Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => StartPage()),
                );
              },
            ),
          ],
        ),
      ),

      body: Container(
        color: AppColor.bgColor,
        margin: EdgeInsets.only(top: 20),
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: <Widget>[
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                  .collection('goals')
                  .where('userId', isEqualTo: userId)
                  .orderBy('createdAt', descending: true)
                  .get(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator()
                    );
                  }
                  final List<DocumentSnapshot> documents = snapshot.data.docs;
                  return ListView(
                    children: documents.map((document) {
                      //final othersPhoto = storage.ref(document['userPhoto']);
                      //final othersPhotoUrl = getDownloadUrl(othersPhoto);
                      return Card(
                        margin: EdgeInsets.all(0.5),
                        elevation: 2.0,
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => HomePage(document.id)),
                              (_) => false,
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.all(5.0),
                            child: ListTile(
                              leading: Container(
                                height: 100.0,
                                width: 100.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8.0),
                                  image: DecorationImage(
                                    image: NetworkImage(document['wantThingImg']),
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    document['date'],
                                    style: TextStyle(
                                      fontSize: 9.0,
                                      fontWeight: FontWeight.w300,
                                    ),
                                  ),
                                  Text(
                                    document['goalText'],
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w600,
                                    )
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Padding(padding: EdgeInsets.all(1.0)),
                                  Text(
                                    '目標金額：' + document['wantThingPrice'],
                                    style: TextStyle(
                                      color: AppColor.textColor,
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: (document['achieve'] == true) ? Icon(Icons.check_box_outlined) : Icon(Icons.check_box_outline_blank),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => GoalSetPage()),
          );
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
      ),
    );
  }
}
