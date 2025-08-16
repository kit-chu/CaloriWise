// auth_screen_bloc.dart
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:calori_wise_app/services/firebase_service.dart';
import 'package:calori_wise_app/screens/authScreen/response/AuthScreenResponse.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

import '../../../services/api/api_caller.dart';
import '../api/auth_service.dart';
import '../request/AuthScreenReuest.dart';
import '../request/DeviceInfoRequest.dart';
import '../response/authLoginGoogleResponse.dart';

part 'auth_screen_event.dart';
part 'auth_screen_state.dart';

class AuthScreenBloc extends Bloc<AuthScreenEvent, AuthScreenState> {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();

  AuthScreenBloc() : super(AuthScreenInitial()) {
    on<LoadAuthScreen>(_onLoadAuthScreen);
    on<GoogleSignInRequested>(_onGoogleSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onLoadAuthScreen(
      LoadAuthScreen event,
      Emitter<AuthScreenState> emit,
      ) async {
    emit(AuthScreenLoading());

    try {
      final request = AuthScreenRequest(
        collection: 'AuthScreen',
        version: event.version ?? 0.3,
      );

      final response = await ApiCaller.fetchAuthScreenItems(request: request);

      if (response?.statusCode == 200 && response?.data != null) {
        emit(AuthScreenLoaded(response!));
      } else {
        emit(AuthScreenError(
            response?.errorData ?? response?.message ?? 'Failed to load data'
        ));
      }
    } catch (e) {
      emit(AuthScreenError('Network error: ${e.toString()}'));
    }
  }


  Future<void> _onGoogleSignInRequested(
      GoogleSignInRequested event,
      Emitter<AuthScreenState> emit,
      ) async {
    emit(GoogleAuthLoading());

    try {
      // BLoC เป็นคนสร้าง device info
      final deviceInfo = await _getDeviceInfo();

      final firebaseIdToken = await _firebaseService.signInWithGoogleAndGetFirebaseIdToken();

      if (firebaseIdToken == null) {
        emit(GoogleAuthFailure('Google Sign-In ถูกยกเลิก'));
        return;
      }

      final response = await AuthService.googleLogin(
        idToken: firebaseIdToken,
        deviceInfo: deviceInfo,
      );

      if (response != null && response.statusCode == 200) {
        emit(GoogleAuthSuccess(response));
      } else {
        emit(GoogleAuthFailure(response?.message ?? 'Login failed'));
      }
    } catch (e) {
      emit(GoogleAuthFailure('เกิดข้อผิดพลาด: $e'));
    }
  }

  Future<DeviceInfoRequest> _getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return DeviceInfoRequest(
          deviceId: iosInfo.identifierForVendor ?? 'unknown-ios',
          platform: 'iOS',
          osVersion: iosInfo.systemVersion,
          deviceModel: iosInfo.utsname.machine,
        );
      } else if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return DeviceInfoRequest(
          deviceId: androidInfo.id,
          platform: 'Android',
          osVersion: 'Android ${androidInfo.version.release}',
          deviceModel: '${androidInfo.brand} ${androidInfo.model}',
        );
      }

      return DeviceInfoRequest(
        deviceId: 'unknown',
        platform: 'unknown',
        osVersion: 'unknown',
        deviceModel: 'unknown',
      );
    } catch (e) {
      print('Error getting device info: $e');
      return DeviceInfoRequest(
        deviceId: 'error',
        platform: 'unknown',
        osVersion: 'unknown',
        deviceModel: 'unknown',
      );
    }
  }






  Future<void> _onSignOutRequested(
      SignOutRequested event,
      Emitter<AuthScreenState> emit,
      ) async {
    emit(GoogleAuthLoading());

    try {
      await _firebaseService.signOut();
      emit(AuthScreenInitial());
    } catch (e) {
      emit(GoogleAuthFailure(e.toString()));
    }
  }
}