import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';

class EmptyCarsWidget extends StatelessWidget {
  const EmptyCarsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 80.h),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: AppColors.lightBlueSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.directions_car_filled_outlined,
                size: 70.sp,
                color: AppColors.primaryBlue,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'لا يوجد لديك سيارات مضافة',
              style: TextStyles.Size18
                  .withWeight(FontWeight.bold)
                  .withColor(AppColors.darkBlueBlack),
            ),
            SizedBox(height: 8.h),
            Text(
              'قم بإضافة مركبتك الأولى الآن لتتمكن من حجز الخدمات والصيانة بسهولة',
              textAlign: TextAlign.center,
              style: TextStyles.Size15
                  .withColor(AppColors.coolGrey)
                  .withHeight(1.5),
            ),
          ],
        ),
      ),
    );
  }
}