import 'package:flutter/material.dart';

/// ============================================================================
/// KEMITRAAN & STANDAR MUTU DEKARBONISASI (UMKM & PERUSAHAAN HIJAU)
/// ============================================================================
class UmkmPartnershipView extends StatelessWidget {
  const UmkmPartnershipView({super.key});

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
              'Standar & Kemitraan Sirkular',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Pedoman Mutu Scrap SNI & Program Akselerasi UMKM',
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
            // Banner SNI & Sortir MRF
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.workspace_premium, color: Color(0xFF16A34A), size: 36),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Standar SNI 07-0052 Scrap Logam',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF166534),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Pabrik baja rute EAF hanya menerima scrap dengan pemilahan MRF bersertifikat untuk mencegah ledakan tungku & slag berlebih.',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF15803D)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              '3 Pilar Kualifikasi Pasokan UMKM',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),

            _buildPillarCard(
              icon: Icons.science_outlined,
              title: 'Kemurnian Fe > 98% & Cu < 0.1%',
              desc:
                  'Kadar pengotor tembaga (Cu) dan timbal (Pb) harus sangat rendah agar baja tulangan dan pelat yang dihasilkan tidak retak panas (hot shortness).',
              badge: 'Kriteria Mutu',
              badgeColor: const Color(0xFF0284C7),
            ),
            const SizedBox(height: 10),
            _buildPillarCard(
              icon: Icons.cleaning_services_outlined,
              title: 'Proses Sortir MRF (Material Recovery)',
              desc:
                  'Bebas dari kontaminan non-logam seperti oli, plastik, cat, tanah, dan serbuk basah yang berpotensi memicu emisi polusi sulfur berlebih.',
              badge: 'Standar Operasi',
              badgeColor: const Color(0xFF059669),
            ),
            const SizedBox(height: 10),
            _buildPillarCard(
              icon: Icons.account_balance_outlined,
              title: 'Fasilitas KUR Hijau & Bantuan Shredder',
              desc:
                  'Program pendanaan berbunga rendah dari pemerintah bagi koperasi besi tua untuk membeli mesin baler press & shredder hidrolik berkapasitas 50 ton/hari.',
              badge: 'Bantuan Finansial',
              badgeColor: const Color(0xFFD97706),
            ),

            const SizedBox(height: 24),

            // Direktori Pabrik Mitra
            const Text(
              'Direktori 142 Pabrik Baja Mitra Penerima Scrap',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildFactoryRow('PT Krakatau Steel (Persero) Tbk', 'Cilegon, Banten', 'EAF & DRI', 'Aktif'),
                  const Divider(color: Color(0xFFF1F5F9), height: 16),
                  _buildFactoryRow('PT Gunung Raja Paksi Tbk', 'Cikarang, Bekasi', 'EAF High-Cap', 'Aktif'),
                  const Divider(color: Color(0xFFF1F5F9), height: 16),
                  _buildFactoryRow('PT Bhirawa Steel', 'Surabaya, Jawa Timur', 'EAF & Rolling Mill', 'Aktif'),
                  const Divider(color: Color(0xFFF1F5F9), height: 16),
                  _buildFactoryRow('PT Lautan Steel Indonesia', 'Tangerang, Banten', 'Induction & EAF', 'Aktif'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillarCard({
    required IconData icon,
    required String title,
    required String desc,
    required String badge,
    required Color badgeColor,
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
              color: badgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: badgeColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
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

  Widget _buildFactoryRow(String name, String loc, String tech, String status) {
    return Row(
      children: [
        const Icon(Icons.business, size: 18, color: Color(0xFF0284C7)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                '$loc • Rute: $tech',
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF16A34A),
            ),
          ),
        ),
      ],
    );
  }
}
