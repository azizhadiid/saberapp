import 'package:flutter/material.dart';

/// ============================================================================
/// POLICY BRIEF & 4 PILAR SDGS (PEMERINTAH / REGULATOR)
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
