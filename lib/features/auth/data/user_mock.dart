import 'package:car_care_plus/features/auth/data/user_model.dart';

// مستخدم وهمي للمرحلة الأولى (تُستبدل ببيانات السيرفر لاحقاً)
UserModel get mockCurrentUser => UserModel(
      id: 1,
      name: 'محمد الأحمد',
      email: 'mohammed.ahmad@example.com',
      phone: '0999123456',
      imageUrl: null,
      isActive: true,
      role: 'customer',
    );
