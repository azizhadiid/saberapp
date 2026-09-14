import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedTabIndex = 0; // 0: Data Perusahaan, 1: Nasional

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Image.asset('assets/img/logo.png', height: 28, errorBuilder: (_,__,___) => const Icon(Icons.factory, color: Color(0xFF006D44), size: 28)),
            const SizedBox(width: 8),
            const Text('SABER KARBON', style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.w900, fontSize: 16)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.black87), onPressed: () {}),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE5E7EB), height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCustomTabBar(),
              const SizedBox(height: 24),
              if (_selectedTabIndex == 0) ..._buildDataPerusahaanContent() else ..._buildNasionalContent(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      height: 45,
      decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 0),
              child: Container(
                decoration: BoxDecoration(color: _selectedTabIndex == 0 ? const Color(0xFF10B981) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: Text('Data Perusahaan', style: TextStyle(color: _selectedTabIndex == 0 ? Colors.white : const Color(0xFF6B7280), fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabIndex = 1),
              child: Container(
                decoration: BoxDecoration(color: _selectedTabIndex == 1 ? const Color(0xFF10B981) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
                alignment: Alignment.center,
                child: Text('Nasional (SIINas)', style: TextStyle(color: _selectedTabIndex == 1 ? Colors.white : const Color(0xFF6B7280), fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 0: DATA PERUSAHAAN (SESUAI FOTO KEDUA)
  // ==========================================
  List<Widget> _buildDataPerusahaanContent() {
    return [
      const Text('Data Pribadi Perusahaan', style: TextStyle(fontSize: 15, color: Color(0xFF4B5563), fontWeight: FontWeight.w500)),
      const SizedBox(height: 12),
      
      // Card 1: Emisi Pabrik Bulan Ini
      _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('EMISI PABRIK BULAN INI', style: TextStyle(color: Color(0xFF4B5563), fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
            const SizedBox(height: 8),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
              children: [
                Text('12,450', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                SizedBox(width: 8),
                Text('tCO2', style: TextStyle(fontSize: 16, color: Color(0xFF4B5563))),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 16), SizedBox(width: 6), Text('Mendekati Batas Kuota', style: TextStyle(color: Color(0xFFDC2626), fontSize: 11, fontWeight: FontWeight.bold))]),
            )
          ],
        ),
      ),
      const SizedBox(height: 12),
      
      // Card 2: Intensitas Karbon
      _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.bar_chart, color: Color(0xFF10B981), size: 18)),
                const SizedBox(width: 12),
                const Text('Intensitas Karbon', style: TextStyle(color: Color(0xFF4B5563), fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
              children: [
                Text('0.18', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                SizedBox(width: 6), Text('tCO2/t', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      
      // Card 3: Efisiensi Energi
      _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.bolt, color: Color(0xFF10B981), size: 18)),
                const SizedBox(width: 12),
                const Text('Efisiensi Energi', style: TextStyle(color: Color(0xFF4B5563), fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 12),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
              children: [
                Text('+12%', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
                SizedBox(width: 8), Text('vs. Last Month', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      
      const Text('Konteks Industri Nasional', style: TextStyle(fontSize: 15, color: Color(0xFF4B5563), fontWeight: FontWeight.w500)),
      const SizedBox(height: 12),
      
      // Card 4: Total Emisi Baja Nasional (Center aligned)
      _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('Total Emisi Baja Nasional', style: TextStyle(color: Color(0xFF4B5563), fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            const Text('2.86 Juta Ton', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(20)),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.trending_up, color: Color(0xFFDC2626), size: 16), SizedBox(width: 4), Text('+35% YoY', style: TextStyle(color: Color(0xFFDC2626), fontSize: 11, fontWeight: FontWeight.bold))]),
            )
          ],
        ),
      ),
      const SizedBox(height: 12),
      
      // Card 5: Peringkat Efisiensi Anda
      _buildCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('PERINGKAT EFISIENSI ANDA', style: TextStyle(color: Color(0xFF4B5563), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            _buildRankItem('1', 'PT Krakatau', '0.12 tCO2/t', false),
            _buildRankItem('2', 'PT Baja Nusantara', '0.18 tCO2/t', true),
            _buildRankItem('3', 'PT Gunung Garuda', '0.21 tCO2/t', false),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ];
  }

  // ==========================================
  // TAB 1: NASIONAL (SESUAI FOTO PERTAMA)
  // ==========================================
  List<Widget> _buildNasionalContent() {
    return [
      // Card 1: Total Emisi dengan Globe
      _buildCard(
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('TOTAL EMISI BAJA NASIONAL', style: TextStyle(color: Color(0xFF4B5563), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  const Text('2.86 Juta\nTon', style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Color(0xFF111827), height: 1.1)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(Icons.trending_up, color: Color(0xFFDC2626), size: 16),
                      const SizedBox(width: 6),
                      const Text('+35% dalam 1 dekade', style: TextStyle(color: Color(0xFFDC2626), fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: -30, top: 10,
              child: Icon(Icons.public, size: 160, color: const Color(0xFFF3F4F6).withOpacity(0.8)),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      
      // Card 2: Target Penurunan
      _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('TARGET PENURUNAN 2030', style: TextStyle(color: Color(0xFF4B5563), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 12),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('45%', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                Text('tercapai', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 10,
              decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(5)),
              child: Row(
                children: [
                  Expanded(flex: 45, child: Container(decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(5)))),
                  Expanded(flex: 55, child: Container()),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      
      // Card 3: Pabrik Terdaftar
      _buildCard(
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.domain, color: Color(0xFF6B7280), size: 24)),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PABRIK TERDAFTAR', style: TextStyle(color: Color(0xFF4B5563), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                SizedBox(height: 4),
                Text('142 fasilitas', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      
      // Card 4: Intensitas Rata-rata
      _buildCard(
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.speed, color: Color(0xFF6B7280), size: 24)),
            const SizedBox(width: 16),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('INTENSITAS KARBON RATA-RATA', style: TextStyle(color: Color(0xFF4B5563), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                SizedBox(height: 4),
                Text('0.15 tCO2/t', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      
      // Card 5: Top Pabrik
      _buildCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.emoji_events_outlined, size: 18, color: Color(0xFF6B7280)),
                  SizedBox(width: 8),
                  Text('TOP PABRIK PALING EFISIEN', style: TextStyle(color: Color(0xFF4B5563), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),
            _buildTopFactoryItem('1', 'PT Krakatau Steel', 'Cilegon, Banten', '0.08 tCO2/t'),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            _buildTopFactoryItem('2', 'PT Gunung Raja Paksi', 'Bekasi, Jawa Barat', '0.11 tCO2/t'),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            _buildTopFactoryItem('3', 'PT Bhirawa Steel', 'Surabaya, Jawa Timur', '0.12 tCO2/t'),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ];
  }

  // ==========================================
  // HELPER WIDGETS
  // ==========================================
  Widget _buildCard({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  Widget _buildRankItem(String rank, String name, String value, bool isHighlighted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFF3F4F6) : Colors.transparent,
        border: isHighlighted ? const Border(left: BorderSide(color: Color(0xFF006D44), width: 3)) : null,
      ),
      child: Row(
        children: [
          SizedBox(width: 24, child: Text(rank, style: TextStyle(color: isHighlighted ? const Color(0xFF006D44) : const Color(0xFF6B7280), fontWeight: FontWeight.bold, fontSize: 13))),
          Expanded(child: Text(name, style: TextStyle(color: const Color(0xFF111827), fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500))),
          Text(value, style: TextStyle(color: isHighlighted ? const Color(0xFF10B981) : const Color(0xFF4B5563), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildTopFactoryItem(String rank, String name, String location, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Color(0xFFEEF2FF), shape: BoxShape.circle),
            child: Text(rank, style: const TextStyle(color: Color(0xFF4F46E5), fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF111827), fontSize: 13)),
                Text(location, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(12)),
            child: Text(value, style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
