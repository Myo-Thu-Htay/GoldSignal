import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/error/global_error_handler.dart';
import 'core/config/app_config.dart';
import 'app.dart';

void main() async{
  runZonedGuarded(() async{
    WidgetsFlutterBinding.ensureInitialized();
    AppConfig.initialize();
    runApp(const ProviderScope(child: MyApp()));
  }, GlobalErrorHandler.handle);
}
