import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:callwich/data/common/http_client.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:callwich/data/common/constans.dart';
import '../components/pick_image.dart';
import 'package:callwich/res/strings.dart';

class ProductImagePickerWidget extends StatelessWidget {
  final XFile? image;
  final ValueChanged<XFile?> onImagePicked;
  final bool isEditing;
  final String? imageUrl;
  const ProductImagePickerWidget({
    Key? key,
    required this.image,
    required this.onImagePicked,
    required this.isEditing,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.productImage,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 200, // Fixed height for consistent sizing
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFFe7d9cf),
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(12),
            color: Colors.transparent,
          ),
          child: isEditing
              ? Stack(
                  children: [
                    // Ensure the image container fills the entire area
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: image != null
                            // Show the newly selected image if available
                            ? Image.file(
                                File(image!.path),
                                fit: BoxFit.cover, // Cover fit to fill the container completely
                                width: double.infinity,
                                height: double.infinity,
                              )
                            // Otherwise show the existing image from network
                            : CachedNetworkImage(
                                imageUrl: "$baseUrlImg$imageUrl",
                                fit: BoxFit.cover, // Cover fit to fill the container completely
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.grey,
                                      ),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(
                                      Icons.broken_image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: FloatingActionButton(
                        onPressed: () async {
                          final picked = await pickImageBottomSheet(context);
                          if (picked != null) {
                            onImagePicked(picked);
                          }
                        },
                        backgroundColor: theme.colorScheme.primary,
                        child: Icon(
                          Icons.edit,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: () async {
                    final picked = await pickImageBottomSheet(context);
                    if (picked != null) {
                      onImagePicked(picked);
                    }
                  },
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            image == null
                                ? Icon(
                                    Icons.add_photo_alternate,
                                    size: 40,
                                    color: Colors.orange[300],
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      File(image!.path),
                                      width: double.infinity,
                                      height: 120,
                                      fit: BoxFit.cover, // Cover fit for consistency
                                    ),
                                  ),
                            const SizedBox(height: 8),
                            const Text(
                              AppStrings.tapToAddImage,
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const Text(
                              AppStrings.recommendedSize,
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9a6c4c),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}