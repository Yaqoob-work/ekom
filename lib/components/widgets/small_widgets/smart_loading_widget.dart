import 'package:flutter/material.dart';

//==============================================================================
// ✅ 1. SMART SKELETON LOADING SERVICE
//==============================================================================
class SmartLoadingWidget extends StatefulWidget {
  final double itemWidth;
  final double itemHeight;

  const SmartLoadingWidget({
    Key? key, 
    required this.itemWidth, 
    required this.itemHeight
  }) : super(key: key);

  @override
  _SmartLoadingWidgetState createState() => _SmartLoadingWidgetState();
}

class _SmartLoadingWidgetState extends State<SmartLoadingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this)..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      // Padding thodi dynamic rakhi hai taaki screen ke hisaab se adjust ho
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.025),
      itemCount: 6, 
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          width: widget.itemWidth,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            children: [
              // Shimmer Poster
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Container(
                    height: widget.itemHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment(-1.0 + _animation.value, -0.3),
                        end: Alignment(1.0 + _animation.value, 0.3),
                        colors: [
                          Colors.grey[200]!,
                          Colors.grey[300]!,
                          Colors.grey[200]!,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              // Shimmer Text
              Container(
                height: 10,
                width: widget.itemWidth * 0.7,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}




