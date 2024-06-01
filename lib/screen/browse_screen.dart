import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/models/posting.dart';
import 'package:flux/services/account_service.dart';
import 'package:flux/services/post_service.dart';
import 'package:flux/widgets/post_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  late ColorPallete colorPallete;
  late Account account;
  Account? acc;
  late SharedPreferences prefs;
  bool _isLoading = true;
  String searchResult = '';

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

  void getUsername(uid) async {
    acc ??= await AccountService.getAccountByUid(uid);
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              backgroundColor: colorPallete.backgroundColor,
              title: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: colorPallete.textFieldBackgroundColor,
                ),
                child: TextField(
                  onChanged: (value) => setState(() {
                    searchResult = value;
                  }),
                  autofocus: false,
                  decoration: const InputDecoration(
                    hintText: 'Find user...',
                    prefixIcon: Icon(Icons.search),
                    //implementasi clear input
                    border: InputBorder.none,
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  style: TextStyle(
                    color: colorPallete.fontColor,
                  ),
                ),
              ),
              automaticallyImplyLeading: false,
            ),
            backgroundColor: colorPallete.backgroundColor,
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: PostService.getPostingList(),
                    builder: (context, snapshot) {
                      // ignore: unnecessary_cast
                      List<Posting> posts = (snapshot.data ??
                          List<Posting>.empty()) as List<Posting>;
                      List<Widget> postingBoxes = [];
                      for (Posting post in posts) {
                        getUsername(post.posterUid);
                        postingBoxes.add(PostCard(
                          colorPallete: colorPallete,
                          uid: post.posterUid!,
                          post: post,
                        ));
                        postingBoxes.add(const SizedBox(height: 10));
                      }
                      return ListView(
                        children: postingBoxes,
                      );
                    },
                  ),
                ),
              ],
            ));
  }
}
