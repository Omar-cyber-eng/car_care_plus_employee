import 'package:car_care_plus/features/auth/presentation/profile_page.dart';
import 'package:car_care_plus/features/cars/ui/views/my_cars_view.dart';
import 'package:car_care_plus/features/home/ui/views/home_view.dart';
import 'package:car_care_plus/features/orders/presentation/orders_page.dart';
import 'package:flutter/material.dart';
import 'package:car_care_plus/core/resources/app_color.dart';
import 'package:car_care_plus/core/resources/text_style.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  // نبدأ افتراضياً على الواجهة الرئيسية (Index 2)
  int _currentIndex = 2;

  // الترتيب من اليمين لليسار (RTL):
  // 0: حسابي (البروفايل)
  // 1: الكراج (سياراتي)
  // 2: الرئيسية
  // 3: طلباتي
  final List<Widget> _pages = const [
    ProfilePage(),
    MyCarsView(),
    HomeView(),
    OrdersPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlueSurface,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBlueBlack.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surfaceWhite,
          elevation: 0,
          selectedItemColor: AppColors.primaryBlue,
          unselectedItemColor: AppColors.coolGrey,
          showUnselectedLabels: true,
          selectedLabelStyle: TextStyles.Size10.withWeight(FontWeight.bold),
          unselectedLabelStyle: TextStyles.Size10,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'حسابي',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.directions_car_outlined),
              activeIcon: Icon(Icons.directions_car_filled_rounded),
              label: 'الكراج',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: 'طلباتي',
            ),
          ],
        ),
      ),
    );
  }
}