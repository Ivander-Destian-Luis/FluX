import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/screen/home_screen.dart';
import 'package:flux/screen/profile_screen.dart';
import 'package:flux/services/account_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      Account? followersAccount = await AccountService.getAccountByUid(uid);
      if (followersAccount != null) {
        accounts.add(followersAccount);
      }
    }
    setState(() {
      followersAccounts = accounts;
    });
  }

  void navigateToProfile(Account account) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          account: account,
          selectPosted: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: colorPallete.backgroundColor,
            appBar: AppBar(
              backgroundColor: colorPallete.backgroundColor,
              title: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  'Followers',
                  style: TextStyle(
                    color: colorPallete.fontColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
              automaticallyImplyLeading: false,
            ),
            body: followersAccounts.isEmpty
                ? Center(
                    child: Text(
                      'Oops! You don\'t have any followers',
                      style: TextStyle(
                          color: colorPallete.fontColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: followersAccounts.length,
                          itemBuilder: (context, index) {
                            final account = followersAccounts[index];
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
