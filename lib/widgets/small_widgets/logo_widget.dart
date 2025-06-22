// // 📁 FILE: lib/widgets/ekom_logo_widget.dart
// // ✅ REUSABLE LOGO WIDGET

// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:mobi_tv_entertainment/widgets/small_widgets/global_assets.dart';

// class EkomLogoWidget extends StatelessWidget {
//   final double? width;
//   final double? height;
//   final BoxFit fit;
//   final bool animated;
  
//   const EkomLogoWidget({
//     Key? key,
//     this.width,
//     this.height,
//     this.fit = BoxFit.contain,
//     this.animated = false,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final double logoWidth = width ?? AppLogos.logoMedium;
//     final double logoHeight = height ?? (logoWidth / AppLogos.aspectRatio);
    
//     Widget logo = SvgPicture.string(
//       AppLogos.ekomTvLogo,
//       width: logoWidth,
//       height: logoHeight,
//       fit: fit,
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
// }
