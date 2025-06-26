import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    try {
      _database = await _initDB('fotokopi.db');
      return _database!;
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<Database> _initDB(String filePath) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    } catch (e) {
      print('Error in _initDB: $e');
      rethrow;
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        is_premium INTEGER DEFAULT 0,
        premium_expiry TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tambahkan admin default
    var adminPassword = sha256.convert(utf8.encode('admin123')).toString();
    await db.insert('users', {
      'nama': 'Admin',
      'email': 'admin@admin.com',
      'password': adminPassword,
      'is_premium': 1,
    });

    await db.execute('''
      CREATE TABLE pengaturan_usaha (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER,
        nama_usaha TEXT DEFAULT 'Usaha Fotokopi',
        alamat TEXT,
        header_nota TEXT DEFAULT '=== NOTA TRANSAKSI ===',
        footer_nota TEXT DEFAULT 'Terima kasih telah menggunakan layanan kami!',
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE produk (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_produk TEXT NOT NULL,
        stok INTEGER DEFAULT 0,
        satuan TEXT DEFAULT 'pcs',
        harga_jual REAL DEFAULT 0.0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE layanan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_layanan TEXT NOT NULL,
        harga_per_lembar REAL NOT NULL,
        jenis TEXT DEFAULT 'fotokopi',
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE pesanan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama_pelanggan TEXT,
        no_hp TEXT,
        layanan_id INTEGER,
        jumlah INTEGER,
        total_harga REAL,
        status TEXT DEFAULT 'menunggu',
        catatan TEXT,
        tanggal_pesan TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (layanan_id) REFERENCES layanan(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE transaksi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        jenis TEXT,
        referensi_id INTEGER,
        jumlah INTEGER,
        total REAL,
        metode_pembayaran TEXT,
        tanggal TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    await db.execute('''
      CREATE TABLE keuangan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        jenis TEXT NOT NULL,
        jumlah REAL NOT NULL,
        keterangan TEXT,
        tanggal TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  // Hash password
  String hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // CRUD untuk User
  Future<int> insertUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    row['password'] = hashPassword(row['password']);
    return await db.insert('users', row);
  }

  Future<Map<String, dynamic>?> getUser(String email, String password) async {
    Database db = await instance.database;
    var hashedPassword = hashPassword(password);
    var results = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, hashedPassword],
    );
    
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<int> updateUser(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    if (row.containsKey('password')) {
      row['password'] = hashPassword(row['password']);
    }
    return await db.update('users', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteUser(int id) async {
    Database db = await instance.database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateUserEmail(int id, String newEmail) async {
    Database db = await instance.database;
    // Check if email already exists for another user
    var existing = await db.query('users', where: 'email = ? AND id != ?', whereArgs: [newEmail, id]);
    if (existing.isNotEmpty) {
      throw 'Email sudah digunakan oleh pengguna lain';
    }
    return await db.update('users', {'email': newEmail}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateUserPassword(int id, String newPassword) async {
    Database db = await instance.database;
    String hashed = hashPassword(newPassword);
    return await db.update('users', {'password': hashed}, where: 'id = ?', whereArgs: [id]);
  }

  // CRUD untuk Pengaturan Usaha
  Future<int> insertPengaturanUsaha(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('pengaturan_usaha', row);
  }

  Future<Map<String, dynamic>?> getPengaturanUsaha(int userId) async {
    Database db = await instance.database;
    var results = await db.query(
      'pengaturan_usaha',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<int> updatePengaturanUsaha(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update('pengaturan_usaha', row, where: 'id = ?', whereArgs: [id]);
  }

  // CRUD untuk Produk
  Future<int> insertProduk(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('produk', row);
  }

  Future<List<Map<String, dynamic>>> getAllProduk() async {
    Database db = await instance.database;
    return await db.query('produk', orderBy: 'nama_produk');
  }

  Future<Map<String, dynamic>?> getProduk(int id) async {
    Database db = await instance.database;
    var results = await db.query(
      'produk',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<int> updateProduk(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update('produk', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteProduk(int id) async {
    Database db = await instance.database;
    return await db.delete('produk', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD untuk Layanan
  Future<int> insertLayanan(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('layanan', row);
  }

  Future<List<Map<String, dynamic>>> getAllLayanan() async {
    Database db = await instance.database;
    return await db.query('layanan', orderBy: 'nama_layanan');
  }

  Future<Map<String, dynamic>?> getLayanan(int id) async {
    Database db = await instance.database;
    var results = await db.query(
      'layanan',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<int> updateLayanan(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update('layanan', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteLayanan(int id) async {
    Database db = await instance.database;
    return await db.delete('layanan', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD untuk Pesanan
  Future<int> insertPesanan(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('pesanan', row);
  }

  Future<List<Map<String, dynamic>>> getAllPesanan() async {
    Database db = await instance.database;
    return await db.rawQuery('''
      SELECT p.*, l.nama_layanan 
      FROM pesanan p
      JOIN layanan l ON p.layanan_id = l.id
      ORDER BY p.tanggal_pesan DESC
    ''');
  }

  Future<Map<String, dynamic>?> getPesanan(int id) async {
    Database db = await instance.database;
    var results = await db.rawQuery('''
      SELECT p.*, l.nama_layanan 
      FROM pesanan p
      JOIN layanan l ON p.layanan_id = l.id
      WHERE p.id = ?
    ''', [id]);
    
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<int> updatePesanan(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update('pesanan', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deletePesanan(int id) async {
    Database db = await instance.database;
    return await db.delete('pesanan', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD untuk Transaksi
  Future<int> insertTransaksi(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('transaksi', row);
  }

  Future<List<Map<String, dynamic>>> getAllTransaksi() async {
    Database db = await instance.database;
    return await db.query('transaksi', orderBy: 'tanggal DESC');
  }

  Future<Map<String, dynamic>?> getTransaksi(int id) async {
    Database db = await instance.database;
    var results = await db.query(
      'transaksi',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<int> updateTransaksi(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update('transaksi', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTransaksi(int id) async {
    Database db = await instance.database;
    return await db.delete('transaksi', where: 'id = ?', whereArgs: [id]);
  }

  // CRUD untuk Keuangan
  Future<int> insertKeuangan(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert('keuangan', row);
  }

  Future<List<Map<String, dynamic>>> getAllKeuangan() async {
    Database db = await instance.database;
    return await db.query('keuangan', orderBy: 'tanggal DESC');
  }

  Future<Map<String, dynamic>?> getKeuangan(int id) async {
    Database db = await instance.database;
    var results = await db.query(
      'keuangan',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (results.isNotEmpty) {
      return results.first;
    }
    return null;
  }

  Future<int> updateKeuangan(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int id = row['id'];
    return await db.update('keuangan', row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteKeuangan(int id) async {
    Database db = await instance.database;
    return await db.delete('keuangan', where: 'id = ?', whereArgs: [id]);
  }
}
