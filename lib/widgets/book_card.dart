// lib/widgets/book_card.dart
import 'package:flutter/material.dart';

import '../core/routes/app_router.dart';
import '../models/book_model.dart';
import 'stock_style.dart';

class BookCard extends StatelessWidget {
  final BookModel book;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const BookCard({
    super.key,
    required this.book,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(book.id.toString())),
        title: Text(book.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        // Latihan 3: stok diberi warna (habis / menipis / aman)
        subtitle: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: '${book.author} · ${book.publishedYear} · '),
              TextSpan(
                text: stockLabel(book.stock),
                style: TextStyle(
                  color: stockColor(book.stock),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
              tooltip: 'Hapus',
            ),
          ],
        ),
        // Tugas A: buka halaman detail (menggantikan dialog detail)
        onTap: () =>
            Navigator.pushNamed(context, AppRoutes.bookDetail, arguments: book),
      ),
    );
  }
}
