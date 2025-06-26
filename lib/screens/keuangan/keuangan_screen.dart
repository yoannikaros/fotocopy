import 'package:flutter/material.dart';
import 'package:fotocopy/database/database_helper.dart';
import 'package:fotocopy/models/keuangan.dart';
import 'package:fotocopy/screens/keuangan/keuangan_form.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class KeuanganScreen extends StatefulWidget {
  const KeuanganScreen({Key? key}) : super(key: key);

  @override
  State<KeuanganScreen> createState() => _KeuanganScreenState();
}

class _KeuanganScreenState extends State<KeuanganScreen> with SingleTickerProviderStateMixin {
  List<Keuangan> _keuanganList = [];
  bool _isLoading = true;
  String _filterJenis = 'semua';
  double _totalPemasukan = 0;
  double _totalPengeluaran = 0;
  double _saldo = 0;
  late AnimationController _animationController;
  final currencyFormatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final List<String> _jenisList = [
    'semua',
    'pemasukan',
    'pengeluaran',
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadKeuangan();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadKeuangan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final keuanganData = await DatabaseHelper.instance.getAllKeuangan();
      print('DEBUG: Data keuangan dari DB:');
      print(keuanganData);
      double pemasukan = 0;
      double pengeluaran = 0;
      final keuanganItems = keuanganData.map((item) {
        final keuangan = Keuangan.fromMap(item);
        if (keuangan.jenis == 'pemasukan') {
          pemasukan += keuangan.jumlah;
        } else if (keuangan.jenis == 'pengeluaran') {
          pengeluaran += keuangan.jumlah;
        }
        return keuangan;
      }).toList();
      setState(() {
        _keuanganList = keuanganItems;
        _totalPemasukan = pemasukan;
        _totalPengeluaran = pengeluaran;
        _saldo = pemasukan - pengeluaran;
        _isLoading = false;
      });
      _animationController.reset();
      _animationController.forward();
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

  List<Keuangan> get _filteredKeuangan {
    print('DEBUG: Filter aktif: [32m[1m[4m[7m$_filterJenis[0m');
    print('DEBUG: Data sebelum filter: ' + _keuanganList.map((e) => e.toMap()).toList().toString());
    if (_filterJenis == 'semua') {
      print('DEBUG: Data setelah filter: ' + _keuanganList.length.toString());
      return _keuanganList;
    } else {
      final filtered = _keuanganList.where((keuangan) => keuangan.jenis == _filterJenis).toList();
      print('DEBUG: Data setelah filter: ' + filtered.length.toString());
      return filtered;
    }
  }

  Future<void> _deleteKeuangan(int id) async {
    try {
      await DatabaseHelper.instance.deleteKeuangan(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data keuangan berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
      _loadKeuangan();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6B8EE8), Color(0xFF5C6BC0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ringkasan Keuangan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Pemasukan',
                    _totalPemasukan,
                    Icons.arrow_upward,
                    Colors.greenAccent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    'Pengeluaran',
                    _totalPengeluaran,
                    Icons.arrow_downward,
                    Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Saldo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    currencyFormatter.format(_saldo),
                    style: TextStyle(
                      color: _saldo >= 0 ? Colors.greenAccent : Colors.redAccent,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currencyFormatter.format(amount),
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: DropdownButtonFormField<String>(
        value: _filterJenis,
        decoration: InputDecoration(
          labelText: 'Filter Transaksi',
          labelStyle: TextStyle(color: Colors.grey[600]),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.filter_list, color: Color(0xFF5C6BC0)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        items: _jenisList.map((String jenis) {
          return DropdownMenuItem<String>(
            value: jenis,
            child: Text(
              jenis[0].toUpperCase() + jenis.substring(1),
              style: const TextStyle(fontSize: 16),
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _filterJenis = newValue!;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Keuangan'),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadKeuangan,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildSummaryCard(),
                    _buildFilterDropdown(),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.6,
                      child: _filteredKeuangan.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.account_balance_wallet_outlined,
                                      size: 64, color: Colors.grey[400]),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Belum ada data keuangan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _filteredKeuangan.length,
                              itemBuilder: (context, index) {
                                final keuangan = _filteredKeuangan[index];
                                return AnimatedBuilder(
                                  animation: _animationController,
                                  builder: (context, child) {
                                    return SlideTransition(
                                      position: Tween<Offset>(
                                        begin: const Offset(1, 0),
                                        end: Offset.zero,
                                      ).animate(CurvedAnimation(
                                        parent: _animationController,
                                        curve: Interval(
                                          index / _filteredKeuangan.length,
                                          (index + 1) / _filteredKeuangan.length,
                                          curve: Curves.easeOut,
                                        ),
                                      )),
                                      child: child,
                                    );
                                  },
                                  child: Card(
                                    elevation: 2,
                                    margin: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      leading: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: keuangan.jenis == 'pemasukan'
                                              ? Colors.green.withOpacity(0.1)
                                              : Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Icon(
                                          keuangan.jenis == 'pemasukan'
                                              ? Icons.arrow_downward
                                              : Icons.arrow_upward,
                                          color: keuangan.jenis == 'pemasukan'
                                              ? Colors.green
                                              : Colors.red,
                                        ),
                                      ),
                                      title: Text(
                                        keuangan.jenis == 'pemasukan' ? 'Pemasukan' : 'Pengeluaran',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            currencyFormatter.format(keuangan.jumlah),
                                            style: TextStyle(
                                              color: keuangan.jenis == 'pemasukan'
                                                  ? Colors.green
                                                  : Colors.red,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            keuangan.keterangan ?? '-',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            'Tanggal: ${keuangan.tanggal}',
                                            style: TextStyle(
                                              color: Colors.grey[500],
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit,
                                                color: Color(0xFF5C6BC0), size: 22),
                                            onPressed: () async {
                                              final result = await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      KeuanganForm(keuangan: keuangan),
                                                ),
                                              );
                                              if (result == true) {
                                                _loadKeuangan();
                                              }
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red, size: 22),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder: (context) => AlertDialog(
                                                  title: const Text('Konfirmasi'),
                                                  content: const Text(
                                                      'Apakah Anda yakin ingin menghapus data ini?'),
                                                  actions: [
                                                    TextButton(
                                                      child: const Text('Batal'),
                                                      onPressed: () => Navigator.pop(context),
                                                    ),
                                                    TextButton(
                                                      child: const Text('Hapus'),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        _deleteKeuangan(keuangan.id!);
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const KeuanganForm(),
            ),
          );
          if (result == true) {
            _loadKeuangan();
          }
        },
        backgroundColor: const Color(0xFF5C6BC0),
        child: const Icon(Icons.add),
      ),
    );
  }
}
