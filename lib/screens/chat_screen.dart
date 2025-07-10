import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/text_style.dart';

class ChatMessage {
  final String message;
  final bool isUser;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isTyping;
  final ChatMessageType type;

  ChatMessage({
    required this.message,
    required this.isUser,
    this.imageUrl,
    DateTime? timestamp,
    this.isTyping = false,
    this.type = ChatMessageType.general,
  }) : timestamp = timestamp ?? DateTime.now();
}

enum ChatMessageType {
  general,
  mealPlan,
  healthAdvice,
  exerciseGuide,
  goalProgress
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _textFieldFocusNode = FocusNode();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  bool _isKeyboardVisible = false;
  bool _isTextFieldFocused = false;
  bool _hasUserStartedTyping = false; // เพิ่มตัวแปรเพื่อติดตามว่าผู้ใช้เคยพิมพ์แล้วหรือยัง
  late AnimationController _typingAnimationController;
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;

  @override
  void initState() {
    super.initState();
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeInOut,
    ));

    // เริ่มต้นด้วยการแสดง header
    _headerAnimationController.forward();

    // Listen to focus changes
    _textFieldFocusNode.addListener(() {
      setState(() {
        _isTextFieldFocused = _textFieldFocusNode.hasFocus;
      });

      // เมื่อ TextField ได้รับ focus ครั้งแรก ให้ซ่อน header และไม่แสดงอีก
      if (_isTextFieldFocused && !_hasUserStartedTyping) {
        _hasUserStartedTyping = true; // ทำเครื่องหมายว่าผู้ใช้เริ่มพิมพ์แล้ว
        _headerAnimationController.reverse(); // ซ่อน header
      }

      print('TextField focus changed: $_isTextFieldFocused, hasStartedTyping: $_hasUserStartedTyping');
    });

    // เพิ่มข้อความต้อนรับ
    _messages.add(
      ChatMessage(
        message: "👋 สวัสดีครับ! ผมคือ AI ที่ปรึกษาด้านอาหารและโภชนาการ\n\nผมสามารถช่วยคุณได้ในเรื่องต่างๆ เช่น:\n• วิเคราะห์อาหารจากรูปภาพ\n• คำนวณแค���อรี่และโภชนาการ\n• แนะนำเมนูอาหาร\n\nลองถ่ายรูปอาหารหรือถามคำถามได้เลยครับ! 😊",
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _typingAnimationController.dispose();
    _headerAnimationController.dispose(); // Dispose Animation Controller
    _textFieldFocusNode.dispose(); // Dispose FocusNode
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

  void _handleAIResponse(String message, {ChatMessageType type = ChatMessageType.general}) {
    setState(() {
      _messages.add(ChatMessage(
        message: message,
        isUser: false,
        type: type,
        isTyping: false,
      ));
    });
    _scrollToBottom();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text;
    setState(() {
      _messages.add(ChatMessage(
        message: userMessage,
        isUser: true,
      ));
      _messageController.clear();

      // Add AI typing indicator
      _messages.add(ChatMessage(
        message: "AI is typing...",
        isUser: false,
        isTyping: true,
      ));
    });
    _scrollToBottom();

    // Simulate AI response based on message content
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.removeLast(); // Remove typing indicator
      });

      if (userMessage.toLowerCase().contains("อาหาร") ||
          userMessage.toLowerCase().contains("แผน")) {
        _handleAIResponse(
          "นี่คือแผนอาหารที่แนะนำตามเป้าหมายของคุณ:\n\n"
          "🍳 เช้า: โจ๊กไข่ขาว (200 kcal)\n"
          "🥗 กลางวัน: สลัดอกไก่ (350 kcal)\n"
          "🍖 เย็น: ปลาย่างผักต้ม (400 kcal)",
          type: ChatMessageType.mealPlan
        );
      } else if (userMessage.toLowerCase().contains("ออกกำลังกาย")) {
        _handleAIResponse(
          "แนะนำการออกกำลังกายสำหรับวันนี้:\n\n"
          "🏃‍♂️ วิ่งเบาๆ 20 นาที\n"
          "💪 กายบริหาร 15 นาที\n"
          "🧘‍♀️ ยืดเหยียด 10 นาที",
          type: ChatMessageType.exerciseGuide
        );
      } else {
        _handleAIResponse(
          "ฉันเป็น AI โค้ชส่วนตัวของคุณ สามารถช่วยเรื่องต่อไปนี้:\n"
          "• วางแผนอาหาร\n"
          "• แนะนำการออกกำลังกาย\n"
          "• ตอบคำถามด้านสุขภาพ\n"
          "• ติดตามความก้าวหน้า",
          type: ChatMessageType.general
        );
      }
    });
  }

  String _getAIResponse(String message) {
    message = message.toLowerCase();

    if (message.contains('แคลอรี่') || message.contains('calorie')) {
      return '📊 **เรื่องแคลอรี่**\n\nแคลอรี่คือหน่วยวัดพลังงานในอาหาร\n\n**ความต้องการต่อวัน:**\n• ผู้ชาย: 2,000-2,500 kcal\n• ผู้หญิง: 1,800-2,000 kcal\n\n💡 **Tips:** ขึ้นอยู่กับอายุ น้ำหนัก และกิจกรรมด้วยนะครับ!';
    } else if (message.contains('ออกกำลังกาย') || message.contains('exercise') || message.contains('วิ่ง') || message.contains('เดิน')) {
      return '🏃‍♂️ **การออกกำลังกาย**\n\n**แคลอรี่ที่เผาผลาญ (น้ำหนัก 65 กก.):**\n• เดินเร็ว (30 นาที): 150 kcal\n• วิ่งเบาๆ (30 นาที): 300 kcal\n• ปั่นจักรยาน (30 นาที): 250 kcal\n• ว่ายน้ำ (30 นาที): 350 kcal\n\n💪 **คำแนะนำ:** ออกกำลังกายอย่างน้อย 150 นาที/สัปดาห์';
    } else if (message.contains('คำนวณ') || message.contains('calculate')) {
      return '🧮 **เครื่องคำนวณ**\n\n**คำนวณได้:**\n• แคลอรี่ที่เผาผลาญจากการออกกำลังกาย\n• BMR (อัตราการเผาผลาญพื้นฐาน)\n• BMI (ดัชนีมวลกาย)\n• ความต้องการน้ำต่อวัน\n\n📱 **วิธีใช้:** พิมพ์ "คำนวณ BMI" หรือ "คำนวณแคลอรี่การวิ่ง 30 นาที"';
    } else if (message.contains('bmi')) {
      return '📏 **คำนวณ BMI**\n\n**สูตร:** น้ำหนัก (กก.) ÷ ส่วน���ูง² (ม.)\n\n**เกณฑ์ประเมิน:**\n• ต่ำกว่า 18.5: ผอมเกินไป\n• 18.5-22.9: ปกติ\n• 23-24.9: ท้วม\n• 25-29.9: อ้วน\n• 30 ขึ้นไป: อ้วนมาก\n\n💡 **ตัวอย่าง:** สูง 170 ซม. น้ำหนัก 65 กก.\nBMI = 65 ÷ (1.7)² = 22.5 (ปกติ)';
    } else if (message.contains('น้ำ') || message.contains('water')) {
      return '💧 **การดื่มน้ำ**\n\n**ความต้องการน้ำต่อวัน:**\n• ผู้ชาย: 2.5-3 ลิตร\n• ผู้หญิง: 2-2.5 ลิตร\n\n**เพิ่มเติมเมื่อ:**\n• ออกกำลังกาย: +500-750 มล./ชม.\n• อากาศร้อน: +300-500 มล.\n• ป่วยไข้: +500-1000 มล.\n\n🕐 **Tips:** ดื่มน้ำทุก 2 ชม. อย่ารอจนหิว!';
    } else if (message.contains('อาหาร') || message.contains('กิน') || message.contains('เมนู')) {
      return '🍽️ **เรื่องอาหาร**\n\n**หลักการกินดี:**\n• กินครบ 5 หมู่\n• ผักผลไม้ 5-9 ส่วนต่อวัน\n• ดื่มน้ำ 8-10 แก้ว\n• หลีกเลี่ยงอาหารทอด หวาน มัน\n\n🥗 ต้องการแนะนำเมนูเฉพาะไหมครับ?';
    } else if (message.contains('ลดน้ำหนัก') || message.contains('diet')) {
      return '⚖️ **การลดน้ำหนัก**\n\n**หลักการ:**\n• สร้าง Calorie Deficit\n• กิน 500 kcal น้อยกว่าที่ใช้\n• ออกกำลังกาย 150 นาที/สัปดาห์\n\n**อาหารแนะนำ:**\n🥗 สลัด, ไก่ต้ม, ปลาย่าง\n🚫 หลีกเลี่ยง: ทอด, หวาน, แป้ง\n\n💪 อดทน + สม่ำเสมอคือกุญแจสำคัญครับ!';
    } else if (message.contains('เพิ่มน้ำหนัก') || message.contains('เพิ่มกล้าม')) {
      return '💪 **การเพิ่มน้ำหนัก/กล้ามเนื้อ**\n\n**หลักการ:**\n• กิน Calorie Surplus 300-500 kcal\n• โปรตีน 1.6-2.2 กรัม/กก.น้ำหนัก\n• เวทเทรนนิ่ง 3-4 ครั้ง/สัปดาห์\n\n**อาหารแนะนำ:**\n🍖 ไก่ ปลา ไข่ ถั่ว\n🍚 ข้าวกล้อง ข้าวโอ๊ต\n🥜 ถั่วอัลมอนด์ อโวคาโด\n\n📈 **เป้าหมาย:** เพิ่ม 0.5-1 กก./เดือน';
    } else if (message.contains('สวัสดี') || message.contains('hello') || message.contains('hi')) {
      return '👋 สวัสดีครับ! ยินดีที่ได้ช่วยเหลือ\n\n**ผมสามารถช่วยได้:**\n📷 วิเคราะห์รูปอาหาร\n🧮 คำนวณแคลอรี่และ BMI\n🏃‍♂️ แนะนำการออกกำลังกาย\n🍽️ แนะนำเมนูอาหาร\n💪 คำแนะนำเรื่องสุขภาพ\n\nมีอะไรให้ช่วยไหมครับ? 😊';
    } else if (message.contains('ขอบคุณ') || message.contains('thank')) {
      return '🙏 ยินดีครับ! หวังว่าจะเป็นประโยชน์นะครับ\n\nหากมีคำถามเพิ่มเ��ิมเรื่องอาหาร โภชนาการ หรือสุขภาพ สามารถถามได้ตลอดเวลาเลยครับ! 😊';
    }

    return '🤔 ขอโทษครับ ผมไม่ค่อยเข้าใจคำถาม\n\n**ลองถามเรื่องเหล่านี้ดูครับ:**\n📷 "วิเคราะห์รูปอาหารหน่อย"\n🧮 "คำนวณ BMI"\n🏃‍♂️ "แคลอรี่การวิ่ง 30 นาที"\n🍽️ "แนะนำเมนูลดน้ำหนัก"\n\nหรือส่งรูปอาหารมาให้ผมวิเคราะห์ก็ได้ครับ! 😊';
  }

  @override
  Widget build(BuildContext context) {
    // Check if keyboard is visible
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    // Update keyboard visibility state and handle unfocus when keyboard closes
    if (_isKeyboardVisible != isKeyboardVisible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          _isKeyboardVisible = isKeyboardVisible;
        });

        // ถ้า keyboard ปิดแล้วแต่ TextField ยัง focus อยู่ ให้ unfocus
        if (!isKeyboardVisible && _textFieldFocusNode.hasFocus) {
          _textFieldFocusNode.unfocus();
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header with smooth animation
          AnimatedBuilder(
            animation: _headerAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -100 * (1 - _headerAnimation.value)), // เลื่อนขึ้น/ลง
                child: Opacity(
                  opacity: _headerAnimation.value, // ค่อยๆ จางหาย/ปรากฏ
                  child: _headerAnimation.value > 0.1 ? _buildHeader() : const SizedBox(),
                ),
              );
            },
          ),
          // Messages
          Expanded(
            child: _buildMessageList(),
          ),
          // Quick Actions with smooth animation
          AnimatedBuilder(
            animation: _headerAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, 50 * (1 - _headerAnimation.value)), // เลื่อนลง/ขึ้น
                child: Opacity(
                  opacity: _headerAnimation.value, // ค่อยๆ จางหาย/ปรากฏ
                  child: _headerAnimation.value > 0.1 ? _buildQuickActions() : const SizedBox(),
                ),
              );
            },
          ),
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
              '🧮 คำนวณ BMI',
                  () => _handleSendMessage('คำนวณ BMI หน่อย'),
            ),
            const SizedBox(width: 8),
            _buildQuickActionChip(
              '🏃‍♂️ แคลอรี่การออกกำลังกาย',
                  () => _handleSendMessage('แคลอรี่การออกกำลังกาย'),
            ),
            const SizedBox(width: 8),
            _buildQuickActionChip(
              '🍽️ แนะนำเมนู',
                  () => _handleSendMessage('แนะนำเมนูอาหารหน่อย'),
            ),
            const SizedBox(width: 8),
            _buildQuickActionChip(
              '💧 ความต้องการน้ำ',
                  () => _handleSendMessage('ความต้องการน้ำต่อวัน'),
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
      padding: const EdgeInsets.all(12), // ลดจาก 16 เป็น 12
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
              width: 36, // ลดจาก 40 เป็น 36
              height: 36, // ลดจาก 40 เป็น 36
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.camera_alt,
                color: AppTheme.primaryPurple,
                size: 18, // ลดจาก 20 เป็น 18
              ),
            ),
          ),
          const SizedBox(width: 10), // ลดจาก 12 เป็น 10
          // Text Input
          Expanded(
            child: Container(
              height: 46, // กำหนดความสูงคงที่
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(18), // ลดจาก 20 เป็น 18
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _textFieldFocusNode,
                decoration: InputDecoration(
                  hintText: 'พิมพ์ข้อความ...',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14, // กำหนดขนาดฟอนต์
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, // ลดจาก 16 เป็น 14
                    vertical: 8, // ลดจาก 10 เป็น 8
                  ),
                ),
                maxLines: 1, // กำหนดให้แสดงแค่บรรทัดเดียว
                style: const TextStyle(fontSize: 14), // กำหนดขนาดฟอนต์ของข้อความ
                textInputAction: TextInputAction.send,
                onSubmitted: _handleSendMessage,
              ),
            ),
          ),
          const SizedBox(width: 10), // ลดจาก 12 เป็น 10
          // Send Button
          GestureDetector(
            onTap: () => _handleSendMessage(_messageController.text),
            child: Container(
              width: 36, // ลดจาก 40 เป็น 36
              height: 36, // ลดจาก 40 เป็น 36
              decoration: BoxDecoration(
                color: AppTheme.primaryPurple,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send,
                color: Colors.white,
                size: 18, // ลดจาก 20 เป็น 18
              ),
            ),
          ),
        ],
      ),
    );
  }
}
