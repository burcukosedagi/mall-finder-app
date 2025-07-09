import 'package:flutter/material.dart';
import 'package:frontend/pages/home_page.dart';
import 'package:frontend/pages/location_page.dart';
import '../pages/search_page.dart';

class AnimatedBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AnimatedBottomNavBar({super.key, required this.currentIndex});

  void _onTabTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget page;
    switch (index) {
      case 0:
        page = const SearchPage();
        break;
      case 1:
        page = const HomePage();
        break;
      case 2:
        page = const LocationPage();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionDuration: const Duration(milliseconds: 250),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) => _onTabTapped(context, index),
      type: BottomNavigationBarType.fixed,
      elevation: 0, // ✅ Üstteki gri çizgiyi kaldırır
      backgroundColor: const Color(0xFFF2E7FA), // ✅ Açık lila arkaplan
      selectedItemColor: const Color(0xFF1B1F3B), // Lacivert seçili ikon/metin
      unselectedItemColor: const Color(0xFF999999), // Gri pasif ikon/metin
      selectedFontSize: 15,
      unselectedFontSize: 12,
      showUnselectedLabels: true,
      selectedIconTheme: const IconThemeData(size: 34),
      unselectedIconTheme: const IconThemeData(size: 24),
      items: [
        _buildItem(Icons.search, 'Ara', currentIndex == 0),
        _buildItem(Icons.home, 'Ana Sayfa', currentIndex == 1),
        _buildItem(Icons.map, 'Yakınımda', currentIndex == 2),
      ],
    );
  }

  BottomNavigationBarItem _buildItem(
    IconData icon,
    String label,
    bool selected,
  ) {
    return BottomNavigationBarItem(icon: Icon(icon), label: label);
  }
}
