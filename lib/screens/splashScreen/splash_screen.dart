import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../theme/app_theme.dart';
import '../../theme/text_style.dart';
import '../../widgets/dialog/appDialogs.dart';
import 'bloc/splash_screen_bloc.dart';
import 'bloc/splash_screen_event.dart';
import 'bloc/splash_screen_state.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SplashScreenBloc(),
      child: const SplashScreenView(),
    );
  }
}

class SplashScreenView extends StatefulWidget {
  const SplashScreenView({super.key});

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SplashScreenBloc>().add(StartSplash());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashScreenBloc, SplashScreenState>(
      listener: (context, state) async {
        // Handle navigation states
        if (state is NavigateToHome) {
          Navigator.pushReplacementNamed(context, '/mainScreen');
        } else if (state is NavigateToLogin) {
          Navigator.pushReplacementNamed(context, '/authScreen');
        }
        // Handle error states with dialogs
        else if (state is NavigateToNetworkError) {
          await _showNetworkErrorDialog(context);
        } else if (state is SplashError) {
          await _showGenericErrorDialog(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.primaryPurple,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Image.asset(
                  'assets/images/app_logo.png',
                  width: 120,
                  height: 120,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.restaurant_menu,
                      size: 80,
                      color: Colors.white,
                    );
                  },
                ),

                const SizedBox(height: 32),

                // App Name
                Text(
                  'Calorie Wise App',
                  style: AppTextStyle.headlineLarge(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Tagline
                Text(
                  'Eat smart, live healthy',
                  style: AppTextStyle.bodyLarge(context).copyWith(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 60),

                // Loading indicator with state management
                BlocBuilder<SplashScreenBloc, SplashScreenState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        // แสดง loading indicator เสมอ (error จะแสดงใน dialog)
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3,
                        ),

                        const SizedBox(height: 20),

                        // แสดงข้อความตาม state
                        Text(
                          _getStatusMessage(state),
                          style: AppTextStyle.bodyMedium(context).copyWith(
                            color: Colors.white70,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // แสดง Network Error Dialog
  Future<void> _showNetworkErrorDialog(BuildContext context) async {
    bool didRetry = false;

    await AppDialogs.showErrorDialog(
      context: context,
      title: 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต',
      message: 'กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ตของคุณและลองใหม่อีกครั้ง',
      buttonText: 'ออกจากแอป',
      retryText: 'ลองใหม่',
      onRetry: () {
        didRetry = true;
        context.read<SplashScreenBloc>().add(RetryConnection());
      },
    );

    // ถ้าไม่ได้กด retry ให้ออกจากแอป
    if (!didRetry) {
      SystemNavigator.pop();
    }
  }

  // แสดง Generic Error Dialog
  Future<void> _showGenericErrorDialog(BuildContext context, String message) async {
    bool didRetry = false;

    await AppDialogs.showErrorDialog(
      context: context,
      title: 'เกิดข้อผิดพลาด',
      message: message,
      buttonText: 'ออกจากแอป',
      retryText: 'ลองใหม่',
      onRetry: () {
        didRetry = true;
        context.read<SplashScreenBloc>().add(RetryConnection());
      },
    );

    // ถ้าไม่ได้กด retry ให้ออกจากแอป
    if (!didRetry) {
      SystemNavigator.pop();
    }
  }

  // อัปเดต function ให้รองรับ State ใหม่ (เอา error cases ออก เพราะใช้ dialog แล้ว)
  String _getStatusMessage(SplashScreenState state) {
    if (state is SplashLoading) {
      return state.message;
    } else if (state is NavigateToHome) {
      return 'กำลังเข้าสู่แอป...';
    } else if (state is NavigateToLogin) {
      return 'กำลังเตรียมพร้อม...';
    } else {
      return 'กำลังโหลด...';
    }
  }
}