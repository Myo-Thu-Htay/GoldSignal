import 'environment.dart';


class AppConfig {
  static late Environment environment;

  static void initialize() {
    environment = Environment.development; // Set the default environment
  }
}