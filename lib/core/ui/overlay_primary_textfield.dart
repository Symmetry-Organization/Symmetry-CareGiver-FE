import 'package:clinician_app/core/constant/app_colors.dart';
import 'package:clinician_app/core/constant/app_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

typedef SearchItemText<T> = String Function(T item);

class PrimarySearchOverlayField<T> extends StatefulWidget {
  const PrimarySearchOverlayField({
    super.key,
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
    this.prefixIconConstraints,
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
    this.textCapitalization = TextCapitalization.none,

    // ---- overlay search specific ----
    required this.items,
    required this.itemText,
    required this.onItemSelected,
    this.filter,
    this.showWhenEmpty = true,
    this.maxOverlayHeight = 220,
    this.overlayElevation = 8,
    this.clearOnSelect = false,
  });

  // ====== same as PrimaryTextField ======
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
  final bool isShowError;

  // ====== overlay search specific ======
  final List<T> items;
  final SearchItemText<T> itemText;
  final ValueChanged<T> onItemSelected;

  /// custom filter, return true to keep item
  final bool Function(T item, String query)? filter;

  /// show overlay even if query is empty (default true for dropdown behavior)
  final bool showWhenEmpty;

  final double maxOverlayHeight;
  final double overlayElevation;

  /// if true clears field after selection, else fills selected text
  final bool clearOnSelect;

  @override
  State<PrimarySearchOverlayField<T>> createState() =>
      _PrimarySearchOverlayFieldState<T>();
}

class _PrimarySearchOverlayFieldState<T> extends State<PrimarySearchOverlayField<T>> {
  static const double _defaultCursorHeight = 22;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  late final TextEditingController _controller =
      widget.controller ?? TextEditingController(text: widget.initialValue ?? '');
  late final FocusNode _focusNode = widget.focusNode ?? FocusNode();

  List<T> _filtered = [];

  @override
  void initState() {
    super.initState();

    _filtered = widget.items;

    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _removeOverlay();
      } else {
        _reFilterAndToggleOverlay(_controller.text);
      }
    });

    _controller.addListener(() {
      widget.onChanged?.call(_controller.text);
      _reFilterAndToggleOverlay(_controller.text);
    });
  }

  @override
  void didUpdateWidget(covariant PrimarySearchOverlayField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items != widget.items) {
      _reFilterAndToggleOverlay(_controller.text);
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _reFilterAndToggleOverlay(String raw) {
    final enabled = widget.enabled ?? true;
    final readOnly = widget.readonly ?? false;

    if (!enabled || readOnly) {
      _removeOverlay();
      return;
    }

    final query = raw.trim();
    final shouldShow = _focusNode.hasFocus && (widget.showWhenEmpty || query.isNotEmpty);

    if (!shouldShow) {
      _removeOverlay();
      return;
    }

    final qLower = query.toLowerCase();

    _filtered = widget.filter != null
        ? widget.items.where((e) => widget.filter!(e, query)).toList()
        : widget.items.where((e) {
      final text = widget.itemText(e).toLowerCase();
      return widget.showWhenEmpty ? true : text.contains(qLower);
    }).toList();

    if (_filtered.isEmpty) {
      _removeOverlay();
      return;
    }

    _showOrUpdateOverlay();
  }

  void _showOrUpdateOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.markNeedsBuild();
      return;
    }
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  double _fieldWidth() {
    final ro = context.findRenderObject();
    if (ro is RenderBox) return ro.size.width;
    return MediaQuery.of(context).size.width;
  }

  OverlayEntry _createOverlayEntry() {
    return OverlayEntry(
      builder: (ctx) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  FocusScope.of(ctx).unfocus();
                  _removeOverlay();
                },
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              // same height feel like your dropdown button (approx)
              offset: Offset(0, 52.h),
              child: Material(
                elevation: widget.overlayElevation,
                borderRadius: BorderRadius.circular((widget.borderRadius ?? 10).r),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: widget.maxOverlayHeight.h,
                    minWidth: _fieldWidth(),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular((widget.borderRadius ?? 10).r),
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        thickness: 1,
                        color: AppColors.textFieldBorderColor.withOpacity(0.4),
                      ),
                      itemBuilder: (ctx, index) {
                        final item = _filtered[index];
                        final text = widget.itemText(item);

                        return InkWell(
                          onTap: () {
                            if (widget.clearOnSelect) {
                              _controller.clear();
                            } else {
                              _controller.text = text;
                              _controller.selection = TextSelection.collapsed(
                                offset: _controller.text.length,
                              );
                            }

                            widget.onItemSelected(item);
                            _removeOverlay();
                            FocusScope.of(ctx).unfocus();
                          },
                          child: Padding(
                            padding: EdgeInsets.all(12.h),
                            child: Text(
                              text,
                              style: AppTextStyle.normal12style.copyWith(
                                fontWeight: FontWeight.w400,
                                color: AppColors.defaultTxtGrey,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final radius = (widget.borderRadius ?? 10).r;

    // SAME borders as your PrimaryTextField
    final enabledBorder = widget.focusedBorder ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.textFieldBorderColor),
        );

    final focusedBorder = widget.focusedBorder ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: const BorderSide(color: AppColors.textFieldBorderColor),
        );

    final disabledBorder = widget.disabledBorder ??
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(
            color: widget.filledColor ?? Colors.transparent,
            width: 0.0,
          ),
        );

    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        // height: 44.h,
        child: TextFormField(
          scrollPadding: widget.scrollPadding ?? EdgeInsets.zero,
          readOnly: widget.readonly ?? false,
          controller: _controller,
          focusNode: _focusNode,
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.textCapitalization,
          obscureText: widget.obscureText,
          autovalidateMode: widget.autovalidateMode ?? AutovalidateMode.onUserInteraction,
          enabled: widget.enabled,
          validator: widget.validator,
          maxLength: widget.maxLength,
          textInputAction: widget.textInputAction ?? TextInputAction.next,
          inputFormatters: [...(widget.inputFormatters ?? [])],
          buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
          onTap: () {
            widget.onTap?.call();
            // on tap show overlay if focus already
            _reFilterAndToggleOverlay(_controller.text);
          },
          onSaved: widget.onSaved,
          onFieldSubmitted: widget.onFieldSubmitted,
          autocorrect: true,
          autofocus: widget.autofocus,
          textAlign: widget.textAlign,
          cursorColor: widget.style?.color,
            cursorHeight: (widget.style?.fontSize != null && widget.style?.height != null)
              ? widget.style!.fontSize! * widget.style!.height!
              : _defaultCursorHeight,
          obscuringCharacter: widget.obscuringCharacter ?? "●",
          style: widget.style ?? AppTextStyle.normal14style,
          decoration: InputDecoration(
            // prefixIcon: widget.prefixIcon,
            prefixIconConstraints: widget.prefixIconConstraints,
            hoverColor: widget.hoverColor,
            prefixText: widget.prefixText,
            prefixStyle: widget.prefixTextStyle,

            isDense: true,
            contentPadding: widget.contentPadding ??
                 EdgeInsets.symmetric(horizontal: 10.w,
                  vertical: 11.h,),
            enabledBorder:
            widget.focusedBorder ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.circular( 10),
                  borderSide: const BorderSide(
                    color: AppColors.textFieldBorderColor,
                  ),
                ),
            // floatingLabelStyle: floatingLabelStyle,
            focusedBorder:
            widget.focusedBorder ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.circular( 10.r),
                  borderSide: const BorderSide(
                    color: AppColors.textFieldBorderColor,
                  ),
                ),
            border:
            widget.focusedBorder ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.circular( 10.r),
                  borderSide: const BorderSide(
                    color: AppColors.textFieldBorderColor,
                    width: 0.0,
                  ),
                ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular( 10.r),
              borderSide: const BorderSide(color: AppColors.redColor),
            ),
            disabledBorder:
            widget.disabledBorder ??
                OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide(
                    color: Colors.transparent,
                    width: 0.0,
                  ),
                ),
            // enabledBorder: enabledBorder,
            // focusedBorder: focusedBorder,
            // border: enabledBorder,
            // errorBorder: OutlineInputBorder(
            //   borderRadius: BorderRadius.circular(radius),
            //   borderSide: const BorderSide(color: AppColors.redColor),
            // ),
            // disabledBorder: disabledBorder,

            fillColor: widget.filledColor ?? AppColors.textFieldBackGColor,
            filled: widget.filled ?? true,

            hintStyle: widget.hintStyle ??
                AppTextStyle.normal10style.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: AppColors.hintGrey,
                ),
            hintText: widget.hintText ?? "",
            labelStyle: widget.labelStyle,
            labelText: widget.labelText,
            helperText: widget.helperText,
          ),
        ),
      ),
    );
  }
}
