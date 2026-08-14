import 'package:car_care_plus/features/service_details/ui/views/service_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import '../../data/models/service_model.dart';

class ServicesListWidget extends StatelessWidget {
  final List<ServiceModel> services;

  const ServicesListWidget({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.h),
          child: Column(
            children: [
              Icon(Icons.search_off_rounded, size: 50.sp, color: AppColors.coolGrey),
              SizedBox(height: 10.h),
              Text(
                'لا توجد خدمات متاحة حالياً لهذا القسم',
                style: TextStyles.Size15.withColor(AppColors.coolGrey),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.fromLTRB(20.w, 5.h, 20.w, 25.h),
      itemCount: services.length,
      separatorBuilder: (_, __) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final service = services[index];
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.borderGrey.withOpacity(0.6)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20.r),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ServiceDetailsView(serviceId: service.id),
      ),
    );
                  // الانتقال لتفاصيل الخدمة
                },
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // أيقونة الخدمة
                          Container(
                            width: 52.w,
                            height: 52.h,
                            decoration: BoxDecoration(
                              gradient: AppColors.buttonGradient,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Icon(
                              Icons.car_repair_rounded,
                              color: AppColors.surfaceWhite,
                              size: 28.sp,
                            ),
                          ),
                          SizedBox(width: 14.w),

                          // العنوان والوصف
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        service.nameAr,
                                        style: TextStyles.Size18.withWeight(FontWeight.bold).withColor(AppColors.darkBlueBlack),
                                      ),
                                    ),
                                    if (service.isVipAvailable)
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                        decoration: BoxDecoration(
                                          color: AppColors.darkBlueBlack,
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Text(
                                          'VIP ⭐',
                                          style: TextStyles.Size10.withColor(AppColors.cyanAccent).withWeight(FontWeight.bold),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  service.description ?? 'خدمة عالية الجودة ومضمونة مع أفضل الفنيين.',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyles.Size10.withColor(AppColors.coolGrey).withHeight(1.5),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Divider(color: AppColors.borderGrey.withOpacity(0.5), height: 1),
                      SizedBox(height: 12.h),

                      // السعر ومدة الخدمة وزر التفاعل
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.access_time_rounded, size: 16.sp, color: AppColors.primaryBlue),
                              SizedBox(width: 4.w),
                              Text(
                                '${service.durationMinutes} دقيقة',
                                style: TextStyles.Size10.withWeight(FontWeight.w600).withColor(AppColors.darkBlueBlack),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '${service.basePrice.toStringAsFixed(0)} د.أ',
                                style: TextStyles.Size24.withWeight(FontWeight.bold).withColor(AppColors.primaryBlue),
                              ),
                              SizedBox(width: 12.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  gradient: AppColors.buttonGradient,
                                  borderRadius: BorderRadius.circular(12.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryBlue.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'احجز الآن',
                                  style: TextStyles.Size10.withColor(AppColors.surfaceWhite).withWeight(FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}