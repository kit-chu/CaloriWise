part of 'home_screen_bloc.dart';

@immutable
sealed class HomeScreenState {}

final class HomeScreenInitial extends HomeScreenState {}

class HomeScreenLoading extends HomeScreenState {}
class HomeScreenLoaded extends HomeScreenState {
  final HomeScreenResponse response;
  HomeScreenLoaded(this.response);
}
class HomeScreenError extends HomeScreenState {
  final String message;
  HomeScreenError(this.message);
}
class HomeScreenApiCase extends HomeScreenState {
  final int statusCode;
  final String message;
  final dynamic data;
  HomeScreenApiCase({required this.statusCode, required this.message, this.data});
}
