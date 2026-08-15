import 'package:flutter/material.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import 'package:car_care_plus/features/orders/data/order_model.dart';

// نموذج تفاصيل الخدمة الميدانية (صيانة/طريق/سحب).
// ⚠️ وضع تجريبي: الحفظ يعرض رسالة فقط ولا يُرسل للباك بعد
// (سيرتبط لاحقاً بـ POST /bookings/{id}/maintenance-detail | road-detail | towing-detail).
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

  // حقول مشتركة/خاصة حسب النوع.
  final _notesController = TextEditingController();
  final _problemController = TextEditingController();
  final _diagnosisController = TextEditingController();
  final _destinationController = TextEditingController();

  // أحجام السيارة (لطلبات الطريق/السحب).
  static const _carSizes = ['sedan', 'suv', 'hatchback', 'pickup'];
  String? _carSize;

  @override
  void dispose() {
    _notesController.dispose();
    _problemController.dispose();
    _diagnosisController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حفظ التفاصيل (وضع تجريبي — سيُرسل للباك لاحقاً)'),
        backgroundColor: AppColors.successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
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
      body: Form(
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
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.surfaceWhite,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.save_outlined),
                label: Text(
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
          _carSizeDropdown(),
          const SizedBox(height: 16),
          _field(
            controller: _diagnosisController,
            label: 'التشخيص',
            hint: 'تشخيص الفنّي للمشكلة...',
            maxLines: 4,
            required: false,
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
            required: false,
          ),
        ];
      case OrderServiceKind.wash:
        // الغسيل لا يملك تفاصيل ميدانية — لا يُفترض الوصول لهذه الشاشة.
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
    bool required = true,
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
          validator: required
              ? (v) => (v == null || v.trim().isEmpty) ? 'هذا الحقل مطلوب' : null
              : null,
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
