import 'package:flutter/material.dart';
import 'package:fotocopy/database/database_helper.dart';
import 'package:fotocopy/models/pesanan.dart';
import 'package:fotocopy/screens/pesanan/pesanan_form.dart';

class PesananDetail extends StatefulWidget {
  final Pesanan pesanan;

  const PesananDetail({Key? key, required this.pesanan}) : super(key: key);

  @override
  State<PesananDetail> createState() => _PesananDetailState();
}

class _PesananDetailState extends State<PesananDetail> {
  late Pesanan _pesanan;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pesanan = widget.pesanan;
  }

  Future<void> _updateStatus(String status) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pesananData = {
        'id': _pesanan.id,
        'status': status,
      };

      await DatabaseHelper.instance.updatePesanan(pesananData);
      
      // Refresh pesanan data
      final updatedPesanan = await DatabaseHelper.instance.getPesanan(_pesanan.id!);
      
      setState(() {
        _pesanan = Pesanan.fromMap(updatedPesanan!);
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Status pesanan berhasil diperbarui'),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'menunggu':
        return Colors.orange;
      case 'diproses':
        return Colors.blue;
      case 'selesai':
        return Colors.green;
      case 'diambil':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PesananForm(pesanan: _pesanan),
                ),
              );
              if (result == true) {
                Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Status Pesanan:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(_pesanan.status),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _pesanan.status[0].toUpperCase() +
                                      _pesanan.status.substring(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Informasi Pelanggan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          _buildInfoRow('Nama', _pesanan.namaPelanggan ?? '-'),
                          _buildInfoRow('No. HP', _pesanan.noHp ?? '-'),
                          const SizedBox(height: 16),
                          const Text(
                            'Detail Pesanan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(),
                          _buildInfoRow('Layanan', _pesanan.namaLayanan ?? '-'),
                          _buildInfoRow('Jumlah', '${_pesanan.jumlah} lembar'),
                          _buildInfoRow(
                            'Total Harga',
                            'Rp ${_pesanan.totalHarga.toStringAsFixed(0)}',
                          ),
                          _buildInfoRow(
                            'Tanggal Pesan',
                            _pesanan.tanggalPesan ?? '-',
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Catatan:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(_pesanan.catatan ?? '-'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Ubah Status Pesanan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.hourglass_empty),
                          label: const Text('Menunggu'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _pesanan.status == 'menunggu'
                                ? Colors.orange
                                : Colors.grey.shade300,
                            foregroundColor: _pesanan.status == 'menunggu'
                                ? Colors.white
                                : Colors.black,
                          ),
                          onPressed: _pesanan.status == 'menunggu'
                              ? null
                              : () => _updateStatus('menunggu'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.pending_actions),
                          label: const Text('Diproses'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _pesanan.status == 'diproses'
                                ? Colors.blue
                                : Colors.grey.shade300,
                            foregroundColor: _pesanan.status == 'diproses'
                                ? Colors.white
                                : Colors.black,
                          ),
                          onPressed: _pesanan.status == 'diproses'
                              ? null
                              : () => _updateStatus('diproses'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.check_circle),
                          label: const Text('Selesai'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _pesanan.status == 'selesai'
                                ? Colors.green
                                : Colors.grey.shade300,
                            foregroundColor: _pesanan.status == 'selesai'
                                ? Colors.white
                                : Colors.black,
                          ),
                          onPressed: _pesanan.status == 'selesai'
                              ? null
                              : () => _updateStatus('selesai'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.delivery_dining),
                          label: const Text('Diambil'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _pesanan.status == 'diambil'
                                ? Colors.purple
                                : Colors.grey.shade300,
                            foregroundColor: _pesanan.status == 'diambil'
                                ? Colors.white
                                : Colors.black,
                          ),
                          onPressed: _pesanan.status == 'diambil'
                              ? null
                              : () => _updateStatus('diambil'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
