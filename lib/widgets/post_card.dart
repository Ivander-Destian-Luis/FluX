import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/models/alert.dart';
import 'package:flux/models/posting.dart';
import 'package:flux/screen/google_maps_screen.dart';
import 'package:flux/screen/profile_screen.dart';
import 'package:flux/services/account_service.dart';
import 'package:flux/services/notification_service.dart';
import 'package:flux/services/post_service.dart';
import 'package:flux/widgets/comment_card.dart';

class PostCard extends StatefulWidget {
  final ColorPallete colorPallete;
  final String uid;
  final Posting post;
  final String? postingImageUrl;

  const PostCard(
      {super.key,
      required this.colorPallete,
      required this.uid,
      required this.post,
      this.postingImageUrl});

  @override
  State<PostCard> createState() => _PostBoxState();
}

class _PostBoxState extends State<PostCard> {
  Account? account;
  bool? _isLiked;
  // bool isFollowing = false;
  bool _isLoading = true;
  bool isBookmarked = false;
  int commentsLength = 0;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    if (widget.post.likes.contains(FirebaseAuth.instance.currentUser!.uid)) {
      setState(() {
        _isLiked = true;
      });
    } else {
      setState(() {
        _isLiked = false;
      });
    }
    commentsLength = await PostService.getCommentsLength(widget.post);
    setState(() {
      commentsLength = commentsLength;
    });
    account ??=
        await AccountService.getAccountByUid(widget.uid).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _notify(String notificationContext) async {
    Alert notif = Alert(
      uid: FirebaseAuth.instance.currentUser!.uid,
      notificationId: null,
      notificationContext: notificationContext,
      notifiedTime: DateTime.now(),
      readBy: [],
    );

    int statusCode = await NotificationService.notify(
        notif, FirebaseAuth.instance.currentUser!.uid);
  }

  // void toggleFollow() async {
  //   if (isFollowing) {
  //     await PostService.unfollow(
  //         FirebaseAuth.instance.currentUser!.uid, widget.post.posterUid!);
  //   } else {
  //     await PostService.follow(
  //         FirebaseAuth.instance.currentUser!.uid, widget.post.posterUid!);
  //   }
  //   setState(() {
  //     isFollowing = !isFollowing;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Container()
        : Container(
            decoration: BoxDecoration(
              color: widget.colorPallete.postBackgroundColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProfileScreen(account: account!)));
                      },
                      child: Row(
                        children: [
                          account!.profilePictureUrl.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                    minRadius: 20,
                                    backgroundImage: NetworkImage(
                                        account!.profilePictureUrl),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                    backgroundImage: widget.colorPallete.logo,
                                    backgroundColor:
                                        widget.colorPallete.backgroundColor,
                                  ),
                                ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    account!.username,
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: widget.colorPallete.fontColor),
                                  ),
                                  Text(
                                    '  ${DateTime.now().difference(widget.post.postedTime).inDays > 0 ? '${DateTime.now().difference(widget.post.postedTime).inDays}d ' : ''}${DateTime.now().difference(widget.post.postedTime).inHours > 0 ? '${DateTime.now().difference(widget.post.postedTime).inHours % 24}h ' : ''}${DateTime.now().difference(widget.post.postedTime).inMinutes > 0 ? "${DateTime.now().difference(widget.post.postedTime).inMinutes % 60}m" : "${DateTime.now().difference(widget.post.postedTime).inSeconds % 60}s"}',
                                    style: TextStyle(
                                      color: widget.colorPallete.fontColor
                                          .withOpacity(0.4),
                                    ),
                                  ),
                                ],
                              ),
                              if (widget.post.location != null) ...[
                                GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                GoogleMapsScreen(
                                                    latitude:
                                                        widget.post.latitude!,
                                                    longitude:
                                                        widget.post.longitude!),
                                          ));
                                    },
                                    child: Text.rich(
                                      TextSpan(
                                          style: TextStyle(
                                              fontSize: 13,
                                              color: widget
                                                  .colorPallete.textLinkColor),
                                          children: [
                                            TextSpan(
                                              text:
                                                  '${widget.post.location} ' ??
                                                      '',
                                            ),
                                            WidgetSpan(
                                              child: Icon(
                                                Icons.pin_drop,
                                                color: widget
                                                    .colorPallete.fontColor,
                                                size: 16,
                                              ),
                                            )
                                          ]),
                                    )),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (widget.post.postingImageUrl != null) ...[
                      if (widget.post.postingImageUrl!.isNotEmpty)
                        GestureDetector(
                          onDoubleTap: () {
                            try {
                              if (!_isLiked! &&
                                  widget.post.posterUid !=
                                      FirebaseAuth.instance.currentUser!.uid) {
                                PostService.like(
                                        FirebaseAuth.instance.currentUser!.uid,
                                        widget.post)
                                    .whenComplete(() {
                                  initialize();
                                  _notify('has liked your post');
                                });
                              }
                            } catch (e) {
                              print("error");
                            }
                          },
                          child: Image.network(widget.post.postingImageUrl!),
                        ),
                    ],
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                      child: Text.rich(TextSpan(
                        children: [
                          TextSpan(
                            text: account!.username,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: widget.colorPallete.fontColor),
                          ),
                          const TextSpan(text: "  "),
                          TextSpan(
                            text: widget.post.postingDescription,
                            style:
                                TextStyle(color: widget.colorPallete.fontColor),
                          ),
                        ],
                      )),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              try {
                                if (_isLiked!) {
                                  PostService.dislike(
                                          FirebaseAuth
                                              .instance.currentUser!.uid,
                                          widget.post)
                                      .whenComplete(() => initialize());
                                } else {
                                  PostService.like(
                                          FirebaseAuth
                                              .instance.currentUser!.uid,
                                          widget.post)
                                      .whenComplete(() {
                                    initialize();
                                    _notify('has liked your post');
                                  });
                                }
                              } catch (e) {
                                print("error");
                              }
                            },
                            child: _isLiked ?? false
                                ? const Icon(Icons.favorite,
                                    color: Colors.red, size: 30)
                                : Icon(Icons.favorite_border,
                                    color: widget.colorPallete.fontColor,
                                    size: 30),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 2, right: 8),
                            child: Text(widget.post.likes.length.toString(),
                                style: TextStyle(
                                    color: widget.colorPallete.fontColor)),
                          ),
                          GestureDetector(
                            onTap: () {
                              TextEditingController commentController =
                                  TextEditingController();
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    List<Widget> children = [];
                                    children.add(
                                      Container(
                                        padding:
                                            const EdgeInsets.only(bottom: 5),
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: widget
                                                  .colorPallete.fontColor
                                                  .withOpacity(0.2),
                                            ),
                                          ),
                                        ),
                                        child: CommentCard(
                                          uid: widget.post.posterUid!,
                                          colorPallete: widget.colorPallete,
                                          comment:
                                              widget.post.postingDescription,
                                        ),
                                      ),
                                    );
                                    widget.post.comments.forEach((key, value) {
                                      for (String comment in value) {
                                        children.add(CommentCard(
                                            uid: key,
                                            colorPallete: widget.colorPallete,
                                            comment: comment));
                                      }
                                    });
                                    return Container(
                                      padding: EdgeInsets.only(
                                          top: 20,
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom),
                                      width: double.infinity,
                                      constraints: const BoxConstraints(
                                        maxHeight: 600,
                                        minHeight: 300,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            widget.colorPallete.backgroundColor,
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              constraints: const BoxConstraints(
                                                maxHeight: 400,
                                              ),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: children,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(13.0),
                                            child: TextField(
                                              controller: commentController,
                                              decoration: InputDecoration(
                                                suffixIcon: IconButton(
                                                  icon: Icon(
                                                      Icons
                                                          .chevron_right_rounded,
                                                      color: widget.colorPallete
                                                          .fontColor),
                                                  onPressed: () {
                                                    if (commentController
                                                        .text.isNotEmpty) {
                                                      PostService.comment(
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser!
                                                                  .uid,
                                                              commentController
                                                                  .text,
                                                              widget.post)
                                                          .whenComplete(() {
                                                        initialize();
                                                        Navigator.of(context)
                                                            .pop();
                                                      });
                                                    }
                                                  },
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  borderSide: BorderSide(
                                                      color: widget.colorPallete
                                                          .fontColor),
                                                ),
                                              ),
                                              onSubmitted: (value) {
                                                if (value.isNotEmpty) {
                                                  PostService.comment(
                                                          FirebaseAuth.instance
                                                              .currentUser!.uid,
                                                          value,
                                                          widget.post)
                                                      .whenComplete(() {
                                                    initialize();
                                                    _notify(
                                                        'has commented on your post');
                                                    Navigator.of(context).pop();
                                                  });
                                                }
                                              },
                                              style: TextStyle(
                                                color: widget
                                                    .colorPallete.fontColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  });
                            },
                            child: Icon(
                              Icons.comment_rounded,
                              color: widget.colorPallete.fontColor,
                              size: 30,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 3, right: 6),
                            child: Text(commentsLength.toString(),
                                style: TextStyle(
                                    color: widget.colorPallete.fontColor)),
                          ),
                          GestureDetector(
                            onTap: () async {
                              setState(() {
                                isBookmarked = !isBookmarked;
                              });

                              try {
                                if (isBookmarked) {
                                  await AccountService.savePost(
                                    FirebaseAuth.instance.currentUser!.uid,
                                    widget.post,
                                  );
                                } else {
                                  await AccountService.removePost(
                                    FirebaseAuth.instance.currentUser!.uid,
                                    widget.post,
                                  );
                                }
                              } catch (e) {
                                print("Error: $e");
                              }
                            },
                            child: Icon(
                              isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_outline,
                              color: widget.colorPallete.fontColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: PopupMenuButton(
                    offset: const Offset(-10, 50),
                    color: widget.colorPallete.postBackgroundColor,
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Post has been reported.'),
                                content: const Text('You reported this post!'),
                                actions: [
                                  TextButton(
                                    child: Text('OK'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text(
                          'Report',
                          style:
                              TextStyle(color: widget.colorPallete.fontColor),
                        ),
                      ),
                    ],
                    iconColor: widget.colorPallete.fontColor,
                  ),
                ),
              ],
            ),
          );
  }
}
