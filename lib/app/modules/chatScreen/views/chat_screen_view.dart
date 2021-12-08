import 'package:chat_app/app/data/chat.dart';
import 'package:chat_app/app/data/chat_message.dart';
import 'package:chat_app/app/data/chat_user.dart';
import 'package:chat_app/utils/date_formatter.dart';
import 'package:chat_app/utils/switch_appbar.dart';
import 'package:chat_ui_kit/chat_ui_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';

import '../controllers/chat_screen_controller.dart';

class ChatScreenView extends GetView<ChatScreenController> {




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
    controller.messageController.insertAll(0,[
      ChatMessage(
          author: controller.currentUser,
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
    controller.messageController.selectedItems.forEach((element) {
      text += element.text ?? "";
      text += '\n';
    });
    Clipboard.setData(ClipboardData(text: text)).then((value) {
      print("text selected");
      controller.messageController.unSelectAll();
    });
  }

  void deleteSelectedMessages() {
    controller.messageController.removeSelectedItems();
    //update app bar
    // setState(() {});
  }

  Widget _buildChatTitle() {
    if (controller.isGroupChat) {
      return Text(controller.chat.name);
    } else {
      final _user = controller.chat.membersWithoutSelf.first;
      return Row(children: [
        ClipOval(
            child: Image.asset(_user.avatar,
                width: 32, height: 32, fit: BoxFit.cover)),
        Expanded(
            child: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text(_user.username ?? "",
                    overflow: TextOverflow.ellipsis)))
      ]);
    }
  }

  Widget _buildMessageBody(
      context, index, item, messagePosition, MessageFlow messageFlow) {
    final _chatMessage = item as ChatMessage;
    Widget _child;

    if (_chatMessage.type == ChatMessageType.text) {
      _child = chatMessageText(Get.context!,index, item, messagePosition, messageFlow);
    } else if (_chatMessage.type == ChatMessageType.image) {
      _child = ChatMessageImage(index, item, messagePosition, messageFlow,
          callback: () => onItemPressed(index, item));
    } else if (_chatMessage.type == ChatMessageType.video) {
      _child = ChatMessageVideo(index, item, messagePosition, messageFlow);
    } else if (_chatMessage.type == ChatMessageType.audio) {
      _child = ChatMessageAudio(index, item, messagePosition, messageFlow);
    } else {
      //return text message as default
      _child = chatMessageText(Get.context!,index, item, messagePosition, messageFlow);
    }

    if (messageFlow == MessageFlow.incoming) return _child;
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Align(alignment: Alignment.centerRight, child: _child));
  }

  Widget _buildDate(BuildContext context, DateTime date) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Align(
                child: Text(
                    DateFormatter.getVerboseDateTimeRepresentation(
                        context, date),
                    style:
                    TextStyle(color: Theme.of(context).disabledColor)))));
  }

  Widget _buildEventMessage(context, animation, index, item, messagePosition) {
    final _chatMessage = item as ChatMessage;
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Align(
                child: Text(
                  _chatMessage.messageText(controller.currentUser.id),
                  style: TextStyle(color: Theme.of(context).disabledColor),
                  textAlign: TextAlign.center,
                ))));
  }

  Widget _buildMessagesList() {
    IncomingMessageTileBuilders incomingBuilders = controller.isGroupChat
        ? IncomingMessageTileBuilders(
        bodyBuilder: (context, index, item, messagePosition) =>
            _buildMessageBody(context, index, item, messagePosition,
                MessageFlow.incoming),
        avatarBuilder: (context, index, item, messagePosition) {
          final _chatMessage = item as ChatMessage;
          return Padding(
              padding: EdgeInsets.only(right: 16),
              child: ClipOval(
                  child: Image.asset(_chatMessage.author!.avatar,
                      width: 32, height: 32, fit: BoxFit.cover)));
        })
        : IncomingMessageTileBuilders(
        bodyBuilder: (context, index, item, messagePosition) =>
            _buildMessageBody(context, index, item, messagePosition,
                MessageFlow.incoming),
        titleBuilder: null);

    return Expanded(
        child: MessagesList(
            controller: controller.messageController,
            appUserId: controller.currentUser.id,
            useCustomTile: (i, item, pos) {
              final msg = item as ChatMessage;
              return msg.isTypeEvent;
            },
            messagePosition: _messagePosition,
            builders: MessageTileBuilders(
                customTileBuilder: _buildEventMessage,
                customDateBuilder: _buildDate,
                incomingMessageBuilders: incomingBuilders,
                outgoingMessageBuilders: OutgoingMessageTileBuilders(
                    bodyBuilder: (context, index, item, messagePosition) =>
                        _buildMessageBody(context, index, item, messagePosition,
                            MessageFlow.outgoing)))));
  }

  /// Override [MessagePosition] to return [MessagePosition.isolated] when
  /// our [ChatMessage] is an event
  MessagePosition _messagePosition(
      MessageBase? previousItem,
      MessageBase currentItem,
      MessageBase? nextItem,
      bool Function(MessageBase currentItem) shouldBuildDate) {
    ChatMessage? _previousItem = previousItem as ChatMessage?;
    final ChatMessage _currentItem = currentItem as ChatMessage;
    ChatMessage? _nextItem = nextItem as ChatMessage?;

    if (shouldBuildDate(_currentItem)) {
      _previousItem = null;
    }

    if (_nextItem?.isTypeEvent == true) _nextItem = null;
    if (_previousItem?.isTypeEvent == true) _previousItem = null;

    if (_previousItem?.author?.id == _currentItem.author?.id &&
        _nextItem?.author?.id == _currentItem.author?.id) {
      return MessagePosition.surrounded;
    } else if (_previousItem?.author?.id == _currentItem.author?.id &&
        _nextItem?.author?.id != _currentItem.author?.id) {
      return MessagePosition.surroundedTop;
    } else if (_previousItem?.author?.id != _currentItem.author?.id &&
        _nextItem?.author?.id == _currentItem.author?.id) {
      return MessagePosition.surroundedBot;
    } else {
      return MessagePosition.isolated;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: SwitchAppBar(
          showSwitch: controller.messageController.isSelectionModeActive,
          switchLeadingCallback: () => controller.messageController.unSelectAll(),
          primaryAppBar: AppBar(
            title: _buildChatTitle(),
            actions: [
              IconButton(
                  icon: Icon(Icons.more_vert), onPressed: onChatDetailsPressed)
            ],
          ),
          switchTitle: Text(controller.selectedItemsCount.toString(),
              style: TextStyle(color: Colors.black)),
          switchActions: [
            IconButton(
                icon: Icon(Icons.content_copy),
                color: Colors.black,
                onPressed: copyContent),
            IconButton(
                color: Colors.black,
                icon: Icon(Icons.delete),
                onPressed: deleteSelectedMessages),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMessagesList(),
            MessageInput(
                textController: controller.textController,
                sendCallback: onMessageSend,
                typingCallback: onTypingEvent),
          ],
        ));
  }



  Widget chatMessageText(BuildContext context, int index, ChatMessage message,
      MessagePosition messagePosition, MessageFlow messageFlow) {
    return MessageContainer(
        decoration: messageDecoration(context,
            messagePosition: messagePosition, messageFlow: messageFlow),
        child: Wrap(runSpacing: 4.0, alignment: WrapAlignment.end, children: [
          Text(message.text ?? ""),
          chatMessageFooter(Get.context!,index, message, messagePosition, messageFlow)
        ]));
  }

  Widget chatMessageFooter(BuildContext context, int index, ChatMessage message,
      MessagePosition messagePosition, MessageFlow messageFlow) {
    final Widget _date = chatMessageDate(Get.context!,index, message, messagePosition);
    return messageFlow == MessageFlow.incoming
        ? _date
        : Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _date,
        ]);
  }


  Widget chatMessageDate(BuildContext context, int index, ChatMessage message,
      MessagePosition messagePosition) {
    final color =
    message.isTypeMedia ? Colors.white : Theme.of(context).disabledColor;
    return Padding(
        padding: EdgeInsets.only(left: 8),
        child: Text(
            DateFormatter.getVerboseDateTimeRepresentation(
                context, message.createdAt,
                timeOnly: true),
            style: TextStyle(color: color)));
  }


}
