import 'package:flutter/material.dart';

class ProductActionButtonsWidget extends StatelessWidget {
  final VoidCallback? onEditPressed;
  final VoidCallback? onDeletePressed;
  final String editText;
  final String deleteText;
  final bool showEditButton;
  final bool dleletLoading;
  final bool showDeleteButton;

  const ProductActionButtonsWidget({
    Key? key,
    this.onEditPressed,
    this.onDeletePressed,
    this.editText = 'ویرایش',
    this.deleteText = 'حذف',
    this.showEditButton = true,
    this.showDeleteButton = true,
    required this.dleletLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showEditButton) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onEditPressed,
              icon: Icon(
                Icons.edit_outlined,
                size: 20,
                color: Colors.brown[800],
              ),
              label: Text(
                editText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFe7d9cf),
                foregroundColor: Colors.brown[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
        if (showEditButton && showDeleteButton) const SizedBox(width: 16),
        if (showDeleteButton) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: dleletLoading ? () {} : onDeletePressed,
              icon:
                  dleletLoading
                      ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          
                          color: Theme.of(context).colorScheme.error,
                        ),
                      )
                      : Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Colors.red[700],
                      ),
              label: Text(
                deleteText,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[100],
                foregroundColor: Colors.red[700],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
