// lib/core/utils/date_format.dart

const _bulan = [
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

/// Format tanggal Indonesia, mis. `10 November 2026`.
String formatTanggal(DateTime d) => '${d.day} ${_bulan[d.month - 1]} ${d.year}';

/// Lama bergabung yang mudah dibaca, mis. `Hari ini`, `3 hari lalu`.
String lamaBergabung(DateTime since, {DateTime? now}) {
  final days = (now ?? DateTime.now()).difference(since).inDays;
  if (days <= 0) return 'Hari ini';
  if (days < 30) return '$days hari lalu';
  if (days < 365) return '${days ~/ 30} bulan lalu';
  return '${days ~/ 365} tahun lalu';
}
