import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PlanExpiredScreen extends StatelessWidget {
  // ✅ API se message lene ke liye variable banaya gaya hai
  final String apiMessage;

  // ✅ Constructor ko update kiya gaya hai taaki message pass ho sake
  const PlanExpiredScreen({Key? key, required this.apiMessage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Back button ko disable kar dein
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
                  // ✅ Yahan ab hardcoded message ki jagah API wala message dikhega
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
                  ElevatedButton.icon(
                    autofocus: true,
                    icon: const Icon(Icons.exit_to_app_rounded, color: Colors.white),
                    label: const Text(
                      'EXIT THE APP',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE74C3C),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      shadowColor: Colors.redAccent,
                    ),
                    onPressed: () {
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