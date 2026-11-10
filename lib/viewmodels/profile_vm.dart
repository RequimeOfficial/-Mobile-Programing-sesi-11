// lib/viewmodels/profile_vm.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import 'providers.dart';

/// Tugas B – state halaman profil.
///
/// FutureProvider otomatis menyediakan tiga keadaan (loading / data / error)
/// lewat AsyncValue. `autoDispose` membuat data diambil ulang dari
/// `GET /api/me` setiap kali halaman profil dibuka.
final profileProvider = FutureProvider.autoDispose<UserModel>(
  (ref) => ref.read(authRepositoryProvider).getProfile(),
);
