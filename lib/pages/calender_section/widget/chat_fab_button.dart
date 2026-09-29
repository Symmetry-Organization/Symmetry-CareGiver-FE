import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Figma `Ellipse 2354` — 36 × 36 `#008000` disc holding the 21.75 × 20.25
/// white chat glyph.
class ChatFabButton extends StatelessWidget {
  const ChatFabButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.h,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.greenColor,
          shape: BoxShape.circle,
        ),
        child: SvgPicture.asset(
          AppAsset.fabChatSvgIcon,
          width: 21.75.w,
          height: 20.25.h,
          colorFilter: Colors.white.getSvgColor,
        ),
      ),
    );
  }
}
