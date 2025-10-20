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





// // 📁 FILE: lib/constants/app_assets.dart
// // ✅ UPDATED WITH COLOR PARAMETERS

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

//   // 🎯 UPDATED LOGO WIDGET WITH COLOR CUSTOMIZATION
//   static Widget localImage({
//     double? width,
//     double? height,
//     BoxFit? fit,
//     bool animated = false,
//     Color? textColor,        // ✅ Text ka color
//     Color? backgroundColor,  // ✅ Background ka color
//     Color? glowColor,       // ✅ Glow effect ka color
//     double? opacity,        // ✅ Logo ki opacity
//   }) {
//     // Default values
//     final double logoWidth = width ?? 150.0;
//     final double logoHeight = height ?? (logoWidth * (360 / 640)); // 16:9 ratio
//     final BoxFit logoFit = fit ?? BoxFit.contain;
    
//     // Default colors (agar kuch specify nahi kiya)
//     final String finalTextColor = textColor != null 
//         ? '#${textColor.value.toRadixString(16).substring(2)}'
//         : 'ffffff';
//     final String finalBgColor = backgroundColor != null
//         ? '#${backgroundColor.value.toRadixString(16).substring(2)}'
//         : '0f0f23';
//     final String finalGlowColor = glowColor != null
//         ? '#${glowColor.value.toRadixString(16).substring(2)}'
//         : '00ffff';
//     final double finalOpacity = opacity ?? 1.0;

//     // Custom SVG with dynamic colors
//     String customSvg = '''
// <svg width="640" height="360" viewBox="0 0 640 360" xmlns="http://www.w3.org/2000/svg">
//   <defs>
//     <radialGradient id="mainBg" cx="50%" cy="50%" r="70%">
//       <stop offset="0%" style="stop-color:#$finalBgColor;stop-opacity:1" />
//       <stop offset="40%" style="stop-color:#${_adjustColor(finalBgColor, 20)};stop-opacity:1" />
//       <stop offset="100%" style="stop-color:#000000;stop-opacity:1" />
//     </radialGradient>
    
//     <linearGradient id="screenGlow" x1="0%" y1="0%" x2="100%" y2="100%">
//       <stop offset="0%" style="stop-color:#$finalGlowColor;stop-opacity:0.8" />
//       <stop offset="25%" style="stop-color:#${_adjustColor(finalGlowColor, -30)};stop-opacity:0.6" />
//       <stop offset="75%" style="stop-color:#${_adjustColor(finalGlowColor, 40)};stop-opacity:0.6" />
//       <stop offset="100%" style="stop-color:#${_adjustColor(finalGlowColor, 80)};stop-opacity:0.8" />
//     </linearGradient>
    
//     <linearGradient id="textGlow" x1="0%" y1="0%" x2="100%" y2="0%">
//       <stop offset="0%" style="stop-color:#$finalGlowColor;stop-opacity:1" />
//       <stop offset="25%" style="stop-color:#$finalTextColor;stop-opacity:1" />
//       <stop offset="75%" style="stop-color:#$finalTextColor;stop-opacity:1" />
//       <stop offset="100%" style="stop-color:#$finalGlowColor;stop-opacity:1" />
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
//       <feDropShadow dx="0" dy="0" stdDeviation="6" flood-color="#$finalGlowColor" flood-opacity="0.6"/>
//     </filter>
    
//     <pattern id="hexPattern" patternUnits="userSpaceOnUse" width="30" height="26">
//       <polygon points="15,2 25,8 25,18 15,24 5,18 5,8" fill="none" stroke="#$finalGlowColor" stroke-width="0.5" opacity="0.2"/>
//     </pattern>
//   </defs>
  
//   <rect width="640" height="360" rx="20" fill="url(#mainBg)"/>
//   <rect width="640" height="360" fill="url(#hexPattern)" opacity="0.3"/>
//   <rect x="10" y="10" width="620" height="340" rx="15" fill="none" stroke="url(#screenGlow)" stroke-width="3" filter="url(#outerGlow)" opacity="0.8"/>
//   <rect x="20" y="20" width="600" height="320" rx="10" fill="none" stroke="#$finalGlowColor" stroke-width="2" opacity="0.6"/>
//   <rect x="60" y="80" width="520" height="200" rx="15" fill="url(#screenGlow)" stroke="#$finalGlowColor" stroke-width="1" opacity="0.2"/>
  
//   <g transform="translate(80, 120)">
//     <rect x="0" y="0" width="120" height="80" rx="8" fill="#001122" stroke="url(#screenGlow)" stroke-width="2" filter="url(#innerGlow)"/>
//     <rect x="8" y="8" width="104" height="64" rx="4" fill="#000033" opacity="0.8"/>
//     <rect x="8" y="8" width="104" height="64" rx="4" fill="none" stroke="#$finalGlowColor" stroke-width="1" opacity="0.6"/>
//     <circle cx="110" cy="15" r="3" fill="#00ff00" opacity="0.8"/>
//   </g>
  
//   <g transform="translate(220, 140)">
//     <path d="M0,20 Q15,5 30,20 Q45,35 60,20" stroke="#$finalGlowColor" stroke-width="3" fill="none" opacity="0.7" filter="url(#innerGlow)"/>
//     <path d="M0,20 Q20,0 40,20 Q60,40 80,20" stroke="#${_adjustColor(finalGlowColor, -30)}" stroke-width="2" fill="none" opacity="0.5"/>
//     <path d="M0,20 Q25,-5 50,20 Q75,45 100,20" stroke="#${_adjustColor(finalGlowColor, 40)}" stroke-width="2" fill="none" opacity="0.4"/>
//   </g>
  
//   <text x="320" y="200" font-family="Arial Black, sans-serif" font-size="64" font-weight="900" text-anchor="middle" fill="url(#textGlow)" filter="url(#textShadow)">EKOM</text>
//   <text x="500" y="200" font-family="Arial, sans-serif" font-size="48" font-weight="bold" fill="#$finalTextColor" opacity="0.9" filter="url(#innerGlow)">TV</text>
//   <line x1="100" y1="230" x2="540" y2="230" stroke="url(#screenGlow)" stroke-width="2" opacity="0.6"/>
//   <text x="320" y="260" font-family="Arial, sans-serif" font-size="18" text-anchor="middle" fill="#$finalGlowColor" opacity="0.8" filter="url(#innerGlow)">NEXT GENERATION ENTERTAINMENT</text>
  
//   <g transform="translate(550, 40)">
//     <circle cx="0" cy="0" r="20" fill="none" stroke="#$finalGlowColor" stroke-width="2" opacity="0.5"/>
//     <circle cx="0" cy="0" r="12" fill="#$finalGlowColor" opacity="0.3"/>
//     <polygon points="-8,-8 8,-8 8,8 -8,8" fill="none" stroke="#${_adjustColor(finalGlowColor, 80)}" stroke-width="1" opacity="0.6"/>
//   </g>
  
//   <g transform="translate(90, 320)">
//     <rect x="-15" y="-15" width="30" height="30" fill="none" stroke="url(#screenGlow)" stroke-width="2" opacity="0.4" rx="5"/>
//   </g>
  
//   <circle cx="150" cy="100" r="2" fill="#$finalGlowColor" opacity="0.6"/>
//   <circle cx="480" cy="300" r="1.5" fill="#${_adjustColor(finalGlowColor, 80)}" opacity="0.5"/>
//   <circle cx="200" cy="280" r="2.5" fill="#${_adjustColor(finalGlowColor, -30)}" opacity="0.4"/>
// </svg>
// ''';

//     Widget logo = Opacity(
//       opacity: finalOpacity,
//       child: SvgPicture.string(
//         customSvg,
//         width: logoWidth,
//         height: logoHeight,
//         fit: logoFit,
//       ),
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
//               opacity: value * finalOpacity,
//               child: SvgPicture.string(
//                 customSvg,
//                 width: logoWidth,
//                 height: logoHeight,
//                 fit: logoFit,
//               ),
//             ),
//           );
//         },
//       );
//     }

//     return logo;
//   }
  
//   // 🎨 COLOR HELPER FUNCTION
//   static String _adjustColor(String hexColor, int adjustment) {
//     try {
//       int colorValue = int.parse(hexColor, radix: 16);
//       int r = (colorValue >> 16) & 0xFF;
//       int g = (colorValue >> 8) & 0xFF;
//       int b = colorValue & 0xFF;
      
//       r = (r + adjustment).clamp(0, 255);
//       g = (g + adjustment).clamp(0, 255);  
//       b = (b + adjustment).clamp(0, 255);
      
//       return ((r << 16) | (g << 8) | b).toRadixString(16).padLeft(6, '0');
//     } catch (e) {
//       return hexColor; // Return original if error
//     }
//   }
  
//   // 🎯 DIFFERENT SIZE OPTIONS - SIMPLE NAMES  
//   static Widget logoSmall() => localImage(width: 80);
//   static Widget logoMedium() => localImage(width: 150);  
//   static Widget logoLarge() => localImage(width: 250);
//   static Widget logoAnimated([double? width]) => localImage(width: width ?? 150, animated: true);
  
//   // 🎨 COLOR VARIATIONS - PREDEFINED THEMES
  
//   // Light theme logo
//   static Widget logoLight([double? width]) => localImage(
//     width: width ?? 150,
//     textColor: Colors.black87,
//     backgroundColor: Colors.grey[100],
//     glowColor: Colors.blue[300],
//     opacity: 0.9,
//   );
  
//   // Dark theme logo (default)
//   static Widget logoDark([double? width]) => localImage(width: width ?? 150);
  
//   // Gold theme logo  
//   static Widget logoGold([double? width]) => localImage(
//     width: width ?? 150,
//     textColor: Colors.amber[100],
//     backgroundColor: Color(0xFF1a1a1a),
//     glowColor: Colors.amber,
//   );
  
//   // Red theme logo
//   static Widget logoRed([double? width]) => localImage(
//     width: width ?? 150,
//     textColor: Colors.red[100],
//     backgroundColor: Color(0xFF2a0a0a),
//     glowColor: Colors.red,
//   );
  
//   // Green theme logo
//   static Widget logoGreen([double? width]) => localImage(
//     width: width ?? 150,
//     textColor: Colors.green[100],
//     backgroundColor: Color(0xFF0a2a0a),
//     glowColor: Colors.green,
//   );
  
//   // Purple theme logo
//   static Widget logoPurple([double? width]) => localImage(
//     width: width ?? 150,
//     textColor: Colors.purple[100],
//     backgroundColor: Color(0xFF1a0a2a),
//     glowColor: Colors.purple,
//   );
  
//   // Minimal/Subtle logo (very light)
//   static Widget logoMinimal([double? width]) => localImage(
//     width: width ?? 150,
//     textColor: Colors.grey[600],
//     backgroundColor: Colors.grey[50],
//     glowColor: Colors.grey[400],
//     opacity: 0.7,
//   );
  
//   // High contrast logo
//   static Widget logoHighContrast([double? width]) => localImage(
//     width: width ?? 150,
//     textColor: Colors.white,
//     backgroundColor: Colors.black,
//     glowColor: Colors.white,
//   );
// }

// /*
// 🎯 USAGE EXAMPLES:

// ✅ BASIC USAGE:
// AppAssets.localImage()
// AppAssets.localImage(width: 200)

// ✅ WITH CUSTOM COLORS:
// AppAssets.localImage(
//   width: 200,
//   textColor: Colors.white,        // ✅ Now available
//   backgroundColor: Colors.black,  // ✅ Now available
//   glowColor: Colors.cyan,        // ✅ Now available
//   opacity: 0.8,                  // ✅ Now available
//   animated: true,
// )

// ✅ FOCUS-BASED COLORS:
// AppAssets.localImage(
//   height: screenhgt * 0.05,
//   width: (screenhgt * 0.05) * (640 / 360),
//   glowColor: focusNode.hasFocus ? randomColor : Colors.cyan,
//   opacity: focusNode.hasFocus ? 1.0 : 0.8,
//   animated: focusNode.hasFocus,
// )

// ✅ PREDEFINED THEMES:
// AppAssets.logoLight()           // Light version
// AppAssets.logoGold()            // Gold version
// AppAssets.logoRed()             // Red version
// AppAssets.logoMinimal()         // Subtle version

// ✅ ALL PARAMETERS AVAILABLE:
// - width: double?
// - height: double?
// - fit: BoxFit?
// - animated: bool
// - textColor: Color?       ✅ NEW
// - backgroundColor: Color? ✅ NEW
// - glowColor: Color?      ✅ NEW
// - opacity: double?       ✅ NEW
// */







// 📁 FILE: lib/constants/app_assets.dart
// ✅ IMPROVED VERSION WITH BETTER VISIBILITY & COLORS

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppAssets {
  // 🎯 IMPROVED LOGO WIDGET WITH BETTER COLOR SYSTEM
  static Widget localImage({
    double? width,
    double? height,
    BoxFit? fit,
    bool animated = false,
    Color? textColor,
    Color? backgroundColor,
    Color? glowColor,
    double? opacity,
    bool highContrast = false,  // ✅ Better visibility option
    LogoTheme? theme,          // ✅ Predefined themes
  }) {
    // Default values
    final double logoWidth = width ?? 150.0;
    final double logoHeight = height ?? (logoWidth * (360 / 640));
    final BoxFit logoFit = fit ?? BoxFit.contain;

    // 🎨 THEME SYSTEM
    Map<String, String> colors = _getThemeColors(
      theme: theme,
      textColor: textColor,
      backgroundColor: backgroundColor,
      glowColor: glowColor,
      highContrast: highContrast,
    );

    final double finalOpacity = opacity ?? 1.0;

    // 🎯 IMPROVED SVG WITH BETTER CONTRAST & VISIBILITY
    String customSvg = '''
<svg width="640" height="360" viewBox="0 0 640 360" xmlns="http://www.w3.org/2000/svg">
  <defs>
    <!-- Background Gradients -->
    <radialGradient id="mainBg" cx="50%" cy="50%" r="70%">
      <stop offset="0%" style="stop-color:${colors['bgPrimary']};stop-opacity:1" />
      <stop offset="40%" style="stop-color:${colors['bgSecondary']};stop-opacity:1" />
      <stop offset="100%" style="stop-color:${colors['bgTertiary']};stop-opacity:1" />
    </radialGradient>
    
    <linearGradient id="screenGlow" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:${colors['glowPrimary']};stop-opacity:0.9" />
      <stop offset="25%" style="stop-color:${colors['glowSecondary']};stop-opacity:0.7" />
      <stop offset="75%" style="stop-color:${colors['glowTertiary']};stop-opacity:0.7" />
      <stop offset="100%" style="stop-color:${colors['glowQuaternary']};stop-opacity:0.9" />
    </linearGradient>
    
    <linearGradient id="textGlow" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" style="stop-color:${colors['textPrimary']};stop-opacity:1" />
      <stop offset="25%" style="stop-color:${colors['textSecondary']};stop-opacity:1" />
      <stop offset="75%" style="stop-color:${colors['textSecondary']};stop-opacity:1" />
      <stop offset="100%" style="stop-color:${colors['textPrimary']};stop-opacity:1" />
    </linearGradient>

    <!-- Enhanced Filters for Better Visibility -->
    <filter id="strongGlow" x="-30%" y="-30%" width="160%" height="160%">
      <feGaussianBlur stdDeviation="10" result="coloredBlur"/>
      <feMerge>
        <feMergeNode in="coloredBlur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
    
    <filter id="textStroke" x="-20%" y="-20%" width="140%" height="140%">
      <feMorphology operator="dilate" radius="1"/>
      <feFlood flood-color="${colors['textStroke']}" flood-opacity="0.8"/>
      <feComposite in="SourceGraphic"/>
      <feGaussianBlur stdDeviation="3" result="glow"/>
      <feMerge>
        <feMergeNode in="glow"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
    
    <filter id="screenBorder" x="-10%" y="-10%" width="120%" height="120%">
      <feGaussianBlur stdDeviation="6" result="coloredBlur"/>
      <feMerge>
        <feMergeNode in="coloredBlur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>
    
    <!-- Improved Pattern -->
    <pattern id="hexPattern" patternUnits="userSpaceOnUse" width="40" height="35">
      <polygon points="20,3 30,10 30,25 20,32 10,25 10,10" 
               fill="none" 
               stroke="${colors['patternColor']}" 
               stroke-width="0.8" 
               opacity="0.3"/>
    </pattern>
  </defs>
  
  <!-- Main Background -->
  <rect width="640" height="360" rx="25" fill="url(#mainBg)" stroke="${colors['borderColor']}" stroke-width="2"/>
  
  <!-- Pattern Overlay -->
  <rect width="640" height="360" fill="url(#hexPattern)" opacity="0.4"/>
  
  <!-- Outer Border with Strong Glow -->
  <rect x="8" y="8" width="624" height="344" rx="20" 
        fill="none" 
        stroke="url(#screenGlow)" 
        stroke-width="4" 
        filter="url(#strongGlow)" 
        opacity="0.9"/>
  
  <!-- Inner Border -->
  <rect x="20" y="20" width="600" height="320" rx="15" 
        fill="none" 
        stroke="${colors['innerBorder']}" 
        stroke-width="2" 
        opacity="0.8"/>
  
  <!-- Main Screen Area -->
  <rect x="60" y="80" width="520" height="200" rx="20" 
        fill="url(#screenGlow)" 
        stroke="${colors['screenBorder']}" 
        stroke-width="2" 
        opacity="0.25" 
        filter="url(#screenBorder)"/>
  
  <!-- Left Screen Monitor -->
  <g transform="translate(80, 120)">
    <rect x="0" y="0" width="120" height="80" rx="12" 
          fill="${colors['monitorBg']}" 
          stroke="url(#screenGlow)" 
          stroke-width="3" 
          filter="url(#strongGlow)"/>
    <rect x="10" y="10" width="100" height="60" rx="6" 
          fill="${colors['monitorScreen']}" 
          opacity="0.9"/>
    <rect x="10" y="10" width="100" height="60" rx="6" 
          fill="none" 
          stroke="${colors['monitorBorder']}" 
          stroke-width="1.5" 
          opacity="0.8"/>
    <circle cx="105" cy="20" r="4" fill="#00ff88" opacity="0.9">
      <animate attributeName="opacity" values="0.5;1;0.5" dur="2s" repeatCount="indefinite"/>
    </circle>
  </g>
  
  <!-- Signal Waves -->
  <g transform="translate(220, 140)">
    <path d="M0,20 Q20,0 40,20 Q60,40 80,20" 
          stroke="${colors['wave1']}" 
          stroke-width="4" 
          fill="none" 
          opacity="0.8" 
          filter="url(#strongGlow)">
      <animate attributeName="opacity" values="0.4;0.8;0.4" dur="3s" repeatCount="indefinite"/>
    </path>
    <path d="M0,20 Q25,-10 50,20 Q75,50 100,20" 
          stroke="${colors['wave2']}" 
          stroke-width="3" 
          fill="none" 
          opacity="0.6">
      <animate attributeName="opacity" values="0.3;0.6;0.3" dur="3.5s" repeatCount="indefinite"/>
    </path>
    <path d="M0,20 Q30,-15 60,20 Q90,55 120,20" 
          stroke="${colors['wave3']}" 
          stroke-width="2" 
          fill="none" 
          opacity="0.5">
      <animate attributeName="opacity" values="0.2;0.5;0.2" dur="4s" repeatCount="indefinite"/>
    </path>
  </g>
  
  <!-- Main EKOM Text with Better Visibility -->
  <text x="320" y="200" 
        font-family="Arial Black, sans-serif" 
        font-size="68" 
        font-weight="900" 
        text-anchor="middle" 
        fill="url(#textGlow)" 
        filter="url(#textStroke)"
        stroke="${colors['textStroke']}" 
        stroke-width="1">EKOM</text>
  
  <!-- TV Text with Better Contrast -->
  <text x="500" y="200" 
        font-family="Arial Black, sans-serif" 
        font-size="52" 
        font-weight="bold" 
        fill="${colors['tvText']}" 
        opacity="0.95" 
        filter="url(#textStroke)"
        stroke="${colors['textStroke']}" 
        stroke-width="0.5">TV</text>
  
  <!-- Separator Line -->
  <line x1="90" y1="235" x2="550" y2="235" 
        stroke="url(#screenGlow)" 
        stroke-width="3" 
        opacity="0.8"/>
  
  <!-- Subtitle with Better Visibility -->
  <text x="320" y="265" 
        font-family="Arial, sans-serif" 
        font-size="20" 
        font-weight="600"
        text-anchor="middle" 
        fill="${colors['subtitle']}" 
        opacity="0.9" 
        filter="url(#textStroke)">NEXT GENERATION ENTERTAINMENT</text>
  
  <!-- Top Right Indicator -->
  <g transform="translate(550, 45)">
    <circle cx="0" cy="0" r="25" 
            fill="none" 
            stroke="${colors['indicator']}" 
            stroke-width="3" 
            opacity="0.7">
      <animate attributeName="r" values="20;25;20" dur="2s" repeatCount="indefinite"/>
    </circle>
    <circle cx="0" cy="0" r="15" 
            fill="${colors['indicatorFill']}" 
            opacity="0.4"/>
    <rect x="-10" y="-10" width="20" height="20" 
          fill="none" 
          stroke="${colors['indicatorBox']}" 
          stroke-width="1.5" 
          opacity="0.7" 
          rx="3"/>
  </g>
  
  <!-- Bottom Left Decoration -->
  <g transform="translate(90, 320)">
    <rect x="-20" y="-20" width="40" height="40" 
          fill="none" 
          stroke="url(#screenGlow)" 
          stroke-width="3" 
          opacity="0.6" 
          rx="8"/>
  </g>
  
  <!-- Floating Elements -->
  <circle cx="150" cy="100" r="3" fill="${colors['float1']}" opacity="0.8">
    <animate attributeName="opacity" values="0.4;0.8;0.4" dur="2.5s" repeatCount="indefinite"/>
  </circle>
  <circle cx="480" cy="300" r="2.5" fill="${colors['float2']}" opacity="0.7">
    <animate attributeName="opacity" values="0.3;0.7;0.3" dur="3s" repeatCount="indefinite"/>
  </circle>
  <circle cx="200" cy="280" r="3.5" fill="${colors['float3']}" opacity="0.6">
    <animate attributeName="opacity" values="0.2;0.6;0.2" dur="3.5s" repeatCount="indefinite"/>
  </circle>
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

    // Animated version with enhanced effects
    if (animated) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 2000),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: 0.7 + (0.3 * value),
            child: Opacity(
              opacity: value * finalOpacity,
              child: Transform.rotate(
                angle: (1 - value) * 0.1,
                child: SvgPicture.string(
                  customSvg,
                  width: logoWidth,
                  height: logoHeight,
                  fit: logoFit,
                ),
              ),
            ),
          );
        },
      );
    }

    return logo;
  }

  // 🎨 THEME SYSTEM
  static Map<String, String> _getThemeColors({
    LogoTheme? theme,
    Color? textColor,
    Color? backgroundColor,
    Color? glowColor,
    bool highContrast = false,
  }) {
    // Use custom colors if provided
    if (textColor != null || backgroundColor != null || glowColor != null) {
      final String customText = textColor != null ? _colorToHex(textColor) : 'ffffff';
      final String customBg = backgroundColor != null ? _colorToHex(backgroundColor) : '0a0a1a';
      final String customGlow = glowColor != null ? _colorToHex(glowColor) : '00ffff';
      
      return _buildCustomTheme(customText, customBg, customGlow, highContrast);
    }

    // Use predefined themes
    switch (theme) {
      case LogoTheme.light:
        return _lightTheme();
      case LogoTheme.dark:
        return _darkTheme(highContrast);
      case LogoTheme.gold:
        return _goldTheme();
      case LogoTheme.red:
        return _redTheme();
      case LogoTheme.green:
        return _greenTheme();
      case LogoTheme.purple:
        return _purpleTheme();
      case LogoTheme.blue:
        return _blueTheme();
      case LogoTheme.minimal:
        return _minimalTheme();
      default:
        return _darkTheme(highContrast);
    }
  }

  static Map<String, String> _buildCustomTheme(String text, String bg, String glow, bool highContrast) {
    return {
      'bgPrimary': '#$bg',
      'bgSecondary': '#${_adjustColorHex(bg, 30)}',
      'bgTertiary': '#000000',
      'textPrimary': '#$text',
      'textSecondary': '#${_adjustColorHex(text, -20)}',
      'textStroke': highContrast ? '#000000' : '#${_adjustColorHex(text, -100)}',
      'tvText': '#$text',
      'subtitle': '#$glow',
      'glowPrimary': '#$glow',
      'glowSecondary': '#${_adjustColorHex(glow, -40)}',
      'glowTertiary': '#${_adjustColorHex(glow, 60)}',
      'glowQuaternary': '#${_adjustColorHex(glow, 100)}',
      'borderColor': '#$glow',
      'innerBorder': '#$glow',
      'screenBorder': '#$glow',
      'monitorBg': '#${_adjustColorHex(bg, 40)}',
      'monitorScreen': '#${_adjustColorHex(bg, 60)}',
      'monitorBorder': '#$glow',
      'patternColor': '#$glow',
      'wave1': '#$glow',
      'wave2': '#${_adjustColorHex(glow, -30)}',
      'wave3': '#${_adjustColorHex(glow, 40)}',
      'indicator': '#$glow',
      'indicatorFill': '#$glow',
      'indicatorBox': '#${_adjustColorHex(glow, 80)}',
      'float1': '#$glow',
      'float2': '#${_adjustColorHex(glow, 80)}',
      'float3': '#${_adjustColorHex(glow, -30)}',
    };
  }

  // Theme definitions
  static Map<String, String> _darkTheme(bool highContrast) => {
    'bgPrimary': '#0f0f23',
    'bgSecondary': '#1a1a3e',
    'bgTertiary': '#000000',
    'textPrimary': highContrast ? '#ffffff' : '#f0f0f0',
    'textSecondary': '#ffffff',
    'textStroke': highContrast ? '#000000' : '#002235',
    'tvText': '#ffffff',
    'subtitle': '#00ffff',
    'glowPrimary': '#00ffff',
    'glowSecondary': '#0080ff',
    'glowTertiary': '#8000ff',
    'glowQuaternary': '#ff00ff',
    'borderColor': '#00ffff',
    'innerBorder': '#00ffff',
    'screenBorder': '#00ffff',
    'monitorBg': '#001122',
    'monitorScreen': '#000033',
    'monitorBorder': '#00ffff',
    'patternColor': '#00ffff',
    'wave1': '#00ffff',
    'wave2': '#0080ff',
    'wave3': '#8000ff',
    'indicator': '#00ffff',
    'indicatorFill': '#00ffff',
    'indicatorBox': '#ff00ff',
    'float1': '#00ffff',
    'float2': '#ff00ff',
    'float3': '#0080ff',
  };

  static Map<String, String> _lightTheme() => {
    'bgPrimary': '#f5f5f5',
    'bgSecondary': '#e0e0e0',
    'bgTertiary': '#ffffff',
    'textPrimary': '#1a1a1a',
    'textSecondary': '#2a2a2a',
    'textStroke': '#ffffff',
    'tvText': '#1a1a1a',
    'subtitle': '#0066cc',
    'glowPrimary': '#0066cc',
    'glowSecondary': '#004499',
    'glowTertiary': '#6600cc',
    'glowQuaternary': '#cc0066',
    'borderColor': '#0066cc',
    'innerBorder': '#0066cc',
    'screenBorder': '#0066cc',
    'monitorBg': '#e8e8e8',
    'monitorScreen': '#f0f0f0',
    'monitorBorder': '#0066cc',
    'patternColor': '#0066cc',
    'wave1': '#0066cc',
    'wave2': '#004499',
    'wave3': '#6600cc',
    'indicator': '#0066cc',
    'indicatorFill': '#0066cc',
    'indicatorBox': '#cc0066',
    'float1': '#0066cc',
    'float2': '#cc0066',
    'float3': '#004499',
  };

  static Map<String, String> _goldTheme() => {
    'bgPrimary': '#1a1a0a',
    'bgSecondary': '#2a2a1a',
    'bgTertiary': '#000000',
    'textPrimary': '#fff8dc',
    'textSecondary': '#ffebcd',
    'textStroke': '#8b4513',
    'tvText': '#fff8dc',
    'subtitle': '#ffd700',
    'glowPrimary': '#ffd700',
    'glowSecondary': '#ffb347',
    'glowTertiary': '#ff8c00',
    'glowQuaternary': '#ff6347',
    'borderColor': '#ffd700',
    'innerBorder': '#ffd700',
    'screenBorder': '#ffd700',
    'monitorBg': '#2a2210',
    'monitorScreen': '#332d15',
    'monitorBorder': '#ffd700',
    'patternColor': '#ffd700',
    'wave1': '#ffd700',
    'wave2': '#ffb347',
    'wave3': '#ff8c00',
    'indicator': '#ffd700',
    'indicatorFill': '#ffd700',
    'indicatorBox': '#ff6347',
    'float1': '#ffd700',
    'float2': '#ff6347',
    'float3': '#ffb347',
  };

  static Map<String, String> _redTheme() => {
    'bgPrimary': '#1a0a0a',
    'bgSecondary': '#2a1515',
    'bgTertiary': '#000000',
    'textPrimary': '#ffe4e1',
    'textSecondary': '#ffcccb',
    'textStroke': '#8b0000',
    'tvText': '#ffe4e1',
    'subtitle': '#ff4444',
    'glowPrimary': '#ff4444',
    'glowSecondary': '#ff6b6b',
    'glowTertiary': '#ff8e8e',
    'glowQuaternary': '#ffb3b3',
    'borderColor': '#ff4444',
    'innerBorder': '#ff4444',
    'screenBorder': '#ff4444',
    'monitorBg': '#331010',
    'monitorScreen': '#441515',
    'monitorBorder': '#ff4444',
    'patternColor': '#ff4444',
    'wave1': '#ff4444',
    'wave2': '#ff6b6b',
    'wave3': '#ff8e8e',
    'indicator': '#ff4444',
    'indicatorFill': '#ff4444',
    'indicatorBox': '#ffb3b3',
    'float1': '#ff4444',
    'float2': '#ffb3b3',
    'float3': '#ff6b6b',
  };

  static Map<String, String> _greenTheme() => {
    'bgPrimary': '#0a1a0a',
    'bgSecondary': '#152a15',
    'bgTertiary': '#000000',
    'textPrimary': '#e4ffe1',
    'textSecondary': '#ccffcb',
    'textStroke': '#006400',
    'tvText': '#e4ffe1',
    'subtitle': '#44ff44',
    'glowPrimary': '#44ff44',
    'glowSecondary': '#6bff6b',
    'glowTertiary': '#8eff8e',
    'glowQuaternary': '#b3ffb3',
    'borderColor': '#44ff44',
    'innerBorder': '#44ff44',
    'screenBorder': '#44ff44',
    'monitorBg': '#103310',
    'monitorScreen': '#154415',
    'monitorBorder': '#44ff44',
    'patternColor': '#44ff44',
    'wave1': '#44ff44',
    'wave2': '#6bff6b',
    'wave3': '#8eff8e',
    'indicator': '#44ff44',
    'indicatorFill': '#44ff44',
    'indicatorBox': '#b3ffb3',
    'float1': '#44ff44',
    'float2': '#b3ffb3',
    'float3': '#6bff6b',
  };

  static Map<String, String> _purpleTheme() => {
    'bgPrimary': '#1a0a1a',
    'bgSecondary': '#2a152a',
    'bgTertiary': '#000000',
    'textPrimary': '#f0e4ff',
    'textSecondary': '#e6ccff',
    'textStroke': '#4b0082',
    'tvText': '#f0e4ff',
    'subtitle': '#8844ff',
    'glowPrimary': '#8844ff',
    'glowSecondary': '#9966ff',
    'glowTertiary': '#aa88ff',
    'glowQuaternary': '#bbaaff',
    'borderColor': '#8844ff',
    'innerBorder': '#8844ff',
    'screenBorder': '#8844ff',
    'monitorBg': '#331033',
    'monitorScreen': '#441544',
    'monitorBorder': '#8844ff',
    'patternColor': '#8844ff',
    'wave1': '#8844ff',
    'wave2': '#9966ff',
    'wave3': '#aa88ff',
    'indicator': '#8844ff',
    'indicatorFill': '#8844ff',
    'indicatorBox': '#bbaaff',
    'float1': '#8844ff',
    'float2': '#bbaaff',
    'float3': '#9966ff',
  };

  static Map<String, String> _blueTheme() => {
    'bgPrimary': '#0a0a1a',
    'bgSecondary': '#15152a',
    'bgTertiary': '#000000',
    'textPrimary': '#e4e4ff',
    'textSecondary': '#ccccff',
    'textStroke': '#000080',
    'tvText': '#e4e4ff',
    'subtitle': '#4488ff',
    'glowPrimary': '#4488ff',
    'glowSecondary': '#66aaff',
    'glowTertiary': '#88ccff',
    'glowQuaternary': '#aaddff',
    'borderColor': '#4488ff',
    'innerBorder': '#4488ff',
    'screenBorder': '#4488ff',
    'monitorBg': '#101033',
    'monitorScreen': '#151544',
    'monitorBorder': '#4488ff',
    'patternColor': '#4488ff',
    'wave1': '#4488ff',
    'wave2': '#66aaff',
    'wave3': '#88ccff',
    'indicator': '#4488ff',
    'indicatorFill': '#4488ff',
    'indicatorBox': '#aaddff',
    'float1': '#4488ff',
    'float2': '#aaddff',
    'float3': '#66aaff',
  };

  static Map<String, String> _minimalTheme() => {
    'bgPrimary': '#fafafa',
    'bgSecondary': '#f0f0f0',
    'bgTertiary': '#ffffff',
    'textPrimary': '#333333',
    'textSecondary': '#555555',
    'textStroke': '#ffffff',
    'tvText': '#333333',
    'subtitle': '#666666',
    'glowPrimary': '#999999',
    'glowSecondary': '#bbbbbb',
    'glowTertiary': '#cccccc',
    'glowQuaternary': '#dddddd',
    'borderColor': '#999999',
    'innerBorder': '#bbbbbb',
    'screenBorder': '#cccccc',
    'monitorBg': '#f5f5f5',
    'monitorScreen': '#ffffff',
    'monitorBorder': '#cccccc',
    'patternColor': '#dddddd',
    'wave1': '#999999',
    'wave2': '#bbbbbb',
    'wave3': '#cccccc',
    'indicator': '#999999',
    'indicatorFill': '#cccccc',
    'indicatorBox': '#bbbbbb',
    'float1': '#999999',
    'float2': '#cccccc',
    'float3': '#bbbbbb',
  };

  // Helper methods
  static String _colorToHex(Color color) {
    return color.value.toRadixString(16).substring(2);
  }

  static String _adjustColorHex(String hexColor, int adjustment) {
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
      return hexColor;
    }
  }

  // Quick access methods
  static Widget logoSmall() => localImage(width: 80);
  static Widget logoMedium() => localImage(width: 150);
  static Widget logoLarge() => localImage(width: 250);
  static Widget logoAnimated([double? width]) => localImage(width: width ?? 150, animated: true);

  // Theme-specific methods
  static Widget logoLight([double? width]) => localImage(width: width ?? 150, theme: LogoTheme.light);
  static Widget logoDark([double? width]) => localImage(width: width ?? 150, theme: LogoTheme.dark);
  static Widget logoGold([double? width]) => localImage(width: width ?? 150, theme: LogoTheme.gold);
  static Widget logoRed([double? width]) => localImage(width: width ?? 150, theme: LogoTheme.red);
  static Widget logoGreen([double? width]) => localImage(width: width ?? 150, theme: LogoTheme.green);
  static Widget logoPurple([double? width]) => localImage(width: width ?? 150, theme: LogoTheme.purple);
  static Widget logoBlue([double? width]) => localImage(width: width ?? 150, theme: LogoTheme.blue);
  static Widget logoMinimal([double? width]) => localImage(width: width ?? 150, theme: LogoTheme.minimal);
  
  // High contrast version for better visibility
  static Widget logoHighContrast([double? width]) => localImage(
    width: width ?? 150, 
    theme: LogoTheme.dark, 
    highContrast: true
  );
}

// Theme enum
enum LogoTheme { light, dark, gold, red, green, purple, blue, minimal }

/*
🎯 IMPROVEMENTS MADE:

✅ BETTER TEXT VISIBILITY:
- Added text stroke/outline for better contrast
- Enhanced font weights and sizes
- Better color combinations
- High contrast option

✅ ENHANCED VISUAL EFFECTS:
- Stronger glow effects
- Animated elements (breathing circles, waves)
- Better border contrast
- Improved pattern visibility

✅ THEME SYSTEM:
- Predefined themes with proper color coordination
- Better light/dark theme support
- High contrast mode for accessibility
- Easy theme switching

✅ USAGE EXAMPLES:

// Basic usage (much better visibility now)
AppAssets.localImage()

// High contrast for better visibility
AppAssets.logoHighContrast()

// With custom colors and high contrast
AppAssets.localImage(
  width: 200,
  textColor: Colors.white,
  backgroundColor: Colors.black,
  glowColor: Colors.cyan,
  highContrast: true,
)

// Theme-based (pre-configured for best visibility)
AppAssets.logoLight()     // Light theme with dark text
AppAssets.logoDark()      // Dark theme with light text
AppAssets.logoGold()      // Gold theme
AppAssets.logoBlue()      // Blue theme

// For focus states
AppAssets.localImage(
  width: 200,
  theme: focusNode.hasFocus ? LogoTheme.gold : LogoTheme.dark,
  highContrast: focusNode.hasFocus,
  animated: focusNode.hasFocus,
)

Ab text bilkul clear dikhega aur colors properly work karenge! 🎉
*/