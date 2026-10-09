import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  final _auth = FirebaseAuth.instance;

  Future<void> signIn(String email, String pw) =>
      _auth.signInWithEmailAndPassword(email: email, password: pw);

  Future<void> signOut() => _auth.signOut();

  Stream<String> roleStream(String uid) => FirebaseFirestore.instance
      .collection('users').doc(uid).snapshots()
      .map((d) => (d.data()?['role'] ?? 'Operator') as String);
}