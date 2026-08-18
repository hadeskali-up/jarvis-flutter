import '../models/crypto_position.dart';
import 'api_service.dart';

class CryptoService {
  final ApiService _api = ApiService();

  Future<CryptoPositionsResponse> fetchPositions() async {
    final data = await _api.get('/api/crypto-positions');
    return CryptoPositionsResponse.fromJson(data);
  }
}
