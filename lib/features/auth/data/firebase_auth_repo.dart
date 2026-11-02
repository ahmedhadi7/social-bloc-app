import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:social_bloc/features/auth/domain/entities/app_user.dart';
import 'package:social_bloc/features/auth/domain/repo/auth_repo.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  @override
  Future<AppUser?> loginWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      //fetch user document from firestore
      DocumentSnapshot userDoc = await firebaseFirestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      //create user
      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        name: userDoc['name'],
        email: email,
      );
      //save user in firebase firestore
      await firebaseFirestore
          .collection("users")
          .doc(user.uid)
          .set(user.toJson());

      //return user
      return user;
    }
    //catch any error
    catch (e) {
      throw Exception('login failed: $e');
    }
  }

  @override
  Future<AppUser?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      //create user
      AppUser user = AppUser(
        uid: userCredential.user!.uid,
        name: name,
        email: email,
      );

      //save user in firebase firestore
      await firebaseFirestore
          .collection("users")
          .doc(user.uid)
          .set(user.toJson());

      //return user
      return user;
    }
    //catch any error
    catch (e) {
      throw Exception('login failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;

    //no user logged in
    if (firebaseUser == null) {
      return null;
    }
    //fetch user document from firestore
    DocumentSnapshot userDoc = await firebaseFirestore
        .collection('users')
        .doc(firebaseUser.uid)
        .get();
    //check if user doc exites
    if (!userDoc.exists) {
      return null;
    }

    //user exits
    return AppUser(
      uid: firebaseUser.uid,
      name: userDoc['name'],
      email: firebaseUser.email!,
    );
  }
}
