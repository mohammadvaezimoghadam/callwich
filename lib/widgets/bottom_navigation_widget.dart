import 'package:callwich/ui/main/mainScreen.dart';
import 'package:flutter/material.dart';
import '../res/strings.dart';

class BottomNavigationWithFab extends StatelessWidget {
  final int currentIndex;
  final Function(int index) onTap;
  final VoidCallback? onFabTap;
  const BottomNavigationWithFab({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onFabTap,
  });

  @override
  Widget build(BuildContext context) {
    // دکمه فلووت بر بالای نوار پایین (ظاهر زیبا شده)
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // BottomNavigationBar اصلی
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFCFAF8).withOpacity(0.8),
            border: Border(
              top: BorderSide(
                color: const Color(0xFFE7D9CF),
                width: 1,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Expanded(
                    child: _buildNavItem(
                      icon: Icons.dashboard,
                      text: AppStrings.dashboard,
                      isSelected: currentIndex == dashboardIndex,
                      onTap: () {
                        onTap(dashboardIndex);
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      icon: Icons.inventory,
                      text: AppStrings.inventory,
                      isSelected: currentIndex == inventoryManagementIndex,
                      onTap: () {
                        onTap(inventoryManagementIndex);
                      },
                    ),
                  ),
                  const SizedBox(width: 64), // برای فضای وسط
                  Expanded(
                    child: _buildNavItem(
                      icon: Icons.shopping_bag,
                      text: AppStrings.productsManagement,
                      isSelected: currentIndex == productsListIndex,
                      onTap: () {
                        onTap(productsListIndex);
                      },
                    ),
                  ),
                  Expanded(
                    child: _buildNavItem(
                      icon: Icons.bar_chart,
                      text: AppStrings.reports,
                      isSelected: currentIndex == reportsIndex,
                      onTap: () {
                        onTap(reportsIndex);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // دکمه فلووت بالای نوار - ظاهر مدرن‌تر، افکت سایه، رنگ گرادینت و آیکون "پلاس" ترکیب با سبد خرید
        Positioned(
          top: -28, // مقدار بیشتر برای تو رفتگی ملایم‌تر
          child: SizedBox(
            height: 72,
            width: 80,
            child: Center(
              child: Material(
                elevation: 12,
                borderRadius: BorderRadius.circular(40),
                color: Colors.transparent,
                shadowColor: const Color(0xFFED7B2A).withOpacity(0.3),
                child: InkWell(
                  borderRadius: BorderRadius.circular(40),
                  onTap: onFabTap ??
                      () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('فروش جدید (FAB)'),
                          ),
                        );
                      },
                  child: Container(
                    height: 64,
                    width: 64,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFED7B2A), Color(0xFFF8C660)],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFED7B2A).withOpacity(0.2),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shopping_cart_checkout,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String text,
    required bool isSelected,
    required Function() onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFFED7B2A)
                  : const Color(0xFF9A6C4C),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFFED7B2A)
                    : const Color(0xFF9A6C4C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
