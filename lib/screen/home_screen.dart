import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/models/posting.dart';
import 'package:flux/services/account_service.dart';
import 'package:flux/services/post_service.dart';
import 'package:flux/widgets/post_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ColorPallete colorPallete;
  late Account account;
  late SharedPreferences prefs;
  bool _isLoading = true;

  void initialize() async {
    prefs = await SharedPreferences.getInstance().then((value) async {
      colorPallete = value.getBool('isDarkMode') ?? false
          ? DarkModeColorPallete()
          : LightModeColorPallete();

      account = (await AccountService.getAccountByUid(
          FirebaseAuth.instance.currentUser!.uid))!;

      setState(() {
        _isLoading = false;
      });
      return value;
    });
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
            appBar: AppBar(
              backgroundColor: colorPallete.backgroundColor,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image(
                    image: colorPallete.logo,
                    fit: BoxFit.contain,
                    height: 48,
                  ),
                ],
              ),
              automaticallyImplyLeading: false,
            ),
            body: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StreamBuilder(
                      stream: PostService.getPostingList(),
                      builder: (context, snapshot) {
                        List<Posting> posts =
                            (snapshot.data ?? List<Posting>.empty());
                        List<Widget> postingBoxes = [];
                        for (Posting post in posts) {
                          if (account.followings.contains(post.posterUid) ||
                              post.posterUid ==
                                  FirebaseAuth.instance.currentUser!.uid) {
                            postingBoxes.add(PostCard(
                              colorPallete: colorPallete,
                              uid: post.posterUid!,
                              post: post,
                              profileEnabled: true,
                            ));
                            postingBoxes.add(const SizedBox(height: 10));
                          }
                        }
                        if (postingBoxes.isEmpty) {
                          postingBoxes.add(const SizedBox(height: 10));
                          postingBoxes.add(Center(
                              child: Text(
                            'Navigate to the Browse Screen to Browse for other User',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorPallete.fontColor),
                          )));
                        }
                        return ListView(
                          children: postingBoxes,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
  }
}
