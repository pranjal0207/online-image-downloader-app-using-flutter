import 'package:cloud_firestore/cloud_firestore.dart';

class OFirestoreService {
  FirebaseFirestore _db = FirebaseFirestore.instance; 
  getData() async{
    return await _db.collection('img').get();
  }
}