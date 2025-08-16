// splash_screen_bloc.dart - แก้ไขให้รองรับ status ตัวเลขและ token refresh
import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/splash_service.dart';
import 'splash_screen_event.dart';
import 'splash_screen_state.dart';

class SplashScreenBloc extends Bloc<SplashScreenEvent, SplashScreenState> {
  SplashScreenBloc() : super(SplashInitial()) {
    on<StartSplash>(_onStartSplash);
    on<RetryConnection>(_onRetryConnection);
  }

  // หลัก Flow: เช็คทุกอย่างแล้วตัดสินใจ
  Future<void> _onStartSplash(StartSplash event, Emitter<SplashScreenState> emit) async {
    try {
      // Step 1: เช็ค Network
      emit(SplashLoading('Checking network connection...'));
      if (!await _hasNetworkConnection()) {
        emit(NavigateToNetworkError());
        return;
      }

      // Step 2: เช็ค Token
      emit(SplashLoading('Checking authentication...'));
      final token = await _getStoredToken();

      if (token == null || token.isEmpty) {
        print('📝 No token found or empty token');
        await _showSplashMinimumTime();
        emit(NavigateToLogin());
        return;
      }

      // Step 3: Validate Token กับ Server
      emit(SplashLoading('Validating token...'));
      final validationResult = await _validateTokenWithServer(token);

      await _showSplashMinimumTime();

      // จัดการผลลัพธ์ตาม status
      switch (validationResult.status) {
        case 1: // SUCCESS
        // ถ้า token ถูก refresh ให้บันทึก token ใหม่
          if (validationResult.tokenRefreshed && validationResult.newToken != null) {
            await _saveToken(validationResult.newToken!);
            emit(SplashLoading('Token refreshed, proceeding to app...'));
            await Future.delayed(Duration(milliseconds: 500));
          }
          emit(NavigateToHome());
          break;

        case 2: // REFRESH_TOKEN_EXPIRED
        case 3: // REFRESH_TOKEN_NOT_FOUND
        // ต้อง login ใหม่
          await _clearStoredToken();
          emit(NavigateToLogin());
          break;

        case 4: // USER_NOT_FOUND
        case 5: // TOKEN_REVOKED
        case 6: // TOKEN_MISMATCH
        // Token มีปัญหา ต้อง login ใหม่
          await _clearStoredToken();
          emit(NavigateToLogin());
          break;

        default: // อื่นๆ (7,8,10)
        // Server error หรือ network issue
          emit(SplashError(validationResult.message ?? 'Token validation failed'));
          break;
      }

    } catch (e) {
      emit(SplashError('Something went wrong: ${e.toString()}'));
    }
  }

  // Retry เมื่อเกิด Error
  Future<void> _onRetryConnection(RetryConnection event, Emitter<SplashScreenState> emit) async {
    emit(SplashInitial());
    add(StartSplash());
  }

  // ================== Helper Methods ==================

  // เช็คว่ามี Internet หรือไม่
  Future<bool> _hasNetworkConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult.any((result) => result != ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  // ดึง Token จาก Storage
  Future<String?> _getStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('jwt_token');
    } catch (e) {
      return null;
    }
  }

  // บันทึก Token ลง Storage
  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);
    } catch (e) {
      // Ignore error
    }
  }

  // ลบ Token จาก Storage
  Future<void> _clearStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('jwt_token');
    } catch (e) {
      // Ignore error
    }
  }

  // Validate Token กับ Server
  Future<TokenValidationResult> _validateTokenWithServer(String token) async {
    try {
      final response = await SplashService.validateToken(idToken: token)
          .timeout(Duration(seconds: 15)); // เพิ่ม timeout

      if (response == null) {
        return TokenValidationResult(
            status: 10,
            success: false,
            message: 'ไม่ได้รับการตอบกลับจากเซิร์ฟเวอร์'
        );
      }

      // เช็ค HTTP status code แบบละเอียด
      switch (response.statusCode) {
        case 200:
          if (response.data != null) {
            final data = response.data!;
            return TokenValidationResult(
                status: data.status ?? 10,
                success: data.status == 1,
                message: data.message,
                newToken: data.accessToken,
                tokenRefreshed: data.tokenRefreshed ?? false
            );
          } else {
            return TokenValidationResult(
                status: 10,
                success: false,
                message: 'ข้อมูลที่ได้รับไม่สมบูรณ์'
            );
          }

        case 400:
          return TokenValidationResult(
              status: 10,
              success: false,
              message: 'ข้อมูลที่ส่งไปไม่ถูกต้อง'
          );

        case 401:
          return TokenValidationResult(
              status: 10,
              success: false,
              message: 'กรุณาเข้าสู่ระบบใหม่อีกครั้ง'
          );

        case 403:
          return TokenValidationResult(
              status: 10,
              success: false,
              message: 'ไม่มีสิทธิ์เข้าถึงข้อมูล'
          );

        case 404:
          return TokenValidationResult(
              status: 10,
              success: false,
              message: 'ไม่พบบริการที่ต้องการ'
          );

        case 500:
          return TokenValidationResult(
              status: 10,
              success: false,
              message: 'เซิร์ฟเวอร์มีปัญหา กรุณาลองใหม่ในภายหลัง'
          );

        case 502:
          return TokenValidationResult(
              status: 10,
              success: false,
              message: 'เซิร์ฟเวอร์ไม่พร้อมใช้งาน'
          );

        case 503:
          return TokenValidationResult(
              status: 10,
              success: false,
              message: 'บริการไม่พร้อมใช้งานชั่วคราว'
          );

        case 504:
          return TokenValidationResult(
              status: 10,
              success: false,
              message: 'เซิร์ฟเวอร์ตอบสนองช้าเกินไป'
          );

        default:
          return TokenValidationResult(
              status: 10,
              success: false,
              message: 'เกิดข้อผิดพลาดในการเชื่อมต่อ (${response.statusCode})'
          );
      }

    } on TimeoutException catch (e) {
      return TokenValidationResult(
          status: 10,
          success: false,
          message: 'เซิร์ฟเวอร์ตอบสนองช้า กรุณาลองใหม่อีกครั้ง'
      );
    } on SocketException catch (e) {
      return TokenValidationResult(
          status: 10,
          success: false,
          message: 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้'
      );
    } on HttpException catch (e) {
      return TokenValidationResult(
          status: 10,
          success: false,
          message: 'เกิดข้อผิดพลาดในการเชื่อมต่อ'
      );
    } on FormatException catch (e) {
      return TokenValidationResult(
          status: 10,
          success: false,
          message: 'ข้อมูลที่ได้รับไม่ถูกต้อง'
      );
    } catch (e) {
      return TokenValidationResult(
          status: 10,
          success: false,
          message: 'เกิดข้อผิดพลาดในการเชื่อมต่อ กรุณาลองใหม่'
      );
    }
  }

  // แสดง Splash ขั้นต่ำ 2 วินาที (สำหรับ UX)
  Future<void> _showSplashMinimumTime() async {
    await Future.delayed(Duration(seconds: 2));
  }
}

// Helper class สำหรับเก็บผลลัพธ์ validation
class TokenValidationResult {
  final int status;
  final bool success;
  final String? message;
  final String? newToken;
  final bool tokenRefreshed;

  TokenValidationResult({
    required this.status,
    required this.success,
    this.message,
    this.newToken,
    this.tokenRefreshed = false,
  });
}
