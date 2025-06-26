import 'package:flutter/material.dart';
import 'package:fotocopy/database/database_helper.dart';
import 'package:fotocopy/models/pengaturan_usaha.dart';

class PengaturanScreen extends StatefulWidget {
  final int? userId;

  const PengaturanScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaUsahaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _headerNotaController = TextEditingController();
  final _footerNotaController = TextEditingController();
  
  bool _isLoading = true;
  int? _pengaturanId;

  @override
  void initState() {
    super.initState();
    _loadPengaturan();
  }

  @override
  void dispose() {
    _namaUsahaController.dispose();
    _alamatController.dispose();
    _headerNotaController.dispose();
    _footerNotaController.dispose();
    super.dispose();
  }

  Future<void> _loadPengaturan() async {
    if (widget.userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final pengaturan = await DatabaseHelper.instance.getPengaturanUsaha(widget.userId!);
      
      if (pengaturan != null) {
        setState(() {
          _pengaturanId = pengaturan['id'];
          _namaUsahaController.text = pengaturan['nama_usaha'];
          _alamatController.text = pengaturan['alamat'] ?? '';
          _headerNotaController.text = pengaturan['header_nota'];
          _footerNotaController.text = pengaturan['footer_nota'];
          _isLoading = false;
        });
      } else {
        // Buat pengaturan default jika belum ada
        await DatabaseHelper.instance.insertPengaturanUsaha({
          'user_id': widget.userId,
          'nama_usaha': 'Usaha Fotokopi',
          'alamat': '',
          'header_nota': '=== NOTA TRANSAKSI ===',
          'footer_nota': 'Terima kasih telah menggunakan layanan kami!',
        });
        
        _loadPengaturan();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _savePengaturan() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final pengaturanData = {
          'id': _pengaturanId,
          'user_id': widget.userId,
          'nama_usaha': _namaUsahaController.text,
          'alamat': _alamatController.text,
          'header_nota': _headerNotaController.text,
          'footer_nota': _footerNotaController.text,
        };

        await DatabaseHelper.instance.updatePengaturanUsaha(pengaturanData);
        
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengaturan berhasil disimpan'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Usaha'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi Usaha',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _namaUsahaController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Usaha',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama usaha tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _alamatController,
                        decoration: const InputDecoration(
                          labelText: 'Alamat',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Pengaturan Nota',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _headerNotaController,
                        decoration: const InputDecoration(
                          labelText: 'Header Nota',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Header nota tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _footerNotaController,
                        decoration: const InputDecoration(
                          labelText: 'Footer Nota',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Footer nota tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _savePengaturan,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Simpan Pengaturan'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
