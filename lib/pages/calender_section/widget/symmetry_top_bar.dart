import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'calendar_style.dart';

/// Figma `Title/Back-icon` — fill 375 × hug 54, 15 px side padding,
/// 1 px bottom border, children laid out `space-between`.
class SymmetryTopBar extends StatelessWidget implements PreferredSizeWidget {
  const SymmetryTopBar({
    super.key,
    this.onMenuTap,
    this.onNotificationTap,
    this.showNotificationBadge = false,
  });

  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;

  /// Green dot on the bell — unread notifications exist.
  final bool showNotificationBadge;

  @override
  Size get preferredSize => Size.fromHeight(54.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54.h,
      padding: EdgeInsets.symmetric(horizontal: 15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.borderGrey, width: 1.h),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ---- menu — Figma vector 16.5 × 11 (material-symbols:menu-rounded)
          InkResponse(
            onTap: onMenuTap,
            radius: 20.r,
            child: SizedBox(
              width: 22.w,
              height: 22.h,
              child: Icon(
                Icons.menu_rounded,
                size: 22.w,
                color: AppColors.defaultTxtGrey,
              ),
            ),
          ),

          // ---- word-mark — logo 31 × 25, 6.62 gap, "Symmetry" 16 / SemiBold
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AppAsset.symmetryLogoImg, width: 31.w, height: 25.h),
              SizedBox(width: 6.62.w),
              Text('Symmetry', style: CalendarStyle.wordMarkText),
            ],
          ),

          // ---- bell — frame 22 × 22, vector 16.5 × 19.25
          InkResponse(
            onTap: onNotificationTap,
            radius: 20.r,
            child: SizedBox(
              width: 22.w,
              height: 22.h,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  SvgPicture.asset(
                    AppAsset.notificationSvgIcon,
                    width: 16.5.w,
                    height: 19.25.h,
                    colorFilter: AppColors.defaultTxtGrey.getSvgColor,
                  ),
                  if (showNotificationBadge)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: AppColors.greenColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.w),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
