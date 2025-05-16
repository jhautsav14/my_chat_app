import 'package:get/get.dart';
import 'package:my_chat_app/app/modules/chat/chat_page.dart';
import 'package:my_chat_app/app/modules/group_create/group_create_page.dart';
import 'package:my_chat_app/app/modules/home/test_patch_screen.dart';
import '../modules/auth/login_page.dart';
import '../modules/auth/signup_page.dart';
import '../modules/home/home_page.dart';

class AppPages {
  static final routes = [
    GetPage(name: '/', page: () => LoginPage()),
    GetPage(name: '/signup', page: () => SignUpPage()),
    GetPage(name: '/home', page: () => HomePage()),
    GetPage(name: '/chat', page: () => ChatPage()),
    GetPage(name: '/patch', page: () => TestPatchScreen()),
    GetPage(name: '/create-group', page: () => GroupCreatePage()),
  ];
}
