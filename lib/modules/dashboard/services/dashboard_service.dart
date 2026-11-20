import '../../../core/constants/api_endpoints.dart';
import '../../../core/services/api_service.dart';
import '../../../models/dashboard_summary.dart';

class DashboardService {
  static Future<DashboardSummary?> fetchSummary() async {
    final response = await ApiService.get<DashboardSummary>(
      ApiEndpoints.dashboard,
      fromJsonData: (data) => DashboardSummary.fromJson(data as Map<String, dynamic>),
    );

    if (response.success && response.data != null) {
      return response.data;
    }
    return null;
  }
}
