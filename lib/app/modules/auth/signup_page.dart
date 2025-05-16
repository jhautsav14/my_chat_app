import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'auth_controller.dart';

class SignUpPage extends StatelessWidget {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthController auth = Get.put(AuthController());

  final RxBool emojiShowing = false.obs;

  SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Obx(
              () => Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.grey[300],
                    child: Text(
                      auth.selectedEmoji.value,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Select your emoji avatar",
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            _buildTextField("Name", nameController),
            const SizedBox(height: 12),
            _buildTextField("Email", emailController),
            const SizedBox(height: 12),
            _buildTextField("Password", passwordController, obscure: true),
            const SizedBox(height: 16),
            Obx(
              () => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => emojiShowing.toggle(),
                child: Text(
                  emojiShowing.value ? "Hide Emoji Picker" : "Choose Emoji",
                ),
              ),
            ),
            const SizedBox(height: 8),
            Obx(
              () => Offstage(
                offstage: !emojiShowing.value,
                child: EmojiPicker(
                  onEmojiSelected: (category, emoji) {
                    auth.selectedEmoji.value = emoji.emoji;
                    emojiShowing.value = false;
                  },
                  config: Config(
                    height: 256,
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
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                auth.signUp(
                  nameController.text.trim(),
                  emailController.text.trim(),
                  passwordController.text.trim(),
                );
              },
              child: const Text("Create Account"),
            ),
            TextButton(
              onPressed: () => Get.toNamed('/'),
              child: const Text(
                "Already have an account? Sign in",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        labelText: label,
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
    );
  }
}
