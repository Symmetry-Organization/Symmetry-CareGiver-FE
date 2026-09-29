import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Figma profile grid tile — 15 px radius, 1 px `#00000014` border, icon on
/// top and a centred semi-bold label. Logout uses the tinted red variant.
class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.title,
    this.image,
    this.svg,
    this.onTap,
    this.isDestructive = false,
  }) : assert(image != null || svg != null, 'provide image or svg');

  final String title;

  /// PNG asset (existing profile icons).
  final String? image;

  /// SVG asset (new icons such as Availability).
  final String? svg;
  final VoidCallback? onTap;
  final bool isDestructive;

  static const double _radius = 15;
  static const double _iconSize = 34;
  static const double _fontSize = 12;
  static const double _lineHeight = 1.5;
  static const Color _border = Color(0x14000000); // #00000014
  static const Color _logoutBg = Color(0x0FF6928A); // #F6928A0F
  static const Color _logoutBorder = Color(0xffEBEBEB);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_radius.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isDestructive ? _logoutBg : Colors.white,
          borderRadius: BorderRadius.circular(_radius.r),
          border: Border.all(color: isDestructive ? _logoutBorder : _border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: _iconSize.w,
              height: _iconSize.w,
              child: svg != null
                  ? SvgPicture.asset(svg!, fit: BoxFit.contain)
                  : Image.asset(image!, fit: BoxFit.contain),
            ),
            customHeight(14.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyle.bold12style.copyWith(
                fontSize: _fontSize.sp,
                fontWeight: FontWeight.w600,
                height: _lineHeight,
                color: AppColors.defaultTxtGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
