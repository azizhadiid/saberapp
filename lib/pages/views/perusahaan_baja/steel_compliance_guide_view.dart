import 'package:flutter/material.dart';

/// ============================================================================
/// PANDUAN REGULASI & KEPATUHAN EMISI (PERUSAHAAN BAJA)
/// ============================================================================
class SteelComplianceGuideView extends StatelessWidget {
  const SteelComplianceGuideView({super.key});

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
              'Panduan Regulasi & Insentif',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Kepatuhan Standar Emisi & Fasilitas Fiskal Industri',
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
            // Banner Kepatuhan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF065F46), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield_outlined, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'STATUS AMBANG BATAS REGULASI',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Ambang Batas Maksimal: 0.80 tCO2/t Baja',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Pabrik dengan intensitas di bawah 0.80 tCO2/t bebas dari denda pajak karbon nasional & tarif penyesuaian batas emisi CBAM Uni Eropa.',
                    style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Insentif Pemerintah yang Dapat Diklaim',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),

            _buildIncentiveCard(
              title: 'Tax Allowance Konversi EAF & Gas',
              agency: 'Kemenperin & Ditjen Pajak Kemenkeu',
              desc:
                  'Pengurangan penghasilan neto sebesar 30% dari jumlah penanaman modal mesin Electric Arc Furnace bertenaga gas/EBT selama 6 tahun.',
              icon: Icons.percent,
              color: const Color(0xFF059669),
            ),
            const SizedBox(height: 10),
            _buildIncentiveCard(
              title: 'Pembebasan Bea Masuk Mesin Hijau',
              agency: 'Direktorat Jenderal Bea dan Cukai',
              desc:
                  'Fasilitas pembebasan bea masuk impor untuk mesin pemurni emisi cerobong (bag filter, wet scrubber, dan continuous emission monitor).',
              icon: Icons.account_balance,
              color: const Color(0xFF0284C7),
            ),
            const SizedBox(height: 10),
            _buildIncentiveCard(
              title: 'Super Tax Deduction Vokasi Hijau',
              agency: 'Peraturan Pemerintah No. 45/2019',
              desc:
                  'Insentif pengurangan pajak hingga 200% atas biaya pelatihan dan sertifikasi green reskilling pekerja operasional tungku peleburan rendah emisi.',
              icon: Icons.school,
              color: const Color(0xFFD97706),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncentiveCard({
    required String title,
    required String agency,
    required String desc,
    required IconData icon,
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
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  agency,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                    height: 1.4,
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
