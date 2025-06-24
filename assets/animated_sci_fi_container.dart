import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AnimatedSciFiContainer extends StatefulWidget {
  final String svgPath;
  final double width;
  final double height;
  final Color primaryColor;
  final Color secondaryColor;
  final Duration totalDuration;
  final VoidCallback? onAnimationComplete;

  const AnimatedSciFiContainer({
    Key? key,
    required this.svgPath,
    this.width = 200,
    this.height = 200,
    this.primaryColor = const Color(0xFF00FFFF), // Cyan
    this.secondaryColor = const Color(0xFF0066FF), // Blue
    this.totalDuration = const Duration(seconds: 25),
    this.onAnimationComplete,
  }) : super(key: key);

  @override
  State<AnimatedSciFiContainer> createState() => _AnimatedSciFiContainerState();
}

class _AnimatedSciFiContainerState extends State<AnimatedSciFiContainer>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _glowController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Main animation controller (25 seconds total)
    _mainController = AnimationController(
      duration: widget.totalDuration,
      vsync: this,
    );

    // Pulse animation for the first 10 seconds
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    // Rotation animation
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );

    // Glow animation
    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    // Fade animation: black for 10 seconds, then fade to transparent
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeInOut),
    ));

    // Pulse animation for variation in first 10 seconds
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Rotation animation
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Glow animation
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    // Scale animation for 3D effect
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
    ));
  }

  void _startAnimations() {
    _mainController.forward();
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _glowController.repeat(reverse: true);

    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _rotationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _mainController,
        _pulseController,
        _rotationController,
        _glowController,
      ]),
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background glow effect
              Container(
                width: widget.width * 1.5,
                height: widget.height * 1.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      widget.primaryColor.withOpacity(0.3 * _glowAnimation.value),
                      widget.secondaryColor.withOpacity(0.1 * _glowAnimation.value),
                      Colors.transparent,
                    ],
                    stops: const [0.2, 0.6, 1.0],
                  ),
                ),
              ),
              
              // Rotating outer ring
              Transform.rotate(
                angle: _rotationAnimation.value * 6.28318, // 2π
                child: Container(
                  width: widget.width * 0.9,
                  height: widget.height * 0.9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.primaryColor.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // Animated dots on the ring
                      ...List.generate(8, (index) {
                        final angle = (index * 45.0) + (_rotationAnimation.value * 360);
                        return Transform.rotate(
                          angle: angle * 3.14159 / 180,
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              width: 4,
                              height: 4,
                              margin: const EdgeInsets.only(top: 2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: widget.primaryColor,
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.primaryColor,
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),

              // Main container with SVG
              Transform.scale(
                scale: _scaleAnimation.value * _pulseAnimation.value,
                child: Container(
                  width: widget.width * 0.6,
                  height: widget.height * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        widget.primaryColor.withOpacity(0.8),
                        widget.secondaryColor.withOpacity(0.6),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.primaryColor.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      widget.svgPath,
                      width: widget.width * 0.3,
                      height: widget.height * 0.3,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Black overlay for fade effect
              Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(_fadeAnimation.value),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Usage Example Widget
class SciFiAnimationDemo extends StatelessWidget {
  const SciFiAnimationDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSciFiContainer(
              svgPath: 'assets/icons/rocket.svg', // Replace with your SVG path
              width: 250,
              height: 250,
              primaryColor: const Color(0xFF00FFFF),
              secondaryColor: const Color(0xFF0066FF),
              onAnimationComplete: () {
                print('Animation completed!');
              },
            ),
            const SizedBox(height: 50),
            AnimatedSciFiContainer(
              svgPath: 'assets/icons/star.svg', // Replace with your SVG path
              width: 200,
              height: 200,
              primaryColor: const Color(0xFFFF0080),
              secondaryColor: const Color(0xFF8000FF),
              totalDuration: const Duration(seconds: 20),
              onAnimationComplete: () {
                print('Second animation completed!');
              },
            ),
          ],
        ),
      ),
    );
  }
}