import 'package:cloud_firestore/cloud_firestore.dart';

class FirestorePatchService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> patchMissingLastUpdated() async {
    final snapshot = await _db.collection('chats').get();

    for (final doc in snapshot.docs) {
      final data = doc.data();
      if (data['lastUpdated'] == null) {
        await doc.reference.update({
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        print("Patched: ${doc.id}");
      }
    }

    print("✅ All missing 'lastUpdated' fields have been updated.");
  }
}
