import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/models/posting.dart';
import 'package:flux/screen/edit_data_screen.dart';
import 'package:flux/screen/followers_screen.dart';
import 'package:flux/screen/followings_screen.dart';
import 'package:flux/services/account_service.dart';
import 'package:flux/services/authentication_service.dart';
import 'package:flux/services/post_service.dart';
import 'package:flux/widgets/post_card.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  final Account account;

  const ProfileScreen({super.key, required this.account});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ColorPallete colorPallete;
  late SharedPreferences prefs;
  late Account comerAccount;
  late Account ownerAccount;
  late Account posterAccount;
  late String _accountUid;
  late String _targetUid;

  bool _isLoading = true;
  String selectedOption = "posted";

  @override
  void initState() {
    super.initState();
    ownerAccount = widget.account;
    initialize();
  }

  void initialize() async {
    prefs = await SharedPreferences.getInstance().then((value) async {
      colorPallete = value.getBool('isDarkMode') ?? false
          ? DarkModeColorPallete()
          : LightModeColorPallete();
      comerAccount = (await AccountService.getAccountByUid(
          FirebaseAuth.instance.currentUser!.uid))!;
      _accountUid = FirebaseAuth.instance.currentUser!.uid;
      _targetUid =
          (await AccountService.getUidByUsername(ownerAccount.username))!;
      ownerAccount = (await AccountService.getAccountByUid(_targetUid))!;

      setState(() {
        _isLoading = false;
        ownerAccount = ownerAccount;
      });
      return value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            backgroundColor: colorPallete.backgroundColor,
            body: Padding(
              padding: const EdgeInsets.only(top: 40.0, right: 8, left: 8),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10, top: 10),
                            child: ownerAccount.profilePictureUrl.isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        ownerAccount.profilePictureUrl),
                                    radius: 60,
                                  )
                                : CircleAvatar(
                                    backgroundImage: colorPallete.logo,
                                    backgroundColor:
                                        colorPallete.postBackgroundColor,
                                    radius: 60,
                                  ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, bottom: 10, top: 10),
                                child: Text(ownerAccount.username,
                                    style: TextStyle(
                                        color: colorPallete.fontColor,
                                        fontSize: 20)),
                              ),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => FollowersScreen(
                                            account: ownerAccount,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Text(
                                              ownerAccount.followers.length
                                                  .toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: colorPallete.fontColor,
                                                  fontSize: 15)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Text('Followers',
                                              style: TextStyle(
                                                  color: colorPallete.fontColor,
                                                  fontSize: 15)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              FollowingsScreen(
                                            account: ownerAccount,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(left: 20),
                                          child: Text(
                                              ownerAccount.followings.length
                                                  .toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: colorPallete.fontColor,
                                                  fontSize: 15)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(left: 20),
                                          child: Text('Followings',
                                              style: TextStyle(
                                                  color: colorPallete.fontColor,
                                                  fontSize: 15)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: Text(
                                            ownerAccount.posts.toString(),
                                            style: TextStyle(
                                                color: colorPallete.fontColor,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: Text('Posts',
                                            style: TextStyle(
                                                color: colorPallete.fontColor,
                                                fontSize: 15)),
                                      ),
                                    ],
                                  ),
                                ],
                              )
                            ],
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20, top: 10, bottom: 10),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text.rich(
                            TextSpan(
                                text: ownerAccount.bio,
                                style: TextStyle(
                                    color: colorPallete.fontColor,
                                    fontSize: 15)),
                          ),
                        ),
                      ),
                      if (comerAccount.username == ownerAccount.username)
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => EditDataScreen(
                                  usernameProfile: ownerAccount.username,
                                  phoneNumberProfile: ownerAccount.phoneNumber,
                                  bioProfile: ownerAccount.bio,
                                  imageLinkProfile:
                                      ownerAccount.profilePictureUrl),
                            ));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 130),
                            decoration: BoxDecoration(
                              color: colorPallete.buttonColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Edit Profile',
                              style: TextStyle(
                                  color: colorPallete.fontColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                          ),
                        ),
                      if (comerAccount.username != ownerAccount.username) ...[
                        if (ownerAccount.followers.contains(_accountUid))
                          GestureDetector(
                            onTap: () {
                              AccountService.unfollow(_accountUid, _targetUid)
                                  .whenComplete(
                                () {
                                  initialize();
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 120),
                              decoration: BoxDecoration(
                                color: colorPallete.buttonColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Unfollow',
                                style: TextStyle(
                                    color: colorPallete.fontColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17),
                              ),
                            ),
                          ),
                        if (!ownerAccount.followers.contains(_accountUid))
                          GestureDetector(
                            onTap: () {
                              AccountService.follow(_accountUid, _targetUid)
                                  .whenComplete(
                                () {
                                  initialize();
                                },
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 120),
                              decoration: BoxDecoration(
                                color: colorPallete.buttonColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                !ownerAccount.followings.contains(_accountUid)
                                    ? 'Follow'
                                    : 'Follow Back',
                                style: TextStyle(
                                    color: colorPallete.fontColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17),
                              ),
                            ),
                          ),
                      ],
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedOption = "posted";
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Text(
                                'Posted',
                                style: TextStyle(
                                  color: colorPallete.fontColor,
                                  fontWeight: selectedOption == "posted"
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedOption = "liked";
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(top: 15),
                              child: Text(
                                'Liked',
                                style: TextStyle(
                                  color: colorPallete.fontColor,
                                  fontWeight: selectedOption == "liked"
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: Divider(
                          color: colorPallete.borderColor,
                        ),
                      ),
                      if (selectedOption == 'posted') ...[
                        Expanded(
                          child: StreamBuilder(
                            stream: PostService.getPostingList(),
                            builder: (context, snapshot) {
                              // ignore: unnecessary_cast
                              List<Posting> posts = (snapshot.data ??
                                  List<Posting>.empty()) as List<Posting>;
                              List<Widget> postingBoxes = [];
                              for (Posting post in posts) {
                                if (post.posterUid == _targetUid) {
                                  postingBoxes.add(PostCard(
                                    colorPallete: colorPallete,
                                    uid: post.posterUid!,
                                    post: post,
                                  ));
                                  postingBoxes.add(const SizedBox(height: 10));
                                }
                              }
                              return ListView(
                                children: postingBoxes,
                              );
                            },
                          ),
                        )
                      ] else if (selectedOption == 'liked') ...[
                        Expanded(
                          child: StreamBuilder(
                            stream: PostService.getPostingList(),
                            builder: (context, snapshot) {
                              // ignore: unnecessary_cast
                              List<Posting> posts = (snapshot.data ??
                                  List<Posting>.empty()) as List<Posting>;
                              List<Widget> postingBoxes = [];
                              for (Posting post in posts) {
                                if (post.likes.contains(_targetUid)) {
                                  postingBoxes.add(PostCard(
                                      colorPallete: colorPallete,
                                      uid: post.posterUid!,
                                      post: post));
                                  postingBoxes.add(const SizedBox(height: 10));
                                }
                              }
                              return ListView(
                                children: postingBoxes,
                              );
                            },
                          ),
                        )
                      ]
                    ],
                  ),
                  PopupMenuButton(
                    iconColor: colorPallete.fontColor,
                    offset: const Offset(-10, 50),
                    color: colorPallete.postBackgroundColor,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () {
                          Navigator.pushNamed(context, '/settings')
                              .then((_) => setState(() {
                                    initialize();
                                  }));
                        },
                        child: Text(
                          'Settings',
                          style: TextStyle(color: colorPallete.fontColor),
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () {
                          Navigator.pushNamed(context, '/saved')
                              .then((_) => setState(() {
                                    initialize();
                                  }));
                        },
                        child: Text(
                          'Saved Post',
                          style: TextStyle(color: colorPallete.fontColor),
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () async {
                          await AuthenticationService.logout().whenComplete(() {
                            Navigator.pushNamedAndRemoveUntil(
                                context, '/login', (route) => false);
                          });
                        },
                        child: Text(
                          'Logout',
                          style: TextStyle(color: colorPallete.fontColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}
