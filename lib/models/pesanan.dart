class Pesanan {
  final int? id;
  final String? namaPelanggan;
  final String? noHp;
  final int layananId;
  final int jumlah;
  final double totalHarga;
  final String status;
  final String? catatan;
  final String? tanggalPesan;
  String? namaLayanan; // Untuk join dengan tabel layanan

  Pesanan({
    this.id,
    this.namaPelanggan,
    this.noHp,
    required this.layananId,
    required this.jumlah,
    required this.totalHarga,
    this.status = 'menunggu',
    this.catatan,
    this.tanggalPesan,
    this.namaLayanan,
  });

  factory Pesanan.fromMap(Map<String, dynamic> json) => Pesanan(
    id: json['id'],
    namaPelanggan: json['nama_pelanggan'],
    noHp: json['no_hp'],
    layananId: json['layanan_id'],
    jumlah: json['jumlah'],
    totalHarga: json['total_harga'],
    status: json['status'],
    catatan: json['catatan'],
    tanggalPesan: json['tanggal_pesan'],
    namaLayanan: json['nama_layanan'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nama_pelanggan': namaPelanggan,
    'no_hp': noHp,
    'layanan_id': layananId,
    'jumlah': jumlah,
    'total_harga': totalHarga,
    'status': status,
    'catatan': catatan,
    'tanggal_pesan': tanggalPesan,
  };
}
