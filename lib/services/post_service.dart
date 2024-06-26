import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flux/models/account.dart';
import 'package:flux/models/posting.dart';
import 'package:flux/services/account_service.dart';

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
            bool commentsExisted = false;
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
                commentsExisted = true;
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

            if (!commentsExisted) {
              accountData['comments'] = Map<String, List<dynamic>>.from({});
            }

            accountData['post_id'] = key.toString();
            items.add(Posting.fromJson(accountData));
          });
          items.sort(
            (a, b) {
              return b.postedTime.compareTo(a.postedTime);
            },
          );
        }
      } catch (e) {
        print(e);
      }
      return items;
    });
  }

  static Stream<List<Posting>> getPostingList2() {
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
            bool commentsExisted = false;
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
                commentsExisted = true;
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

            if (!commentsExisted) {
              accountData['comments'] = Map<String, List<dynamic>>.from({});
            }

            accountData['post_id'] = key.toString();
            items.add(Posting.fromJson(accountData));
          });
          items.sort(
            (a, b) {
              return b.postedTime.compareTo(a.postedTime);
            },
          );
        }
      } catch (e) {
        print(e);
      }
      return items;
    });
  }

  static Future<int> post(Posting posting, String uid) async {
    int statusCode = 0;
    try {
      await _database.push().set({
        'uid': uid,
        'location': posting.location,
        'posting_image_url': posting.postingImageUrl,
        'description': posting.postingDescription,
        'likes': posting.likes,
        'latitude': posting.latitude,
        'longitude': posting.longitude,
        'comments': posting.comments,
        'postedTime': DateTime.now().toString(),
      }).whenComplete(() async {
        Account account = (await AccountService.getAccountByUid(
            FirebaseAuth.instance.currentUser!.uid))!;
        AccountService.edit(
            FirebaseAuth.instance.currentUser!.uid,
            account.username,
            account.phoneNumber,
            account.bio,
            account.followings,
            account.followers,
            account.profilePictureUrl,
            account.posts + 1,
            account.saved);
      });

      print("Berhasil");

      statusCode = 200;
    } catch (e) {
      statusCode = 401;
      print("Errorr");
    }

    return statusCode;
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
      bool commentsExist = false;
      data.forEach((key, value) {
        if (key.toString() == 'comments') {
          commentsExist = true;
          final temp = value as Map<Object?, Object?>;
          bool isExist = false;
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

      if (!commentsExist) {
        mapComments[uid] = [comment];
      }
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

  static Future<List<Posting>> getSavedPost(String uid) async {
    Account? account = await AccountService.getAccountByUid(uid);
    List<Posting> savedPosts = List<Posting>.empty(growable: true);

    try {
      savedPosts = await _database.once().then(
        (snapshot) {
          Map<dynamic, dynamic> value = Map<dynamic, dynamic>.from(
              snapshot.snapshot.value as Map<dynamic, dynamic>);
          value.forEach(
            (key, value) {
              if (account!.saved.contains(key.toString())) {
                Map<String, dynamic> data = {};
                Map<Object?, Object?>.from(value).forEach(
                  (key, value) {
                    if (key == 'likes') {
                      final dataLikes = value as List<Object?>;
                      List<String> likes = [];
                      for (var like in dataLikes) {
                        likes.add(like.toString());
                      }
                      data[key.toString()] = likes;
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
                      data[key.toString()] = comments;
                    } else {
                      data[key.toString()] = value;
                    }
                  },
                );
                if (data['likes'] == null) {
                  data['likes'] = List<String>.empty();
                }
                if (data['comments'] == null) {
                  data['comments'] = Map<String, List<dynamic>>.from({});
                }
                data['post_id'] = key.toString();
                Posting posting = Posting.fromJson(data);
                savedPosts.add(posting);
              }
            },
          );
          return savedPosts;
        },
      );
    } catch (e) {}
    return savedPosts;
  }
}
