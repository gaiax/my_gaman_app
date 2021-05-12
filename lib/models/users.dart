import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserState extends ChangeNotifier {
  LoginUser user = LoginUser();

  UserState(loginuser){
    getUser(loginuser);
  }

  void getUser(loginUser) {
    user.userEmail = loginUser.email;
    user.userName = loginUser.displayName;
    user.userPhoto = loginUser.photoURL;
    notifyListeners();
  }
}

class LoginUser {
  var userEmail;
  var userName;
  var userPhoto;
}
