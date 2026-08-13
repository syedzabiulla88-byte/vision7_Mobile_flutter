import 'package:flutter/material.dart';
import '../../core/constants/spacing.dart';

class AppInput extends StatelessWidget {
  final String? label;
  final String value;
  final ValueChanged<String> onChanged;
  final String? placeholder;
  final String? error;
  final bool obscureText;
  final TextInputType keyboardType;
  final bool isMultiline;
  final Widget? leftIcon;
  final Widget? rightIcon;
  final EdgeInsetsGeometry? padding;

  const AppInput({
    super.key,
    this.label,
    required this.value,
    required this.onChanged,
    this.placeholder,
    this.error,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.isMultiline = false,
    this.leftIcon,
    this.rightIcon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: AppSpacing.sm),
        ],
        TextField(
          controller: TextEditingController(text: value)..selection = TextSelection.fromPosition(TextPosition(offset: value.length)),
          onChanged: onChanged,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: isMultiline ? 4 : 1,
          decoration: InputDecoration(
            hintText: placeholder,
            errorText: error,
            prefixIcon: leftIcon,
            suffixIcon: rightIcon,
          ),
        ),
      ],
    );
  }
}
