import 'package:get/get.dart';

import 'package:chat_app/app/modules/chatScreen/bindings/chat_screen_binding.dart';
import 'package:chat_app/app/modules/chatScreen/views/chat_screen_view.dart';
import 'package:chat_app/app/modules/chatsScreen/bindings/chats_screen_binding.dart';
import 'package:chat_app/app/modules/chatsScreen/views/chats_screen_view.dart';
import 'package:chat_app/app/modules/home/bindings/home_binding.dart';
import 'package:chat_app/app/modules/home/views/home_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.CHATS_SCREEN;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.CHATS_SCREEN,
      page: () => ChatsScreenView(),
      binding: ChatsScreenBinding(),
    ),
    GetPage(
      name: _Paths.CHAT_SCREEN,
      page: () => ChatScreenView(),
      binding: ChatScreenBinding(),
    ),
  ];
}
