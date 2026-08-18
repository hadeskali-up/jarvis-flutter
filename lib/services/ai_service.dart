import '../models/ai_usage.dart';
import 'api_service.dart';

class AiService {
  final ApiService _api = ApiService();

  Future<AiUsageData> fetchUsage() async {
    final data = await _api.get('/api/ai-usage');
    return AiUsageData.fromJson(data);
  }
}
