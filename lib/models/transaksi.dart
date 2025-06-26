class Transaksi {
  final int? id;
  final String jenis;
  final int referensiId;
  final int jumlah;
  final double total;
  final String metodePembayaran;
  final String? tanggal;

  Transaksi({
    this.id,
    required this.jenis,
    required this.referensiId,
    required this.jumlah,
    required this.total,
    required this.metodePembayaran,
    this.tanggal,
  });

  factory Transaksi.fromMap(Map<String, dynamic> json) => Transaksi(
    id: json['id'],
    jenis: json['jenis'],
    referensiId: json['referensi_id'],
    jumlah: json['jumlah'],
    total: json['total'],
    metodePembayaran: json['metode_pembayaran'],
    tanggal: json['tanggal'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'jenis': jenis,
    'referensi_id': referensiId,
    'jumlah': jumlah,
    'total': total,
    'metode_pembayaran': metodePembayaran,
    'tanggal': tanggal,
  };
}
