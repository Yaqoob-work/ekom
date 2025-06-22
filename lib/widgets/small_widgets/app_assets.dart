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





/*
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





// 📁 FILE: lib/constants/app_assets.dart
// ✅ UPDATED WITH COLOR PARAMETERS

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

  // 🎯 UPDATED LOGO WIDGET WITH COLOR CUSTOMIZATION
  static Widget localImage({
    double? width,
    double? height,
    BoxFit? fit,
    bool animated = false,
    Color? textColor,        // ✅ Text ka color
    Color? backgroundColor,  // ✅ Background ka color
    Color? glowColor,       // ✅ Glow effect ka color
    double? opacity,        // ✅ Logo ki opacity
  }) {
    // Default values
    final double logoWidth = width ?? 150.0;
    final double logoHeight = height ?? (logoWidth * (360 / 640)); // 16:9 ratio
    final BoxFit logoFit = fit ?? BoxFit.contain;
    
    // Default colors (agar kuch specify nahi kiya)
    final String finalTextColor = textColor != null 
        ? '#${textColor.value.toRadixString(16).substring(2)}'
        : 'ffffff';
    final String finalBgColor = backgroundColor != null
        ? '#${backgroundColor.value.toRadixString(16).substring(2)}'
        : '0f0f23';
    final String finalGlowColor = glowColor != null
        ? '#${glowColor.value.toRadixString(16).substring(2)}'
        : '00ffff';
    final double finalOpacity = opacity ?? 1.0;

    // Custom SVG with dynamic colors
    String customSvg = '''
<svg width="640" height="360" viewBox="0 0 640 360" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <radialGradient id="mainBg" cx="50%" cy="50%" r="70%">
      <stop offset="0%" style="stop-color:#$finalBgColor;stop-opacity:1" />
      <stop offset="40%" style="stop-color:#${_adjustColor(finalBgColor, 20)};stop-opacity:1" />
      <stop offset="100%" style="stop-color:#000000;stop-opacity:1" />
    </radialGradient>
    
    <linearGradient id="screenGlow" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#$finalGlowColor;stop-opacity:0.8" />
      <stop offset="25%" style="stop-color:#${_adjustColor(finalGlowColor, -30)};stop-opacity:0.6" />
      <stop offset="75%" style="stop-color:#${_adjustColor(finalGlowColor, 40)};stop-opacity:0.6" />
      <stop offset="100%" style="stop-color:#${_adjustColor(finalGlowColor, 80)};stop-opacity:0.8" />
    </linearGradient>
    
    <linearGradient id="textGlow" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" style="stop-color:#$finalGlowColor;stop-opacity:1" />
      <stop offset="25%" style="stop-color:#$finalTextColor;stop-opacity:1" />
      <stop offset="75%" style="stop-color:#$finalTextColor;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#$finalGlowColor;stop-opacity:1" />
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
      <feDropShadow dx="0" dy="0" stdDeviation="6" flood-color="#$finalGlowColor" flood-opacity="0.6"/>
    </filter>
    
    <pattern id="hexPattern" patternUnits="userSpaceOnUse" width="30" height="26">
      <polygon points="15,2 25,8 25,18 15,24 5,18 5,8" fill="none" stroke="#$finalGlowColor" stroke-width="0.5" opacity="0.2"/>
    </pattern>
  </defs>
  
  <rect width="640" height="360" rx="20" fill="url(#mainBg)"/>
  <rect width="640" height="360" fill="url(#hexPattern)" opacity="0.3"/>
  <rect x="10" y="10" width="620" height="340" rx="15" fill="none" stroke="url(#screenGlow)" stroke-width="3" filter="url(#outerGlow)" opacity="0.8"/>
  <rect x="20" y="20" width="600" height="320" rx="10" fill="none" stroke="#$finalGlowColor" stroke-width="2" opacity="0.6"/>
  <rect x="60" y="80" width="520" height="200" rx="15" fill="url(#screenGlow)" stroke="#$finalGlowColor" stroke-width="1" opacity="0.2"/>
  
  <g transform="translate(80, 120)">
    <rect x="0" y="0" width="120" height="80" rx="8" fill="#001122" stroke="url(#screenGlow)" stroke-width="2" filter="url(#innerGlow)"/>
    <rect x="8" y="8" width="104" height="64" rx="4" fill="#000033" opacity="0.8"/>
    <rect x="8" y="8" width="104" height="64" rx="4" fill="none" stroke="#$finalGlowColor" stroke-width="1" opacity="0.6"/>
    <circle cx="110" cy="15" r="3" fill="#00ff00" opacity="0.8"/>
  </g>
  
  <g transform="translate(220, 140)">
    <path d="M0,20 Q15,5 30,20 Q45,35 60,20" stroke="#$finalGlowColor" stroke-width="3" fill="none" opacity="0.7" filter="url(#innerGlow)"/>
    <path d="M0,20 Q20,0 40,20 Q60,40 80,20" stroke="#${_adjustColor(finalGlowColor, -30)}" stroke-width="2" fill="none" opacity="0.5"/>
    <path d="M0,20 Q25,-5 50,20 Q75,45 100,20" stroke="#${_adjustColor(finalGlowColor, 40)}" stroke-width="2" fill="none" opacity="0.4"/>
  </g>
  
  <text x="320" y="200" font-family="Arial Black, sans-serif" font-size="64" font-weight="900" text-anchor="middle" fill="url(#textGlow)" filter="url(#textShadow)">EKOM</text>
  <text x="500" y="200" font-family="Arial, sans-serif" font-size="48" font-weight="bold" fill="#$finalTextColor" opacity="0.9" filter="url(#innerGlow)">TV</text>
  <line x1="100" y1="230" x2="540" y2="230" stroke="url(#screenGlow)" stroke-width="2" opacity="0.6"/>
  <text x="320" y="260" font-family="Arial, sans-serif" font-size="18" text-anchor="middle" fill="#$finalGlowColor" opacity="0.8" filter="url(#innerGlow)">NEXT GENERATION ENTERTAINMENT</text>
  
  <g transform="translate(550, 40)">
    <circle cx="0" cy="0" r="20" fill="none" stroke="#$finalGlowColor" stroke-width="2" opacity="0.5"/>
    <circle cx="0" cy="0" r="12" fill="#$finalGlowColor" opacity="0.3"/>
    <polygon points="-8,-8 8,-8 8,8 -8,8" fill="none" stroke="#${_adjustColor(finalGlowColor, 80)}" stroke-width="1" opacity="0.6"/>
  </g>
  
  <g transform="translate(90, 320)">
    <rect x="-15" y="-15" width="30" height="30" fill="none" stroke="url(#screenGlow)" stroke-width="2" opacity="0.4" rx="5"/>
  </g>
  
  <circle cx="150" cy="100" r="2" fill="#$finalGlowColor" opacity="0.6"/>
  <circle cx="480" cy="300" r="1.5" fill="#${_adjustColor(finalGlowColor, 80)}" opacity="0.5"/>
  <circle cx="200" cy="280" r="2.5" fill="#${_adjustColor(finalGlowColor, -30)}" opacity="0.4"/>
</svg>
''';

    Widget logo = Opacity(
      opacity: finalOpacity,
      child: SvgPicture.string(
        customSvg,
        width: logoWidth,
        height: logoHeight,
        fit: logoFit,
      ),
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
              opacity: value * finalOpacity,
              child: SvgPicture.string(
                customSvg,
                width: logoWidth,
                height: logoHeight,
                fit: logoFit,
              ),
            ),
          );
        },
      );
    }

    return logo;
  }
  
  // 🎨 COLOR HELPER FUNCTION
  static String _adjustColor(String hexColor, int adjustment) {
    try {
      int colorValue = int.parse(hexColor, radix: 16);
      int r = (colorValue >> 16) & 0xFF;
      int g = (colorValue >> 8) & 0xFF;
      int b = colorValue & 0xFF;
      
      r = (r + adjustment).clamp(0, 255);
      g = (g + adjustment).clamp(0, 255);  
      b = (b + adjustment).clamp(0, 255);
      
      return ((r << 16) | (g << 8) | b).toRadixString(16).padLeft(6, '0');
    } catch (e) {
      return hexColor; // Return original if error
    }
  }
  
  // 🎯 DIFFERENT SIZE OPTIONS - SIMPLE NAMES  
  static Widget logoSmall() => localImage(width: 80);
  static Widget logoMedium() => localImage(width: 150);  
  static Widget logoLarge() => localImage(width: 250);
  static Widget logoAnimated([double? width]) => localImage(width: width ?? 150, animated: true);
  
  // 🎨 COLOR VARIATIONS - PREDEFINED THEMES
  
  // Light theme logo
  static Widget logoLight([double? width]) => localImage(
    width: width ?? 150,
    textColor: Colors.black87,
    backgroundColor: Colors.grey[100],
    glowColor: Colors.blue[300],
    opacity: 0.9,
  );
  
  // Dark theme logo (default)
  static Widget logoDark([double? width]) => localImage(width: width ?? 150);
  
  // Gold theme logo  
  static Widget logoGold([double? width]) => localImage(
    width: width ?? 150,
    textColor: Colors.amber[100],
    backgroundColor: Color(0xFF1a1a1a),
    glowColor: Colors.amber,
  );
  
  // Red theme logo
  static Widget logoRed([double? width]) => localImage(
    width: width ?? 150,
    textColor: Colors.red[100],
    backgroundColor: Color(0xFF2a0a0a),
    glowColor: Colors.red,
  );
  
  // Green theme logo
  static Widget logoGreen([double? width]) => localImage(
    width: width ?? 150,
    textColor: Colors.green[100],
    backgroundColor: Color(0xFF0a2a0a),
    glowColor: Colors.green,
  );
  
  // Purple theme logo
  static Widget logoPurple([double? width]) => localImage(
    width: width ?? 150,
    textColor: Colors.purple[100],
    backgroundColor: Color(0xFF1a0a2a),
    glowColor: Colors.purple,
  );
  
  // Minimal/Subtle logo (very light)
  static Widget logoMinimal([double? width]) => localImage(
    width: width ?? 150,
    textColor: Colors.grey[600],
    backgroundColor: Colors.grey[50],
    glowColor: Colors.grey[400],
    opacity: 0.7,
  );
  
  // High contrast logo
  static Widget logoHighContrast([double? width]) => localImage(
    width: width ?? 150,
    textColor: Colors.white,
    backgroundColor: Colors.black,
    glowColor: Colors.white,
  );
}

/*
🎯 USAGE EXAMPLES:

✅ BASIC USAGE:
AppAssets.localImage()
AppAssets.localImage(width: 200)

✅ WITH CUSTOM COLORS:
AppAssets.localImage(
  width: 200,
  textColor: Colors.white,        // ✅ Now available
  backgroundColor: Colors.black,  // ✅ Now available
  glowColor: Colors.cyan,        // ✅ Now available
  opacity: 0.8,                  // ✅ Now available
  animated: true,
)

✅ FOCUS-BASED COLORS:
AppAssets.localImage(
  height: screenhgt * 0.05,
  width: (screenhgt * 0.05) * (640 / 360),
  glowColor: focusNode.hasFocus ? randomColor : Colors.cyan,
  opacity: focusNode.hasFocus ? 1.0 : 0.8,
  animated: focusNode.hasFocus,
)

✅ PREDEFINED THEMES:
AppAssets.logoLight()           // Light version
AppAssets.logoGold()            // Gold version
AppAssets.logoRed()             // Red version
AppAssets.logoMinimal()         // Subtle version

✅ ALL PARAMETERS AVAILABLE:
- width: double?
- height: double?
- fit: BoxFit?
- animated: bool
- textColor: Color?       ✅ NEW
- backgroundColor: Color? ✅ NEW
- glowColor: Color?      ✅ NEW
- opacity: double?       ✅ NEW
*/




