import 'package:flutter/foundation.dart';

@immutable
abstract class SplashScreenState {}

@immutable
class SplashInitial extends SplashScreenState {}


@immutable
class SplashLoading extends SplashScreenState {
  final String message;
  SplashLoading(this.message);
}

@immutable
class SplashError extends SplashScreenState {
  final String message;
  SplashError(this.message);
}

@immutable
class NavigateToHome extends SplashScreenState {}


@immutable
class NavigateToLogin extends SplashScreenState {}

@immutable
class NavigateToNetworkError extends SplashScreenState {}