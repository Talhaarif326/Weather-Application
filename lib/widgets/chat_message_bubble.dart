import 'dart:ui';
import 'package:flutter/material.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.child,
    required this.isUser,
  });
  final String child;
  final bool isUser;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                bottom: 4,
                left: 4,
                right: 4,
              ),
              child: Text(
                isUser ? 'You' : 'Gemini',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white60,
                ),
              ),
            ),
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isUser
                    ? const Radius.circular(16)
                    : Radius.zero,
                bottomRight: isUser
                    ? Radius.zero
                    : const Radius.circular(16),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? Colors.white.withOpacity(0.25)
                        : Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isUser
                          ? const Radius.circular(16)
                          : Radius.zero,
                      bottomRight: isUser
                          ? Radius.zero
                          : const Radius.circular(16),
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Text(
                    child,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
