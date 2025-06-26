import 'package:flutter/material.dart';
import 'package:fotocopy/database/database_helper.dart';
import 'package:fotocopy/models/transaksi.dart';
import 'package:fotocopy/screens/transaksi/transaksi_form.dart';
import 'package:fotocopy/screens/transaksi/struk_screen.dart';
import 'package:intl/intl.dart';

class TransaksiScreen extends StatefulWidget {
  final int? userId;

  const TransaksiScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<TransaksiScreen> createState() => _TransaksiScreenState();
}

class _TransaksiScreenState extends State<TransaksiScreen> with SingleTickerProviderStateMixin {
  List<Transaksi> _transaksiList = [];
  bool _isLoading = true;
  String _filterJenis = 'semua';
  late AnimationController _animationController;
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final List<String> _jenisList = [
    'semua',
    'penjualan_produk',
    'pesanan_layanan',
  ];

  @override
  void initState() {
    super.initState();
    _loadTransaksi();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadTransaksi() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transaksiData = await DatabaseHelper.instance.getAllTransaksi();
      setState(() {
        _transaksiList = transaksiData.map((item) => Transaksi.fromMap(item)).toList();
        _isLoading = false;
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

  List<Transaksi> get _filteredTransaksi {
    if (_filterJenis == 'semua') {
      return _transaksiList;
    } else {
      return _transaksiList.where((transaksi) => transaksi.jenis == _filterJenis).toList();
    }
  }

  Future<void> _deleteTransaksi(int id) async {
    try {
      await DatabaseHelper.instance.deleteTransaksi(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
      _loadTransaksi();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
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

  Color _getJenisColor(String jenis) {
    switch (jenis) {
      case 'penjualan_produk':
        return Colors.blue.shade100;
      case 'pesanan_layanan':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Transaksi',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadTransaksi,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Transaksi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _filterJenis,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                      items: _jenisList.map((String jenis) {
                        return DropdownMenuItem<String>(
                          value: jenis,
                          child: Text(
                            jenis == 'semua' ? 'Semua Transaksi' : _formatJenis(jenis),
                            style: const TextStyle(color: Colors.black87),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _filterJenis = newValue!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _filteredTransaksi.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 64,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Belum ada transaksi',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredTransaksi.length,
                        itemBuilder: (context, index) {
                          final transaksi = _filteredTransaksi[index];
                          return Hero(
                            tag: 'transaksi-${transaksi.id}',
                            child: Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              margin: const EdgeInsets.only(bottom: 16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TransaksiForm(
                                        transaksi: transaksi,
                                        userId: widget.userId,
                                      ),
                                    ),
                                  );
                                  if (result == true) {
                                    _loadTransaksi();
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getJenisColor(transaksi.jenis),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              _formatJenis(transaksi.jenis),
                                              style: TextStyle(
                                                color: Colors.grey.shade800,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          PopupMenuButton(
                                            icon: const Icon(Icons.more_vert),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                child: ListTile(
                                                  leading: const Icon(Icons.receipt, color: Colors.green),
                                                  title: const Text('Lihat Struk'),
                                                  contentPadding: EdgeInsets.zero,
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => StrukScreen(
                                                          transaksi: transaksi,
                                                          userId: widget.userId ?? 1,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                              PopupMenuItem(
                                                child: ListTile(
                                                  leading: const Icon(Icons.delete, color: Colors.red),
                                                  title: const Text('Hapus'),
                                                  contentPadding: EdgeInsets.zero,
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) => AlertDialog(
                                                        title: const Text('Konfirmasi'),
                                                        content: const Text(
                                                          'Apakah Anda yakin ingin menghapus transaksi ini?',
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () => Navigator.pop(context),
                                                            child: const Text('Batal'),
                                                          ),
                                                          TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(context);
                                                              _deleteTransaksi(transaksi.id!);
                                                            },
                                                            child: const Text(
                                                              'Hapus',
                                                              style: TextStyle(color: Colors.red),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                currencyFormatter.format(transaksi.total),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Jumlah: ${transaksi.jumlah}',
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue.shade50,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  transaksi.metodePembayaran,
                                                  style: TextStyle(
                                                    color: Colors.blue.shade700,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                transaksi.tanggal ?? '-',
                                                style: TextStyle(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransaksiForm(userId: widget.userId),
            ),
          );
          if (result == true) {
            _loadTransaksi();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Transaksi Baru'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
