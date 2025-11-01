import 'package:flutter/material.dart';

class CustomQuantityTextField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String>? onChanged;
  final String? keyValue;
  final double? width;
  final bool enabled;
  final String? hintText;
  final TextAlign textAlign;

  const CustomQuantityTextField({
    Key? key,
    required this.initialValue,
    this.onChanged,
    this.keyValue,
    this.width,
    this.enabled = true,
    this.hintText,
    this.textAlign = TextAlign.center,
  }) : super(key: key);

  @override
  State<CustomQuantityTextField> createState() => _CustomQuantityTextFieldState();
}

class _CustomQuantityTextFieldState extends State<CustomQuantityTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SizedBox(
      width: widget.width ?? 96,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isFocused ? [
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: TextFormField(
          key: widget.keyValue != null ? ValueKey(widget.keyValue) : null,
          controller: _controller,
          focusNode: _focusNode,
          enabled: widget.enabled,
          keyboardType: const TextInputType.numberWithOptions(
            signed: false,
            decimal: false,
          ),
          textAlign: widget.textAlign,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            // حالت عادی
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            // حالت فوکوس
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2.5,
              ),
            ),
            // حالت خطا
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2,
              ),
            ),
            // حالت غیرفعال
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.2),
                width: 1,
              ),
            ),
            // پس‌زمینه
            filled: true,
            fillColor: widget.enabled 
              ? (_isFocused 
                  ? theme.colorScheme.primary.withOpacity(0.08)
                  : theme.colorScheme.surface)
              : theme.colorScheme.surface.withOpacity(0.3),
            // padding
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            // hint text
            hintText: widget.hintText ?? '0',
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.4),
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            // counter text
            counterText: '',
          ),
          onChanged: (value) {
            widget.onChanged?.call(value);
          },
          onTap: () {
            // انتخاب تمام متن هنگام کلیک
            _controller.selection = TextSelection(
              baseOffset: 0,
              extentOffset: _controller.text.length,
            );
          },
        ),
      ),
    );
  }
}