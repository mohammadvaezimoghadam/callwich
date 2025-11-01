import 'package:flutter/material.dart';
import 'package:callwich/res/colors.dart';

class AddPaymentMethodWidget extends StatefulWidget {
  const AddPaymentMethodWidget({Key? key, required this.submit})
    : super(key: key);
  final Function(String name) submit;
  @override
  State<AddPaymentMethodWidget> createState() => _AddPaymentMethodWidgetState();
}

class _AddPaymentMethodWidgetState extends State<AddPaymentMethodWidget> {
  final _formKey = GlobalKey<FormState>();
  final _paymentMethodController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _paymentMethodController.dispose();
    super.dispose();
  }

  // Function to validate form
  bool _validateForm() {
    if (_formKey.currentState != null) {
      return _formKey.currentState!.validate();
    }
    return false;
  }

  // Function to get the payment method name from the form
  String? _getPaymentMethodName() {
    if (_validateForm()) {
      return _paymentMethodController.text.trim();
    }
    return null;
  }

  void _showAddPaymentMethodDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.payment, color: LightAppColors.primary),
              const SizedBox(width: 8),
              Text(
                'افزودن روش پرداخت جدید',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _paymentMethodController,
                  decoration: InputDecoration(
                    labelText: 'نام روش پرداخت',
                    hintText: 'مثال: کیف پول الکترونیکی',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: Icon(
                      Icons.payment,
                      color: LightAppColors.primary,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'لطفاً نام روش پرداخت را وارد کنید';
                    }
                    if (value.trim().length < 2) {
                      return 'نام روش پرداخت باید حداقل ۲ کاراکتر باشد';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('انصراف', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : ()  {
                final paymentMethodName = _getPaymentMethodName();
                if (paymentMethodName != null) {
                  setState(() => _isLoading = true);
                  
                  try {
                    // Call the submit function from parent
                     widget.submit(paymentMethodName);
                    
                    // Close dialog and clear form on success
                    Navigator.of(context).pop();
                    _paymentMethodController.clear(); 
                    
                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('روش پرداخت "$paymentMethodName" با موفقیت اضافه شد'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } catch (e) {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('خطا در افزودن روش پرداخت: $e'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } finally {
                    setState(() => _isLoading = false);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: LightAppColors.primary,
                foregroundColor: LightAppColors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child:
                  _isLoading
                      ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            LightAppColors.onPrimary,
                          ),
                        ),
                      )
                      : const Text('افزودن'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _showAddPaymentMethodDialog,
      icon: Icon(
        Icons.add_circle_outline,
        color: LightAppColors.primary,
        size: 24,
      ),
      tooltip: 'افزودن روش پرداخت جدید',
    );
  }
}