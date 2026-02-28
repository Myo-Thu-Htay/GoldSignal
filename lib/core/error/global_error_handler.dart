import '../logging/app_logger.dart';

class GlobalErrorHandler {
  static void handle(Object error, StackTrace stack) {
    // Log the error using your logging mechanism
    AppLogger.log('Unhandled exception: $error');
    AppLogger.log(stack.toString());
  }
}