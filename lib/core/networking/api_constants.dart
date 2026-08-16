class ApiConstants {
  // Base URL الخاص بالسيرفر المحلي عبر XAMPP
  static const String baseUrl = 'http://10.0.2.2:8000/api/';

  // Auth Endpoints
  static const String login = 'login';
  static const String register = 'register';

  // Operations Endpoints (تحديث الصيغ لتطابق لارافيل)
  static const String category = 'categories';     // تعديل من category إلى categories
  static const String service = 'services'; 
  static String servicesByCategory(int categoryId) => 'categories/$categoryId/services';
  static String subServicesByService(int serviceId) => 'services/$serviceId/sub-services';
  static const String carTypes = 'car-types';
  static const String carBrands = 'car-brands';
  static const String package = 'packages';
  static const String userPackage = 'user-packages';
  static const String points = 'points';
  static const String profile = 'profile';
  static const String branche = 'branches';

  // Company Endpoints
  static const String myCompany = 'companies/my'; // شركة المستخدم الحالي
  static const String company = 'companies/';      // تعديل: companies/{id}

  // Orders (Bookings) Endpoints — تطبيق الورشة/الموظف
  static const String bookings = 'bookings';                         // GET قائمة (مُصفّاة تلقائياً + مُرقّمة)
  static String bookingDetails(int id) => 'bookings/$id';           // GET تفاصيل طلب
  static String startBooking(int id) => 'bookings/$id/start';       // POST assigned → in_progress
  static String completeBooking(int id) => 'bookings/$id/complete'; // POST in_progress → completed
  static String confirmCash(int paymentId) =>
      'payments/$paymentId/confirm-cash';                            // POST تأكيد نقد (بمعرّف الدفعة)

  // تفاصيل ميدانية للميكانيكي — GET (قد يعيد null) + POST (upsert) على نفس المسار
  static String maintenanceDetail(int orderId) =>
      'bookings/$orderId/maintenance-detail';
  static String roadDetail(int orderId) => 'bookings/$orderId/road-detail';
  static String towingDetail(int orderId) => 'bookings/$orderId/towing-detail';

  // كتالوج المواد (لاختيار material_id في قطع الغيار)
  static const String materials = 'materials';

  // قطع الغيار (الميكانيكي: إنشاء + عرض؛ الاعتماد على لوحة العميل)
  static const String sparePartRequests = 'spare-part-requests';

  // تقارير الموظف (غسّال+ميكانيكي إنشاء، +الورشة عرض)
  static const String employeeReports = 'employee-reports';

  // التقييمات (عرض فقط للموظف/الورشة)
  static const String ratings = 'ratings';

  // الورشة (دور workshop): ملف ورشتي + تعديلها + سجل صيانة سيارة
  static const String myWorkshop = 'workshops/my';
  static String workshop(int id) => 'workshops/$id';
  static String workshopCarHistory(int carId) =>
      'workshops/cars/$carId/history';

  // سجلّات GPS (الموظف: إرسال فقط أثناء التنفيذ — GET يرجع 403 فلا نقرأها)
  static const String gpsLogs = 'gps-logs';

  // المشاكل المقترحة (ميكانيكي) — لقائمة problem_type_id في road-detail
  static const String suggestedProblems = 'suggested-problems';

  // سجل حالة الطلب (غسّال/ميكانيكي، لا الورشة)
  static String statusHistory(int orderId) => 'bookings/$orderId/status-history';
  // Cars Endpoints
static const String userCars = 'cars/indexClient'; // جلب سيارات المستخدم
static const String createCar = 'cars';             // إنشاء/إضافة سيارة جديدة (POST)
static const String showCar = 'cars/show/';        // عرض تفاصيل سيارة
static const String updateCar = 'cars/update/';    // تعديل بيانات سيارة
static const String deleteCar = 'cars/delete/';    // حذف سيارة
}