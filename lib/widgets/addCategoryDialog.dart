import 'package:callwich/res/strings.dart';
import 'package:flutter/material.dart';

class AddCategoryDialog extends StatelessWidget {
  AddCategoryDialog({
    super.key,
    required this.title,
    required this.hintText,
    required this.onSave,
  });
  final String title;
  final String hintText;
  final Function(String name) onSave;

  final TextEditingController categoryControler = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: TextField(
        controller: categoryControler,

        decoration: InputDecoration(hintText: hintText),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(AppStrings.cancel),
        ),

        TextButton(
          onPressed: () {
            onSave(categoryControler.text);
          },
          child: Text(AppStrings.save),
        ),
      ],
    );
  }
}
