import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/services/authentication_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flux/services/account_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  String _errorTextForEmail = '';
  String _errorTextForPassword = '';
  String _errorTextForConfirmPassword = '';
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late ColorPallete colorPallete;
  late Account account;
  late SharedPreferences prefs;
  bool _isLoading = true;

  void initialize() async {
    prefs = await SharedPreferences.getInstance().then((value) async {
      colorPallete = value.getBool('isDarkMode') ?? false
          ? DarkModeColorPallete()
          : LightModeColorPallete();

      setState(() {
        _isLoading = false;
      });
      return value;
    });
  }

  void _register() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (password.length < 8) {
      setState(() {
        _errorTextForPassword = 'Minimal 8 Karakter !';
      });
      return;
    } else if (!password.contains(RegExp(r'[A-Z]'))) {
      setState(() {
        _errorTextForPassword = 'Harus mempunyai huruf Kapital !';
      });
      return;
    } else if (password != confirmPassword) {
      setState(() {
        _errorTextForConfirmPassword = 'Invalid Credential';
      });
      return;
    } else {
      setState(() {
        _errorTextForConfirmPassword = '';
        _errorTextForPassword = '';
      });
    }

    if (!email.contains(RegExp(r'[@]'))) {
      setState(() {
        _errorTextForEmail = 'Harus berbentuk Email !';
      });
      return;
    } else {
      setState(() {
        _errorTextForEmail = '';
      });
    }

    if (email.isNotEmpty && password.isNotEmpty) {
      int statusCode = await AuthenticationService.register(email, password);
      if (statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/input_data');
      } else if (statusCode == 401) {
        setState(() {
          _errorTextForEmail = 'Email telah digunakan!';
        });
      } else {
        setState(() {
          _errorTextForEmail = 'Error ditemukan!';
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: colorPallete.backgroundColor,
            body: ListView(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: 140,
                    left: 20,
                  ),
                  child: Text(
                    'Create New     Account',
                    style:
                        TextStyle(fontSize: 45, color: colorPallete.fontColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: TextFormField(
                    style: TextStyle(color: colorPallete.fontColor),
                    controller: _emailController,
                    decoration: InputDecoration(
                        filled: true,
                        errorText: _errorTextForEmail.isNotEmpty
                            ? _errorTextForEmail
                            : null,
                        hintText: 'Masukkan Email...',
                        hintStyle: TextStyle(color: colorPallete.fontColor),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        fillColor: colorPallete.backgroundColor),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                  child: TextFormField(
                    style: TextStyle(color: colorPallete.fontColor),
                    obscureText: _obscurePassword,
                    controller: _passwordController,
                    decoration: InputDecoration(
                      errorText: _errorTextForPassword.isNotEmpty
                          ? _errorTextForPassword
                          : null,
                      hintText: 'Masukkan Password...',
                      hintStyle: TextStyle(color: colorPallete.fontColor),
                      filled: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      fillColor: colorPallete.backgroundColor,
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(_obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 20, right: 20),
                  child: TextFormField(
                    style: TextStyle(color: colorPallete.fontColor),
                    obscureText: _obscureConfirmPassword,
                    controller: _confirmPasswordController,
                    decoration: InputDecoration(
                      filled: true,
                      errorText: _errorTextForConfirmPassword.isNotEmpty
                          ? _errorTextForConfirmPassword
                          : null,
                      hintText: 'Masukkan Ulang Password...',
                      hintStyle: TextStyle(color: colorPallete.fontColor),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20)),
                      fillColor: colorPallete.backgroundColor,
                      suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(_obscureConfirmPassword
                              ? Icons.visibility_off
                              : Icons.visibility)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 20),
                  child: InkWell(
                    child: const Text(
                      'Already Have Account ?',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 30, right: 30),
                  child: ElevatedButton(
                      onPressed: () {
                        _register();
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: colorPallete.backgroundColor,
                          fixedSize: const Size(300, 60)),
                      child: Text(
                        'Register Now',
                        style: TextStyle(
                            color: colorPallete.fontColor, fontSize: 20),
                      )),
                ),
              ],
            ),
          );
  }
}
