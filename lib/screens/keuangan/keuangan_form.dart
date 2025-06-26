import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';


import '../../database/database_helper.dart';
import '../../models/keuangan.dart';

class KeuanganForm extends StatefulWidget {
  final Keuangan? keuangan;

  const KeuanganForm({Key? key, this.keuangan}) : super(key: key);

  @override
  State<KeuanganForm> createState() => _KeuanganFormState();
}

class _KeuanganFormState extends State<KeuanganForm> {
  final _formKey = GlobalKey<FormState>();
  final _jumlahController = TextEditingController();
  final _keteranganController = TextEditingController();

  String _jenis = 'pemasukan';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.keuangan != null) {
      _jenis = widget.keuangan!.jenis;
      _jumlahController.text = widget.keuangan!.jumlah.toString();
      _keteranganController.text = widget.keuangan!.keterangan ?? '';
    }
  }

  @override
  void dispose() {
    _jumlahController.dispose();
    _keteranganController.dispose();
    super.dispose();
  }

  Future<void> _saveKeuangan() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final now = DateTime.now();
        final tanggal = DateFormat('yyyy-MM-dd').format(now);
        final keuanganData = {
          'jenis': _jenis,
          'jumlah': double.parse(_jumlahController.text),
          'keterangan': _keteranganController.text,
          'tanggal': tanggal,
        };

        if (widget.keuangan != null) {
          // Update keuangan
          // Perbaikan: Memastikan id tidak null dengan null assertion operator
          // dan mengkonversi ke tipe yang diharapkan
          if (widget.keuangan!.id != null) {
            keuanganData['id'] = widget.keuangan!.id!;
            await DatabaseHelper.instance.updateKeuangan(keuanganData);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data keuangan berhasil diperbarui'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            throw Exception('ID keuangan tidak valid');
          }
        } else {
          // Tambah keuangan baru
          await DatabaseHelper.instance.insertKeuangan(keuanganData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data keuangan berhasil ditambahkan'),
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
        title: Text(widget.keuangan == null ? 'Tambah Keuangan' : 'Edit Keuangan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(
                      value: 'pemasukan',
                      label: Text('Pemasukan'),
                      icon: Icon(Icons.arrow_downward),
                    ),
                    ButtonSegment<String>(
                      value: 'pengeluaran',
                      label: Text('Pengeluaran'),
                      icon: Icon(Icons.arrow_upward),
                    ),
                  ],
                  selected: {_jenis},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _jenis = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _jumlahController,
                  decoration: const InputDecoration(
                    labelText: 'Jumlah',
                    border: OutlineInputBorder(),
                    prefixText: 'Rp ',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Jumlah tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _keteranganController,
                  decoration: const InputDecoration(
                    labelText: 'Keterangan',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveKeuangan,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(widget.keuangan == null ? 'Simpan' : 'Perbarui'),
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
