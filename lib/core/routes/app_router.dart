// lib/core/routes/app_router.dart
import 'package:flutter/material.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String books = '/books';
  static const String bookDetail = '/books/detail'; // Tugas A
  static const String profile = '/profile'; // Tugas B
}

/// Navigator global agar interceptor Dio (di luar widget tree) bisa
/// mengarahkan user ke halaman login saat token tidak valid (401).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void redirectToLogin() {
  navigatorKey.currentState?.pushNamedAndRemoveUntil(
    AppRoutes.login,
    (_) => false,
  );
}
