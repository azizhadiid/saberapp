import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'cbam_page.dart';
import 'market_page.dart';
import 'idri_page.dart';
import 'profile_page.dart';

class MainContainer extends StatefulWidget {
  final int initialIndex;
  final String userRole;

  const MainContainer({
    super.key,
    this.initialIndex = 0,
    this.userRole = 'Perusahaan Industri',
  });

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  late int _navIndex;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    final bool isGovOrAdmin =
        widget.userRole.toLowerCase().contains('pemerintah') ||
        widget.userRole.toLowerCase().contains('admin');
    _screens = [
      DashboardPage(initialTabIndex: isGovOrAdmin ? 2 : 0),
      const CbamPage(),      // Index 1: CBAM Simulator (Perusahaan Eksportir)
      const IdriPage(),      // Index 2: IDRI Screen (Audit Pabrik & 4 SDGs)
      const ProfilePage(),   // Index 3: Profile Screen
      const MarketPage(),    // Index 4: Green Market (Bursa Scrap UMKM & MRF)
    ];
    _navIndex = widget.initialIndex.clamp(0, _screens.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      body: _screens[_navIndex],
      floatingActionButton: isKeyboardVisible
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () => setState(() => _navIndex = 4),
                  backgroundColor: _navIndex == 4
                      ? const Color(0xFF10B981)
                      : const Color(0xFF006D44),
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: const Icon(
                    Icons.storefront,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Market',
                  style: TextStyle(
                    fontSize: 10,
                    color: _navIndex == 4
                        ? const Color(0xFF10B981)
                        : const Color(0xFF6B7280),
                    fontWeight: _navIndex == 4
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: isKeyboardVisible
          ? null
          : BottomAppBar(
              color: Colors.white,
              shape: const CircularNotchedRectangle(),
              notchMargin: 8.0,
              child: SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.dashboard, 'Dashboard', 0),
                    _buildNavItem(Icons.public, 'CBAM', 1),
                    const SizedBox(width: 40),
                    _buildNavItem(Icons.bar_chart, 'IDRI', 2),
                    _buildNavItem(Icons.person_outline, 'Profile', 3),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _navIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _navIndex = index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected
                ? const Color(0xFF006D44)
                : const Color(0xFF9CA3AF),
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected
                  ? const Color(0xFF006D44)
                  : const Color(0xFF9CA3AF),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
