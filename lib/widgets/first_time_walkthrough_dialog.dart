import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ============================================================================
/// FIRST-TIME USER WALKTHROUGH TUTORIAL (TUTORIAL PERTAMA KALI MASUK)
/// DIDESAIN ALA PERBANKAN MODERN (BRI, BNI, TELKOMSEL) DENGAN ALUR NEXT-NEXT
/// MUNCUL SEKALI SAJA SESUAI ROLE (PABRIK BAJA, UMKM, PEMERINTAH)
/// ============================================================================
class FirstTimeWalkthroughDialog extends StatefulWidget {
  final String roleKey;
  final VoidCallback? onCompleted;

  const FirstTimeWalkthroughDialog({
    super.key,
    required this.roleKey,
    this.onCompleted,
  });

  /// Cek apakah pengguna sudah pernah melihat tutorial untuk peran ini
  static Future<bool> shouldShow(String roleKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeen = prefs.getBool('tutorial_seen_$roleKey') ?? false;
      return !hasSeen;
    } catch (_) {
      return false;
    }
  }

  /// Tampilkan tutorial modal
  static Future<void> show(
    BuildContext context,
    String roleKey, {
    bool force = false,
    VoidCallback? onCompleted,
  }) async {
    if (!force) {
      final needShow = await shouldShow(roleKey);
      if (!needShow) return;
    }

    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => FirstTimeWalkthroughDialog(
        roleKey: roleKey,
        onCompleted: onCompleted,
      ),
    );
  }

  @override
  State<FirstTimeWalkthroughDialog> createState() =>
      _FirstTimeWalkthroughDialogState();
}

class _FirstTimeWalkthroughDialogState
    extends State<FirstTimeWalkthroughDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<_TutorialStep> get _steps {
    if (widget.roleKey == 'pemerintah') {
      return _governmentSteps;
    } else if (widget.roleKey == 'perusahaan_hijau') {
      return _umkmSteps;
    }
    return _steelCompanySteps;
  }

  String get _roleTitle {
    if (widget.roleKey == 'pemerintah') return 'Pemerintah / Regulator';
    if (widget.roleKey == 'perusahaan_hijau') {
      return 'Perusahaan Hijau / UMKM';
    }
    return 'Pabrik Baja Nasional';
  }

  Future<void> _markCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('tutorial_seen_${widget.roleKey}', true);
    } catch (e) {
      debugPrint('Error saving tutorial state: $e');
    }
    if (mounted) {
      Navigator.pop(context);
    }
    widget.onCompleted?.call();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps;
    final isLastPage = _currentPage == steps.length - 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.22),
              blurRadius: 32,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header: Logo Tag & Tombol Lewati
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          color: Color(0xFF059669),
                          size: 13,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'PANDUAN MULAI • $_roleTitle',
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF047857),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _markCompleted,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'Lewati',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // PageView Konten Tutorial
            SizedBox(
              height: 380,
              child: PageView.builder(
                controller: _pageController,
                itemCount: steps.length,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemBuilder: (context, index) {
                  final step = steps[index];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Lingkaran Ikon Bergradasi
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                step.accentColor,
                                step.accentColor.withValues(alpha: 0.75),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: step.accentColor.withValues(alpha: 0.28),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(step.icon, color: Colors.white, size: 40),
                        ),
                        const SizedBox(height: 18),

                        // Judul Langkah
                        Text(
                          step.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Subtitle
                        Text(
                          step.subtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: step.accentColor,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Deskripsi Fitur
                        Text(
                          step.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Box Instruksi "Habis ini ke mana?"
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 1),
                                child: Icon(
                                  Icons.explore_outlined,
                                  size: 16,
                                  color: Color(0xFF059669),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF334155),
                                      height: 1.35,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: 'Langkah Operasional: ',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      TextSpan(text: step.nextAction),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indikator Titik Halaman (Dots)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                steps.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == i ? 24 : 8,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _currentPage == i
                        ? const Color(0xFF059669)
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Aksi Bawah
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
              child: Row(
                children: [
                  if (_currentPage > 0) ...[
                    OutlinedButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF475569),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'Kembali',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (isLastPage) {
                          _markCompleted();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLastPage
                                ? 'Mulai Eksplorasi'
                                : 'Lanjut (${_currentPage + 1}/${steps.length})',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            isLastPage
                                ? Icons.check_circle_outline_rounded
                                : Icons.arrow_forward_rounded,
                            size: 17,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // DATA STEP WALKTHROUGH SESUAI ROLE
  // ===========================================================================

  // 1. ROLE PABRIK BAJA
  static final List<_TutorialStep> _steelCompanySteps = [
    _TutorialStep(
      icon: Icons.factory_outlined,
      accentColor: const Color(0xFF059669),
      title: 'Selamat Datang di Portal Pabrik Baja',
      subtitle: 'Pusat Kendali Emisi & Efisiensi Energi Logam',
      description:
          'Pantau tonase produksi, intensitas emisi cerobong CEMS secara berkala, dan lacak target penurunan emisi dekarbonisasi.',
      nextAction:
          'Mulai dari tab Dashboard untuk melihat status kepatuhan batas emisi Anda.',
    ),
    _TutorialStep(
      icon: Icons.calculate_outlined,
      accentColor: const Color(0xFF0D9488),
      title: 'Kalkulator & Simulator CBAM',
      subtitle: 'Simulasi Risiko Tarif Karbon Ekspor Uni Eropa',
      description:
          'Hitung potensi denda regulasi CBAM (ambang batas 0.80 tCO2/t) dan simulasikan penghematan biaya dengan rute tungku EAF sirkular.',
      nextAction:
          'Pilih menu CBAM di bilah bawah untuk menghitung dampak ekspor baja Anda.',
    ),
    _TutorialStep(
      icon: Icons.storefront_rounded,
      accentColor: const Color(0xFF047857),
      title: 'Green Market Pasokan Scrap UMKM',
      subtitle: 'Akses Bahan Baku Sirkular Berstandar MRV',
      description:
          'Dapatkan pasokan besi tua/scrap HMS 1&2 bermutu tinggi (kadar Fe > 98%) dari depo UMKM terverifikasi untuk peleburan bersih.',
      nextAction:
          'Tekan tombol Market di tengah navigasi untuk memesan bahan baku dan terbitkan Purchase Order (PO).',
    ),
    _TutorialStep(
      icon: Icons.assignment_turned_in_outlined,
      accentColor: const Color(0xFF10B981),
      title: 'Audit SIINas & Pengiriman DO',
      subtitle: 'Validasi Otomatis & Ketertelusuran Emisi',
      description:
          'Lacak Surat Jalan (DO) dari mitra UMKM secara transparan. Setiap ton scrap yang Anda gunakan diakui langsung dalam audit dekarbonisasi SIINas.',
      nextAction:
          'Buka Keranjang PO di Market atau cek menu Profil untuk riwayat kemitraan.',
    ),
  ];

  // 2. ROLE PERUSAHAAN HIJAU / UMKM
  static final List<_TutorialStep> _umkmSteps = [
    _TutorialStep(
      icon: Icons.recycling_rounded,
      accentColor: const Color(0xFF059669),
      title: 'Selamat Datang di Portal UMKM Scrap',
      subtitle: 'Sentra Pasokan Bahan Baku Logam Sirkular',
      description:
          'Koneksikan depo pengolahan scrap besi Anda langsung ke pabrik-pabrik peleburan baja besar nasional.',
      nextAction:
          'Buka tab Katalog untuk mengelola ketersediaan stok scrap siap kirim.',
    ),
    _TutorialStep(
      icon: Icons.add_box_outlined,
      accentColor: const Color(0xFF0D9488),
      title: 'Unggah Stok & Parameter Mutu',
      subtitle: 'Tonase, Kemurnian Fe, dan Sertifikasi Depo',
      description:
          'Daftarkan stok scrap EAF Anda lengkap dengan estimasi harga per ton, kemurnian kadar Fe, dan sertifikat bebas kontaminan radioaktif.',
      nextAction:
          'Tekan tombol Tambah Pasokan di halaman Katalog untuk mendaftarkan stok baru.',
    ),
    _TutorialStep(
      icon: Icons.shopping_basket_outlined,
      accentColor: const Color(0xFF047857),
      title: 'Terima Purchase Order (PO)',
      subtitle: 'Pesanan Masuk Otomatis dari Pabrik Baja',
      description:
          'Setiap kali pabrik baja menerbitkan pesanan, detail PO masuk ke menu Permintaan. Lakukan verifikasi dan terbitkan Surat Jalan (DO) resmi.',
      nextAction:
          'Pilih menu Permintaan pada navigasi bawah untuk melihat pesanan masuk.',
    ),
    _TutorialStep(
      icon: Icons.verified_user_outlined,
      accentColor: const Color(0xFF10B981),
      title: 'Akreditasi MRV & Fasilitas Insentif',
      subtitle: 'Standar Nasional Bebas Pajak PPh Pasal 22',
      description:
          'Depo scrap yang terakreditasi MRV berhak memperoleh kemudahan akses perbankan hijau dan pelatihan Green Reskilling tenaga kerja.',
      nextAction:
          'Buka tab Kemitraan untuk memeriksa standar uji mutu dan profil legalitas Anda.',
    ),
  ];

  // 3. ROLE PEMERINTAH / REGULATOR
  static final List<_TutorialStep> _governmentSteps = [
    _TutorialStep(
      icon: Icons.account_balance_outlined,
      accentColor: const Color(0xFF059669),
      title: 'Selamat Datang di Portal Regulator',
      subtitle: 'Pusat Kendali Pengawasan Emisi Baja Nasional',
      description:
          'Akses data pengawasan terpadu SIINas Kemenperin dan BPPHLHK RI guna mengawal peta jalan NZE 2060 sektor industri logam.',
      nextAction:
          'Mulai dari menu SIINas Nasional untuk memverifikasi audit MRV pabrik dan UMKM.',
    ),
    _TutorialStep(
      icon: Icons.map_outlined,
      accentColor: const Color(0xFF0D9488),
      title: 'Peta Spasial Geospasial Emisi',
      subtitle: 'Pemetaan Klaster Wilayah & Smelter Indonesia',
      description:
          'Analisis zonasi emisi terdistribusi: Zona Merah Jawa Timur (prioritas audit), Zona Kuning Jabar/Banten, dan Zona Aman Jateng.',
      nextAction:
          'Pilih menu Peta Spasial di bilah bawah untuk membuka radar interaktif.',
    ),
    _TutorialStep(
      icon: Icons.description_outlined,
      accentColor: const Color(0xFF047857),
      title: 'Naskah Kebijakan Strategis (Policy Brief)',
      subtitle: 'Dokumen Rekomendasi Resmi Kemenperin-BPPHLHK',
      description:
          'Pelajari 3 pilar rekomendasi kebijakan dekarbonisasi dan unduh naskah formal dalam format PDF cetak 100% vektor bebas error.',
      nextAction:
          'Buka menu Policy Brief untuk membaca naskah dan mengunduh berkas PDF.',
    ),
    _TutorialStep(
      icon: Icons.account_tree_outlined,
      accentColor: const Color(0xFF10B981),
      title: 'Simulasi Anggaran Transisi Hijau',
      subtitle: 'Optimalisasi Dana Karbon APBN & BPDLH',
      description:
          'Simulasikan perimbangan anggaran antara program Green Reskilling pekerja baja (SDG 4) vs bantuan modernisasi mesin depo UMKM (SDG 9).',
      nextAction:
          'Gunakan bilah geser anggaran di bagian bawah halaman Policy Brief.',
    ),
  ];
}

class _TutorialStep {
  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
  final String description;
  final String nextAction;

  const _TutorialStep({
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.nextAction,
  });
}
