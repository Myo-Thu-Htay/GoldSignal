import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/error/global_error_handler.dart';
import 'core/config/app_config.dart';
import 'app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  runZonedGuarded(() async{
    WidgetsFlutterBinding.ensureInitialized();
    await dotenv.load(fileName: ".env");
    AppConfig.initialize();
    runApp(const ProviderScope(child: MyApp()));
  }, GlobalErrorHandler.handle);
}
