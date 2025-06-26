import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fotocopy/database/database_helper.dart';
import 'package:fotocopy/models/pesanan.dart';
import 'package:fotocopy/models/layanan.dart';

class PesananForm extends StatefulWidget {
  final Pesanan? pesanan;

  const PesananForm({Key? key, this.pesanan}) : super(key: key);

  @override
  State<PesananForm> createState() => _PesananFormState();
}

class _PesananFormState extends State<PesananForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaPelangganController = TextEditingController();
  final _noHpController = TextEditingController();
  final _jumlahController = TextEditingController();
  final _catatanController = TextEditingController();
  
  int? _selectedLayananId;
  String _status = 'menunggu';
  double _hargaPerLembar = 0;
  double _totalHarga = 0;
  bool _isLoading = true;
  List<Layanan> _layananList = [];

  final List<String> _statusList = [
    'menunggu',
    'diproses',
    'selesai',
    'diambil',
  ];

  @override
  void initState() {
    super.initState();
    _loadLayanan();
    
    if (widget.pesanan != null) {
      _namaPelangganController.text = widget.pesanan!.namaPelanggan ?? '';
      _noHpController.text = widget.pesanan!.noHp ?? '';
      _jumlahController.text = widget.pesanan!.jumlah.toString();
      _catatanController.text = widget.pesanan!.catatan ?? '';
      _selectedLayananId = widget.pesanan!.layananId;
      _status = widget.pesanan!.status;
      _totalHarga = widget.pesanan!.totalHarga;
    }
  }

  @override
  void dispose() {
    _namaPelangganController.dispose();
    _noHpController.dispose();
    _jumlahController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _loadLayanan() async {
    try {
      final layananData = await DatabaseHelper.instance.getAllLayanan();
      setState(() {
        _layananList = layananData.map((item) => Layanan.fromMap(item)).toList();
        _isLoading = false;
        
        if (_layananList.isNotEmpty && _selectedLayananId == null) {
          _selectedLayananId = _layananList[0].id;
          _hargaPerLembar = _layananList[0].hargaPerLembar;
          _hitungTotal();
        } else if (_selectedLayananId != null) {
          final selectedLayanan = _layananList.firstWhere(
            (layanan) => layanan.id == _selectedLayananId,
            orElse: () => _layananList[0],
          );
          _hargaPerLembar = selectedLayanan.hargaPerLembar;
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

  void _hitungTotal() {
    if (_jumlahController.text.isNotEmpty) {
      final jumlah = int.tryParse(_jumlahController.text) ?? 0;
      setState(() {
        _totalHarga = jumlah * _hargaPerLembar;
      });
    }
  }

  Future<void> _savePesanan() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final pesananData = {
          'nama_pelanggan': _namaPelangganController.text,
          'no_hp': _noHpController.text,
          'layanan_id': _selectedLayananId,
          'jumlah': int.parse(_jumlahController.text),
          'total_harga': _totalHarga,
          'status': _status,
          'catatan': _catatanController.text,
        };

        if (widget.pesanan != null) {
          // Update pesanan
          pesananData['id'] = widget.pesanan!.id;
          await DatabaseHelper.instance.updatePesanan(pesananData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesanan berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Tambah pesanan baru
          await DatabaseHelper.instance.insertPesanan(pesananData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pesanan berhasil ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
        }

        setState(() {
          _isLoading = false;
        });

        Navigator.pop(context, true);
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
        title: Text(widget.pesanan == null ? 'Tambah Pesanan' : 'Edit Pesanan'),
      ),
      body: _isLoading && _layananList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _namaPelangganController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Pelanggan',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _noHpController,
                        decoration: const InputDecoration(
                          labelText: 'Nomor HP',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<int>(
                        value: _selectedLayananId,
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
                              _selectedLayananId = newValue;
                              final selectedLayanan = _layananList.firstWhere(
                                (layanan) => layanan.id == newValue,
                                orElse: () => _layananList.isNotEmpty ? _layananList.first : Layanan(
                                  namaLayanan: 'Default',
                                  hargaPerLembar: 0,
                                ),
                              );
                              _hargaPerLembar = selectedLayanan.hargaPerLembar;
                              _hitungTotal();
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _jumlahController,
                        decoration: const InputDecoration(
                          labelText: 'Jumlah Lembar',
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
                        onChanged: (value) {
                          _hitungTotal();
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _status,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: _statusList.map((String status) {
                          return DropdownMenuItem<String>(
                            value: status,
                            child: Text(status[0].toUpperCase() + status.substring(1)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _status = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _catatanController,
                        decoration: const InputDecoration(
                          labelText: 'Catatan',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.blue.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Harga per Lembar:'),
                                  Text('Rp ${_hargaPerLembar.toStringAsFixed(0)}'),
                                ],
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Harga:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Rp ${_totalHarga.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _savePesanan,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(widget.pesanan == null ? 'Simpan' : 'Perbarui'),
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
