class User {
  final int? id;
  final String nama;
  final String email;
  final String password;
  final int isPremium;
  final String? premiumExpiry;
  final String? createdAt;

  User({
    this.id,
    required this.nama,
    required this.email,
    required this.password,
    this.isPremium = 0,
    this.premiumExpiry,
    this.createdAt,
  });

  factory User.fromMap(Map<String, dynamic> json) => User(
    id: json['id'],
    nama: json['nama'],
    email: json['email'],
    password: json['password'],
    isPremium: json['is_premium'],
    premiumExpiry: json['premium_expiry'],
    createdAt: json['created_at'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'nama': nama,
    'email': email,
    'password': password,
    'is_premium': isPremium,
    'premium_expiry': premiumExpiry,
    'created_at': createdAt,
  };
}
