import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flux/models/posting.dart';

class PostService {
  static final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child('posting_list');

  static Stream<List<Posting>> getPostingList() {
    return _database.onValue.map((event) {
      List<Posting> items = [];
      DataSnapshot snapshot = event.snapshot;
      try {
        if (snapshot.value != null) {
          Map<Object?, Object?> listData =
              snapshot.value as Map<Object?, Object?>;
          listData.forEach((key, value) {
            final data = value as Map<Object?, Object?>;
            Map<String, dynamic> accountData = {};
            bool likesExisted = false;
            data.forEach((key, value) {
              if (key.toString() == 'likes') {
                likesExisted = true;
                final dataLikes = value as List<Object?>;
                List<String> likes = [];
                for (var like in dataLikes) {
                  likes.add(like.toString());
                }
                accountData[key.toString()] = likes;
              } else if (key.toString() == 'comments') {
                final dataComments = value as Map<Object?, Object?>;
                Map<String, List<String>> comments = {};
                dataComments.forEach((key, value) {
                  final temp = value as List<Object?>;
                  List<String> listComments = [];
                  for (var comment in temp) {
                    listComments.add(comment.toString());
                  }
                  comments[key.toString()] = listComments;
                });
                accountData[key.toString()] = comments;
              } else {
                accountData[key.toString()] = value;
              }
            });

            if (!likesExisted) {
              accountData['likes'] = List<String>.empty();
            }

            accountData['post_id'] = key.toString();
            items.add(Posting.fromJson(accountData));
          });
        }
      } catch (e) {
        print(e);
      }
      return items;
    });
  }

  static Future<void> post(Posting posting, String uid) async {
    await _database.push().set({
      'uid': uid,
      'location': posting.location,
      'posting_image_url': posting.postingImageUrl,
      'description': posting.postingDescription,
      'likes': posting.likes,
      'comments': posting.comments,
      'postedTime': DateTime.now().toString(),
    });
  }

  static Future<String?> addPostingImage(File? selectedImage) async {
    try {
      if (selectedImage == null) {
        return null;
      }
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final storageRef = FirebaseStorage.instance.ref();
      final timestamp = DateTime.now().microsecondsSinceEpoch;
      final uploadRef = storageRef.child("posts/$userId/$timestamp");

      final taskSnapshot = await uploadRef.putFile(selectedImage);

      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      return null;
    }
  }

  static Future<void> like(String uid, Posting posting) async {
    try {
      DataSnapshot snapshot = await _database.child(posting.postId!).get();
      Map<Object?, Object?> data = snapshot.value as Map<Object?, Object?>;
      List<Object?> dataLikes = (data['likes'] ?? []) as List<Object?>;
      List<String> likes = [];
      if (dataLikes.isNotEmpty) {
        for (var like in dataLikes) {
          likes.add(like.toString());
        }
      }
      likes.add(uid);
      await _database.child(posting.postId!).update({'likes': likes});
    } catch (e) {
      print(e);
    }
  }

  static Future<void> dislike(String uid, Posting posting) async {
    try {
      DataSnapshot snapshot = await _database.child(posting.postId!).get();
      Map<Object?, Object?> data = snapshot.value as Map<Object?, Object?>;
      List<Object?> dataLikes = data['likes'] as List<Object?>;
      List<String> likes = [];
      for (var like in dataLikes) {
        likes.add(like.toString());
      }
      likes.remove(uid);
      await _database.child(posting.postId!).update({'likes': likes});
    } catch (e) {
      print(e);
    }
  }

  static Future<void> comment(
      String uid, String comment, Posting posting) async {
    try {
      DataSnapshot snapshot = await _database.child(posting.postId!).get();
      Map<Object?, Object?> data = snapshot.value as Map<Object?, Object?>;
      Map<String, dynamic> mapComments = {};
      data.forEach((key, value) {
        if (key.toString() == 'comments') {
          final temp = value as Map<Object?, Object?>;
          bool isExist = false;
          bool isEmpty = false;
          temp.forEach((key, value) {
            List<String> comments = [];
            final eachUid = key.toString();
            final listComments = value as List<Object?>;

            if (eachUid == uid) {
              isExist = true;
              if (listComments[0].toString().isNotEmpty) {
                for (var commentMessage in listComments) {
                  comments.add(commentMessage.toString());
                }
              }
              comments.add(comment);
            } else {
              if (listComments[0].toString().isNotEmpty) {
                for (var commentMessage in listComments) {
                  comments.add(commentMessage.toString());
                }
              }
            }
            mapComments[eachUid] = comments;
          });

          if (!isExist) {
            mapComments[uid] = [comment];
          }
        }
      });
      await _database.child(posting.postId!).update({'comments': mapComments});
    } catch (e) {
      print("error sending comment");
    }
  }

  static Future<int> getCommentsLength(Posting post) async {
    int length = 0;
    try {
      DataSnapshot snapshot = await _database.child(post.postId!).get();
      Map<Object?, Object?> data = snapshot.value as Map<Object?, Object?>;

      data.forEach((key, value) {
        if (key.toString() == 'comments') {
          final temp = value as Map<Object?, Object?>;
          List<String> comments = [];
          temp.forEach((key, value) {
            final listComments = value as List<Object?>;
            if (listComments[0].toString().isEmpty) {
              return;
            } else {
              for (var commentMessage in listComments) {
                length++;
              }
            }
          });
        }
      });
    } catch (e) {}

    return length;
  }
}
