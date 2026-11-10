// Test untuk Latihan 3 dan Tugas A, B, C (tanpa server: repository palsu).
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perpus_app/core/utils/date_format.dart';
import 'package:perpus_app/main.dart';
import 'package:perpus_app/models/book_model.dart';
import 'package:perpus_app/models/user_model.dart';
import 'package:perpus_app/repositories/auth_repository.dart';
import 'package:perpus_app/repositories/book_repository.dart';
import 'package:perpus_app/services/api_service.dart';
import 'package:perpus_app/services/storage_service.dart';
import 'package:perpus_app/viewmodels/book_vm.dart';
import 'package:perpus_app/viewmodels/providers.dart';
import 'package:perpus_app/views/books/book_detail_view.dart';
import 'package:perpus_app/views/profile/profile_view.dart';
import 'package:perpus_app/widgets/book_card.dart';
import 'package:perpus_app/widgets/stock_style.dart';

BookModel buku(int id, String title, {int stock = 3, String? desc}) =>
    BookModel(
      id: id,
      title: title,
      author: 'Andrea Hirata',
      publisher: 'Bentang Pustaka',
      isbn: 'ISBN-$id',
      publishedYear: 2005,
      stock: stock,
      description: desc,
    );

final admin = UserModel(
  id: 1,
  name: 'Admin Perpus',
  email: 'admin@example.com',
  createdAt: DateTime(2026, 11, 9, 14, 20),
);

/// Repository buku palsu: data di memori + mencatat setiap pencarian.
class MemoryBookRepository extends BookRepository {
  MemoryBookRepository(this.books) : super(ApiService(Dio()));
  final List<BookModel> books;
  final searches = <String?>[];

  @override
  Future<BookPage> getBooks({String? search, int page = 1}) async {
    searches.add(search);
    final q = (search ?? '').toLowerCase();
    final hasil = books
        .where((b) => q.isEmpty || b.title.toLowerCase().contains(q))
        .toList();
    return BookPage(
      books: hasil,
      currentPage: 1,
      lastPage: 1,
      total: hasil.length,
    );
  }

  @override
  Future<BookModel> updateBook(int id, Map<String, dynamic> payload) async {
    final lama = books.firstWhere((b) => b.id == id);
    final baru = BookModel.fromJson({...lama.toJson(), 'id': id, ...payload});
    books[books.indexOf(lama)] = baru;
    return baru;
  }

  @override
  Future<void> deleteBook(int id) async => books.removeWhere((b) => b.id == id);
}

/// Repository auth palsu: selalu sudah login sebagai [admin].
class FakeAuthRepository extends AuthRepository {
  FakeAuthRepository() : super(ApiService(Dio()), StorageService());
  int profileCalls = 0;
  bool loggedOut = false;

  @override
  Future<UserModel?> restoreSession() async => admin;

  @override
  Future<UserModel> getProfile() async {
    profileCalls++;
    return admin;
  }

  @override
  Future<void> logout() async => loggedOut = true;
}

/// Jalankan aplikasi asli (PerpusApp) dengan repository palsu.
Future<(MemoryBookRepository, FakeAuthRepository)> bukaApp(
  WidgetTester tester, {
  Size size = const Size(400, 860),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final books = MemoryBookRepository([
    buku(1, 'Laskar Pelangi', stock: 12, desc: 'Kisah anak Belitung.'),
    buku(2, 'Sang Pemimpi', stock: 4),
    buku(3, 'Edensor', stock: 0),
  ]);
  final auth = FakeAuthRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        bookRepositoryProvider.overrideWithValue(books),
        authRepositoryProvider.overrideWithValue(auth),
      ],
      child: const PerpusApp(),
    ),
  );
  await tester.pumpAndSettle();
  return (books, auth);
}

void main() {
  group('Latihan 3 – warna stok', () {
    test('warna & label stok sesuai aturan', () {
      expect(stockColor(0), Colors.red.shade700);
      expect(stockColor(5), Colors.orange.shade800);
      expect(stockColor(6), Colors.green.shade700);
      expect(stockLabel(0), 'Stok: 0 (Habis)');
      expect(stockLabel(7), 'Stok: 7');
    });

    testWidgets('BookCard menampilkan stok habis berwarna merah', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookCard(
              book: buku(3, 'Edensor', stock: 0),
              onEdit: () {},
              onDelete: () {},
            ),
          ),
        ),
      );
      final rich = tester.widget<RichText>(
        find.descendant(
          of: find.byType(ListTile),
          matching: find.byWidgetPredicate(
            (w) => w is RichText && w.text.toPlainText().contains('Habis'),
          ),
        ),
      );
      final span = (rich.text as TextSpan).children!.first as TextSpan;
      expect(span.children!.last.style?.color, Colors.red.shade700);
    });
  });

  group('Tugas A – Detail Buku', () {
    testWidgets('tap kartu membuka detail berisi semua field', (tester) async {
      await bukaApp(tester);
      expect(find.text('Daftar Buku'), findsOneWidget);

      await tester.tap(find.text('Laskar Pelangi'));
      await tester.pumpAndSettle();

      expect(find.byType(BookDetailView), findsOneWidget);
      expect(find.text('Detail Buku'), findsOneWidget);
      expect(find.text('Bentang Pustaka'), findsOneWidget);
      expect(find.text('ISBN-1'), findsOneWidget);
      expect(find.text('2005'), findsOneWidget);
      expect(find.text('12 eksemplar'), findsOneWidget);
      expect(find.text('Kisah anak Belitung.'), findsOneWidget);
    });

    testWidgets('edit dari detail langsung memperbarui tampilan', (
      tester,
    ) async {
      await bukaApp(tester);
      await tester.tap(find.text('Sang Pemimpi'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit Buku'));
      await tester.pumpAndSettle();
      final stokField = find.byType(TextFormField).at(5);
      await tester.enterText(stokField, '9');
      await tester.tap(find.text('Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('9 eksemplar'), findsOneWidget);
      expect(find.text('Perubahan disimpan'), findsOneWidget);
    });

    testWidgets('hapus dari detail kembali ke daftar & buku hilang', (
      tester,
    ) async {
      final (repo, _) = await bukaApp(tester);
      await tester.tap(find.text('Edensor'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hapus Buku'));
      await tester.pumpAndSettle();
      expect(find.text('Hapus "Edensor"?'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
      await tester.pumpAndSettle();

      expect(find.byType(BookDetailView), findsNothing);
      expect(find.text('Daftar Buku'), findsOneWidget);
      expect(find.text('Edensor'), findsNothing);
      expect(find.text('Buku dihapus'), findsOneWidget);
      expect(repo.books.length, 2);
    });
  });

  group('Tugas B – Profil User', () {
    test('UserModel membaca created_at ISO 8601', () {
      final u = UserModel.fromJson({
        'id': 1,
        'name': 'Admin',
        'email': 'admin@example.com',
        'created_at': '2026-11-09T14:20:25.000000Z',
      });
      expect(u.createdAt, isNotNull);
      expect(u.createdAt!.toUtc(), DateTime.utc(2026, 11, 9, 14, 20, 25));
      expect(formatTanggal(DateTime(2026, 11, 9)), '9 November 2026');
      expect(
        lamaBergabung(DateTime(2026, 11, 1), now: DateTime(2026, 11, 10)),
        '9 hari lalu',
      );
    });

    testWidgets('tombol profil (HP) membuka profil dari GET /api/me', (
      tester,
    ) async {
      final (_, auth) = await bukaApp(tester);
      await tester.tap(find.byTooltip('Profil'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileView), findsOneWidget);
      expect(auth.profileCalls, 1);
      expect(find.text('Admin Perpus'), findsWidgets);
      expect(find.text('admin@example.com'), findsWidgets);
      expect(find.textContaining('9 November 2026'), findsOneWidget);
    });

    testWidgets('NavigationRail (desktop) punya tujuan Profil', (tester) async {
      await bukaApp(tester, size: const Size(1200, 800));
      expect(find.byType(NavigationRail), findsOneWidget);
      await tester.tap(find.text('Profil'));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileView), findsOneWidget);
    });

    testWidgets('logout dari profil kembali ke halaman login', (tester) async {
      final (_, auth) = await bukaApp(tester);
      await tester.tap(find.byTooltip('Profil'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Logout'));
      await tester.pumpAndSettle();

      expect(auth.loggedOut, isTrue);
      expect(find.text('Masuk'), findsOneWidget);
      expect(find.byType(ProfileView), findsNothing);
    });
  });

  group('Tugas C – Pencarian otomatis (debounce)', () {
    testWidgets('mengetik cepat hanya mengirim 1 request setelah 500 ms', (
      tester,
    ) async {
      final (repo, _) = await bukaApp(tester);
      repo.searches.clear();
      final cari = find.byType(TextField).first;

      await tester.enterText(cari, 'l');
      await tester.pump(const Duration(milliseconds: 150));
      await tester.enterText(cari, 'la');
      await tester.pump(const Duration(milliseconds: 150));
      await tester.enterText(cari, 'las');
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        repo.searches,
        isEmpty,
        reason: 'belum 500 ms sejak huruf terakhir',
      );

      await tester.pump(const Duration(milliseconds: 150));
      await tester.pumpAndSettle();
      expect(repo.searches, ['las']);
      expect(find.text('Laskar Pelangi'), findsOneWidget);
      expect(find.text('Sang Pemimpi'), findsNothing);
    });

    test(
      '_requestId: respons pencarian lama yang datang belakangan diabaikan',
      () async {
        final lambat = Completer<BookPage>();
        final repo = _ControlledRepo({
          'a': lambat.future,
          'ab': Future.value(
            BookPage(
              books: [buku(2, 'AB')],
              currentPage: 1,
              lastPage: 1,
              total: 1,
            ),
          ),
        });
        final c = ProviderContainer(
          overrides: [bookRepositoryProvider.overrideWithValue(repo)],
        );
        addTearDown(c.dispose);
        final vm = c.read(bookProvider.notifier);

        final p1 = vm.load(search: 'a'); // request #1 (lambat)
        await vm.load(search: 'ab'); // request #2 selesai duluan
        lambat.complete(
          BookPage(
            books: [buku(1, 'A lama')],
            currentPage: 1,
            lastPage: 1,
            total: 1,
          ),
        );
        await p1;

        final s = c.read(bookProvider);
        expect(s.search, 'ab');
        expect(s.books.single.title, 'AB'); // tidak ditimpa hasil lama
      },
    );
  });
}

class _ControlledRepo extends BookRepository {
  _ControlledRepo(this.responses) : super(ApiService(Dio()));
  final Map<String, Future<BookPage>> responses;

  @override
  Future<BookPage> getBooks({String? search, int page = 1}) =>
      responses[search ?? '']!;
}
