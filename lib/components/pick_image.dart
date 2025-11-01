import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<XFile?> pickImageBottomSheet(BuildContext context) async {
  return showModalBottomSheet<XFile?>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Text('Select Image Source', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.camera_alt, color: Colors.orange),
              ),
              title: const Text('Camera'),
              onTap: () async {
                final picked = await ImagePicker().pickImage(
                  source: ImageSource.camera,
                  imageQuality: 60, // 0-100: lower = more compression
                  maxWidth: 1280,   // downscale large images
                  maxHeight: 1280,
                );
                Navigator.pop(context, picked);
              },
            ),
            ListTile(
              leading: Container(
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.photo, color: Colors.orange),
              ),
              title: const Text('Gallery'),
              onTap: () async {
                final picked = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 60,
                  maxWidth: 1280,
                  maxHeight: 1280,
                );
                Navigator.pop(context, picked);
              },
            ),
          ],
        ),
      );
    },
  );
}