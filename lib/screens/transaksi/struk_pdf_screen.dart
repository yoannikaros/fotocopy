import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:fotocopy/models/transaksi.dart';
import 'package:fotocopy/models/pengaturan_usaha.dart';
import 'package:fotocopy/services/pdf_service.dart';
import 'package:share_plus/share_plus.dart';

class StrukPdfScreen extends StatefulWidget {
  final Transaksi transaksi;
  final PengaturanUsaha? pengaturanUsaha;
  final String itemName;

  const StrukPdfScreen({
    Key? key,
    required this.transaksi,
    required this.pengaturanUsaha,
    required this.itemName,
  }) : super(key: key);

  @override
  State<StrukPdfScreen> createState() => _StrukPdfScreenState();
}

class _StrukPdfScreenState extends State<StrukPdfScreen> {
  File? _pdfFile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _generatePdf();
  }

  Future<void> _generatePdf() async {
    try {
      final file = await PdfService.generateStrukPdf(
        transaksi: widget.transaksi,
        pengaturanUsaha: widget.pengaturanUsaha,
        itemName: widget.itemName,
      );
      
      setState(() {
        _pdfFile = file;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuat PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _sharePdf() async {
    if (_pdfFile == null) return;
    
    try {
      await Share.shareXFiles(
        [XFile(_pdfFile!.path)],
        text: 'Struk Transaksi ${widget.pengaturanUsaha?.namaUsaha ?? 'Usaha Fotokopi'}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membagikan PDF: $e'),
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
        title: const Text('Preview Struk PDF'),
        actions: [
          if (!_isLoading && _pdfFile != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _sharePdf,
              tooltip: 'Bagikan PDF',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pdfFile == null
              ? const Center(child: Text('Gagal membuat PDF'))
              : PDFView(
                  filePath: _pdfFile!.path,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: false,
                  pageFling: false,
                  fitPolicy: FitPolicy.WIDTH,
                  pageSnap: true,
                  onError: (error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                ),
    );
  }
}
