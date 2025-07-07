import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/text_style.dart';
import 'nutrition_card.dart';

class ChatMessage {
  final String message;
  final bool isUser;
  final Widget? nutritionCard;

  ChatMessage({
    required this.message,
    required this.isUser,
    this.nutritionCard,
  });
}

class ChatMessageList extends StatelessWidget {
  final List<ChatMessage> messages;

  const ChatMessageList({
    super.key,
    required this.messages,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      reverse: true,
      itemBuilder: (context, index) {
        final message = messages[index];
        return MessageBubble(
          message: message.message,
          isUser: message.isUser,
          nutritionCard: message.nutritionCard,
        );
      },
      itemCount: messages.length,
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isUser;
  final Widget? nutritionCard;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isUser,
    this.nutritionCard,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                size: 18,
                color: AppTheme.primaryPurple,
              ),
            ),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.only(
                    left: isUser ? 64 : 0,
                    right: isUser ? 0 : 64,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppTheme.primaryPurple
                        : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isUser ? 16 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 16),
                    ),
                    border: isUser
                        ? null
                        : Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message,
                    style: AppTextStyle.bodyMedium(context).copyWith(
                      color: isUser ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (nutritionCard != null) ...[
                  const SizedBox(height: 8),
                  nutritionCard!,
                ],
              ],
            ),
          ),
          if (isUser) ...[
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryCoral.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.person,
                size: 18,
                color: AppTheme.primaryCoral,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
