class PengaturanUsaha {
  final int? id;
  final int userId;
  final String namaUsaha;
  final String? alamat;
  final String headerNota;
  final String footerNota;

  PengaturanUsaha({
    this.id,
    required this.userId,
    this.namaUsaha = 'Usaha Fotokopi',
    this.alamat,
    this.headerNota = '=== NOTA TRANSAKSI ===',
    this.footerNota = 'Terima kasih telah menggunakan layanan kami!',
  });

  factory PengaturanUsaha.fromMap(Map<String, dynamic> json) => PengaturanUsaha(
    id: json['id'],
    userId: json['user_id'],
    namaUsaha: json['nama_usaha'],
    alamat: json['alamat'],
    headerNota: json['header_nota'],
    footerNota: json['footer_nota'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'nama_usaha': namaUsaha,
    'alamat': alamat,
    'header_nota': headerNota,
    'footer_nota': footerNota,
  };
}
