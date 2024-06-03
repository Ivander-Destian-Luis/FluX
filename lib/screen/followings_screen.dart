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
  List<Account> followingAccounts = [];

  @override
  void initState() {
    super.initState();
    account = widget.account;
    initialize();
  }

  void initialize() async {
    prefs = await SharedPreferences.getInstance();
    colorPallete = prefs.getBool('isDarkMode') ?? false
        ? DarkModeColorPallete()
        : LightModeColorPallete();

    await fetchFollowingAccounts();
    setState(() {
      _isLoading = false;
    });
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

  void navigateToProfile(Account account) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(account: account),
      ),
    );
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
                Padding(
                  padding:
                      const EdgeInsets.only(top: 60.0, left: 30.0, right: 30.0),
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
                        leading: GestureDetector(
                          onTap: () => navigateToProfile(account),
                          child: CircleAvatar(
                            backgroundImage:
                                NetworkImage(account.profilePictureUrl),
                          ),
                        ),
                        title: GestureDetector(
                          onTap: () => navigateToProfile(account),
                          child: Text(account.username),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
  }
}
