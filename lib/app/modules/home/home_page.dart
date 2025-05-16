import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'home_controller.dart';

class HomePage extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  HomePage({super.key});

  Future<Map<String, dynamic>> getUserDetails(String uid) async {
    final doc = await controller.db.collection('users').doc(uid).get();
    if (doc.exists) {
      return {'emoji': doc['emoji'] ?? '🙂', 'name': doc['name'] ?? 'Unknown'};
    }
    return {'emoji': '🙂', 'name': 'Unknown'};
  }

  @override
  Widget build(BuildContext context) {
    final myUid = controller.auth.firebaseUser.value!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              "assets/logo.png",
              height: MediaQuery.of(context).size.height * 0.1,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.search, color: Colors.blue.shade900),
            onPressed:
                () => showSearch(
                  context: context,
                  delegate: UserSearchDelegate(),
                ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.logOut, color: Colors.red),
            onPressed: () async {
              await controller.auth.signOut();
              Get.offAllNamed('/');
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[900],
        onPressed: () => Get.toNamed('/create-group'),
        child: const Icon(Icons.group_add, color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            Obx(() {
              if (controller.searchResults.isNotEmpty) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.searchResults.length,
                  itemBuilder: (context, index) {
                    final user = controller.searchResults[index];
                    return ListTile(
                      leading: Text(
                        user['emoji'],
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Text(user['name']),
                      subtitle: Text(user['email']),
                      onTap: () => controller.startPrivateChat(user),
                    );
                  },
                );
              }
              return const SizedBox();
            }),

            Row(
              children: [
                Icon(LucideIcons.messageCircle, color: Colors.blue.shade900),
                Text(
                  "Chats",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                ),
              ],
            ),
            Divider(indent: 50, endIndent: 50, color: Colors.grey[300]),

            Expanded(
              child: Obx(() {
                if (controller.chats.isEmpty) {
                  return const Center(child: Text("No chats yet."));
                }
                return ListView.builder(
                  itemCount: controller.chats.length,
                  itemBuilder: (context, index) {
                    final chat = controller.chats[index];
                    final isGroup = chat['isGroup'] as bool;
                    final members = List<String>.from(chat['members']);
                    final title =
                        isGroup
                            ? chat['groupName']
                            : "Chat with ${members.firstWhere((id) => id != myUid)}";

                    return FutureBuilder<Map<String, dynamic>>(
                      future:
                          isGroup
                              ? Future.value({
                                'emoji': chat['groupEmoji'] ?? '👥',
                                'name': chat['groupName'] ?? 'Group',
                              })
                              : getUserDetails(
                                members.firstWhere((id) => id != myUid),
                              ),
                      builder: (context, snapshot) {
                        final emoji = snapshot.data?['emoji'] ?? '🙂';
                        final name = snapshot.data?['name'] ?? 'User';
                        final timestamp =
                            chat['lastUpdated'] is Timestamp
                                ? (chat['lastUpdated'] as Timestamp).toDate()
                                : null;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          leading: CircleAvatar(
                            backgroundColor:
                                isGroup ? Colors.blue[300] : Colors.grey[300],

                            radius: 24,
                            child: Text(
                              emoji,
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  name,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (timestamp != null)
                                Text(
                                  "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Text(
                            chat['lastMessage'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: FutureBuilder<int>(
                            future: controller.getUnreadCount(chat),
                            builder: (context, snapshot) {
                              final count = snapshot.data ?? 0;
                              if (count == 0) return const SizedBox();

                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '+$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            },
                          ),

                          onTap: () => Get.toNamed('/chat', arguments: chat),
                        );
                      },
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class UserSearchDelegate extends SearchDelegate {
  final HomeController controller = Get.find<HomeController>();

  @override
  String get searchFieldLabel => 'Search by email';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(onPressed: () => query = '', icon: const Icon(Icons.clear)),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    controller.searchUsers(query);

    return Obx(() {
      if (controller.searchResults.isEmpty) {
        return const Center(child: Text("No users found"));
      }
      return ListView.builder(
        itemCount: controller.searchResults.length,
        itemBuilder: (context, index) {
          final user = controller.searchResults[index];
          return ListTile(
            leading: Text(user['emoji'], style: const TextStyle(fontSize: 28)),
            title: Text(user['name']),
            subtitle: Text(user['email']),
            onTap: () {
              controller.startPrivateChat(user);
              close(context, null);
            },
          );
        },
      );
    });
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(child: Text("Type an email to search"));
  }
}
