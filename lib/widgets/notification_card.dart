import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/models/alert.dart';
import 'package:flux/screen/profile_screen.dart';
import 'package:flux/services/account_service.dart';
import 'package:flux/services/notification_service.dart';
import 'package:flux/services/post_service.dart';
import 'package:flux/widgets/comment_card.dart';

class NotificationCard extends StatefulWidget {
  final ColorPallete colorPallete;
  final String uid;
  final Alert notif;

  const NotificationCard(
      {super.key,
      required this.colorPallete,
      required this.uid,
      required this.notif});

  @override
  State<NotificationCard> createState() => _PostBoxState();
}

class _PostBoxState extends State<NotificationCard> {
  Account? account;
  bool? _isRead;

  bool _isLoading = true;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initialize();
  }

  void initialize() async {
    if (widget.notif.readBy.contains(FirebaseAuth.instance.currentUser!.uid)) {
      setState(() {
        _isRead = true;
      });
    } else {
      setState(() {
        _isRead = false;
      });
    }

    account ??= await AccountService.getAccountByUid(widget.uid);
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return (_isLoading || _isRead!)
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
                                    backgroundImage: NetworkImage(
                                        account!.profilePictureUrl),
                                  ),
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CircleAvatar(
                                    backgroundImage: widget.colorPallete.logo,
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
                                        color: widget.colorPallete.fontColor),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${DateTime.now().difference(widget.notif.notifiedTime).inDays > 0 ? '${DateTime.now().difference(widget.notif.notifiedTime).inDays}d ' : ''}${DateTime.now().difference(widget.notif.notifiedTime).inHours > 0 ? '${DateTime.now().difference(widget.notif.notifiedTime).inHours % 24}h ' : ''}${DateTime.now().difference(widget.notif.notifiedTime).inMinutes > 0 ? "${DateTime.now().difference(widget.notif.notifiedTime).inMinutes % 60}m" : "${DateTime.now().difference(widget.notif.notifiedTime).inSeconds % 60}s"}',
                                    style: TextStyle(
                                      color: widget.colorPallete.fontColor
                                          .withOpacity(0.4),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                widget.notif.notificationContext,
                                style: TextStyle(
                                    color: widget.colorPallete.borderColor),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    try {
                      NotificationService.read(
                              FirebaseAuth.instance.currentUser!.uid,
                              widget.notif)
                          .whenComplete(() => initialize());
                    } catch (e) {
                      print("error");
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child:
                        Icon(Icons.close, color: widget.colorPallete.fontColor),
                  ),
                ),
              ],
            ),
          );
  }
}
