class Produk {
  final int? id;
  final String namaProduk;
  final int stok;
  final String satuan;
  final double hargaJual;
  final String? createdAt;

  Produk({
    this.id,
    required this.namaProduk,
    this.stok = 0,
    this.satuan = 'pcs',
    this.hargaJual = 0.0,
    this.createdAt,
  });

  factory Produk.fromMap(Map<String, dynamic> json) => Produk(
    id: json['id'],
    namaProduk: json['nama_produk'],
    stok: json['stok'],
    satuan: json['satuan'],
    hargaJual: json['harga_jual'],
    createdAt: json['created_at'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nama_produk': namaProduk,
    'stok': stok,
    'satuan': satuan,
    'harga_jual': hargaJual,
    'created_at': createdAt,
  };
}
