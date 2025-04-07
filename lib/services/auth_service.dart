import 'package:firebase_auth/firebase_auth.dart';
import 'package:kifg/models/user_model.dart';
import 'package:kifg/services/firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Register a new user with email and password
  Future<User?> register(String email, String password, bool isTeacher) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = result.user;

      if (user != null) {
        final firestoreService = FirestoreService();
        final newUser = UserModel(
          email: email,
          creationDate: DateTime.now(),
          isTeacher: isTeacher,
        );
        await firestoreService.createUser(user.uid, newUser);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  /// Log in an existing user
  Future<User?> signIn(String email, String password) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e));
    }
  }

  /// Log out the current user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Handle FirebaseAuth error codes
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'User has been disabled.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already in use.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'operation-not-allowed':
        return 'Operation not allowed. Please contact support.';
      default:
        return 'An unknown error occurred: ${e.message}';
    }
  }
}
