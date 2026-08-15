import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import 'package:car_care_plus/features/orders/data/spare_part_models.dart';
import 'package:car_care_plus/features/orders/data/spare_parts_repo.dart';

// قطع الغيار (الميكانيكي): قائمة طلباته لهذا الطلب + إنشاء طلب جديد.
// الإنشاء متاح فقط والطلب مفتوح (غير مكتمل/ملغى).
class SparePartsPage extends StatefulWidget {
  final int orderId;
  final bool orderIsOpen;

  const SparePartsPage({
    super.key,
    required this.orderId,
    required this.orderIsOpen,
  });

  @override
  State<SparePartsPage> createState() => _SparePartsPageState();
}

class _SparePartsPageState extends State<SparePartsPage> {
  final _repo = SparePartsRepo(ApiService());
  final _formKey = GlobalKey<FormState>();

  final _quantityController = TextEditingController(text: '1');
  final _specsController = TextEditingController();
  final _notesController = TextEditingController();
  int? _materialId;

  List<MaterialItem> _materials = [];
  List<SparePartRequest> _requests = [];
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
    _quantityController.dispose();
    _specsController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final materials = await _repo.getMaterials();
      final requests = await _repo.getRequests(orderId: widget.orderId);
      if (!mounted) return;
      setState(() {
        _materials = materials;
        _requests = requests;
      });
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
    if (_materialId == null) {
      _snack('اختر القطعة من الكتالوج', AppColors.errorColor);
      return;
    }
    setState(() => _saving = true);
    try {
      await _repo.createRequest(
        orderId: widget.orderId,
        materialId: _materialId!,
        quantity: int.tryParse(_quantityController.text.trim()) ?? 1,
        specifications: _specsController.text.trim(),
        notes: _notesController.text.trim(),
      );
      if (!mounted) return;
      _snack('تم إرسال طلب القطعة للعميل', AppColors.successColor);
      _specsController.clear();
      _notesController.clear();
      _quantityController.text = '1';
      setState(() => _materialId = null);
      await _load();
    } catch (_) {
      if (mounted) _snack('تعذّر إرسال الطلب، حاول مجدداً', AppColors.errorColor);
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
          'قطع الغيار',
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
                    if (_requests.isNotEmpty) ...[
                      Text(
                        'طلبات هذا الطلب',
                        style: TextStyles.Size15
                            .withColor(AppColors.darkBlueBlack)
                            .withWeight(FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      ..._requests.map(_requestCard),
                      const SizedBox(height: 24),
                    ],
                    if (widget.orderIsOpen)
                      _createForm()
                    else
                      _closedNote(),
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

  Widget _closedNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.coolGrey.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'لا يمكن طلب قطع غيار لطلب مكتمل أو ملغى.',
        style: TextStyles.Size15.withColor(AppColors.coolGrey),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _requestCard(SparePartRequest r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${r.materialName} × ${r.quantity}',
                  style: TextStyles.Size15
                      .withColor(AppColors.darkBlueBlack)
                      .withWeight(FontWeight.bold),
                ),
                if (r.specifications.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    r.specifications,
                    style: TextStyles.Size10.withColor(AppColors.coolGrey),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              r.statusLabel,
              style: TextStyles.Size10
                  .withColor(AppColors.primaryBlue)
                  .withWeight(FontWeight.bold),
            ),
          ),
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
            'طلب قطعة جديدة',
            style: TextStyles.Size15
                .withColor(AppColors.darkBlueBlack)
                .withWeight(FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _label('القطعة'),
          DropdownButtonFormField<int>(
            initialValue: _materialId,
            isExpanded: true,
            decoration: _fieldDecoration(),
            hint: const Text('اختر من الكتالوج'),
            items: _materials
                .map((m) =>
                    DropdownMenuItem(value: m.id, child: Text(m.name)))
                .toList(),
            onChanged: (v) => setState(() => _materialId = v),
          ),
          const SizedBox(height: 16),
          _label('الكمية'),
          TextFormField(
            controller: _quantityController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _fieldDecoration(),
            validator: (v) {
              final n = int.tryParse((v ?? '').trim());
              if (n == null || n < 1) return 'الكمية 1 على الأقل';
              return null;
            },
          ),
          const SizedBox(height: 16),
          _label('المواصفات (اختياري)'),
          TextFormField(
            controller: _specsController,
            maxLines: 2,
            decoration: _fieldDecoration(hint: 'مقاس/نوع/ماركة...'),
          ),
          const SizedBox(height: 16),
          _label('ملاحظات (اختياري)'),
          TextFormField(
            controller: _notesController,
            maxLines: 2,
            decoration: _fieldDecoration(),
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
                  : const Icon(Icons.send_rounded),
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
                      'إرسال الطلب',
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
