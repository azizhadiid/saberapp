import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'policy_brief_pdf_service.dart';
import 'policy_brief_reader_page.dart';

/// ============================================================================
/// POLICY BRIEF & 4 PILAR SDGS (PEMERINTAH / REGULATOR)
/// DILENGKAPI PEMBACA NASKAH DIGITAL & SISTEM UNDUH PDF RESMI KEMENPERIN-KLHK
/// ============================================================================
class GovPolicyBriefView extends StatefulWidget {
  const GovPolicyBriefView({super.key});

  @override
  State<GovPolicyBriefView> createState() => _GovPolicyBriefViewState();
}

class _GovPolicyBriefViewState extends State<GovPolicyBriefView> {
  double _budgetSplit = 55.0; // 55% Reskilling, 45% Bantuan Mesin MRF Scrap
  bool _isGeneratingPdf = false;

  /// Buka tampilan pembaca naskah langsung di dalam aplikasi (100% bebas error native)
  void _openInAppReader() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PolicyBriefReaderPage(budgetSplit: _budgetSplit),
      ),
    );
  }

  /// Tampilkan dialog panduan restart jika native plugin printing belum aktif
  void _showRestartRequiredDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.restart_alt_rounded, color: Color(0xFF4338CA)),
            SizedBox(width: 8),
            Text('Perlu Restart Aplikasi', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Plugin cetak native (printing) baru saja ditambahkan ke aplikasi.\n\n'
          'Flutter memerlukan restart penuh (Stop terminal / IDE, lalu jalankan kembali "flutter run") agar fungsi cetak native perangkat aktif.\n\n'
          'Sementara itu, Anda tetap dapat membaca naskah kebijakan resmi secara lengkap langsung di dalam aplikasi!',
          style: TextStyle(fontSize: 12, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _openInAppReader();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4338CA),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.chrome_reader_mode_rounded, size: 16),
            label: const Text('Baca di Aplikasi'),
          ),
        ],
      ),
    );
  }

  /// Buka modal pilihan unduh atau baca naskah kebijakan
  Future<void> _handlePdfAction() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'Naskah Kebijakan Strategis Eksekutif',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Text(
                  'Format Dokumen Resmi Kemenperin-KLHK RI • Saber Karbon 2026',
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),

                // Opsi 1: Baca Langsung di Aplikasi
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.chrome_reader_mode_rounded, color: Color(0xFF4338CA)),
                  ),
                  title: const Text(
                    'Baca Naskah Langsung di Aplikasi',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Tampilan dokumen resmi lengkap tanpa memerlukan plugin eksternal',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _openInAppReader();
                  },
                ),
                const Divider(height: 1),

                // Opsi 2: Pratinjau & Cetak Dokumen
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.print_rounded, color: Color(0xFF334155)),
                  ),
                  title: const Text(
                    'Buka Pratinjau & Cetak Dokumen',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Lihat tata letak multi-halaman dan cetak ke printer/PDF',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _openPdfPreview();
                  },
                ),
                const Divider(height: 1),

                // Opsi 3: Simpan & Bagikan Berkas PDF Langsung
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.share_rounded, color: Color(0xFF059669)),
                  ),
                  title: const Text(
                    'Unduh & Bagikan Berkas PDF Langsung',
                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Kirim berkas naskah kebijakan ke WhatsApp, Email, atau Simpan File',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _sharePdfDirectly();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Pratinjau interaktif PDF
  Future<void> _openPdfPreview() async {
    setState(() => _isGeneratingPdf = true);
    try {
      await Printing.layoutPdf(
        name: 'Policy_Brief_Dekarbonisasi_Baja_Nasional_2026.pdf',
        onLayout: (format) async {
          return await PolicyBriefPdfService.generatePdf(budgetSplit: _budgetSplit);
        },
      );
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('MissingPluginException') ||
            e.toString().contains('No implementation found')) {
          _showRestartRequiredDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal membuat pratinjau PDF: $e'),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  /// Bagikan / Unduh file PDF langsung
  Future<void> _sharePdfDirectly() async {
    setState(() => _isGeneratingPdf = true);
    try {
      final pdfBytes = await PolicyBriefPdfService.generatePdf(budgetSplit: _budgetSplit);
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'Policy_Brief_Dekarbonisasi_Baja_Nasional_2026.pdf',
      );
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('MissingPluginException') ||
            e.toString().contains('No implementation found')) {
          _showRestartRequiredDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengunduh berkas PDF: $e'),
              backgroundColor: const Color(0xFFDC2626),
            ),
          );
        }
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF4338CA);
    const darkPurple = Color(0xFF312E81);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFC7D2FE)),
              ),
              child: Image.asset(
                'assets/img/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.menu_book,
                  color: primaryPurple,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Policy Brief & SDGs',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Rekomendasi Kebijakan Dekarbonisasi Hard-to-Abate 2060',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _isGeneratingPdf ? null : _handlePdfAction,
            icon: _isGeneratingPdf
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: primaryPurple),
                  )
                : const Icon(Icons.picture_as_pdf_outlined, color: primaryPurple),
            tooltip: 'Unduh Naskah Kebijakan Resmi (PDF)',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==============================================================
            // 1. KARTU RINGKASAN EKSEKUTIF DENGAN TOMBOL UNDUH PDF ASLI
            // ==============================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [darkPurple, primaryPurple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryPurple.withValues(alpha: 0.25),
                    blurRadius: 14,
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
                      const Expanded(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.description, color: Color(0xFFA5B4FC), size: 16),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'EXECUTIVE POLICY BRIEF #01/2026',
                                style: TextStyle(
                                  color: Color(0xFFC7D2FE),
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.6,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Kemenperin • KLHK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
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
                    'Mengintegrasikan model peramalan deret waktu untuk memandu kebijakan insentif pajak karbon, kepatuhan batas CBAM 0.80 tCO2/t, dan perlindungan rantai pasok UMKM scrap sirkular.',
                    style: TextStyle(color: Color(0xFFE0E7FF), fontSize: 11.5, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openInAppReader,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: darkPurple,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.chrome_reader_mode_rounded, size: 18),
                          label: const Text(
                            'Baca di Aplikasi',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isGeneratingPdf ? null : _handlePdfAction,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white70, width: 1.2),
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: _isGeneratingPdf
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.picture_as_pdf_rounded, size: 18),
                          label: Text(
                            _isGeneratingPdf ? 'Memproses...' : 'Unduh PDF',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==============================================================
            // 2. INTEGRASI 4 PILAR SDGS
            // ==============================================================
            const Text(
              'Integrasi 4 Pilar SDGs (Sustainable Development Goals)',
              style: TextStyle(
                fontSize: 13.5,
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

            // ==============================================================
            // 3. SIMULATOR ANGGARAN TRANSISI HIJAU (DINAMIS KE PDF)
            // ==============================================================
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
                    activeColor: primaryPurple,
                    onChanged: (val) {
                      setState(() => _budgetSplit = val);
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Pendidikan: Rp ${(_budgetSplit * 1.8).toStringAsFixed(1)} Miliar',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: primaryPurple,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'UMKM: Rp ${((100 - _budgetSplit) * 1.8).toStringAsFixed(1)} Miliar',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF059669),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
                  const SizedBox(height: 8),
                  const Row(
                    children: [
                      Icon(Icons.info_outline, size: 14, color: Color(0xFF94A3B8)),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Nilai simulasi ini otomatis tertera pada naskah PDF resmi saat diunduh.',
                          style: TextStyle(fontSize: 10.5, fontStyle: FontStyle.italic, color: Color(0xFF64748B)),
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
