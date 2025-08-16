import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../theme/app_theme.dart';
import '../../theme/text_style.dart';

class NetworkErrorScreen extends StatefulWidget {
  const NetworkErrorScreen({Key? key}) : super(key: key);

  @override
  State<NetworkErrorScreen> createState() => _NetworkErrorScreenState();
}

class _NetworkErrorScreenState extends State<NetworkErrorScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bounceAnimation;

  // Language configuration
  final bool _isThaiLanguage = true;
  // Localized text
  Map<String, String> get _texts => _isThaiLanguage
      ? {
    'title': 'ไม่มีการเชื่อมต่อ',
    'subtitle': 'CaloriWise ต้องการการเชื่อมต่อ Internet\nเพื่อให้บริการที่ดีที่สุด',
    'closeApp': 'ปิดแอป',
    'tips': 'เคล็ดลับ',
    'tip1': '• ตรวจสอบว่า Wi-Fi หรือ Mobile Data เปิดอยู่',
    'tip2': '• ลองเข้าใกล้จุดเชื่อมต่อ Wi-Fi',
    'tip3': '• รีสตาร์ทโหมดเครื่องบิน',
  }
      : {
    'title': 'No Internet Connection',
    'subtitle': 'CaloriWise requires Internet connection\nfor the best experience',
    'closeApp': 'Close App',
    'tips': 'Tips',
    'tip1': '• Check if Wi-Fi or Mobile Data is enabled',
    'tip2': '• Try moving closer to WiFi router',
    'tip3': '• Toggle Airplane mode on/off',
  };

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    // TODO: Get language preference from app settings
    // _isThaiLanguage = AppSettings.isThaiLanguage;
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _bounceController.forward();
  }

  void _closeApp() {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _closeApp();
        return false;
      },
      child: Scaffold(
        backgroundColor: AppTheme.primaryPurple,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated WiFi Icon
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.wifi_off,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // Title with bounce animation
                AnimatedBuilder(
                  animation: _bounceAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, (1 - _bounceAnimation.value) * 20),
                      child: Opacity(
                        opacity: _bounceAnimation.value,
                        child: Text(
                          _texts['title']!,
                          textAlign: TextAlign.center,
                          style: AppTextStyle.headlineLarge(context).copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // Subtitle
                Text(
                  _texts['subtitle']!,
                  textAlign: TextAlign.center,
                  style: AppTextStyle.bodyLarge(context).copyWith(
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 60),

                // Close App Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _closeApp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryPurple,
                      elevation: 2,
                      shadowColor: Colors.black.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.close),
                    label: Text(
                      _texts['closeApp']!,
                      style: AppTextStyle.titleMedium(context).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Tips Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.lightbulb_outline,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _texts['tips']!,
                            style: AppTextStyle.titleSmall(context).copyWith(
                              color: Colors.amber,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${_texts['tip1']!}\n${_texts['tip2']!}\n${_texts['tip3']!}',
                        style: AppTextStyle.bodySmall(context).copyWith(
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // App info at bottom
                Text(
                  'CaloriWise',
                  style: AppTextStyle.bodySmall(context).copyWith(
                    color: Colors.white.withOpacity(0.5),
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}