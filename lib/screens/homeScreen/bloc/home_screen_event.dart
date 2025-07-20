part of 'home_screen_bloc.dart';

@immutable
abstract class HomeScreenEvent {}

class FetchHomeScreenItems extends HomeScreenEvent {
  final HomeScreenRequest request;
  FetchHomeScreenItems({required this.request});
}
