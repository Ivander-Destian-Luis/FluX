import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flux/color_pallete.dart';
import 'package:flux/models/account.dart';
import 'package:flux/models/alert.dart';
import 'package:flux/services/account_service.dart';
import 'package:flux/services/notification_service.dart';
import 'package:flux/widgets/notification_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  late ColorPallete colorPallete;
  late Account account;
  late SharedPreferences prefs;
  bool _isLoading = true;

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
                  Text(
                    style:
                        TextStyle(color: colorPallete.fontColor, fontSize: 30),
                    'Notification',
                  )
                ],
              ),
              automaticallyImplyLeading: false,
            ),
            body: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 14),
                    child: StreamBuilder(
                      stream: NotificationService.getNotificationList(),
                      builder: (context, snapshot) {
                        // ignore: unnecessary_cast
                        List<Alert> notifications = (snapshot.data ??
                            List<Alert>.empty()) as List<Alert>;
                        List<Widget> notificationBoxes = [];
                        for (Alert notification in notifications) {
                          if (account.followings.contains(notification.uid)) {
                            notificationBoxes.add(NotificationCard(
                              colorPallete: colorPallete,
                              uid: notification.uid,
                              notif: notification,
                            ));
                            notificationBoxes.add(const SizedBox(height: 10));
                          }
                        }
                        return ListView(
                          children: notificationBoxes,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ));
  }
}
