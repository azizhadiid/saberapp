import 'package:flutter/material.dart';

/// ============================================================================
/// BUKU PANDUAN MANUAL APLIKASI & TATA KELOLA HAK AKSES ENTERPRISE
/// SABER KARBON: SISTEM AKSELERASI BAJA RENDAH KARBON TERINTEGRASI
/// ============================================================================
class AppManualPage extends StatefulWidget {
  final int initialTabIndex;
  const AppManualPage({super.key, this.initialTabIndex = 0});

  @override
  State<AppManualPage> createState() => _AppManualPageState();
}

class _AppManualPageState extends State<AppManualPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Panduan & Tata Kelola Platform',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Manual Aplikasi Resmi • Saber Karbon 2026',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF059669),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF059669).withValues(alpha: 0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF64748B),
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(
                  iconMargin: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book_rounded, size: 16),
                      SizedBox(width: 6),
                      Text('Manual Aplikasi'),
                    ],
                  ),
                ),
                Tab(
                  iconMargin: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shield_outlined, size: 16),
                      SizedBox(width: 6),
                      Text('Kebijakan Hak Akses'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApplicationManualTab(),
          _buildAccessPolicyTab(),
        ],
      ),
    );
  }

  // ===========================================================================
  // TAB 1: MANUAL APLIKASI LENGKAP (ALUR & CARA PENGGUNAAN FITUR)
  // ===========================================================================
  Widget _buildApplicationManualTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Card Ringkasan Inovasi
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF064E3B), Color(0xFF047857)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF059669).withValues(alpha: 0.2),
                blurRadius: 14,
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
                      Icons.eco_rounded,
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
                          'Saber Karbon 2026',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Akselerasi Dekarbonisasi Hard-to-Abate Menuju NZE 2060',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text(
                'Saber Karbon adalah platform terintegrasi tripartite (B2B & G2B) yang menjembatani Pabrik Baja Nasional, UMKM Pengepul Scrap Sirkular (MRF), dan Regulator Pemerintah (Kemenperin & KLHK) guna memenuhi ambang batas CBAM Uni Eropa dan target penurunan emisi nasional 35% pada 2030.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Section Title: Panduan Berdasarkan Peran Pengguna
        const Text(
          'PANDUAN ALUR FITUR SESUAI PERAN (ROLE)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 12),

        // 1. Role Pabrik Baja
        _buildRoleGuideCard(
          title: '1. Peran: Pabrik Baja (Steel Industry)',
          roleBadge: 'Produsen Logam & Pembeli Scrap',
          badgeColor: const Color(0xFF059669),
          icon: Icons.factory_outlined,
          description:
              'Dikhususkan bagi fasilitas peleburan baja (EAF, Blast Furnace, Reheating Mill) untuk mengaudit intensitas karbon, simulasi kepatuhan CBAM, dan pemenuhan bahan baku sirkular.',
          steps: const [
            'Dashboard Emisi: Pantau total tonase produksi, emisi cerobong CEMS real-time, dan status MRV industri.',
            'Kalkulator & Simulator CBAM: Hitung potensi denda tarif karbon ekspor Uni Eropa (ambang batas 0.80 tCO2/t) dan proyeksi penghematan.',
            'Bursa Green Market: Cari depo scrap UMKM bersertifikat MRV, ajukan kontrak pasok sirkular, dan terbitkan Purchase Order (PO) otomatis.',
            'Keranjang & Status PO: Pantau penerbitan Surat Jalan (DO) dan verifikasi timbangan scrap untuk pelaporan SIINas.',
          ],
        ),
        const SizedBox(height: 14),

        // 2. Role Perusahaan Hijau / UMKM Scrap
        _buildRoleGuideCard(
          title: '2. Peran: Perusahaan Hijau / UMKM Scrap',
          roleBadge: 'Mitra Pemasok Bahan Baku Sirkular',
          badgeColor: const Color(0xFF0D9488),
          icon: Icons.recycling_rounded,
          description:
              'Dikhususkan bagi sentra pengumpul scrap, depo pemilahan logam, dan penyedia teknologi hijau sirkular untuk terhubung langsung ke rantai pasok industri baja skala besar.',
          steps: const [
            'Katalog Pasokan: Daftarkan stok scrap HMS 1&2, tonase siap kirim, kemurnian kadar Fe (%), serta harga per ton.',
            'Permintaan & Order Masuk: Terima Purchase Order (PO) dari pabrik baja mitra, lakukan konfirmasi, dan terbitkan Surat Jalan (DO) resmi.',
            'Standar & Akreditasi MRV: Ikuti panduan uji kontaminasi radioaktif dan residu tembaga (Cu < 0.05%) untuk memperoleh predikat UMKM Lolos MRV.',
            'Profil Usaha: Lengkapi legalitas NIB, kapasitas gilingan/mesin press, dan daftar tenaga kerja lokal yang diberdayakan.',
          ],
        ),
        const SizedBox(height: 14),

        // 3. Role Pemerintah / Regulator
        _buildRoleGuideCard(
          title: '3. Peran: Pemerintah (Regulator Kemenperin & KLHK)',
          roleBadge: 'Otoritas Pengawasan & Akreditasi MRV',
          badgeColor: const Color(0xFF047857),
          icon: Icons.account_balance_outlined,
          description:
              'Dikhususkan bagi auditor dinas, inspektur emisi, pengelola BPDLH, dan tim penilai akreditasi untuk memantau dekarbonisasi industri logam nasional.',
          steps: const [
            'SIINas Nasional: Verifikasi status audit MRV cerobong pabrik baja dan kepatuhan standar depo scrap UMKM secara transparan.',
            'Peta Spasial Hotspot: Analisis geospasial sebaran pabrik baja per wilayah (Zona Merah Jatim, Zona Kuning Jabar/Banten, Zona Aman Jateng).',
            'Naskah Policy Brief: Unduh dan cetak naskah rekomendasi kebijakan resmi Kemenperin-KLHK (bebas error font / 100% vector layout).',
            'Simulasi Anggaran Transisi: Simulasikan proporsi alokasi insentif fiskal pajak karbon antara Green Reskilling (SDG 4) vs Modernisasi Mesin UMKM (SDG 9).',
          ],
        ),
        const SizedBox(height: 20),

        // Section: Alur Transaksi B2B Terpadu
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
              const Row(
                children: [
                  Icon(Icons.hub_outlined, color: Color(0xFF059669), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Alur Interkoneksi Tripartite',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildFlowStep(
                num: '1',
                title: 'Pasokan Scrap Terverifikasi',
                desc: 'UMKM mengunggah pasokan scrap dengan parameter standar MRV (kadar Fe > 98%).',
              ),
              _buildFlowStep(
                num: '2',
                title: 'Penerbitan PO oleh Pabrik Baja',
                desc: 'Pabrik baja memesan bahan baku sirkular di Market Green untuk menurunkan rasio emisi peleburan EAF.',
              ),
              _buildFlowStep(
                num: '3',
                title: 'Penerbitan DO & Pengiriman',
                desc: 'UMKM menerima pesanan dan menerbitkan Surat Jalan (DO) resmi pengiriman scrap ke pabrik.',
              ),
              _buildFlowStep(
                num: '4',
                title: 'Audit & Validasi Regulator',
                desc: 'Data transaksi dan reduksi tCO2e tercatat otomatis di SIINas Nasional untuk validasi CBAM oleh Pemerintah.',
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // TAB 2: TATA KELOLA & KEBIJAKAN HAK AKSES (NON-PUBLIK / ENTERPRISE CLOSED)
  // ===========================================================================
  Widget _buildAccessPolicyTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        // Warning Banner Non-Publik
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.gpp_maybe_rounded,
                color: Color(0xFFD97706),
                size: 26,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Pemberitahuan Tata Kelola Akses Platform',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF92400E),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Saber Karbon adalah sistem enterprise tertutup (Governed Closed Ecosystem B2B & G2B) dan bukan platform publik terbuka untuk umum. Akses dibatasi secara ketat hanya bagi entitas industri baja berizin, UMKM scrap terakreditasi, serta auditor pemerintah berwenang.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF78350F),
                        height: 1.45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Persyaratan Akreditasi Masuk per Peran
        const Text(
          'KRITERIA HAK AKSES & KELAYAKAN ENTITAS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 12),

        // Entitas 1: Pabrik Baja
        _buildPolicyCard(
          title: 'A. Entitas Produsen / Pabrik Baja',
          icon: Icons.domain_rounded,
          criteria: const [
            'Memiliki Izin Usaha Industri (IUI) aktif dengan klasifikasi KBLI 2410 (Industri Logam Dasar Besi dan Baja).',
            'Telah terdaftar resmi dalam Sistem Informasi Industri Nasional (SIINas) Kementerian Perindustrian RI.',
            'Memiliki fasilitas peleburan operasional (Blast Furnace, Electric Arc Furnace, atau Induction Furnace) dengan pelaporan neraca energi.',
            'Berkomitmen mematuhi regulasi pelaporan pemantauan emisi berkelanjutan (Continuous Emission Monitoring System / CEMS).',
          ],
        ),
        const SizedBox(height: 12),

        // Entitas 2: UMKM Scrap
        _buildPolicyCard(
          title: 'B. Entitas Perusahaan Hijau / UMKM Scrap',
          icon: Icons.storefront_rounded,
          criteria: const [
            'Memiliki Nomor Induk Berusaha (NIB) sektor pengelolaan daur ulang barang bekas logam / sirkularitas material.',
            'Memiliki depo fisik pengumpulan dan mesin pemilahan/pemadatan scrap (Shearing & Baling Machine).',
            'Lolos uji ambang batas mutu bahan baku: bebas zat radioaktif alam (NORM) dan kadar pengotor Cu < 0.05%.',
            'Terdaftar dalam wadah koperasi atau asosiasi mitra industri binaan Kemenperin-KLHK.',
          ],
        ),
        const SizedBox(height: 12),

        // Entitas 3: Pemerintah
        _buildPolicyCard(
          title: 'C. Otoritas Pemerintah & Tim Evaluator',
          icon: Icons.admin_panel_settings_rounded,
          criteria: const [
            'Pejabat dan inspektur berwenang di lingkungan Kementerian Perindustrian (Ditjen ILMATE), Kementerian LHK, atau BPDLH.',
            'Wajib menggunakan kredensial kedinasan resmi (.go.id) atau akun yang telah divalidasi oleh Administrator Pusat Saber Karbon.',
            'Dikecualikan bagi Tim Penilai / Dewan Juri Belmawa Kemendikbudristek (Satria Data): Diberikan akses Sandbox Evaluator untuk keperluan uji coba dan validasi naskah kompetisi.',
            'Memegang kewenangan penuh atas validasi MRV, audit lapangan, serta rekomendasi kebijakan naskah strategis.',
          ],
        ),
        const SizedBox(height: 18),

        // Pernyataan Kepatuhan & Keamanan Data
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Integritas Data & Audit MRV',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Seluruh data transaksi pasokan scrap, perhitungan emisi gas rumah kaca (GRK), dan surat jalan logistik terenkripsi dan disimpan secara terpusat untuk menjamin ketertelusuran (traceability) audit emisi CBAM Uni Eropa dan akreditasi ISO 14064 / ISO 14067.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF64748B),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleGuideCard({
    required String title,
    required String roleBadge,
    required Color badgeColor,
    required IconData icon,
    required String description,
    required List<String> steps,
  }) {
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
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: badgeColor, size: 22),
              ),
              const SizedBox(width: 10),
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
                      roleBadge,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Langkah Operasional:',
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 6),
          ...steps.map(
            (step) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 5, right: 8),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      step,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF475569),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyCard({
    required String title,
    required IconData icon,
    required List<String> criteria,
  }) {
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
            children: [
              Icon(icon, color: const Color(0xFF059669), size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...criteria.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF059669),
                    size: 15,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF475569),
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowStep({
    required String num,
    required String title,
    required String desc,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                color: Color(0xFF059669),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                num,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 1.5,
                height: 30,
                color: const Color(0xFFCBD5E1),
              ),
          ],
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
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
        ),
      ],
    );
  }
}
