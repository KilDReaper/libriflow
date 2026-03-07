abstract class ScannerRepository {
  Future<Map<String, dynamic>> borrowByQRCode(String qrCode);
}
