import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//ref: https://blog.logrocket.com/implementing-firebase-authentication-in-a-flutter-app/
class FireAuth {
  // For registering a new user
  static Future<User?> registerUsingEmailPassword({
    required String name,
    required String email,
    required String password,
    BuildContext? context
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({"name": name, "email": email, "createdAt":DateTime.now()});
      user = userCredential.user;
      await user!.updateDisplayName(name);
      await user.reload();
      user = auth.currentUser;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context!).showSnackBar(const SnackBar(content: Text('Weak password')));
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context!).showSnackBar(const SnackBar(content: Text('The account already exists for that email.')));
        print('The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context!).showSnackBar(const SnackBar(content: Text('Invalid email')));
        print('The account already exists for that email.');
      }
    } catch (e) {
      print("An error occurs");
    }
    return user;
  }

  // For signing in an user (have already registered)
  static Future<User?> signInUsingEmailPassword({
    required String email,
    required String password,
    BuildContext? context
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        ScaffoldMessenger.of(context!).showSnackBar(const SnackBar(content: Text('Email or password is incorrect.')));
        print('No user found for that email.');
      } else if (e.code == 'invalid-email') {
        ScaffoldMessenger.of(context!).showSnackBar(const SnackBar(content: Text('Invalid email')));
        print('Invalid email');
      }
    }

    return user;
  }

  static Future<User?> refreshUser(User user) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await user.reload();
    User? refreshedUser = auth.currentUser;

    return refreshedUser;
  }
}
