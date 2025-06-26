class Keuangan {
  final int? id;
  final String jenis;
  final double jumlah;
  final String? keterangan;
  final String? tanggal;

  Keuangan({
    this.id,
    required this.jenis,
    required this.jumlah,
    this.keterangan,
    this.tanggal,
  });

  factory Keuangan.fromMap(Map<String, dynamic> json) => Keuangan(
    id: json['id'],
    jenis: json['jenis'],
    jumlah: json['jumlah'],
    keterangan: json['keterangan'],
    tanggal: json['tanggal'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'jenis': jenis,
    'jumlah': jumlah,
    'keterangan': keterangan,
    'tanggal': tanggal,
  };
}
