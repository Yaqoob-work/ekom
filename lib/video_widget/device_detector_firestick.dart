// // lib/utils/device_detector.dart
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:flutter/material.dart';

// class DeviceDetectorFirestick {
//   static Future<bool> isFireTV4KCapable() async {
//     DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    
//     // Fire TV specific model detection
//     String model = androidInfo.model.toLowerCase();
    
//     // Fire TV 4K models
//     List<String> fourKModels = [
//       'aftmm',    // Fire TV Stick 4K
//       'aftka',    // Fire TV Stick 4K Max
//       'aftkmst12', // Fire TV Stick 4K Max (newer)
//     ];
    
//     return fourKModels.any((ftvModel) => model.contains(ftvModel));
//   }
  
//   // Navigation helper
//   static Future<void> checkAndNavigate(BuildContext context) async {
//     bool is4KCapable = await isFireTV4KCapable();
    
//     if (is4KCapable) {
//       Navigator.pushNamed(context, '/4k-page');
//     } else {
//       Navigator.pushNamed(context, '/regular-page');
//     }
//   }
  
//   // Just check without navigation
//   static Future<void> checkAndNavigateCustom(
//     BuildContext context, {
//     required String fourKRoute,
//     required String regularRoute,
//   }) async {
//     bool is4KCapable = await isFireTV4KCapable();
    
//     if (is4KCapable) {
//       Navigator.pushNamed(context, fourKRoute);
//     } else {
//       Navigator.pushNamed(context, regularRoute);
//     }
//   }
// }