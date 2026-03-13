import 'environment.dart';


class AppConfig {
  static late Environment environment;

  static void initialize() {
    const bool kReleaseMode = bool.fromEnvironment('dart.vm.product');
    if (kReleaseMode) {
      environment = Environment.production; // Set the default environment
    } else {
      environment = Environment.development; // Set the default environment
    }
  }
}