import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/screen/home_screen.dart';
import 'package:flux/screen/profile_screen.dart';
import 'package:flux/services/account_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FollowingScreen extends StatefulWidget {
  final Account account;
  const FollowingScreen({super.key, required this.account});

  @override
  State<FollowingScreen> createState() => _FollowingScreenState();
}

class _FollowingScreenState extends State<FollowingScreen> {
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

  List<Account> followingAccounts = [];

  @override
  void initState() {
    super.initState();
    account = widget.account;
    initialize();
  }

  Future<void> fetchFollowingAccounts() async {
    List<Account> accounts = [];
    for (String uid in account.followings) {
      Account? followingAccount = await AccountService.getAccountByUid(uid);
      if (followingAccount != null) {
        accounts.add(followingAccount);
      }
    }
    setState(() {
      followingAccounts = accounts;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: colorPallete.backgroundColor,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.chevron_left,
                        color: colorPallete.fontColor,
                        size: 40,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                  child: Text(
                    'Followings',
                    style: TextStyle(
                      fontSize: 32,
                      color: colorPallete.fontColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: followingAccounts.length,
                    itemBuilder: (context, index) {
                      final account = followingAccounts[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage:
                              NetworkImage(account.profilePictureUrl),
                        ),
                        title: Text(account.username),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }
}