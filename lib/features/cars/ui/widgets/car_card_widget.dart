import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import '../../data/models/car_model.dart';

class CarCardWidget extends StatelessWidget {
  final CarModel car;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const CarCardWidget({
    super.key,
    required this.car,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final String? formattedImageUrl = car.cleanImageUrl;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.borderGrey, width: 1.w),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadowColor,
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. الجزء العلوي: لوحة السيارة ونوع الموديل ومحوّر التحكم
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car.model,
                      style: TextStyles.Size18
                          .withWeight(FontWeight.bold)
                          .withColor(AppColors.darkBlueBlack),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'موديل ${car.year}',
                      style: TextStyles.Size10.withColor(AppColors.coolGrey),
                    ),
                  ],
                ),

                // تصميم لوحة السيارة الاحترافية
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.darkBlueBlack, width: 1.5.w),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.directions_car,
                          size: 14.sp, color: AppColors.darkBlueBlack),
                      SizedBox(width: 6.w),
                      Text(
                        car.plateNumber.toUpperCase(),
                        style: TextStyles.Size15
                            .withWeight(FontWeight.bold)
                            .withColor(AppColors.darkBlueBlack)
                            .withLetterSpacing(1.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. صورة المركبة بلمسة التدرج
          if (formattedImageUrl != null && formattedImageUrl.isNotEmpty)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(0.r)),
                  child: Image.network(
                    formattedImageUrl,
                    height: 150.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint("CarCardWidget Image Error: $error | URL: $formattedImageUrl");
                      return _buildDefaultCarImage();
                    },
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.darkBlueBlack.withOpacity(0.6),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                if (car.carType != null)
                  Positioned(
                    bottom: 10.h,
                    right: 12.w,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        car.carType!.nameAr.isNotEmpty
                            ? car.carType!.nameAr
                            : car.carType!.name,
                        style: TextStyles.Size10
                            .withWeight(FontWeight.bold)
                            .withColor(AppColors.surfaceWhite),
                      ),
                    ),
                  ),
              ],
            )
          else
            _buildDefaultCarImage(),

          SizedBox(height: 12.h),

          // 3. المواصفات الفنية المباشرة (المسافة، السلندرات، نوع الوقود)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.bgLight,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCarInfoItem(
                    icon: Icons.speed_rounded,
                    title: 'المسافة',
                    value: '${car.mileage} كم',
                  ),
                  _buildVerticalDivider(),
                  _buildCarInfoItem(
                    icon: Icons.local_gas_station_rounded,
                    title: 'الوقود',
                    value: _translateFuelType(car.fuelType),
                  ),
                  _buildVerticalDivider(),
                  _buildCarInfoItem(
                    icon: Icons.tune_rounded,
                    title: 'السلندرات',
                    value: '${car.cylinders} سلندر',
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // 4. الفرع والأزرار الإجرائية
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (car.branch != null)
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 16.sp, color: AppColors.primaryBlue),
                      SizedBox(width: 4.w),
                      Text(
                        car.branch!.nameAr.isNotEmpty
                            ? car.branch!.nameAr
                            : car.branch!.name,
                        style: TextStyles.Size10
                            .withWeight(FontWeight.w600)
                            .withColor(AppColors.darkBlueBlack),
                      ),
                    ],
                  )
                else
                  const SizedBox.shrink(),

                Row(
                  children: [
                    IconButton(
                      onPressed: onEdit,
                      icon: Icon(Icons.edit_outlined,
                          size: 20.sp, color: AppColors.primaryBlue),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.all(6.r),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      onPressed: () => _showDeleteDialog(context),
                      icon: Icon(Icons.delete_outline_rounded,
                          size: 20.sp, color: AppColors.errorColor),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.all(6.r),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultCarImage() {
    return Container(
      height: 120.h,
      width: double.infinity,
      color: AppColors.lightBlueSurface,
      child: Center(
        child: Icon(
          Icons.directions_car_filled_sharp,
          size: 60.sp,
          color: AppColors.primaryBlue.withOpacity(0.4),
        ),
      ),
    );
  }

  Widget _buildCarInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, size: 18.sp, color: AppColors.primaryBlue),
        SizedBox(height: 4.h),
        Text(
          title,
          style: TextStyles.Size10.withColor(AppColors.coolGrey),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyles.Size10
              .withWeight(FontWeight.bold)
              .withColor(AppColors.darkBlueBlack),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 25.h,
      width: 1.w,
      color: AppColors.borderGrey,
    );
  }

  String _translateFuelType(String fuel) {
    switch (fuel.toLowerCase()) {
      case 'petrol':
      case 'gasoline':
        return 'بنزين';
      case 'diesel':
        return 'ديزل';
      case 'hybrid':
        return 'هايبرايد';
      case 'electric':
        return 'كهرباء';
      default:
        return fuel;
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'حذف السيارة',
          style: TextStyles.Size18
              .withWeight(FontWeight.bold)
              .withColor(AppColors.darkBlueBlack),
        ),
        content: Text(
          'هل أنت تأكد من أنك تريد حذف هذه السيارة من قائمة مركباتك؟',
          style: TextStyles.Size15.withColor(AppColors.coolGrey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('إلغاء',
                style: TextStyles.Size15.withColor(AppColors.coolGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.errorColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r)),
            ),
            child: Text('حذف',
                style: TextStyles.Size15.withColor(AppColors.surfaceWhite)),
          ),
        ],
      ),
    );
  }
}