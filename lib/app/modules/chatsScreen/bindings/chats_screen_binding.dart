import 'package:get/get.dart';

import '../controllers/chats_screen_controller.dart';

class ChatsScreenBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatsScreenController>(
      () => ChatsScreenController(),
    );
  }
}
