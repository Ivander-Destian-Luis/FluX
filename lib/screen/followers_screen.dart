import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/screen/home_screen.dart';
import 'package:flux/screen/launch_app_screen.dart';
import 'package:flux/screen/login_screen.dart';
import 'package:flux/screen/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class FollowersScreen extends StatefulWidget {
  final Account account;

  const FollowersScreen({super.key, required this.account});

  @override
  State<FollowersScreen> createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  late ColorPallete colorPallete;
  late Account account;
  late SharedPreferences prefs;
  bool _isLoading = true;
  List<Account> followersAccounts = [];

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

    await fetchfollowersAccounts();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchfollowersAccounts() async {
    List<Account> accounts = [];
    for (String uid in account.followers) {
      Account? followersAccount = await getAccountByUid(uid);
      if (followersAccount != null) {
        accounts.add(followersAccount);
      }
    }
    setState(() {
      followersAccounts = accounts;
    });
  }

  Future<Account?> getAccountByUid(String uid) async {
    return await Future.delayed(const Duration(seconds: 1), () {
      return Account(
        bio: '',
        followers: [],
        phoneNumber: '',
        posts: 0,
        username: 'Username $uid',
        profilePictureUrl: 'https://example.com/profileImage/$uid.png',
        followings: [],
      );
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
                    'Followers',
                    style: TextStyle(
                      fontSize: 32,
                      color: colorPallete.fontColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: followersAccounts.length,
                    itemBuilder: (context, index) {
                      final account = followersAccounts[index];
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
