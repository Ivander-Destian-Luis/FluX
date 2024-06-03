import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/models/posting.dart';
import 'package:flux/services/post_service.dart';
import 'package:flux/widgets/post_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  late ColorPallete colorPallete;
  late Account account;
  late SharedPreferences prefs;
  bool _isLoading = true;
  List<Widget> _children = [];

  void initialize() async {
    prefs = await SharedPreferences.getInstance().then((value) async {
      colorPallete = value.getBool('isDarkMode') ?? false
          ? DarkModeColorPallete()
          : LightModeColorPallete();

      for (Posting post in await PostService.getSavedPost(
          FirebaseAuth.instance.currentUser!.uid)) {
        _children.add(PostCard(
            colorPallete: colorPallete,
            uid: post.posterUid!,
            post: post,
            profileEnabled: true));
      }

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
              title: Text(
                'Saved Post',
                style: TextStyle(color: colorPallete.fontColor),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: colorPallete.fontColor),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              backgroundColor: colorPallete.backgroundColor,
            ),
            body: ListView(
              children: _children,
            ),
          );
  }
}
