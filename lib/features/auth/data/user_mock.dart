import 'package:car_care_plus/features/auth/data/user_model.dart';

UserModel get mockCurrentUser => UserModel(
  id: 1,
  name: 'أحمد الميكانيكي',
  email: 'ahmed.mechanic@example.com',
  phone: '0999123456',
  imageUrl: null,
  isActive: true,
  role:
      'employee_mechanic', // 'workshop' | 'employee_washer' | 'employee_mechanic'
);
