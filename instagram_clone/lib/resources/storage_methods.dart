import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageMethods {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> uploadImageToStorage(
      {required String type,
      required Uint8List file,
      String postId = ""}) async {
    Reference storageRef =
        _storage.ref().child(type).child(_auth.currentUser!.uid);

    if (postId != "") {
      storageRef = storageRef.child(postId);
    }

    TaskSnapshot snapshot = await storageRef.putData(file);
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }
}
