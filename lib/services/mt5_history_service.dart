import '../models/mt5_history.dart';
import 'api_service.dart';

class MT5HistoryService {
  final ApiService _api = const ApiService();

  Future<MT5HistoryResponse> fetchHistory({int limit = 50}) async {
    final data = await _api.get('/api/mt5-history?limit=$limit');
    return MT5HistoryResponse.fromJson(data);
  }
}
