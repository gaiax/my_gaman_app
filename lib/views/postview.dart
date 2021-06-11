import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:my_gaman_app/views/setting.dart';
import '../configs/colors.dart';
import '../main.dart';

class PostViewPage extends StatefulWidget {
  @override
  _PostViewPageState createState() => _PostViewPageState();
}

class _PostViewPageState extends State<PostViewPage> {

  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance;

  var cloud = FirebaseFirestore.instance;
  var user = FirebaseAuth.instance.currentUser;
  var userName;
  var userPhoto;
  var userEmail;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      setData();
    }
  }

  void setData() async {
    userName = user.displayName;
    userPhoto = user.photoURL;
    userEmail = user.email;

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
          'みんなの我慢履歴',
          style: TextStyle(
            color:AppColor.textColor,
            fontWeight: FontWeight.w600,
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
          if (index == 0) {
            Navigator.of(context).pop();
          } else if (index == 1) {
            setState(() {});
          }
        },
        fixedColor: AppColor.priceColor,
        currentIndex: 1,
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
                  .collection('gamans')
                  .orderBy('createdAt', descending: true)
                  .limit(50)
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
                        child: Padding(
                          padding: EdgeInsets.all(7.0),
                          child: FutureBuilder<DocumentSnapshot>(
                            future: cloud
                              .collection('users')
                              .doc(document['userId'])
                              .get(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Center(
                                  child: CircularProgressIndicator()
                                );
                              }
                              final DocumentSnapshot userData = snapshot.data;
                              return ListTile(
                                leading: Container(
                                  height: 55.0,
                                  width: 55.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    image: DecorationImage(
                                      image: NetworkImage(userData['userPhotoUrl']),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      userData['userName'],
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      document['date'],
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
                                        color: AppColor.textColor,
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                                trailing: Text(
                                  document['price'].toString(),
                                  style: TextStyle(
                                    color: AppColor.priceColor,
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              );
                            },
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
    );
  }
}
