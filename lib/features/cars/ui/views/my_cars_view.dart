import 'package:car_care_plus/core/routing/app_routes.dart';
import 'package:car_care_plus/features/cars/ui/views/add_car_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import '../../data/repos/cars_repo.dart';
import '../../logic/cars_cubit.dart';
import '../../logic/cars_state.dart';
import '../widgets/car_card_widget.dart';
import '../widgets/empty_cars_widget.dart';

class MyCarsView extends StatelessWidget {
  const MyCarsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CarsCubit(CarsRepo(ApiService()))..getUserCars(),
      child: Scaffold(
        backgroundColor: AppColors.bgLight,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.surfaceWhite,
          surfaceTintColor: Colors.transparent,
          title: Text(
            'مركباتي',
            style: TextStyles.Size18.withWeight(
              FontWeight.bold,
            ).withColor(AppColors.darkBlueBlack),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                // فتح شاشة البحث أو الفلترة إن وجدت
              },
              icon: Icon(
                Icons.tune_rounded,
                color: AppColors.darkBlueBlack,
                size: 22.sp,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: BlocConsumer<CarsCubit, CarsState>(
            listener: (context, state) {
              if (state is CarsErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      state.message,
                      style: TextStyles.Size15.withColor(
                        AppColors.surfaceWhite,
                      ),
                    ),
                    backgroundColor: AppColors.errorColor,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                );
              }
            },
            builder: (context, state) {
              final cubit = context.read<CarsCubit>();

              if (state is CarsLoadingState) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue,
                  ),
                );
              }

              if (cubit.cars.isEmpty && state is! CarsLoadingState) {
                return RefreshIndicator(
                  color: AppColors.primaryBlue,
                  onRefresh: () => cubit.getUserCars(),
                  child: const SingleChildScrollView(
                    physics: AlwaysScrollableScrollPhysics(),
                    child: EmptyCarsWidget(),
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primaryBlue,
                onRefresh: () => cubit.getUserCars(),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 16.h,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'السيارات المسجلة',
                                  style: TextStyles.Size18.withWeight(
                                    FontWeight.bold,
                                  ).withColor(AppColors.darkBlueBlack),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'لديك ${cubit.cars.length} مركبة قائمة',
                                  style: TextStyles.Size10.withColor(
                                    AppColors.coolGrey,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.lightBlueSurface,
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.directions_car_rounded,
                                    size: 16.sp,
                                    color: AppColors.primaryBlue,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'نشط',
                                    style: TextStyles.Size10.withWeight(
                                      FontWeight.bold,
                                    ).withColor(AppColors.primaryBlue),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final car = cubit.cars[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 16.h),
                            child: CarCardWidget(
                              car: car,
                              onDelete: () {
                                context.read<CarsCubit>().deleteCar(car.id);
                              },
                              onEdit: () {
                                // الانتقال لشاشة تعديل البيانات وتمرير كائن السيارة الحالية
                                Navigator.pushNamed(
                                  context,
                                  Routes
                                      .editCar, // أصلح اسم الـ Route حسب ملف الإشارات لديك
                                  arguments: car,
                                );
                              },
                            ),
                          );
                        }, childCount: cubit.cars.length),
                      ),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 80.h)),
                  ],
                ),
              );
            },
          ),
        ),
        floatingActionButton: Container(
          decoration: BoxDecoration(
            gradient: AppColors.buttonGradient,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.35),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: FloatingActionButton.extended(
            onPressed: () {
              final carsCubit = context.read<CarsCubit>();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => BlocProvider.value(
                    value: carsCubit,
                    child: const AddCarView(),
                  ),
                ),
              );
            },
            elevation: 0,
            backgroundColor: Colors.transparent,
            icon: Icon(
              Icons.add_rounded,
              color: AppColors.surfaceWhite,
              size: 22.sp,
            ),
            label: Text(
              'إضافة سيارة',
              style: TextStyles.Size15.withWeight(
                FontWeight.bold,
              ).withColor(AppColors.surfaceWhite),
            ),
          ),
        ),
      ),
    );
  }
}
