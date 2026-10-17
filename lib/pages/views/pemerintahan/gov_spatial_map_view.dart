import 'package:flutter/material.dart';

/// ============================================================================
/// PETA SPASIAL SEBARAN EMISI & PABRIK BAJA (PEMERINTAH / REGULATOR)
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
      'color': const Color(0xFFDC2626), // Red
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
      'color': const Color(0xFFD97706), // Amber
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
      'color': const Color(0xFF2563EB), // Blue
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
      'color': const Color(0xFF16A34A), // Green
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
