import 'dart:io';
import 'package:car_care_plus/features/cars/logic/cars_cubit.dart';
import 'package:car_care_plus/features/cars/logic/cars_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import '../../data/models/car_model.dart';

class EditCarPage extends StatefulWidget {
  final CarModel car;

  const EditCarPage({super.key, required this.car});

  @override
  State<EditCarPage> createState() => _EditCarPageState();
}

class _EditCarPageState extends State<EditCarPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _modelController;
  late TextEditingController _yearController;
  late TextEditingController _plateNumberController;
  late TextEditingController _mileageController;
  late TextEditingController _cylindersController;
  late TextEditingController _colorController;

  String? _selectedFuelType;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> _fuelTypes = ['petrol', 'diesel', 'hybrid', 'electric'];

  @override
  void initState() {
    super.initState();
    // تعبئة البيانات المسبقة من كائن السيارة
    _modelController = TextEditingController(text: widget.car.model);
    _yearController = TextEditingController(text: widget.car.year);
    _plateNumberController = TextEditingController(text: widget.car.plateNumber);
    _mileageController = TextEditingController(text: widget.car.mileage.toString());
    _cylindersController = TextEditingController(text: widget.car.cylinders.toString());
    _colorController = TextEditingController(text: widget.car.color);
    _selectedFuelType = _fuelTypes.contains(widget.car.fuelType.toLowerCase())
        ? widget.car.fuelType.toLowerCase()
        : _fuelTypes.first;
  }

  @override
  void dispose() {
    _modelController.dispose();
    _yearController.dispose();
    _plateNumberController.dispose();
    _mileageController.dispose();
    _cylindersController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CarsCubit, CarsState>(
      listener: (context, state) {
        if (state is UpdateCarSuccessState) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('تم تعديل بيانات السيارة بنجاح'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // العودة للشاشة السابقة بعد التحديث
        } else if (state is CarsErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is UpdateCarLoadingState;

        return Scaffold(
          backgroundColor: AppColors.bgLight,
          appBar: AppBar(
            title: Text(
              'تعديل بيانات السيارة',
              style: TextStyles.Size18.withWeight(FontWeight.bold).withColor(AppColors.darkBlueBlack),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, color: AppColors.darkBlueBlack, size: 20.sp),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.all(20.r),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. اختيار صورة السيارة
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        children: [
                          Container(
                            height: 140.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceWhite,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: AppColors.borderGrey, width: 1.w),
                              image: _selectedImage != null
                                  ? DecorationImage(
                                      image: FileImage(_selectedImage!),
                                      fit: BoxFit.cover,
                                    )
                                  : (widget.car.cleanImageUrl != null
                                      ? DecorationImage(
                                          image: NetworkImage(widget.car.cleanImageUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null),
                            ),
                            child: (_selectedImage == null && widget.car.cleanImageUrl == null)
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.add_a_photo_outlined, size: 40.sp, color: AppColors.primaryBlue),
                                      SizedBox(height: 8.h),
                                      Text('إضافة صورة للسيارة', style: TextStyles.Size10.withColor(AppColors.coolGrey)),
                                    ],
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 8.h,
                            right: 8.w,
                            child: Container(
                              padding: EdgeInsets.all(8.r),
                              decoration: const BoxDecoration(
                                color: AppColors.primaryBlue,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.edit, color: Colors.white, size: 16.sp),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 2. حقول إدخال البيانات
                  _buildTextField(
                    controller: _modelController,
                    label: 'الموديل / اسم السيارة',
                    icon: Icons.directions_car,
                    validator: (v) => v == null || v.isEmpty ? 'يرجى إدخال الموديل' : null,
                  ),

                  SizedBox(height: 16.h),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _yearController,
                          label: 'سنة التصنيع',
                          icon: Icons.calendar_today,
                          keyboardType: TextInputType.number,
                          validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildTextField(
                          controller: _plateNumberController,
                          label: 'رقم اللوحة',
                          icon: Icons.subtitles,
                          validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _mileageController,
                          label: 'المسافة (كم)',
                          icon: Icons.speed,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _buildTextField(
                          controller: _cylindersController,
                          label: 'السلندرات',
                          icon: Icons.tune,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // حقل اللون
                  _buildTextField(
                    controller: _colorController,
                    label: 'لون السيارة',
                    icon: Icons.palette,
                  ),

                  SizedBox(height: 16.h),

                  // قائمة اختيار نوع الوقود
                  DropdownButtonFormField<String>(
                    value: _selectedFuelType,
                    decoration: _buildInputDecoration('نوع الوقود', Icons.local_gas_station),
                    items: _fuelTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(_translateFuelType(type), style: TextStyles.Size15),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedFuelType = val),
                  ),

                  SizedBox(height: 32.h),

                  // 3. زر حفظ التعديلات
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _saveChanges,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: isLoading
                          ? SizedBox(
                              height: 24.h,
                              width: 24.w,
                              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(
                              'حفظ التعديلات',
                              style: TextStyles.Size18.withWeight(FontWeight.bold).withColor(AppColors.surfaceWhite),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
void _saveChanges() {
  if (_formKey.currentState!.validate()) {
    // تجهيز البيانات وتحويل الأرقام إلى أنواعها الرقمية الصحيحة
    final Map<String, dynamic> carData = {
      'model': _modelController.text.trim(),
      'plate_number': _plateNumberController.text.trim(),
      'year': int.tryParse(_yearController.text.trim()) ?? widget.car.year,
      'mileage': int.tryParse(_mileageController.text.trim()) ?? widget.car.mileage,
      'cylinders': int.tryParse(_cylindersController.text.trim()) ?? widget.car.cylinders,
      'color': _colorController.text.trim(),
      'fuel_type': _selectedFuelType ?? widget.car.fuelType,
    };

    context.read<CarsCubit>().updateCar(
          carId: widget.car.id,
          carData: carData,
          imageFile: _selectedImage,
        );
  }
}
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyles.Size15.withColor(AppColors.darkBlueBlack),
      decoration: _buildInputDecoration(label, icon),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primaryBlue, size: 20.sp),
      filled: true,
      fillColor: AppColors.surfaceWhite,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.borderGrey)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.borderGrey)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5)),
    );
  }

  String _translateFuelType(String fuel) {
    switch (fuel.toLowerCase()) {
      case 'petrol': return 'بنزين';
      case 'diesel': return 'ديزل';
      case 'hybrid': return 'هايبرايد';
      case 'electric': return 'كهرباء';
      default: return fuel;
    }
  }
}