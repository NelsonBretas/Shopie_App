import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:shopie/models/http_exception.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  var _token = '';
  var _expiryDate;
  var _userId;
  var _authTimer;

  bool get isAuth {
    return token != '';
  }

  String get token {
    if (_token != '') {
      return _token;
    }
    return '';
  }

  String get userId {
    return _userId;
  }

  Future<void> _authenticate(
      String email, String password, String newUrl) async {
    var url = Uri.parse(newUrl);
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));
      final responseData = jsonDecode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _autoLogout();
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      final userData = jsonEncode({'token': _token, 'userId': _userId});
      prefs.setString('userData', userData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    return _authenticate(email, password,
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyCIRjLDozxzT9ygZA6RYpmZr3-KB-iLvAQ');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password,
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyCIRjLDozxzT9ygZA6RYpmZr3-KB-iLvAQ');
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    final extractedUserData = json
        .decode(prefs.getString('userData').toString()) as Map<String, Object>;
    //  final expiryDate =
    //    DateTime.parse(extractedUserData['expiryDate'].toString());

    //if (expiryDate.isBefore(DateTime.now())) {
    //return false;
//    }

    _token = extractedUserData['token'].toString();
    _userId = extractedUserData['userId'].toString();
    //_expiryDate = expiryDate.toIso8601String();
    //notifyListeners();

    return true;
/*
    if (prefs.containsKey('userData')) {
      //return true;
    }

    final extractedUserData = json
        .decode(prefs.getString('userData').toString()) as Map<String, Object>;
    //  final expiryDate =
    //    DateTime.parse(extractedUserData['expiryDate'].toString());

    //if (expiryDate.isBefore(DateTime.now())) {
    //return false;
//    }

    _token = extractedUserData['token'].toString();
    _userId = extractedUserData['userId'].toString();
    //_expiryDate = expiryDate.toIso8601String();
    notifyListeners();
    _autoLogout();

    return true;
    */
  }

  Future<void> logout() async {
    _token = '';
    _userId = '';
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    //prefs.remove('userData');
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timetoExpire = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timetoExpire), logout);
  }
}
