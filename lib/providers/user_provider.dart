import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kifg/models/user_model.dart';

class UserProvider with ChangeNotifier {
  User? _firebaseUser;
  UserModel? _userModel;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;

  bool get isLoggedIn => _firebaseUser != null;
  bool get isTeacher => _userModel?.isTeacher ?? false;

  void setFirebaseUser(User? user) {
    _firebaseUser = user;
    notifyListeners();
  }

  void setUserModel(UserModel? userModel) {
    _userModel = userModel;
    notifyListeners();
  }

  void clear() {
    _firebaseUser = null;
    _userModel = null;
    notifyListeners();
  }
}
