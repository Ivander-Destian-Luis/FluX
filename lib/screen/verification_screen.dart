import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/services/authentication_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  _VerificationScreenState createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _previousPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _errorMessage;
  late ColorPallete colorPallete;
  late SharedPreferences prefs;
  bool _obscurePassword = true;
  bool _isLoading = true;
  String _errorText = '';

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      colorPallete = prefs.getBool('isDarkMode') ?? false
          ? DarkModeColorPallete()
          : LightModeColorPallete();
      _isLoading = false;
    });
  }

  Future<void> _sendPasswordResetEmail() async {
    try {
      int statusCode = await AuthenticationService.register(
          _emailController.text, 'randomAja');

      print(statusCode);

      if (statusCode == 401) {
        await _auth.sendPasswordResetEmail(email: _emailController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!')),
        );
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      } else {
        await FirebaseAuth.instance.currentUser!.delete();
        setState(() {
          _errorMessage = 'Email tidak ditemukan, silahkan coba lagi.';
        });
      }
    } catch (e) {
      await FirebaseAuth.instance.currentUser!.delete();
      setState(() {
        _errorMessage = 'Email tidak ditemukan, silahkan coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: colorPallete.backgroundColor,
            body: ListView(
              physics: const NeverScrollableScrollPhysics(),
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 250, left: 30.0, right: 30.0, bottom: 10),
                      child: Text('Email',
                          style: TextStyle(
                              fontSize: 18,
                              color: colorPallete.fontColor,
                              fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: TextFormField(
                        controller: _emailController,
                        style: TextStyle(color: colorPallete.fontColor),
                        decoration: InputDecoration(
                          errorText: _errorMessage,
                          border: const UnderlineInputBorder(
                              borderSide: BorderSide()),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 30.0),
                      child: Center(
                        child: ElevatedButton(
                          onPressed: _sendPasswordResetEmail,
                          style: ElevatedButton.styleFrom(
                              backgroundColor: colorPallete.backgroundColor,
                              fixedSize: const Size(250, 50),
                              side: BorderSide(
                                  color: colorPallete.fontColor, width: 2)),
                          child: Text(
                            'Send Verification Email',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorPallete.fontColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
  }
}
