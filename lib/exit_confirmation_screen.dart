// // lib/exit_confirmation_screen.dart

// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:mobi_tv_entertainment/main.dart'; // Apne global variables ke liye import karein

// class ExitConfirmationScreen extends StatefulWidget {
//   // Yeh flag batayega ki screen back button se khuli hai ya app start par
//   final bool isFromBackButton;

//   const ExitConfirmationScreen({
//     Key? key,
//     required this.isFromBackButton,
//   }) : super(key: key);

//   @override
//   State<ExitConfirmationScreen> createState() => _ExitConfirmationScreenState();
// }

// class _ExitConfirmationScreenState extends State<ExitConfirmationScreen> {
//   late final FocusNode _enterButtonFocusNode;
//   late final FocusNode _exitButtonFocusNode;

//   @override
//   void initState() {
//     super.initState();

//     _enterButtonFocusNode = FocusNode();
//     _exitButtonFocusNode = FocusNode();

//     // SCENARIO 1: Agar screen app start par khuli hai
//     if (!widget.isFromBackButton) {
//       // 5 second ke baad screen ko automatically band kar dein
//       Timer(const Duration(seconds: 8), () {
//         // Yeh check zaroori hai, taaki agar widget tree se hat chuka ho to error na aaye
//         if (mounted) {
//           Navigator.of(context).pop();
//         }
//       });
//     } else {
//       // SCENARIO 2: Agar screen back button se khuli hai
//       // Build complete hone ke baad 'Enter' button par focus set karein
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         FocusScope.of(context).requestFocus(_enterButtonFocusNode);
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _enterButtonFocusNode.dispose();
//     _exitButtonFocusNode.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // Screen ko semi-transparent banayein taaki peeche ka HomeScreen dikhe
//       backgroundColor: Colors.black.withOpacity(0.85),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Yahan aap apna logo ya koi text daal sakte hain
//             Image.asset(
//               'assets/cpPlayer.png', // Apna logo path daalein
//               width: 150,
//             ),
//             const SizedBox(height: 40),

//             // Buttons sirf tabhi dikhayein jab screen back button se khuli ho
//             if (widget.isFromBackButton)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   _buildButton(
//                     text: 'Enter',
//                     focusNode: _enterButtonFocusNode,
//                     onPressed: () {
//                       // 'Enter' par, is screen ko band karke HomeScreen par wapas jayein
//                       // Navigator.of(context).pop();
//                                   Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => MyHome()),
//             );
//                     },
//                   ),
//                   const SizedBox(width: 30),
//                   _buildButton(
//                     text: 'Exit',
//                     focusNode: _exitButtonFocusNode,
//                     onPressed: () {
//                       // 'Exit' par, app ko band kar dein
//                       SystemNavigator.pop();
//                     },
//                     isExitButton: true,
//                   ),
//                 ],
//               )
//             else
//               // App start par, ek loading indicator ya message dikhayein
//               Column(
//                 children: [
//                   const CircularProgressIndicator(color: Colors.white),
//                   const SizedBox(height: 20),
//                   Text(
//                     'Loading your experience...',
//                     style: TextStyle(color: Colors.white, fontSize: menutextsz),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Focusable button banane ke liye ek helper widget
//   Widget _buildButton({
//     required String text,
//     required FocusNode focusNode,
//     required VoidCallback onPressed,
//     bool isExitButton = false,
//   }) {
//     return ElevatedButton(
//       focusNode: focusNode,
//       onPressed: onPressed,
//       style: ButtonStyle(
//         backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
//           if (states.contains(MaterialState.focused)) {
//             return isExitButton ? Colors.redAccent : Colors.blueAccent;
//           }
//           return Colors.white.withOpacity(0.1);
//         }),
//         shape: MaterialStateProperty.all(
//           RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//             side: BorderSide(
//               color: focusNode.hasFocus
//                   ? Colors.white
//                   : Colors.white.withOpacity(0.3),
//               width: 2,
//             ),
//           ),
//         ),
//         padding: MaterialStateProperty.all(
//           const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
//         ),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: nametextsz,
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }
// }






// lib/exit_confirmation_screen.dart

import 'dart:async';
import 'dart:ui'; // ImageFilter ke liye import karein
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobi_tv_entertainment/main.dart';

class ExitConfirmationScreen extends StatefulWidget {
  final bool isFromBackButton;

  const ExitConfirmationScreen({
    Key? key,
    required this.isFromBackButton,
  }) : super(key: key);

  @override
  State<ExitConfirmationScreen> createState() => _ExitConfirmationScreenState();
}

// ✨ Animation ke liye SingleTickerProviderStateMixin add karein
class _ExitConfirmationScreenState extends State<ExitConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late final FocusNode _enterButtonFocusNode;
  late final FocusNode _exitButtonFocusNode;

  // ✨ UI elements ke fade-in animation ke liye controllers
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _enterButtonFocusNode = FocusNode();
    _exitButtonFocusNode = FocusNode();

    // ✨ Animation controller ko initialize karein
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (!widget.isFromBackButton) {
      // 5 second ke baad screen ko automatically band kar dein
      Timer(const Duration(seconds: 8), () {
        if (mounted) {
          // Screen ko fade-out karte hue pop karein
          _animationController.reverse().whenComplete(() {
            Navigator.of(context).pop();
          });
        }
      });
    } else {
      // 'Enter' button par focus set karein
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_enterButtonFocusNode);
      });
    }

    // ✨ Animation shuru karein
    _animationController.forward();
  }

  @override
  void dispose() {
    _enterButtonFocusNode.dispose();
    _exitButtonFocusNode.dispose();
    _animationController.dispose(); // ✨ Controller ko dispose karna zaroori hai
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Transparent background zaroori hai blur ke liye
      // ✨ UI ko blur effect dene ke liye BackdropFilter
      body: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          // Blur ke upar ek dark overlay, taaki text saaf dikhe
          color: Colors.black.withOpacity(0.6),
          child: FadeTransition(
            opacity: _fadeAnimation, // ✨ Fade animation apply karein
            child: Center(
              child: _buildContent(), // UI content ke liye alag function
            ),
          ),
        ),
      ),
    );
  }

  // ✨ UI ko organize karne ke liye alag function
  Widget _buildContent() {
    // Agar back button se khula hai, to exit confirmation UI dikhayein
    if (widget.isFromBackButton) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image.asset('assets/cpPlayer.png', width: 120),
          Image.network(SessionManager.logoUrl,width: 150,),
          const SizedBox(height: 20),
          Text(
            'Leaving so soon?',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: Headingtextsz * 0.8,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FocusableAnimatedButton(
                focusNode: _exitButtonFocusNode,
                text: 'Exit App',
                icon: Icons.exit_to_app,
                onPressed: () => SystemNavigator.pop(),
                isDestructive: true,
              ),
              const SizedBox(width: 30),
               FocusableAnimatedButton(
                focusNode: _enterButtonFocusNode,
                text: 'Stay',
                icon: Icons.check_circle_outline,
                onPressed: () {
                  // Navigator.of(context).pop();
                                                    Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHome()),
            );
                },

              ),
            ],
          ),
        ],
      );
    }
    // Warna, initial loading UI dikhayein
    else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/cpPlayer.png', width: 150),
          const SizedBox(height: 40),
          const CircularProgressIndicator(color: Colors.white),
          const SizedBox(height: 20),
          Text(
            'Loading your experience...',
            style: TextStyle(color: Colors.white, fontSize: menutextsz),
          ),
        ],
      );
    }
  }
}

// ✨ Focus par scale animation ke saath ek behtar, reusable button widget
class FocusableAnimatedButton extends StatefulWidget {
  final FocusNode focusNode;
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isDestructive;

  const FocusableAnimatedButton({
    Key? key,
    required this.focusNode,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isDestructive = false,
  }) : super(key: key);

  @override
  State<FocusableAnimatedButton> createState() => _FocusableAnimatedButtonState();
}

class _FocusableAnimatedButtonState extends State<FocusableAnimatedButton> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _isFocused = widget.focusNode.hasFocus;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedScale widget focus par button ko smoothly bada karega
    return AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: _isFocused ? 1.1 : 1.0,
      curve: Curves.easeOut,
      child: ElevatedButton.icon(
        focusNode: widget.focusNode,
        onPressed: widget.onPressed,
        icon: Icon(widget.icon, color: Colors.white),
        label: Text(
          widget.text,
          style: TextStyle(
            fontSize: nametextsz,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          backgroundColor: _isFocused
              ? (widget.isDestructive ? Colors.red.shade700 : Colors.blue.shade700)
              : Colors.white.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _isFocused ? Colors.white : Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          elevation: _isFocused ? 8 : 2,
        ),
      ),
    );
  }
}