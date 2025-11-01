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

