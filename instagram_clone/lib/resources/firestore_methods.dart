import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/model/post.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Upload post
  Future<String> uploadPost(String caption, Uint8List file, String uid,
      String username, String profilePic) async {
    String res = 'Some error occurred';

    String postId = const Uuid().v1();
    try {
      String photoUrl = await StorageMethods()
          .uploadImageToStorage(type: 'posts', file: file, postId: postId);

      Post post = Post(
        profilePic: profilePic,
        username: username,
        uid: uid,
        postId: postId,
        postDate: DateTime.now(),
        postUrl: photoUrl,
        caption: caption,
        likes: [],
      );

      _firestore.collection('posts').doc(postId).set(post.toJson());
      res = 'success';
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  static Future<void> likePost(
    String postId,
    String uid,
    List likes,
  ) async {
    try {
      if (likes.contains(uid)) {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> postComment(String postId, String comment, String uid,
      String username, String profilePic) async {
    try {
      if (comment.isNotEmpty) {
        String commentId = const Uuid().v1();
        _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'username': username,
          'uid': uid,
          'comment': comment,
          'postId': postId,
          'dateCommented': DateTime.now(),
        });
      }
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> followUsers(String uid, String followUid) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];

      if (following.contains(followUid)) {
        await _firestore.collection('users').doc(followUid).update(
          {
            'followers': FieldValue.arrayRemove([uid]),
          },
        );
        await _firestore.collection('users').doc(uid).update(
          {
            'following': FieldValue.arrayRemove([followUid]),
          },
        );
      } else {
        await _firestore.collection('users').doc(followUid).update(
          {
            'followers': FieldValue.arrayUnion([uid]),
          },
        );
        await _firestore.collection('users').doc(uid).update(
          {
            'following': FieldValue.arrayUnion([followUid]),
          },
        );
      }
    } catch (err) {
      print(err.toString());
    }
  }
}
