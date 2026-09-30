import '../models/auth_model.dart';

class AuthPresenter {
  final AuthModel _model = AuthModel();

  Future<String?> login(String email, String password) {
    return _model.login(email, password);
  }

  Future<String?> signUp(String email, String password) {
    return _model.signUp(email, password);
  }

  Future<void> logout() {
    return _model.signOut();
  }

  Future<String?> resetPassword(String email) {
  return _model.resetPassword(email);
}

  Stream authStateChanges() {
    return _model.authStateChanges();
  }

  String? get currentUserEmail => _model.currentUser?.email;
}