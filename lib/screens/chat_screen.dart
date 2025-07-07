import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/text_style.dart';

class ChatMessage {
  final String message;
  final bool isUser;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isTyping;

  ChatMessage({
    required this.message,
    required this.isUser,
    this.imageUrl,
    DateTime? timestamp,
    this.isTyping = false,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  late AnimationController _typingAnimationController;

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // เพิ่มข้อความต้อนรับ
    _messages.add(
      ChatMessage(
        message: "👋 สวัสดีครับ! ผมคือ AI ที่ปรึกษาด้านอาหารและโภชนาการ\n\nผมสามารถช่วยคุณได้ในเรื่องต่างๆ เช่น:\n• วิเคราะห์อาหารจากรูปภาพ\n• คำนวณแคลอรี่และโภชนาการ\n• แนะนำเมนูอาหาร\n\nลองถ่ายรูปอาหารหรือถามคำถามได้เลยครับ! 😊",
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSendMessage(String message) {
    if (message.trim().isEmpty) return;

    setState(() {
      _messages.insert(0, ChatMessage(message: message, isUser: true));
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();

    // จำลองการ typing และตอบกลับ
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isTyping = false;
        String response = _getAIResponse(message);
        _messages.insert(0, ChatMessage(message: response, isUser: false));
      });
      _scrollToBottom();
    });
  }

  void _handleImageUpload() {
    // จำลองการอัพโหลดรูป
    setState(() {
      _messages.insert(0, ChatMessage(
        message: "📷 รูปอาหารที่คุณส่งมา",
        isUser: true,
        imageUrl: "https://picsum.photos/300/200",
      ));
      _isTyping = true;
    });

    _scrollToBottom();

    // จำลองการวิเคราะห์รูป
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isTyping = false;
        _messages.insert(0, ChatMessage(
          message: "🔍 จากรูปที่คุณส่งมา ผมวิเคราะห์แล้วเห็นว่าเป็น:\n\n🍳 **ข้าวผัดกุ้ง**\n📊 **ประมาณ 350-400 แคลอรี่**\n\n**ส่วนประกอบหลัก:**\n• ข้าวสวย - 250 kcal\n• กุ้ง - 80 kcal\n• ไข่ - 70 kcal\n• น้ำมัน - 50 kcal\n\n💡 **คำแนะนำ:** เป็นอาหารที่มีโปรตีนดี เหมาะสำหรับมื้อหลัก แต่ควรเพิ่มผักให้มากขึ้นนะครับ!",
          isUser: false,
        ));
      });
      _scrollToBottom();
    });
  }

  String _getAIResponse(String message) {
    message = message.toLowerCase();

    if (message.contains('แคลอรี่') || message.contains('calorie')) {
      return '📊 **เรื่องแคลอรี่**\n\nแคลอรี่คือหน่วยวัดพลังงานในอาหาร\n\n**ความต้องการต่อวัน:**\n• ผู้ชาย: 2,000-2,500 kcal\n• ผู้หญิง: 1,800-2,000 kcal\n\n💡 **Tips:** ขึ้นอยู่กับอายุ น้ำหนัก และกิจกรรมด้วยนะครับ!';
    } else if (message.contains('อาหาร') || message.contains('กิน') || message.contains('เมนู')) {
      return '🍽️ **เรื่องอาหาร**\n\n**หลักการกินดี:**\n• กินครบ 5 หมู่\n• ผักผลไม้ 5-9 ส่วนต่อวัน\n• ดื่มน้ำ 8-10 แก้ว\n• หลีกเลี่ยงอาหารทอด หวาน มัน\n\n🥗 ต้องการแนะนำเมนูเฉพาะไหมครับ?';
    } else if (message.contains('ลดน้ำหนัก') || message.contains('diet')) {
      return '⚖️ **การลดน้ำหนัก**\n\n**หลักการ:**\n• สร้าง Calorie Deficit\n• กิน 500 kcal น้อยกว่าที่ใช้\n• ออกกำลังกาย 150 นาที/สัปดาห์\n\n**อาหารแนะนำ:**\n🥗 สลัด, ไก่ต้ม, ปลาย่าง\n🚫 หลีกเลี่ยง: ทอด, หวาน, แป้ง\n\n💪 อดทน + สม่ำเสมอคือกุญแจสำคัญครับ!';
    } else if (message.contains('สวัสดี') || message.contains('hello') || message.contains('hi')) {
      return '👋 สวัสดีครับ! ยินดีที่ได้ช่วยเหลือ\n\n**ผมสามารถช่วยได้:**\n📷 วิเคราะห์รูปอาหาร\n📊 คำนวณแคลอรี่\n🍽️ แนะนำเมนู\n💪 คำแนะนำเรื่องสุขภาพ\n\nมีอะไรให้ช่วยไหมครับ? 😊';
    } else if (message.contains('ขอบคุณ') || message.contains('thank')) {
      return '🙏 ยินดีครับ! หวังว่าจะเป็นประโยชน์นะครับ\n\nหากมีคำถามเพิ่มเติมเรื่องอาหาร โภชนาการ หรือสุขภาพ สามารถถามได้ตลอดเวลาเลยครับ! 😊';
    }

    return '🤔 ขอโทษครับ ผมไม่ค่อยเข้าใจคำถาม\n\n**ลองถามเรื่องเหล่านี้ดูครับ:**\n📷 "วิเคราะห์รูปอาหารหน่อย"\n📊 "แคลอรี่ในข้าวผัดเท่าไหร่"\n🍽️ "แนะนำเมนูลดน้ำหนัก"\n\nหรือส่งรูปอาหารมาให้ผมวิเคราะห์ก็ได้ครับ! 😊';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
          _buildHeader(),
          // Messages
          Expanded(
            child: _buildMessageList(),
          ),
          // Quick Actions
          _buildQuickActions(),
          // Input Bar
          _buildInputBar(),
          // Safe Area
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryPurple, AppTheme.primaryPurple.withAlpha(204)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.smart_toy,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI ที่ปรึกษาโภชนาการ',
                      style: AppTextStyle.titleMedium(context).copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'พร้อมช่วยวิเคราะห์อาหารและให้คำแนะนำ',
                      style: AppTextStyle.bodySmall(context).copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'ออนไลน์',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
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

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == 0 && _isTyping) {
          return _buildTypingIndicator();
        }

        final messageIndex = _isTyping ? index - 1 : index;
        final message = _messages[messageIndex];
        return _buildMessageBubble(message);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.smart_toy,
                color: AppTheme.primaryPurple,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppTheme.primaryPurple
                    : Colors.white,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: message.isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: message.isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.imageUrl != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        message.imageUrl!,
                        width: double.infinity,
                        height: 150,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 150,
                            color: Colors.grey[200],
                            child: const Icon(Icons.image_not_supported),
                          );
                        },
                      ),
                    ),
                    if (message.message.isNotEmpty) const SizedBox(height: 8),
                  ],
                  if (message.message.isNotEmpty)
                    Text(
                      message.message,
                      style: AppTextStyle.bodyMedium(context).copyWith(
                        color: message.isUser ? Colors.white : Colors.black87,
                        height: 1.4,
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                color: AppTheme.primaryPurple,
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.primaryPurple.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.smart_toy,
              color: AppTheme.primaryPurple,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedBuilder(
              animation: _typingAnimationController,
              builder: (context, child) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(3, (index) {
                    final delay = index * 0.2;
                    final animationValue = (_typingAnimationController.value - delay).clamp(0.0, 1.0);
                    return Container(
                      margin: EdgeInsets.only(right: index < 2 ? 4 : 0),
                      child: Transform.translate(
                        offset: Offset(0, -8 * (animationValue < 0.5
                            ? 2 * animationValue
                            : 2 * (1 - animationValue))),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildQuickActionChip(
              '📷 วิเคราะห์รูปอาหาร',
                  () => _handleImageUpload(),
            ),
            const SizedBox(width: 8),
            _buildQuickActionChip(
              '📊 คำนวณแคลอรี่',
                  () => _handleSendMessage('คำนวณแคลอรี่ให้หน่อย'),
            ),
            const SizedBox(width: 8),
            _buildQuickActionChip(
              '🍽️ แนะนำเมนู',
                  () => _handleSendMessage('แนะนำเมนูอาหารหน่อย'),
            ),
            const SizedBox(width: 8),
            _buildQuickActionChip(
              '💪 ลดน้ำหนัก',
                  () => _handleSendMessage('แนะนำวิธีลดน้ำหนัก'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryPurple.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryPurple.withOpacity(0.2),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: AppTheme.primaryPurple,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Camera Button
          GestureDetector(
            onTap: _handleImageUpload,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt,
                color: AppTheme.primaryPurple,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Text Input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'พิมพ์ข้อความหรือถ่ายรูปอาหาร...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: _handleSendMessage,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Send Button
          GestureDetector(
            onTap: () => _handleSendMessage(_messageController.text),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple,
                shape: BoxShape.circle,
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
    );
  }
}