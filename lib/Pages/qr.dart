import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScreen extends StatelessWidget {
  const QrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escáner de QR'),
      ),
      body: MobileScanner( //MobileScanner es el encargado de manejar la cámara y detectar códigos QR
        onDetect: (BarcodeCapture capture) { //onDetect es el callback que se ejecuta cuando el escáner detecta uno o más códigos QR
          final List<Barcode> barcodes = capture.barcodes; //capture.barcodes es una lista de códigos QR detectados
          for (final barcode in barcodes) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Código escaneado: ${barcode.rawValue}')),
            );
          }
        },
      ),
    );
  }
}
