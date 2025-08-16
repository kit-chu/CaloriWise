part of 'auth_screen_bloc.dart';



@immutable
abstract class AuthScreenEvent {}

class LoadAuthScreen extends AuthScreenEvent {
  final double? version;
  final String? languageCode;

  LoadAuthScreen({
    this.version,
    this.languageCode,
  });
}

class GoogleSignInRequested extends AuthScreenEvent {}

class SignOutRequested extends AuthScreenEvent {}


class GoogleSignInWithDeviceRequested extends AuthScreenEvent {
  final DeviceInfoRequest deviceInfo;

  GoogleSignInWithDeviceRequested({required this.deviceInfo});
}