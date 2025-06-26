import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fotocopy/database/database_helper.dart';
import 'package:fotocopy/models/produk.dart';

class ProdukForm extends StatefulWidget {
  final Produk? produk;

  const ProdukForm({Key? key, this.produk}) : super(key: key);

  @override
  State<ProdukForm> createState() => _ProdukFormState();
}

class _ProdukFormState extends State<ProdukForm> {
  final _formKey = GlobalKey<FormState>();
  final _namaProdukController = TextEditingController();
  final _stokController = TextEditingController();
  final _satuanController = TextEditingController();
  final _hargaJualController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.produk != null) {
      _namaProdukController.text = widget.produk!.namaProduk;
      _stokController.text = widget.produk!.stok.toString();
      _satuanController.text = widget.produk!.satuan;
      _hargaJualController.text = widget.produk!.hargaJual.toString();
    } else {
      _satuanController.text = 'pcs';
    }
  }

  @override
  void dispose() {
    _namaProdukController.dispose();
    _stokController.dispose();
    _satuanController.dispose();
    _hargaJualController.dispose();
    super.dispose();
  }

  Future<void> _saveProduk() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final produkData = {
          'nama_produk': _namaProdukController.text,
          'stok': int.parse(_stokController.text),
          'satuan': _satuanController.text,
          'harga_jual': double.parse(_hargaJualController.text),
        };

        if (widget.produk != null) {
          // Update produk
          // Perbaikan: Memastikan id tidak null dengan null check
          if (widget.produk!.id != null) {
            produkData['id'] = widget.produk!.id!;
            await DatabaseHelper.instance.updateProduk(produkData);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Produk berhasil diperbarui'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            throw Exception('ID produk tidak valid');
          }
        } else {
          // Tambah produk baru
          await DatabaseHelper.instance.insertProduk(produkData);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Produk berhasil ditambahkan'),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.produk == null ? 'Tambah Produk' : 'Edit Produk'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header section
                  if (widget.produk == null)
                    Column(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 48,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tambah Produk Baru',
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lengkapi informasi produk di bawah ini',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),
                      ],
                    )
                  else
                    const SizedBox(height: 8),

                  // Form fields
                  TextFormField(
                    controller: _namaProdukController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Produk',
                      hintText: 'Masukkan nama produk',
                      prefixIcon: Icon(Icons.label_outline),
                    ),
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama produk tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _stokController,
                          decoration: const InputDecoration(
                            labelText: 'Stok',
                            hintText: 'Jumlah stok',
                            prefixIcon: Icon(Icons.inventory_outlined),
                          ),
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Stok tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _satuanController,
                          decoration: const InputDecoration(
                            labelText: 'Satuan',
                            hintText: 'pcs, kg, dll',
                            prefixIcon: Icon(Icons.straighten_outlined),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Satuan tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _hargaJualController,
                    decoration: const InputDecoration(
                      labelText: 'Harga Jual',
                      hintText: 'Masukkan harga jual',
                      prefixIcon: Icon(Icons.attach_money_outlined),
                      prefixText: 'Rp ',
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Harga jual tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _isLoading ? null : _saveProduk,
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                        : Text(widget.produk == null ? 'Simpan Produk' : 'Perbarui Produk'),
                  ),
                  if (widget.produk != null) ...[
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
