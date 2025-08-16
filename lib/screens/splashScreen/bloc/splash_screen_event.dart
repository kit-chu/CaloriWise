import 'package:flutter/foundation.dart';


@immutable
abstract class SplashScreenEvent {}


@immutable
class StartSplash extends SplashScreenEvent {}
@immutable
class RetryConnection extends SplashScreenEvent {}