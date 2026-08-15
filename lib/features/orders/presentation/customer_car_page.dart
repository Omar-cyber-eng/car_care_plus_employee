import 'package:flutter/material.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import 'package:car_care_plus/features/orders/data/customer_car_model.dart';
import 'package:car_care_plus/features/orders/data/orders_repo.dart';

// عرض سيارة العميل (قراءة فقط) — GET /cars/show/{id}.
class CustomerCarPage extends StatefulWidget {
  final int carId;

  const CustomerCarPage({super.key, required this.carId});

  @override
  State<CustomerCarPage> createState() => _CustomerCarPageState();
}

class _CustomerCarPageState extends State<CustomerCarPage> {
  final _repo = OrdersRepo(ApiService());
  CustomerCar? _car;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final car = await _repo.getCustomerCar(widget.carId);
      if (mounted) setState(() => _car = car);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
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
          'سيارة العميل',
          style: TextStyles.Size18
              .withColor(AppColors.surfaceWhite)
              .withWeight(FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            )
          : _error != null
              ? _errorView()
              : _content(_car!),
    );
  }

  Widget _errorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _error ?? 'خطأ',
            style: TextStyles.Size15.withColor(AppColors.errorColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _load, child: const Text('إعادة المحاولة')),
        ],
      ),
    );
  }

  Widget _content(CustomerCar car) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      children: [
        if (car.imageUrl != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              car.imageUrl!,
              height: 190,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholderImage(),
            ),
          )
        else
          _placeholderImage(),
        const SizedBox(height: 16),
        Text(
          car.model,
          style: TextStyles.Size24
              .withColor(AppColors.darkBlueBlack)
              .withWeight(FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          car.plateNumber.toUpperCase(),
          style: TextStyles.Size15
              .withColor(AppColors.primaryBlue)
              .withWeight(FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _specGrid(car),
      ],
    );
  }

  Widget _placeholderImage() {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.lightBlueSurface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Icon(
        Icons.directions_car_filled_rounded,
        size: 64,
        color: AppColors.primaryBlue.withOpacity(0.4),
      ),
    );
  }

  Widget _specGrid(CustomerCar car) {
    final specs = <List<String>>[
      ['السنة', car.year?.toString() ?? '—'],
      ['اللون', car.color.isEmpty ? '—' : car.color],
      ['الوقود', car.fuelLabel],
      ['السلندرات', car.cylinders?.toString() ?? '—'],
      ['المسافة', car.mileage != null ? '${car.mileage} كم' : '—'],
      ['النوع', car.carTypeName.isEmpty ? '—' : car.carTypeName],
      if (car.branchName.isNotEmpty) ['الفرع', car.branchName],
    ];

    return Column(
      children: [
        for (final s in specs)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  s[0],
                  style: TextStyles.Size15.withColor(AppColors.coolGrey),
                ),
                Text(
                  s[1],
                  style: TextStyles.Size15
                      .withColor(AppColors.darkBlueBlack)
                      .withWeight(FontWeight.w600),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
