import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/api/api_caller.dart';
import '../request/homeScreenReuest.dart';
import '../response/homeScreenResponse.dart';

part 'home_screen_event.dart';
part 'home_screen_state.dart';

class HomeScreenBloc extends Bloc<HomeScreenEvent, HomeScreenState> {
  HomeScreenBloc() : super(HomeScreenInitial()) {
    on<FetchHomeScreenItems>((event, emit) async {
      emit(HomeScreenLoading());
      final response = await ApiCaller.fetchHomeScreenItems(request: event.request);
      if (response != null && response.statusCode == 200) {
        emit(HomeScreenLoaded(response));
      } else {
        emit(HomeScreenError(response?.message ?? 'Unknown error'));
      }
    });
  }
}
