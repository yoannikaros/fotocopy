import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:fotocopy/models/transaksi.dart';
import 'package:fotocopy/models/pengaturan_usaha.dart';
import 'package:fotocopy/services/pdf_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:esc_pos_utils_updated/esc_pos_utils_updated.dart';
import 'dart:ui' as ui;

class PrintService {
  static Future<List<PrinterDevice>> getBluetoothDevices() async {
    // Request permissions
    Map<Permission, PermissionStatus> statuses =
        await [
          Permission.bluetooth,
          Permission.bluetoothConnect,
          Permission.bluetoothScan,
          Permission.location,
        ].request();

    if (statuses[Permission.bluetooth]!.isGranted &&
        statuses[Permission.bluetoothConnect]!.isGranted &&
        statuses[Permission.bluetoothScan]!.isGranted &&
        statuses[Permission.location]!.isGranted) {
      // Initialize printer
      var printerManager = PrinterManager.instance;

      // Get bluetooth devices
      List<PrinterDevice> devices = [];
      try {
        // Menggunakan discovery yang mengembalikan Stream dan mengumpulkannya menjadi List
        await for (var device in printerManager.discovery(
          type: PrinterType.bluetooth,
        )) {
          devices.add(device);
        }
        return devices;
      } catch (e) {
        print('Error discovering printers: $e');
        throw Exception('Gagal menemukan printer: $e');
      }
    } else {
      throw Exception('Izin Bluetooth atau Lokasi ditolak');
    }
  }

  static Future<void> printToPrinter({
    required PrinterDevice printer,
    required Transaksi transaksi,
    required PengaturanUsaha? pengaturanUsaha,
    required String itemName,
  }) async {
    try {
      // Validasi printer
      if (printer.address == null || printer.address!.isEmpty) {
        throw Exception('Alamat printer tidak valid');
      }

      // Generate PDF
      final pdfFile = await PdfService.generateStrukPdf(
        transaksi: transaksi,
        pengaturanUsaha: pengaturanUsaha,
        itemName: itemName,
      );

      // Baca file PDF sebagai bytes
      final pdfBytes = await pdfFile.readAsBytes();

      // Menggunakan ESC/POS commands untuk mencetak teks langsung
      // Ini adalah pendekatan yang lebih sederhana daripada mencoba mengkonversi PDF ke gambar

      // Buat generator ESC/POS
      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);

      // Buat ESC/POS commands
      List<int> bytes = [];

      // Header
      bytes += generator.text(
        pengaturanUsaha?.namaUsaha ?? 'Usaha Fotokopi',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );

      if (pengaturanUsaha?.alamat != null &&
          pengaturanUsaha!.alamat!.isNotEmpty) {
        bytes += generator.text(
          pengaturanUsaha.alamat!,
          styles: const PosStyles(align: PosAlign.center),
        );
      }

      bytes += generator.text(
        pengaturanUsaha?.headerNota ?? '=== NOTA TRANSAKSI ===',
        styles: const PosStyles(align: PosAlign.center, bold: true),
      );

      bytes += generator.hr();

      // Transaction info
      bytes += generator.row([
        PosColumn(text: 'Tanggal:', width: 4),
        PosColumn(
          text: transaksi.tanggal ?? DateTime.now().toString().substring(0, 16),
          width: 8,
        ),
      ]);

      bytes += generator.row([
        PosColumn(text: 'No. Transaksi:', width: 4),
        PosColumn(text: '#${transaksi.id}', width: 8),
      ]);

      bytes += generator.row([
        PosColumn(text: 'Jenis:', width: 4),
        PosColumn(
          text:
              transaksi.jenis == 'penjualan_produk'
                  ? 'Penjualan Produk'
                  : 'Pesanan Layanan',
          width: 8,
        ),
      ]);

      bytes += generator.hr();

      // Item details
      bytes += generator.text(
        'Detail Transaksi:',
        styles: const PosStyles(bold: true),
      );

      bytes += generator.row([
        PosColumn(text: itemName, width: 6),
        PosColumn(
          text: '${transaksi.jumlah}x',
          width: 2,
          styles: const PosStyles(align: PosAlign.right),
        ),
        PosColumn(
          text: 'Rp ${transaksi.total.toStringAsFixed(0)}',
          width: 4,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      bytes += generator.hr();

      // Total
      bytes += generator.row([
        PosColumn(
          text: 'Total:',
          width: 6,
          styles: const PosStyles(bold: true),
        ),
        PosColumn(
          text: 'Rp ${transaksi.total.toStringAsFixed(0)}',
          width: 6,
          styles: const PosStyles(bold: true, align: PosAlign.right),
        ),
      ]);

      bytes += generator.row([
        PosColumn(text: 'Metode Pembayaran:', width: 6),
        PosColumn(
          text:
              transaksi.metodePembayaran[0].toUpperCase() +
              transaksi.metodePembayaran.substring(1),
          width: 6,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]);

      bytes += generator.hr();

      // Footer
      bytes += generator.text(
        pengaturanUsaha?.footerNota ??
            'Terima kasih telah menggunakan layanan kami!',
        styles: const PosStyles(align: PosAlign.center),
      );

      bytes += generator.cut();

      // Connect to printer
      var printerManager = PrinterManager.instance;

      // Connect to printer with timeout
      try {
        // Buat PrinterInput dari PrinterDevice
        // Menggunakan parameter minimal yang diperlukan
        final input = BluetoothPrinterInput(
          name: printer.name ?? 'Unknown',
          address: printer.address!,
        );

        await printerManager
            .connect(type: PrinterType.bluetooth, model: input)
            .timeout(const Duration(seconds: 5));

        // Print bytes
        await printerManager.send(
          type: PrinterType.bluetooth,
          bytes: Uint8List.fromList(bytes),
        );

        // Disconnect
        await printerManager.disconnect(type: PrinterType.bluetooth);
      } catch (e) {
        throw Exception('Gagal mencetak: $e');
      }
    } catch (e) {
      print('Error in printToPrinter: $e');
      rethrow;
    }
  }

  static Future<void> printWithDialog({
    required Transaksi transaksi,
    required PengaturanUsaha? pengaturanUsaha,
    required String itemName,
  }) async {
    // Generate PDF
    final pdfFile = await PdfService.generateStrukPdf(
      transaksi: transaksi,
      pengaturanUsaha: pengaturanUsaha,
      itemName: itemName,
    );

    // Print with dialog
    await Printing.layoutPdf(
      onLayout: (_) async => pdfFile.readAsBytes(),
      name: 'Struk Transaksi #${transaksi.id}',
      format: PdfPageFormat(80 * PdfPageFormat.mm, 210 * PdfPageFormat.mm),
    );
  }
}
