import 'package:calori_wise_app/screens/authScreen/bloc/auth_screen_bloc.dart';
import 'package:calori_wise_app/screens/authScreen/response/AuthScreenResponse.dart';
import 'package:calori_wise_app/screens/authScreen/response/authLoginGoogleResponse.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../../theme/app_theme.dart';
import '../../theme/text_style.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  List<ItemsAuth>? items = [];
  late String firebaseUser ;
  AuthLoginGoogleResponse? authLoginGoogleResponse;
  @override
  void initState() {
    super.initState();
    TextAuthScreen.setLanguage(true);
    context.read<AuthScreenBloc>().add(LoadAuthScreen(version: 0.4));
  }

  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
      print("Token saved successfully");
    } catch (e) {
      print("Failed to save token: $e");
    }
  }


  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthScreenBloc, AuthScreenState>(
      listener: (context, state) async {
        if (state is GoogleAuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${TextAuthScreen.loginFailed}: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is GoogleAuthSuccess) {
          authLoginGoogleResponse = state.authLoginGoogleResponse;

          final token = state.authLoginGoogleResponse.data?.token;
          if (token != null) {
            await _saveToken(token);
            print("token saved: ${token.substring(0, 20)}...");
          } else {
            print("Warning: No token received from login response");
          }

          Navigator.pushReplacementNamed(context, '/mainScreen');
        } else if (state is AuthScreenLoaded) {
          items = state.data.data?.items;
          TextAuthScreen.setLabels(items);
        } else if (state is AuthScreenError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isAuthLoading = state is GoogleAuthLoading;
        final isDataLoading = state is AuthScreenLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: isDataLoading
                        ? Shimmer(
                      duration: Duration(seconds: 2),
                      color: AppTheme.primaryPurple.withOpacity(0.3),
                      colorOpacity: 0.3,
                      enabled: true,
                      direction: ShimmerDirection.fromLTRB(),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(60),
                        ),
                      ),
                    )
                        : Image.asset(
                      'assets/images/app_logo.png',
                      width: 120,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.restaurant_menu,
                          size: 80,
                          color: AppTheme.primaryPurple,
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 40),

                  // App Title - ไม่มี Shimmer หลังโหลดเสร็จ
                  isDataLoading
                      ? Shimmer(
                    duration: Duration(seconds: 2),
                    color: Colors.grey[300]!,
                    colorOpacity: 0.5,
                    enabled: true,
                    direction: ShimmerDirection.fromLTRB(),
                    child: Container(
                      height: 35,
                      width: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                      : Text(
                    TextAuthScreen.appTitle,
                    style: AppTextStyle.headlineLarge(context).copyWith(
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  isDataLoading
                      ? Column(
                    children: [
                      Shimmer(
                        duration: Duration(seconds: 2),
                        color: Colors.grey[300]!,
                        colorOpacity: 0.5,
                        enabled: true,
                        direction: ShimmerDirection.fromLTRB(),
                        child: Container(
                          height: 18,
                          width: 280,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Shimmer(
                        duration: Duration(seconds: 2),
                        color: Colors.grey[300]!,
                        colorOpacity: 0.5,
                        enabled: true,
                        direction: ShimmerDirection.fromLTRB(),
                        child: Container(
                          height: 18,
                          width: 220,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  )
                      : Text(
                    TextAuthScreen.subtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.bodyLarge(context).copyWith(
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 60),

                  // Google Sign-In Button - ไม่มี Shimmer หลังโหลดเสร็จ
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: isDataLoading
                        ? Shimmer(
                      duration: Duration(seconds: 2),
                      color: Colors.grey[300]!,
                      colorOpacity: 0.5,
                      enabled: true,
                      direction: ShimmerDirection.fromLTRB(),
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                        : ElevatedButton.icon(
                      onPressed: isAuthLoading
                          ? null
                          : () => context.read<AuthScreenBloc>().add(GoogleSignInRequested()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      icon: isAuthLoading
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                          : Image.network(
                        'https://developers.google.com/identity/images/g-logo.png',
                        width: 20,
                        height: 20,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.g_mobiledata,
                            size: 20,
                            color: Colors.blue,
                          );
                        },
                      ),
                      label: Text(
                        isAuthLoading ? TextAuthScreen.signingIn : TextAuthScreen.googleSignIn,
                        style: AppTextStyle.titleMedium(context).copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  isDataLoading
                      ? Column(
                    children: [
                      Shimmer(
                        duration: Duration(seconds: 2),
                        color: Colors.grey[300]!,
                        colorOpacity: 0.5,
                        enabled: true,
                        direction: ShimmerDirection.fromLTRB(),
                        child: Container(
                          height: 14,
                          width: 300,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Shimmer(
                        duration: Duration(seconds: 2),
                        color: Colors.grey[300]!,
                        colorOpacity: 0.5,
                        enabled: true,
                        direction: ShimmerDirection.fromLTRB(),
                        child: Container(
                          height: 14,
                          width: 250,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  )
                      : Text(
                    TextAuthScreen.termsPrivacy,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.bodySmall(context).copyWith(
                      color: Colors.grey[500],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}