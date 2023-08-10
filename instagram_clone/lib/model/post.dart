import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String profilePic;
  final String username;
  final String uid;
  final String postId;
  final postDate;
  final String postUrl;
  final String caption;
  final likes;

  const Post({
    required this.profilePic,
    required this.username,
    required this.uid,
    required this.postId,
    required this.postDate,
    required this.postUrl,
    required this.caption,
    required this.likes,
  });

  Map<String, dynamic> toJson() => {
        'profilePic': profilePic,
        'username': username,
        'uid': uid,
        'postId': postId,
        'postDate': postDate,
        'postUrl': postUrl,
        'caption': caption,
        'likes': likes,
      };

  static Post snapToUserModel(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return Post(
      profilePic: snap['profilePic'],
      username: snap['username'],
      uid: snap['uid'],
      postId: snap['postId'],
      postDate: snap['postDate'],
      postUrl: snap['postUrl'],
      caption: snap['caption'],
      likes: snap['likes'],
    );
  }
}
