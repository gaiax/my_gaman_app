import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class PostViewPage extends StatefulWidget {
  @override
  _PostViewPageState createState() => _PostViewPageState();
}

class _PostViewPageState extends State<PostViewPage> {

  final Color bgColor = Color(0xFFF2FBFE);
  final Color white = Color(0xFFffffff);
  final Color shadow = Color(0xFF505659);
  final Color wavecolor = Color(0xFF45B5AA);
  final Color waveshadow = Color(0xFF83C1BB);
  final Color priceColor = Color(0xFF44AAD6);
  final Color textColor = Color(0xFF332F2E);

  var saving = 0;
  var wantThingPrice = 15000;
  var gamanPrice;

  TextEditingController priceController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  firebase_storage.FirebaseStorage storage = firebase_storage.FirebaseStorage.instance; 

  var user = FirebaseAuth.instance.currentUser;
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
      backgroundColor: bgColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey),
        title: Text(
          'タイムライン',
          style: TextStyle(
            color:textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: white,
        shadowColor: shadow,
      ),

      body: Container(
        color: bgColor,
        margin: EdgeInsets.only(top: 20),
        padding: EdgeInsets.only(left: 10, right: 10),
        child: Column(
          children: <Widget>[
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                  .collection('gamans')
                  .orderBy('createdAt')
                  .get(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
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
                        );
                      }).toList(),
                    );
                  }
                  return Center(
                    child: CircularProgressIndicator()
                  );
                },
              ),
            )
          ]
        ),
      ),
    );
  }
}
