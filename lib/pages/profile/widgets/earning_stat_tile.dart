import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Figma earnings stat tile — 107 px card, 10 px radius, `#0000000F` border,
/// SVG icon, label and a grey pill whose value text takes the accent colour.
class EarningStatTile extends StatelessWidget {
  const EarningStatTile({
    super.key,
    required this.svg,
    required this.label,
    required this.value,
    required this.accent,
  });

  final String svg;
  final String label;
  final String value;
  final Color accent;

  static const double height = 107;
  static const double _radius = 10;
  static const double _iconSize = 18;
  static const double _fontSize = 12;
  static const double _labelFontSize = 10;
  static const Color _background = Color(0x33FFFFFF); // #FFFFFF33
  static const Color _border = Color(0x0F000000); // #0000000F
  static const Color _pillBackground = Color(0x2EC0C0C0); // #C0C0C02E
  static const double _pillHeight = 35;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.h,
      padding: EdgeInsets.fromLTRB(6.w, 10.h, 6.w, 6.h),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(_radius.r),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            svg,
            height: _iconSize.h,
            fit: BoxFit.contain,
            colorFilter: accent.getSvgColor,
          ),
          customHeight(6.h),
          Expanded(
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                // Figma: Fira Sans 400 / 10px / 100% #686464
                style: AppTextStyle.normal12style.copyWith(
                  fontSize: _labelFontSize.sp,
                  fontWeight: FontWeight.w400,
                  height: 1,
                  color: AppColors.defaultTxtGrey,
                ),
              ),
            ),
          ),
          customHeight(6.h),
          Container(
            width: double.infinity,
            height: _pillHeight.h,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _pillBackground,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              // Figma: Fira Sans 600 / 12px / 100%
              style: AppTextStyle.bold12style.copyWith(
                fontSize: _fontSize.sp,
                fontWeight: FontWeight.w600,
                height: 1,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
