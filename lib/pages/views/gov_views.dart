import 'package:flutter/material.dart';

/// ============================================================================
/// 1. PETA SPASIAL SEBARAN EMISI & PABRIK BAJA (PEMERINTAH / REGULATOR)
/// ============================================================================
class GovSpatialMapView extends StatefulWidget {
  const GovSpatialMapView({super.key});

  @override
  State<GovSpatialMapView> createState() => _GovSpatialMapViewState();
}

class _GovSpatialMapViewState extends State<GovSpatialMapView> {
  String _selectedRegionFilter = 'Semua Wilayah';

  final List<Map<String, dynamic>> _provincialData = [
    {
      'province': 'Jawa Timur',
      'island': 'Pulau Jawa',
      'cluster': 'Episentrum Zona Merah',
      'factories_count': 48,
      'total_emissions': '1.12 MtCO2e',
      'avg_intensity': 1.48, // tCO2/t
      'compliance_status': 'Perhatian Tinggi',
      'color': Color(0xFFDC2626), // Red
      'description':
          'Konsentrasi peleburan besi tua & induction furnace (Gresik, Surabaya, Sidoarjo, Mojokerto). Emisi debu PM2.5 & SOx mendesak ditangani.',
    },
    {
      'province': 'Jawa Barat & Banten',
      'island': 'Pulau Jawa',
      'cluster': 'Zona Transisi Hulu',
      'factories_count': 70,
      'total_emissions': '1.28 MtCO2e',
      'avg_intensity': 0.95,
      'compliance_status': 'Proses Transisi',
      'color': Color(0xFFD97706), // Amber
      'description':
          'Klaster terintegrasi blast furnace, DRI, dan EAF (Cilegon, Karawang, Bekasi). Sedang migrasi ke bauran gas & scrap daur ulang.',
    },
    {
      'province': 'Jawa Tengah & DIY',
      'island': 'Pulau Jawa',
      'cluster': 'Zona Sedang',
      'factories_count': 14,
      'total_emissions': '0.28 MtCO2e',
      'avg_intensity': 0.82,
      'compliance_status': 'Cukup Patuh',
      'color': Color(0xFF2563EB), // Blue
      'description':
          'Dominasi industri rolling mill dan fabrikasi baja konstruksi (Semarang, Kudus). Rata-rata emisi mendekati ambang batas CBAM.',
    },
    {
      'province': 'Luar Jawa (Sumatera, Kalimantan, Sulawesi)',
      'island': 'Luar Jawa',
      'cluster': 'Zona Smelter Khusus',
      'factories_count': 10,
      'total_emissions': '0.18 MtCO2e',
      'avg_intensity': 0.74,
      'compliance_status': 'Patuh Terkendali',
      'color': Color(0xFF16A34A), // Green
      'description':
          'Fasilitas pengolahan bijih primer & smelter terisolasi dengan akses potensi hidro/PLTA di Sumatera dan Sulawesi.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProvinces = _selectedRegionFilter == 'Semua Wilayah'
        ? _provincialData
        : _provincialData
            .where((item) => item['island'] == _selectedRegionFilter)
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Peta Spasial Emisi Logam',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Distribusi 142 Pabrik Baja Berbasis Jenks Natural Breaks',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu Peta Geospasial Grafis
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1B4B),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1E1B4B).withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.public, color: Color(0xFF818CF8), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'GEOSPASIAL HOTSPOT EMISI NASIONAL',
                            style: TextStyle(
                              color: Color(0xFFC7D2FE),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Text(
                          'Data 38 Provinsi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.map,
                            size: 54,
                            color: Color(0xFF818CF8),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '87% Emisi Terpusat di Koridor Industri Pulau Jawa',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Metode Analisis Spasial: Jenks Natural Breaks Optimization',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MapLegendItem(color: Color(0xFFDC2626), label: 'Zona Merah (>1.4)'),
                      _MapLegendItem(color: Color(0xFFD97706), label: 'Transisi (0.8-1.4)'),
                      _MapLegendItem(color: Color(0xFF16A34A), label: 'Lolos CBAM (<0.8)'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Filter Wilayah
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Klaster Regional Emisi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                DropdownButton<String>(
                  value: _selectedRegionFilter,
                  underline: const SizedBox(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4338CA),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Semua Wilayah', child: Text('Semua Wilayah')),
                    DropdownMenuItem(value: 'Pulau Jawa', child: Text('Pulau Jawa')),
                    DropdownMenuItem(value: 'Luar Jawa', child: Text('Luar Jawa')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedRegionFilter = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredProvinces.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = filteredProvinces[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: item['color'] as Color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  item['province'] as String,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: (item['color'] as Color).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item['compliance_status'] as String,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: item['color'] as Color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item['description'] as String,
                        style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFFF1F5F9), height: 1),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildMiniStat('Pabrik Terdaftar', '${item['factories_count']} Unit'),
                          _buildMiniStat('Emisi Tahunan', item['total_emissions'] as String),
                          _buildMiniStat(
                            'Intensitas Rata-rata',
                            '${item['avg_intensity']} tCO2/t',
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        const SizedBox(height: 2),
        Text(
          val,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }
}

class _MapLegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _MapLegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 10.5),
        ),
      ],
    );
  }
}

/// ============================================================================
/// 2. POLICY BRIEF & 4 PILAR SDGS (PEMERINTAH / REGULATOR)
/// ============================================================================
class GovPolicyBriefView extends StatefulWidget {
  const GovPolicyBriefView({super.key});

  @override
  State<GovPolicyBriefView> createState() => _GovPolicyBriefViewState();
}

class _GovPolicyBriefViewState extends State<GovPolicyBriefView> {
  double _budgetSplit = 55.0; // 55% Reskilling, 45% Bantuan Mesin MRF Scrap

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Policy Brief & SDGs',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Rekomendasi Kebijakan Dekarbonisasi Hard-to-Abate 2060',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu Ringkasan Eksekutif
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF312E81), Color(0xFF4338CA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.description, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'EXECUTIVE POLICY BRIEF #01/2026',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Baja Hijau atau Emisi Biru: Jalan Tengah Dekarbonisasi Logam Nasional',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Mengintegrasikan model peramalan deret waktu (Sectoral Hybrid Regression, GPR, & GM(1,1)) untuk memandu kebijakan insentif pajak karbon dan perlindungan rantai pasok UMKM scrap.',
                    style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Mengunduh Policy Brief Resmi (PDF Kemenperin-KLHK)...',
                          ),
                          backgroundColor: Color(0xFF4338CA),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF312E81),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.download, size: 16),
                    label: const Text(
                      'Unduh Naskah Kebijakan (PDF)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 4 Pilar SDGs
            const Text(
              'Integrasi 4 Pilar SDGs (Sustainable Development Goals)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),

            _buildSdgCard(
              sdgNumber: '13',
              title: 'SDG 13: Penanganan Perubahan Iklim',
              target: 'Batas Emisi Maksimal 0.80 tCO2/t Baja',
              desc:
                  'Mengurangi risiko pengenaan pajak ekspor CBAM Uni Eropa dan memastikan lintasan dekarbonisasi menuju Net Zero Emission 2060.',
              color: const Color(0xFF3F7E44),
            ),
            const SizedBox(height: 10),
            _buildSdgCard(
              sdgNumber: '9',
              title: 'SDG 9: Industri, Inovasi, & Infrastruktur',
              target: 'Adopsi Teknologi Rendah Emisi (EAF & DRI)',
              desc:
                  'Modernisasi pabrik baja nasional dengan rute Electric Arc Furnace bertenaga EBT dan hidrogen hijau.',
              color: const Color(0xFFFD6925),
            ),
            const SizedBox(height: 10),
            _buildSdgCard(
              sdgNumber: '3',
              title: 'SDG 3: Kehidupan Sehat & Sejahtera',
              target: 'Reduksi Polusi Udara PM2.5 & Sulfur',
              desc:
                  'Kewajiban pemasangan filter cerobong basah (wet scrubber) di kawasan peleburan baja Jawa Timur untuk menekan penyakit ISPA.',
              color: const Color(0xFF4C9F38),
            ),
            const SizedBox(height: 10),
            _buildSdgCard(
              sdgNumber: '4',
              title: 'SDG 4: Pendidikan & Pelatihan Berkualitas',
              target: 'Green Reskilling 12.400 Pekerja Baja',
              desc:
                  'Pelatihan kejuruan operasional teknologi hijau dan manajemen material scrap sirkular bagi tenaga kerja industri & UMKM.',
              color: const Color(0xFFC5192D),
            ),

            const SizedBox(height: 24),

            // Simulator Anggaran
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Simulator Alokasi Dana Transisi Hijau (APBN/Dana Karbon)',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Proporsi Pelatihan Tenaga Kerja (Pendidikan): ${_budgetSplit.toInt()}%  |  Bantuan Mesin MRF UMKM: ${(100 - _budgetSplit).toInt()}%',
                    style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                  ),
                  Slider(
                    value: _budgetSplit,
                    min: 20.0,
                    max: 80.0,
                    divisions: 12,
                    activeColor: const Color(0xFF4338CA),
                    onChanged: (val) {
                      setState(() => _budgetSplit = val);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pendidikan: Rp ${(_budgetSplit * 1.8).toStringAsFixed(1)} Miliar',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4338CA),
                        ),
                      ),
                      Text(
                        'UMKM: Rp ${((100 - _budgetSplit) * 1.8).toStringAsFixed(1)} Miliar',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF059669),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSdgCard({
    required String sdgNumber,
    required String title,
    required String target,
    required String desc,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              sdgNumber,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Target: $target',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// 3. AUDIT & VALIDASI MRV NASIONAL (PEMERINTAH / REGULATOR)
/// ============================================================================
class GovMrvAuditView extends StatefulWidget {
  const GovMrvAuditView({super.key});

  @override
  State<GovMrvAuditView> createState() => _GovMrvAuditViewState();
}

class _GovMrvAuditViewState extends State<GovMrvAuditView> {
  final List<Map<String, dynamic>> _auditQueue = [
    {
      'id': 'MRV-2026-01',
      'factory_name': 'PT Krakatau Baja Terpadu',
      'siinas_id': 'SIINAS #KRK-01',
      'location': 'Cilegon, Banten',
      'route': 'Direct Reduced Iron (DRI) -> EAF',
      'intensity': 0.76, // tCO2/t
      'status': 'Menunggu Validasi MRV',
      'verified': false,
    },
    {
      'id': 'MRV-2026-02',
      'factory_name': 'PT Smelter Induksi Jaya',
      'siinas_id': 'SIINAS #SIJ-09',
      'location': 'Gresik, Jawa Timur',
      'route': 'Induction Furnace Tanpa Scrubber',
      'intensity': 1.68,
      'status': 'Peringatan K3 Polusi PM2.5',
      'verified': false,
    },
    {
      'id': 'MRV-2026-03',
      'factory_name': 'Koperasi Scrap Besi Mandiri',
      'siinas_id': 'SIINAS #KSM-03',
      'location': 'Surabaya, Jawa Timur',
      'route': 'Material Recovery Facility (MRF)',
      'intensity': 0.12,
      'status': 'Menunggu Sertifikasi Hijau',
      'verified': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Panel Audit & Validasi MRV',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Pengawasan Kepatuhan Emisi Pabrik Baja & Sertifikasi Hijau',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _auditQueue.length,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final item = _auditQueue[index];
          final isVerified = item['verified'] == true;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isVerified
                    ? const Color(0xFF86EFAC)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['id'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4338CA),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isVerified
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isVerified
                            ? 'Lolos Verifikasi MRV'
                            : (item['status'] as String),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isVerified
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item['factory_name'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item['siinas_id']} • ${item['location']}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rute: ${item['route']}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF334155)),
                      ),
                      Text(
                        '${item['intensity']} tCO2/t',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: (item['intensity'] as double) <= 0.80
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isVerified) ...[
                      OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Surat Peringatan & Rekomendasi dikirim ke ${item['factory_name']}!',
                              ),
                              backgroundColor: const Color(0xFFDC2626),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFFCA5A5)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        child: const Text('Kirim Peringatan', style: TextStyle(fontSize: 11)),
                      ),
                      const SizedBox(width: 8),
                    ],
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          item['verified'] = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Laporan ${item['factory_name']} berhasil diverifikasi resmi!',
                            ),
                            backgroundColor: const Color(0xFF16A34A),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isVerified
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF4338CA),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      icon: Icon(
                        isVerified ? Icons.check : Icons.verified,
                        size: 14,
                      ),
                      label: Text(
                        isVerified ? 'Terverifikasi' : 'Verifikasi MRV',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
