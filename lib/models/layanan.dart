class Layanan {
  final int? id;
  final String namaLayanan;
  final double hargaPerLembar;
  final String jenis;
  final String? createdAt;

  Layanan({
    this.id,
    required this.namaLayanan,
    required this.hargaPerLembar,
    this.jenis = 'fotokopi',
    this.createdAt,
  });

  factory Layanan.fromMap(Map<String, dynamic> json) => Layanan(
    id: json['id'],
    namaLayanan: json['nama_layanan'],
    hargaPerLembar: json['harga_per_lembar'],
    jenis: json['jenis'],
    createdAt: json['created_at'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nama_layanan': namaLayanan,
    'harga_per_lembar': hargaPerLembar,
    'jenis': jenis,
    'created_at': createdAt,
  };
}
