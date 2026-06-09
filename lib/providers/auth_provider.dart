import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _firebaseUser;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _error;

  User? get firebaseUser => _firebaseUser;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _firebaseUser != null;
  bool get isHost => _userModel?.isHost ?? false;
  bool get isGuest => _firebaseUser?.isAnonymous ?? false;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? user) async {
    _firebaseUser = user;
    if (user != null && !user.isAnonymous) {
      _userModel = await _authService.getUserData(user.uid);
    } else {
      _userModel = null;
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final cred = await _authService.signIn(email, password);
      _userModel = await _authService.getUserData(cred.user!.uid);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapFirebaseError(e.code);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(
      String email, String password, String name, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.register(email, password, name, role);
      _userModel = await _authService.getUserData(
          _authService.currentUser!.uid);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapFirebaseError(e.code);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInAsGuest(String guestName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.signInAnonymously();
      _userModel = UserModel(
        uid: _authService.currentUser!.uid,
        name: guestName,
        email: '',
        role: 'participant',
        createdAt: DateTime.now(),
      );
      return true;
    } catch (e) {
      _error = 'حدث خطأ، يرجى المحاولة مرة أخرى';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _userModel = null;
    _firebaseUser = null;
    notifyListeners();
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'البريد الإلكتروني غير مسجل';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم مسبقاً';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'too-many-requests':
        return 'محاولات كثيرة، يرجى الانتظار';
      default:
        return 'حدث خطأ، يرجى المحاولة مرة أخرى';
    }
  }
}
