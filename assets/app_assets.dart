// // 📁 FILE: lib/constants/app_assets.dart
// // ✅ SIMPLE    localImage SOLUTION - BILKUL Image.asset KI TARAH

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

// class AppAssets {
//   // 🎯 SVG LOGO STRING
//   static const String _ekomLogoSvg = '''
// <svg width="640" height="360" viewBox="0 0 640 360" xmlns="http://www.w3.org/2000/svg">
//   <defs>
//     <radialGradient id="mainBg" cx="50%" cy="50%" r="70%">
//       <stop offset="0%" style="stop-color:#0f0f23;stop-opacity:1" />
//       <stop offset="40%" style="stop-color:#1a1a3e;stop-opacity:1" />
//       <stop offset="100%" style="stop-color:#000000;stop-opacity:1" />
//     </radialGradient>
    
//     <linearGradient id="screenGlow" x1="0%" y1="0%" x2="100%" y2="100%">
//       <stop offset="0%" style="stop-color:#00ffff;stop-opacity:0.8" />
//       <stop offset="25%" style="stop-color:#0080ff;stop-opacity:0.6" />
//       <stop offset="75%" style="stop-color:#8000ff;stop-opacity:0.6" />
//       <stop offset="100%" style="stop-color:#ff00ff;stop-opacity:0.8" />
//     </linearGradient>
    
//     <linearGradient id="textGlow" x1="0%" y1="0%" x2="100%" y2="0%">
//       <stop offset="0%" style="stop-color:#00ffff;stop-opacity:1" />
//       <stop offset="25%" style="stop-color:#ffffff;stop-opacity:1" />
//       <stop offset="75%" style="stop-color:#ffffff;stop-opacity:1" />
//       <stop offset="100%" style="stop-color:#ff00ff;stop-opacity:1" />
//     </linearGradient>
    
//     <filter id="outerGlow" x="-20%" y="-20%" width="140%" height="140%">
//       <feGaussianBlur stdDeviation="8" result="coloredBlur"/>
//       <feMerge>
//         <feMergeNode in="coloredBlur"/>
//         <feMergeNode in="SourceGraphic"/>
//       </feMerge>
//     </filter>
    
//     <filter id="innerGlow" x="-10%" y="-10%" width="120%" height="120%">
//       <feGaussianBlur stdDeviation="4" result="coloredBlur"/>
//       <feMerge>
//         <feMergeNode in="coloredBlur"/>
//         <feMergeNode in="SourceGraphic"/>
//       </feMerge>
//     </filter>
    
//     <filter id="textShadow" x="-20%" y="-20%" width="140%" height="140%">
//       <feDropShadow dx="0" dy="0" stdDeviation="6" flood-color="#00ffff" flood-opacity="0.6"/>
//     </filter>
    
//     <pattern id="hexPattern" patternUnits="userSpaceOnUse" width="30" height="26">
//       <polygon points="15,2 25,8 25,18 15,24 5,18 5,8" fill="none" stroke="#00ffff" stroke-width="0.5" opacity="0.2"/>
//     </pattern>
//   </defs>
  
//   <rect width="640" height="360" rx="20" fill="url(#mainBg)"/>
//   <rect width="640" height="360" fill="url(#hexPattern)" opacity="0.3"/>
//   <rect x="10" y="10" width="620" height="340" rx="15" fill="none" stroke="url(#screenGlow)" stroke-width="3" filter="url(#outerGlow)" opacity="0.8"/>
//   <rect x="20" y="20" width="600" height="320" rx="10" fill="none" stroke="#00ffff" stroke-width="2" opacity="0.6"/>
//   <rect x="60" y="80" width="520" height="200" rx="15" fill="url(#screenGlow)" stroke="#00ffff" stroke-width="1" opacity="0.2"/>
  
//   <g transform="translate(80, 120)">
//     <rect x="0" y="0" width="120" height="80" rx="8" fill="#001122" stroke="url(#screenGlow)" stroke-width="2" filter="url(#innerGlow)"/>
//     <rect x="8" y="8" width="104" height="64" rx="4" fill="#000033" opacity="0.8"/>
//     <rect x="8" y="8" width="104" height="64" rx="4" fill="none" stroke="#00ffff" stroke-width="1" opacity="0.6"/>
//     <circle cx="110" cy="15" r="3" fill="#00ff00" opacity="0.8"/>
//   </g>
  
//   <g transform="translate(220, 140)">
//     <path d="M0,20 Q15,5 30,20 Q45,35 60,20" stroke="#00ffff" stroke-width="3" fill="none" opacity="0.7" filter="url(#innerGlow)"/>
//     <path d="M0,20 Q20,0 40,20 Q60,40 80,20" stroke="#0080ff" stroke-width="2" fill="none" opacity="0.5"/>
//     <path d="M0,20 Q25,-5 50,20 Q75,45 100,20" stroke="#8000ff" stroke-width="2" fill="none" opacity="0.4"/>
//   </g>
  
//   <text x="320" y="200" font-family="Arial Black, sans-serif" font-size="64" font-weight="900" text-anchor="middle" fill="url(#textGlow)" filter="url(#textShadow)">EKOM</text>
//   <text x="500" y="200" font-family="Arial, sans-serif" font-size="48" font-weight="bold" fill="#ffffff" opacity="0.9" filter="url(#innerGlow)">TV</text>
//   <line x1="100" y1="230" x2="540" y2="230" stroke="url(#screenGlow)" stroke-width="2" opacity="0.6"/>
//   <text x="320" y="260" font-family="Arial, sans-serif" font-size="18" text-anchor="middle" fill="#00ffff" opacity="0.8" filter="url(#innerGlow)">NEXT GENERATION ENTERTAINMENT</text>
  
//   <g transform="translate(550, 40)">
//     <circle cx="0" cy="0" r="20" fill="none" stroke="#00ffff" stroke-width="2" opacity="0.5"/>
//     <circle cx="0" cy="0" r="12" fill="#00ffff" opacity="0.3"/>
//     <polygon points="-8,-8 8,-8 8,8 -8,8" fill="none" stroke="#ff00ff" stroke-width="1" opacity="0.6"/>
//   </g>
  
//   <g transform="translate(90, 320)">
//     <rect x="-15" y="-15" width="30" height="30" fill="none" stroke="url(#screenGlow)" stroke-width="2" opacity="0.4" rx="5"/>
//   </g>
  
//   <circle cx="150" cy="100" r="2" fill="#00ffff" opacity="0.6"/>
//   <circle cx="480" cy="300" r="1.5" fill="#ff00ff" opacity="0.5"/>
//   <circle cx="200" cy="280" r="2.5" fill="#0080ff" opacity="0.4"/>
// </svg>
// ''';

//   // 🎯 SIMPLE LOGO WIDGET - BILKUL Image.asset KI TARAH USE KARIYE
//   static Widget localImage({
//     double? width,
//     double? height,
//     BoxFit? fit,
//     bool animated = false,
//   }) {
//     // Default values
//     final double logoWidth = width ?? 150.0;
//     final double logoHeight = height ?? (logoWidth * (360 / 640)); // 16:9 ratio
//     final BoxFit logoFit = fit ?? BoxFit.contain;

//     Widget logo = SvgPicture.string(
//       _ekomLogoSvg,
//       width: logoWidth,
//       height: logoHeight,
//       fit: logoFit,
//     );

//     // Animated version
//     if (animated) {
//       return TweenAnimationBuilder<double>(
//         duration: const Duration(milliseconds: 1500),
//         tween: Tween(begin: 0.0, end: 1.0),
//         builder: (context, value, child) {
//           return Transform.scale(
//             scale: 0.8 + (0.2 * value),
//             child: Opacity(
//               opacity: value,
//               child: logo,
//             ),
//           );
//         },
//       );
//     }

//     return logo;
//   }

//   // 🎯 DIFFERENT SIZE OPTIONS - SIMPLE NAMES
//   static Widget logoSmall() => localImage(width: 80);
//   static Widget logoMedium() => localImage(width: 150);
//   static Widget logoLarge() => localImage(width: 250);
//   static Widget logoAnimated([double? width]) =>
//       localImage(width: width ?? 150, animated: true);
// }






// 📁 FILE: lib/constants/app_assets.dart
// ✅ SIMPLE localImage SOLUTION - BILKUL Image.asset KI TARAH

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppAssets {
  // 🎯 SVG LOGO STRING
  static const String _ekomLogoSvg = '''
<svg width="640" height="360" viewBox="0 0 640 360" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <radialGradient id="mainBg" cx="50%" cy="50%" r="70%">
      <stop offset="0%" style="stop-color:#0f0f23;stop-opacity:1" />
      <stop offset="40%" style="stop-color:#1a1a3e;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#000000;stop-opacity:1" />
    </radialGradient>
    
    <linearGradient id="screenGlow" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#00ffff;stop-opacity:0.8" />
      <stop offset="25%" style="stop-color:#0080ff;stop-opacity:0.6" />
      <stop offset="75%" style="stop-color:#8000ff;stop-opacity:0.6" />
      <stop offset="100%" style="stop-color:#ff00ff;stop-opacity:0.8" />
    </linearGradient>
    
    <linearGradient id="textGlow" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" style="stop-color:#00ffff;stop-opacity:1" />
      <stop offset="25%" style="stop-color:#ffffff;stop-opacity:1" />
      <stop offset="75%" style="stop-color:#ffffff;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#ff00ff;stop-opacity:1" />
    </linearGradient>
    
    <filter id="outerGlow" x="-20%" y="-20%" width="140%" height="140%">
      <feGaussianBlur stdDeviation="8" result="coloredBlur"/>
      <feMerge>
        <feMergeNode in="coloredBlur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
    
    <filter id="innerGlow" x="-10%" y="-10%" width="120%" height="120%">
      <feGaussianBlur stdDeviation="4" result="coloredBlur"/>
      <feMerge>
        <feMergeNode in="coloredBlur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
    
    <filter id="textShadow" x="-20%" y="-20%" width="140%" height="140%">
      <feDropShadow dx="0" dy="0" stdDeviation="6" flood-color="#00ffff" flood-opacity="0.6"/>
    </filter>
    
    <pattern id="hexPattern" patternUnits="userSpaceOnUse" width="30" height="26">
      <polygon points="15,2 25,8 25,18 15,24 5,18 5,8" fill="none" stroke="#00ffff" stroke-width="0.5" opacity="0.2"/>
    </pattern>
  </defs>
  
  <rect width="640" height="360" rx="20" fill="url(#mainBg)"/>
  <rect width="640" height="360" fill="url(#hexPattern)" opacity="0.3"/>
  <rect x="10" y="10" width="620" height="340" rx="15" fill="none" stroke="url(#screenGlow)" stroke-width="3" filter="url(#outerGlow)" opacity="0.8"/>
  <rect x="20" y="20" width="600" height="320" rx="10" fill="none" stroke="#00ffff" stroke-width="2" opacity="0.6"/>
  <rect x="60" y="80" width="520" height="200" rx="15" fill="url(#screenGlow)" stroke="#00ffff" stroke-width="1" opacity="0.2"/>
  
  <g transform="translate(80, 120)">
    <rect x="0" y="0" width="120" height="80" rx="8" fill="#001122" stroke="url(#screenGlow)" stroke-width="2" filter="url(#innerGlow)"/>
    <rect x="8" y="8" width="104" height="64" rx="4" fill="#000033" opacity="0.8"/>
    <rect x="8" y="8" width="104" height="64" rx="4" fill="none" stroke="#00ffff" stroke-width="1" opacity="0.6"/>
    <circle cx="110" cy="15" r="3" fill="#00ff00" opacity="0.8"/>
  </g>
  
  <g transform="translate(220, 140)">
    <path d="M0,20 Q15,5 30,20 Q45,35 60,20" stroke="#00ffff" stroke-width="3" fill="none" opacity="0.7" filter="url(#innerGlow)"/>
    <path d="M0,20 Q20,0 40,20 Q60,40 80,20" stroke="#0080ff" stroke-width="2" fill="none" opacity="0.5"/>
    <path d="M0,20 Q25,-5 50,20 Q75,45 100,20" stroke="#8000ff" stroke-width="2" fill="none" opacity="0.4"/>
  </g>
  
  <text x="320" y="200" font-family="Arial Black, sans-serif" font-size="64" font-weight="900" text-anchor="middle" fill="url(#textGlow)" filter="url(#textShadow)">EKOM</text>
  <text x="500" y="200" font-family="Arial, sans-serif" font-size="48" font-weight="bold" fill="#ffffff" opacity="0.9" filter="url(#innerGlow)">TV</text>
  <line x1="100" y1="230" x2="540" y2="230" stroke="url(#screenGlow)" stroke-width="2" opacity="0.6"/>
  <text x="320" y="260" font-family="Arial, sans-serif" font-size="18" text-anchor="middle" fill="#00ffff" opacity="0.8" filter="url(#innerGlow)">NEXT GENERATION ENTERTAINMENT</text>
  
  <g transform="translate(550, 40)">
    <circle cx="0" cy="0" r="20" fill="none" stroke="#00ffff" stroke-width="2" opacity="0.5"/>
    <circle cx="0" cy="0" r="12" fill="#00ffff" opacity="0.3"/>
    <polygon points="-8,-8 8,-8 8,8 -8,8" fill="none" stroke="#ff00ff" stroke-width="1" opacity="0.6"/>
  </g>
  
  <g transform="translate(90, 320)">
    <rect x="-15" y="-15" width="30" height="30" fill="none" stroke="url(#screenGlow)" stroke-width="2" opacity="0.4" rx="5"/>
  </g>
  
  <circle cx="150" cy="100" r="2" fill="#00ffff" opacity="0.6"/>
  <circle cx="480" cy="300" r="1.5" fill="#ff00ff" opacity="0.5"/>
  <circle cx="200" cy="280" r="2.5" fill="#0080ff" opacity="0.4"/>
</svg>
''';

  // 🎯 SIMPLE LOGO WIDGET - BILKUL Image.asset KI TARAH USE KARIYE
  static Widget localImage({
    double? width,
    double? height,
    BoxFit? fit,
    bool animated = false,
  }) {
    // Default values
    final double logoWidth = width ?? 150.0;
    final double logoHeight = height ?? (logoWidth * (360 / 640)); // 16:9 ratio
    final BoxFit logoFit = fit ?? BoxFit.contain;
    
    Widget logo = SvgPicture.string(
      _ekomLogoSvg,
      width: logoWidth,
      height: logoHeight,
      fit: logoFit,
    );
    
    // Animated version
    if (animated) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 1500),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * value),
            child: Opacity(
              opacity: value,
              child: logo,
            ),
          );
        },
      );
    }
    
    return logo;
  }
  
  // 🎯 DIFFERENT SIZE OPTIONS - SIMPLE NAMES
  static Widget logoSmall() => localImage(width: 80);
  static Widget logoMedium() => localImage(width: 150);  
  static Widget logoLarge() => localImage(width: 250);
  static Widget logoAnimated([double? width]) => localImage(width: width ?? 150, animated: true);
}

// 📁 FILE: lib/main.dart (UPDATED)
// ✅ AAPKA MAIN.DART MEIN BILKUL SIMPLE CHANGES
/*
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
// ... your existing imports
import 'constants/app_assets.dart'; // ✅ Add this import

// ✅ SOLUTION: localImage ko global getter banayiye
Widget get localImage => AppAssets.localImage();

// ✅ ALTERNATIVE: Function approach
Widget localImage({double? width, double? height, bool animated = false}) {
  return AppAssets.localImage(
    width: width,
    height: height,
    animated: animated,
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    AuthManager.initialize();
  }

  @override
  Widget build(BuildContext context) {
    // ... your existing variables setup
    
    screenhgt = MediaQuery.of(context).size.height;
    screenwdt = MediaQuery.of(context).size.width;
    // ... rest of your code

    // ✅ AB AAP localImage USE KAR SAKTE HAIN BILKUL Image.asset KI TARAH!

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      routes: {
        // ... your routes
      },
    );
  }
}

// 📝 USAGE EXAMPLES - BILKUL Image.asset KI TARAH!

class UsageExamples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: localImage, // ✅ Simple!
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ✅ PEHLE AISA KARTE THE:
          // Image.asset('assets/logo.png', width: 200),
          
          // ✅ AB AISA KARIYE:
          localImage, // ✅ Default size
          
          // ✅ WITH WIDTH:
          AppAssets.localImage(width: 200),
          
          // ✅ WITH WIDTH & HEIGHT:
          AppAssets.localImage(width: 250, height: 140),
          
          // ✅ ANIMATED:
          AppAssets.localImage(animated: true),
          
          // ✅ DIFFERENT SIZES:
          AppAssets.logoSmall(),    // 80px
          AppAssets.logoMedium(),   // 150px  
          AppAssets.logoLarge(),    // 250px
          AppAssets.logoAnimated(), // Animated
          
          // ✅ IN CONTAINER (PEHLE WAISA):
          Container(
            width: 300,
            height: 200,
            child: localImage, // ✅ Simple!
          ),
          
          // ✅ IN CARD:
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: localImage, // ✅ Simple!
            ),
          ),
          
          // ✅ IN ROW/COLUMN:
          Row(
            children: [
              localImage, // ✅ Simple!
              Text('EKOM TV'),
            ],
          ),
        ],
      ),
      
      // ✅ IN BOTTOM BAR:
      bottomNavigationBar: Container(
        child: localImage, // ✅ Simple!
      ),
    );
  }
}

// 🎯 MIGRATION GUIDE

/*
✅ BEFORE (Image.asset):
Image.asset('assets/logo.png')
Image.asset('assets/logo.png', width: 200)
Image.asset('assets/logo.png', width: 200, height: 100)
Image.asset('assets/logo.png', fit: BoxFit.cover)

✅ AFTER (localImage):
localImage                                          // Default
AppAssets.localImage(width: 200)                   // With width
AppAssets.localImage(width: 200, height: 100)      // With width & height  
AppAssets.localImage(fit: BoxFit.cover)            // With fit
AppAssets.localImage(animated: true)               // Animated

✅ SIMPLE SHORTCUTS:
AppAssets.logoSmall()     // 80px
AppAssets.logoMedium()    // 150px
AppAssets.logoLarge()     // 250px
AppAssets.logoAnimated()  // Animated version
*/

// 🎯 COMPLETE REPLACEMENT EXAMPLES

class MigrationExamples extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // ❌ OLD WAY:
          // Container(
          //   child: Image.asset('assets/logo.png', width: 200),
          // ),
          
          // ✅ NEW WAY (EXACT SAME SIMPLICITY):
          Container(
            child: localImage,
          ),
          
          // ❌ OLD WAY:
          // CircleAvatar(
          //   backgroundImage: AssetImage('assets/logo.png'),
          // ),
          
          // ✅ NEW WAY:
          CircleAvatar(
            child: AppAssets.logoSmall(),
            backgroundColor: Colors.transparent,
          ),
          
          // ❌ OLD WAY:
          // ListTile(
          //   leading: Image.asset('assets/logo.png', width: 50),
          //   title: Text('EKOM TV'),
          // ),
          
          // ✅ NEW WAY:
          ListTile(
            leading: AppAssets.localImage(width: 50),
            title: Text('EKOM TV'),
          ),
        ],
      ),
    );
  }
}

/*
🎯 SUMMARY:

✅ PEHLE:
Image.asset('assets/logo.png')           // Simple
Image.asset('assets/logo.png', width: 200)  // With size

✅ AB:
localImage                               // Simple (exactly same!)
AppAssets.localImage(width: 200)         // With size (exactly same!)

✅ BENEFITS:
- 🎯 Bilkul Image.asset jitna simple
- 📱 Animated SVG logo
- 🚀 High quality vector graphics
- 🎨 Sci-fi professional look
- 📐 Responsive sizing
- ⚡ Fast performance
- 🔄 Easy to maintain

✅ MIGRATION:
1. Import: import 'constants/app_assets.dart';
2. Replace: Image.asset('assets/logo.png') → localImage
3. Done! ✨

Bilkul waisa hi simple hai jaise aap Image.asset use karte the! 🎉
*/
*/