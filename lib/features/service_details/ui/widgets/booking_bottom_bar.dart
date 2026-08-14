import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';

class BookingBottomBar extends StatelessWidget {
  final double price;
  final double? discountPrice;
  final VoidCallback onBookingPressed;

  const BookingBottomBar({
    super.key,
    required this.price,
    this.discountPrice,
    required this.onBookingPressed,
  });

  @override
  Widget build(BuildContext context) {
    final finalPrice = discountPrice ?? price;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'التكلفة الإجمالية',
                  style: TextStyles.Size10.withColor(Colors.grey[600]!),
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Text(
                      '\$$finalPrice',
                      style: TextStyles.Size15.withWeight(FontWeight.bold).withColor(AppColors.primaryBlue),
                    ),
                    if (discountPrice != null) ...[
                      SizedBox(width: 8.w),
                      Text(
                        '\$$price',
                        style: TextStyles.Size15.withColor(Colors.grey[400]!).copyWith(
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: onBookingPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'حجز الموعد',
                style: TextStyles.Size15.withWeight(FontWeight.bold).withColor(AppColors.surfaceWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }
}