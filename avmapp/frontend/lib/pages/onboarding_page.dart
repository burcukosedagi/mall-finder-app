import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';

import 'home_page.dart';

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  PageController _pageController = PageController();
  int currentPage = 0;
  bool _showTitle = false;

  void onPageChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  void completeOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomePage()),
    );
  }

  final Color backgroundColor = Color(0xFFb29191);
  final Color curveColor = Color.fromARGB(255, 214, 200, 200);

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 300), () {
      setState(() {
        _showTitle = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 6,
                child: Container(
                  width: double.infinity,
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: onPageChanged,
                    children: [
                      // Sayfa 1
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              1,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                height: double.infinity,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/harita.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Center(
                                child: AnimatedOpacity(
                                  duration: Duration(milliseconds: 1200),
                                  opacity: _showTitle ? 1.0 : 0.0,
                                  child: AnimatedScale(
                                    duration: Duration(milliseconds: 800),
                                    scale: _showTitle ? 1.0 : 0.7,
                                    child: Text(
                                      'AVM\'m NEREDE',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: const Color.fromARGB(
                                          255,
                                          249,
                                          181,
                                          163,
                                        ),
                                        shadows: [
                                          Shadow(
                                            offset: Offset(2, 2),
                                            blurRadius: 3,
                                            color: Color(0xFF562b1a),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Sayfa 2
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFdbd8d0),
                              Color.fromARGB(255, 240, 248, 255),
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                        ),
                        child: CustomPaint(
                          painter: CurvePainter(curveColor),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(height: 45),
                                Expanded(
                                  flex: 6,
                                  child: Lottie.asset(
                                    'assets/animasyonbir.json',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                AnimatedOpacity(
                                  duration: Duration(milliseconds: 500),
                                  opacity: currentPage == 1 ? 1.0 : 0.0,
                                  child: Column(
                                    children: [
                                      Text(
                                        'Tüm AVM’ler Tek Yerde',
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          letterSpacing: 0.3,
                                          color: Color(0xFF562b1a),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Yakındaki AVM’leri, mağazaları ve fırsatları kolayca keşfet.',
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 15,
                                          height: 1.5,
                                          letterSpacing: 0.2,
                                          color: Color(0xFF562b1a),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 110),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Sayfa 3
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFFdbd8d0),
                              Color.fromARGB(255, 245, 250, 255),
                            ],
                            begin: Alignment.bottomLeft,
                            end: Alignment.topRight,
                          ),
                        ),
                        child: CustomPaint(
                          painter: CurvePainter(curveColor),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                const SizedBox(height: 40),
                                Expanded(
                                  flex: 6,
                                  child: Lottie.asset(
                                    'assets/animasyoniki.json',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                AnimatedOpacity(
                                  duration: Duration(milliseconds: 500),
                                  opacity: currentPage == 2 ? 1.0 : 0.0,
                                  child: Column(
                                    children: [
                                      Text(
                                        'Yorumlara Göz At',
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                          letterSpacing: 0.3,
                                          color: Color(0xFF562b1a),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Kullanıcı yorumlarını ve puanlamaları incele, tercihini güvenle yap.',
                                        style: GoogleFonts.montserrat(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 15,
                                          height: 1.5,
                                          letterSpacing: 0.2,
                                          color: Color(0xFF562b1a),
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 90),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Sayfa Noktaları
              if (currentPage != 0)
                Container(
                  height: 60,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 6),
                        width: currentPage == index ? 14 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentPage == index
                              ? curveColor
                              : const Color.fromARGB(255, 206, 206, 206),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ),
            ],
          ),

          // Sayfa geçişi dokunuş
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                if (currentPage < 2) {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                } else {
                  completeOnboarding();
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  final Color curveColor;

  CurvePainter(this.curveColor);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = curveColor;

    Path path = Path();
    path.lineTo(0, size.height - 100);
    path.quadraticBezierTo(
      size.width / 2,
      size.height - 20,
      size.width,
      size.height - 100,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
