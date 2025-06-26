import 'package:flutter/material.dart';
import 'package:fotocopy/database/database_helper.dart';
import 'package:fotocopy/models/pengaturan_usaha.dart';

class BusinessSettingsScreen extends StatefulWidget {
  final int userId;

  const BusinessSettingsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<BusinessSettingsScreen> createState() => _BusinessSettingsScreenState();
}

class _BusinessSettingsScreenState extends State<BusinessSettingsScreen> {
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
    try {
      final pengaturan = await DatabaseHelper.instance.getPengaturanUsaha(widget.userId);
      
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
        // Create default settings if none exist
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Business settings saved successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Business Settings'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Business Information',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _namaUsahaController,
                            decoration: InputDecoration(
                              labelText: 'Business Name',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.business),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Business name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _alamatController,
                            decoration: InputDecoration(
                              labelText: 'Address',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.location_on_outlined),
                            ),
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Receipt Settings',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _headerNotaController,
                            decoration: InputDecoration(
                              labelText: 'Receipt Header',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.title),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Receipt header is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _footerNotaController,
                            decoration: InputDecoration(
                              labelText: 'Receipt Footer',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              prefixIcon: const Icon(Icons.format_align_center),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Receipt footer is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(20),
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _savePengaturan,
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Save Settings'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
} 