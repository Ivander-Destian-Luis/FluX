import 'package:flutter/material.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/services/account_service.dart';

class CommentCard extends StatefulWidget {
  final String uid;
  final String comment;
  final ColorPallete colorPallete;
  const CommentCard(
      {super.key,
      required this.uid,
      required this.colorPallete,
      required this.comment});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  Account? account;

  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    initialize();
  }

  void initialize() async {
    account = await AccountService.getAccountByUid(widget.uid).whenComplete(() {
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            child: Row(
              children: [
                if (widget.comment.isNotEmpty) ...[
                  account!.profilePictureUrl.isNotEmpty
                      ? CircleAvatar(
                          backgroundImage:
                              NetworkImage(account!.profilePictureUrl),
                        )
                      : CircleAvatar(
                          backgroundImage: widget.colorPallete.logo,
                          backgroundColor:
                              widget.colorPallete.postBackgroundColor,
                        ),
                  const SizedBox(width: 10),
                  Text(
                    account!.username,
                    style: TextStyle(
                      color: widget.colorPallete.fontColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.comment,
                    style: TextStyle(
                      color: widget.colorPallete.fontColor,
                    ),
                  ),
                ],
                if (widget.comment.isEmpty) Container(),
              ],
            ),
          );
  }
}
