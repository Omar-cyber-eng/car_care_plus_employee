import 'package:car_care_plus/core/networking/api_constants.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import 'package:car_care_plus/features/notifications/data/notification_model.dart';

// الإشعارات داخل التطبيق (Scoping تلقائي — كل مستخدم يرى إشعاراته).
class NotificationsRepo {
  final ApiService _apiService;

  NotificationsRepo(this._apiService);

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _apiService.get(endpoint: ApiConstants.notifications);
    final data = response.data['data'];
    final List list = data is List
        ? data
        : (data is Map ? (data['data'] as List? ?? const []) : const []);
    return list
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final response =
        await _apiService.get(endpoint: ApiConstants.notificationsUnreadCount);
    final data = response.data['data'] ?? response.data;
    final count = (data is Map ? data['unread_count'] : null) ?? 0;
    return count is int ? count : int.tryParse(count.toString()) ?? 0;
  }

  Future<void> markRead(int id) async {
    await _apiService.post(endpoint: ApiConstants.notificationRead(id));
  }

  Future<void> markAllRead() async {
    await _apiService.post(endpoint: ApiConstants.notificationsReadAll);
  }
}
