// import 'dart:io';
//
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
//
// import '../utils/app_utils.dart';
//
// class PermissionService {
//   /// Requests the correct storage/media permissions based on the platform and SDK version.
//   static Future<bool> requestStoragePermission() async {
//     if (Platform.isIOS) {
//       // iOS uses Photos permission
//       PermissionStatus status = await Permission.photos.request();
//       return status.isGranted || status.isLimited;
//     }
//
//     if (Platform.isAndroid) {
//       final deviceInfo = DeviceInfoPlugin();
//       final androidInfo = await deviceInfo.androidInfo;
//
//       // Android 13 (SDK 33) and above
//       if (androidInfo.version.sdkInt >= 33) {
//         Map<Permission, PermissionStatus> statuses = await [
//           Permission.photos,
//           Permission.videos,
//         ].request();
//
//         bool isGranted =
//             statuses[Permission.photos] == PermissionStatus.granted &&
//                 statuses[Permission.videos] == PermissionStatus.granted;
//
//         if (!isGranted) {
//           _showPermissionDeniedToast();
//         }
//         return isGranted;
//       } else {
//         // Android 12 and below
//         PermissionStatus status = await Permission.manageExternalStorage
//             .request();
//         if (!status.isGranted) {
//           _showPermissionDeniedToast();
//         }
//         return status.isGranted;
//       }
//     }
//     return false;
//   }
//
//   /// Helper to request camera permission (common for chat apps)
//   static Future<bool> requestCameraPermission() async {
//     PermissionStatus status = await Permission.camera.request();
//     if (!status.isGranted) {
//       _showPermissionDeniedToast();
//     }
//     return status.isGranted;
//   }
//
//   static void _showPermissionDeniedToast() {
//     AppUtils.showToast(
//       msg: "Permission denied. Please enable it from settings.",
//     );
//   }
//
//   /// Opens app settings if permissions are permanently denied
//   static Future<void> openSettings() async {
//     await openAppSettings();
//   }
// }
