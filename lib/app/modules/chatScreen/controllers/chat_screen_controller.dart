import 'package:chat_app/app/models/chat.dart';
import 'package:chat_app/app/models/chat_message.dart';
import 'package:chat_app/app/models/chat_user.dart';
import 'package:chat_app/app/modules/chatsScreen/controllers/chats_screen_controller.dart';
import 'package:chat_app/utils/app_const.dart';
import 'package:chat_ui_kit/chat_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ChatScreenController extends GetxController {

  final TextEditingController textController = TextEditingController();
  /// The data controller
  final MessagesListController messageController = MessagesListController();
  /// Whether at least 1 message is selected
  int selectedItemsCount = 0;

  // ChatWithMembers get chat => args.chat;
  ChatWithMembers get chat => Get.arguments['chat'];
  /// Whether it's a group chat (more than 2 users)
  bool get isGroupChat => chat.members.length > 2;


  ChatsScreenController  chatScreenController=Get.find<ChatsScreenController>();
  ChatUser get currentUser => chatScreenController.chatUsers[0];
  Map<String, List<ChatMessage>> chatMessages = {};


  @override
  void onInit() {
    chatMessages=chatScreenController.chatMessages;
    messageController.addAll( chatMessages[chat.id] ?? []);
    messageController.selectionEventStream.listen((event) {
      // setState(() {
      selectedItemsCount = event.currentSelectionCount;
      update();
      // });
    });
    super.onInit();

  }


  /// Called when the user pressed the top right corner icon
  void onChatDetailsPressed() {
    print("Chat details pressed");
  }

  /// Called when a user tapped an item
  void onItemPressed(int index, MessageBase message) {
    print(
        "item pressed, you could display images in full screen or play videos with this callback");
  }

  void onMessageSend(String text) {
    messageController.insertAll(0,[
      ChatMessage(
          author: currentUser,
          text: text,
          creationTimestamp: DateTime.now().millisecondsSinceEpoch)
    ]);
  }

  void onTypingEvent(TypingEvent event) {
    print("typing event received: $event");
  }

  /// Copy the selected comment's comment to the clipboard.
  /// Reset selection once copied.
  void copyContent() {
    String text = "";
    messageController.selectedItems.forEach((element) {
      text += element.text ?? "";
      text += '\n';
    });
    Clipboard.setData(ClipboardData(text: text)).then((value) {
      print("text selected");
      messageController.unSelectAll();
    });
  }

  void deleteSelectedMessages() {
    messageController.removeSelectedItems();
    update();
    //update app bar
    // setState(() {});
  }


  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }


}
