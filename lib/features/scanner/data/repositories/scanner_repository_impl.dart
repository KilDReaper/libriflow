import '../../domain/repositories/scanner_repository.dart';
import '../datasources/scanner_remote_datasource.dart';

class ScannerRepositoryImpl implements ScannerRepository {
  final ScannerRemoteDataSource remoteDataSource;

  ScannerRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, dynamic>> borrowByQRCode(String qrCode) async {
    return await remoteDataSource.borrowByQRCode(qrCode);
  }
}
