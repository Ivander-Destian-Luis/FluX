class Account {
  final String bio;
  final List<dynamic> followers;
  final List<dynamic> followings;
  final String phoneNumber;
  final int posts;
  final String profilePictureUrl;
  final String username;
  final List<dynamic> saved;

  Account(
      {required this.bio,
      required this.followers,
      required this.followings,
      required this.phoneNumber,
      required this.posts,
      required this.profilePictureUrl,
      required this.saved,
      required this.username});

  factory Account.fromJson(Map<String, dynamic> data) {
    Account account = Account(
      bio: data['bio'],
      followers: data['followers'],
      followings: data['followings'],
      phoneNumber: data['phone_number'],
      posts: data['posts'],
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      saved: data['saved'],
      username: data['username'],
    );

    return account;
  }
}
