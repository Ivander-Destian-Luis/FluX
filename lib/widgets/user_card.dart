import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/models/posting.dart';
import 'package:flux/screen/profile_screen.dart';
import 'package:flux/services/account_service.dart';
import 'package:flux/services/post_service.dart';
import 'package:flux/widgets/comment_card.dart';

class UserCard extends StatefulWidget {
  final ColorPallete colorPallete;
  final Account account;

  const UserCard({
    super.key,
    required this.colorPallete,
    required this.account,
  });

  @override
  State<UserCard> createState() => _PostBoxState();
}

class _PostBoxState extends State<UserCard> {
  Account? account;

  bool _isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialize();
  }

  void initialize() async {
    account = widget.account;
    setState(() {
      _isLoading = false;
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
              alignment: Alignment.centerRight,
              children: [
                Column(
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
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          account!.profilePictureUrl.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                    backgroundImage: NetworkImage(
                                        account!.profilePictureUrl),
                                  ),
                                )
                              : const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircleAvatar(),
                                ),
                          Column(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    account!.username,
                                    style: TextStyle(
                                        color: widget.colorPallete.fontColor),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
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
