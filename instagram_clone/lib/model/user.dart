import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String profilePic;
  final String username;
  final String uid;
  final String email;
  final String bio;
  final List followers;
  final List following;

  const User({
    required this.profilePic,
    required this.username,
    required this.uid,
    required this.email,
    required this.bio,
    required this.followers,
    required this.following,
  });

  Map<String, dynamic> toJson() => {
        'profilePic': profilePic,
        'username': username,
        'uid': uid,
        'email': email,
        'bio': bio,
        'followers': followers,
        'following': following,
      };

  static User snapToUserModel(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;

    return User(
      profilePic: snap['profilePic'],
      username: snap['username'],
      uid: snap['uid'],
      email: snap['email'],
      bio: snap['bio'],
      followers: snap['followers'],
      following: snap['following'],
    );
  }
}
