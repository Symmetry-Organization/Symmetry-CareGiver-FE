import 'dart:io';

import 'package:camera/camera.dart';
import 'package:clinician_app/core/constant/constant_import.dart';
import 'package:clinician_app/core/ui/buttons/primary_button.dart';
import 'package:clinician_app/core/ui/buttons/primary_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Camera screen for scanning a document page.
///
/// Live preview with framing brackets and a Scan button; once a shot is taken
/// it switches to a still preview offering Retake or Upload. Pops with the
/// captured [File] when the user accepts it, or null if they back out.
class DocumentScanScreen extends StatefulWidget {
  const DocumentScanScreen({super.key, this.actionLabel = "Scan"});

  /// Label on the shutter button — "Scan" for documents, "Capture" for photos.
  final String actionLabel;

  @override
  State<DocumentScanScreen> createState() => _DocumentScanScreenState();
}

class _DocumentScanScreenState extends State<DocumentScanScreen> {
  CameraController? _controller;
  Future<void>? _initialization;
  File? _captured;
  bool _isCapturing = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _initialization = _setUpCamera();
  }

  Future<void> _setUpCamera() async {
    final List<CameraDescription> cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw CameraException('no_camera', 'No camera available on this device.');
    }
    final CameraDescription back = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    final CameraController controller = CameraController(
      back,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await controller.initialize();
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() => _controller = controller);
  }

  Future<void> _capture() async {
    final CameraController? controller = _controller;
    if (controller == null || _isCapturing) return;
    setState(() => _isCapturing = true);
    try {
      final XFile shot = await controller.takePicture();
      if (!mounted) return;
      setState(() => _captured = File(shot.path));
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.description ?? 'Could not capture the photo.');
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _captured != null ? _buildCapturedPreview() : _buildCameraView(),
    );
  }

  Widget _buildCameraView() {
    return FutureBuilder<void>(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError || _error.isNotEmpty) {
          return _buildError(
            _error.isNotEmpty ? _error : '${snapshot.error}',
          );
        }
        final CameraController? controller = _controller;
        if (controller == null || !controller.value.isInitialized) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryAppColor),
          );
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            _FullScreenCameraPreview(controller: controller),
            CustomPaint(painter: _ScanFramePainter(), size: Size.infinite),
            SafeArea(
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
                  onPressed: () => Get.back<File>(),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 92.h),
                child: _ScanButton(
                  label: widget.actionLabel,
                  isBusy: _isCapturing,
                  onTap: _capture,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCapturedPreview() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Image.file(_captured!, fit: BoxFit.contain),
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                Expanded(
                  child: PrimaryOutlinedButton(
                    height: 44.h,
                    text: "Retake",
                    borderWidth: 1.5,
                    radius: 8,
                    textStyle: AppTextStyle.normal12style.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryAppColor,
                    ),
                    buttonColor: AppColors.primaryAppColor,
                    onPressed: () => setState(() => _captured = null),
                  ),
                ),
                customWidth(16.w),
                Expanded(
                  child: PrimaryButton(
                    height: 44.h,
                    padding: EdgeInsets.zero,
                    borderRadius: 8,
                    label: "Upload",
                    labelStyle: AppTextStyle.normal12style.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    onTap: () => Get.back<File>(result: _captured),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle.normal12style.copyWith(color: Colors.white),
            ),
            customHeight(16.h),
            PrimaryOutlinedButton(
              height: 40.h,
              text: "Close",
              radius: 8,
              textStyle: AppTextStyle.normal12style.copyWith(
                fontSize: 14.sp,
                color: Colors.white,
              ),
              buttonColor: Colors.white,
              onPressed: () => Get.back<File>(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fills the screen with the preview instead of letter-boxing it, by scaling
/// the camera's own aspect ratio up to cover the viewport.
class _FullScreenCameraPreview extends StatelessWidget {
  const _FullScreenCameraPreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.of(context).size;
    // The controller reports its ratio in landscape terms, so multiplying by
    // the screen's portrait ratio gives the factor that makes the preview
    // cover the viewport rather than letter-box inside it.
    double scale = screen.aspectRatio * controller.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;
    return ClipRect(
      child: Transform.scale(
        scale: scale,
        child: Center(child: CameraPreview(controller)),
      ),
    );
  }
}

class _ScanButton extends StatelessWidget {
  const _ScanButton({
    required this.onTap,
    required this.isBusy,
    required this.label,
  });

  final VoidCallback onTap;
  final bool isBusy;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isBusy ? null : onTap,
      child: Container(
        height: 55.h,
        padding: EdgeInsets.symmetric(horizontal: 44.w),
        decoration: BoxDecoration(
          color: AppColors.visitActionBlue,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Color(0x40000000),
              offset: Offset(0, 3.33),
              blurRadius: 3.33,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isBusy)
              SizedBox(
                height: 22.h,
                width: 22.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              Icon(
                Icons.crop_free,
                color: Colors.white,
                size: 26.sp,
              ),
            customWidth(14.w),
            Text(
              label,
              style: AppTextStyle.regular16style.copyWith(
                fontWeight: FontWeight.w600,
                height: 36 / 16,
                letterSpacing: 0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The four white framing brackets the document is lined up inside.
class _ScanFramePainter extends CustomPainter {
  static const double _inset = 22;
  static const double _armLength = 90;
  static const double _topOffset = 60;
  static const double _bottomOffset = 80;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    final double left = _inset;
    final double right = size.width - _inset;
    final double top = _topOffset;
    final double bottom = size.height - _bottomOffset;

    void corner(Offset origin, double dx, double dy) {
      canvas.drawLine(origin, origin.translate(_armLength * dx, 0), paint);
      canvas.drawLine(origin, origin.translate(0, _armLength * dy), paint);
    }

    corner(Offset(left, top), 1, 1);
    corner(Offset(right, top), -1, 1);
    corner(Offset(left, bottom), 1, -1);
    corner(Offset(right, bottom), -1, -1);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
