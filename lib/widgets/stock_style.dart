// lib/widgets/stock_style.dart
import 'package:flutter/material.dart';

/// Latihan 3 – warna stok dipakai bersama oleh BookCard & BookDetailView.
/// 0 = merah (habis), 1–5 = oranye (menipis), > 5 = hijau (aman).
Color stockColor(int stock) {
  if (stock == 0) return Colors.red.shade700;
  if (stock <= 5) return Colors.orange.shade800;
  return Colors.green.shade700;
}

String stockLabel(int stock) => stock == 0 ? 'Stok: 0 (Habis)' : 'Stok: $stock';
