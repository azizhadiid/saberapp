import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DashboardPage extends StatefulWidget {
  final int initialTabIndex;

  const DashboardPage({super.key, this.initialTabIndex = 0});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // 0: Data Perusahaan, 1: Nasional (SIINas), 2: Admin (MRV & Policy Brief)
  late int _selectedTabIndex;

  Map<String, dynamic>? _companyData;
  Map<String, dynamic>? _nationalData;
  List<dynamic> _topFactories = [];
  bool _isLoading = true;

  // State Interaktif Panel Admin (MRV & Policy Brief - Langkah 5)
  double _pilar1BudgetPercent = 55.0; // 55% Green Reskilling, 45% MRF Scrap UMKM
  String _selectedZoneFilter = 'Semua Zona Jenks';

  final List<Map<String, dynamic>> _mrvQueueItems = [
    {
      'id': 'MRV-2026-01',
      'entity_name': 'PT Krakatau Baja Terpadu',
      'entity_type': 'Pabrik Baja (SIINas #KRK-01)',
      'location': 'Cilegon, Banten (Zona Transisi Hulu)',
      'route': 'Direct Reduced Iron (DRI) -> EAF',
      'intensity': '0.76 tCO2/t',
      'sdg_focus': 'SDG 9 & SDG 13 (Lolos Ambang CBAM 0.80)',
      'status': 'Menunggu Validasi MRV',
      'status_type': 'pending',
    },
    {
      'id': 'MRV-2026-02',
      'entity_name': 'PT Smelter Induksi Jaya',
      'entity_type': 'Pabrik Peleburan (SIINas #SIJ-09)',
      'location': 'Gresik, Jawa Timur (Zona Merah Episentrum)',
      'route': 'Induction Furnace (IF) Tanpa Scrubber',
      'intensity': '1.68 tCO2/t',
      'sdg_focus': 'Pelanggaran SDG 3 (Polusi Debu PM2.5 & SOx Tinggi)',
      'status': 'Perlu Audit & Surat Peringatan K3',
      'status_type': 'warning',
    },
    {
      'id': 'MRV-2026-03',
      'entity_name': 'Koperasi UMKM Logam Jaya Surabaya',
      'entity_type': 'Mitra UMKM Scrap (45 Lapak Besi Tua)',
      'location': 'Surabaya & Sidoarjo, Jawa Timur (Zona Merah)',
      'route': 'Material Recovery Facility (MRF) HMS 1&2',
      'intensity': 'Kemurnian Fe 98.4% (-1.42 tCO2e/t)',
      'sdg_focus': 'SDG 9 & SDG 8 (Pemasok 52% Scrap EAF)',
      'status': 'Menunggu Sertifikasi MRF & KUR Hijau',
      'status_type': 'pending',
    },
    {
      'id': 'MRV-2026-04',
      'entity_name': 'PT Nusantara Blast Furnace Steel',
      'entity_type': 'Pabrik Baja Terintegrasi (SIINas #NBF-04)',
      'location': 'Bekasi, Jawa Barat (Zona Merah Episentrum)',
      'route': 'Blast Furnace (BF-BOF) Batu Bara Kokas',
      'intensity': '1.92 tCO2/t',
      'sdg_focus': 'SDG 4 & SDG 13 (Wajib Green Reskilling 450 Buruh)',
      'status': 'Melebihi Kuota Emisi (Kena Pajak UU HPP)',
      'status_type': 'warning',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedTabIndex = widget.initialTabIndex.clamp(0, 2);
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final companyRes = await Supabase.instance.client
            .from('companies')
            .select()
            .eq('user_id', user.id)
            .maybeSingle();

        if (companyRes != null) {
          _companyData = companyRes;
        }
      }

      final natRes = await Supabase.instance.client
          .from('emission_log')
          .select()
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (natRes != null) {
        _nationalData = natRes;
      }

      final topRes = await Supabase.instance.client
          .from('top_factories')
          .select()
          .order('rank', ascending: true);

      if (topRes.isNotEmpty) {
        _topFactories = topRes;
      }
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
            Image.asset(
              'assets/img/logo.png',
              height: 28,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.factory, color: Color(0xFF006D44), size: 28),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'SABER KARBON',
                style: TextStyle(
                  color: Color(0xFF065F46),
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Shortcut Cepat ke Panel Admin MRV di AppBar
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: TextButton.icon(
              onPressed: () {
                setState(() => _selectedTabIndex = 2);
              },
              style: TextButton.styleFrom(
                backgroundColor: _selectedTabIndex == 2
                    ? const Color(0xFFEEF2FF)
                    : const Color(0xFFF3F4F6),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: Icon(
                Icons.admin_panel_settings_outlined,
                size: 16,
                color: _selectedTabIndex == 2
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFF4B5563),
              ),
              label: Text(
                'Panel Admin MRV',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _selectedTabIndex == 2
                      ? const Color(0xFF4F46E5)
                      : const Color(0xFF4B5563),
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE5E7EB), height: 1.0),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF10B981)),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCustomTabBar(),
                    const SizedBox(height: 20),
                    if (_selectedTabIndex == 0)
                      ..._buildDataPerusahaanContent()
                    else if (_selectedTabIndex == 1)
                      ..._buildNasionalContent()
                    else
                      ..._buildAdminMrvPolicyContent(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCustomTabBar() {
    return Container(
      height: 46,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _buildTabItem(
            index: 0,
            label: 'Perusahaan',
            activeColor: const Color(0xFF10B981),
          ),
          _buildTabItem(
            index: 1,
            label: 'Nasional (SIINas)',
            activeColor: const Color(0xFF059669),
          ),
          _buildTabItem(
            index: 2,
            label: 'Admin (MRV & Policy)',
            activeColor: const Color(0xFF4F46E5),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required String label,
    required Color activeColor,
  }) {
    final bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================
  // TAB 0: DATA PERUSAHAAN
  // ==========================================
  List<Widget> _buildDataPerusahaanContent() {
    final companyName = _companyData?['name'] ?? 'Perusahaan Belum Terdaftar';
    final currentEmission =
        _companyData?['current_emission']?.toString() ?? '12,450';
    final emissionStatus =
        _companyData?['emission_status']?.toString() ?? 'Mendekati Batas Kuota';
    final carbonIntensity =
        _companyData?['carbon_intensity']?.toString() ?? '0.18';
    final energyTrend =
        _companyData?['energy_efficiency_trend']?.toString() ?? '12';

    String dynamicRank = '2';
    if (_companyData != null && _topFactories.isNotEmpty) {
      final userCompanyId = _companyData!['id'];
      try {
        final fac = _topFactories.firstWhere(
          (f) => f['company_id'] == userCompanyId,
        );
        dynamicRank = fac['rank'].toString();
      } catch (e) {
        dynamicRank = _companyData?['national_rank']?.toString() ?? '2';
      }
    } else {
      dynamicRank = _companyData?['national_rank']?.toString() ?? '2';
    }

    final totalEmissionsNat =
        _nationalData?['total_emissions']?.toString() ?? '2.86';
    final trendPercentageNat =
        _nationalData?['trend_percentage']?.toString() ?? '35';

    return [
      const Text(
        'Data Pribadi Perusahaan',
        style: TextStyle(
          fontSize: 15,
          color: Color(0xFF4B5563),
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 12),

      // Card 1: Emisi Pabrik Bulan Ini
      _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'EMISI PABRIK BULAN INI',
              style: TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  currentEmission,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'tCO2',
                  style: TextStyle(fontSize: 16, color: Color(0xFF4B5563)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFDC2626),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      emissionStatus,
                      style: const TextStyle(
                        color: Color(0xFFDC2626),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bar_chart,
                    color: Color(0xFF10B981),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Intensitas Karbon',
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  carbonIntensity,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 6),
                const Text(
                  'tCO2/t',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.bolt,
                    color: Color(0xFF10B981),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Efisiensi Energi',
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '+$energyTrend%',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'vs. Last Month',
                  style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),

      const Text(
        'Konteks Industri Nasional',
        style: TextStyle(
          fontSize: 15,
          color: Color(0xFF4B5563),
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 12),

      // Card 4: Total Emisi Baja Nasional
      _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Total Emisi Baja Nasional',
              style: TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$totalEmissionsNat Juta Ton',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.trending_up,
                    color: Color(0xFFDC2626),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '+$trendPercentageNat% YoY',
                    style: const TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),

      // Card 5: Peringkat Efisiensi
      _buildCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'PERINGKAT EFISIENSI ANDA',
                style: TextStyle(
                  color: Color(0xFF4B5563),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),

            if (_companyData != null) ...[
              _buildRankItem(
                dynamicRank,
                companyName,
                '$carbonIntensity tCO2/t',
                true,
              ),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
            ],

            if (_topFactories.isNotEmpty)
              ..._topFactories.map((fac) {
                return Column(
                  children: [
                    _buildRankItem(
                      fac['rank']?.toString() ?? '0',
                      fac['name'] ?? 'Unknown',
                      '${fac['carbon_intensity']?.toString() ?? '0'} tCO2/t',
                      false,
                    ),
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  ],
                );
              })
            else ...[
              _buildRankItem('1', 'PT Krakatau', '0.12 tCO2/t', false),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              _buildRankItem('3', 'PT Gunung Garuda', '0.21 tCO2/t', false),
            ],

            const SizedBox(height: 8),
          ],
        ),
      ),
    ];
  }

  // ==========================================
  // TAB 1: NASIONAL (SIINas)
  // ==========================================
  List<Widget> _buildNasionalContent() {
    final totalEmissions =
        _nationalData?['total_emissions']?.toString() ?? '2.86';
    final trendPercentage =
        _nationalData?['trend_percentage']?.toString() ?? '35';
    final targetReduction =
        _nationalData?['target_reduction']?.toString() ?? '45';
    final registeredFactories =
        _nationalData?['registered_factories']?.toString() ?? '142';
    final avgCarbonIntensity =
        _nationalData?['avg_carbon_intensity']?.toString() ?? '0.15';

    int targetVal = 45;
    if (_nationalData != null && _nationalData!['target_reduction'] != null) {
      targetVal = (_nationalData!['target_reduction'] as num).toInt();
    }

    return [
      _buildCard(
        padding: EdgeInsets.zero,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'TOTAL EMISI BAJA NASIONAL',
                    style: TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$totalEmissions Juta\nTon',
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: Color(0xFFDC2626),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '+$trendPercentage% dalam 1 dekade (Tapio e = 0.12)',
                        style: const TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Positioned(
              right: -30,
              top: 10,
              child: Icon(
                Icons.public,
                size: 160,
                color: const Color(0xFFF3F4F6).withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),

      _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TARGET PENURUNAN 2030 (ENHANCED NDC)',
              style: TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$targetReduction%',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const Text(
                  'tercapai',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: targetVal,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                  Expanded(flex: 100 - targetVal, child: Container()),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),

      _buildCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.domain,
                color: Color(0xFF6B7280),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PABRIK TERDAFTAR',
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$registeredFactories fasilitas',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),

      _buildCard(
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.speed,
                color: Color(0xFF6B7280),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'INTENSITAS KARBON RATA-RATA',
                  style: TextStyle(
                    color: Color(0xFF4B5563),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$avgCarbonIntensity tCO2/t',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),

      _buildCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    size: 18,
                    color: Color(0xFF6B7280),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'TOP PABRIK PALING EFISIEN',
                    style: TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5E7EB)),

            if (_topFactories.isNotEmpty)
              ..._topFactories.map((fac) {
                return Column(
                  children: [
                    _buildTopFactoryItem(
                      fac['rank']?.toString() ?? '0',
                      fac['name'] ?? 'Unknown',
                      fac['location'] ?? '-',
                      '${fac['carbon_intensity']?.toString() ?? '0'} tCO2/t',
                    ),
                    const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  ],
                );
              })
            else ...[
              _buildTopFactoryItem(
                '1',
                'PT Krakatau Steel',
                'Cilegon, Banten',
                '0.08 tCO2/t',
              ),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              _buildTopFactoryItem(
                '2',
                'PT Gunung Raja Paksi',
                'Bekasi, Jawa Barat',
                '0.11 tCO2/t',
              ),
              const Divider(height: 1, color: Color(0xFFF3F4F6)),
              _buildTopFactoryItem(
                '3',
                'PT Bhirawa Steel',
                'Surabaya, Jawa Timur',
                '0.12 tCO2/t',
              ),
            ],

            const SizedBox(height: 8),
          ],
        ),
      ),
    ];
  }

  // ===========================================================================
  // TAB 2: PANEL SISI ADMIN / REGULATOR (MRV & POLICY BRIEF - LANGKAH 5)
  // ===========================================================================
  List<Widget> _buildAdminMrvPolicyContent() {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final numberFormatter = NumberFormat.decimalPattern('id_ID');

    // Simulasi Alokasi Dana Pajak Karbon Sektor Baja (UU HPP No. 7/2021 & Bursa Karbon)
    // Total kolam dana earmarking pajak karbon tahunan: Rp 1.200.000.000.000 (Rp 1,2 Triliun)
    const double totalCarbonPoolBillion = 1200.0; // Dalam Miliar Rupiah
    final double pilar1BudgetBillion =
        totalCarbonPoolBillion * (_pilar1BudgetPercent / 100.0);
    final double pilar2BudgetBillion =
        totalCarbonPoolBillion * ((100.0 - _pilar1BudgetPercent) / 100.0);

    // Estimasi output dampak kebijakan dari alokasi anggaran:
    // Pilar 1: Biaya sertifikasi & pelatihan vokasi Green Reskilling ~Rp 6 juta / pekerja
    final int reskilledWorkersCount =
        ((pilar1BudgetBillion * 1000000000) / 6000000).round();
    // Pilar 2: Biaya hibah mesin shredder/magnetic separator MRF UMKM ~Rp 1,5 Miliar / unit koperasi
    final int mrfUnitsFunded = (pilar2BudgetBillion / 1.5).round();
    final double scrapSupplyBoostPercent =
        (mrfUnitsFunded * 0.14).clamp(10.0, 52.0);

    final int approvedCount = _mrvQueueItems
        .where((item) => item['status_type'] == 'approved')
        .length;
    final int warningCount = _mrvQueueItems
        .where((item) => item['status_type'] == 'warning')
        .length;

    return [
      // 1. Header Banner Regulator (MRV & Policy Command Center)
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF312E81)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PANEL REGULATOR: MRV & POLICY BRIEF',
                        style: TextStyle(
                          color: Color(0xFF93C5FD),
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Kemenperin (SIINas) • KLHK (SRN-PPI) • ESDM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Pusat Pengawasan Measurement, Reporting, and Verification (MRV) Emisi Industri Baja, Sertifikasi MRF UMKM, dan Eksekusi 2 Pilar Policy Brief.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),
            // 3 Indikator Ringkasan Kajian Satria Data
            Row(
              children: [
                Expanded(
                  child: _buildAdminKpiPill(
                    label: 'Elastisitas Tapio',
                    value: 'e = 0.12',
                    sub: 'Weak Decoupling',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildAdminKpiPill(
                    label: 'Gap NZE 2060',
                    value: '5.300 Mt',
                    sub: 'BAU vs LCCP',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildAdminKpiPill(
                    label: 'Spasial Jenks',
                    value: 'GVF 0.97',
                    sub: '6,95 Jt Pekerja',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 20),

      // 2. Modul Antrean Verifikasi MRV (Measurement, Reporting, & Verification)
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              '1. Antrean Audit & Verifikasi MRV Nasional',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$approvedCount Disetujui • $warningCount Tindak Lanjut',
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF065F46),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 6),
      const Text(
        'Verifikasi laporan emisi pabrik (SIINas), kepatuhan K3 udara bersih (SDG 3), dan kelayakan subsidi MRF Koperasi Besi Tua UMKM.',
        style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
      ),
      const SizedBox(height: 12),

      ..._mrvQueueItems.asMap().entries.map((entry) {
        final int idx = entry.key;
        final Map<String, dynamic> item = entry.value;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildMrvAuditCard(idx, item),
        );
      }),

      const SizedBox(height: 16),

      // 3. Modul Simulasi Eksekusi 2 Pilar Policy Brief (Earmarking Pajak Karbon)
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFC7D2FE), width: 1.4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.policy_outlined,
                    color: Color(0xFF4F46E5),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '2. EKSEKUSI 2 PILAR POLICY BRIEF (EARMARKING)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F46E5),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Realokasi Dana Pajak Karbon (UU HPP No. 7/2021)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 22),
            const Text(
              'Geser proporsi alokasi Dana Insentif Dekarbonisasi Industri (Estimasi Pool Pajak Karbon Domestik Rp 1,20 Triliun/Tahun):',
              style: TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Pilar 1: Reskilling (${_pilar1BudgetPercent.toStringAsFixed(0)}%)',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    'Pilar 2: MRF UMKM (${(100 - _pilar1BudgetPercent).toStringAsFixed(0)}%)',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF059669),
                    ),
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF4F46E5),
                inactiveTrackColor: const Color(0xFF10B981),
                thumbColor: const Color(0xFF312E81),
              ),
              child: Slider(
                value: _pilar1BudgetPercent,
                min: 20,
                max: 80,
                divisions: 60,
                onChanged: (val) {
                  setState(() => _pilar1BudgetPercent = val);
                },
              ),
            ),
            const SizedBox(height: 8),

            // Kotak Dampak Pilar 1: Green Reskilling (Jenks Zona Merah)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'PILAR 1: VOKASI GREEN RESKILLING (SDG 4 & 8)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3730A3),
                          ),
                        ),
                      ),
                      Text(
                        'Rp ${pilar1BudgetBillion.toStringAsFixed(0)} Miliar',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Target Output: Melatih ulang ${numberFormatter.format(reskilledWorkersCount)} buruh tungku batu bara menjadi operator EAF digital & auditor emisi.',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Prioritas Spasial Jenks (GVF=0.9699): Jawa Timur (2,64 Jt pekerja), Jawa Tengah (1,88 Jt), Jawa Barat (1,71 Jt), dan Banten (250 Rb).',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF475569),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Kotak Dampak Pilar 2: Sirkularitas Scrap UMKM & MRF
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'PILAR 2: SIRKULARITAS SCRAP & MRF UMKM (SDG 9 & 13)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF065F46),
                          ),
                        ),
                      ),
                      Text(
                        'Rp ${pilar2BudgetBillion.toStringAsFixed(0)} Miliar',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Target Output: Pembangunan $mrfUnitsFunded Unit Material Recovery Facility (MRF) Koperasi UMKM (Pasokan Scrap EAF naik ke ${scrapSupplyBoostPercent.toStringAsFixed(1)}%).',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Menyediakan mesin shredder & pemisah magnetik agar besi tua rakyat memenuhi standar High-Grade (Fe > 98%) dan menggantikan impor scrap.',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF065F46),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // 4. Kartu Pemetaan Risiko Ketenagakerjaan Spasial (Jenks Natural Breaks)
      _buildCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    '3. PRIORITAS INTERVENSI SPASIAL (JENKS GVF = 0.9699)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4B5563),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedZoneFilter,
                    isDense: true,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Semua Zona Jenks',
                        child: Text('Semua Zona Jenks'),
                      ),
                      DropdownMenuItem(
                        value: 'Zona Merah (Episentrum)',
                        child: Text('Zona Merah (Episentrum)'),
                      ),
                      DropdownMenuItem(
                        value: 'Zona Kuning (Transisi)',
                        child: Text('Zona Kuning (Transisi)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => _selectedZoneFilter = val);
                      }
                    },
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            if (_selectedZoneFilter == 'Semua Zona Jenks' ||
                _selectedZoneFilter == 'Zona Merah (Episentrum)') ...[
              _buildSpatialZoneRow(
                zoneBadge: 'ZONA MERAH',
                badgeColor: const Color(0xFFDC2626),
                province: 'Jawa Timur (Episentrum #1 Nasional)',
                workers: '2.643.536 Pekerja • 925.985 Unit IMK',
                action: 'Prioritas Utama BLK Green Reskilling & 85 Unit MRF UMKM',
              ),
              const Divider(height: 16),
              _buildSpatialZoneRow(
                zoneBadge: 'ZONA MERAH',
                badgeColor: const Color(0xFFDC2626),
                province: 'Jawa Tengah & Jawa Barat',
                workers: '3.598.247 Pekerja Gabungan',
                action: 'Insentif Konversi Tungku Induksi/BF ke EAF & Sentra Scrap',
              ),
              const Divider(height: 16),
            ],
            if (_selectedZoneFilter == 'Semua Zona Jenks' ||
                _selectedZoneFilter == 'Zona Kuning (Transisi)') ...[
              _buildSpatialZoneRow(
                zoneBadge: 'ZONA KUNING',
                badgeColor: const Color(0xFFD97706),
                province: 'Banten, DKI Jakarta, Sumut, Sulsel',
                workers: 'Klaster Smelter Hulu & Pelabuhan Ekspor',
                action: 'Audit Kepatuhan EU CBAM 2026 & Subsidi Green Hydrogen (H2-DRI)',
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: 16),

      // Tombol Eksekusi Penerbitan SK Rekomendasi Policy Brief
      SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () {
            _showPolicyBriefSummaryDialog(
              context: context,
              pilar1Billion: pilar1BudgetBillion,
              pilar2Billion: pilar2BudgetBillion,
              workersReskilled: reskilledWorkersCount,
              mrfUnits: mrfUnitsFunded,
              currencyFormatter: currencyFormatter,
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          icon: const Icon(Icons.gavel_rounded, size: 19),
          label: const Text(
            'Terbitkan Keputusan MRV & Rekomendasi Policy Brief',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
      ),
    ];
  }

  Widget _buildAdminKpiPill({
    required String label,
    required String value,
    required String sub,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFBFDBFE),
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            sub,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 9,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMrvAuditCard(int index, Map<String, dynamic> item) {
    final String statusType = item['status_type'] ?? 'pending';
    Color badgeBg = const Color(0xFFFEF3C7);
    Color badgeTextCol = const Color(0xFF92400E);
    IconData badgeIcon = Icons.hourglass_top_rounded;

    if (statusType == 'approved') {
      badgeBg = const Color(0xFFECFDF5);
      badgeTextCol = const Color(0xFF065F46);
      badgeIcon = Icons.verified_rounded;
    } else if (statusType == 'warning') {
      badgeBg = const Color(0xFFFEE2E2);
      badgeTextCol = const Color(0xFF991B1B);
      badgeIcon = Icons.warning_amber_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusType == 'approved'
              ? const Color(0xFF6EE7B7)
              : (statusType == 'warning'
                    ? const Color(0xFFFECACA)
                    : const Color(0xFFE5E7EB)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item['id']} • ${item['entity_type']}',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6B7280),
                ),
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badgeIcon, size: 12, color: badgeTextCol),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          item['status'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: badgeTextCol,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item['entity_name'],
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${item['location']} | Rute: ${item['route']}',
            style: const TextStyle(fontSize: 11.5, color: Color(0xFF4B5563)),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Metrik: ${item['intensity']}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item['sdg_focus'],
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF047857),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      _mrvQueueItems[index]['status'] =
                          'SP-1 & Mandat Retrofit Diterbitkan';
                      _mrvQueueItems[index]['status_type'] = 'warning';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Surat Peringatan (SP-1) & instruksi audit K3/Scrubber dikirim ke ${item['entity_name']}.',
                        ),
                        backgroundColor: const Color(0xFFD97706),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFB45309),
                    side: const BorderSide(color: Color(0xFFF59E0B)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.gpp_maybe_outlined, size: 15),
                  label: const Text(
                    'Beri SP / Audit',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _mrvQueueItems[index]['status'] =
                          'Terverifikasi MRV & Sah';
                      _mrvQueueItems[index]['status_type'] = 'approved';
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${item['entity_name']} resmi disahkan dalam registri MRV Nasional!',
                        ),
                        backgroundColor: const Color(0xFF059669),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 15),
                  label: const Text(
                    'Setujui MRV',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpatialZoneRow({
    required String zoneBadge,
    required Color badgeColor,
    required String province,
    required String workers,
    required String action,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                province,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                zoneBadge,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          workers,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Rekomendasi Kebijakan: $action',
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF059669),
          ),
        ),
      ],
    );
  }

  void _showPolicyBriefSummaryDialog({
    required BuildContext context,
    required double pilar1Billion,
    required double pilar2Billion,
    required int workersReskilled,
    required int mrfUnits,
    required NumberFormat currencyFormatter,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.verified_user_rounded, color: Color(0xFF4F46E5)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'SK Rekomendasi Policy Brief & MRV Nasional',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ringkasan Eksekutif Keputusan Regulator (Berbasis 3 Lensa Analisis):',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '1. Peta Jalan Strong Decoupling (Tapio e < 0): Mengalihkan ${pilar1Billion.toStringAsFixed(0)} Miliar Rupiah dana Pajak Karbon untuk melatih ulang $workersReskilled pekerja tungku di Zona Merah Pulau Jawa (SDG 4 & SDG 8).',
                  style: const TextStyle(fontSize: 12, height: 1.35),
                ),
                const SizedBox(height: 8),
                Text(
                  '2. Sirkularitas 52% Scrap EAF: Mengalokasikan ${pilar2Billion.toStringAsFixed(0)} Miliar Rupiah untuk membiayai $mrfUnits unit Material Recovery Facility (MRF) di Koperasi UMKM Besi Tua (SDG 9 & SDG 13).',
                  style: const TextStyle(fontSize: 12, height: 1.35),
                ),
                const SizedBox(height: 8),
                const Text(
                  '3. Penegakan K3 & Lingkungan (SDG 3): Mewajibkan instalasi Wet Scrubber & Baghouse Filter bagi pabrik dengan intensitas > 1.0 tCO2/t.',
                  style: TextStyle(fontSize: 12, height: 1.35),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Dokumen Keputusan MRV & Policy Brief berhasil disahkan ke dalam sistem SIINas!',
                    ),
                    backgroundColor: Color(0xFF4F46E5),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
              ),
              child: const Text('Sahkan Kebijakan'),
            ),
          ],
        );
      },
    );
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildRankItem(
    String rank,
    String name,
    String value,
    bool isHighlighted,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isHighlighted ? const Color(0xFFF3F4F6) : Colors.transparent,
        border: isHighlighted
            ? const Border(left: BorderSide(color: Color(0xFF006D44), width: 3))
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              rank,
              style: TextStyle(
                color: isHighlighted
                    ? const Color(0xFF006D44)
                    : const Color(0xFF6B7280),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: const Color(0xFF111827),
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isHighlighted
                  ? const Color(0xFF10B981)
                  : const Color(0xFF4B5563),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopFactoryItem(
    String rank,
    String name,
    String location,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2FF),
              shape: BoxShape.circle,
            ),
            child: Text(
              rank,
              style: const TextStyle(
                color: Color(0xFF4F46E5),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                    fontSize: 13,
                  ),
                ),
                Text(
                  location,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF10B981),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
