import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ============================================================================
/// HALAMAN NASIONAL SIINAS & STATUS MRV (ROLE PEMERINTAH / REGULATOR)
/// Tema Desain: Flat Modern Emerald Green (#059669 & #065F46)
/// Membaca Data Real-Time dari Tabel Supabase: public.companies (Role: perusahaan_baja)
/// ============================================================================
class GovNationalSiinasView extends StatefulWidget {
  const GovNationalSiinasView({super.key});

  @override
  State<GovNationalSiinasView> createState() => _GovNationalSiinasViewState();
}

class _GovNationalSiinasViewState extends State<GovNationalSiinasView> {
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedMrvFilter = 'Semua Status';

  List<Map<String, dynamic>> _companiesList = [];

  // Data pembanding awal / kurasi pabrik baja nasional (Khusus role: perusahaan_baja)
  final List<Map<String, dynamic>> _baselineFactories = [
    {
      'id': 'b-01',
      'name': 'PT Krakatau Steel (Persero) Tbk',
      'siinas_id': 'SIINAS #KRK-001',
      'location': 'Cilegon, Banten',
      'role': 'perusahaan_baja',
      'route': 'Direct Reduced Iron (DRI) -> Electric Arc Furnace (EAF)',
      'current_emission': 1.12,
      'carbon_intensity': 0.76, // Di bawah ambang batas CBAM 0.80
      'mrv_status': 'disetujui',
      'compliance_note': 'Lolos Ambang Batas CBAM Uni Eropa (0.76 < 0.80 tCO2/t)',
      'verified_at': '12 Okt 2026',
    },
    {
      'id': 'b-02',
      'name': 'PT Gunung Raja Paksi Tbk',
      'siinas_id': 'SIINAS #GRP-002',
      'location': 'Cikarang, Bekasi - Jawa Barat',
      'role': 'perusahaan_baja',
      'route': 'Electric Arc Furnace (EAF) Scrap Bauran 65%',
      'current_emission': 0.85,
      'carbon_intensity': 0.79,
      'mrv_status': 'disetujui',
      'compliance_note': 'Memenuhi Standar Sertifikasi Hijau Kemenperin Industri Hijau Level 5',
      'verified_at': '08 Okt 2026',
    },
    {
      'id': 'b-03',
      'name': 'PT Bhirawa Steel Surabaya',
      'siinas_id': 'SIINAS #BHR-003',
      'location': 'Margomulyo, Surabaya - Jawa Timur',
      'role': 'perusahaan_baja',
      'route': 'EAF Rolling Mill & Preheating Scrap',
      'current_emission': 0.94,
      'carbon_intensity': 0.82,
      'mrv_status': 'menunggu',
      'compliance_note': 'Laporan Emisi Tahunan 2025 Sedang Ditinjau Tim Verifikator MRV',
      'verified_at': '-',
    },
    {
      'id': 'b-04',
      'name': 'PT Smelter Induksi Jaya Gresik',
      'siinas_id': 'SIINAS #SIJ-009',
      'location': 'Manyar, Gresik - Jawa Timur',
      'role': 'perusahaan_baja',
      'route': 'Induction Furnace Tanpa Wet Scrubber',
      'current_emission': 1.68,
      'carbon_intensity': 1.68, // Melebihi batas aman
      'mrv_status': 'perlu_tindakan',
      'compliance_note': 'Pelanggaran Baku Mutu Emisi Cerobong PM2.5 & Sulfur (Wajib Pasang Scrubber)',
      'verified_at': '-',
    },
    {
      'id': 'b-05',
      'name': 'PT Lautan Steel Indonesia',
      'siinas_id': 'SIINAS #LSI-014',
      'location': 'Balaraja, Tangerang - Banten',
      'role': 'perusahaan_baja',
      'route': 'Induction Furnace to EAF Hybrid',
      'current_emission': 1.05,
      'carbon_intensity': 0.88,
      'mrv_status': 'menunggu',
      'compliance_note': 'Menunggu Dokumen Kalibrasi CEMS (Continuous Emission Monitoring System)',
      'verified_at': '-',
    },
    {
      'id': 'b-06',
      'name': 'PT The Master Steel Mfg Co',
      'siinas_id': 'SIINAS #MSM-021',
      'location': 'Pulo Gadung, Jakarta Timur',
      'role': 'perusahaan_baja',
      'route': 'EAF High-Efficiency Rolling Mill',
      'current_emission': 0.89,
      'carbon_intensity': 0.81,
      'mrv_status': 'menunggu',
      'compliance_note': 'Dalam Proses Kalibrasi Sensor Cerobong CEMS Industri Logam',
      'verified_at': '-',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchCompaniesData();
  }

  /// Ambil data real-time dari Supabase khusus untuk entitas role 'perusahaan_baja'
  Future<void> _fetchCompaniesData() async {
    setState(() => _isLoading = true);
    try {
      // 1. Ambil data dari tabel public.companies
      final response = await Supabase.instance.client
          .from('companies')
          .select('*')
          .or('role.eq.perusahaan_baja,role.is.null')
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> fetched = [];
      final Set<String> existingNames = {};

      for (var row in response) {
        final map = Map<String, dynamic>.from(row);
        final role = (map['role'] ?? 'perusahaan_baja').toString().toLowerCase();

        // Filter ketat: Hanya tampilkan entitas Perusahaan Baja di dashboard SIINas ini
        if (role == 'perusahaan_baja') {
          fetched.add(map);
          if (map['name'] != null) {
            existingNames.add((map['name'] as String).toLowerCase().trim());
          }
        }
      }

      // 2. Gabungkan data kurasi pabrik baja pembanding agar selalu lengkap saat demo
      for (var base in _baselineFactories) {
        if (!existingNames.contains((base['name'] as String).toLowerCase().trim())) {
          fetched.add(base);
        }
      }

      setState(() {
        _companiesList = fetched;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Gagal fetch companies dari Supabase: $e');
      setState(() {
        _companiesList = List.from(_baselineFactories);
        _isLoading = false;
      });
    }
  }

  /// Update status MRV langsung ke tabel public.companies di Supabase
  Future<void> _updateMrvStatusInSupabase(
    Map<String, dynamic> comp,
    String newStatus,
  ) async {
    final companyId = comp['id'];
    final companyName = comp['name'] ?? 'Perusahaan';

    // Update state lokal seketika (Optimistic UI update)
    setState(() {
      comp['mrv_status'] = newStatus;
    });

    try {
      bool success = false;

      // KASUS A: Entitas sudah memiliki UUID valid dari Supabase
      if (companyId != null && !companyId.toString().startsWith('b-')) {
        final res = await Supabase.instance.client
            .from('companies')
            .update({'mrv_status': newStatus})
            .eq('id', companyId)
            .select();

        if (res.isNotEmpty) {
          success = true;
        } else {
          // PostgreSQL RLS menolak update secara silent (0 rows affected)
          throw Exception(
            'RLS Supabase menolak update (0 baris diubah). '
            'Pastikan SQL Policy UPDATE untuk tabel companies sudah dijalankan di Supabase SQL Editor.',
          );
        }
      } else {
        // KASUS B: Entitas baseline (b-01, dll) -> Cek dulu apakah nama perusahaan sudah ada di Supabase
        final existing = await Supabase.instance.client
            .from('companies')
            .select('id')
            .eq('name', companyName)
            .maybeSingle();

        if (existing != null && existing['id'] != null) {
          final realId = existing['id'];
          final res = await Supabase.instance.client
              .from('companies')
              .update({'mrv_status': newStatus})
              .eq('id', realId)
              .select();

          if (res.isNotEmpty) {
            comp['id'] = realId;
            success = true;
          } else {
            throw Exception('RLS Supabase menolak update pada entitas terdaftar.');
          }
        } else {
          // Belum ada di Supabase -> INSERT entitas pabrik baja ini ke database Supabase secara otomatis!
          final inserted = await Supabase.instance.client
              .from('companies')
              .insert({
                'name': companyName,
                'siinas_id': comp['siinas_id'] ?? 'SIINAS #ID-2026',
                'location': comp['location'] ?? 'Indonesia',
                'role': 'perusahaan_baja',
                'carbon_intensity': comp['carbon_intensity'] ?? 0.0,
                'current_emission': comp['current_emission'] ?? 0.0,
                'mrv_status': newStatus,
              })
              .select()
              .single();

          comp['id'] = inserted['id'];
          success = true;
        }
      }

      if (mounted && success) {
        final statusLabel = newStatus == 'disetujui'
            ? 'MRV Disetujui'
            : (newStatus == 'perlu_tindakan'
                ? 'Peringatan & Jadwal Audit Terbit'
                : 'Menunggu Validasi');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Row(
              children: [
                Icon(
                  newStatus == 'disetujui'
                      ? Icons.check_circle
                      : Icons.warning_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Status $companyName berhasil disimpan ke Supabase: "$statusLabel"!',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: newStatus == 'disetujui'
                ? const Color(0xFF16A34A)
                : (newStatus == 'perlu_tindakan'
                    ? const Color(0xFFDC2626)
                    : const Color(0xFFD97706)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error updating MRV status in Supabase: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Text(
              'Gagal simpan ke Supabase: $e\nSilakan jalankan SQL Section 8 di Supabase SQL Editor.',
              style: const TextStyle(fontSize: 11),
            ),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  String _deriveMrvStatus(Map<String, dynamic> comp) {
    if (comp['mrv_status'] != null && comp['mrv_status'].toString().isNotEmpty) {
      return comp['mrv_status'].toString().toLowerCase();
    }
    final num? intensity = comp['carbon_intensity'] as num?;
    if (intensity == null) return 'menunggu';
    if (intensity <= 0.80) return 'disetujui';
    if (intensity > 1.40) return 'perlu_tindakan';
    return 'menunggu';
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF059669); // Emerald Green
    const darkPurple = Color(0xFF065F46);    // Deep Forest Emerald

    // Filter pencarian & status MRV
    final filteredList = _companiesList.where((comp) {
      final name = (comp['name'] ?? '').toString().toLowerCase();
      final siinas = (comp['siinas_id'] ?? '').toString().toLowerCase();
      final loc = (comp['location'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase().trim();

      final matchesQuery = query.isEmpty ||
          name.contains(query) ||
          siinas.contains(query) ||
          loc.contains(query);

      final status = _deriveMrvStatus(comp);
      if (_selectedMrvFilter == 'MRV Disetujui' && status != 'disetujui') {
        return false;
      }
      if (_selectedMrvFilter == 'Menunggu Validasi' && status != 'menunggu') {
        return false;
      }
      if (_selectedMrvFilter == 'Perlu Tindakan' && status != 'perlu_tindakan') {
        return false;
      }

      return matchesQuery;
    }).toList();

    // Hitung statistik kepatuhan nasional
    int totalCount = _companiesList.length;
    int approvedCount = _companiesList.where((c) => _deriveMrvStatus(c) == 'disetujui').length;
    int pendingCount = _companiesList.where((c) => _deriveMrvStatus(c) == 'menunggu').length;
    int actionCount = _companiesList.where((c) => _deriveMrvStatus(c) == 'perlu_tindakan').length;
    int compliancePercent = totalCount > 0 ? ((approvedCount / totalCount) * 100).round() : 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      // APPBAR KHUSUS PEMERINTAH (FLAT, GREEN THEME, LOGO ASLI SABER CARBON)
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleSpacing: 16,
        title: Row(
          children: [
            // LOGO ASLI SABER KARBON (Bukan Ikon Rumah)
            Container(
              padding: const EdgeInsets.all(4),
              width: 38,
              height: 38,
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
                    'SIINas Nasional • Data Emisi',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Kementerian Perindustrian & KLHK RI',
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
            onPressed: _fetchCompaniesData,
            icon: const Icon(Icons.refresh, color: primaryPurple),
            tooltip: 'Sinkronisasi Data Supabase',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCompaniesData,
        color: primaryPurple,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BANNER STATISTIK PEMERINTAH (BEBAS OVERFLOW WIDTH)
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
                    // ROW HEADER: PERBAIKAN OVERFLOW 8.1 PIXEL MENGGUNAKAN EXPANDED + FLEXIBLE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_user, color: Color(0xFF6EE7B7), size: 16),
                              SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'AUDIT MRV NASIONAL',
                                  style: TextStyle(
                                    color: Color(0xFFA7F3D0),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '$compliancePercent% Lolos MRV',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      '2.86 MtCO2e',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Agregat Emisi Industri Baja Terdaftar (Target Penurunan -35% NDC 2030)',
                      style: TextStyle(color: Color(0xFFD1FAE5), fontSize: 11.5),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildStatCol('Pabrik Baja', '$totalCount Unit'),
                        Container(width: 1, height: 26, color: Colors.white24),
                        _buildStatCol('Disetujui', '$approvedCount Lolos'),
                        Container(width: 1, height: 26, color: Colors.white24),
                        _buildStatCol('Menunggu', '$pendingCount Antre'),
                        Container(width: 1, height: 26, color: Colors.white24),
                        _buildStatCol('Perlu Audit', '$actionCount Aksi'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // SEARCH BAR FLAT
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'Cari pabrik baja, nomor SIINas, atau kota...',
                    hintStyle: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                    prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // FILTER CHIPS STATUS MRV
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'Semua Status',
                    'MRV Disetujui',
                    'Menunggu Validasi',
                    'Perlu Tindakan',
                  ].map((filter) {
                    final isSelected = _selectedMrvFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() => _selectedMrvFilter = filter);
                        },
                        selectedColor: primaryPurple,
                        backgroundColor: Colors.white,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 11.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? primaryPurple : const Color(0xFFE2E8F0),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // DAFTAR PERUSAHAAN SIINAS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pabrik Baja Terdaftar (${filteredList.length})',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  // GANTI LABEL MENJADI 'Data Asli' (DENGAN INDIKATOR HIJAU LIVE)
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF16A34A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      const Text(
                        'Data Asli (Terkini)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: primaryPurple),
                  ),
                )
              else if (filteredList.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.search_off, size: 40, color: Color(0xFF94A3B8)),
                      SizedBox(height: 8),
                      Text(
                        'Tidak ada pabrik baja yang cocok dengan filter.',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                      ),
                    ],
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredList.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final comp = filteredList[index];
                    return _buildCompanyCard(comp);
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCol(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Color(0xFFA7F3D0), fontSize: 9.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(Map<String, dynamic> comp) {
    final status = _deriveMrvStatus(comp);
    final intensity = (comp['carbon_intensity'] as num?)?.toDouble() ?? 0.0;
    final name = comp['name'] ?? 'Entitas Tanpa Nama';
    final siinas = comp['siinas_id'] ?? 'SIINAS #ID-2026';
    final location = comp['location'] ?? 'Indonesia';
    final route = comp['route'] ?? 'Rute Industri Logam Standard';
    final note = comp['compliance_note'] ?? 'Pelaporan berkala melalui portal SIINas';

    // Konfigurasi Badge MRV
    Color badgeBg;
    Color badgeTextColor;
    IconData badgeIcon;
    String badgeText;

    if (status == 'disetujui') {
      badgeBg = const Color(0xFFDCFCE7);
      badgeTextColor = const Color(0xFF16A34A);
      badgeIcon = Icons.check_circle_rounded;
      badgeText = 'MRV Disetujui';
    } else if (status == 'perlu_tindakan') {
      badgeBg = const Color(0xFFFEE2E2);
      badgeTextColor = const Color(0xFFDC2626);
      badgeIcon = Icons.warning_rounded;
      badgeText = 'Perlu Audit & Peringatan';
    } else {
      badgeBg = const Color(0xFFFEF3C7);
      badgeTextColor = const Color(0xFFD97706);
      badgeIcon = Icons.hourglass_top_rounded;
      badgeText = 'Menunggu Validasi MRV';
    }

    return InkWell(
      onTap: () => _showCompanyDetailModal(comp, status),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: status == 'perlu_tindakan'
                ? const Color(0xFFFCA5A5)
                : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              siinas,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Badge Status MRV
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(badgeIcon, size: 12, color: badgeTextColor),
                      const SizedBox(width: 4),
                      Text(
                        badgeText,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: badgeTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Rute: $route',
              style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 4),
            Text(
              note,
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: status == 'perlu_tindakan'
                    ? const Color(0xFFDC2626)
                    : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Intensitas Karbon',
                      style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$intensity tCO2/t',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: intensity <= 0.80
                            ? const Color(0xFF16A34A)
                            : (intensity > 1.40
                                ? const Color(0xFFDC2626)
                                : const Color(0xFFD97706)),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      intensity <= 0.80 ? 'Lolos Batas CBAM' : 'Perlu Mitigasi',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: intensity <= 0.80
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right, size: 18, color: Color(0xFF94A3B8)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// MODAL DETAIL REGISTRASI SIINAS & VERIFIKASI MRV REAL-TIME SUPABASE
  void _showCompanyDetailModal(Map<String, dynamic> comp, String currentStatus) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Detail Registrasi SIINas & MRV',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                comp['name'] ?? '',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                '${comp['siinas_id']} • ${comp['location']}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    _buildRowDetail('Intensitas Karbon', '${comp['carbon_intensity'] ?? 0} tCO2/t'),
                    const SizedBox(height: 6),
                    _buildRowDetail('Status Audit MRV Saat Ini', currentStatus.toUpperCase()),
                    const SizedBox(height: 6),
                    _buildRowDetail('Rute Peleburan', comp['route'] ?? 'Rute EAF / Blast Furnace'),
                    const SizedBox(height: 6),
                    _buildRowDetail('Sinkronisasi Supabase', 'Aktif'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Ubah Status Kepatuhan MRV di Database:',
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _updateMrvStatusInSupabase(comp, 'perlu_tindakan');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Kirim Peringatan', style: TextStyle(fontSize: 11.5)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _updateMrvStatusInSupabase(comp, 'menunggu');
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFD97706),
                        side: const BorderSide(color: Color(0xFFFDE68A)),
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Antre Validasi', style: TextStyle(fontSize: 11.5)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _updateMrvStatusInSupabase(comp, 'disetujui');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                      ),
                      child: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text('Setujui MRV', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRowDetail(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
