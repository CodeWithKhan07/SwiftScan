import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:swiftscan/views/scanner/scan_controller.dart';

import '../widgets/scanner_overlay.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shutterController;
  late Animation<double> _shutterAnimation;
  final ScannerController controller = Get.find<ScannerController>();

  @override
  void initState() {
    super.initState();
    _shutterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _shutterAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_shutterController);
    controller.onCaptureStarted = () {
      _shutterController.forward().then((_) => _shutterController.reverse());
    };
  }

  @override
  void dispose() {
    _shutterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraAwesomeBuilder.custom(
            saveConfig: SaveConfig.photo(),
            sensorConfig: SensorConfig.single(
              aspectRatio: CameraAspectRatios.ratio_16_9,
            ),
            builder: (cameraState, preview) {
              cameraState.when(
                onPhotoMode: (state) => controller.updateCameraState(state),
              );
              return Stack(
                children: [
                  const IgnorePointer(child: ScannerOverlay()),
                  cameraState.when(
                    onPhotoMode: (state) => Positioned(
                      bottom: 140,
                      left: 45,
                      right: 45,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSmallBtn(
                            icon: Icons.photo_library_rounded,
                            onTap: () => controller.pickFromGallery(context),
                          ),

                          StreamBuilder<FlashMode>(
                            stream: state.sensorConfig.flashMode$,
                            builder: (context, snapshot) {
                              final flash = snapshot.data ?? FlashMode.none;
                              return _buildSmallBtn(
                                icon: flash == FlashMode.none
                                    ? Icons.flash_off_rounded
                                    : Icons.flash_on_rounded,
                                onTap: () => state.sensorConfig.setFlashMode(
                                  flash == FlashMode.none
                                      ? FlashMode.always
                                      : FlashMode.none,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    onPreparingCamera: (state) =>
                        const Center(child: SpinKitRipple(color: Colors.blue)),
                  ),
                ],
              );
            },
          ),
          IgnorePointer(
            child: FadeTransition(
              opacity: _shutterAnimation,
              child: Container(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBtn({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
