import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather/providers/weather_provider.dart';
import 'package:weather/widgets/chat_message_bubble.dart';

class GeminiScreen extends ConsumerStatefulWidget {
  const GeminiScreen({
    super.key,
    required this.isClickedFromOtherScreen,
  });

  final bool isClickedFromOtherScreen;

  @override
  ConsumerState<GeminiScreen> createState() => _GeminiScreenState();
}

class _GeminiScreenState extends ConsumerState<GeminiScreen> {
  TextEditingController controller = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  Candidates? response;
  bool isContextSend = false;
  List<Content> chatHistory = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    if (widget.isClickedFromOtherScreen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        autoSend();
      });
    }
  }

  void sendMessage(
    String text,
    Map<String, dynamic> currentWeather,
    List<dynamic> hourlyWeather,
    List<dynamic> weeklyweather,
  ) async {
    if (text.trim().isEmpty) return;

    final gemini = Gemini.instance;

    setState(() {
      messages.add({"sender": "user", "message": text});
        });
    _scrollToBottom();
    chatHistory.add(Content(parts: [Part.text(text)], role: "user"));

    try {
      Map<String, dynamic> finalGeminiPrompt = {"Question": text};
      final fullWeatherContext = {
        "currentWeather": currentWeather,
        "hourlyWeather": hourlyWeather,
        "weeklyWeather": weeklyweather,
      };
      if (!isContextSend) {
        finalGeminiPrompt = {
          "Question": text,
          "Context": fullWeatherContext,
        };
        isContextSend = true;
      }

      response = await gemini.chat(
        chatHistory,
        systemPrompt:
            'You are a strict weather assistant. Continue answering questions based ONLY on the weather data provided. $finalGeminiPrompt , in the units like degress, and km/s .',
      );
      final reply = response?.output ?? 'No response';
      setState(() {
        messages.add({"sender": "gemini", "message": reply});
      });
      _scrollToBottom();
      chatHistory.add(
        Content(parts: [Part.text(reply)], role: "model"),
      );
    } catch (e) {
      setState(() {
        messages.add({"sender": "gemini", "message": e.toString()});
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      ),
    );
  }

  void autoSend() {
    final weatherForAutoSend = ref.read(weatherProvider);

    controller.text = "Give me a summary of today's weather";
    sendMessage(
      controller.text,
      weatherForAutoSend.currentWeather,
      weatherForAutoSend.hourlyWeather,
      weatherForAutoSend.weeklyWeather,
    );
    controller.clear();
  }

  @override
  void dispose() {
    controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentWeather = ref.watch(weatherProvider).currentWeather;
    final hourlyWeather = ref.watch(weatherProvider).hourlyWeather;
    final weeklyweather = ref.watch(weatherProvider).weeklyWeather;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Weather Assistant',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF4A90E2),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        // ← same gradient as home screen
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4A90E2), Color(0xFF1B3A6B)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ← message list
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.wb_cloudy_outlined,
                              size: 64,
                              color: Colors.white.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Ask me anything about\nyour weather',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white.withValues(
                                  alpha: 0.5,
                                ),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final messageMap = messages[index];
                          final sender = messageMap["sender"];
                          final message = messageMap["message"];

                          return ChatMessageBubble(
                            child: message,
                            isUser: sender == "user",
                          );
                        },
                      ),
              ),

              // ← input bar — glass style matching home screen
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Ask about your weather...',
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        sendMessage(
                          controller.text,
                          currentWeather,
                          hourlyWeather,
                          weeklyweather,
                        );
                        controller.clear();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(
                              alpha: 0.3,
                            ),
                          ),
                        ),
                        child: const Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
