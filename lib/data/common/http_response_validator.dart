import 'package:callwich/data/common/app_exeption.dart';

mixin HttpResponseValidatorMixin {
  void validateResponse(dynamic response) {
    final statusCode = response?.statusCode;
    
    // حالا که Dio exception نمی‌دهد، باید status code را چک کنیم
    if (statusCode == null || statusCode < 200 || statusCode >= 300) {
      // اگر response data وجود دارد و پیام خطا دارد، از آن استفاده کن
      if (response?.data != null && response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        final message = data['message'] ?? data['detail'] ?? 'خطا در درخواست';
        throw AppException(message: message.toString());
      } else {
        throw AppException();
      }
    }
  }
}