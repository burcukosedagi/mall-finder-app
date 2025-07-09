import 'package:flutter/material.dart';
import 'dart:math';
import '../models/mall.dart';

class ScrollCardWidget extends StatefulWidget {
  final List<Mall> malls;
  final Function(int) onCardTap;

  const ScrollCardWidget({
    Key? key,
    required this.malls,
    required this.onCardTap,
  }) : super(key: key);

  @override
  State<ScrollCardWidget> createState() => _ScrollCardWidgetState();
}

class _ScrollCardWidgetState extends State<ScrollCardWidget> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 1,
      viewportFraction: 0.62,
      keepPage: true,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      width: double.infinity,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.malls.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final mall = widget.malls[index];

          return AnimatedBuilder(
            animation: _pageController,
            builder: (context, child) {
              double value = 0.0;
              if (_pageController.position.haveDimensions) {
                value = _pageController.page! - index;
              }

              double rotationY = value * pi / 4;
              double scale = 1 - (value.abs() * 0.25);
              double opacity = 1 - (value.abs() * 0.5);

              return Opacity(
                opacity: opacity.clamp(0.3, 1.0),
                child: Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateY(rotationY)
                    ..scale(scale),
                  child: GestureDetector(
                    onTap: () => widget.onCardTap(index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            child: SizedBox(
                              height: 120,
                              width: double.infinity,
                              child: Image.network(
                                mall.photoUrl ?? '',
                                fit: BoxFit.scaleDown, // 👈 patlama engellendi
                                alignment: Alignment.center,
                                errorBuilder: (_, __, ___) => const SizedBox(
                                  height: 120,
                                  child: Center(
                                    child: Icon(Icons.image_not_supported),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 4,
                            ),
                            child: Text(
                              mall.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
