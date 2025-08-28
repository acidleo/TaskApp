import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    _firebaseAuth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Private helper to set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// ✅ SIGN UP
  Future<String?> signUp(String email, String password) async {
    try {
      _setLoading(true);
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      _errorMessage = null;
      return null; // success
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      return e.message;
    } catch (e) {
      _errorMessage = "An unexpected error occurred.";
      return _errorMessage;
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ LOGIN
  Future<String?> login(String email, String password) async {
    try {
      _setLoading(true);
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _errorMessage = null;
      return null;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message;
      return e.message;
    } catch (e) {
      _errorMessage = "An unexpected error occurred.";
      return _errorMessage;
    } finally {
      _setLoading(false);
    }
  }

  /// ✅ LOGOUT
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firebaseAuth.signOut();
      _user = null; // Clear user locally
      _errorMessage = null;
    } catch (e) {
      _errorMessage = "Logout failed. Try again.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
