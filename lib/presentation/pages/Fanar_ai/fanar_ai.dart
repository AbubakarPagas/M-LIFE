// FanarAi — public entry point for the Fanar AI feature.
// Import this single file from anywhere in the app to navigate to the AI chat.
//
// Usage:
//   Get.to(() => const FanarAiPage());
// or from the home screen / bottom nav:
//   const FanarAiPage()

import 'package:flutter/material.dart';

import 'presentation/chat/chat_screen.dart';

export 'presentation/chat/chat_screen.dart';
export 'presentation/chat/conversation_list_screen.dart';
export 'presentation/viewmodel/fanar_chat_controller.dart';

/// Top-level widget — wraps ChatScreen and ensures the controller is initialised.
class FanarAiPage extends StatelessWidget {
  const FanarAiPage({super.key});

  @override
  Widget build(BuildContext context) => const ChatScreen();
}
