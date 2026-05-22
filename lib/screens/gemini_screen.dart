import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather/providers/weather_provider.dart';

import 'package:weather/widgets/chat_message_bubble.dart';

class GeminiScreen extends ConsumerStatefulWidget {
  const GeminiScreen({super.key});

  @override
  ConsumerState<GeminiScreen> createState() => _GeminiScreenState();
}

class _GeminiScreenState extends ConsumerState<GeminiScreen> {
  TextEditingController controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  Candidates? response;
  String? geminiResponse;
  bool isContextSend = false;
  List<Content> chatHistory = [];

  void sendMessage(
    String text,
    Map<String, dynamic> currentWeather,
    List<dynamic> hourlyWeather,
    List<dynamic> weeklyweather,
  ) async {
    if (text.trim().isEmpty) {
      return;
    }

    final gemini = Gemini.instance;

    setState(() {
      messages.add({"sender": "user", "message": text});
    });
    chatHistory.add(Content(parts: [Part.text(text)], role: "user"));
    try {
      Map<String, dynamic> finalGeminiPrompt = {"Question": text};
      final fullWeatherContext = {
        "currentWeather":currentWeather,
        "hourlyWeather":hourlyWeather,
        "weeklyWeather": weeklyweather,
      };
      if (!isContextSend) {
        finalGeminiPrompt = {
          "Question": text,
          "Context": fullWeatherContext,
        };
        isContextSend = true;
      }
      print(
        " weekly weather ${fullWeatherContext['weeklyWeather']}",
      );

      response = await gemini.chat(
        chatHistory,
        systemPrompt:
            'You are a strict weather assistant. Continue answering questions based ONLY on the weather data provided. $finalGeminiPrompt',
      );
      final reply = response?.output ?? 'No response';
      setState(() {
        messages.add({"sender": "gemini", "message": reply});
      });
      chatHistory.add(
        Content(parts: [Part.text(reply)], role: "model"),
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentWeather = ref.watch(weatherProvider).currentWeather;
    final hourlyWeather = ref.watch(weatherProvider).hourlyWeather;
    final weeklyweather = ref.watch(weatherProvider).weeklyWeather;
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final messageMap = messages[index];
                final sender = messageMap["sender"];
                final message = messageMap["message"];

                if (sender == "user") {
                  return ChatMessageBubble(
                    child: message,
                    isUser: true,
                  );
                }
                if (sender == "gemini") {
                  return ChatMessageBubble(
                    child: message,
                    isUser: false,
                  );
                }
                return SizedBox.shrink();
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
                    sendMessage(
                      controller.text,
                      currentWeather,
                      hourlyWeather,
                      weeklyweather,
                    );
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
