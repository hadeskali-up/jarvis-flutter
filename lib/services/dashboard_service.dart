import '../models/dashboard_data.dart';
import 'api_service.dart';

class DashboardService {
  final ApiService _dashboardApi = const ApiService(
    baseUrl: 'https://dashboard.alisuhari.top',
  );
  final ApiService _bridgeApi = const ApiService();

  Future<DashboardSnapshot> fetchSnapshot() async {
    final data = await _dashboardApi.get('/api/snapshot');
    return DashboardSnapshot.fromJson(data);
  }

  Future<ProviderBalancesResponse> fetchProviderBalances() async {
    const readKey = String.fromEnvironment('PROVIDER_READ_KEY');
    if (readKey.isEmpty) {
      throw Exception('Provider balance access is not configured');
    }
    final data = await _bridgeApi.get(
      '/api/provider-balances',
      headers: const {'X-Provider-Read-Key': readKey},
    );
    return ProviderBalancesResponse.fromJson(data);
  }
}
