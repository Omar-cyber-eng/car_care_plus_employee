import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import 'package:car_care_plus/core/widgets/gradient_header.dart';
import '../../data/models/company_model.dart';
import '../../data/repos/company_repo.dart';
import '../../logic/company_cubit.dart';
import '../../logic/company_state.dart';
import '../widgets/company_status_badge.dart';

class CompanyProfileView extends StatelessWidget {
  const CompanyProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CompanyCubit(CompanyRepo(ApiService()))..getMyCompany(),
      child: const _CompanyProfileBody(),
    );
  }
}

class _CompanyProfileBody extends StatelessWidget {
  const _CompanyProfileBody();

  // نافذة تعديل بيانات الشركة (لا تُرسل status ولا is_active)
  void _showEditCompanyBottomSheet(
    BuildContext context,
    CompanyCubit cubit,
    CompanyModel company,
  ) {
    final nameController = TextEditingController(text: company.name);
    final nameArController = TextEditingController(text: company.nameAr);
    final commercialRegController =
        TextEditingController(text: company.commercialReg);
    final taxNumberController = TextEditingController(text: company.taxNumber);
    final addressController = TextEditingController(text: company.address);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تعديل بيانات الشركة',
                      style: TextStyles.Size18
                          .withColor(AppColors.darkBlueBlack)
                          .withWeight(FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(bottomSheetContext),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SheetField(
                  controller: nameController,
                  label: 'اسم الشركة (بالإنجليزية)',
                  icon: Icons.business_outlined,
                ),
                const SizedBox(height: 14),
                _SheetField(
                  controller: nameArController,
                  label: 'اسم الشركة (بالعربية)',
                  icon: Icons.business_outlined,
                ),
                const SizedBox(height: 14),
                _SheetField(
                  controller: commercialRegController,
                  label: 'رقم السجل التجاري',
                  icon: Icons.assignment_outlined,
                ),
                const SizedBox(height: 14),
                _SheetField(
                  controller: taxNumberController,
                  label: 'الرقم الضريبي',
                  icon: Icons.receipt_long_outlined,
                ),
                const SizedBox(height: 14),
                _SheetField(
                  controller: addressController,
                  label: 'عنوان الشركة',
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(bottomSheetContext);
                      cubit.updateCompany(
                        companyId: company.id,
                        companyData: {
                          'name': nameController.text.trim(),
                          'name_ar': nameArController.text.trim(),
                          'commercial_reg': commercialRegController.text.trim(),
                          'tax_number': taxNumberController.text.trim(),
                          'address': addressController.text.trim(),
                        },
                      );
                    },
                    child: Text(
                      'حفظ التعديلات',
                      style: TextStyles.Size15.withColor(AppColors.surfaceWhite),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueSurface,
      body: BlocConsumer<CompanyCubit, CompanyState>(
        listener: (context, state) {
          if (state is UpdateCompanySuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تحديث بيانات الشركة بنجاح'),
                backgroundColor: AppColors.primaryBlue,
              ),
            );
          } else if (state is CompanyErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          final cubit = context.read<CompanyCubit>();

          if (state is CompanyLoadingState && cubit.company == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

          if (cubit.company == null) {
            return _ErrorRetry(
              message: state is CompanyErrorState
                  ? state.message
                  : 'تعذّر تحميل بيانات الشركة',
              onRetry: () => cubit.getMyCompany(),
            );
          }

          final company = cubit.company!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GradientHeader(
                padding: const EdgeInsets.fromLTRB(16, 8, 24, 32),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: AppColors.surfaceWhite,
                          ),
                        ),
                        IconButton(
                          onPressed: () => _showEditCompanyBottomSheet(
                            context,
                            cubit,
                            company,
                          ),
                          icon: const Icon(
                            Icons.edit,
                            color: AppColors.surfaceWhite,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceWhite.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: const Icon(
                        Icons.business_rounded,
                        color: AppColors.surfaceWhite,
                        size: 44,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      company.nameAr.isNotEmpty ? company.nameAr : company.name,
                      style: TextStyles.Size24
                          .withColor(AppColors.surfaceWhite)
                          .withWeight(FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    CompanyStatusBadge(status: company.status),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'معلومات الشركة',
                            style: TextStyles.Size18
                                .withColor(AppColors.darkBlueBlack)
                                .withWeight(FontWeight.bold),
                          ),
                          TextButton.icon(
                            onPressed: () => _showEditCompanyBottomSheet(
                              context,
                              cubit,
                              company,
                            ),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: const Text('تعديل'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _InfoTile(
                        icon: Icons.business_outlined,
                        label: 'اسم الشركة (بالإنجليزية)',
                        value: company.name.isNotEmpty
                            ? company.name
                            : 'غير متوفر',
                      ),
                      const SizedBox(height: 12),
                      _InfoTile(
                        icon: Icons.assignment_outlined,
                        label: 'رقم السجل التجاري',
                        value: company.commercialReg.isNotEmpty
                            ? company.commercialReg
                            : 'غير متوفر',
                      ),
                      const SizedBox(height: 12),
                      _InfoTile(
                        icon: Icons.receipt_long_outlined,
                        label: 'الرقم الضريبي',
                        value: company.taxNumber.isNotEmpty
                            ? company.taxNumber
                            : 'غير متوفر',
                      ),
                      const SizedBox(height: 12),
                      _InfoTile(
                        icon: Icons.location_on_outlined,
                        label: 'العنوان',
                        value: company.address.isNotEmpty
                            ? company.address
                            : 'غير متوفر',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const _SheetField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: AppColors.errorColor,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyles.Size15.withColor(AppColors.darkBlueBlack),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
              ),
              child: Text(
                'إعادة المحاولة',
                style: TextStyles.Size15.withColor(AppColors.surfaceWhite),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlueBlack.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.lightBlueSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyles.Size10.withColor(AppColors.coolGrey),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyles.Size15
                      .withColor(AppColors.darkBlueBlack)
                      .withWeight(FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
