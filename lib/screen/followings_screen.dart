import 'package:flutter/material.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/screen/profile_screen.dart';
import 'package:flux/services/account_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FollowingsScreen extends StatefulWidget {
  final Account account;
  const FollowingsScreen({super.key, required this.account});

  @override
  State<FollowingsScreen> createState() => _FollowingsScreenState();
}

class _FollowingsScreenState extends State<FollowingsScreen> {
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
            appBar: AppBar(
              backgroundColor: colorPallete.backgroundColor,
              title: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Text(
                  'Followings',
                  style: TextStyle(
                    color: colorPallete.fontColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                ),
              ),
              automaticallyImplyLeading: false,
            ),
            body: followingAccounts.isEmpty
                ? Center(
                    child: Text(
                      'Follow other users!',
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
