import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/models/posting.dart';
import 'package:flux/screen/profile_screen.dart';
import 'package:flux/services/account_service.dart';
import 'package:flux/services/post_service.dart';
import 'package:flux/widgets/comment_card.dart';

class UserCard extends StatefulWidget {
  final ColorPallete colorPallete;
  final String uid;

  const UserCard(
      {super.key,
      required this.colorPallete,
      required this.uid,
      });

  @override
  State <UserCard> createState() => _PostBoxState();
}

class _PostBoxState extends State <UserCard> {
  Account? account;
  bool? _isLiked;

  bool _isLoading = true;
  int commentsLength = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialize();
  }

  void initialize() async {
    account ??=
        await AccountService.getAccountByUid(widget.uid).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
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
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (context) =>
                        //             ProfileScreen(account: account!)));
                      },
                      child: Row(
                        children: [
                          account!.profilePictureUrl.isNotEmpty
                              ? CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(account!.profilePictureUrl),
                                )
                              : const CircleAvatar(),
                          Text(
                            account!.username,
                            style:
                                TextStyle(color: widget.colorPallete.fontColor),
                          ),
                          Text(
                            '1h',
                            style: TextStyle(
                              color: widget.colorPallete.fontColor
                                  .withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Column(
                          children: [
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
