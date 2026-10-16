import 'package:flutter/material.dart';
import 'dashboard_page.dart';
import 'cbam_page.dart';
import 'market_page.dart';
import 'idri_page.dart';
import 'profile_page.dart';
import 'views/green_company_views.dart';
import 'views/gov_views.dart';

class MainContainer extends StatefulWidget {
  final int initialIndex;
  final String userRole;

  const MainContainer({
    super.key,
    this.initialIndex = 0,
    this.userRole = 'perusahaan_baja',
  });

  @override
  State<MainContainer> createState() => _MainContainerState();
}

class _MainContainerState extends State<MainContainer> {
  late int _navIndex;
  late List<Widget> _screens;

  String get _roleKey {
    final r = widget.userRole.toLowerCase();
    if (r.contains('hijau') || r.contains('umkm')) return 'perusahaan_hijau';
    if (r.contains('pemerintah') ||
        r.contains('admin') ||
        r.contains('regulator')) {
      return 'pemerintah';
    }
    return 'perusahaan_baja';
  }

  void _openAddSupplyDialog() {
    showDialog(
      context: context,
      builder: (context) => const GreenAddSupplyDialog(),
    );
  }

  @override
  void initState() {
    super.initState();
    final role = _roleKey;

    if (role == 'perusahaan_hijau') {
      // 1. Ekosistem Perusahaan Hijau (UMKM Scrap & Green Tech)
      _screens = [
        GreenKatalogView(onAddSupply: _openAddSupplyDialog), // 0: Katalog Pasokan
        const GreenDemandView(),                             // 1: Permintaan Pabrik
        const GreenPartnershipView(),                        // 2: Kemitraan & Standar
        const ProfilePage(),                                 // 3: Profil UMKM
        const MarketPage(),                                  // 4: Green Market Hub
      ];
    } else if (role == 'pemerintah') {
      // 2. Ekosistem Pemerintah (Regulator & Auditor MRV)
      _screens = [
        const DashboardPage(initialTabIndex: 1),             // 0: Dashboard Nasional SIINas
        const GovSpatialMapView(),                           // 1: Peta Spasial Hotspot
        const GovPolicyBriefView(),                          // 2: Policy Brief & SDGs
        const ProfilePage(),                                 // 3: Profil Pengawas
        const GovMrvAuditView(),                             // 4: Panel Validasi MRV
      ];
    } else {
      // 3. Ekosistem Perusahaan Baja (Tetap, Jangan Diganggu Gugat!)
      _screens = [
        const DashboardPage(initialTabIndex: 0),             // 0: Dashboard Pabrik
        const CbamPage(),                                    // 1: CBAM Simulator
        const IdriPage(),                                    // 2: IDRI Screen
        const ProfilePage(),                                 // 3: Profile Screen
        const MarketPage(),                                  // 4: Green Market
      ];
    }

    _navIndex = widget.initialIndex.clamp(0, _screens.length - 1);
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final role = _roleKey;

    if (role == 'perusahaan_hijau') {
      return _buildGreenCompanyScaffold(isKeyboardVisible);
    } else if (role == 'pemerintah') {
      return _buildGovernmentScaffold(isKeyboardVisible);
    }

    // Default: Perusahaan Baja (Desain awal tetap dipertahankan)
    return _buildSteelCompanyScaffold(isKeyboardVisible);
  }

  /// ==========================================================================
  /// 1. LAYOUT PERUSAHAAN BAJA (TETAP & TIDAK DIGANGGU GUGAT)
  /// ==========================================================================
  Widget _buildSteelCompanyScaffold(bool isKeyboardVisible) {
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
                    _buildNavItem(
                      icon: Icons.dashboard,
                      label: 'Dashboard',
                      index: 0,
                      activeColor: const Color(0xFF006D44),
                    ),
                    _buildNavItem(
                      icon: Icons.public,
                      label: 'CBAM',
                      index: 1,
                      activeColor: const Color(0xFF006D44),
                    ),
                    const SizedBox(width: 40),
                    _buildNavItem(
                      icon: Icons.bar_chart,
                      label: 'IDRI',
                      index: 2,
                      activeColor: const Color(0xFF006D44),
                    ),
                    _buildNavItem(
                      icon: Icons.person_outline,
                      label: 'Profile',
                      index: 3,
                      activeColor: const Color(0xFF006D44),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// ==========================================================================
  /// 2. LAYOUT PERUSAHAAN HIJAU (UMKM SCRAP & GREEN TECH SUPPLIER)
  /// ==========================================================================
  Widget _buildGreenCompanyScaffold(bool isKeyboardVisible) {
    const primaryGreenTech = Color(0xFF0284C7); // Sky Blue / Cyan Eco

    return Scaffold(
      body: _screens[_navIndex],
      floatingActionButton: isKeyboardVisible
          ? null
          : Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    // Jika belum di tab 4, beralih ke hub market, jika sudah buka form pasok
                    if (_navIndex != 4) {
                      setState(() => _navIndex = 4);
                    } else {
                      _openAddSupplyDialog();
                    }
                  },
                  backgroundColor: _navIndex == 4
                      ? const Color(0xFF0284C7)
                      : const Color(0xFF0369A1),
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: const Icon(
                    Icons.add_business,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pasok Scrap',
                  style: TextStyle(
                    fontSize: 10,
                    color: _navIndex == 4
                        ? const Color(0xFF0284C7)
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
                    _buildNavItem(
                      icon: Icons.inventory_2_outlined,
                      label: 'Katalog',
                      index: 0,
                      activeColor: primaryGreenTech,
                    ),
                    _buildNavItem(
                      icon: Icons.assignment_outlined,
                      label: 'Permintaan',
                      index: 1,
                      activeColor: primaryGreenTech,
                    ),
                    const SizedBox(width: 40),
                    _buildNavItem(
                      icon: Icons.handshake_outlined,
                      label: 'Kemitraan',
                      index: 2,
                      activeColor: primaryGreenTech,
                    ),
                    _buildNavItem(
                      icon: Icons.store_outlined,
                      label: 'Profil UMKM',
                      index: 3,
                      activeColor: primaryGreenTech,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /// ==========================================================================
  /// 3. LAYOUT PEMERINTAH (REGULATOR & AUDITOR MRV)
  /// ==========================================================================
  Widget _buildGovernmentScaffold(bool isKeyboardVisible) {
    const primaryGov = Color(0xFF4338CA); // Deep Indigo

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
                      ? const Color(0xFF4F46E5)
                      : const Color(0xFF312E81),
                  shape: const CircleBorder(),
                  elevation: 4,
                  child: const Icon(
                    Icons.fact_check,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Audit MRV',
                  style: TextStyle(
                    fontSize: 10,
                    color: _navIndex == 4
                        ? const Color(0xFF4338CA)
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
                    _buildNavItem(
                      icon: Icons.analytics_outlined,
                      label: 'Nasional',
                      index: 0,
                      activeColor: primaryGov,
                    ),
                    _buildNavItem(
                      icon: Icons.map_outlined,
                      label: 'Peta Emisi',
                      index: 1,
                      activeColor: primaryGov,
                    ),
                    const SizedBox(width: 40),
                    _buildNavItem(
                      icon: Icons.menu_book_outlined,
                      label: 'Policy Brief',
                      index: 2,
                      activeColor: primaryGov,
                    ),
                    _buildNavItem(
                      icon: Icons.admin_panel_settings_outlined,
                      label: 'Pengawas',
                      index: 3,
                      activeColor: primaryGov,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required Color activeColor,
  }) {
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
            color: isSelected ? activeColor : const Color(0xFF9CA3AF),
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? activeColor : const Color(0xFF9CA3AF),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
