// import 'dart:convert';
// import 'package:http/http.dart' as https;

// // ================= MODELS =================

// class CdnSettings {
//   final bool status;
//   final bool enabled;
//   final List<String> urls;

//   CdnSettings({
//     required this.status,
//     required this.enabled,
//     required this.urls,
//   });

//   factory CdnSettings.fromJson(Map<String, dynamic> json) {
//     return CdnSettings(
//       status: json['status'] ?? false,
//       enabled: json['enabled'] ?? false,
//       urls: json['urls'] != null ? List<String>.from(json['urls']) : [],
//     );
//   }
// }

// class TokenizedUrlResponse {
//   final bool status;
//   final String url;

//   TokenizedUrlResponse({required this.status, required this.url});

//   factory TokenizedUrlResponse.fromJson(Map<String, dynamic> json) {
//     return TokenizedUrlResponse(
//       status: json['status'] ?? false,
//       url: json['url'] ?? '',
//     );
//   }
// }

// // ================= SERVICE CLASS =================

// class SecureUrlService {
//   // Is variable mein settings save rahengi taki baar-baar API call na ho
//   static CdnSettings? _cachedSettings;

//   /// 1. REFRESH SETTINGS (Call inside initState)
//   /// Ye function API call karega aur settings ko cache mein save karega.
//   static Future<void> refreshSettings() async {
//     try {
//       final uri = Uri.parse('https://dash.getplaybox.com/api/v3/getCDNSettings');
//       final response = await https.get(uri);

//       if (response.statusCode == 200) {
//         _cachedSettings = CdnSettings.fromJson(json.decode(response.body));
//         print("✅ SecureUrlService: Settings Refreshed & Cached");
//       } else {
//         print("❌ SecureUrlService: Failed to fetch settings (Status: ${response.statusCode})");
//       }
//     } catch (e) {
//       print("❌ SecureUrlService Error: $e");
//     }
//   }

//   /// 2. GET SECURE URL (Call inside _playContent)
//   /// Ye cache check karega, agar URL match hua to Tokenize karega, nahi to original URL dega.
//   static Future<String> getSecureUrl(String originalUrl) async {
//     // Safety Check: Agar cache null hai (init mein load nahi hua), to abhi load kar lo
//     if (_cachedSettings == null) {
//       await refreshSettings();
//     }

//     // Logic: Enabled hai? + URL List mein hai?
//     if (_cachedSettings != null && _cachedSettings!.enabled) {
//       // Check exact match
//       bool urlMatchFound = _cachedSettings!.urls.contains(originalUrl);

//       // (Optional) Partial match logic ke liye neeche wali line uncomment kar sakte hain
//       // if (!urlMatchFound) { urlMatchFound = _cachedSettings!.urls.any((u) => originalUrl.contains(u)); }

//       if (urlMatchFound) {
//         print("🔒 Secure Match Found! Tokenizing URL...");
//         return await _tokenizeUrl(originalUrl);
//       }
//     }

//     // Agar disabled hai ya match nahi hua, to original URL return karo
//     return originalUrl;
//   }

//   /// Helper: Tokenize API Call
//   static Future<String> _tokenizeUrl(String url) async {
//     try {
//       final uri = Uri.parse('https://dash.getplaybox.com/api/v3/tokenizeUrl');
//       final response = await https.post(
//         uri,
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({"url": url}),
//       );

//       if (response.statusCode == 200) {
//         final data = TokenizedUrlResponse.fromJson(json.decode(response.body));
//         if (data.status && data.url.isNotEmpty) {
//           print("🔑 Token Generated Successfully");
//           return data.url; // Naya Secure URL
//         }
//       }
//     } catch (e) {
//       print("❌ Error tokenizing URL: $e");
//     }
//     return url; // Fail hone par purana URL hi chalega
//   }
// }




// import 'dart:convert';
// import 'package:http/http.dart' as https;

// // ================= MODELS =================

// class CdnSettings {
//   final bool status;
//   final bool enabled;
//   final List<String> urls;

//   CdnSettings({
//     required this.status,
//     required this.enabled,
//     required this.urls,
//   });

//   factory CdnSettings.fromJson(Map<String, dynamic> json) {
//     return CdnSettings(
//       status: json['status'] ?? false,
//       enabled: json['enabled'] ?? false,
//       urls: json['urls'] != null ? List<String>.from(json['urls']) : [],
//     );
//   }
// }

// class TokenizedUrlResponse {
//   final bool status;
//   final String url;

//   TokenizedUrlResponse({required this.status, required this.url});

//   factory TokenizedUrlResponse.fromJson(Map<String, dynamic> json) {
//     return TokenizedUrlResponse(
//       status: json['status'] ?? false,
//       url: json['url'] ?? '',
//     );
//   }
// }

// // ================= SERVICE CLASS =================

// class SecureUrlService {
//   // Is variable mein settings save rahengi
//   static CdnSettings? _cachedSettings;

//   /// 1. REFRESH SETTINGS (TESTING MODE ACTIVE 🚧)
//   /// Ye function abhi API call nahi karega, direct manual settings set karega.
//   static Future<void> refreshSettings() async {
//     // ==========================================================
//     // 🚧 MANUAL OVERRIDE FOR TESTING
//     // ==========================================================
    
//     print("⚠️ DEBUG: Using Manual Settings for Testing");
    
//     _cachedSettings = CdnSettings(
//       status: true,
//       enabled: true, // Humne ise Force Enable kar diya hai
//       urls: [
//         // 👇 IMPORTANT: Jis URL ko aap play kar rahe hain, use yahan paste karein
//         // Agar URL yahan nahi hoga, to wo Tokenize nahi hoga.
//         'ind2.cpbox.net', 
//       ],
//     );

//     // Testing ke liye hum yahi se return kar jayenge
//     return;

//     // ==========================================================
//     // ⬇️ ORIGINAL API CODE (Disabled for Testing)
//     // ==========================================================
//     /*
//     try {
//       final uri = Uri.parse('https://dash.getplaybox.com/api/v3/getCDNSettings');
//       final response = await https.get(uri);

//       if (response.statusCode == 200) {
//         _cachedSettings = CdnSettings.fromJson(json.decode(response.body));
//         print("✅ SecureUrlService: Settings Refreshed & Cached");
//       } else {
//         print("❌ SecureUrlService: Failed to fetch settings (Status: ${response.statusCode})");
//       }
//     } catch (e) {
//       print("❌ SecureUrlService Error: $e");
//     }
//     */
//   }

// /// 2. GET SECURE URL (Updated Logic)
//   static Future<String> getSecureUrl(String originalUrl) async {
//     // Safety Check
//     if (_cachedSettings == null) {
//       await refreshSettings();
//     }

//     print("🔍 Checking URL: $originalUrl"); // Debug Print

//     if (_cachedSettings != null && _cachedSettings!.enabled) {
      
//       // ❌ PURANA LOGIC (Yeh fail ho raha tha kyunki yeh EXACT match dhoondhta hai)
//       // bool urlMatchFound = _cachedSettings!.urls.contains(originalUrl);

//       // ✅ NAYA LOGIC (Yeh check karega ki kya URL mein domain match ho raha hai?)
//       bool urlMatchFound = _cachedSettings!.urls.any((allowedDomain) {
//         return originalUrl.contains(allowedDomain);
//       });

//       if (urlMatchFound) {
//         print("✅ Match Found! Domain is authorized. Tokenizing...");
//         return await _tokenizeUrl(originalUrl);
//       } else {
//         print("⚠️ No Match Found.");
//         print("Allowed List: ${_cachedSettings!.urls}");
//         print("Input URL: $originalUrl");
//       }
//     }

//     return originalUrl;
//   }
// /// Helper: Tokenize API Call (With DEBUG Logs)
//   static Future<String> _tokenizeUrl(String url) async {
//     try {
//       final uri = Uri.parse('https://dash.getplaybox.com/api/v3/tokenizeUrl');
      
//       print("🔄 Calling Tokenize API for: $url");
      
//       final response = await https.post(
//         uri,
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({"url": url}),
//       );

//       print("📥 API Status Code: ${response.statusCode}");
//       print("📥 API Response Body: ${response.body}"); // Yeh line sabse important hai

//       if (response.statusCode == 200) {
//         final data = TokenizedUrlResponse.fromJson(json.decode(response.body));
        
//         // Debugging Internal Status
//         if (!data.status) {
//           print("⚠️ API returned status: FALSE. Reason: Maybe URL is not valid or server issue.");
//         }

//         if (data.status && data.url.isNotEmpty) {
//           print("🔑 Token Generated Successfully: ${data.url}");
//           return data.url; // Naya Secure URL
//         }
//       } else {
//         print("❌ Tokenize API Failed with Status: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("❌ Error inside _tokenizeUrl: $e");
//     }
    
//     print("🔙 Returning Original URL (Tokenization Failed)");
//     return url; // Fail hone par purana URL hi chalega
//   }
// }


// import 'dart:convert';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/main.dart';

// // ================= MODELS =================

// class CdnSettings {
//   final bool status;
//   final bool enabled;
//   final List<String> urls;

//   CdnSettings({
//     required this.status,
//     required this.enabled,
//     required this.urls,
//   });

//   factory CdnSettings.fromJson(Map<String, dynamic> json) {
//     // 1. DOMAINS FIX: Postman mein "domains" hai, isliye hum wahi check karenge
//     var domainsList = json['domains'] as List?;
//     List<String> parsedUrls = [];

//     if (domainsList != null) {
//       // Har object ke andar se 'domain_name' nikal rahe hain
//       parsedUrls = domainsList.map((e) => e['domain_name'].toString()).toList();
//     }

//     return CdnSettings(
//       // 2. SAFE BOOLEAN: Kabhi kabhi true/false string ya 1/0 mein aata hai
//       status: json['status'] == true || json['status'] == 1,
//       enabled: json['enabled'] == true || json['enabled'] == 1,
//       urls: parsedUrls,
//     );
//   }
// }

// class TokenizedUrlResponse {
//   final bool status;
//   final String url;

//   TokenizedUrlResponse({required this.status, required this.url});

//   factory TokenizedUrlResponse.fromJson(Map<String, dynamic> json) {
//     return TokenizedUrlResponse(
//       status: json['status'] == true || json['status'] == 1,
//       url: json['url'] ?? '',
//     );
//   }
// }

// // ================= SERVICE CLASS =================

// class SecureUrlService {
//   static CdnSettings? _cachedSettings;

//   /// Helper for Headers
//   static Map<String, String> get _headers {
//     return {
//       'auth-key': SessionManager.authKey, // 🔑 Auth Key zaroori hai
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//     };
//   }

//   /// 1. REFRESH SETTINGS
//   static Future<void> refreshSettings() async {
//     try {
//       // ✅ URL Update based on Postman
//       final uri = Uri.parse('https://dashboard.cpplayers.com/api/v3/getCDNSettings');
      
//       print("🔄 Fetching CDN Settings...");
//       final response = await https.get(uri, headers: _headers);

//       if (response.statusCode == 200) {
//         // Debugging ke liye response print karein
//         // print("📥 Server Response: ${response.body}");
        
//         _cachedSettings = CdnSettings.fromJson(json.decode(response.body));
        
//         print("✅ CDN Settings Refreshed:");
//         print("   Enabled: ${_cachedSettings?.enabled}"); // Ab ye TRUE aana chahiye
//         print("   Allowed Domains: ${_cachedSettings?.urls}");
//       } else {
//         print("❌ Settings Failed: ${response.statusCode} | ${response.body}");
//       }
//     } catch (e) {
//       print("❌ SecureUrlService Error: $e");
//     }
//   }

//   /// 2. GET SECURE URL
//   static Future<String> getSecureUrl(String originalUrl) async {
//     // Cache check
//     if (_cachedSettings == null) {
//       await refreshSettings();
//     }

//     // Logic Check
//     if (_cachedSettings != null && _cachedSettings!.enabled) {
      
//       // ✅ Partial Match (Domain Check)
//       bool isMatch = _cachedSettings!.urls.any((allowedDomain) {
//         return originalUrl.contains(allowedDomain);
//       });

//       if (isMatch) {
//         print("🔒 Secure Match Found. Requesting Token...");
//         return await _tokenizeUrl(originalUrl);
//       } 
//     }

//     // Match nahi hua to original URL wapas
//     return originalUrl;
//   }

//   /// 3. TOKENIZE API
//   static Future<String> _tokenizeUrl(String url) async {
//     try {
//       // ✅ Tokenize API bhi new domain par honi chahiye
//       final uri = Uri.parse('https://dashboard.cpplayers.com/api/v3/tokenizeUrl');
      
//       final response = await https.post(
//         uri,
//         headers: _headers,
//         body: json.encode({"url": url}),
//       );

//       if (response.statusCode == 200) {
//         final data = TokenizedUrlResponse.fromJson(json.decode(response.body));
        
//         if (data.status && data.url.isNotEmpty) {
//           print("🔑 Token Generated Successfully: ${data.url}");
//           return data.url; 
//         } else {
//            print("⚠️ Tokenize status false: ${response.body}");
//         }
//       } else {
//         print("⚠️ Tokenize API Error: ${response.statusCode} | ${response.body}");
//       }
//     } catch (e) {
//       print("❌ Error inside _tokenizeUrl: $e");
//     }
    
//     return url;
//   }
// }



// import 'dart:convert';
// import 'package:http/http.dart' as https;
// import 'package:mobi_tv_entertainment/main.dart';
// // 👇 Apne project ka sahi path check karein

// // ================= MODELS =================

// class CdnSettings {
//   final bool status;
//   final bool enabled;
//   final List<String> urls;

//   CdnSettings({
//     required this.status,
//     required this.enabled,
//     required this.urls,
//   });

//   factory CdnSettings.fromJson(Map<String, dynamic> json) {
//     // 1. DOMAINS PARSING
//     var domainsList = json['domains'] as List?;
//     List<String> parsedUrls = [];

//     if (domainsList != null) {
//       parsedUrls = domainsList.map((e) => e['domain_name'].toString()).toList();
//     }

//     return CdnSettings(
//       // ✅ FIX: Robust Boolean Parsing using helper function
//       status: _parseBool(json['status']),
//       enabled: _parseBool(json['emabled']),
//       urls: parsedUrls,
//     );
//   }

//   // ✅ Helper function for robust boolean parsing
//   static bool _parseBool(dynamic value) {
//     if (value is bool) return value;
//     if (value is int) return value == 1;
//     if (value is String) {
//       return value.toLowerCase() == 'true' || value == '1';
//     }
//     return false;
//   }
// }

// class TokenizedUrlResponse {
//   final bool status;
//   final String url;

//   TokenizedUrlResponse({required this.status, required this.url});

//   factory TokenizedUrlResponse.fromJson(Map<String, dynamic> json) {
//     return TokenizedUrlResponse(
//       // ✅ FIX: Using helper function for boolean parsing
//       status: _parseBool(json['status']),
//       url: json['url'] ?? '',
//     );
//   }

//   // ✅ Helper function for robust boolean parsing
//   static bool _parseBool(dynamic value) {
//     if (value is bool) return value;
//     if (value is int) return value == 1;
//     if (value is String) {
//       return value.toLowerCase() == 'true' || value == '1';
//     }
//     return false;
//   }
// }

// // ================= SERVICE CLASS =================

// class SecureUrlService {
//   static CdnSettings? _cachedSettings;

//   /// Headers Helper
//   static Map<String, String> get _headers {
//     return {
//       'auth-key': SessionManager.authKey, // 🔑 Auth Key
//       'Content-Type': 'application/json',
//       'Accept': 'application/json',
//     };
//   }

//   /// 1. REFRESH SETTINGS
//   static Future<void> refreshSettings() async {
//     try {
//       final uri = Uri.parse('https://dashboard.cpplayers.com/api/v3/getCDNSettings');
      
//       print("🔄 Fetching CDN Settings...");
//       final response = await https.get(uri, headers: _headers);

//       if (response.statusCode == 200) {
//         // Debugging ke liye Raw Body print karein
//         print("📥 Raw Server Response: ${response.body}");

//         // Decode JSON
//         final decodedJson = json.decode(response.body);
        
//         // 🔍 DEBUG: Type aur Value check karein
//         print("🔍 Type of 'status': ${decodedJson['status'].runtimeType}");
//         print("🔍 Value of 'status': ${decodedJson['status']}");
//         print("🔍 Type of 'enabled': ${decodedJson['enabled'].runtimeType}");
//         print("🔍 Value of 'enabled': ${decodedJson['enabled']}");

//         // Parse settings
//         _cachedSettings = CdnSettings.fromJson(decodedJson);
        
//         print("✅ CDN Settings Parsed Successfully!");
//         print("✅ Status: ${_cachedSettings?.status}");
//         print("✅ Enabled: ${_cachedSettings?.enabled}");
//         print("✅ URLs: ${_cachedSettings?.urls}");
//       } else {
//         print("❌ Settings Failed: ${response.statusCode} | ${response.body}");
//       }
//     } catch (e) {
//       print("❌ SecureUrlService Error: $e");
//     }
//   }

//   /// 2. GET SECURE URL
//   static Future<String> getSecureUrl(String originalUrl) async {
//     // Cache check
//     if (_cachedSettings == null) {
//       print("⚠️ Settings not cached. Fetching...");
//       await refreshSettings();
//     }

//     // Check if Enabled
//     if (_cachedSettings != null && _cachedSettings!.enabled) {
//       print("✅ CDN is ENABLED. Checking domain match...");
      
//       // Domain Check
//       bool isMatch = _cachedSettings!.urls.any((allowedDomain) {
//         return originalUrl.contains(allowedDomain);
//       });

//       if (isMatch) {
//         print("🔒 Domain Match Found! Requesting Token for: $originalUrl");
//         return await _tokenizeUrl(originalUrl);
//       } else {
//         print("⚠️ Domain NOT in allowed list. Using original URL.");
//       }
//     } else {
//       print("⚠️ CDN is DISABLED or Settings NULL. Using original URL.");
//     }

//     return originalUrl;
//   }

//   /// 3. TOKENIZE API
//   static Future<String> _tokenizeUrl(String url) async {
//     try {
//       final uri = Uri.parse('https://dashboard.cpplayers.com/api/v3/generateSecureToken');
      
//       print("🔐 Sending tokenize request...");
//       final response = await https.post(
//         uri,
//         headers: _headers,
//         body: json.encode({"url": url}),
//       );

//       if (response.statusCode == 200) {
//         print("📥 Token Response: ${response.body}");
        
//         final data = TokenizedUrlResponse.fromJson(json.decode(response.body));
        
//         if (data.status && data.url.isNotEmpty) {
//           print("✅ Token Generated Successfully!");
//           print("🔑 SecureURL: ${data.url}");
//           return data.url; 
//         } else {
//           print("⚠️ Token Status is FALSE or URL is empty.");
//           print("📄 Full Response: ${response.body}");
//         }
//       } else {
//         print("❌ Tokenize API Failed: ${response.statusCode}");
//         print("📄 Response Body: ${response.body}");
//       }
//     } catch (e) {
//       print("❌ Error inside _tokenizeUrl: $e");
//     }
    
//     // Fallback to original URL
//     print("⚠️ Returning original URL as fallback.");
//     return url;
//   }
// }



import 'dart:convert';
import 'package:http/http.dart' as https;
import 'package:mobi_tv_entertainment/main.dart';

// ================= MODELS =================

class CdnSettings {
  final bool status;
  final bool enabled;
  final List<String> urls;

  CdnSettings({
    required this.status,
    required this.enabled,
    required this.urls,
  });

  factory CdnSettings.fromJson(Map<String, dynamic> json) {
    // 1. DOMAINS PARSING
    var domainsList = json['domains'] as List?;
    List<String> parsedUrls = [];

    if (domainsList != null) {
      parsedUrls = domainsList.map((e) => e['domain_name'].toString()).toList();
    }

    return CdnSettings(
      // ✅ FIX: Parsing logic
      status: _parseBool(json['status']),
      // ✅ FIX: 'emabled' spelling correct ki gayi hai 'enabled' mein
      enabled: _parseBool(json['emabled']), 
      urls: parsedUrls,
    );
  }

  // ✅ Helper function for robust boolean parsing
  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return false;
  }
}

class TokenizedUrlResponse {
  final bool status;
  final String url;

  TokenizedUrlResponse({required this.status, required this.url});

  factory TokenizedUrlResponse.fromJson(Map<String, dynamic> json) {
    return TokenizedUrlResponse(
      // ✅ FIX: Using helper function for boolean parsing
      status: _parseBool(json['status']),
      url: json['url'] ?? '',
    );
  }

  // ✅ Helper function for robust boolean parsing
  static bool _parseBool(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return false;
  }
}

// ================= SERVICE CLASS =================

class SecureUrlService {
  static CdnSettings? _cachedSettings;

  /// Headers Helper
  static Map<String, String> get _headers {
    return {
      'auth-key': SessionManager.authKey, // 🔑 Auth Key
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  /// 1. REFRESH SETTINGS
  static Future<void> refreshSettings() async {
    try {
      final uri = Uri.parse('https://dashboard.cpplayers.com/api/v3/getCDNSettings');
      
      print("🔄 Fetching CDN Settings...");
      final response = await https.get(uri, headers: _headers);

      if (response.statusCode == 200) {
        // Debugging ke liye Raw Body print karein
        // print("📥 Raw Server Response: ${response.body}");

        // Decode JSON
        final decodedJson = json.decode(response.body);
        
        // Parse settings
        _cachedSettings = CdnSettings.fromJson(decodedJson);
        
        print("✅ CDN Settings Parsed Successfully!");
        print("✅ CDN Enabled Status: ${_cachedSettings?.enabled}");
      } else {
        print("❌ Settings Failed: ${response.statusCode} | ${response.body}");
      }
    } catch (e) {
      print("❌ SecureUrlService Error: $e");
    }
  }

  /// 2. GET SECURE URL
  /// ✅ Updated: Ab ye expirySeconds bhi accept karega
  static Future<String> getSecureUrl(String originalUrl, {int? expirySeconds}) async {
    // Cache check
    if (_cachedSettings == null) {
      print("⚠️ Settings not cached. Fetching...");
      await refreshSettings();
    }

    // Check if Enabled
    if (_cachedSettings != null && _cachedSettings!.enabled) {
      
      // Domain Check
      bool isMatch = _cachedSettings!.urls.any((allowedDomain) {
        return originalUrl.contains(allowedDomain);
      });

      if (isMatch) {
        print("🔒 Domain Match Found! Requesting Token for: $originalUrl with expiry: $expirySeconds");
        // ✅ Tokenize call with expiry
        return await _tokenizeUrl(originalUrl, expirySeconds);
      } else {
        print("⚠️ Domain NOT in allowed list. Using original URL.");
      }
    } else {
      print("⚠️ CDN is DISABLED or Settings NULL. Using original URL.");
    }

    return originalUrl;
  }

  /// 3. TOKENIZE API
  /// ✅ Updated: Expiry param logic added here
  static Future<String> _tokenizeUrl(String url, int? expirySeconds) async {
    try {
      final uri = Uri.parse('https://dashboard.cpplayers.com/api/v3/generateSecureToken');
      
      // ✅ Dynamic Body Construction
      Map<String, dynamic> bodyParams = {
        "url": url,
      };

      // Agar expirySeconds paas kiya gaya hai to hi add karein
      if (expirySeconds != null) {
        bodyParams["token_expiry_seconds"] = expirySeconds;
      }

      print("🔐 Sending tokenize request: $bodyParams");

      final response = await https.post(
        uri,
        headers: _headers,
        body: json.encode(bodyParams),
      );

      if (response.statusCode == 200) {
        // print("📥 Token Response: ${response.body}");
        
        final data = TokenizedUrlResponse.fromJson(json.decode(response.body));
        
        if (data.status && data.url.isNotEmpty) {
          print("✅ Token Generated Successfully!");
          return data.url; 
        } else {
          print("⚠️ Token Status is FALSE or URL is empty.");
        }
      } else {
        print("❌ Tokenize API Failed: ${response.statusCode}");
        print("📄 Response Body: ${response.body}");
      }
    } catch (e) {
      print("❌ Error inside _tokenizeUrl: $e");
    }
    
    // Fallback to original URL
    print("⚠️ Returning original URL as fallback.");
    return url;
  }
}