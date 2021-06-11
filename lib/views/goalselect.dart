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

  var cloud = FirebaseFirestore.instance;
  var user = FirebaseAuth.instance.currentUser;
  var userId;
  var userEmail;
  var userName;
  var userPhoto;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    user.reload();
    user = FirebaseAuth.instance.currentUser;
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
      backgroundColor: AppColor.bgColor2,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey),
        title: Text(
          'ホーム',
          style: TextStyle(
            color:AppColor.textColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: AppColor.white,
        shadowColor: AppColor.shadow,
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'ホーム',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.whatshot_outlined),
            label: 'みんなの我慢',
          ),
        ],
        onTap: (int index) {
          if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => PostViewPage()),
            );
          }
        },
        fixedColor: AppColor.priceColor,
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
            Padding(padding: EdgeInsets.all(10.0)),
            ListTile(
              leading: Icon(Icons.settings_outlined),
              title: Text('アカウント設定'),
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
              leading: Icon(Icons.logout_outlined),
              title: Text('サインアウト'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pop();
                await Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => StartPage()),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),

      body: Container(
        color: AppColor.bgColor2,
        margin: EdgeInsets.only(top: 20),
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: <Widget>[
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: cloud
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
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => HomePage(document.id)),
                            );
                          },
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('目的削除'),
                                  content: Text('この目的を削除しますか？'),
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
                                        deleteGoal(document.id);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
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
        child: Text(
          '＋',
          style: TextStyle(
            color: AppColor.white,
            fontSize: 35.0,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: AppColor.priceColor,
      ),
    );
  }

  void deleteGoal(String id) async {
    QuerySnapshot gamanSnapshot = await cloud.collection('gamans').where('goalId', isEqualTo: id).orderBy('createdAt', descending: true).get();
    gamanSnapshot.docs.forEach((DocumentSnapshot gaman) async { 
      await cloud.collection('gamans').doc(gaman.id).delete();
    });
    await cloud.collection('goals').doc(id).delete();
    setState(() {});
  }
}
