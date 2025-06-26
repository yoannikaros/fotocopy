import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:fotocopy/database/database_helper.dart';
import 'package:fotocopy/models/transaksi.dart';
import 'package:fotocopy/models/produk.dart';
import 'package:fotocopy/models/layanan.dart';
import 'package:fotocopy/models/pengaturan_usaha.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fotocopy/screens/transaksi/struk_pdf_screen.dart';
import 'package:fotocopy/screens/transaksi/printer_selection_screen.dart';

class StrukScreen extends StatefulWidget {
  final Transaksi transaksi;
  final int userId;

  const StrukScreen({
    Key? key,
    required this.transaksi,
    required this.userId,
  }) : super(key: key);

  @override
  State<StrukScreen> createState() => _StrukScreenState();
}

class _StrukScreenState extends State<StrukScreen> {
  bool _isLoading = true;
  PengaturanUsaha? _pengaturanUsaha;
  String _itemName = '';
  final GlobalKey _strukKey = GlobalKey();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load pengaturan usaha
      final pengaturanData = await DatabaseHelper.instance.getPengaturanUsaha(widget.userId);
      if (pengaturanData != null) {
        _pengaturanUsaha = PengaturanUsaha.fromMap(pengaturanData);
      }

      // Load item name based on transaction type
      if (widget.transaksi.jenis == 'penjualan_produk') {
        final produkData = await DatabaseHelper.instance.getProduk(widget.transaksi.referensiId);
        if (produkData != null) {
          final produk = Produk.fromMap(produkData);
          _itemName = produk.namaProduk;
        }
      } else if (widget.transaksi.jenis == 'pesanan_layanan') {
        final layananData = await DatabaseHelper.instance.getLayanan(widget.transaksi.referensiId);
        if (layananData != null) {
          final layanan = Layanan.fromMap(layananData);
          _itemName = layanan.namaLayanan;
        }
      }

      setState(() {
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

  // Perbaikan: Menambahkan delay untuk memastikan widget sudah dirender sebelum mengambil screenshot
  Future<void> _saveAndShareStruk() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Menambahkan delay untuk memastikan widget sudah dirender
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Capture the widget as an image
      final RenderRepaintBoundary? boundary = _strukKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) {
        throw Exception('Tidak dapat menemukan widget untuk screenshot');
      }
      
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) {
        throw Exception('Gagal mengambil gambar struk');
      }
      
      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/struk_transaksi.png').create();
      await file.writeAsBytes(pngBytes);

      // Share the image
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Struk Transaksi ${_pengaturanUsaha?.namaUsaha ?? 'Usaha Fotokopi'}',
      );

      setState(() {
        _isSaving = false;
      });
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan struk: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openPdfPreview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StrukPdfScreen(
          transaksi: widget.transaksi,
          pengaturanUsaha: _pengaturanUsaha,
          itemName: _itemName,
        ),
      ),
    );
  }

  void _openPrinterSelection() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PrinterSelectionScreen(
          transaksi: widget.transaksi,
          pengaturanUsaha: _pengaturanUsaha,
          itemName: _itemName,
        ),
      ),
    );
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

  String _formatMetodePembayaran(String metode) {
    return metode[0].toUpperCase() + metode.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Struk Transaksi'),
        actions: [
          if (!_isLoading)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'share':
                    _saveAndShareStruk();
                    break;
                  case 'pdf':
                    _openPdfPreview();
                    break;
                  case 'print':
                    _openPrinterSelection();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 20),
                      SizedBox(width: 8),
                      Text('Bagikan Gambar'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'pdf',
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf, size: 20),
                      SizedBox(width: 8),
                      Text('Lihat PDF'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'print',
                  child: Row(
                    children: [
                      Icon(Icons.print, size: 20),
                      SizedBox(width: 8),
                      Text('Cetak Struk'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  RepaintBoundary(
                    key: _strukKey,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            _pengaturanUsaha?.namaUsaha ?? 'Usaha Fotokopi',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_pengaturanUsaha?.alamat != null && _pengaturanUsaha!.alamat!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                _pengaturanUsaha!.alamat!,
                                style: const TextStyle(fontSize: 14),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            _pengaturanUsaha?.headerNota ?? '=== NOTA TRANSAKSI ===',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Divider(thickness: 1),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Tanggal:'),
                              Text(widget.transaksi.tanggal ?? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('No. Transaksi:'),
                              Text('#${widget.transaksi.id}'),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Jenis:'),
                              Text(_formatJenis(widget.transaksi.jenis)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Detail Transaksi:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(_itemName),
                              ),
                              Expanded(
                                flex: 1,
                                child: Text(
                                  '${widget.transaksi.jumlah}x',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  'Rp ${widget.transaksi.total.toStringAsFixed(0)}',
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(thickness: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Rp ${widget.transaksi.total.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Metode Pembayaran:'),
                              Text(_formatMetodePembayaran(widget.transaksi.metodePembayaran)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(thickness: 1),
                          Text(
                            _pengaturanUsaha?.footerNota ?? 'Terima kasih telah menggunakan layanan kami!',
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_isSaving)
                    const CircularProgressIndicator()
                  else
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _saveAndShareStruk,
                            icon: const Icon(Icons.share),
                            label: const Text('Bagikan'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _openPdfPreview,
                            icon: const Icon(Icons.picture_as_pdf),
                            label: const Text('PDF'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _openPrinterSelection,
                            icon: const Icon(Icons.print),
                            label: const Text('Cetak'),
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Tip: Screenshot struk ini atau gunakan tombol di atas untuk menyimpan, mencetak, atau membagikan struk',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }
}
