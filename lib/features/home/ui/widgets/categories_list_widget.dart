import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import '../../data/models/category_model.dart';

class CategoriesListWidget extends StatelessWidget {
  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final Function(int?) onCategorySelected;

  const CategoriesListWidget({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  IconData _getCategoryIcon(String name) {
    if (name.contains('غسيل') || name.toLowerCase().contains('wash')) {
      return Icons.local_car_wash_rounded;
    } else if (name.contains('صيانة') || name.toLowerCase().contains('maint')) {
      return Icons.build_circle_rounded;
    } else if (name.contains('زيت') || name.toLowerCase().contains('oil')) {
      return Icons.oil_barrel_rounded;
    }
    return Icons.miscellaneous_services_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 14.w),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategoryId == category.id;

          return AnimatedGestureDetector(
            onTap: () => onCategorySelected(category.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 100.w,
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.buttonGradient : null,
                color: isSelected ? null : AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected ? Colors.transparent : AppColors.borderGrey,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected ? AppColors.primaryBlue.withOpacity(0.3) : AppColors.cardShadowColor,
                    blurRadius: isSelected ? 12 : 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.surfaceWhite.withOpacity(0.2) : AppColors.lightBlueSurface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getCategoryIcon(category.nameAr),
                      color: isSelected ? AppColors.surfaceWhite : AppColors.primaryBlue,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    category.nameAr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyles.Size10.withWeight(
                      isSelected ? FontWeight.bold : FontWeight.w600,
                    ).withColor(
                      isSelected ? AppColors.surfaceWhite : AppColors.darkBlueBlack,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class AnimatedGestureDetector extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const AnimatedGestureDetector({super.key, required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}