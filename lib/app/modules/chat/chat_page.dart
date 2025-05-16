import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'chat_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatelessWidget {
  final ChatController controller = Get.put(ChatController());

  ChatPage({super.key});

  String _formatTimestamp(dynamic ts) {
    if (ts is Timestamp) {
      final dt = ts.toDate();
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return "$hour:$min";
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final chat = Get.arguments;
    controller.setChatId(chat.id);
    controller.markChatAsSeen();

    final myUid = controller.auth.firebaseUser.value!.uid;
    final members = List<String>.from(chat['members']);
    final isGroup = chat['isGroup'] ?? false;
    final otherUid =
        !isGroup && members.length == 2
            ? (members[0] == myUid ? members[1] : members[0])
            : null;

    const bgColor = Color(0xFFF5F5F5);
    const myBubble = Color(0xFFB3E5FC);
    const otherBubble = Color(0xFFE0E0E0);
    const inputColor = Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(75),
        child: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: true,
          titleSpacing: 0,
          elevation: 2,
          flexibleSpace: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 60, right: 12, top: 10),
              child:
                  isGroup
                      ? Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue[200],
                            radius: 20,
                            child: Text(chat['groupEmoji'] ?? '👥'),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            chat['groupName'],
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                      : StreamBuilder<DocumentSnapshot>(
                        stream:
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(otherUid)
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return const Text(
                              "Loading...",
                              style: TextStyle(color: Colors.white),
                            );
                          }
                          final data =
                              snapshot.data!.data() as Map<String, dynamic>;
                          final name = data['name'] ?? 'User';
                          final emoji = data['emoji'] ?? '🙂';

                          return Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Colors.grey[300],
                                radius: 20,
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(
              () => ListView.builder(
                reverse: true,
                itemCount: controller.filteredMessages.length,
                itemBuilder: (context, index) {
                  final msg = controller.filteredMessages[index];
                  final isMe = msg['sender'] == myUid;
                  final data = msg.data() as Map<String, dynamic>;
                  final content = data['content'] ?? '';
                  final timestamp = data['timestamp'];

                  return FutureBuilder<DocumentSnapshot>(
                    future:
                        FirebaseFirestore.instance
                            .collection('users')
                            .doc(msg['sender'])
                            .get(),
                    builder: (context, snapshot) {
                      final senderData =
                          snapshot.data?.data() as Map<String, dynamic>? ?? {};
                      final senderName = senderData['name'] ?? 'User';
                      final senderEmoji = senderData['emoji'] ?? '🙂';

                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment:
                              isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onLongPress: () {
                                if (isMe) {
                                  Get.defaultDialog(
                                    title: "Delete Message",
                                    middleText: "Are you sure?",
                                    onConfirm: () {
                                      controller.deleteMessage(msg.id);
                                      Get.back();
                                    },
                                    onCancel: () => Get.back(),
                                    textConfirm: "Yes",
                                    textCancel: "No",
                                  );
                                }
                              },
                              child: IntrinsicWidth(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 4,
                                    horizontal: 8,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isMe ? myBubble : otherBubble,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        content,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      if (timestamp != null)
                                        Align(
                                          alignment: Alignment.bottomRight,
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                              top: 4,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  _formatTimestamp(timestamp),
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: Colors.grey[700],
                                                  ),
                                                ),
                                                if (isMe)
                                                  Text(
                                                    (data.containsKey('seen') &&
                                                            data['seen'] ==
                                                                true)
                                                        ? 'Seen'
                                                        : 'Sent',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color:
                                                          data['seen'] == true
                                                              ? Colors.green
                                                              : Colors
                                                                  .grey[600],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (!isMe && isGroup)
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 16,
                                  top: 2,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 10,
                                      backgroundColor: Colors.grey[300],
                                      child: Text(
                                        senderEmoji,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      senderName,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => TextField(
                      maxLines: null,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      onChanged: (value) {
                        controller.messageText.value = value;
                      },
                      style: const TextStyle(color: Colors.black),
                      controller: TextEditingController.fromValue(
                        TextEditingValue(
                          text: controller.messageText.value,
                          selection: TextSelection.collapsed(
                            offset: controller.messageText.value.length,
                          ),
                        ),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Type a message',
                        hintStyle: const TextStyle(color: Colors.black54),
                        filled: true,
                        fillColor: inputColor,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.black),
                  onPressed:
                      () =>
                          controller.sendMessage(controller.messageText.value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
