import 'package:flutter/material.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import 'package:car_care_plus/features/orders/data/order_extras_model.dart';
import 'package:car_care_plus/features/orders/data/order_model.dart';
import 'package:car_care_plus/features/orders/data/orders_repo.dart';

// نموذج تفاصيل الخدمة الميدانية (صيانة/طريق/سحب).
// GET يجلب التفصيل الحالي (قد يعيد null) → prefill، وPOST يعمل upsert على order_id.
class OrderServiceDetailPage extends StatefulWidget {
  final OrderServiceKind kind;
  final int orderId;

  const OrderServiceDetailPage({
    super.key,
    required this.kind,
    required this.orderId,
  });

  @override
  State<OrderServiceDetailPage> createState() => _OrderServiceDetailPageState();
}

class _OrderServiceDetailPageState extends State<OrderServiceDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _repo = OrdersRepo(ApiService());

  final _notesController = TextEditingController();
  final _problemController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _destinationController = TextEditingController();

  static const _carSizes = ['sedan', 'suv', 'hatchback', 'pickup'];
  String? _carSize;

  // أنواع المشاكل (للطريق) من /suggested-problems.
  List<SuggestedProblem> _problems = [];
  int? _problemTypeId;

  bool _loading = true; // جلب التفصيل الحالي
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _problemController.dispose();
    _diagnosisController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await _repo.getServiceDetail(widget.orderId, widget.kind);
      if (data != null) _prefill(data);
    } catch (_) {
      // نعرض نموذجاً فارغاً (قد يكون بلا تفاصيل بعد، أو تعذّر الجلب).
    }
    // أنواع المشاكل للطريق (أفضل جهد — لا تُعطّل النموذج).
    if (widget.kind == OrderServiceKind.road) {
      try {
        _problems = await _repo.getSuggestedProblems();
      } catch (_) {}
    }
    if (mounted) setState(() => _loading = false);
  }

  void _prefill(Map<String, dynamic> d) {
    _carSize = (d['car_type_size'] as String?)?.trim().isNotEmpty == true
        ? d['car_type_size'] as String?
        : null;
    switch (widget.kind) {
      case OrderServiceKind.maintenance:
        _notesController.text = (d['notes'] ?? '').toString();
        break;
      case OrderServiceKind.road:
        _problemController.text = (d['problem_description'] ?? '').toString();
        _diagnosisController.text = (d['ai_diagnosis'] ?? '').toString();
        _problemTypeId = d['problem_type_id'] is int
            ? d['problem_type_id'] as int
            : null;
        break;
      case OrderServiceKind.towing:
        _destinationController.text =
            (d['destination_address'] ?? '').toString();
        _notesController.text = (d['notes'] ?? '').toString();
        break;
      case OrderServiceKind.wash:
        break;
    }
  }

  Map<String, dynamic> _buildFields() {
    final f = <String, dynamic>{};
    String t(TextEditingController c) => c.text.trim();

    switch (widget.kind) {
      case OrderServiceKind.maintenance:
        if (t(_notesController).isNotEmpty) f['notes'] = t(_notesController);
        break;
      case OrderServiceKind.road:
        if (t(_problemController).isNotEmpty) {
          f['problem_description'] = t(_problemController);
        }
        if (_problemTypeId != null) f['problem_type_id'] = _problemTypeId;
        if (_carSize != null) f['car_type_size'] = _carSize;
        if (t(_diagnosisController).isNotEmpty) {
          f['ai_diagnosis'] = t(_diagnosisController);
        }
        break;
      case OrderServiceKind.towing:
        if (t(_destinationController).isNotEmpty) {
          f['destination_address'] = t(_destinationController);
        }
        if (_carSize != null) f['car_type_size'] = _carSize;
        if (t(_notesController).isNotEmpty) f['notes'] = t(_notesController);
        break;
      case OrderServiceKind.wash:
        break;
    }
    return f;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final fields = _buildFields();
    if (fields.isEmpty) {
      _snack('أدخل بياناً واحداً على الأقل', AppColors.errorColor);
      return;
    }

    setState(() => _saving = true);
    try {
      await _repo.saveServiceDetail(widget.orderId, widget.kind, fields);
      if (!mounted) return;
      _snack('تم حفظ التفاصيل بنجاح', AppColors.successColor);
      Navigator.pop(context);
    } catch (_) {
      if (mounted) _snack('تعذّر حفظ التفاصيل، حاول مجدداً', AppColors.errorColor);
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
          'تفاصيل ${widget.kind.label}',
          style: TextStyles.Size18
              .withColor(AppColors.surfaceWhite)
              .withWeight(FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            )
          : Form(
              key: _formKey,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                children: [
                  ..._fieldsForKind(),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
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
                          : const Icon(Icons.save_outlined),
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
                              'حفظ التفاصيل',
                              style: TextStyles.Size18
                                  .withColor(AppColors.surfaceWhite)
                                  .withWeight(FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  List<Widget> _fieldsForKind() {
    switch (widget.kind) {
      case OrderServiceKind.maintenance:
        return [
          _field(
            controller: _notesController,
            label: 'ملاحظات الصيانة',
            hint: 'صف حالة المركبة والأعمال المنفّذة...',
            maxLines: 5,
          ),
        ];
      case OrderServiceKind.road:
        return [
          _field(
            controller: _problemController,
            label: 'وصف المشكلة',
            hint: 'مثال: البطارية فارغة',
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          if (_problems.isNotEmpty) ...[
            _problemTypeDropdown(),
            const SizedBox(height: 16),
          ],
          _carSizeDropdown(),
          const SizedBox(height: 16),
          _field(
            controller: _diagnosisController,
            label: 'التشخيص',
            hint: 'تشخيص الفنّي للمشكلة...',
            maxLines: 4,
          ),
        ];
      case OrderServiceKind.towing:
        return [
          _field(
            controller: _destinationController,
            label: 'وجهة السحب',
            hint: 'العنوان الذي ستُسحب إليه المركبة',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _carSizeDropdown(),
          const SizedBox(height: 16),
          _field(
            controller: _notesController,
            label: 'ملاحظات',
            hint: 'أي ملاحظات إضافية...',
            maxLines: 3,
          ),
        ];
      case OrderServiceKind.wash:
        return [
          Text(
            'لا توجد تفاصيل ميدانية لهذا النوع.',
            style: TextStyles.Size15.withColor(AppColors.coolGrey),
          ),
        ];
    }
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.Size15
              .withColor(AppColors.darkBlueBlack)
              .withWeight(FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.surfaceWhite,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _problemTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع المشكلة',
          style: TextStyles.Size15
              .withColor(AppColors.darkBlueBlack)
              .withWeight(FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: _problemTypeId,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceWhite,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          hint: const Text('اختر نوع المشكلة'),
          items: _problems
              .map((p) => DropdownMenuItem(value: p.id, child: Text(p.name)))
              .toList(),
          onChanged: (v) => setState(() => _problemTypeId = v),
        ),
      ],
    );
  }

  Widget _carSizeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'حجم المركبة',
          style: TextStyles.Size15
              .withColor(AppColors.darkBlueBlack)
              .withWeight(FontWeight.w600),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _carSize,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surfaceWhite,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          hint: const Text('اختر حجم المركبة'),
          items: _carSizes
              .map((s) => DropdownMenuItem(value: s, child: Text(s)))
              .toList(),
          onChanged: (v) => setState(() => _carSize = v),
        ),
      ],
    );
  }
}
