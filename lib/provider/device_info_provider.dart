// lib/provider/device_info_provider.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceInfoProvider with ChangeNotifier {
  String _deviceName = 'Unknown Device';
  
  // Public getter taaki doosre pages is value ko padh sakein
  String get deviceName => _deviceName;

  /// Yeh function app shuru hote hi device ki jaankari load karega
  Future<void> loadDeviceInfo() async {
    // ✅ DEBUG: Check if function is running
    print("--- 1. loadDeviceInfo FUNCTION STARTED ---");

    final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    String deviceIdentifier = 'Unknown Device'; // Temporary variable

    try {
      if (Platform.isAndroid) {
        final AndroidDeviceInfo androidInfo = await deviceInfoPlugin.androidInfo;

        final String brand = androidInfo.brand.toLowerCase();
        final String model = androidInfo.model;
        final String device = androidInfo.device;

        // ✅ DEBUG: Check the raw data we are getting from the plugin
        print("--- 2. RAW DEVICE DATA ---");
        print("   Brand: '$brand'");
        print("   Model: '$model'");
        print("   Device Codename: '$device'");
        print("--------------------------");

        // Aapka original logic jo sahi kaam kar raha tha
        if (brand == 'amazon') {
          switch (model) {
            case 'AFTKM':
              deviceIdentifier = 'AFTKM : Amazon Fire Stick 4K';
              break;
            case 'AFTKA':
              deviceIdentifier = 'AFTKA : Amazon Fire Stick 4K TEST';
              break;
            case 'AFTSS':
              deviceIdentifier = 'AFTSS : Amazon Fire Stick HD';
              break;
            case 'AFTT': 
              deviceIdentifier = 'AFTT : Amazon Fire Stick ABC';
              break;
            default:
              deviceIdentifier = 'Amazon Fire TV Device';
          }
        } else if (brand == 'google') {
          switch (device) {
            case 'sabrina':
              deviceIdentifier = 'sabrina : Chromecast with Google TV (4K)';
              break;
            case 'boreal':
              deviceIdentifier = 'boreal : Chromecast with Google TV (HD)';
              break;
            default:
              deviceIdentifier = 'Google TV Device';
          }
        } else {
          final bool isTv = androidInfo.systemFeatures.contains('android.software.leanback');
          String name = model.isEmpty ? '${androidInfo.brand} $device' : model;
          deviceIdentifier = isTv ? '$name (TV)' : name;
        }
      } else if (Platform.isIOS) {
        final IosDeviceInfo iosInfo = await deviceInfoPlugin.iosInfo;
        deviceIdentifier = iosInfo.name;
      }
    } catch (e) {
      // ✅ DEBUG: Check for any errors during the process
      print("--- !!! ERROR CAUGHT in DeviceInfoProvider !!! ---");
      print(e.toString());
      print("-------------------------------------------------");
      deviceIdentifier = 'Error getting name';
    }

    _deviceName = deviceIdentifier;
    
    // ✅ DEBUG: Check the final value being set in the provider
    print("--- 3. FINAL DEVICE NAME SET TO: '$_deviceName' ---");

    // UI ko update karne ke liye listeners ko notify karein
    notifyListeners();
  }
}