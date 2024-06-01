import 'package:flutter/widgets.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
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
                        if (account.followings.contains(post.posterUid) ||
                            post.posterUid ==
                                FirebaseAuth.instance.currentUser!.uid) {
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
            ));
  }
}
