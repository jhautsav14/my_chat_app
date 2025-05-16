import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'group_create_controller.dart';

class GroupCreatePage extends StatelessWidget {
  final GroupCreateController controller = Get.put(GroupCreateController());

  GroupCreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Group"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder:
                          (_) => EmojiPicker(
                            onEmojiSelected: (category, emoji) {
                              controller.groupEmoji.value = emoji.emoji;
                              Get.back();
                            },
                            config: Config(
                              emojiViewConfig: EmojiViewConfig(
                                emojiSizeMax:
                                    28 *
                                    (foundation.defaultTargetPlatform ==
                                            TargetPlatform.iOS
                                        ? 1.2
                                        : 1.0),
                              ),
                            ),
                          ),
                    );
                  },
                  child: Obx(
                    () => Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        controller.groupEmoji.value,
                        style: const TextStyle(fontSize: 28),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: "Group Name (optional)",
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black),
                      ),
                    ),
                    onChanged: (val) => controller.groupName.value = val,
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text("Select Members"),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: controller.allUsers.length,
                  itemBuilder: (context, index) {
                    final user = controller.allUsers[index];
                    final uid = user['uid'];

                    return ListTile(
                      title: Text(user['name']),
                      subtitle: Text(user['email']),
                      leading: Text(
                        user['emoji'],
                        style: const TextStyle(fontSize: 28),
                      ),
                      trailing: Obx(
                        () => Icon(
                          controller.selectedUserIds.contains(uid)
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          color:
                              controller.selectedUserIds.contains(uid)
                                  ? Colors.green
                                  : null,
                        ),
                      ),
                      onTap: () => controller.toggleSelection(uid),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Obx(
              () => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed:
                    controller.selectedUserIds.isEmpty
                        ? null
                        : () => controller.createGroup(),
                child: const Text("Create Group"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
