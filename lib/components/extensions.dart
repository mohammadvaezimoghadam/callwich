import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension IntExtension on int {

  String toToman() {
    final formatter = NumberFormat('#,###', 'fa_IR');
    return '${formatter.format(this)} تومان';
  }


  String toFormattedNumber() {
    final formatter = NumberFormat('#,###', 'fa_IR');
    return formatter.format(this);
  }
}


extension IntSizedBoxExtension on int {
  SizedBox get heightBox => SizedBox(height: toDouble());
  SizedBox get widthBox => SizedBox(width: toDouble());
}
extension IdoubleExtension on double {

  String toToman() {
    final formatter = NumberFormat('#,###', 'fa_IR');
    return '${formatter.format(this)} تومان';
  }


  String toFormattedNumber() {
    final formatter = NumberFormat('#,###', 'fa_IR');
    return formatter.format(this);
  }
}

extension StringDigitConversionExtension on String {
  /// Converts Persian and Eastern Arabic-Indic digits within the string to ASCII digits.
  String toEnglishDigits() {
    var result = this;
    const easternArabic = '٠١٢٣٤٥٦٧٨٩'; // U+0660..U+0669
    const persian = '۰۱۲۳۴۵۶۷۸۹'; // U+06F0..U+06F9
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(easternArabic[i], i.toString());
      result = result.replaceAll(persian[i], i.toString());
    }
    return result;
  }
}

