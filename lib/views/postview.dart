import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import '../configs/colors.dart';

class PostViewPage extends StatefulWidget {
  @override
  _PostViewPageState createState() => _PostViewPageState();
}

class _PostViewPageState extends State<PostViewPage> {

  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance; 

  var user = FirebaseAuth.instance.currentUser;
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
          'タイムライン',
          style: TextStyle(
            color:AppColor.textColor,
            fontWeight: FontWeight.w600,
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
                  .collection('gamans')
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
                              document['price'],
                              style: TextStyle(
                                color: AppColor.priceColor,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          )
                        )
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
