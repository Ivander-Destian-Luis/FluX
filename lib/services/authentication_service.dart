import "package:firebase_auth/firebase_auth.dart";

class AuthenticationService {
  static Future<int> login(String email, String password) async {
    int statusCode = 0;
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      statusCode = 200;
    } catch (e) {
      print(e);
      statusCode = 404;
    }

    return statusCode;
  }

  static Future<int> register(String email, String password) async {
    int statusCode = 0;
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      statusCode = 200;
    } catch (e) {
      print(e);
      if (e.toString().contains('already in use')) {
        statusCode = 401;
      } else {
        statusCode = 404;
      }
    }

    return statusCode;
  }

  static Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e);
    }
  }
}
