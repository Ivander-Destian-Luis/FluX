class Posting {
  String? postingImageUrl;
  final String? posterUid;
  final String? postId;
  final String postingDescription;
  final String location;
  final List<String> likes;
  final Map<String, List<dynamic>> comments;
  final DateTime postedTime;

  Posting(
      {required this.postingDescription,
      required this.location,
      this.postingImageUrl,
      required this.likes,
      required this.comments,
      required this.postedTime,
      required this.postId,
      required this.posterUid});

  factory Posting.fromJson(Map<String, dynamic> json) {
    return Posting(
      postingDescription: json['description'],
      location: json['location'],
      postingImageUrl: json['posting_image_url'],
      likes: json['likes'] as List<String>,
      comments: json['comments'],
      postedTime: DateTime.now(),
      postId: json['post_id'],
      posterUid: json['uid'],
    );
  }
}
