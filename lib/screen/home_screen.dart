import 'package:flutter/material.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/models/posting.dart';
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
                    child: StreamBuilder(
                      stream: PostService.getPostingList(),
                      builder: (context, snapshot) {
                        // ignore: unnecessary_cast
                        List<Posting> posts = (snapshot.data ??
                            List<Posting>.empty()) as List<Posting>;
                        List<Widget> postingBoxes = [];
                        for (Posting post in posts) {
                          if (account.followings.contains(post.posterUid)) {
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
                  ),
                ],
              )
          );
  }
}
