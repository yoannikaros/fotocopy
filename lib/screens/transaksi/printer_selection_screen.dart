import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'package:fotocopy/models/transaksi.dart';
import 'package:fotocopy/models/pengaturan_usaha.dart';
import 'package:fotocopy/services/print_service.dart';
import 'dart:typed_data';

class PrinterSelectionScreen extends StatefulWidget {
  final Transaksi transaksi;
  final PengaturanUsaha? pengaturanUsaha;
  final String itemName;

  const PrinterSelectionScreen({
    Key? key,
    required this.transaksi,
    required this.pengaturanUsaha,
    required this.itemName,
  }) : super(key: key);

  @override
  State<PrinterSelectionScreen> createState() => _PrinterSelectionScreenState();
}

class _PrinterSelectionScreenState extends State<PrinterSelectionScreen> {
  List<PrinterDevice> _devices = [];
  bool _isLoading = true;
  bool _isPrinting = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _scanDevices();
  }

  Future<void> _scanDevices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final devices = await PrintService.getBluetoothDevices();
      setState(() {
        _devices = devices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _printToDevice(PrinterDevice printer) async {
    setState(() {
      _isPrinting = true;
    });

    try {
      await PrintService.printToPrinter(
        printer: printer,
        transaksi: widget.transaksi,
        pengaturanUsaha: widget.pengaturanUsaha,
        itemName: widget.itemName,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Struk berhasil dicetak'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mencetak: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isPrinting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Printer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _scanDevices,
            tooltip: 'Scan Ulang',
          ),
        ],
      ),
      body: _isPrinting
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Mencetak struk...'),
          ],
        ),
      )
          : _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Error: $_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _scanDevices,
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      )
          : _devices.isEmpty
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.print_disabled,
                color: Colors.grey,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Tidak ada printer yang ditemukan',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Pastikan printer Bluetooth Anda menyala dan dalam jangkauan',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _scanDevices,
                child: const Text('Scan Ulang'),
              ),
            ],
          ),
        ),
      )
          : ListView.builder(
        itemCount: _devices.length,
        itemBuilder: (context, index) {
          final device = _devices[index];
          return ListTile(
            leading: const Icon(Icons.print),
            title: Text(device.name ?? 'Printer Tidak Dikenal'),
            subtitle: Text(device.address ?? ''),
            onTap: () => _printToDevice(device),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: () async {
            try {
              await PrintService.printWithDialog(
                transaksi: widget.transaksi,
                pengaturanUsaha: widget.pengaturanUsaha,
                itemName: widget.itemName,
              );
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Gagal mencetak: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: const Text('Cetak ke Printer Sistem'),
        ),
      ),
    );
  }
}
