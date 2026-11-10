// lib/views/books/book_actions.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/book_model.dart';
import '../../viewmodels/book_vm.dart';
import 'book_form_dialog.dart';

/// Aksi buku yang dipakai bersama oleh BooksView dan BookDetailView,
/// supaya logika dialog tambah/edit/hapus tidak ditulis dua kali.
/// View tetap hanya memanggil method ViewModel (bookProvider.notifier).

void showToast(BuildContext context, String msg, {bool isError = false}) {
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
}

/// Buka form tambah ([book] == null) atau edit. Return `true` jika tersimpan.
Future<bool> openBookForm(
  BuildContext context,
  WidgetRef ref, [
  BookModel? book,
]) async {
  final vm = ref.read(bookProvider.notifier);
  final saved = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (_) => BookFormDialog(
      book: book,
      onSubmit: (payload) =>
          book == null ? vm.create(payload) : vm.update(book.id, payload),
    ),
  );
  if (saved == true && context.mounted) {
    showToast(
      context,
      book == null ? 'Buku berhasil ditambahkan' : 'Perubahan disimpan',
    );
  }
  return saved == true;
}

/// Konfirmasi lalu hapus buku. Return `true` jika buku benar-benar terhapus.
Future<bool> confirmDeleteBook(
  BuildContext context,
  WidgetRef ref,
  BookModel book,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: const Text('Hapus Buku'),
      content: Text('Hapus "${book.title}"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogCtx, true),
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
  if (ok != true) return false;
  final err = await ref.read(bookProvider.notifier).delete(book.id);
  if (context.mounted) {
    showToast(context, err ?? 'Buku dihapus', isError: err != null);
  }
  return err == null;
}
