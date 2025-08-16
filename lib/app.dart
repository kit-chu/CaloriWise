import 'package:calori_wise_app/screens/MainScreen.dart';
import 'package:calori_wise_app/screens/NetworkErrorScreen/NetworkErrorScreen.dart';
import 'package:calori_wise_app/screens/authScreen/auth_screen.dart';
import 'package:calori_wise_app/screens/authScreen/bloc/auth_screen_bloc.dart';
import 'package:calori_wise_app/screens/homeScreen/home_screen.dart';
import 'package:calori_wise_app/screens/homeScreen/bloc/home_screen_bloc.dart'; // เพิ่มบรรทัดนี้
import 'package:calori_wise_app/screens/splashScreen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme/app_theme.dart';

class CaloriWiseApp extends StatelessWidget {
  const CaloriWiseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthScreenBloc()),
        BlocProvider(create: (context) => HomeScreenBloc()),
      ],
      child: MaterialApp(
        title: 'CaloriWise',
        theme: AppTheme.lightTheme.copyWith(
          appBarTheme: AppTheme.lightTheme.appBarTheme.copyWith(
            elevation: 0,
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/networkError': (context) => const NetworkErrorScreen(),
          '/authScreen': (context) => const AuthScreen(),
          '/homeScreen': (context) => const HomeScreen(),
          '/mainScreen': (context) => const MainScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}