import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import 'package:car_care_plus/core/routing/app_routes.dart';
import 'package:flutter/material.dart';

// شاشة "طلبك قيد المراجعة" — تظهر بعد تقديم طلب تسجيل الورشة.
// تسجيل الورشة معلّق (بلا توكن) حتى يعتمده الأدمن، ثم يصبح الحساب نشطاً ويمكن الدخول.
class PendingApprovalPage extends StatelessWidget {
  const PendingApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.mainAppGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceWhite.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_top_rounded,
                    color: AppColors.surfaceWhite,
                    size: 60,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'طلبك قيد المراجعة',
                  style: TextStyles.Size24
                      .withColor(AppColors.surfaceWhite)
                      .withWeight(FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                Text(
                  'تم استلام طلب تسجيل ورشتك بنجاح. '
                  'سيقوم فريق الإدارة بمراجعته واعتماده قريباً، '
                  'وستتمكن من تسجيل الدخول فور تفعيل الحساب.',
                  style: TextStyles.Size15.withColor(
                    AppColors.surfaceWhite.withOpacity(0.85),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      Routes.login,
                      (route) => false,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'العودة لتسجيل الدخول',
                      style: TextStyles.Size18
                          .withColor(AppColors.primaryBlue)
                          .withWeight(FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
