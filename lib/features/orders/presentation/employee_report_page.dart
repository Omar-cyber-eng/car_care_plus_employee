import 'package:flutter/material.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import 'package:car_care_plus/features/orders/data/employee_report_model.dart';
import 'package:car_care_plus/features/orders/data/employee_reports_repo.dart';

// تقارير الموظف لطلب: عرض التقارير الحالية + إنشاء تقرير (للموظفين فقط).
class EmployeeReportPage extends StatefulWidget {
  final int orderId;
  final bool canCreate; // الغسّال/الميكانيكي = true، الورشة = false (عرض فقط)

  const EmployeeReportPage({
    super.key,
    required this.orderId,
    required this.canCreate,
  });

  @override
  State<EmployeeReportPage> createState() => _EmployeeReportPageState();
}

class _EmployeeReportPageState extends State<EmployeeReportPage> {
  final _repo = EmployeeReportsRepo(ApiService());
  final _formKey = GlobalKey<FormState>();

  final _problemController = TextEditingController();
  final _partsController = TextEditingController();
  final _recommendationController = TextEditingController();

  List<EmployeeReport> _reports = [];
  bool _loading = true;
  bool _saving = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _problemController.dispose();
    _partsController.dispose();
    _recommendationController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final reports = await _repo.getReports(orderId: widget.orderId);
      if (mounted) setState(() => _reports = reports);
    } catch (e) {
      if (mounted) {
        setState(() => _loadError = e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final parts = _partsController.text
          .split(RegExp(r'[،,]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      await _repo.createReport(
        orderId: widget.orderId,
        problemDescription: _problemController.text.trim(),
        affectedParts: parts,
        recommendation: _recommendationController.text.trim(),
      );
      if (!mounted) return;
      _snack('تم إرسال التقرير', AppColors.successColor);
      _problemController.clear();
      _partsController.clear();
      _recommendationController.clear();
      await _load();
    } catch (_) {
      if (mounted) _snack('تعذّر إرسال التقرير، حاول مجدداً', AppColors.errorColor);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueSurface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.surfaceWhite,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'تقارير الموظف',
          style: TextStyles.Size18
              .withColor(AppColors.surfaceWhite)
              .withWeight(FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            )
          : _loadError != null
              ? _errorView()
              : ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                  children: [
                    if (_reports.isNotEmpty) ...[
                      Text(
                        'التقارير الحالية',
                        style: TextStyles.Size15
                            .withColor(AppColors.darkBlueBlack)
                            .withWeight(FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ..._reports.map(_reportCard),
                      const SizedBox(height: 24),
                    ] else
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Text(
                          'لا توجد تقارير لهذا الطلب بعد.',
                          style: TextStyles.Size15.withColor(AppColors.coolGrey),
                        ),
                      ),
                    if (widget.canCreate) _createForm(),
                  ],
                ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _loadError ?? 'خطأ',
            style: TextStyles.Size15.withColor(AppColors.errorColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _load, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }

  Widget _reportCard(EmployeeReport r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            r.problemDescription,
            style: TextStyles.Size15
                .withColor(AppColors.darkBlueBlack)
                .withWeight(FontWeight.w600),
          ),
          if (r.affectedParts.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'الأجزاء: ${r.affectedParts.join('، ')}',
              style: TextStyles.Size10.withColor(AppColors.coolGrey),
            ),
          ],
          if (r.recommendation.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'التوصية: ${r.recommendation}',
              style: TextStyles.Size10.withColor(AppColors.coolGrey),
            ),
          ],
          if (r.employeeName.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'بواسطة: ${r.employeeName}',
              style: TextStyles.Size10.withColor(AppColors.primaryBlue),
            ),
          ],
        ],
      ),
    );
  }

  Widget _createForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تقرير جديد',
            style: TextStyles.Size15
                .withColor(AppColors.darkBlueBlack)
                .withWeight(FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _label('وصف المشكلة'),
          TextFormField(
            controller: _problemController,
            maxLines: 4,
            decoration: _fieldDecoration(hint: 'صف المشكلة التي عاينتها...'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'وصف المشكلة مطلوب' : null,
          ),
          const SizedBox(height: 16),
          _label('الأجزاء المتضررة (افصل بفاصلة)'),
          TextFormField(
            controller: _partsController,
            decoration: _fieldDecoration(hint: 'مثال: المكابح، البطارية'),
          ),
          const SizedBox(height: 16),
          _label('التوصية (اختياري)'),
          TextFormField(
            controller: _recommendationController,
            maxLines: 3,
            decoration: _fieldDecoration(hint: 'توصيتك للإجراء التالي...'),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.surfaceWhite,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: _saving
                  ? const SizedBox.shrink()
                  : const Icon(Icons.description_outlined),
              label: _saving
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.surfaceWhite,
                      ),
                    )
                  : Text(
                      'إرسال التقرير',
                      style: TextStyles.Size18
                          .withColor(AppColors.surfaceWhite)
                          .withWeight(FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: TextStyles.Size15
              .withColor(AppColors.darkBlueBlack)
              .withWeight(FontWeight.w600),
        ),
      );

  InputDecoration _fieldDecoration({String? hint}) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.surfaceWhite,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      );
}
