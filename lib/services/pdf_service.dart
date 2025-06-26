import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:fotocopy/models/transaksi.dart';
import 'package:fotocopy/models/pengaturan_usaha.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class PdfService {
  static Future<File> generateStrukPdf({
    required Transaksi transaksi,
    required PengaturanUsaha? pengaturanUsaha,
    required String itemName,
  }) async {
    // Gunakan font default
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
      ),
    );
    
    // Referensi font untuk digunakan dalam dokumen
    final baseFont = pw.Font.helvetica();

    // Create PDF document
    // final pdf = pw.Document();

    // Add page to the PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(80 * PdfPageFormat.mm, 210 * PdfPageFormat.mm),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Header
              pw.Text(
                pengaturanUsaha?.namaUsaha ?? 'Usaha Fotokopi',
                style: pw.TextStyle(
                  font: baseFont,
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              if (pengaturanUsaha?.alamat != null && pengaturanUsaha!.alamat!.isNotEmpty)
                pw.Text(
                  pengaturanUsaha.alamat!,
                  style: pw.TextStyle(font: baseFont, fontSize: 8),
                  textAlign: pw.TextAlign.center,
                ),
              pw.SizedBox(height: 5),
              pw.Text(
                pengaturanUsaha?.headerNota ?? '=== NOTA TRANSAKSI ===',
                style: pw.TextStyle(
                  font: baseFont,
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.Divider(thickness: 1),
              pw.SizedBox(height: 5),
              
              // Transaction Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Tanggal:', style: pw.TextStyle(font: baseFont, fontSize: 8)),
                  pw.Text(
                    transaksi.tanggal ?? DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
                    style: pw.TextStyle(font: baseFont, fontSize: 8),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('No. Transaksi:', style: pw.TextStyle(font: baseFont, fontSize: 8)),
                  pw.Text('#${transaksi.id}', style: pw.TextStyle(font: baseFont, fontSize: 8)),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Jenis:', style: pw.TextStyle(font: baseFont, fontSize: 8)),
                  pw.Text(_formatJenis(transaksi.jenis), style: pw.TextStyle(font: baseFont, fontSize: 8)),
                ],
              ),
              pw.SizedBox(height: 10),
              
              // Transaction Details
              pw.Text(
                'Detail Transaksi:',
                style: pw.TextStyle(
                  font: baseFont,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.left,
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Text(itemName, style: pw.TextStyle(font: baseFont, fontSize: 8)),
                  ),
                  pw.Expanded(
                    flex: 1,
                    child: pw.Text(
                      '${transaksi.jumlah}x',
                      style: pw.TextStyle(font: baseFont, fontSize: 8),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Text(
                      'Rp ${transaksi.total.toStringAsFixed(0)}',
                      style: pw.TextStyle(font: baseFont, fontSize: 8),
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1),
              
              // Total
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total:',
                    style: pw.TextStyle(
                      font: baseFont,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Rp ${transaksi.total.toStringAsFixed(0)}',
                    style: pw.TextStyle(
                      font: baseFont,
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Metode Pembayaran:', style: pw.TextStyle(font: baseFont, fontSize: 8)),
                  pw.Text(
                    _formatMetodePembayaran(transaksi.metodePembayaran),
                    style: pw.TextStyle(font: baseFont, fontSize: 8),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Divider(thickness: 1),
              
              // Footer
              pw.Text(
                pengaturanUsaha?.footerNota ?? 'Terima kasih telah menggunakan layanan kami!',
                style: pw.TextStyle(
                  font: baseFont,
                  fontSize: 8,
                  fontStyle: pw.FontStyle.italic,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ],
          );
        },
      ),
    );

    // Save the PDF file
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/struk_transaksi_${transaksi.id}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static String _formatJenis(String jenis) {
    switch (jenis) {
      case 'penjualan_produk':
        return 'Penjualan Produk';
      case 'pesanan_layanan':
        return 'Pesanan Layanan';
      default:
        return jenis;
    }
  }

  static String _formatMetodePembayaran(String metode) {
    return metode[0].toUpperCase() + metode.substring(1);
  }
}
