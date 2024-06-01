import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/models/posting.dart';
import 'package:flux/screen/profile_screen.dart';
import 'package:flux/services/account_service.dart';
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
  bool isFollowing = false;
  bool _isLoading = true;
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
    if (widget.uid != FirebaseAuth.instance.currentUser!.uid) {
      isFollowing = await PostService.isFollowing(
          FirebaseAuth.instance.currentUser!.uid, widget.post.posterUid!);
    }
    setState(() {
      isFollowing = isFollowing;
    });
  }

  void toggleFollow() async {
    if (isFollowing) {
      await PostService.unfollow(
          FirebaseAuth.instance.currentUser!.uid, widget.post.posterUid!);
    } else {
      await PostService.follow(
          FirebaseAuth.instance.currentUser!.uid, widget.post.posterUid!);
    }
    setState(() {
      isFollowing = !isFollowing;
    });
  }

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
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(account!.profilePictureUrl),
                                )
                              : const CircleAvatar(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    account!.username,
                                    style: TextStyle(
                                        color: widget.colorPallete.fontColor),
                                  ),
                                  const SizedBox(width: 4),
                                  if (widget.uid !=
                                      FirebaseAuth.instance.currentUser!.uid)
                                    TextButton(
                                      onPressed: toggleFollow,
                                      child: Text(
                                          isFollowing ? 'Unfollow' : 'Follow'),
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            widget.colorPallete.textLinkColor,
                                      ),
                                    ),
                                ],
                              ),
                              Text(
                                '${DateTime.now().difference(widget.post.postedTime).inDays > 0 ? '${DateTime.now().difference(widget.post.postedTime).inDays}d ' : ''}${DateTime.now().difference(widget.post.postedTime).inHours > 0 ? '${DateTime.now().difference(widget.post.postedTime).inHours % 24}h ' : ''}${DateTime.now().difference(widget.post.postedTime).inMinutes > 0 ? "${DateTime.now().difference(widget.post.postedTime).inMinutes % 60}m" : "${DateTime.now().difference(widget.post.postedTime).inSeconds % 60}s"}',
                                style: TextStyle(
                                  color: widget.colorPallete.fontColor
                                      .withOpacity(0.4),
                                ),
                              ),
                              Text(
                                widget.post.location ?? '',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: widget.colorPallete.textLinkColor),
                              ),
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
                                    .whenComplete(() => initialize());
                              }
                            } catch (e) {
                              print("error");
                            }
                          },
                          child: Image.network(widget.post.postingImageUrl!),
                        ),
                    ],
                    Text.rich(TextSpan(
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
                    Row(
                      children: [
                        Column(
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
                                        .whenComplete(() => initialize());
                                  }
                                } catch (e) {
                                  print("error");
                                }
                              },
                              child: _isLiked ?? false
                                  ? const Icon(Icons.favorite,
                                      color: Colors.red)
                                  : Icon(Icons.favorite_border,
                                      color: widget.colorPallete.fontColor),
                            ),
                            Text(widget.post.likes.length.toString(),
                                style: TextStyle(
                                    color: widget.colorPallete.fontColor)),
                          ],
                        ),
                        Column(
                          children: [
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
                                      widget.post.comments
                                          .forEach((key, value) {
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
                                          color: widget
                                              .colorPallete.backgroundColor,
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
                                                constraints:
                                                    const BoxConstraints(
                                                  maxHeight: 400,
                                                ),
                                                child: SingleChildScrollView(
                                                  child: Column(
                                                    children: children,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            TextField(
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
                                                    Navigator.of(context).pop();
                                                  });
                                                }
                                              },
                                              style: TextStyle(
                                                color: widget
                                                    .colorPallete.fontColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                              },
                              child: Icon(Icons.comment_rounded,
                                  color: widget.colorPallete.fontColor),
                            ),
                            Text(commentsLength.toString(),
                                style: TextStyle(
                                    color: widget.colorPallete.fontColor)),
                          ],
                        ),
                        GestureDetector(
                          child: Icon(Icons.share,
                              color: widget.colorPallete.fontColor),
                        ),
                        GestureDetector(
                          child: Icon(Icons.bookmark,
                              color: widget.colorPallete.fontColor),
                        ),
                      ],
                    ),
                  ],
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [],
                  iconColor: widget.colorPallete.fontColor,
                ),
              ],
            ),
          );
  }
}
