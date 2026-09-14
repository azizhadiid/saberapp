import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'cbam_page.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});
  @override
  State<MainContainer> createState() => _MainContainerState();
}
class _MainContainerState extends State<MainContainer> {
  int _navIndex = 0;

  final List<Widget> _screens = [
    const DashboardPage(),
    const CbamPage(),
    const Center(child: Text('IDRI Screen')),
    const Center(child: Text('Profile Screen')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_navIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF006D44),
        shape: const CircleBorder(),
        elevation: 4,
        child: const Icon(Icons.storefront, color: Colors.white, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
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
          Icon(icon, color: isSelected ? const Color(0xFF006D44) : const Color(0xFF9CA3AF), size: 24),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: isSelected ? const Color(0xFF006D44) : const Color(0xFF9CA3AF), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
