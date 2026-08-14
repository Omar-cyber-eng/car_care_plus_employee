import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import '../../data/models/service_details_model.dart';

class ServiceInfoSection extends StatelessWidget {
  final ServiceDetailsModel service;

  const ServiceInfoSection({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // عنوان الخدمة والتقييم
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                service.nameAr,
                style: TextStyles.Size15.withWeight(FontWeight.bold).withColor(AppColors.darkBlueBlack),
              ),
            ),
            
          ],
        ),
        SizedBox(height: 12.h),

        // مدة التنفيذ
        Row(
          children: [
            Icon(Icons.access_time_rounded, size: 18.sp, color: AppColors.primaryBlue),
            SizedBox(width: 6.w),
            Text(
             'المدة المتوقعة: ${service.formattedDuration}',
              style: TextStyles.Size15.withColor(Colors.grey[700]!),
            ),
          ],
        ),
        SizedBox(height: 20.h),

        // الوصف
        Text(
          'الوصف',
          style: TextStyles.Size15.withWeight(FontWeight.bold).withColor(AppColors.darkBlueBlack),
        ),
        SizedBox(height: 8.h),
        Text(
          service.description,
          style: TextStyles.Size15.withColor(Colors.grey[600]!).copyWith(height: 1.5),
        ),
        SizedBox(height: 24.h),

        // مميزات الخدمة
       
        
      ],
    );
  }
}