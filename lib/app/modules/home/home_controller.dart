import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:my_chat_app/app/modules/auth/auth_controller.dart';

class HomeController extends GetxController {
  // final _db = FirebaseFirestore.instance;
  final FirebaseFirestore db = FirebaseFirestore.instance;

  final auth = AuthController.to;
  RxList<DocumentSnapshot> chats = <DocumentSnapshot>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchUserChats();
  }

  void fetchUserChats() {
    final uid = auth.firebaseUser.value!.uid;

    db
        .collection('chats')
        .where('members', arrayContains: uid)
        .snapshots()
        .listen((snapshot) {
          // Manually sort by lastUpdated descending if it exists
          final sorted =
              snapshot.docs.toList()..sort((a, b) {
                final aTime = a['lastUpdated'];
                final bTime = b['lastUpdated'];
                if (aTime == null && bTime == null) return 0;
                if (aTime == null) return 1;
                if (bTime == null) return -1;
                return bTime.compareTo(aTime);
              });

          chats.value = sorted;
        });
  }

  RxList<DocumentSnapshot> searchResults = <DocumentSnapshot>[].obs;

  void searchUsers(String query) async {
    final uid = auth.firebaseUser.value!.uid;
    final snapshot =
        await db
            .collection('users')
            .where('email', isEqualTo: query.trim())
            .get();

    searchResults.value =
        snapshot.docs.where((doc) => doc['uid'] != uid).toList();
  }

  Future<void> startPrivateChat(DocumentSnapshot userDoc) async {
    final myUid = auth.firebaseUser.value!.uid;
    final otherUid = userDoc['uid'];

    final chatQuery =
        await db
            .collection('chats')
            .where('isGroup', isEqualTo: false)
            .where('members', arrayContains: myUid)
            .get();

    for (final doc in chatQuery.docs) {
      final members = List<String>.from(doc['members']);
      if (members.contains(otherUid)) {
        Get.toNamed('/chat', arguments: doc);
        return;
      }
    }

    final newChat = await db.collection('chats').add({
      'isGroup': false,
      'members': [myUid, otherUid],
      'lastUpdated': FieldValue.serverTimestamp(),
      'lastMessage': '',
    });

    Get.toNamed('/chat', arguments: await newChat.get());
  }

  bool hasUnreadMessages(DocumentSnapshot chat) {
    final currentUser = auth.firebaseUser.value!.uid;
    final lastSeenField = 'seenBy.$currentUser';

    final lastSeen =
        chat.data().toString().contains(lastSeenField)
            ? chat[lastSeenField]
            : null;

    final lastUpdated = chat['lastUpdated'];

    return lastSeen == null ||
        (lastUpdated is Timestamp &&
            lastUpdated.toDate().isAfter(lastSeen.toDate()));
  }

  Future<int> getUnreadCount(DocumentSnapshot chat) async {
    final currentUser = auth.firebaseUser.value!.uid;
    final seenBy = Map<String, dynamic>.from(chat['seenBy'] ?? {});
    final lastSeen =
        seenBy[currentUser] is Timestamp
            ? (seenBy[currentUser] as Timestamp).toDate()
            : DateTime(2000);

    final msgQuery =
        await FirebaseFirestore.instance
            .collection('chats')
            .doc(chat.id)
            .collection('messages')
            .where('timestamp', isGreaterThan: lastSeen)
            .where('sender', isNotEqualTo: currentUser)
            .get();

    return msgQuery.docs.length;
  }
}
