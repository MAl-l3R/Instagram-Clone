import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:instagram_clone/model/user.dart' as model;
import 'package:instagram_clone/resources/storage_methods.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<model.User> getUserDetails() async {
    User currentUser = _auth.currentUser!;

    DocumentSnapshot snap =
        await _firestore.collection('users').doc(currentUser.uid).get();

    return model.User.snapToUserModel(snap);
  }

  Future<String> signUpUser({
    required String username,
    required String email,
    required String password,
    required String bio,
    required Uint8List file,
  }) async {
    String res = "Some error occurred";
    try {
      if (username.isNotEmpty &&
          email.isNotEmpty &&
          password.isNotEmpty &&
          bio.isNotEmpty) {
        // Register User
        UserCredential credential = await _auth.createUserWithEmailAndPassword(
            email: email, password: password);

        String profilePicUrl = await StorageMethods()
            .uploadImageToStorage(type: 'profilePics', file: file);

        // Add user to local database
        model.User user = model.User(
          username: username,
          uid: credential.user!.uid,
          email: email,
          bio: bio,
          followers: [],
          following: [],
          profilePic: profilePicUrl,
        );

        // Add user to firebase
        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(user.toJson());
        res = 'success';
      } else {
        res = 'Please enter all the fields';
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'invalid-email') {
        res = 'Invalid email address';
      } else if (err.code == 'email-already-in-use') {
        res = 'The email address is already in use by another account';
      } else if (err.code == 'weak-password') {
        res = 'Weak password. Must be at least 6 characters long.';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";

    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        res = 'success';
      } else {
        res = 'Please enter all the fields';
      }
    } on FirebaseAuthException catch (err) {
      if (err.code == 'user-not-found') {
        res = 'No user is registered with this email address.';
      } else if (err.code == 'wrong-password') {
        res = 'Incorrect Password. Please try again.';
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
