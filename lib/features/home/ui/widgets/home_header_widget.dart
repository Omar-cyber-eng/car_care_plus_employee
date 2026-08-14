import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';

class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      decoration: BoxDecoration(
        gradient: AppColors.mainAppGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28.r),
          bottomRight: Radius.circular(28.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // شريط الترحيب والبروفايل المصغر
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'أهلاً بك 👋',
                    style: TextStyles.Size15.withColor(AppColors.cyanAccent),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'اختر خدمة سيارتك',
                    style: TextStyles.Size24.withWeight(FontWeight.bold).withColor(AppColors.surfaceWhite),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cyanAccent, width: 2),
                ),
                child: CircleAvatar(
                  radius: 22.r,
                  backgroundColor: AppColors.royalBlue,
                  child: Icon(Icons.person, color: AppColors.surfaceWhite, size: 24.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // كرت عرض ترويجي (Promo Card)
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              gradient: AppColors.cyanGlowGradient,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyanAccent.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.darkBlueBlack.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          'خصم خاص 20%',
                          style: TextStyles.Size10.withWeight(FontWeight.bold).withColor(AppColors.surfaceWhite),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'عناية كاملة بسيارتك',
                        style: TextStyles.Size18.withWeight(FontWeight.bold).withColor(AppColors.darkBlueBlack),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'احجز باقة الغسيل والتلميع الشامل الآن',
                        style: TextStyles.Size10.withColor(AppColors.darkBlueBlack.withOpacity(0.8)),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.directions_car_filled_rounded,
                  size: 60.sp,
                  color: AppColors.darkBlueBlack.withOpacity(0.85),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}