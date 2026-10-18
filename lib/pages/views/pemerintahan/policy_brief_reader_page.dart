import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'policy_brief_pdf_service.dart';

/// ============================================================================
/// HALAMAN PEMBACA NASKAH KEBIJAKAN EKSEKUTIF (IN-APP POLICY BRIEF READER)
/// DIDESAIN LAYAKNYA DOKUMEN RESMI NEGARA (KOP SURAT, TABEL, PENELITIAN, TTD)
/// ============================================================================
class PolicyBriefReaderPage extends StatelessWidget {
  final double budgetSplit;

  const PolicyBriefReaderPage({
    super.key,
    required this.budgetSplit,
  });

  @override
  Widget build(BuildContext context) {
    const primaryIndigo = Color(0xFF059669);
    const darkNavy = Color(0xFF064E3B);

    final double educationBudget = budgetSplit * 1.8;
    final double umkmBudget = (100 - budgetSplit) * 1.8;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate desk background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Naskah Kebijakan Strategis Eksekutif',
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'PB.01/MENPERIN-KLHK/DEKARB-BAJA/X/2026',
              style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () async {
              try {
                await Printing.layoutPdf(
                  name: 'Policy_Brief_Dekarbonisasi_Baja_Nasional_2026.pdf',
                  onLayout: (format) async =>
                      await PolicyBriefPdfService.generatePdf(budgetSplit: budgetSplit),
                );
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Fungsi cetak native memerlukan restart aplikasi (flutter run).',
                      ),
                      backgroundColor: Color(0xFFD97706),
                    ),
                  );
                }
              }
            },
            icon: const Icon(Icons.print_outlined, color: primaryIndigo),
            tooltip: 'Cetak / Unduh PDF',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 720),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==============================================================
                // 1. KOP SURAT RESMI LEMBAGA NEGARA
                // ==============================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Image.asset(
                        'assets/img/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.eco,
                          color: primaryIndigo,
                          size: 28,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'KEMENTERIAN PERINDUSTRIAN REPUBLIK INDONESIA',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                              letterSpacing: 0.2,
                            ),
                          ),
                          Text(
                            'KEMENTERIAN LINGKUNGAN HIDUP DAN KEHUTANAN RI',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'SATUAN TUGAS DEKARBONISASI INDUSTRI LOGAM (SABER KARBON 2026)',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: primaryIndigo,
                            ),
                          ),
                          Text(
                            'Jl. Jend. Gatot Subroto Kav. 52-53, Jakarta 12950 • Portal Terpadu: siinas.kemenperin.go.id',
                            style: TextStyle(fontSize: 8, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(thickness: 1.8, color: Color(0xFF0F172A), height: 1),
                const SizedBox(height: 2),
                const Divider(thickness: 0.6, color: Color(0xFF0F172A), height: 1),
                const SizedBox(height: 16),

                // ==============================================================
                // 2. KOTAK INFORMASI NASKAH
                // ==============================================================
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'NOMOR: PB.01/MENPERIN-KLHK/DEKARB-BAJA/X/2026',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: primaryIndigo,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDC2626),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'DOKUMEN KEBIJAKAN STRATEGIS • EKSEKUTIF',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'BAJA HIJAU ATAU EMISI BIRU: JALAN TENGAH DEKARBONISASI INDUSTRI LOGAM NASIONAL MENUJU NZE 2060 DAN KESIAPAN PASAR CBAM',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: darkNavy,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sasaran Regulasi: ',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Menko Perekonomian, Menperin RI, Menteri LHK RI, BPDLH, dan Pengurus Asosiasi Baja (IISIA)',
                              style: TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ==============================================================
                // 3. BAB I: RINGKASAN EKSEKUTIF
                // ==============================================================
                _buildHeaderSection('I. RINGKASAN EKSEKUTIF & URGENSI CBAM 2026'),
                const Text(
                  '1. Industri besi dan baja merupakan sektor vital penopang pembangunan infrastruktur nasional. Namun, sektor ini menyumbang intensitas emisi gas rumah kaca (GRK) terbesar dalam klaster hard-to-abate di Indonesia dengan total emisi terdaftar mencapai 2.86 MtCO2e.\n\n'
                  '2. Mulai 2026, pemberlakuan penuh mekanisme tarif karbon Uni Eropa (Carbon Border Adjustment Mechanism / CBAM) dengan ambang batas acuan 0.80 tCO2/t baja cair menempatkan industri baja nasional pada risiko disinsentif ekspor sebesar Rp 180 Miliar per tahun bila tidak segera melakukan modernisasi rute teknologi peleburan.\n\n'
                  '3. Naskah kebijakan ini merekomendasikan strategi jalan tengah: percepatan transisi dari rute energi fosil (Blast Furnace & Induction Furnace) ke rute sirkular Electric Arc Furnace (EAF) berbasis bahan baku scrap lokal, didukung standardisasi bahan baku UMKM serta sistem audit MRV digital terintegrasi SIINas.',
                  style: TextStyle(fontSize: 10.5, color: Color(0xFF334155), height: 1.5),
                ),
                const SizedBox(height: 18),

                // ==============================================================
                // 4. BAB II: ANALISIS DIAGNOSTIK DATA SIINAS
                // ==============================================================
                _buildHeaderSection('II. ANALISIS DIAGNOSTIK EMISI & FAKTA LAPANGAN (DATA SIINAS)'),
                const Text(
                  'Berdasarkan audit spasial platform SIINas terhadap 142 fasilitas pabrik baja terdaftar di Indonesia, ditemukan ketimpangan rute emisi antar-wilayah:',
                  style: TextStyle(fontSize: 10.5, color: Color(0xFF334155), height: 1.4),
                ),
                const SizedBox(height: 8),

                // Tabel Ringkasan Spasial
                Table(
                  border: TableBorder.all(color: const Color(0xFFCBD5E1), width: 0.8),
                  columnWidths: const {
                    0: FlexColumnWidth(3),
                    1: FlexColumnWidth(4),
                    2: FlexColumnWidth(2.5),
                    3: FlexColumnWidth(3),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: darkNavy),
                      children: [
                        _buildTableCell('Klaster Wilayah', isHeader: true),
                        _buildTableCell('Dominasi Rute Teknologi', isHeader: true),
                        _buildTableCell('Intensitas Rata-rata', isHeader: true),
                        _buildTableCell('Status Kepatuhan CBAM', isHeader: true),
                      ],
                    ),
                    TableRow(
                      children: [
                        _buildTableCell('Jawa Timur (48 Pabrik)'),
                        _buildTableCell('Induction Furnace & Scrap Murahan'),
                        _buildTableCell('1.48 tCO2/t'),
                        _buildTableCell('ZONA MERAH (Perlu Tindakan)', textColor: const Color(0xFFDC2626)),
                      ],
                    ),
                    TableRow(
                      decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                      children: [
                        _buildTableCell('Jawa Barat & Banten (70 Pabrik)'),
                        _buildTableCell('Terpadu: Blast Furnace, DRI & EAF'),
                        _buildTableCell('0.95 tCO2/t'),
                        _buildTableCell('ZONA KUNING (Masa Transisi)', textColor: const Color(0xFFD97706)),
                      ],
                    ),
                    TableRow(
                      children: [
                        _buildTableCell('Jawa Tengah & DIY (14 Pabrik)'),
                        _buildTableCell('Rolling Mill & Reheating Furnace'),
                        _buildTableCell('0.82 tCO2/t'),
                        _buildTableCell('ZONA AMAN TERKENDALI', textColor: const Color(0xFF2563EB)),
                      ],
                    ),
                    TableRow(
                      decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                      children: [
                        _buildTableCell('Luar Jawa (10 Smelter)'),
                        _buildTableCell('Smelter Primer & EBT Hidro'),
                        _buildTableCell('0.74 tCO2/t'),
                        _buildTableCell('LOLOS AMBANG BATAS (<0.80)', textColor: const Color(0xFF16A34A)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ==============================================================
                // 5. BAB III: INTEGRASI 4 PILAR SDGS
                // ==============================================================
                _buildHeaderSection('III. PENYELARASAN DENGAN 4 PILAR SDGS INDONESIA'),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildInAppSdgCard(
                        code: 'SDG 13',
                        title: 'Aksi Perubahan Iklim',
                        desc: 'Penurunan intensitas karbon menuju ambang batas 0.80 tCO2/t untuk mendukung komitmen NDC 2030.',
                        color: const Color(0xFF3F7E44),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInAppSdgCard(
                        code: 'SDG 9',
                        title: 'Industri & Inovasi',
                        desc: 'Modernisasi fasilitas peleburan konvensional ke rute EAF efisien dan integrasi CEMS cerobong digital.',
                        color: const Color(0xFFFD6925),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildInAppSdgCard(
                        code: 'SDG 3',
                        title: 'Kesehatan Masyarakat',
                        desc: 'Pemasangan wet scrubber pada cerobong industri peleburan di Jawa Timur untuk menekan partikulat PM2.5 & ISPA.',
                        color: const Color(0xFF4C9F38),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildInAppSdgCard(
                        code: 'SDG 4',
                        title: 'Pendidikan & Pelatihan',
                        desc: 'Pelatihan Green Reskilling bagi 12.400 pekerja baja & kemitraan UMKM scrap dalam sertifikasi mutu sirkular.',
                        color: const Color(0xFFC5192D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // ==============================================================
                // 6. BAB IV: REKOMENDASI KEBIJAKAN STRATEGIS
                // ==============================================================
                _buildHeaderSection('IV. TIGA PILAR REKOMENDASI KEBIJAKAN KONKRET'),
                _buildBulletRecommendation(
                  number: '1',
                  title: 'Standardisasi Mutu Scrap Nasional & Kemitraan Sirkular UMKM',
                  content:
                      'Menerbitkan Peraturan Bersama Kemenperin-KLHK tentang Standar Baku Mutu Scrap Logam Sirkular (bebas tramp elements) serta pembebasan PPh Pasal 22 bagi pabrik yang bermitra resmi dengan koperasi UMKM scrap binaan.',
                ),
                const SizedBox(height: 8),
                _buildBulletRecommendation(
                  number: '2',
                  title: 'Mandatori CEMS Digital & Akreditasi MRV Melalui SIINas',
                  content:
                      'Mewajibkan pabrik berkapasitas di atas 50.000 ton/tahun memasang CEMS terhubung langsung ke dashboard SIINas. Pabrik yang memperoleh status "MRV Disetujui" diberikan diskon tarif listrik hijau (Green Tariff PLN).',
                ),
                const SizedBox(height: 8),
                _buildBulletRecommendation(
                  number: '3',
                  title: 'Alokasi Dana Transisi Hijau APBN / Nilai Ekonomi Karbon (NEK)',
                  content:
                      'Mengalokasikan penerimaan pajak karbon sektor industri untuk mendanai modernisasi mesin scrap UMKM serta program reskilling tenaga kerja industri baja lokal.',
                ),
                const SizedBox(height: 14),

                // Kotak Simulasi Fiskal
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'SIMULASI ALOKASI ANGGARAN TRANSISI HIJAU (DANA KARBON / APBN):',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: darkNavy,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '• Porsi Pendidikan & Reskilling Tenaga Kerja (${budgetSplit.toInt()}%)',
                            style: const TextStyle(fontSize: 10, color: Color(0xFF334155)),
                          ),
                          Text(
                            'Rp ${educationBudget.toStringAsFixed(1)} Miliar',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: primaryIndigo,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '• Porsi Bantuan Mesin & Gudang Scrap UMKM (${(100 - budgetSplit).toInt()}%)',
                            style: const TextStyle(fontSize: 10, color: Color(0xFF334155)),
                          ),
                          Text(
                            'Rp ${umkmBudget.toStringAsFixed(1)} Miliar',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // ==============================================================
                // 7. ROADMAP & LEMBAR PENGESAHAN
                // ==============================================================
                _buildHeaderSection('V. ROADMAP TAHAPAN AKSELERASI (2026 - 2030)'),
                Table(
                  border: TableBorder.all(color: const Color(0xFFCBD5E1), width: 0.8),
                  columnWidths: const {
                    0: FlexColumnWidth(1.5),
                    1: FlexColumnWidth(4),
                    2: FlexColumnWidth(2.5),
                    3: FlexColumnWidth(4),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: darkNavy),
                      children: [
                        _buildTableCell('Tahun', isHeader: true),
                        _buildTableCell('Fokus Kebijakan Utama', isHeader: true),
                        _buildTableCell('Target Emisi', isHeader: true),
                        _buildTableCell('Indikator Output', isHeader: true),
                      ],
                    ),
                    TableRow(
                      children: [
                        _buildTableCell('2026'),
                        _buildTableCell('Mandatori MRV & Standar Scrap UMKM'),
                        _buildTableCell('1.10 tCO2/t'),
                        _buildTableCell('100% Pabrik Terkoneksi SIINas & CEMS'),
                      ],
                    ),
                    TableRow(
                      decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                      children: [
                        _buildTableCell('2027'),
                        _buildTableCell('Insentif Green Tariff PLN & Pajak Karbon'),
                        _buildTableCell('0.95 tCO2/t'),
                        _buildTableCell('40% Rute Induksi Beralih ke EAF'),
                      ],
                    ),
                    TableRow(
                      children: [
                        _buildTableCell('2028-2029'),
                        _buildTableCell('Injeksi Hidrogen Hijau pada DRI'),
                        _buildTableCell('0.82 tCO2/t'),
                        _buildTableCell('Pasokan Scrap Sirkular Capai 75%'),
                      ],
                    ),
                    TableRow(
                      decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                      children: [
                        _buildTableCell('2030'),
                        _buildTableCell('Kepatuhan Penuh CBAM Uni Eropa'),
                        _buildTableCell('<= 0.78 tCO2/t'),
                        _buildTableCell('Target Reduksi Sektor Baja -35% Tercapai'),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Lembar Pengesahan
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Mengetahui,', style: TextStyle(fontSize: 10, color: Color(0xFF475569))),
                        SizedBox(height: 2),
                        Text(
                          'Direktur Industri Logam\nKementerian Perindustrian RI',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 44),
                        Text('( __________________________ )', style: TextStyle(fontSize: 10)),
                        SizedBox(height: 2),
                        Text('NIP. 19740512 199903 1 002', style: TextStyle(fontSize: 8.5, color: Color(0xFF64748B))),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Ditetapkan di Jakarta, 17 Oktober 2026', style: TextStyle(fontSize: 9.5, color: Color(0xFF475569))),
                        const SizedBox(height: 2),
                        const Text(
                          'Koordinator Tim Peneliti & Analis\nInisiatif Saber Karbon 2026',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 44),
                        const Text('( Dr. Ir. Aditia Rahmad, M.Sc. )', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        const Text('NIDN. 0724088901 • Tim Ahli Kebijakan', style: TextStyle(fontSize: 8.5, color: Color(0xFF64748B))),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Widget _buildHeaderSection(String title) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.bold,
          color: Color(0xFF065F46),
        ),
      ),
    );
  }

  static Widget _buildTableCell(String text, {bool isHeader = false, Color? textColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 8.5 : 8.5,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader
              ? Colors.white
              : (textColor ?? const Color(0xFF0F172A)),
        ),
      ),
    );
  }

  static Widget _buildInAppSdgCard({
    required String code,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              code,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(fontSize: 8, color: Color(0xFF64748B), height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildBulletRecommendation({
    required String number,
    required String title,
    required String content,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xFF065F46),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                content,
                style: const TextStyle(fontSize: 9, color: Color(0xFF475569), height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
