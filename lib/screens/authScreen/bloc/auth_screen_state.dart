part of 'auth_screen_bloc.dart';

@immutable
abstract class AuthScreenState {}

class AuthScreenInitial extends AuthScreenState {}

// Loading & Data States
class AuthScreenLoading extends AuthScreenState {}

class AuthScreenLoaded extends AuthScreenState {
  final AuthScreenResponse data ;

  AuthScreenLoaded(this.data);
}

class AuthScreenError extends AuthScreenState {
  final String message;

  AuthScreenError(this.message);
}

class GoogleAuthLoading extends AuthScreenState {}

class GoogleAuthSuccess extends AuthScreenState {
  final AuthLoginGoogleResponse authLoginGoogleResponse;
  GoogleAuthSuccess(this.authLoginGoogleResponse);
}

class GoogleAuthFailure extends AuthScreenState {
  final String message;

  GoogleAuthFailure(this.message);
}

