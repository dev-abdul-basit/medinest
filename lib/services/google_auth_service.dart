import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:medinest/utils/debug.dart';
import 'package:medinest/utils/preference.dart';

class GoogleAuthService {
  GoogleAuthService._();
  static final GoogleAuthService instance = GoogleAuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  bool _initialized = false;

  /// Initialize ONCE (NO auth here)
  Future<void> initialize({
    String? clientId,
    String? serverClientId,
  }) async {
    if (_initialized) return;

    await _googleSignIn.initialize(
      clientId: clientId,
      serverClientId: serverClientId,
    );

    _initialized = true;
    Debug.printLog('GoogleAuthService initialized');
  }

  /// USER-INTENT login (button tap ONLY)
  Future<GoogleSignInResult> signInWithGoogle() async {
    try {
      if (!_googleSignIn.supportsAuthenticate()) {
        return GoogleSignInResult.error(
          'Google authentication not supported on this platform',
        );
      }

      // 🔴 This is the ONLY place authenticate() is allowed
      GoogleSignInAccount? user;
      try {
        user = await _googleSignIn.authenticate();
      } catch (e) {
        return GoogleSignInResult.error(e.toString());
      }
      if (user == null) {
        return GoogleSignInResult.cancelled();
      }

      final GoogleSignInAuthentication auth =
      await user.authentication;

      if (auth.idToken == null && auth.idToken == null) {
        return GoogleSignInResult.error('Missing Google auth tokens');
      }

      final OAuthCredential credential =
      GoogleAuthProvider.credential(
        idToken: auth.idToken,
        accessToken: auth.idToken,
      );

      final UserCredential firebaseUser =
      await _auth.signInWithCredential(credential);

      final userData = firebaseUser.user;
      if (userData == null) {
        return GoogleSignInResult.error('Firebase user is null');
      }

      // Persist login state
      Preference.shared.setIsUserLogin(true);
      Preference.shared.setString(
        Preference.firebaseAuthUid,
        userData.uid,
      );
      Preference.shared.setString(
        Preference.firebaseEmail,
        userData.email ?? '',
      );

      Debug.printLog('Google login success: ${userData.email}');

      return GoogleSignInResult.success(firebaseUser);
    } on GoogleSignInException catch (e) {
      Debug.printLog('GoogleSignInException: ${e.code}');
      return GoogleSignInResult.error(_mapError(e));
    } catch (e) {
      Debug.printLog('Google login error: $e');
      return GoogleSignInResult.error(e.toString());
    }
  }

  /// Logout (explicit)
  Future<void> signOut() async {
    await _googleSignIn.disconnect();
    await _auth.signOut();
    Preference.shared.setIsUserLogin(false);
  }

  String _mapError(GoogleSignInException e) {
    return switch (e.code) {
      GoogleSignInExceptionCode.canceled => 'Sign in cancelled',
      _ => e.description ?? 'Google sign-in failed',
    };
  }
}

/// Result model
class GoogleSignInResult {
  final bool isSuccess;
  final bool isCancelled;
  final String? errorMessage;
  final UserCredential? credential;

  GoogleSignInResult._({
    required this.isSuccess,
    required this.isCancelled,
    this.errorMessage,
    this.credential,
  });

  factory GoogleSignInResult.success(UserCredential credential) {
    return GoogleSignInResult._(
      isSuccess: true,
      isCancelled: false,
      credential: credential,
    );
  }

  factory GoogleSignInResult.cancelled() {
    return GoogleSignInResult._(
      isSuccess: false,
      isCancelled: true,
    );
  }

  factory GoogleSignInResult.error(String message) {
    return GoogleSignInResult._(
      isSuccess: false,
      isCancelled: false,
      errorMessage: message,
    );
  }
}
