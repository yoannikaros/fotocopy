import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:fotocopy/database/database_helper.dart';
import 'package:fotocopy/models/layanan.dart';
import 'package:fotocopy/screens/layanan/layanan_form.dart';

class LayananScreen extends StatefulWidget {
  const LayananScreen({Key? key}) : super(key: key);

  @override
  State<LayananScreen> createState() => _LayananScreenState();
}

class _LayananScreenState extends State<LayananScreen> {
  List<Layanan> _layananList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLayanan();
  }

  Future<void> _loadLayanan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final layananData = await DatabaseHelper.instance.getAllLayanan();
      setState(() {
        _layananList = layananData.map((item) => Layanan.fromMap(item)).toList();
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

  Future<void> _deleteLayanan(int id) async {
    try {
      await DatabaseHelper.instance.deleteLayanan(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Layanan berhasil dihapus'),
          backgroundColor: Colors.green,
        ),
      );
      _loadLayanan();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _getServiceColor(String jenis) {
    switch (jenis.toLowerCase()) {
      case 'fotokopi':
        return Colors.blue;
      case 'print':
        return Colors.green;
      case 'foto':
        return Colors.purple;
      case 'jilid':
        return Colors.orange;
      case 'laminasi':
        return Colors.teal;
      case 'scan':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getServiceIcon(String jenis) {
    switch (jenis.toLowerCase()) {
      case 'fotokopi':
        return Icons.copy;
      case 'print':
        return Icons.print;
      case 'foto':
        return Icons.photo_camera;
      case 'jilid':
        return Icons.book;
      case 'laminasi':
        return Icons.layers;
      case 'scan':
        return Icons.scanner;
      default:
        return Icons.miscellaneous_services;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: colorScheme.surface.withOpacity(0.7),
            ),
          ),
        ),
        title: const Text(
          'Daftar Layanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [

          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer.withOpacity(0.3),
                  colorScheme.surface,
                ],
              ),
            ),
          ),
          // Content
          _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _layananList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: colorScheme.primary.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada layanan',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tambahkan layanan baru dengan tombol + di bawah',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    )
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        const SliverPadding(
                          padding: EdgeInsets.only(top: kToolbarHeight + 40),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                    final layanan = _layananList[index];
                                final serviceColor = _getServiceColor(layanan.jenis);
                                final serviceIcon = _getServiceIcon(layanan.jenis);
                                
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Card(
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      side: BorderSide(
                                        color: serviceColor.withOpacity(0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: serviceColor.withOpacity(0.05),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                      padding: const EdgeInsets.all(8),
                                                      decoration: BoxDecoration(
                                                        color: serviceColor.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(12),
                      ),
                                                      child: Icon(
                                                        serviceIcon,
                                                        color: serviceColor,
                                                        size: 24,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            layanan.namaLayanan,
                                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                              fontWeight: FontWeight.bold,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 4,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              color: serviceColor.withOpacity(0.1),
                                                              borderRadius: BorderRadius.circular(8),
                                                            ),
                                                            child: Text(
                                                              layanan.jenis[0].toUpperCase() + layanan.jenis.substring(1),
                                                              style: TextStyle(
                                                                color: serviceColor,
                                                                fontSize: 12,
                                                                fontWeight: FontWeight.w500,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Text(
                                                      'Rp ${layanan.hargaPerLembar.toStringAsFixed(0)}',
                                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                                        fontWeight: FontWeight.bold,
                                                        color: serviceColor,
                        ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                                                    TextButton.icon(
                                                      icon: const Icon(Icons.edit_outlined),
                                                      label: const Text('Edit'),
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LayananForm(layanan: layanan),
                                  ),
                                );
                                if (result == true) {
                                  _loadLayanan();
                                }
                              },
                            ),
                                                    const SizedBox(width: 8),
                                                    TextButton.icon(
                                                      icon: const Icon(Icons.delete_outline),
                                                      label: const Text('Hapus'),
                                                      style: TextButton.styleFrom(
                                                        foregroundColor: Colors.red,
                                                      ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                                          barrierColor: Colors.black54,
                                                          builder: (context) => BackdropFilter(
                                                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                                            child: AlertDialog(
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius: BorderRadius.circular(20),
                                                              ),
                                    title: const Text('Konfirmasi'),
                                    content: const Text(
                                      'Apakah Anda yakin ingin menghapus layanan ini?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Batal'),
                                      ),
                                                                FilledButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteLayanan(layanan.id!);
                                        },
                                                                  style: FilledButton.styleFrom(
                                                                    backgroundColor: Colors.red,
                                                                  ),
                                        child: const Text('Hapus'),
                                      ),
                                    ],
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: _layananList.length,
                            ),
                          ),
                        ),
                        const SliverPadding(
                          padding: EdgeInsets.only(bottom: 80),
                        ),
                      ],
                      ),
        ],
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LayananForm(),
            ),
          );
          if (result == true) {
            _loadLayanan();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Layanan'),
      ),
    );
  }
}
