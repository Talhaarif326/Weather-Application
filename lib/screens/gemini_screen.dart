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

  void sendMessage(String text) async {
    final fullWeatherContext = {
      "current Weather ": ref.watch(weatherProvider).currentWeather,
      "hourly weather ": ref.watch(weatherProvider).hourlyWeather,
      "weeklyWeather": ref.watch(weatherProvider).weeklyWeather,
    };
    final gemini = Gemini.instance;
    try {
      response = await gemini.chat(
        [
          Content(parts: [Part.text(text)]),
        ],
        systemPrompt:
            '''
            You are a helpful weather assistant.

            Here is the current weather data: $fullWeatherContext 
            Instructions:
              - Answer questions based on this data only.
              - Be conversational and friendly.
              - Convert technical values to human language.
              - If asked something not in the data, say you dont have that information. ''',
      );
      setState(() {
        messages.add({"sender": "user", "message": text});
      });
    } catch (e) {
      AlertDialog(content: Text("$e"));
    }
    if (response?.output == null) {
      return;
    }
    geminiResponse = response?.output;
    setState(() {
      messages.add({"sender": "gemini", "message": geminiResponse});
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
                final messageMap = messages[index];
                final sender = messageMap["sender"];
                final message = messageMap["message"];

                if (geminiResponse == null) {
                  return Text('Reponse Error');
                }

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
