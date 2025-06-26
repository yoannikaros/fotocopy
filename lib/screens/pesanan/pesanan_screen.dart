import 'package:flutter/material.dart';
import 'package:fotocopy/database/database_helper.dart';
import 'package:fotocopy/models/pesanan.dart';
import 'package:fotocopy/screens/pesanan/pesanan_form.dart';
import 'package:fotocopy/screens/pesanan/pesanan_detail.dart';

class PesananScreen extends StatefulWidget {
  const PesananScreen({Key? key}) : super(key: key);

  @override
  State<PesananScreen> createState() => _PesananScreenState();
}

class _PesananScreenState extends State<PesananScreen> with SingleTickerProviderStateMixin {
  List<Pesanan> _pesananList = [];
  bool _isLoading = true;
  String _filterStatus = 'semua';
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<String> _statusList = [
    'semua',
    'menunggu',
    'diproses',
    'selesai',
    'diambil',
  ];

  @override
  void initState() {
    super.initState();
    _loadPesanan();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadPesanan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pesananData = await DatabaseHelper.instance.getAllPesanan();
      setState(() {
        _pesananList = pesananData.map((item) => Pesanan.fromMap(item)).toList();
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

  List<Pesanan> get _filteredPesanan {
    if (_filterStatus == 'semua') {
      return _pesananList;
    } else {
      return _pesananList.where((pesanan) => pesanan.status == _filterStatus).toList();
    }
  }

  Future<void> _deletePesanan(int id) async {
    try {
      await DatabaseHelper.instance.deletePesanan(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pesanan berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
      _loadPesanan();
    } catch (e) {
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
        return Colors.orange.shade400;
      case 'diproses':
        return Colors.blue.shade400;
      case 'selesai':
        return Colors.green.shade400;
      case 'diambil':
        return Colors.purple.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar with back button
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 4, right: 4),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Text(
                      'Daftar Pesanan',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadPesanan,
                    ),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: _statusList.map((status) {
                    final isSelected = status == _filterStatus;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: isSelected,
                        label: Text(
                          status[0].toUpperCase() + status.substring(1),
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        backgroundColor: Colors.white,
                        selectedColor: Colors.blue,
                        onSelected: (bool selected) {
                          setState(() {
                            _filterStatus = status;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : _filteredPesanan.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.inbox_rounded,
                                  size: 64,
                                  color: Colors.grey.shade400,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Belum ada pesanan',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredPesanan.length,
                                itemBuilder: (context, index) {
                                  final pesanan = _filteredPesanan[index];
                                  return FadeTransition(
                                    opacity: _animation,
                                    child: Card(
                                      elevation: 2,
                                      margin: const EdgeInsets.only(bottom: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(16),
                                        onTap: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  PesananDetail(pesanan: pesanan),
                                            ),
                                          );
                                          if (result == true) {
                                            _loadPesanan();
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                        Colors.blue.shade50,
                                                    child: Text(
                                                      pesanan.namaPelanggan?.substring(0, 1).toUpperCase() ??
                                                              'T',
                                                      style: TextStyle(
                                                        color:
                                                            Colors.blue.shade700,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          pesanan.namaPelanggan ??
                                                              'Tanpa Nama',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: _getStatusColor(
                                                                pesanan.status),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12),
                                                          ),
                                                          child: Text(
                                                            pesanan.status[0]
                                                                    .toUpperCase() +
                                                                pesanan.status
                                                                    .substring(
                                                                        1),
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 12,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuButton(
                                                    icon: const Icon(
                                                        Icons.more_vert),
                                                    itemBuilder: (context) => [
                                                      PopupMenuItem(
                                                        child: ListTile(
                                                          leading: const Icon(
                                                              Icons.edit,
                                                              color:
                                                                  Colors.blue),
                                                          title: const Text(
                                                              'Edit'),
                                                          contentPadding:
                                                              EdgeInsets.zero,
                                                          onTap: () async {
                                                            Navigator.pop(
                                                                context);
                                                            final result =
                                                                await Navigator
                                                                    .push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder: (context) =>
                                                                    PesananForm(
                                                                        pesanan:
                                                                            pesanan),
                                                              ),
                                                            );
                                                            if (result ==
                                                                true) {
                                                              _loadPesanan();
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                      PopupMenuItem(
                                                        child: ListTile(
                                                          leading: const Icon(
                                                              Icons.delete,
                                                              color:
                                                                  Colors.red),
                                                          title: const Text(
                                                              'Hapus'),
                                                          contentPadding:
                                                              EdgeInsets.zero,
                                                          onTap: () {
                                                            Navigator.pop(
                                                                context);
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) =>
                                                                      AlertDialog(
                                                                title: const Text(
                                                                    'Konfirmasi'),
                                                                content:
                                                                    const Text(
                                                                  'Apakah Anda yakin ingin menghapus pesanan ini?',
                                                                ),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.pop(
                                                                            context),
                                                                    child: const Text(
                                                                        'Batal'),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                      _deletePesanan(
                                                                          pesanan.id!);
                                                                    },
                                                                    child: const Text(
                                                                        'Hapus'),
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
                                              const Divider(height: 24),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        'Layanan',
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey.shade600,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      Text(
                                                        pesanan.namaLayanan ?? '-',
                                                        style:
                                                            const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        'Jumlah',
                                                        style: TextStyle(
                                                          color: Colors
                                                              .grey.shade600,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                      Text(
                                                        '${pesanan.jumlah} lembar',
                                                        style:
                                                            const TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    'Total: ',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade600,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Rp ${pesanan.totalHarga.toStringAsFixed(0)}',
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue,
                                                    ),
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
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PesananForm(),
            ),
          );
          if (result == true) {
            _loadPesanan();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Pesanan'),
        elevation: 4,
      ),
    );
  }
}
