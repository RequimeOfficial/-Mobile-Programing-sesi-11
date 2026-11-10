// lib/views/common/session_actions.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/routes/app_router.dart';
import '../../viewmodels/auth_vm.dart';
import '../../viewmodels/book_vm.dart';

/// Logout dipakai dari BooksView maupun ProfileView: akhiri sesi,
/// bersihkan cache daftar buku, lalu kembali ke halaman login.
Future<void> logoutAndGoToLogin(BuildContext context, WidgetRef ref) async {
  await ref.read(authProvider.notifier).logout();
  ref.read(bookProvider.notifier).reset();
  if (!context.mounted) return;
  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
}
