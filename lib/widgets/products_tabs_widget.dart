import 'package:callwich/data/models/category.dart';
import 'package:flutter/material.dart';

class ProductsTabsWidget extends StatelessWidget {
  final List<CategoryEntity> tabs;
  final int selectedTabIndex;
  final Function({required int index,required int categoryId}) onTabChanged;
  final ThemeData theme;

  const ProductsTabsWidget({
    super.key,
    required this.tabs,
    required this.selectedTabIndex,
    required this.onTabChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline, width: 1),
        ),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ListView.builder(
          padding: EdgeInsets.only(left: 8),
          scrollDirection: Axis.horizontal,
          itemCount: tabs.length,
          itemBuilder: (context, index) {
            final isSelected = index == selectedTabIndex;
            return GestureDetector(
              onTap: () => onTabChanged(index:index,categoryId: tabs[index].id),
              child: Container(
                margin: const EdgeInsets.only(right: 24),
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  tabs[index].name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                    color:
                        isSelected
                            ? theme.colorScheme.primary
                            : Color(0xFF9A6C4C),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
