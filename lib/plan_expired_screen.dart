// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// class PlanExpiredScreen extends StatelessWidget {
//   // ✅ API se message lene ke liye variable banaya gaya hai
//   final String apiMessage;

//   // ✅ Constructor ko update kiya gaya hai taaki message pass ho sake
//   const PlanExpiredScreen({Key? key, required this.apiMessage}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false, // Back button ko disable kar dein
//       child: Scaffold(
//         body: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF232526), Color(0xFF414345)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(30.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   const Icon(
//                     Icons.lock_clock_outlined,
//                     size: 100,
//                     color: Color(0xFFE74C3C),
//                   ),
//                   const SizedBox(height: 30),
//                   const Text(
//                     'Subscription Expired',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 32,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 1.2,
//                     ),
//                   ),
//                   const SizedBox(height: 15),
//                   // ✅ Yahan ab hardcoded message ki jagah API wala message dikhega
//                   Text(
//                     apiMessage,
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       color: Colors.white70,
//                       fontSize: 18,
//                       height: 1.5,
//                     ),
//                   ),
//                   const SizedBox(height: 50),
//                   ElevatedButton.icon(
//                     autofocus: true,
//                     icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white),
//                     label: const Text(
//                       'EXIT THE APP',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: const Color(0xFFE74C3C),
//                       padding: const EdgeInsets.symmetric(vertical: 15),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       elevation: 8,
//                       shadowColor: Colors.redAccent,
//                     ),
//                     onPressed: () {
//                       SystemNavigator.pop();
//                     },
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobi_tv_entertainment/main.dart'; // Ensure LoginScreen access

class PlanExpiredScreen extends StatelessWidget {
  final String apiMessage;

  const PlanExpiredScreen({Key? key, required this.apiMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF232526), Color(0xFF414345)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.lock_clock_outlined,
                    size: 100,
                    color: Color(0xFFE74C3C),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Subscription Expired',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    apiMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 18,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 50),

                  // ---------------------------------------------
                  // 1. UPDATE PIN BUTTON (Clears Cache & Go to Login)
                  // ---------------------------------------------
                  TvActionButton(
                    label: 'UPDATE PIN',
                    icon: Icons.refresh_rounded,
                    baseColor: Colors.blueAccent,
                    autoFocus: true, // Pehle focus yahan rahega
                    onPressed: () async {
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      
                      // Clear Login data
                      await prefs.remove('result_auth_key');
                      await prefs.remove('user_data');
                      await prefs.remove('is_logged_in');
                      await prefs.remove('user_id');
                      // Note: 'saved_domain' delete nahi kiya taaki user ko type na karna pade

                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                          (route) => false,
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 25), 

                  // ---------------------------------------------
                  // 2. EXIT APP BUTTON (✅ Ab ye bhi Cache Clear karega)
                  // ---------------------------------------------
                  TvActionButton(
                    label: 'EXIT THE APP',
                    icon: Icons.exit_to_app_rounded,
                    baseColor: const Color(0xFFE74C3C),
                    autoFocus: false,
                    onPressed: () async {
                      // ✅ 1. Pehle data clear karein
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.remove('result_auth_key');
                      await prefs.remove('user_data');
                      await prefs.remove('is_logged_in');
                      await prefs.remove('user_id');
                      // Domain yahan bhi bacha ke rakha hai agle launch ke liye

                      // ✅ 2. Phir app band karein
                      SystemNavigator.pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------
// TV ACTION BUTTON (Focus & Animation Logic)
// -----------------------------------------------------------
class TvActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color baseColor;
  final VoidCallback onPressed;
  final bool autoFocus;

  const TvActionButton({
    Key? key,
    required this.label,
    required this.icon,
    required this.baseColor,
    required this.onPressed,
    this.autoFocus = false,
  }) : super(key: key);

  @override
  State<TvActionButton> createState() => _TvActionButtonState();
}

class _TvActionButtonState extends State<TvActionButton> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: _isFocused ? 1.05 : 1.0, 
      child: Focus(
        autofocus: widget.autoFocus,
        onFocusChange: (hasFocus) {
          setState(() {
            _isFocused = hasFocus;
          });
        },
        child: ElevatedButton.icon(
          icon: Icon(
            widget.icon, 
            color: Colors.white,
            size: _isFocused ? 28 : 24,
          ),
          label: Text(
            widget.label,
            style: TextStyle(
              fontSize: _isFocused ? 20 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.baseColor,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              // White Border logic
              side: _isFocused 
                  ? const BorderSide(color: Colors.white, width: 3) 
                  : BorderSide.none,
            ),
            elevation: _isFocused ? 12 : 6,
            shadowColor: _isFocused ? Colors.white.withOpacity(0.4) : widget.baseColor,
          ),
          onPressed: widget.onPressed,
        ),
      ),
    );
  }
}