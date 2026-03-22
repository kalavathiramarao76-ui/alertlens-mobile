import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  static const int maxFreeUses = 3;
  static const String _usageKey = 'usage_count';
  
  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStream => _auth.authStateChanges();
  
  Future<int> getUsageCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_usageKey) ?? 0;
  }
  
  Future<int> incrementUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final count = (prefs.getInt(_usageKey) ?? 0) + 1;
    await prefs.setInt(_usageKey, count);
    return count;
  }
  
  Future<bool> needsAuth() async {
    final count = await getUsageCount();
    return count >= maxFreeUses && currentUser == null;
  }
  
  Future<User?> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null;
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final result = await _auth.signInWithCredential(credential);
    return result.user;
  }
  
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
