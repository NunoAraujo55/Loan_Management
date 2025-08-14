import 'package:flutter/material.dart';
import 'package:flutter_amortiza/models/user_model.dart';

class UserController with ChangeNotifier {
  User? _user;

  User? get user => _user;

  void setUser(User user) {
    _user = user;
    notifyListeners();
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
