import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/scanner_provider.dart';

class QRScannerPage extends ConsumerStatefulWidget {
  const QRScannerPage({super.key});

  @override
  ConsumerState<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends ConsumerState<QRScannerPage> {
  MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool isScanned = false;
  bool isProcessing = false;

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (isScanned || isProcessing) return;
    
    if (barcodes.barcodes.isNotEmpty) {
      final barcode = barcodes.barcodes.first;
      final String? code = barcode.rawValue;

      if (code != null) {
        setState(() {
          isScanned = true;
        });

        // Process the barcode with backend
        _processScan(code, barcode.format);
      }
    }
  }

  Future<void> _processScan(String code, BarcodeFormat format) async {
    setState(() => isProcessing = true);

    // If QR contains a web link, open it directly in external browser.
    if (_isWebUrl(code)) {
      await _openScannedUrl(code);
      if (!mounted) return;
      setState(() {
        isProcessing = false;
        isScanned = false;
      });
      return;
    }
    
    final scannerNotifier = ref.read(scannerProvider.notifier);
    final result = await scannerNotifier.borrowByQRCode(code);

    if (!mounted) return;

    setState(() => isProcessing = false);

    if (result != null) {
      // Success - show result dialog
      _showSuccessDialog(result);
    } else {
      // Error - show error dialog
      final error = ref.read(scannerProvider).error ?? 'Failed to process scan';
      _showErrorDialog(error);
    }
  }

  bool _isWebUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    if (uri == null) return false;
    return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Future<void> _openScannedUrl(String rawUrl) async {
    final uri = Uri.parse(rawUrl.trim());
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      _showErrorDialog('Unable to open link: $rawUrl');
      return;
    }

    if (mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Link Opened', style: TextStyle(color: Colors.green)),
          content: Text('Opened: $rawUrl'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  isScanned = false;
                });
              },
              child: const Text('Scan Another'),
            ),
          ],
        ),
      );
    }
  }

  void _showSuccessDialog(Map<String, dynamic> result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Book Issued Successfully!', style: TextStyle(color: Colors.green)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Book: ${result['book']?['title'] ?? 'Unknown'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Due Date: ${result['dueDate']?.toString().split(' ')[0] ?? 'N/A'}',
            ),
            const SizedBox(height: 8),
            if (result['borrowingId'] != null)
              Text(
                'Borrowing ID: ${result['borrowingId']}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                isScanned = false;
              });
            },
            child: const Text('Scan Another'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Error', style: TextStyle(color: Colors.red)),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                isScanned = false;
              });
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Book QR/Barcode'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            tooltip: 'Toggle Flash',
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            tooltip: 'Switch Camera',
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: cameraController,
            onDetect: _handleBarcode,
          ),
          
          // Overlay with scanning frame
          CustomPaint(
            painter: ScannerOverlay(),
            child: Container(),
          ),
          
          // Processing indicator
          if (isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black54,
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Processing...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          
          // Instructions
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Position the QR code or barcode within the frame',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildFormatChip('QR Code'),
                      const SizedBox(width: 8),
                      _buildFormatChip('Barcode'),
                      const SizedBox(width: 8),
                      _buildFormatChip('ISBN'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatChip(String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 10),
      ),
      padding: const EdgeInsets.all(4),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

// Custom painter for scanner overlay
class ScannerOverlay extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final scanArea = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: size.width * 0.7,
      height: size.height * 0.4,
    );

    // Draw dark overlay
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()
          ..addRRect(RRect.fromRectAndRadius(scanArea, const Radius.circular(16)))
          ..close(),
      ),
      paint,
    );

    // Draw corner brackets
    final bracketPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    const bracketLength = 30.0;
    const cornerRadius = 16.0;

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(scanArea.left, scanArea.top + bracketLength)
        ..lineTo(scanArea.left, scanArea.top + cornerRadius)
        ..arcToPoint(
          Offset(scanArea.left + cornerRadius, scanArea.top),
          radius: const Radius.circular(cornerRadius),
        )
        ..lineTo(scanArea.left + bracketLength, scanArea.top),
      bracketPaint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(scanArea.right - bracketLength, scanArea.top)
        ..lineTo(scanArea.right - cornerRadius, scanArea.top)
        ..arcToPoint(
          Offset(scanArea.right, scanArea.top + cornerRadius),
          radius: const Radius.circular(cornerRadius),
        )
        ..lineTo(scanArea.right, scanArea.top + bracketLength),
      bracketPaint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(scanArea.left, scanArea.bottom - bracketLength)
        ..lineTo(scanArea.left, scanArea.bottom - cornerRadius)
        ..arcToPoint(
          Offset(scanArea.left + cornerRadius, scanArea.bottom),
          radius: const Radius.circular(cornerRadius),
        )
        ..lineTo(scanArea.left + bracketLength, scanArea.bottom),
      bracketPaint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(scanArea.right - bracketLength, scanArea.bottom)
        ..lineTo(scanArea.right - cornerRadius, scanArea.bottom)
        ..arcToPoint(
          Offset(scanArea.right, scanArea.bottom - cornerRadius),
          radius: const Radius.circular(cornerRadius),
        )
        ..lineTo(scanArea.right, scanArea.bottom - bracketLength),
      bracketPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
