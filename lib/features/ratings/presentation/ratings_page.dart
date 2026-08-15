import 'package:flutter/material.dart';
import 'package:car_care_plus/core/networking/api_service.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';
import 'package:car_care_plus/features/ratings/data/rating_model.dart';
import 'package:car_care_plus/features/ratings/data/ratings_repo.dart';

// شاشة التقييمات (عرض فقط) — التقييمات التي تلقّاها الموظف/الورشة.
class RatingsPage extends StatefulWidget {
  const RatingsPage({super.key});

  @override
  State<RatingsPage> createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage> {
  final _repo = RatingsRepo(ApiService());
  List<RatingModel> _ratings = [];
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
      final ratings = await _repo.getRatings();
      if (mounted) setState(() => _ratings = ratings);
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
          'التقييمات',
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
              : _ratings.isEmpty
                  ? _emptyView()
                  : RefreshIndicator(
                      color: AppColors.primaryBlue,
                      onRefresh: _load,
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                        itemCount: _ratings.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 14),
                        itemBuilder: (_, i) => _RatingCard(rating: _ratings[i]),
                      ),
                    ),
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

  Widget _emptyView() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.28),
        Icon(
          Icons.star_border_rounded,
          size: 64,
          color: AppColors.coolGrey.withOpacity(0.5),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'لا توجد تقييمات بعد',
            style: TextStyles.Size15.withColor(AppColors.coolGrey),
          ),
        ),
      ],
    );
  }
}

class _RatingCard extends StatelessWidget {
  final RatingModel rating;
  const _RatingCard({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${rating.customerName} • طلب #${rating.orderId}',
                  style: TextStyles.Size15
                      .withColor(AppColors.darkBlueBlack)
                      .withWeight(FontWeight.bold),
                ),
              ),
              _Stars(value: rating.serviceRating),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              _MiniRating(label: 'الخدمة', value: rating.serviceRating),
              if (rating.employeeRating != null)
                _MiniRating(label: 'الموظف', value: rating.employeeRating!),
              if (rating.workshopRating != null)
                _MiniRating(label: 'الورشة', value: rating.workshopRating!),
            ],
          ),
          if (rating.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              rating.comment,
              style: TextStyles.Size15.withColor(AppColors.coolGrey),
            ),
          ],
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  final int value;
  const _Stars({required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < value ? Icons.star_rounded : Icons.star_border_rounded,
          size: 18,
          color: AppColors.warningColor,
        ),
      ),
    );
  }
}

class _MiniRating extends StatelessWidget {
  final String label;
  final int value;
  const _MiniRating({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyles.Size10.withColor(AppColors.coolGrey),
        ),
        Icon(Icons.star_rounded, size: 14, color: AppColors.warningColor),
        Text(
          '$value',
          style: TextStyles.Size10
              .withColor(AppColors.darkBlueBlack)
              .withWeight(FontWeight.bold),
        ),
      ],
    );
  }
}
