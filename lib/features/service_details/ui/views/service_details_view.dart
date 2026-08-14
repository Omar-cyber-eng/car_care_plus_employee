import 'package:car_care_plus/features/service_details/data/repos/service_details_repo.dart';
import 'package:car_care_plus/features/service_details/logic/service_details_cubit.dart';
import 'package:car_care_plus/features/service_details/logic/service_details_state.dart';
import 'package:car_care_plus/features/sub_services/data/repo/sub_service_repo.dart';
import 'package:car_care_plus/features/sub_services/logic/sub_service_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import '../widgets/booking_bottom_bar.dart';
import '../widgets/service_info_section.dart';




class ServiceDetailsView extends StatelessWidget {
  final int serviceId;

  const ServiceDetailsView({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // 1. Cubit تفاصيل الخدمة الرئيسية
        BlocProvider(
          create: (context) =>
              ServiceDetailsCubit(ServiceDetailsRepo(ApiService()))
                ..getServiceDetails(serviceId),
        ),
        // 2. Cubit الخدمات الفرعية المخصص لمنطق وطلب بيانات الـ Sub-Services
        BlocProvider(
          create: (context) =>
              SubServiceCubit(SubServiceRepo(ApiService()))
                ..fetchSubServices(serviceId),
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: BlocBuilder<ServiceDetailsCubit, ServiceDetailsState>(
          builder: (context, state) {
            if (state is ServiceDetailsLoadingState) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryBlue),
              );
            }

            if (state is ServiceDetailsErrorState) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: AppColors.errorColor,
                      size: 48.sp,
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      state.message,
                      style: TextStyles.Size15.withColor(
                        AppColors.darkBlueBlack,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        context
                            .read<ServiceDetailsCubit>()
                            .getServiceDetails(serviceId);
                        context
                            .read<SubServiceCubit>()
                            .fetchSubServices(serviceId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                      ),
                      child: Text(
                        'إعادة المحاولة',
                        style: TextStyles.Size15.withColor(
                          AppColors.surfaceWhite,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is ServiceDetailsSuccessState) {
              final service = state.serviceDetails;

              return Column(
                children: [
                  Expanded(
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        // صورة الخدمة مع زر العودة
                        SliverAppBar(
                          expandedHeight: 250.h,
                          pinned: true,
                          backgroundColor: AppColors.surfaceWhite,
                          leading: Padding(
                            padding: EdgeInsets.all(8.r),
                            child: CircleAvatar(
                              backgroundColor: Colors.black26,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                          ),
                          flexibleSpace: FlexibleSpaceBar(
                            background: Image.asset(
                              'assets/images/logo.png',
                              height: 70.h,
                              width: 200.w,
                            ),
                          ),
                        ),

                        // 1. محتوى تفاصيل الخدمة الرئيسية
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(20.r),
                            child: ServiceInfoSection(service: service),
                          ),
                        ),

                        // 2. قسم الخدمات الفرعية (Sub Services)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'الخدمات الفرعية والإضافات',
                                  style: TextStyles.Size18
                                      .withWeight(FontWeight.bold)
                                      .withColor(AppColors.darkBlueBlack),
                                ),
                                SizedBox(height: 12.h),
                                _buildSubServicesSection(),
                                SizedBox(height: 20.h),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // شريط الحجز السفلي
                  BlocBuilder<SubServiceCubit, SubServiceState>(
                    builder: (context, subState) {
                      final subCubit = context.read<SubServiceCubit>();
                      
                      // حساب إجمالي سعر الخدمات الفرعية المحددة إضافةً للسعر الأساسي
                      double extraPrice = subCubit.selectedSubServices
                          .fold(0.0, (sum, item) => sum + item.price);
                      
                      double finalPrice = service.basePrice + extraPrice;

                      return BookingBottomBar(
                        price: finalPrice,
                        discountPrice: service.vipExtraPrice,
                        onBookingPressed: () {
                          // الانتقال للخطوة التالية مع إرسال قائمة الخدمات الفرعية المحددة
                          final selectedSubs = subCubit.selectedSubServices;
                          // navigateToBooking(service, selectedSubs);
                        },
                      );
                    },
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  /// ويدجيت عرض قائمة الخدمات الفرعية
  Widget _buildSubServicesSection() {
    return BlocBuilder<SubServiceCubit, SubServiceState>(
      builder: (context, state) {
        final cubit = context.read<SubServiceCubit>();

        if (state is SubServiceLoadingState) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            ),
          );
        }

        if (state is SubServiceErrorState) {
          return Text(
            'تعذر تحميل الخدمات الفرعية',
            style: TextStyles.Size15.withColor(AppColors.errorColor),
          );
        }

        if (cubit.selectedSubServices.isEmpty && state is SubServiceSuccessState && state.subServices.isEmpty) {
          return Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'لا توجد خدمات فرعية متاحة لهذه الخدمة حالياً.',
              style: TextStyles.Size15.withColor(Colors.grey),
            ),
          );
        }

        // جلب قائمة الخدمات الفرعية الحالية
        final subServicesList = state is SubServiceSuccessState ? state.subServices : [];

        if (subServicesList.isEmpty) {
          return const SizedBox.shrink();
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: subServicesList.length,
          separatorBuilder: (context, index) => SizedBox(height: 10.h),
          itemBuilder: (context, index) {
            final subService = subServicesList[index];
            final isSelected = cubit.selectedSubServices.contains(subService);

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: CheckboxListTile(
                activeColor: AppColors.primaryBlue,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                title: Text(
                  subService.nameAr.isNotEmpty ? subService.nameAr : subService.name,
                  style: TextStyles.Size15.withWeight(FontWeight.bold)
                      .withColor(AppColors.darkBlueBlack),
                ),
                subtitle: Text(
                  subService.description,
                  style: TextStyles.Size10.withColor(Colors.grey),
                ),
                secondary: Text(
                  '+${subService.price} د.أ',
                  style: TextStyles.Size15.withWeight(FontWeight.bold)
                      .withColor(AppColors.primaryBlue),
                ),
                value: isSelected,
                onChanged: (bool? value) {
                  cubit.toggleSubServiceSelection(subService);
                },
              ),
            );
          },
        );
      },
    );
  }
}