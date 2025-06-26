import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../database/database_helper.dart';
import '../../models/layanan.dart';

class LayananForm extends StatefulWidget {
  final Layanan? layanan;

  const LayananForm({Key? key, this.layanan}) : super(key: key);

  @override
  State<LayananForm> createState() => _LayananFormState();
}

class _LayananFormState extends State<LayananForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaLayananController = TextEditingController();
  final _hargaPerLembarController = TextEditingController();
  String _jenisLayanan = 'fotokopi';
  bool _isLoading = false;

  final List<String> _jenisLayananList = [
    'fotokopi',
    'print',
    'foto',
    'jilid',
    'laminasi',
    'scan',
    'lainnya',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.layanan != null) {
      _namaLayananController.text = widget.layanan!.namaLayanan;
      _hargaPerLembarController.text = widget.layanan!.hargaPerLembar.toString();
      _jenisLayanan = widget.layanan!.jenis;
    }
  }

  @override
  void dispose() {
    _namaLayananController.dispose();
    _hargaPerLembarController.dispose();
    super.dispose();
  }

  Future<void> _saveLayanan() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final layananData = {
          'nama_layanan': _namaLayananController.text,
          'harga_per_lembar': double.parse(_hargaPerLembarController.text),
          'jenis': _jenisLayanan,
        };

        if (widget.layanan != null) {
          // Update layanan
          // Perbaikan: Memastikan id tidak null dengan null check
          if (widget.layanan!.id != null) {
            layananData['id'] = widget.layanan!.id!;
            await DatabaseHelper.instance.updateLayanan(layananData);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Layanan berhasil diperbarui'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            throw Exception('ID layanan tidak valid');
          }
        } else {
          // Tambah layanan baru
          await DatabaseHelper.instance.insertLayanan(layananData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Layanan berhasil ditambahkan'),
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
        title: Text(widget.layanan == null ? 'Tambah Layanan' : 'Edit Layanan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _namaLayananController,
                  decoration: const InputDecoration(
                    labelText: 'Nama Layanan',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama layanan tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _jenisLayanan,
                  decoration: const InputDecoration(
                    labelText: 'Jenis Layanan',
                    border: OutlineInputBorder(),
                  ),
                  items: _jenisLayananList.map((String jenis) {
                    return DropdownMenuItem<String>(
                      value: jenis,
                      child: Text(jenis[0].toUpperCase() + jenis.substring(1)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _jenisLayanan = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _hargaPerLembarController,
                  decoration: const InputDecoration(
                    labelText: 'Harga per Lembar',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Harga per lembar tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveLayanan,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(widget.layanan == null ? 'Simpan' : 'Perbarui'),
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
