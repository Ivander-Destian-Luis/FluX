import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flux/models/account.dart';
import 'package:flux/models/posting.dart';

class AccountService {
  static Future<Map<String, dynamic>> addUser(String username,
      String phoneNumber, String bio, String? profileImageUrl) async {
    try {
      var isAccountMade = false;

      await FirebaseFirestore.instance
          .collection('accounts')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        isAccountMade = value.data() != null;
      });

      if (isAccountMade) {
        return {'isError': true, 'message': "Account has been made."};
      }

      final snapshot =
          await FirebaseFirestore.instance.collection('accounts').get();

      var isUsernameTaken = false;

      for (var account in snapshot.docs) {
        if (account.data()['username'] == username) {
          isUsernameTaken = true;
          break;
        }
      }

      if (isUsernameTaken) {
        return {'isError': true, 'message': "Username has been taken."};
      }

      await FirebaseFirestore.instance
          .collection('accounts')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        "username": username,
        "phone_number": phoneNumber,
        "bio": bio,
        "followings": [],
        "followers": [],
        "profilePictureUrl": profileImageUrl ?? '',
        "posts": 0,
        "saved": [],
      }).whenComplete(() {
        print("Submit Selesai");
      });
      return {
        'isError': false,
        'message': "Account has been made successfully."
      };
    } catch (e) {
      print(e);
    }

    return {'isError': true, 'message': "There is something error."};
  }

  static Future<String?> addPhotoProfile(File? selectedImage) async {
    try {
      if (selectedImage == null) {
        return null;
      }
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final storageRef = FirebaseStorage.instance.ref();
      final timestamp = DateTime.now().microsecondsSinceEpoch;
      final uploadRef = storageRef.child("profile_pictures/$userId/$timestamp");

      final taskSnapshot = await uploadRef.putFile(selectedImage);

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  static Future<Account?> getAccountByUid(String uid) async {
    Account? account;
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('accounts')
          .doc(uid)
          .get();
      final data = snapshot.data() as Map<String, dynamic>?;
      account = Account.fromJson(data!);
    } catch (e) {
      print("Error di get account by uid ${e}");
      return null;
    }

    return account;
  }

  static Future<String?> getUidByUsername(String username) async {
    String? uid;
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('accounts').get();

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['username'] == username) {
          uid = doc.id;
        }
      }
    } catch (e) {
      print('Error');
      return null;
    }

    return uid;
  }

  static Future<List<Account>> getAccountsByUsername(String username) async {
    List<Account> accountsUid = [];
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('accounts').get();
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['username']
            .toString()
            .substring(0, username.length)
            .toLowerCase()
            .contains(username.toLowerCase())) {
          accountsUid.add((await getAccountByUid(doc.id))!);
        }
      }
    } catch (e) {}

    return accountsUid;
  }

  static Future<void> edit(
      String uid,
      String? username,
      String? phoneNumber,
      String? bio,
      List<dynamic>? followings,
      List<dynamic>? followers,
      String? profilePictureUrl,
      int? posts,
      List<dynamic>? savedPost) async {
    Account account = (await getAccountByUid(uid))!;
    try {
      await FirebaseFirestore.instance.collection('accounts').doc(uid).set({
        "username": username ?? account.username,
        "phone_number": phoneNumber ?? account.phoneNumber,
        "bio": bio ?? account.bio,
        "followings": followings ?? account.followings,
        "followers": followers ?? account.followers,
        "profilePictureUrl": profilePictureUrl ?? account.profilePictureUrl,
        "posts": posts ?? account.posts,
        "saved": savedPost ?? account.saved,
      }).whenComplete(() {
        print("Edit Selesai");
      });
    } catch (e) {}
  }

  static Future<void> follow(String uid, String targetUid) async {
    Account? user = await getAccountByUid(uid);
    Account? targetUser = await getAccountByUid(targetUid);

    try {
      List<dynamic> userFollowings = user!.followings;
      userFollowings.add(targetUid);
      edit(uid, null, null, null, userFollowings, null, null, null, null);

      List<dynamic> targetFollowers = targetUser!.followers;
      targetFollowers.add(uid);
      edit(
          targetUid, null, null, null, null, targetFollowers, null, null, null);
    } catch (e) {}
  }

  static Future<void> unfollow(String uid, String targetUid) async {
    Account? user = await getAccountByUid(uid);
    Account? targetUser = await getAccountByUid(targetUid);

    try {
      List<dynamic> userFollowings = user!.followings;
      if (userFollowings.contains(targetUid)) {
        userFollowings.remove(targetUid);
      }
      edit(uid, null, null, null, userFollowings, null, null, null, null);

      List<dynamic> targetFollowers = targetUser!.followers;
      if (targetFollowers.contains(uid)) {
        targetFollowers.remove(uid);
      }
      edit(
          targetUid, null, null, null, null, targetFollowers, null, null, null);
    } catch (e) {}
  }

  static Future<void> savePost(String uid, Posting post) async {
    Account? account = await getAccountByUid(uid);

    account!.saved.add(post.postId!);

    await edit(uid, null, null, null, null, null, null, null, account.saved);
  }
}
