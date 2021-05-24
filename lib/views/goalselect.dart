import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:my_gaman_app/views/goalset.dart';
import '../configs/colors.dart';
import 'home.dart';

class GoalSelectPage extends StatefulWidget {
  @override
  _GoalSelectPageState createState() => _GoalSelectPageState();
}

class _GoalSelectPageState extends State<GoalSelectPage> {

  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance; 

  var user = FirebaseAuth.instance.currentUser;
  var userId;
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
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(builder: (context) => HomePage(document.id)),
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
