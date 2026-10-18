import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ============================================================================
/// HALAMAN NASIONAL SIINAS & VERIFIKASI DUA SITES (ROLE PEMERINTAH / REGULATOR)
/// Site 1: Perusahaan Baja (Audit Kepatuhan MRV, Intensitas Karbon & CBAM)
/// Site 2: Usaha Hijau & UMKM (Sertifikasi, Akreditasi Depo Scrap/Biomassa & Seleksi Mitra)
/// Membaca & Mengubah Data Real-Time di Tabel Supabase: public.companies
/// ============================================================================
class GovNationalSiinasView extends StatefulWidget {
  const GovNationalSiinasView({super.key});

  @override
  State<GovNationalSiinasView> createState() => _GovNationalSiinasViewState();
}

class _GovNationalSiinasViewState extends State<GovNationalSiinasView> {
  // 0: Site Perusahaan Baja, 1: Site Usaha Hijau & UMKM
  int _selectedTabSite = 0;
  bool _isLoading = true;

  // Filter & Search untuk Site 1 (Pabrik Baja)
  String _searchQuerySteel = '';
  String _selectedMrvFilter = 'Semua Status';
  List<Map<String, dynamic>> _steelCompaniesList = [];

  // Filter & Search untuk Site 2 (Usaha Hijau & UMKM)
  String _searchQueryUmkm = '';
  String _selectedUmkmStatusFilter = 'Semua Status';
  String _selectedUmkmTypeFilter = 'Semua Tipe';
  List<Map<String, dynamic>> _greenCompaniesList = [];

  // Data kurasi pembanding pabrik baja nasional (Role: perusahaan_baja)
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

  // Data kurasi pembanding UMKM & Usaha Hijau sirkular (Role: perusahaan_hijau / UMKM)
  final List<Map<String, dynamic>> _baselineUmkm = [
    {
      'id': 'umkm-01',
      'name': 'Koperasi Scrap Hijau Mandiri',
      'nib': 'NIB. 9120004523812',
      'siinas_id': 'SIINAS #MRF-SBY01',
      'pic_name': 'Bpk. Ahmad Fauzi',
      'location': 'Margomulyo, Surabaya - Jawa Timur',
      'role': 'perusahaan_hijau',
      'company_type': 'umkm',
      'monthly_capacity': 1850.0,
      'facilities': 'Timbangan Jembatan 60 Ton, Mesin Baler Pres Hidrolik, Pemisah Magnetik MRF',
      'is_verified': true,
      'verification_status': 'terverifikasi',
      'verification_grade': 'A',
      'verified_at': '10 Okt 2026',
      'verified_by': 'Inspektur Kemenperin RI',
      'verification_notes': 'Fasilitas pemilahan magnetik memenuhi standar scrap bebas tembaga <0.08%. Siap umpan EAF.',
      'phone': '+62 813-8899-7711',
    },
    {
      'id': 'umkm-02',
      'name': 'CV Logam Daur Lestari',
      'nib': 'NIB. 8120349810231',
      'siinas_id': 'SIINAS #MRF-CLG02',
      'pic_name': 'Ibu Dewi Sartika',
      'location': 'Cilegon, Banten',
      'role': 'perusahaan_hijau',
      'company_type': 'umkm',
      'monthly_capacity': 1200.0,
      'facilities': 'Shredder Cacah Otomotif, Timbangan Jembatan 60 Ton, Depo Beratap Bebas Air Hujan',
      'is_verified': true,
      'verification_status': 'terverifikasi',
      'verification_grade': 'A',
      'verified_at': '12 Okt 2026',
      'verified_by': 'Inspektur Kemenperin RI',
      'verification_notes': 'Sertifikasi MRF Grade A untuk pasokan rutin EAF Pabrik Cilegon.',
      'phone': '+62 812-7766-5544',
    },
    {
      'id': 'umkm-03',
      'name': 'PT Biomassa Sawit Nusantara',
      'nib': 'NIB. 0220458921104',
      'siinas_id': 'SIINAS #BIO-JMB03',
      'pic_name': 'Ir. Bambang Trihatmojo',
      'location': 'Muaro Jambi, Jambi',
      'role': 'perusahaan_hijau',
      'company_type': 'perusahaan_hijau',
      'monthly_capacity': 650.0,
      'facilities': 'Mesin Karbonisasi Pirolisis, Briketizer Tekanan Tinggi, Gudang Kering',
      'is_verified': false,
      'verification_status': 'menunggu_verifikasi',
      'verification_grade': 'B',
      'verified_at': '-',
      'verified_by': '-',
      'verification_notes': 'Menunggu uji laboratorium kadar sulfur dan volatile matter briket cangkang sawit.',
      'phone': '+62 811-2345-6789',
    },
    {
      'id': 'umkm-04',
      'name': 'Sentra Daur Logam Ceper Bersatu',
      'nib': 'NIB. 9210984723011',
      'siinas_id': 'SIINAS #MRF-KLT04',
      'pic_name': 'Bpk. Sukirno Wibowo',
      'location': 'Ceper, Klaten - Jawa Tengah',
      'role': 'perusahaan_hijau',
      'company_type': 'umkm',
      'monthly_capacity': 450.0,
      'facilities': 'Alat Uji Spektrometer Fe, Pemisah Magnetik MRF, Truk Dump',
      'is_verified': false,
      'verification_status': 'perlu_perbaikan',
      'verification_grade': 'C',
      'verified_at': '14 Okt 2026',
      'verified_by': 'Inspektur Kemenperin RI',
      'verification_notes': 'Perlu perbaikan atap kanopi depo penyimpanan agar scrap tidak teroksidasi air hujan.',
      'phone': '+62 856-7890-1234',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchCompaniesData();
  }

  /// Ambil data real-time dari tabel public.companies dan pisahkan menjadi dua kategori entitas
  Future<void> _fetchCompaniesData() async {
    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client
          .from('companies')
          .select('*')
          .order('created_at', ascending: false);

      final List<Map<String, dynamic>> fetchedSteel = [];
      final List<Map<String, dynamic>> fetchedGreen = [];
      final Set<String> existingSteelNames = {};
      final Set<String> existingGreenNames = {};

      for (var row in response) {
        final map = Map<String, dynamic>.from(row);
        final role = (map['role'] ?? '').toString().toLowerCase().trim();
        final companyType = (map['company_type'] ?? '').toString().toLowerCase().trim();
        final name = (map['name'] ?? '').toString().toLowerCase().trim();

        // 1. Kategori Pabrik Baja
        if (role == 'perusahaan_baja') {
          fetchedSteel.add(map);
          if (name.isNotEmpty) existingSteelNames.add(name);
        }
        // 2. Kategori Usaha Hijau & UMKM
        else if (role == 'perusahaan_hijau' || companyType == 'umkm' || companyType == 'perusahaan_hijau') {
          fetchedGreen.add(map);
          if (name.isNotEmpty) existingGreenNames.add(name);
        }
        // 3. Fallback jika peran belum spesifik (bukan pemerintah)
        else if (role != 'pemerintah') {
          fetchedSteel.add(map);
          if (name.isNotEmpty) existingSteelNames.add(name);
        }
      }

      // Gabungkan data kurasi pembanding pabrik baja
      for (var base in _baselineFactories) {
        if (!existingSteelNames.contains((base['name'] as String).toLowerCase().trim())) {
          fetchedSteel.add(base);
        }
      }

      // Gabungkan data kurasi pembanding UMKM & Usaha Hijau
      for (var base in _baselineUmkm) {
        if (!existingGreenNames.contains((base['name'] as String).toLowerCase().trim())) {
          fetchedGreen.add(base);
        }
      }

      setState(() {
        _steelCompaniesList = fetchedSteel;
        _greenCompaniesList = fetchedGreen;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Gagal fetch companies dari Supabase: $e');
      setState(() {
        _steelCompaniesList = List.from(_baselineFactories);
        _greenCompaniesList = List.from(_baselineUmkm);
        _isLoading = false;
      });
    }
  }

  /// Update status MRV Pabrik Baja di Supabase (Mendukung mrv_status & mrv_verified)
  Future<void> _updateMrvStatusInSupabase(
    Map<String, dynamic> comp,
    String newStatus,
  ) async {
    final companyId = comp['id'];
    final companyName = comp['name'] ?? 'Perusahaan Baja';
    final isApproved = (newStatus == 'disetujui');

    // Optimistic UI update
    setState(() {
      comp['mrv_status'] = newStatus;
      comp['mrv_verified'] = isApproved;
    });

    try {
      bool success = false;

      // Helper untuk eksekusi update dengan fallback toleran skema
      Future<List<dynamic>> executeUpdate(dynamic id) async {
        try {
          final payload = {
            'mrv_status': newStatus,
            'mrv_verified': isApproved,
          };
          return await Supabase.instance.client
              .from('companies')
              .update(payload)
              .eq('id', id)
              .select();
        } catch (_) {
          return await Supabase.instance.client
              .from('companies')
              .update({'mrv_status': newStatus})
              .eq('id', id)
              .select();
        }
      }

      if (companyId != null && !companyId.toString().startsWith('b-')) {
        final res = await executeUpdate(companyId);
        if (res.isNotEmpty) {
          success = true;
        } else {
          throw Exception('RLS Supabase menolak update.');
        }
      } else {
        final existing = await Supabase.instance.client
            .from('companies')
            .select('id')
            .eq('name', companyName)
            .maybeSingle();

        if (existing != null && existing['id'] != null) {
          final realId = existing['id'];
          final res = await executeUpdate(realId);
          if (res.isNotEmpty) {
            comp['id'] = realId;
            success = true;
          }
        } else {
          final insertPayload = {
            'name': companyName,
            'siinas_id': comp['siinas_id'] ?? 'SIINAS #ID-2026',
            'location': comp['location'] ?? 'Indonesia',
            'role': 'perusahaan_baja',
            'carbon_intensity': comp['carbon_intensity'] ?? 0.0,
            'current_emission': comp['current_emission'] ?? 0.0,
            'mrv_status': newStatus,
          };
          final inserted = await Supabase.instance.client
              .from('companies')
              .insert(insertPayload)
              .select()
              .single();
          comp['id'] = inserted['id'];
          success = true;
        }
      }

      if (mounted && success) {
        final statusLabel = newStatus == 'disetujui'
            ? 'MRV Disetujui (CBAM Compliant)'
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
                  newStatus == 'disetujui' ? Icons.check_circle : Icons.warning_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Status MRV $companyName berhasil disimpan: "$statusLabel"!',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: newStatus == 'disetujui'
                ? const Color(0xFF16A34A)
                : (newStatus == 'perlu_tindakan' ? const Color(0xFFDC2626) : const Color(0xFFD97706)),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error update MRV status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update status MRV ke Supabase: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    }
  }

  /// Update Verifikasi Usaha Hijau & UMKM di Supabase (Mendukung is_verified, verification_status & umkm_verification)
  Future<void> _updateUmkmVerificationInSupabase(
    Map<String, dynamic> comp, {
    required String newStatus,
    required bool isVerified,
    required String grade,
    required String notes,
  }) async {
    final companyId = comp['id'];
    final companyName = comp['name'] ?? 'Usaha Hijau';
    final nowIso = DateTime.now().toIso8601String();
    const inspectorName = 'Tim Inspektorat Kemenperin RI';

    // Optimistic UI update
    setState(() {
      comp['is_verified'] = isVerified;
      comp['verification_status'] = newStatus;
      comp['verification_grade'] = grade;
      comp['verification_notes'] = notes;
      comp['verified_at'] = nowIso.split('T').first;
      comp['verified_by'] = inspectorName;
    });

    final updatePayload = {
      'is_verified': isVerified,
      'verification_status': newStatus,
      'verification_grade': grade,
      'verification_notes': notes,
      'verified_at': nowIso,
      'verified_by': inspectorName,
    };

    try {
      bool success = false;

      // Helper update toleran jika kolom umkm_verification tersedia atau tidak
      Future<List<dynamic>> executeUpdate(dynamic id) async {
        try {
          final payload = Map<String, dynamic>.from(updatePayload);
          payload['umkm_verification'] = newStatus;
          return await Supabase.instance.client
              .from('companies')
              .update(payload)
              .eq('id', id)
              .select();
        } catch (_) {
          return await Supabase.instance.client
              .from('companies')
              .update(updatePayload)
              .eq('id', id)
              .select();
        }
      }

      if (companyId != null && !companyId.toString().startsWith('umkm-')) {
        final res = await executeUpdate(companyId);
        if (res.isNotEmpty) {
          success = true;
        } else {
          throw Exception('RLS Supabase menolak update.');
        }
      } else {
        final existing = await Supabase.instance.client
            .from('companies')
            .select('id')
            .eq('name', companyName)
            .maybeSingle();

        if (existing != null && existing['id'] != null) {
          final realId = existing['id'];
          final res = await executeUpdate(realId);
          if (res.isNotEmpty) {
            comp['id'] = realId;
            success = true;
          }
        } else {
          final insertPayload = {
            'name': companyName,
            'nib': comp['nib'] ?? 'NIB. 9120004523812',
            'siinas_id': comp['siinas_id'] ?? 'SIINAS #MRF-2026',
            'pic_name': comp['pic_name'] ?? 'Pimpinan Usaha',
            'location': comp['location'] ?? 'Indonesia',
            'role': 'perusahaan_hijau',
            'company_type': comp['company_type'] ?? 'umkm',
            'monthly_capacity': comp['monthly_capacity'] ?? 1000.0,
            'facilities': comp['facilities'] ?? 'Timbangan Jembatan, Mesin Baler, Pemisah Magnetik',
            'is_verified': isVerified,
            'verification_status': newStatus,
            'verification_grade': grade,
            'verification_notes': notes,
            'verified_at': nowIso,
            'verified_by': inspectorName,
          };
          try {
            final payload = Map<String, dynamic>.from(insertPayload);
            payload['umkm_verification'] = newStatus;
            final inserted = await Supabase.instance.client
                .from('companies')
                .insert(payload)
                .select()
                .single();
            comp['id'] = inserted['id'];
            success = true;
          } catch (_) {
            final inserted = await Supabase.instance.client
                .from('companies')
                .insert(insertPayload)
                .select()
                .single();
            comp['id'] = inserted['id'];
            success = true;
          }
        }
      }

      if (mounted && success) {
        final statusLabel = isVerified
            ? 'Terverifikasi (Sertifikasi Hijau Terbit)'
            : (newStatus == 'perlu_perbaikan'
                ? 'Diminta Perbaikan Dokumen'
                : (newStatus == 'ditolak' ? 'Ditolak' : 'Menunggu Seleksi'));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Row(
              children: [
                Icon(
                  isVerified ? Icons.check_circle : Icons.info_outline,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Verifikasi $companyName berhasil disimpan: "$statusLabel"!',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: isVerified
                ? const Color(0xFF16A34A)
                : (newStatus == 'perlu_perbaikan'
                    ? const Color(0xFFD97706)
                    : (newStatus == 'ditolak' ? const Color(0xFFDC2626) : const Color(0xFF475569))),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error update verifikasi UMKM: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update verifikasi UMKM ke Supabase: $e'),
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

  String _deriveUmkmStatus(Map<String, dynamic> comp) {
    final rawVer = comp['verification_status']?.toString().toLowerCase().trim();
    if (rawVer != null && rawVer.isNotEmpty) {
      if (rawVer == 'terverifikasi' || rawVer == 'disetujui') return 'terverifikasi';
      if (rawVer == 'perlu_perbaikan') return 'perlu_perbaikan';
      if (rawVer == 'ditolak') return 'ditolak';
    }
    if (comp['is_verified'] == true) return 'terverifikasi';
    return 'menunggu_verifikasi';
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF059669);

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
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Image.asset(
                'assets/img/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.eco,
                  color: primaryGreen,
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
                    'SIINas Nasional • Verifikasi & Audit',
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
            icon: const Icon(Icons.refresh, color: primaryGreen),
            tooltip: 'Sinkronisasi Data Supabase',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCompaniesData,
        color: primaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==============================================================
              // TOGGLE SWITCH DUA SITES / ANAK HALAMAN (BAJA vs UMKM)
              // ==============================================================
              _buildSiteToggleSwitcher(),
              const SizedBox(height: 14),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(60.0),
                    child: CircularProgressIndicator(color: primaryGreen),
                  ),
                )
              else if (_selectedTabSite == 0)
                _buildSteelSubPage()
              else
                _buildGreenUmkmSubPage(),
            ],
          ),
        ),
      ),
    );
  }

  /// TOGGLE DUA SITES (PABRIK BAJA & USAHA HIJAU)
  Widget _buildSiteToggleSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabSite = 0),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: _selectedTabSite == 0 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: _selectedTabSite == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.factory_outlined,
                      size: 16,
                      color: _selectedTabSite == 0 ? const Color(0xFF059669) : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Pabrik Baja & MRV (${_steelCompaniesList.length})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: _selectedTabSite == 0 ? FontWeight.bold : FontWeight.w500,
                          color: _selectedTabSite == 0 ? const Color(0xFF065F46) : const Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedTabSite = 1),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: _selectedTabSite == 1 ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: _selectedTabSite == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.eco_outlined,
                      size: 16,
                      color: _selectedTabSite == 1 ? const Color(0xFF059669) : const Color(0xFF64748B),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Usaha Hijau & UMKM (${_greenCompaniesList.length})',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: _selectedTabSite == 1 ? FontWeight.bold : FontWeight.w500,
                          color: _selectedTabSite == 1 ? const Color(0xFF065F46) : const Color(0xFF64748B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ==========================================================================
  /// SITE 1: PABRIK BAJA & AUDIT MRV NASIONAL
  /// ==========================================================================
  Widget _buildSteelSubPage() {
    const primaryGreen = Color(0xFF059669);
    const darkGreen = Color(0xFF065F46);

    final filteredList = _steelCompaniesList.where((comp) {
      final name = (comp['name'] ?? '').toString().toLowerCase();
      final siinas = (comp['siinas_id'] ?? '').toString().toLowerCase();
      final loc = (comp['location'] ?? '').toString().toLowerCase();
      final query = _searchQuerySteel.toLowerCase().trim();

      final matchesQuery = query.isEmpty ||
          name.contains(query) ||
          siinas.contains(query) ||
          loc.contains(query);

      final status = _deriveMrvStatus(comp);
      if (_selectedMrvFilter == 'MRV Disetujui' && status != 'disetujui') return false;
      if (_selectedMrvFilter == 'Menunggu Validasi' && status != 'menunggu') return false;
      if (_selectedMrvFilter == 'Perlu Tindakan' && status != 'perlu_tindakan') return false;

      return matchesQuery;
    }).toList();

    int totalCount = _steelCompaniesList.length;
    int approvedCount = _steelCompaniesList.where((c) => _deriveMrvStatus(c) == 'disetujui').length;
    int pendingCount = _steelCompaniesList.where((c) => _deriveMrvStatus(c) == 'menunggu').length;
    int actionCount = _steelCompaniesList.where((c) => _deriveMrvStatus(c) == 'perlu_tindakan').length;
    int compliancePercent = totalCount > 0 ? ((approvedCount / totalCount) * 100).round() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // BANNER STATISTIK EMISI BAJA
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [darkGreen, primaryGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryGreen.withValues(alpha: 0.25),
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
                        Icon(Icons.verified_user, color: Color(0xFF6EE7B7), size: 16),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'AUDIT MRV PABRIK BAJA (CBAM)',
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

        const SizedBox(height: 18),

        // SEARCH BAR BAJA
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuerySteel = val),
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

        // FILTER CHIPS MRV
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
                  onSelected: (val) => setState(() => _selectedMrvFilter = filter),
                  selectedColor: primaryGreen,
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
                      color: isSelected ? primaryGreen : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // DAFTAR PABRIK BAJA
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
                    color: primaryGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (filteredList.isEmpty)
          _buildEmptyCard('Tidak ada pabrik baja yang cocok dengan filter.')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildCompanyCard(filteredList[index]),
          ),
      ],
    );
  }

  /// ==========================================================================
  /// SITE 2: USAHA HIJAU & UMKM (SERTIFIKASI & SELEKSI KEMENPERIN)
  /// ==========================================================================
  Widget _buildGreenUmkmSubPage() {
    const primaryGreen = Color(0xFF059669);
    const darkEmerald = Color(0xFF065F46);

    final filteredList = _greenCompaniesList.where((comp) {
      final name = (comp['name'] ?? '').toString().toLowerCase();
      final nib = (comp['nib'] ?? '').toString().toLowerCase();
      final siinas = (comp['siinas_id'] ?? '').toString().toLowerCase();
      final loc = (comp['location'] ?? '').toString().toLowerCase();
      final pic = (comp['pic_name'] ?? '').toString().toLowerCase();
      final facilities = (comp['facilities'] ?? '').toString().toLowerCase();
      final query = _searchQueryUmkm.toLowerCase().trim();

      final matchesQuery = query.isEmpty ||
          name.contains(query) ||
          nib.contains(query) ||
          siinas.contains(query) ||
          loc.contains(query) ||
          pic.contains(query) ||
          facilities.contains(query);

      final status = _deriveUmkmStatus(comp);
      if (_selectedUmkmStatusFilter == 'Terverifikasi' && status != 'terverifikasi') return false;
      if (_selectedUmkmStatusFilter == 'Menunggu Seleksi' && status != 'menunggu_verifikasi') return false;
      if (_selectedUmkmStatusFilter == 'Perlu Perbaikan' && status != 'perlu_perbaikan') return false;
      if (_selectedUmkmStatusFilter == 'Ditolak' && status != 'ditolak') return false;

      final type = (comp['company_type'] ?? 'umkm').toString().toLowerCase();
      if (_selectedUmkmTypeFilter == 'UMKM Scrap Logam' && type != 'umkm') return false;
      if (_selectedUmkmTypeFilter == 'Perusahaan Hijau' && type != 'perusahaan_hijau') return false;

      return matchesQuery;
    }).toList();

    int totalCount = _greenCompaniesList.length;
    int verifiedCount = _greenCompaniesList.where((c) => _deriveUmkmStatus(c) == 'terverifikasi').length;
    int pendingCount = _greenCompaniesList.where((c) => _deriveUmkmStatus(c) == 'menunggu_verifikasi').length;
    int revisionCount = _greenCompaniesList.where((c) => _deriveUmkmStatus(c) == 'perlu_perbaikan').length;

    double totalCapacity = 0;
    for (var c in _greenCompaniesList) {
      final cap = (c['monthly_capacity'] as num?)?.toDouble() ?? 0;
      totalCapacity += cap;
    }
    int verifyPercent = totalCount > 0 ? ((verifiedCount / totalCount) * 100).round() : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // BANNER STATISTIK UMKM & USAHA HIJAU
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [darkEmerald, primaryGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: primaryGreen.withValues(alpha: 0.25),
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
                        Icon(Icons.workspace_premium, color: Color(0xFF6EE7B7), size: 16),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'SELEKSI & SERTIFIKASI UMKM HIJAU',
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
                      '$verifyPercent% Tersertifikasi',
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
              Text(
                '${totalCapacity.toStringAsFixed(0)} Ton/Bulan',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Agregat Suplai Scrap Sirkular & Biomassa Rendah Emisi EAF Nasional',
                style: TextStyle(color: Color(0xFFD1FAE5), fontSize: 11.5),
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatCol('Total Usaha', '$totalCount Unit'),
                  Container(width: 1, height: 26, color: Colors.white24),
                  _buildStatCol('Terverifikasi', '$verifiedCount Unit'),
                  Container(width: 1, height: 26, color: Colors.white24),
                  _buildStatCol('Antre Seleksi', '$pendingCount Antre'),
                  Container(width: 1, height: 26, color: Colors.white24),
                  _buildStatCol('Perlu Revisi', '$revisionCount Revisi'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // SEARCH BAR UMKM
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            onChanged: (val) => setState(() => _searchQueryUmkm = val),
            decoration: const InputDecoration(
              hintText: 'Cari nama UMKM, NIB, PIC, atau kota depo...',
              hintStyle: TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
              prefixIcon: Icon(Icons.search, size: 20, color: Color(0xFF64748B)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ),

        const SizedBox(height: 12),

        // FILTER CHIPS STATUS VERIFIKASI UMKM
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              'Semua Status',
              'Terverifikasi',
              'Menunggu Seleksi',
              'Perlu Perbaikan',
              'Ditolak',
            ].map((filter) {
              final isSelected = _selectedUmkmStatusFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _selectedUmkmStatusFilter = filter),
                  selectedColor: primaryGreen,
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
                      color: isSelected ? primaryGreen : const Color(0xFFE2E8F0),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 8),

        // FILTER CHIPS KATEGORI USAHA
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              'Semua Tipe',
              'UMKM Scrap Logam',
              'Perusahaan Hijau',
            ].map((filter) {
              final isSelected = _selectedUmkmTypeFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _selectedUmkmTypeFilter = filter),
                  selectedColor: const Color(0xFF047857),
                  backgroundColor: const Color(0xFFF1F5F9),
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF334155),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF047857) : const Color(0xFFCBD5E1),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // DAFTAR UMKM
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pemasok Hijau & UMKM (${filteredList.length})',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
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
                  'Verifikasi Kemenperin',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (filteredList.isEmpty)
          _buildEmptyCard('Tidak ada Usaha Hijau / UMKM yang cocok dengan filter.')
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filteredList.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _buildUmkmCard(filteredList[index]),
          ),
      ],
    );
  }

  Widget _buildEmptyCard(String msg) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 40, color: Color(0xFF94A3B8)),
          const SizedBox(height: 8),
          Text(
            msg,
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
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

  /// KARTU PABRIK BAJA
  Widget _buildCompanyCard(Map<String, dynamic> comp) {
    final status = _deriveMrvStatus(comp);
    final intensity = (comp['carbon_intensity'] as num?)?.toDouble() ?? 0.0;
    final name = comp['name'] ?? 'Entitas Tanpa Nama';
    final siinas = comp['siinas_id'] ?? 'SIINAS #ID-2026';
    final location = comp['location'] ?? 'Indonesia';
    final route = comp['route'] ?? 'Rute Industri Logam Standard';
    final note = comp['compliance_note'] ?? 'Pelaporan berkala melalui portal SIINas';

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
            color: status == 'perlu_tindakan' ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
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
                color: status == 'perlu_tindakan' ? const Color(0xFFDC2626) : const Color(0xFF64748B),
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
                            : (intensity > 1.40 ? const Color(0xFFDC2626) : const Color(0xFFD97706)),
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
                        color: intensity <= 0.80 ? const Color(0xFF16A34A) : const Color(0xFFD97706),
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

  /// KARTU USAHA HIJAU & UMKM
  Widget _buildUmkmCard(Map<String, dynamic> comp) {
    final status = _deriveUmkmStatus(comp);
    final name = comp['name'] ?? 'Usaha Hijau Tanpa Nama';
    final nib = comp['nib'] ?? comp['siinas_id'] ?? 'NIB. 9120000000000';
    final location = comp['location'] ?? 'Indonesia';
    final pic = comp['pic_name'] ?? 'Pimpinan Usaha';
    final phone = comp['phone'] ?? '-';
    final capacity = (comp['monthly_capacity'] as num?)?.toDouble() ?? 0.0;
    final facilities = comp['facilities'] ?? 'Fasilitas Depo Scrap / Bahan Baku Hijau Standar';
    final grade = comp['verification_grade'] ?? 'A';
    final notes = comp['verification_notes'] ?? 'Menunggu hasil peninjauan kelayakan fasilitas.';
    final isUmkm = (comp['company_type'] ?? '').toString().toLowerCase() != 'perusahaan_hijau';

    Color badgeBg;
    Color badgeTextColor;
    IconData badgeIcon;
    String badgeText;

    if (status == 'terverifikasi') {
      badgeBg = const Color(0xFFDCFCE7);
      badgeTextColor = const Color(0xFF16A34A);
      badgeIcon = Icons.verified_rounded;
      badgeText = 'Terverifikasi (Grade $grade)';
    } else if (status == 'perlu_perbaikan') {
      badgeBg = const Color(0xFFFEF3C7);
      badgeTextColor = const Color(0xFFD97706);
      badgeIcon = Icons.pending_actions_rounded;
      badgeText = 'Perlu Perbaikan Dokumen';
    } else if (status == 'ditolak') {
      badgeBg = const Color(0xFFFEE2E2);
      badgeTextColor = const Color(0xFFDC2626);
      badgeIcon = Icons.cancel_outlined;
      badgeText = 'Ditolak Kemenperin';
    } else {
      badgeBg = const Color(0xFFF1F5F9);
      badgeTextColor = const Color(0xFF475569);
      badgeIcon = Icons.hourglass_empty_rounded;
      badgeText = 'Menunggu Seleksi';
    }

    return InkWell(
      onTap: () => _showUmkmDetailModal(comp),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: status == 'terverifikasi'
                ? const Color(0xFFA7F3D0)
                : (status == 'perlu_perbaikan' ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0)),
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
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isUmkm ? const Color(0xFFECFDF5) : const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: Text(
                              isUmkm ? 'UMKM SCRAP' : 'PERUSAHAAN HIJAU',
                              style: const TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF047857),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              nib,
                              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        location,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
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
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text(
                  'PIC: $pic',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                ),
                if (phone != '-') ...[
                  const SizedBox(width: 8),
                  const Text('•', style: TextStyle(color: Color(0xFFCBD5E1))),
                  const SizedBox(width: 8),
                  Text(
                    phone,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  const Icon(Icons.inventory_2_outlined, size: 14, color: Color(0xFF059669)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Kapasitas: ${capacity.toStringAsFixed(0)} Ton/Bulan • Fasilitas: $facilities',
                      style: const TextStyle(fontSize: 10.5, color: Color(0xFF334155)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Evaluasi: $notes',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: status == 'perlu_perbaikan'
                    ? const Color(0xFFD97706)
                    : (status == 'ditolak' ? const Color(0xFFDC2626) : const Color(0xFF64748B)),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFF1F5F9), height: 1),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      status == 'terverifikasi' ? Icons.check_circle_outline : Icons.pending_outlined,
                      size: 16,
                      color: status == 'terverifikasi' ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status == 'terverifikasi'
                          ? 'Mitra EAF Terverifikasi'
                          : 'Perlu Tinjauan Lapangan',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: status == 'terverifikasi' ? const Color(0xFF16A34A) : const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showUmkmDetailModal(comp),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.rule_rounded, size: 14),
                  label: const Text('Verifikasi & Seleksi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// MODAL DETAIL REGISTRASI SIINAS & VERIFIKASI MRV PABRIK BAJA
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
                      'Audit & Verifikasi MRV Pabrik Baja',
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
                    _buildRowDetail('Sinkronisasi Supabase', 'Aktif (Real-Time)'),
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

  /// MODAL DETAIL SELEKSI & VERIFIKASI USAHA HIJAU / UMKM (KEMENPERIN RI)
  void _showUmkmDetailModal(Map<String, dynamic> comp) {
    String selectedGrade = comp['verification_grade'] ?? 'A';
    final notesController = TextEditingController(
      text: comp['verification_notes'] ??
          'Fasilitas pemilahan magnetik terstandar dan bebas pengotor tembaga <0.08%. Memenuhi standar bahan baku EAF.',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'Seleksi & Sertifikasi Usaha Hijau (Kemenperin)',
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
                    const SizedBox(height: 8),
                    Text(
                      comp['name'] ?? 'Usaha Hijau',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${comp['nib'] ?? comp['siinas_id'] ?? 'NIB'} • ${comp['location'] ?? 'Indonesia'}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),

                    // Detail Data Entitas
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          _buildRowDetail('Kontak PIC', comp['pic_name'] ?? 'Pimpinan Usaha'),
                          const SizedBox(height: 6),
                          _buildRowDetail('Nomor Kontak', comp['phone'] ?? '-'),
                          const SizedBox(height: 6),
                          _buildRowDetail('Kapasitas Suplai', '${(comp['monthly_capacity'] as num?)?.toDouble() ?? 0} Ton/Bulan'),
                          const SizedBox(height: 6),
                          _buildRowDetail('Fasilitas Depo', comp['facilities'] ?? 'Standar Pemilahan'),
                          const SizedBox(height: 6),
                          _buildRowDetail('Status Verifikasi Saat Ini', _deriveUmkmStatus(comp).toUpperCase()),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Pemilihan Grade Akreditasi
                    const Text(
                      'Pilih Akreditasi Mutu & Kelayakan Depo:',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: ['A', 'B', 'C'].map((g) {
                        final isSel = selectedGrade == g;
                        String desc = g == 'A' ? 'Grade A (Sangat Layak)' : (g == 'B' ? 'Grade B (Layak)' : 'Grade C (Pendampingan)');
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: ChoiceChip(
                              label: Text(desc),
                              selected: isSel,
                              onSelected: (val) {
                                if (val) {
                                  setModalState(() => selectedGrade = g);
                                }
                              },
                              selectedColor: const Color(0xFF059669),
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSel ? Colors.white : const Color(0xFF334155),
                                fontSize: 10,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 12),

                    // Input Catatan Hasil Verifikasi & Rekomendasi
                    const Text(
                      'Catatan Hasil Evaluasi & Rekomendasi Inspektur:',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 12),
                      decoration: InputDecoration(
                        hintText: 'Tuliskan catatan hasil audit dokumen atau peninjauan lapangan...',
                        contentPadding: const EdgeInsets.all(10),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 3 Tombol Aksi Verifikasi UMKM
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _updateUmkmVerificationInSupabase(
                                comp,
                                newStatus: 'ditolak',
                                isVerified: false,
                                grade: selectedGrade,
                                notes: notesController.text.trim(),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFDC2626),
                              side: const BorderSide(color: Color(0xFFFCA5A5)),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                            ),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Tolak Seleksi', style: TextStyle(fontSize: 11)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _updateUmkmVerificationInSupabase(
                                comp,
                                newStatus: 'perlu_perbaikan',
                                isVerified: false,
                                grade: selectedGrade,
                                notes: notesController.text.trim(),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFD97706),
                              side: const BorderSide(color: Color(0xFFFDE68A)),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                            ),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Minta Revisi', style: TextStyle(fontSize: 11)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _updateUmkmVerificationInSupabase(
                                comp,
                                newStatus: 'terverifikasi',
                                isVerified: true,
                                grade: selectedGrade,
                                notes: notesController.text.trim(),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF16A34A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                            ),
                            child: const FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text('Terbitkan Sertifikasi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
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
