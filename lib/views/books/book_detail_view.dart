// lib/views/books/book_detail_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/book_model.dart';
import '../../viewmodels/book_vm.dart';
import '../../widgets/stock_style.dart';
import 'book_actions.dart';

/// Tugas A – Halaman Detail Buku.
///
/// Menerima [book] dari argumen route, lalu membaca versi terbaru dari
/// `bookProvider` (berdasarkan id) sehingga setelah Edit tampilan ikut
/// berubah tanpa perlu memuat ulang.
class BookDetailView extends ConsumerWidget {
  final BookModel book;

  const BookDetailView({super.key, required this.book});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(
      bookProvider.select(
        (s) => s.books.where((b) => b.id == book.id).firstOrNull,
      ),
    );
    final b = current ?? book;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    Future<void> delete() async {
      final deleted = await confirmDeleteBook(context, ref, b);
      if (deleted && context.mounted) Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Buku'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () => openBookForm(context, ref, b),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Hapus',
            onPressed: delete,
          ),
        ],
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              // Header: sampul sederhana + judul + penulis + status stok
              Card(
                color: scheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 96,
                        decoration: BoxDecoration(
                          color: scheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.menu_book_rounded,
                          color: scheme.onPrimary,
                          size: 40,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              b.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              b.author,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: scheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Chip(
                              avatar: Icon(
                                Icons.inventory_2,
                                size: 18,
                                color: stockColor(b.stock),
                              ),
                              label: Text(
                                stockLabel(b.stock),
                                style: TextStyle(
                                  color: stockColor(b.stock),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              backgroundColor: scheme.surface,
                              side: BorderSide(color: stockColor(b.stock)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    _row(Icons.tag, 'ID Buku', '${b.id}'),
                    _row(Icons.person, 'Penulis', b.author),
                    _row(Icons.business, 'Penerbit', b.publisher ?? '-'),
                    _row(Icons.qr_code, 'ISBN', b.isbn),
                    _row(
                      Icons.calendar_today,
                      'Tahun Terbit',
                      '${b.publishedYear}',
                    ),
                    _row(Icons.inventory_2, 'Stok', '${b.stock} eksemplar'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Deskripsi', style: theme.textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        (b.description?.isNotEmpty ?? false)
                            ? b.description!
                            : 'Belum ada deskripsi.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => openBookForm(context, ref, b),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Buku'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: delete,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      icon: const Icon(Icons.delete),
                      label: const Text('Hapus Buku'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) => ListTile(
    leading: Icon(icon),
    title: Text(label),
    subtitle: Text(value),
    dense: true,
  );
}
