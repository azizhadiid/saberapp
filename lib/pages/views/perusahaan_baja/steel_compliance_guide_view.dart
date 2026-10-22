import 'package:flutter/material.dart';
import '../pemerintahan/policy_brief_reader_page.dart';

/// ============================================================================
/// POLICY BRIEF & PANDUAN REGULASI KHUSUS PERUSAHAAN BAJA (STEEL INDUSTRY)
/// MENYAJIKAN BUTIR REKOMENDASI KEBIJAKAN, INSENTIF FISKAL & KEPATUHAN CBAM
/// ============================================================================
class SteelComplianceGuideView extends StatelessWidget {
  const SteelComplianceGuideView({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryEmerald = Color(0xFF059669);
    const darkNavy = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: darkNavy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Policy Brief Perusahaan Baja',
              style: TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: darkNavy,
              ),
            ),
            Text(
              'Rekomendasi Kebijakan, Fasilitas Fiskal & Kepatuhan CBAM',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==============================================================
            // 1. BANNER STATUS AMBANG BATAS & KEPATUHAN CBAM
            // ==============================================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF064E3B), Color(0xFF047857)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF064E3B).withValues(alpha: 0.18),
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
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.shield_outlined, color: Colors.white, size: 18),
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'AMBANG BATAS RESMI PERDAGANGAN GLOBAL',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Ambang Batas Maksimal: 0.80 tCO2/t Baja',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pabrik baja yang berhasil menekan intensitas karbon di bawah 0.80 tCO2/t bebas denda tarif penyesuaian perbatasan karbon (CBAM Uni Eropa) serta berhak atas insentif fiskal dekarbonisasi nasional.',
                    style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.4),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==============================================================
            // 2. EMPAT BUTIR REKOMENDASI KEBIJAKAN UNTUK PABRIK BAJA
            // ==============================================================
            const Text(
              'Rekomendasi Strategis untuk Perusahaan Baja',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Disarikan dari Naskah Kebijakan Kemenperin & BPPHLHK 2026',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),

            _buildActionPoint(
              number: '1',
              title: 'Substitusi Bahan Baku Scrap Sirkular di Tanur EAF',
              desc:
                  'Tingkatkan porsi scrap hingga minimal 52% pada tanur Electric Arc Furnace (EAF). Substitusi ini memangkas emisi primer (Scope 1) hingga 50% dibandingkan tanur konvensional Blast Furnace (BF-BOF).',
              tag: 'Sirkularitas Logam',
              tagColor: const Color(0xFF059669),
            ),
            const SizedBox(height: 10),

            _buildActionPoint(
              number: '2',
              title: 'Kemitraan UMKM Scrap & Pembebasan PPh Pasal 22',
              desc:
                  'Manfaatkan fasilitas pembebasan PPh Pasal 22 bagi pabrik baja yang menyerap scrap dari depo/koperasi UMKM lokal yang telah lolos standardisasi MRV kadar pengotor Cu < 0.05%.',
              tag: 'Insentif Pajak',
              tagColor: const Color(0xFF2563EB),
            ),
            const SizedBox(height: 10),

            _buildActionPoint(
              number: '3',
              title: 'Integrasi CEMS Digital & Verifikasi SIINas',
              desc:
                  'Pabrik dengan kapasitas di atas 50.000 ton/tahun wajib memasang Continuous Emission Monitoring System (CEMS) terhubung langsung ke dashboard SIINas untuk mempermudah audit akreditasi MRV.',
              tag: 'Mandatori Regulasi',
              tagColor: const Color(0xFFD97706),
            ),
            const SizedBox(height: 10),

            _buildActionPoint(
              number: '4',
              title: 'Pemanfaatan Diskon Green Tariff Listrik PLN',
              desc:
                  'Pabrik yang memperoleh status "MRV Disetujui" berhak mengajukan tarif listrik hijau preferensial (Green Tariff PLN) dari sumber energi terbarukan guna menekan emisi listrik Scope 2 hingga 35%.',
              tag: 'Efisiensi Energi',
              tagColor: const Color(0xFF7C3AED),
            ),

            const SizedBox(height: 22),

            // ==============================================================
            // 3. FASILITAS INSENTIF FISKAL PEMERINTAH
            // ==============================================================
            const Text(
              'Fasilitas Insentif Fiskal yang Dapat Diklaim',
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),

            _buildIncentiveCard(
              title: 'Tax Allowance Konversi EAF & Gas',
              agency: 'Kemenperin & Ditjen Pajak Kemenkeu',
              desc:
                  'Pengurangan penghasilan neto sebesar 30% dari jumlah penanaman modal mesin Electric Arc Furnace bertenaga gas/EBT selama 6 tahun (5% per tahun).',
              icon: Icons.percent,
              color: const Color(0xFF059669),
            ),
            const SizedBox(height: 10),

            _buildIncentiveCard(
              title: 'Pembebasan Bea Masuk Mesin Hijau',
              agency: 'Direktorat Jenderal Bea dan Cukai',
              desc:
                  'Pembebasan bea masuk impor untuk mesin pemurni emisi cerobong (bag filter, wet scrubber, dan continuous emission monitor CEMS).',
              icon: Icons.account_balance,
              color: const Color(0xFF0284C7),
            ),
            const SizedBox(height: 10),

            _buildIncentiveCard(
              title: 'Super Tax Deduction Vokasi Hijau',
              agency: 'Peraturan Pemerintah No. 45/2019',
              desc:
                  'Pengurangan pajak hingga 200% atas biaya pelatihan dan sertifikasi green reskilling pekerja operasional tungku peleburan rendah emisi.',
              icon: Icons.school,
              color: const Color(0xFFD97706),
            ),

            const SizedBox(height: 24),

            // ==============================================================
            // 4. TOMBOL BUKA DOKUMEN POLICY BRIEF LENGKAP NEGARA
            // ==============================================================
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryEmerald,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Naskah Kebijakan Lengkap',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF064E3B),
                              ),
                            ),
                            Text(
                              'Dokumen Resmi Kemenperin & BPPHLHK 2026',
                              style: TextStyle(fontSize: 11, color: Color(0xFF047857)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ingin meninjau naskah kebijakan eksekutif selengkapnya beserta dasar hukum, analisis spasial SIINas, dan simulasi alokasi dana transisi hijau?',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF065F46), height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PolicyBriefReaderPage(budgetSplit: 50.0),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryEmerald,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      icon: const Icon(Icons.menu_book_rounded, size: 18),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Baca Naskah Kebijakan Lengkap & Cetak PDF',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildActionPoint({
    required String number,
    required String title,
    required String desc,
    required String tag,
    required Color tagColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: tagColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              number,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: tagColor),
            ),
          ),
          const SizedBox(width: 12),
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
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: tagColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: tagColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
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

  Widget _buildIncentiveCard({
    required String title,
    required String agency,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  agency,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11.5,
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
