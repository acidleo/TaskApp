import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkProvider extends ChangeNotifier {
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  NetworkProvider() {
    Connectivity().onConnectivityChanged.listen((status) {
      _isOnline = status != ConnectivityResult.none;
      notifyListeners();
    });
  }
}
