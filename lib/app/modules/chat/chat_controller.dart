import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:my_chat_app/app/modules/auth/auth_controller.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final auth = AuthController.to;

  late String chatId;
  RxList<DocumentSnapshot> messages = <DocumentSnapshot>[].obs;

  final messageText = ''.obs;

  void setChatId(String id) {
    chatId = id;
    _listenMessages();
  }

  void _listenMessages() {
    _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
          messages.value = snapshot.docs;
        });
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    final newMsg = {
      'sender': auth.firebaseUser.value!.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'content': content,
    };

    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(newMsg);

    await _db.collection('chats').doc(chatId).update({
      'lastMessage': content,
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    messageText.value = '';
  }

  Stream<String?> getTypingStatus() {
    return _db.collection('chats').doc(chatId).snapshots().map((doc) {
      final data = doc.data();
      if (data == null || data['typing'] == null) return null;

      final typingMap = Map<String, dynamic>.from(data['typing']);
      for (final entry in typingMap.entries) {
        if (entry.key != auth.firebaseUser.value!.uid && entry.value == true) {
          return "User is typing...";
        }
      }
      return null;
    });
  }

  Future<void> deleteMessage(String messageId) async {
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  RxString searchQuery = ''.obs;

  List<DocumentSnapshot> get filteredMessages {
    if (searchQuery.value.isEmpty) return messages;
    return messages
        .where(
          (msg) => (msg['content'] ?? '').toLowerCase().contains(
            searchQuery.value.toLowerCase(),
          ),
        )
        .toList();
  }

  Future<void> markChatAsSeen() async {
    final uid = auth.firebaseUser.value!.uid;

    await _db.collection('chats').doc(chatId).update({
      'seenBy.$uid': FieldValue.serverTimestamp(),
    });

    final lastMsg =
        await _db
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

    if (lastMsg.docs.isNotEmpty) {
      final doc = lastMsg.docs.first;
      final data = doc.data();
      if (data['sender'] != uid && data['seen'] != true) {
        await doc.reference.update({'seen': true});
      }
    }
  }

  void setTyping(bool isTyping) {
    final uid = auth.firebaseUser.value!.uid;
    _db.collection('chats').doc(chatId).update({'typing.$uid': isTyping});
  }
}
