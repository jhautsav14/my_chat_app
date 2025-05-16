import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_chat_app/app/modules/auth/auth_controller.dart';

class GroupCreateController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final auth = AuthController.to;

  RxList<DocumentSnapshot> allUsers = <DocumentSnapshot>[].obs;
  RxList<String> selectedUserIds = <String>[].obs;

  final RxString groupName = ''.obs;
  RxString groupEmoji = "🙂".obs;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(Duration.zero, loadUsers); // Ensures context is ready
  }

  void loadUsers() async {
    final uid = auth.firebaseUser.value?.uid;
    if (uid == null) return;

    final snapshot = await _db.collection('users').get();
    allUsers.value = snapshot.docs.where((u) => u['uid'] != uid).toList();
  }

  void toggleSelection(String uid) {
    selectedUserIds.contains(uid)
        ? selectedUserIds.remove(uid)
        : selectedUserIds.add(uid);
  }

  Future<void> createGroup() async {
    final myUid = auth.firebaseUser.value!.uid;
    final all = [myUid, ...selectedUserIds];

    final chatRef = await _db.collection('chats').add({
      'isGroup': true,
      'groupName':
          groupName.value.trim().isEmpty ? "New Group" : groupName.value.trim(),
      'groupEmoji': groupEmoji.value,
      'members': all,
      'lastMessage': '',
      'lastUpdated': FieldValue.serverTimestamp(),
    });
    Get.offAllNamed('/home');
    // Get.offAllNamed('/chat', arguments: await chatRef.get());
  }
}
