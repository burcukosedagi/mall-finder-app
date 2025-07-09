import 'package:flutter/material.dart';
import 'package:frontend/pages/lucky_pick_page.dart';
import 'package:frontend/pages/mall_detail_page.dart';
import 'package:frontend/services/api/mall_api.dart';
import 'package:lottie/lottie.dart';
import 'package:frontend/pages/weather_and_planner_page.dart';
import 'package:frontend/pages/search_page.dart';
import 'package:frontend/models/mall.dart';
import '../../widgets/animated_bottom_navbar.dart';
import '../../widgets/scroll_card_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Mall> randomMalls = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRandomMalls();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SearchPage(initialQuery: query)),
        );
      });
    }
  }

  Future<void> _loadRandomMalls() async {
    try {
      final malls = await MallApi.fetchRandomMalls(3);
      setState(() {
        randomMalls = malls;
        isLoading = false;
      });
    } catch (e) {
      print("Hata: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: const AnimatedBottomNavBar(currentIndex: 1),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFFF7F3FF),
              image: DecorationImage(
                image: AssetImage('assets/center_logo.png'),
                fit: BoxFit.contain,
                alignment: Alignment.center,
                opacity: 0.25,
                scale: 1.4,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      'AVM\'m NEREDE?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Quicksand',
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _submitSearch(),
                    decoration: InputDecoration(
                      hintText: 'AVM ara...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      filled: true,
                      fillColor: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  const SizedBox(height: 40),
                  _modernCardButton(
                    context: context,
                    label: 'ŞANSINA NE ÇIKARSA',
                    imagePath: 'assets/gift_pattern.png',
                    animationPath: 'assets/gift.json',
                    destination: LuckyPickPage(),
                  ),
                  const SizedBox(height: 22),
                  _modernCardButton(
                    context: context,
                    label: 'GÜNÜMÜ PLANLA',
                    imagePath: 'assets/notebook_pattern.png',
                    animationPath: 'assets/notebook.json',
                    destination: const WeatherAndPlannerPage(),
                  ),
                  const SizedBox(height: 55),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 7),
                    child:
                        isLoading
                            ? const CircularProgressIndicator()
                            : ScrollCardWidget(
                              malls: randomMalls,
                              onCardTap: (index) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => MallDetailPage(
                                          mall: randomMalls[index],
                                        ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernCardButton({
    required BuildContext context,
    required String label,
    required String imagePath,
    required String animationPath,
    required Widget destination,
  }) {
    return Center(
      child: StatefulBuilder(
        builder: (context, setState) {
          double scale = 1.0;

          return MouseRegion(
            onEnter: (_) => setState(() => scale = 1.03),
            onExit: (_) => setState(() => scale = 1.0),
            child: Listener(
              onPointerDown: (_) => setState(() => scale = 0.96),
              onPointerUp: (_) => setState(() => scale = 1.03),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 150),
                scale: scale,
                child: InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (context) => Center(
                            child: SizedBox(
                              width: 200,
                              height: 200,
                              child: Lottie.asset(
                                animationPath,
                                repeat: false,
                                onLoaded: (composition) {
                                  Future.delayed(composition.duration, () {
                                    Navigator.of(context).pop();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => destination,
                                      ),
                                    );
                                  });
                                },
                              ),
                            ),
                          ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  splashColor: Colors.white.withOpacity(0.2),
                  highlightColor: Colors.white.withOpacity(0.1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 260,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(
                      vertical: 26,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                        opacity: 0.12,
                      ),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF9E9BC7), Color(0xFFC8C6E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Quicksand',
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
