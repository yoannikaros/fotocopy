import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fotocopy/database/database_helper.dart';
import 'package:fotocopy/models/transaksi.dart';
import 'package:fotocopy/models/produk.dart';
import 'package:fotocopy/models/layanan.dart';
import 'package:fotocopy/screens/transaksi/struk_screen.dart';

class TransaksiForm extends StatefulWidget {
  final Transaksi? transaksi;
  final int? userId;

  const TransaksiForm({Key? key, this.transaksi, this.userId}) : super(key: key);

  @override
  State<TransaksiForm> createState() => _TransaksiFormState();
}

class _TransaksiFormState extends State<TransaksiForm> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _totalController = TextEditingController();
  
  String _jenis = 'penjualan_produk';
  int? _referensiId;
  String _metodePembayaran = 'tunai';
  bool _isLoading = true;
  List<Produk> _produkList = [];
  List<Layanan> _layananList = [];

  final List<String> _jenisList = [
    'penjualan_produk',
    'pesanan_layanan',
  ];

  final List<String> _metodePembayaranList = [
    'tunai',
    'transfer',
    'qris',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    
    if (widget.transaksi != null) {
      _jenis = widget.transaksi!.jenis;
      _referensiId = widget.transaksi!.referensiId;
      _jumlahController.text = widget.transaksi!.jumlah.toString();
      _totalController.text = widget.transaksi!.total.toString();
      _metodePembayaran = widget.transaksi!.metodePembayaran;
    }
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _totalController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final produkData = await DatabaseHelper.instance.getAllProduk();
      final layananData = await DatabaseHelper.instance.getAllLayanan();
      
      setState(() {
        _produkList = produkData.map((item) => Produk.fromMap(item)).toList();
        _layananList = layananData.map((item) => Layanan.fromMap(item)).toList();
        _isLoading = false;
        
        if (_jenis == 'penjualan_produk' && _produkList.isNotEmpty && _referensiId == null) {
          _referensiId = _produkList[0].id;
        } else if (_jenis == 'pesanan_layanan' && _layananList.isNotEmpty && _referensiId == null) {
          _referensiId = _layananList[0].id;
        }
      });
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

  // Perbaikan: Memperbaiki logika untuk mengambil harga produk/layanan saat dipilih
  void _updateHargaOtomatis() {
    if (_referensiId == null || _jumlahController.text.isEmpty) return;
    
    int jumlah = int.tryParse(_jumlahController.text) ?? 0;
    double hargaSatuan = 0;
    
    try {
      if (_jenis == 'penjualan_produk') {
        if (_produkList.isEmpty) return;
        
        final produk = _produkList.firstWhere(
          (p) => p.id == _referensiId,
          orElse: () => _produkList.first,
        );
        hargaSatuan = produk.hargaJual;
      } else if (_jenis == 'pesanan_layanan') {
        if (_layananList.isEmpty) return;
        
        final layanan = _layananList.firstWhere(
          (l) => l.id == _referensiId,
          orElse: () => _layananList.first,
        );
        hargaSatuan = layanan.hargaPerLembar;
      }
      
      double total = jumlah * hargaSatuan;
      _totalController.text = total.toString();
    } catch (e) {
      // Tangani error dengan diam-diam
      print('Error updating price: $e');
    }
  }

  Future<void> _saveTransaksi() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final transaksiData = {
          'jenis': _jenis,
          'referensi_id': _referensiId,
          'jumlah': int.parse(_jumlahController.text),
          'total': double.parse(_totalController.text),
          'metode_pembayaran': _metodePembayaran,
        };

        int transaksiId;
        
        if (widget.transaksi != null) {
          // Update transaksi
          transaksiData['id'] = widget.transaksi!.id;
          await DatabaseHelper.instance.updateTransaksi(transaksiData);
          transaksiId = widget.transaksi!.id!;
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaksi berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Tambah transaksi baru
          transaksiId = await DatabaseHelper.instance.insertTransaksi(transaksiData);
          
          // Tambahkan ke keuangan sebagai pemasukan
          await DatabaseHelper.instance.insertKeuangan({
            'jenis': 'pemasukan',
            'jumlah': double.parse(_totalController.text),
            'keterangan': 'Transaksi ${_jenis == 'penjualan_produk' ? 'penjualan produk' : 'layanan'}',
          });
          
          // Update stok jika penjualan produk
          if (_jenis == 'penjualan_produk') {
            final produk = _produkList.firstWhere((p) => p.id == _referensiId);
            final newStok = produk.stok - int.parse(_jumlahController.text);
            
            if (newStok >= 0) {
              await DatabaseHelper.instance.updateProduk({
                'id': produk.id,
                'stok': newStok,
              });
            }
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transaksi berhasil ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
        }

        setState(() {
          _isLoading = false;
        });

        // Ambil data transaksi yang baru saja dibuat/diupdate
        final transaksiResult = await DatabaseHelper.instance.getTransaksi(transaksiId);
        if (transaksiResult != null) {
          final transaksi = Transaksi.fromMap(transaksiResult);
          
          // Perbaikan: Menggunakan push biasa, bukan pushReplacement
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StrukScreen(
                transaksi: transaksi,
                userId: widget.userId ?? 1, // Default ke 1 jika tidak ada userId
              ),
            ),
          ).then((_) {
            // Kembali ke halaman sebelumnya setelah melihat struk
            Navigator.pop(context, true);
          });
        } else {
          if (!mounted) return;
          Navigator.pop(context, true);
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
  }

  String _formatJenis(String jenis) {
    switch (jenis) {
      case 'penjualan_produk':
        return 'Penjualan Produk';
      case 'pesanan_layanan':
        return 'Pesanan Layanan';
      default:
        return jenis;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaksi == null ? 'Tambah Transaksi' : 'Edit Transaksi'),
      ),
      body: _isLoading && (_produkList.isEmpty || _layananList.isEmpty)
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: _jenis,
                        decoration: const InputDecoration(
                          labelText: 'Jenis Transaksi',
                          border: OutlineInputBorder(),
                        ),
                        items: _jenisList.map((String jenis) {
                          return DropdownMenuItem<String>(
                            value: jenis,
                            child: Text(_formatJenis(jenis)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _jenis = newValue!;
                            _referensiId = null;
                            // Reset total saat jenis berubah
                            _totalController.text = '';
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      if (_jenis == 'penjualan_produk') ...[
                        DropdownButtonFormField<int>(
                          value: _referensiId,
                          decoration: const InputDecoration(
                            labelText: 'Produk',
                            border: OutlineInputBorder(),
                          ),
                          items: _produkList.isEmpty
                              ? [const DropdownMenuItem<int>(value: null, child: Text('Tidak ada produk'))]
                              : _produkList.map((Produk produk) {
                                  return DropdownMenuItem<int>(
                                    value: produk.id,
                                    child: Text(
                                      '${produk.namaProduk} - Rp ${produk.hargaJual.toStringAsFixed(0)}',
                                    ),
                                  );
                                }).toList(),
                          validator: (value) {
                            if (_produkList.isEmpty) {
                              return 'Tambahkan produk terlebih dahulu';
                            }
                            if (value == null) {
                              return 'Pilih produk';
                            }
                            return null;
                          },
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _referensiId = newValue;
                                _updateHargaOtomatis();
                              });
                            }
                          },
                        ),
                      ] else if (_jenis == 'pesanan_layanan') ...[
                        DropdownButtonFormField<int>(
                          value: _referensiId,
                          decoration: const InputDecoration(
                            labelText: 'Layanan',
                            border: OutlineInputBorder(),
                          ),
                          items: _layananList.isEmpty
                              ? [const DropdownMenuItem<int>(value: null, child: Text('Tidak ada layanan'))]
                              : _layananList.map((Layanan layanan) {
                                  return DropdownMenuItem<int>(
                                    value: layanan.id,
                                    child: Text(
                                      '${layanan.namaLayanan} - Rp ${layanan.hargaPerLembar.toStringAsFixed(0)}/lembar',
                                    ),
                                  );
                                }).toList(),
                          validator: (value) {
                            if (_layananList.isEmpty) {
                              return 'Tambahkan layanan terlebih dahulu';
                            }
                            if (value == null) {
                              return 'Pilih layanan';
                            }
                            return null;
                          },
                          onChanged: (int? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _referensiId = newValue;
                                _updateHargaOtomatis();
                              });
                            }
                          },
                        ),
                      ],
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _jumlahController,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Jumlah tidak boleh kosong';
                          }
                          if (int.tryParse(value) == 0) {
                            return 'Jumlah harus lebih dari 0';
                          }
                          return null;
                        },
                        onChanged: (_) {
                          _updateHargaOtomatis();
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _totalController,
                        decoration: const InputDecoration(
                          labelText: 'Total Harga',
                          border: OutlineInputBorder(),
                          prefixText: 'Rp ',
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Total harga tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _metodePembayaran,
                        decoration: const InputDecoration(
                          labelText: 'Metode Pembayaran',
                          border: OutlineInputBorder(),
                        ),
                        items: _metodePembayaranList.map((String metode) {
                          return DropdownMenuItem<String>(
                            value: metode,
                            child: Text(metode[0].toUpperCase() + metode.substring(1)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _metodePembayaran = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveTransaksi,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(widget.transaksi == null ? 'Simpan & Buat Struk' : 'Perbarui & Buat Struk'),
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
