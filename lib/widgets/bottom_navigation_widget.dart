import 'package:callwich/ui/main/mainScreen.dart';
import 'package:flutter/material.dart';
import '../res/strings.dart';

class BottomNavigationWidget extends StatelessWidget {
  final int currentIndex;
  final Function(int index) onTap;
  const BottomNavigationWidget({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF8).withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFE7D9CF), // neutral-200
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
                  isSelected: currentIndex==dashboardIndex,
                  onTap: () {
                    onTap(dashboardIndex);
                  },
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.inventory,
                  text: AppStrings.inventory,
                  isSelected: currentIndex==inventoryManagementIndex,
                  onTap: () {
                    onTap(inventoryManagementIndex);
                  },
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.shopping_bag,
                  text: AppStrings.productsManagement,
                  isSelected: currentIndex==productsListIndex,
                  onTap: () {
                    onTap(productsListIndex);
                  },
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.bar_chart,
                  text: AppStrings.reports, // Fixed: changed 'reports' to 'report'
                  isSelected: currentIndex==reportsIndex,
                  onTap: () {
                    onTap(reportsIndex);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
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
        color: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 4),
        
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color:
                  isSelected
                      ? const Color(0xFFED7B2A) // primary-600
                      : const Color(0xFF9A6C4C), // neutral-600
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color:
                    isSelected
                        ? const Color(0xFFED7B2A) // primary-600
                        : const Color(0xFF9A6C4C), // neutral-600
              ),
            ),
          ],
        ),
      ),
    );
  }
}
