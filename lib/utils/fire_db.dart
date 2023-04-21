import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FireDb {
  static Future<String> getUserName() async {
    var userCollection = FirebaseFirestore.instance.collection('/users');
    if (FirebaseAuth.instance.currentUser != null) {
      return userCollection
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) => value['name']);
    } else {
      return "";
    }
  }
}
