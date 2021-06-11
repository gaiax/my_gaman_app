import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:my_gaman_app/views/goalselect.dart';
import 'package:universal_html/controller.dart';
import 'goalset_manual.dart';
import '../models/upload_image.dart';
import '../configs/colors.dart';

class GoalSetPage extends StatefulWidget {
  @override
  _GoalSetPageState createState() => _GoalSetPageState();
}

class _GoalSetPageState extends State<GoalSetPage> {

  TextEditingController goalTextController = TextEditingController();
  TextEditingController wantThingController = TextEditingController();

  var user = FirebaseAuth.instance.currentUser;
  var userId;

  bool _loading = true;
  bool isGoalEmpty = false;
  bool isWantThingEmpty = false;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      userId = user.uid;
    }
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
      backgroundColor: AppColor.white,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.grey),
        title: Text(
          '目的設定',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: AppColor.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Container(
                color: AppColor.white,
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      '我慢目的',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: AppColor.shadow,
                      ),
                    ),
                    TextField(
                      controller: goalTextController,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLength: 15,
                      decoration: InputDecoration(
                        hintText: '(例)ディスプレイが欲しい！',
                      ),
                    ),
                    Visibility(
                      visible: isGoalEmpty,
                      child: Text(
                        "我慢目的を入力してください。(例: ディスプレイが欲しい！）",
                        style: TextStyle(color: Colors.red, fontSize: 12.0),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Text(
                      '欲しいもの',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w500,
                        color: AppColor.shadow,
                      ),
                    ),
                    Text(
                      '※ Amazon商品リンクを貼り付けてください.',
                      style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.w500,
                        color: AppColor.shadow,
                      ),
                    ),
                    TextField(
                      controller: wantThingController,
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Visibility(
                      visible: isWantThingEmpty,
                      child: Text(
                        "欲しいモノのAmazon商品リンクを入力してください。",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(30.0),),
                    Container(
                      alignment: Alignment.bottomRight,
                      padding: EdgeInsets.all(10.0),
                      child: SizedBox(
                        child: ElevatedButton(
                          onPressed: submitPressed,
                          style: ElevatedButton.styleFrom(
                            primary: AppColor.priceColor,
                            onPrimary: AppColor.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            '登録',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24.0,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(30.0)),
                    SizedBox(
                      width: 200.0,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => GoalSetManualPage()),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          primary: AppColor.shadow,
                          onPrimary: AppColor.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          '手動で登録する',
                          style: TextStyle(
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void submitPressed() async {
    if (goalTextController.text.isNotEmpty && wantThingController.text.isNotEmpty) {
      setState(() {
        _loading = true;
      });
      final time = DateTime.now();
      final createdAt = Timestamp.fromDate(time);
      final date = DateFormat('yyyy-MM-dd HH:mm').format(time).toString();

      try {
        final amazonUrl = getAmazonlink(wantThingController.text);
        final controller = WindowController();
        await controller.openHttp(
          uri: Uri.parse(amazonUrl),
        );

        var wantThingAmazonImg;
        try {
          final imgContainer = controller.window.document.querySelector("#imgTagWrapperId");
          wantThingAmazonImg = imgContainer.querySelectorAll("img").first.getAttribute("src");
        } catch(e) {
          wantThingAmazonImg = controller.window.document.querySelectorAll("#ebooksImgBlkFront").first.getAttribute("src");
        }

        final wantThingPrice = controller.window.document.querySelectorAll("span.a-color-price").first.text.replaceAll('\n', '');

        final wantThingImg = await UploadImage.uploadAmazonImg(wantThingAmazonImg, userId, date);

        await FirebaseFirestore.instance
          .collection('goals')
          .doc()
          .set({
            'userId': userId,
            'goalText': goalTextController.text,
            'wantThingUrl': amazonUrl,
            'wantThingImg': wantThingImg,
            'wantThingPrice': wantThingPrice,
            'createdAt' : createdAt,
            'date': date,
            'achieve': false,
          });
      } catch(e) {
        return showDialog(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('エラー'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('欲しいモノ情報が取得できませんでした。'),
                    Text('手動で登録してください。'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => GoalSetManualPage()),
                    );
                  },
                ),
              ],
            );
          },
        );
      }

      goalTextController.clear();
      wantThingController.clear();

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => GoalSelectPage()),
      );

      _loading = false;
    } else {
      setState(() {
        isGoalEmpty = goalTextController.text.isEmpty;
        isWantThingEmpty = wantThingController.text.isEmpty;
      });
    }
  }

  String getAmazonlink (String input){
    // RegExpを定義
    final RegExp urlRegExp = RegExp(
      r'((https?:www\.)|(https?:\/\/)|(www\.))[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9]{1,6}(\/[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)?'
    );
          
    // ここで、Iterable型でURLの配列を取得
    final Iterable<RegExpMatch> urlMatches = urlRegExp.allMatches(input);
    for (RegExpMatch urlMatch in urlMatches) {
      return input.substring(urlMatch.start, urlMatch.end);
    }
    return null;
  }
}
