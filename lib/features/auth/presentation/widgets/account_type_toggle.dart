import 'package:flutter/material.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';

enum AccountType { individual, company }

// مبدّل نوع الحساب في رأس صفحة إنشاء الحساب (فرد / شركة)
class AccountTypeToggle extends StatelessWidget {
  final AccountType value;
  final ValueChanged<AccountType> onChanged;

  const AccountTypeToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          _Segment(
            label: 'حساب فرد',
            icon: Icons.person_outline_rounded,
            selected: value == AccountType.individual,
            onTap: () => onChanged(AccountType.individual),
          ),
          _Segment(
            label: 'حساب شركة',
            icon: Icons.business_outlined,
            selected: value == AccountType.company,
            onTap: () => onChanged(AccountType.company),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? AppColors.surfaceWhite : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? AppColors.primaryBlue
                    : AppColors.surfaceWhite.withOpacity(0.85),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyles.Size15
                    .withColor(
                      selected
                          ? AppColors.primaryBlue
                          : AppColors.surfaceWhite.withOpacity(0.85),
                    )
                    .withWeight(FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
