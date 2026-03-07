import '../repositories/scanner_repository.dart';

class BorrowByQRCodeUseCase {
  final ScannerRepository repository;

  BorrowByQRCodeUseCase({required this.repository});

  Future<Map<String, dynamic>> call(String qrCode) async {
    return await repository.borrowByQRCode(qrCode);
  }
}
