import 'package:clinician_app/core/constant/app_colors.dart';
import 'package:clinician_app/core/constant/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PrimaryTextField extends StatelessWidget {
  static const double _defaultCursorHeight = 22;
  const PrimaryTextField({
    super.key,
    final Key? fieldKey,
    this.autovalidateMode,
    this.hintText,
    this.labelText,
    this.helperText,
    this.initialValue,
    this.errorMaxLines,
    this.maxLines,
    this.maxLength,
    this.enabled,
    this.filledColor,
    this.filled,
    this.borderRadius = 10,
    this.cursorColor,
    this.borderColor,
    this.hoverColor,
    this.prefixIcon,
    this.prefixText,
    this.prefixTextStyle,
    this.suffixIcon,
    this.focusNode,
    this.style,
    this.hintStyle,
    this.floatingLabelStyle,
    this.labelStyle,
    this.controller,
    this.inputFormatters,
    this.textInputAction,
    this.keyboardType,
    this.onTap,
    this.onSaved,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.border,
    this.contentPadding,
    this.readonly,
    this.scrollPadding,
    this.obscuringCharacter,
    this.focusedBorder,
    this.disabledBorder,
    this.obscureText = false,
    this.isShowError = false,
    this.textAlign = TextAlign.left,
    this.autofocus = false,
    this.enableSuffixIcon = true,
    this.textCapitalization = TextCapitalization.none,
    this.maxWidth,
    this.isMaxWidth = true,
    this.isLandLine = false,
    this.boxShadow,
    this.validationLength,
    this.prefixIconConstraints,
    this.isCapital = false,
    this.isUsPhone = false,
  });
  final AutovalidateMode? autovalidateMode;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final String? initialValue;
  final int? errorMaxLines;
  final int? maxLines;
  final int? maxLength;
  final double? borderRadius;
  final bool? enabled;
  final bool autofocus;
  final bool obscureText;
  final Color? filledColor;
  final bool? filled;
  final Color? cursorColor;
  final Color? borderColor;
  final Color? hoverColor;
  final Widget? prefixIcon;
  final BoxConstraints? prefixIconConstraints;
  final String? prefixText;
  final TextStyle? prefixTextStyle;
  final Widget? suffixIcon;
  final bool enableSuffixIcon;
  final bool isShowError;
  final FocusNode? focusNode;
  final TextStyle? style;
  final TextStyle? hintStyle;
  final TextStyle? floatingLabelStyle;
  final TextStyle? labelStyle;
  final TextAlign textAlign;
  final TextEditingController? controller;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final GestureTapCallback? onTap;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final BorderSide? border;
  final EdgeInsetsGeometry? contentPadding;
  final bool? readonly;
  final EdgeInsets? scrollPadding;
  final String? obscuringCharacter;
  final InputBorder? focusedBorder;
  final InputBorder? disabledBorder;
  final double? maxWidth;
  final bool isMaxWidth;
  final bool isLandLine;
  final List<BoxShadow>? boxShadow;
  final bool isCapital;
  final bool isUsPhone;

  /// Validate Textfield after given number of length
  final int? validationLength;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // height: 35,
      child: TextFormField(
        scrollPadding: scrollPadding ?? EdgeInsets.zero,
        key: key,
        readOnly: readonly ?? false,
        controller: controller,
        focusNode: focusNode,
        maxLines: obscureText ? 1 : maxLines,
        initialValue: initialValue,
        keyboardType:  isUsPhone ? TextInputType.phone : keyboardType,
        textCapitalization: textCapitalization,
        obscureText: obscureText,
        autovalidateMode:
            autovalidateMode ?? AutovalidateMode.onUserInteraction,
        enabled: enabled,
        validator: validator,
        maxLength:  isUsPhone ? 14 : maxLength,
        textInputAction: textInputAction ?? TextInputAction.next,
        inputFormatters: [
          if (isUsPhone) ...[
            FilteringTextInputFormatter.digitsOnly,
            UsPhoneInputFormatter(),
          ],
          ...inputFormatters ?? [],
        ],
        buildCounter: (
          context, {
          required currentLength,
          required isFocused,
          maxLength,
        }) {
          return null;
        },
        onTap: onTap,
        onSaved: onSaved,
        onChanged: onChanged,
        onFieldSubmitted: onFieldSubmitted,
        autocorrect: true,
        autofocus: autofocus,
        textAlign: textAlign,
        cursorColor: style?.color,
        cursorHeight: (style?.fontSize != null && style?.height != null)
            ? style!.fontSize! * style!.height!
            : _defaultCursorHeight,
        // obscuringCharacter: obscuringCharacter ?? "●",
        style: style ?? AppTextStyle.normal12style.copyWith(
          fontWeight: FontWeight.w400,
          color: AppColors.defaultTxtGrey,
        ),
        decoration: InputDecoration(
          // errorStyle: const TextStyle(height: 0, fontSize: 0),
          // errorText: null,
          // errorMaxLines: 1,
          // label: Text(
          //   "",
          //   style: hintStyle,
          // ),
          // floatingLabelBehavior: FloatingLabelBehavior.always,
          prefixIcon: prefixIcon,
          prefixIconConstraints: prefixIconConstraints,
          hoverColor: hoverColor,
          prefixText: prefixText,
          prefixStyle: prefixTextStyle,
          // constraints: BoxConstraints(
          //   maxWidth:
          //       MediaQuery.of(navigatorKey.currentContext!).size.width * 0.5,
          // ),
          isDense: true,
          contentPadding:
              contentPadding ??
              (const EdgeInsets.symmetric(horizontal: 10, vertical: 5)),

          enabledBorder:
              focusedBorder ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
                borderSide: const BorderSide(
                  color: AppColors.textFieldBorderColor,
                ),
              ),
          // floatingLabelStyle: floatingLabelStyle,
          focusedBorder:
              focusedBorder ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
                borderSide: const BorderSide(
                  color: AppColors.textFieldBorderColor,
                ),
              ),
          border:
              focusedBorder ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
                borderSide: const BorderSide(
                  color: AppColors.textFieldBorderColor,
                  width: 0.0,
                ),
              ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
            borderSide: const BorderSide(color: AppColors.redColor),
          ),
          disabledBorder:
              disabledBorder ??
              OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius ?? 10.r),
                borderSide: BorderSide(
                  color: filledColor ?? Colors.transparent,
                  width: 0.0,
                ),
              ),
          fillColor: filledColor ?? AppColors.textFieldBackGColor,
          filled: filled ?? true,
          hintStyle:
              hintStyle ??
              AppTextStyle.normal10style.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.hintGrey,
              ),
          hintText: hintText ?? "",
          enabled: enabled ?? true,
          suffixIcon:
              enableSuffixIcon ? suffixIcon ?? const SizedBox.shrink() : null,
          labelStyle: labelStyle,
          labelText: labelText,
          helperText: helperText,

        ),

      ),
    );
  }
}




/// USA Phone Input Formatter
class UsPhoneInputFormatter extends TextInputFormatter {
  static final _nonDigit = RegExp(r'\D');

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    // 1) Extract digits
    final newDigits = newValue.text.replaceAll(_nonDigit, '');
    final oldDigits = oldValue.text.replaceAll(_nonDigit, '');

    // Limit to 10 digits
    if (newDigits.length > 10) return oldValue;

    // 2) Count how many digits are before the cursor in the NEW value
    final digitsBeforeCursor = _countDigitsBefore(
      newValue.text,
      newValue.selection.baseOffset,
    );

    // 3) Build formatted text
    final formatted = _formatUsPhone(newDigits);

    // 4) Compute cursor position in formatted text corresponding to digitsBeforeCursor
    final newCursor = _cursorOffsetForDigitIndex(formatted, digitsBeforeCursor);

    // 5) Special case: if user is deleting and cursor lands on a separator, move left
    final isDeleting = newDigits.length < oldDigits.length;
    final adjustedCursor = isDeleting
        ? _skipSeparatorsLeft(formatted, newCursor)
        : newCursor;

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: adjustedCursor.clamp(0, formatted.length),
      ),
    );
  }

  int _countDigitsBefore(String text, int cursor) {
    if (cursor <= 0) return 0;
    final end = cursor.clamp(0, text.length);
    return text.substring(0, end).replaceAll(_nonDigit, '').length;
  }

  String _formatUsPhone(String digits) {
    if (digits.isEmpty) return '';

    final sb = StringBuffer();

    // (XXX
    sb.write('(');
    sb.write(digits.substring(0, digits.length.clamp(0, 3)));

    if (digits.length >= 3) {
      sb.write(') ');
      // XXX
      sb.write(digits.substring(3, digits.length.clamp(3, 6)));

      if (digits.length >= 6) {
        sb.write('-');
        // XXXX
        sb.write(digits.substring(6));
      }
    }

    return sb.toString();
  }

  int _cursorOffsetForDigitIndex(String formatted, int digitIndex) {
    if (digitIndex <= 0) return 0;

    int digitsSeen = 0;
    for (int i = 0; i < formatted.length; i++) {
      if (_isDigit(formatted.codeUnitAt(i))) {
        digitsSeen++;
        if (digitsSeen == digitIndex) {
          // place cursor right AFTER this digit
          return i + 1;
        }
      }
    }
    return formatted.length;
  }

  int _skipSeparatorsLeft(String formatted, int cursor) {
    int c = cursor;
    while (c > 0 && !_isDigit(formatted.codeUnitAt(c - 1))) {
      c--;
    }
    return c;
  }

  bool _isDigit(int codeUnit) => codeUnit >= 48 && codeUnit <= 57;
}

