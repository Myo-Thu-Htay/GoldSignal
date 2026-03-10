import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/controller_service.dart';

final controllerProvider = Provider<Controller>((ref) {
  return Controller();
});