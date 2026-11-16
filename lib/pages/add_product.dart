import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../service/api.dart';
import '../theme/appColors.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

class AddProduct extends StatefulWidget {
  const AddProduct({super.key});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  Uint8List? selectedImage;
  String? selectedImageName;
  String? selectedImageMimeType;

  final ImagePicker picker = ImagePicker();

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final descriptionController = TextEditingController();

  String? selectedCategory;

  List<dynamic> categories = [];

  bool isLoadingCategories = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  // Get categories from API
  Future<void> getCategories() async {
    try {
      final response = await ApiService.getCategories();

      if (!mounted) return;

      setState(() {
        categories = response['data']['categories'];
        isLoadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingCategories = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load categories: $e')));
    }
  }

  // Get image MIME type
  String? getImageMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return null;
    }
  }

  // Pick image from gallery
  Future<void> pickImage() async {
    if (!kIsWeb && Platform.isAndroid)  {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      PermissionStatus status;

      if (androidInfo.version.sdkInt >= 33) {
        status = await Permission.photos.request();
      } else {
        status = await Permission.storage.request();
      }

      print('ANDROID VERSION: ${androidInfo.version.sdkInt}');
      print('PERMISSION STATUS: $status');
      print('IS GRANTED: ${status.isGranted}');

      if (!status.isGranted && !status.isLimited) {
        print('PERMISSION DENIED');

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Photo access permission is required.')),
        );
        return;
      }
    }

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      final mimeType = pickedFile.mimeType ?? getImageMimeType(pickedFile.name);

      if (mimeType == null ||
          !['image/jpeg', 'image/png', 'image/webp'].contains(mimeType)) {
        return;
      }

      final bytes = await pickedFile.readAsBytes();

      if (!mounted) return;

      setState(() {
        selectedImage = bytes;
        selectedImageName = pickedFile.name;
        selectedImageMimeType = mimeType;
      });
    }
  }

  // Add product to API
  Future<void> addProduct() async {
    if (nameController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        stockController.text.trim().isEmpty ||
        selectedCategory == null ||
        descriptionController.text.trim().isEmpty ||
        selectedImage == null ||
        selectedImageName == null ||
        selectedImageMimeType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields and select an image.'),
        ),
      );
      return;
    }

    final price = double.tryParse(priceController.text.trim());
    final stock = int.tryParse(stockController.text.trim());

    if (price == null || price <= 0 || stock == null || stock < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price and stock.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ApiService.postMultipart(
        '/products',
        {
          'name': nameController.text.trim(),
          'categoryId': selectedCategory!,
          'price': price.toString(),
          'stock': stock.toString(),
          'description': descriptionController.text.trim(),
        },
        selectedImage!,
        selectedImageName!,
        selectedImageMimeType!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added successfully!')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to add product: $e')));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Input field
  Widget inputField({
    required String hint,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
        ),
        filled: true,
        fillColor: const Color(0xFFF3F3F3),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Field label
  Widget fieldLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 55, 24, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Page title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Product',
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Product image and name
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.border.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: selectedImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Image.memory(
                                    selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.add_photo_alternate_outlined,
                                  color: AppColors.textSecondary,
                                  size: 28,
                                ),
                        ),
                      ),

                      const SizedBox(width: 20),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            fieldLabel('Product Name'),
                            inputField(
                              hint: 'Enter product name',
                              controller: nameController,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // Price and stock
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            fieldLabel('Price'),
                            inputField(
                              hint: 'Rp 0',
                              controller: priceController,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            fieldLabel('Stock'),
                            inputField(
                              hint: 'Enter stock',
                              controller: stockController,
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Category
                  fieldLabel('Category'),

                  isLoadingCategories
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        )
                      : DropdownButtonFormField<String>(
                          value: selectedCategory,
                          hint: const Text(
                            'Select category',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: const Color(0xFFF3F3F3),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category['id'].toString(),
                              child: Text(category['name'].toString()),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                            });
                          },
                        ),

                  const SizedBox(height: 22),

                  // Description
                  fieldLabel('Description'),

                  inputField(
                    hint: 'Enter product description',
                    controller: descriptionController,
                    maxLines: 4,
                  ),
                ],
              ),
            ),
          ),

          // Add product button
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
            child: SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                onPressed: isLoading ? null : addProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textPrimary,
                  disabledBackgroundColor: AppColors.primary.withValues(
                    alpha: 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textPrimary,
                        ),
                      )
                    : const Text(
                        'Add Product',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
