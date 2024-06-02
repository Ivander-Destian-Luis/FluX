import 'package:firebase_database/firebase_database.dart';
import 'package:flux/models/alert.dart';

class NotificationService {
  static final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('notification_list');

  static Stream<List<Alert>> getNotificationList() {
    return _database.onValue.map((event) {
      List<Alert> items = [];
      DataSnapshot snapshot = event.snapshot;
      try {
        if (snapshot.value != null) {
          Map<Object?, Object?> listData =
              snapshot.value as Map<Object?, Object?>;
          listData.forEach((key, value) {
            final data = value as Map<Object?, Object?>;
            Map<String, dynamic> notificationData = {};
            bool readExist = false;
            data.forEach((key, value) {
              if (key.toString() == 'read_by') {
                readExist = true;
                final dataReads = value as List<Object?>;
                List<String> readBy = [];
                for (var read in dataReads) {
                  readBy.add(read.toString());
                }
                notificationData[key.toString()] = readBy;
              } else {
                notificationData[key.toString()] = value;
              }
            });

            if (!readExist) {
              notificationData['read_by'] = List<String>.empty();
            }

            notificationData['notification_id'] = key.toString();
            items.add(Alert.fromJson(notificationData));
          });
        }
      } catch (e) {
        print(e);
      }
      return items;
    });
  }

  static Future<int> notify(Alert notification, String uid) async {
    int statusCode = 0;
    try {
      await _database.push().set({
        'uid': uid,
        'read_by': notification.readBy,
        'notified_time': DateTime.now().toString(),
        'notification_context': notification.notificationContext,
      });

      print("Berhasil");

      statusCode = 200;
    } catch (e) {
      statusCode = 401;
      print("Error");
    }

    return statusCode;
  }

  static Future<void> read(String uid, Alert notification) async {
    try {
      DataSnapshot snapshot =
          await _database.child(notification.notificationId!).get();
      Map<Object?, Object?> data = snapshot.value as Map<Object?, Object?>;
      List<Object?> dataReads = (data['read_by'] ?? []) as List<Object?>;
      List<String> reads = [];
      if (dataReads.isNotEmpty) {
        for (var read in dataReads) {
          reads.add(read.toString());
        }
      }
      reads.add(uid);
      await _database
          .child(notification.notificationId!)
          .update({'read_by': reads});
    } catch (e) {
      print(e);
    }
  }
}
