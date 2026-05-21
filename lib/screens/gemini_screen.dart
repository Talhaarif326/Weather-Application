import 'package:flutter/material.dart';

import 'package:weather/widgets/chat_message_bubble.dart';

class GeminiScreen extends StatefulWidget {
  const GeminiScreen({super.key});

  @override
  State<GeminiScreen> createState() => _GeminiScreenState();
}

class _GeminiScreenState extends State<GeminiScreen> {
  TextEditingController controller = TextEditingController();
  List<String> messages = [];

  void sendMessage(String text) {
    setState(() {
      messages.add(text);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ChatMessageBubble(child: messages[index]);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 50,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: TextStyle(color: Colors.white),

                    decoration: InputDecoration(
                      hintText: 'Enter message ...',
                      hintStyle: TextStyle(color: Colors.white),
                      contentPadding: EdgeInsets.all(8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    sendMessage(controller.text);
                    controller.clear();
                  },
                  icon: Icon(
                    Icons.send,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
