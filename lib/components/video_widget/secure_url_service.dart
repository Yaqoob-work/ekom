import 'dart:convert';
import 'package:http/http.dart' as https;

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
    return CdnSettings(
      status: json['status'] ?? false,
      enabled: json['enabled'] ?? false,
      urls: json['urls'] != null ? List<String>.from(json['urls']) : [],
    );
  }
}

class TokenizedUrlResponse {
  final bool status;
  final String url;

  TokenizedUrlResponse({required this.status, required this.url});

  factory TokenizedUrlResponse.fromJson(Map<String, dynamic> json) {
    return TokenizedUrlResponse(
      status: json['status'] ?? false,
      url: json['url'] ?? '',
    );
  }
}

// ================= SERVICE CLASS =================

class SecureUrlService {
  // Is variable mein settings save rahengi taki baar-baar API call na ho
  static CdnSettings? _cachedSettings;

  /// 1. REFRESH SETTINGS (Call inside initState)
  /// Ye function API call karega aur settings ko cache mein save karega.
  static Future<void> refreshSettings() async {
    try {
      final uri = Uri.parse('https://dash.getplaybox.com/api/v3/getCDNSettings');
      final response = await https.get(uri);

      if (response.statusCode == 200) {
        _cachedSettings = CdnSettings.fromJson(json.decode(response.body));
        print("✅ SecureUrlService: Settings Refreshed & Cached");
      } else {
        print("❌ SecureUrlService: Failed to fetch settings (Status: ${response.statusCode})");
      }
    } catch (e) {
      print("❌ SecureUrlService Error: $e");
    }
  }

  /// 2. GET SECURE URL (Call inside _playContent)
  /// Ye cache check karega, agar URL match hua to Tokenize karega, nahi to original URL dega.
  static Future<String> getSecureUrl(String originalUrl) async {
    // Safety Check: Agar cache null hai (init mein load nahi hua), to abhi load kar lo
    if (_cachedSettings == null) {
      await refreshSettings();
    }

    // Logic: Enabled hai? + URL List mein hai?
    if (_cachedSettings != null && _cachedSettings!.enabled) {
      // Check exact match
      bool urlMatchFound = _cachedSettings!.urls.contains(originalUrl);

      // (Optional) Partial match logic ke liye neeche wali line uncomment kar sakte hain
      // if (!urlMatchFound) { urlMatchFound = _cachedSettings!.urls.any((u) => originalUrl.contains(u)); }

      if (urlMatchFound) {
        print("🔒 Secure Match Found! Tokenizing URL...");
        return await _tokenizeUrl(originalUrl);
      }
    }

    // Agar disabled hai ya match nahi hua, to original URL return karo
    return originalUrl;
  }

  /// Helper: Tokenize API Call
  static Future<String> _tokenizeUrl(String url) async {
    try {
      final uri = Uri.parse('https://dash.getplaybox.com/api/v3/tokenizeUrl');
      final response = await https.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"url": url}),
      );

      if (response.statusCode == 200) {
        final data = TokenizedUrlResponse.fromJson(json.decode(response.body));
        if (data.status && data.url.isNotEmpty) {
          print("🔑 Token Generated Successfully");
          return data.url; // Naya Secure URL
        }
      }
    } catch (e) {
      print("❌ Error tokenizing URL: $e");
    }
    return url; // Fail hone par purana URL hi chalega
  }
}