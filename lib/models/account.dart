class Account {
  final String bio;
  final List<dynamic> followers;
  final List<dynamic> followings;
  final String phoneNumber;
  final int posts;
  final String profilePictureUrl;
  final String username;

  Account(
      {required this.bio,
      required this.followers,
      required this.followings,
      required this.phoneNumber,
      required this.posts,
      required this.profilePictureUrl,
      required this.username});

  factory Account.fromJson(Map<String, dynamic> data) {
    return Account(
      bio: data['bio'] ?? '',
      followers: data['followers'] ?? List.empty(),
      followings: data['followings'] ?? List.empty(),
      phoneNumber: data['phoneNumber'] ?? '',
      posts: data['posts'] ?? 0,
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      username: data['username'] ?? '',
    );
  }
}
