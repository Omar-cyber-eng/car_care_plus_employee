import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import '../../data/repos/home_repo.dart';
import '../../logic/home_cubit.dart';
import '../../logic/home_state.dart';
import '../widgets/categories_list_widget.dart';
import '../widgets/home_header_widget.dart';
import '../widgets/services_list_widget.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(HomeRepo(ApiService()))..getHomeData(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC), // العودة للخلفية الفاتحة
        body: SafeArea(
          top: false,
          child: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final cubit = context.read<HomeCubit>();

              if (state is HomeLoadingState) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primaryBlue),
                );
              }

              if (state is HomeErrorState) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline_rounded, color: AppColors.errorColor, size: 50.sp),
                        SizedBox(height: 12.h),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: TextStyles.Size15.withColor(AppColors.darkBlueBlack),
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () => cubit.getHomeData(),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
                          child: Text('إعادة المحاولة', style: TextStyles.Size15.withColor(AppColors.surfaceWhite)),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => cubit.getHomeData(),
                color: AppColors.primaryBlue,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // 1. الهيدر الثابت أثناء التمرير
                    SliverAppBar(
                      pinned: true, // يضمن ثبات الهيدر عند السكرول
                      floating: false,
                      automaticallyImplyLeading: false,
                      backgroundColor: const Color(0xFFF8FAFC),
                      expandedHeight: 280.h,
                      flexibleSpace: FlexibleSpaceBar(
                        background: const HomeHeaderWidget(),
                        collapseMode: CollapseMode.pin,
                      ),
                    ),

                    // 2. المحتوى القابل للتمرير (الأقسام والعناوين)
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 16.h),

                          // الأقسام والتصنيفات
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'الأقسام الرئيسية',
                                  style: TextStyles.Size18.withWeight(FontWeight.bold).withColor(AppColors.darkBlueBlack),
                                ),
                                if (cubit.selectedCategoryId != null)
                                  GestureDetector(
                                    onTap: () => cubit.filterByCategory(null),
                                    child: Text(
                                      'عرض الكل',
                                      style: TextStyles.Size10.withColor(AppColors.primaryBlue).withWeight(FontWeight.bold),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 12.h),
                          CategoriesListWidget(
                            categories: cubit.categories,
                            selectedCategoryId: cubit.selectedCategoryId,
                            onCategorySelected: (id) => cubit.filterByCategory(id),
                          ),
                          SizedBox(height: 24.h),

                          // عنوان قائمة الخدمات
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Text(
                              'الخدمات المتاحة',
                              style: TextStyles.Size18.withWeight(FontWeight.bold).withColor(AppColors.darkBlueBlack),
                            ),
                          ),
                          SizedBox(height: 8.h),
                        ],
                      ),
                    ),

                    // 3. قائمة الخدمات
                    state is ServicesLoadingState
                        ? const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(30.0),
                              child: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
                            ),
                          )
                        : SliverToBoxAdapter(
                            child: ServicesListWidget(services: cubit.services),
                          ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}