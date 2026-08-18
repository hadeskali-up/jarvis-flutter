import '../models/forex_position.dart';
import 'api_service.dart';

class ForexService {
  final ApiService _api = ApiService();

  Future<MT5PositionsResponse> fetchMT5Positions() async {
    final data = await _api.get('/mt5/positions');
    return MT5PositionsResponse.fromJson(data);
  }
}
