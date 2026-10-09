import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/station_model.dart';

class StationController {
  final _col = FirebaseFirestore.instance.collection('stations');

  Stream<QuerySnapshot> stream() => _col.snapshots();
  Future<void> add(Station s) async => await _col.add(s.toMap());
  Future<void> update(String id, Station s) async => await _col.doc(id).update(s.toMap());
  Future<void> delete(String id) async => await _col.doc(id).delete();
}