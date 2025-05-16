import 'package:flutter/material.dart';
import 'package:my_chat_app/firestore_patch_service.dart';

class TestPatchScreen extends StatelessWidget {
  final patchService = FirestorePatchService();

  TestPatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test Firestore Patch")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await patchService.patchMissingLastUpdated();
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Patch completed")));
          },
          child: const Text("Run Patch"),
        ),
      ),
    );
  }
}
