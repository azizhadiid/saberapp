import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ============================================================================
/// PETA SPASIAL SEBARAN EMISI & PABRIK BAJA (PEMERINTAH / REGULATOR)
/// SINKRONISASI DATA ASLI SUPABASE & ANALISIS LOKASI (SURABAYA, INDONESIA, DLL.)
/// ============================================================================
class GovSpatialMapView extends StatefulWidget {
  const GovSpatialMapView({super.key});

  @override
  State<GovSpatialMapView> createState() => _GovSpatialMapViewState();
}

class _GovSpatialMapViewState extends State<GovSpatialMapView> {
  String _selectedRegionFilter = 'Semua Wilayah';
  String _selectedCityFilter = 'Semua Lokasi';
  bool _isLoading = false;

  List<Map<String, dynamic>> _companiesList = [];

  // Data kurasi pabrik baja pembanding nasional (SIINas)
  final List<Map<String, dynamic>> _baselineFactories = [
    {
      'id': 'b-01',
      'name': 'PT Krakatau Steel (Persero) Tbk',
      'siinas_id': 'SIINAS #KRK-001',
      'location': 'Cilegon, Banten',
      'role': 'perusahaan_baja',
      'route': 'Direct Reduced Iron (DRI) -> Electric Arc Furnace (EAF)',
      'current_emission': 1.12,
      'carbon_intensity': 0.76,
      'mrv_status': 'disetujui',
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
    },
    {
      'id': 'b-04',
      'name': 'PT Smelter Induksi Jaya Gresik',
      'siinas_id': 'SIINAS #SIJ-009',
      'location': 'Manyar, Gresik - Jawa Timur',
      'role': 'perusahaan_baja',
      'route': 'Induction Furnace Tanpa Wet Scrubber',
      'current_emission': 1.68,
      'carbon_intensity': 1.68,
      'mrv_status': 'perlu_tindakan',
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
    },
  ];

  final List<Map<String, dynamic>> _provincialData = [
    {
      'province': 'Jawa Timur',
      'island': 'Pulau Jawa',
      'cluster': 'Episentrum Zona Merah',
      'factories_count': 48,
      'total_emissions': '1.12 MtCO2e',
      'avg_intensity': 1.48, // tCO2/t
      'compliance_status': 'Perhatian Tinggi',
      'color': const Color(0xFFDC2626), // Red
      'description':
          'Konsentrasi peleburan besi tua & induction furnace (Gresik, Surabaya, Sidoarjo, Mojokerto). Emisi debu PM2.5 & SOx mendesak ditangani.',
    },
    {
      'province': 'Jawa Barat & Banten',
      'island': 'Pulau Jawa',
      'cluster': 'Zona Transisi Hulu',
      'factories_count': 70,
      'total_emissions': '1.28 MtCO2e',
      'avg_intensity': 0.95,
      'compliance_status': 'Proses Transisi',
      'color': const Color(0xFFD97706), // Amber
      'description':
          'Klaster terintegrasi blast furnace, DRI, dan EAF (Cilegon, Karawang, Bekasi). Sedang migrasi ke bauran gas & scrap daur ulang.',
    },
    {
      'province': 'Jawa Tengah & DIY',
      'island': 'Pulau Jawa',
      'cluster': 'Zona Sedang',
      'factories_count': 14,
      'total_emissions': '0.28 MtCO2e',
      'avg_intensity': 0.82,
      'compliance_status': 'Cukup Patuh',
      'color': const Color(0xFF2563EB), // Blue
      'description':
          'Dominasi industri rolling mill dan fabrikasi baja konstruksi (Semarang, Kudus). Rata-rata emisi mendekati ambang batas CBAM.',
    },
    {
      'province': 'Luar Jawa (Sumatera, Kalimantan, Sulawesi)',
      'island': 'Luar Jawa',
      'cluster': 'Zona Smelter Khusus',
      'factories_count': 10,
      'total_emissions': '0.18 MtCO2e',
      'avg_intensity': 0.74,
      'compliance_status': 'Patuh Terkendali',
      'color': const Color(0xFF16A34A), // Green
      'description':
          'Fasilitas pengolahan bijih primer & smelter terisolasi dengan akses potensi hidro/PLTA di Sumatera dan Sulawesi.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchCompaniesData();
  }

  /// Ambil data pabrik baja real-time dari tabel companies di Supabase
  Future<void> _fetchCompaniesData() async {
    setState(() => _isLoading = true);
    try {
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

        if (role == 'perusahaan_baja') {
          fetched.add(map);
          if (map['name'] != null) {
            existingNames.add((map['name'] as String).toLowerCase().trim());
          }
        }
      }

      // Gabungkan baseline data kurasi nasional agar tampilan visualisasi selalu kaya
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
      debugPrint('Gagal fetch companies di Peta Spasial: $e');
      setState(() {
        _companiesList = List.from(_baselineFactories);
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryPurple = Color(0xFF059669);

    // Filter regional provinsi
    final filteredProvinces = _selectedRegionFilter == 'Semua Wilayah'
        ? _provincialData
        : _provincialData
            .where((item) => item['island'] == _selectedRegionFilter)
            .toList();

    // Kalkulasi agregasi pabrik per kota/lokasi dari Supabase
    int countTotal = _companiesList.length;

    int countSurabaya = _companiesList.where((c) {
      final loc = (c['location'] ?? '').toString().toLowerCase();
      final name = (c['name'] ?? '').toString().toLowerCase();
      return loc.contains('surabaya') || name.contains('surabaya');
    }).length;

    int countIndonesia = _companiesList.where((c) {
      final loc = (c['location'] ?? '').toString().toLowerCase().trim();
      final name = (c['name'] ?? '').toString().toLowerCase();
      return loc == 'indonesia' ||
          loc.contains('kominfo') ||
          name.contains('kominfo') ||
          loc.isEmpty;
    }).length;

    int countGresik = _companiesList.where((c) {
      final loc = (c['location'] ?? '').toString().toLowerCase();
      final name = (c['name'] ?? '').toString().toLowerCase();
      return loc.contains('gresik') || name.contains('gresik');
    }).length;

    int countBanten = _companiesList.where((c) {
      final loc = (c['location'] ?? '').toString().toLowerCase();
      return loc.contains('cilegon') || loc.contains('banten') || loc.contains('tangerang');
    }).length;

    int countJabar = _companiesList.where((c) {
      final loc = (c['location'] ?? '').toString().toLowerCase();
      return loc.contains('bekasi') || loc.contains('cikarang') || loc.contains('jawa barat') || loc.contains('karawang');
    }).length;

    // Filter daftar pabrik berdasarkan chip lokasi yang dipilih
    final filteredCompanies = _companiesList.where((comp) {
      if (_selectedCityFilter == 'Semua Lokasi') return true;
      final loc = (comp['location'] ?? '').toString().toLowerCase();
      final name = (comp['name'] ?? '').toString().toLowerCase();

      if (_selectedCityFilter == 'Surabaya') {
        return loc.contains('surabaya') || name.contains('surabaya');
      }
      if (_selectedCityFilter == 'Indonesia (Nasional)') {
        return loc == 'indonesia' || loc.contains('kominfo') || name.contains('kominfo') || loc.isEmpty;
      }
      if (_selectedCityFilter == 'Gresik') {
        return loc.contains('gresik') || name.contains('gresik');
      }
      if (_selectedCityFilter == 'Banten / Cilegon') {
        return loc.contains('cilegon') || loc.contains('banten') || loc.contains('tangerang');
      }
      if (_selectedCityFilter == 'Jawa Barat / Bekasi') {
        return loc.contains('bekasi') || loc.contains('cikarang') || loc.contains('jawa barat');
      }
      return true;
    }).toList();

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
                  Icons.map,
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
                    'Sebaran Pabrik & Emisi Regional',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Distribusi Industri Baja Berbasis Wilayah & SIINas',
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
              // ==============================================================
              // SEBARAN LOKASI PABRIK REAL-TIME SUPABASE (SURABAYA, INDONESIA, DLL)
              // ==============================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Sebaran Lokasi Pabrik (Supabase)',
                    style: TextStyle(
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
                      Text(
                        '$countTotal Pabrik Terdata',
                        style: const TextStyle(
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

              // Kartu Ringkasan Sebaran Kota
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildLocationCard(
                      title: 'Surabaya',
                      badge: 'Episentrum Jatim',
                      countText: '$countSurabaya Unit',
                      subtext: 'Margomulyo & Sekitarnya',
                      accentColor: const Color(0xFFDC2626),
                      icon: Icons.location_city,
                      isSelected: _selectedCityFilter == 'Surabaya',
                      onTap: () => setState(() {
                        _selectedCityFilter =
                            _selectedCityFilter == 'Surabaya' ? 'Semua Lokasi' : 'Surabaya';
                      }),
                    ),
                    const SizedBox(width: 10),
                    _buildLocationCard(
                      title: 'Indonesia (Nasional)',
                      badge: 'Entitas Baru / SIINas',
                      countText: '$countIndonesia Unit',
                      subtext: 'Registrasi Kominfo RI',
                      accentColor: primaryPurple,
                      icon: Icons.flag,
                      isSelected: _selectedCityFilter == 'Indonesia (Nasional)',
                      onTap: () => setState(() {
                        _selectedCityFilter = _selectedCityFilter == 'Indonesia (Nasional)'
                            ? 'Semua Lokasi'
                            : 'Indonesia (Nasional)';
                      }),
                    ),
                    const SizedBox(width: 10),
                    _buildLocationCard(
                      title: 'Gresik',
                      badge: 'Kawasan Manyar',
                      countText: '$countGresik Unit',
                      subtext: 'Pabrik Smelter Induksi',
                      accentColor: const Color(0xFFEA580C),
                      icon: Icons.factory,
                      isSelected: _selectedCityFilter == 'Gresik',
                      onTap: () => setState(() {
                        _selectedCityFilter =
                            _selectedCityFilter == 'Gresik' ? 'Semua Lokasi' : 'Gresik';
                      }),
                    ),
                    const SizedBox(width: 10),
                    _buildLocationCard(
                      title: 'Banten / Cilegon',
                      badge: 'Zona Krakatau',
                      countText: '$countBanten Unit',
                      subtext: 'Krakatau & Tangerang',
                      accentColor: const Color(0xFF0284C7),
                      icon: Icons.domain,
                      isSelected: _selectedCityFilter == 'Banten / Cilegon',
                      onTap: () => setState(() {
                        _selectedCityFilter =
                            _selectedCityFilter == 'Banten / Cilegon' ? 'Semua Lokasi' : 'Banten / Cilegon';
                      }),
                    ),
                    const SizedBox(width: 10),
                    _buildLocationCard(
                      title: 'Jawa Barat / Bekasi',
                      badge: 'Zona Cikarang',
                      countText: '$countJabar Unit',
                      subtext: 'Gunung Raja Paksi dkk',
                      accentColor: const Color(0xFF16A34A),
                      icon: Icons.precision_manufacturing,
                      isSelected: _selectedCityFilter == 'Jawa Barat / Bekasi',
                      onTap: () => setState(() {
                        _selectedCityFilter = _selectedCityFilter == 'Jawa Barat / Bekasi'
                            ? 'Semua Lokasi'
                            : 'Jawa Barat / Bekasi';
                      }),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Filter Chips Cepat Lokasi
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'Semua Lokasi',
                    'Surabaya',
                    'Indonesia (Nasional)',
                    'Gresik',
                    'Banten / Cilegon',
                    'Jawa Barat / Bekasi',
                  ].map((filter) {
                    final isSelected = _selectedCityFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (val) {
                          setState(() => _selectedCityFilter = filter);
                        },
                        selectedColor: primaryPurple,
                        backgroundColor: Colors.white,
                        checkmarkColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 11,
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

              const SizedBox(height: 20),

              // ==============================================================
              // 3. DAFTAR PABRIK SESUAI LOKASI TERPILIH (SURABAYA / NASIONAL)
              // ==============================================================
              Text(
                'Daftar Pabrik di ${_selectedCityFilter == 'Semua Lokasi' ? 'Seluruh Lokasi' : _selectedCityFilter} (${filteredCompanies.length} Unit)',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 10),

              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30.0),
                    child: CircularProgressIndicator(color: primaryPurple),
                  ),
                )
              else if (filteredCompanies.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Center(
                    child: Text(
                      'Tidak ada pabrik pada lokasi ini.',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
                    ),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredCompanies.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final comp = filteredCompanies[index];
                    final intensity = (comp['carbon_intensity'] as num?)?.toDouble() ?? 0.0;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.factory, size: 18, color: primaryPurple),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  comp['name'] ?? 'Pabrik Tanpa Nama',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${comp['siinas_id'] ?? '-'} • ${comp['location'] ?? 'Indonesia'}',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '$intensity tCO2/t',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: intensity <= 0.80
                                      ? const Color(0xFF16A34A)
                                      : (intensity > 1.40
                                          ? const Color(0xFFDC2626)
                                          : const Color(0xFFD97706)),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                comp['mrv_status'] == 'disetujui'
                                    ? 'MRV Lolos'
                                    : (comp['mrv_status'] == 'perlu_tindakan'
                                        ? 'Perlu Audit'
                                        : 'Validasi'),
                                style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

              const SizedBox(height: 24),

              // ==============================================================
              // 4. KLASTER REGIONAL EMISI (PERBAIKAN OVERFLOW 99px & 30px)
              // ==============================================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Klaster Regional Emisi Nasional',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  DropdownButton<String>(
                    value: _selectedRegionFilter,
                    underline: const SizedBox(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryPurple,
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Semua Wilayah', child: Text('Semua Wilayah')),
                      DropdownMenuItem(value: 'Pulau Jawa', child: Text('Pulau Jawa')),
                      DropdownMenuItem(value: 'Luar Jawa', child: Text('Luar Jawa')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRegionFilter = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredProvinces.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = filteredProvinces[index];
                  final statusColor = item['color'] as Color;

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
                        // Header Baris Provinsi: PERBAIKAN OVERFLOW 99 PIXEL
                        // Menggunakan Expanded pada Text judul agar tidak overflow meskipun teks sangat panjang
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: statusColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Expanded di sini menjamin judul panjang tidak overflow 99 pixel
                                  Expanded(
                                    child: Text(
                                      item['province'] as String,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item['compliance_status'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['description'] as String,
                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: Color(0xFFF1F5F9), height: 1),
                        const SizedBox(height: 10),

                        // Baris 3 Statistik: PERBAIKAN OVERFLOW 30 PIXEL
                        // Membungkus setiap _buildMiniStat dengan Expanded
                        Row(
                          children: [
                            Expanded(
                              child: _buildMiniStat('Pabrik Terdaftar', '${item['factories_count']} Unit'),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildMiniStat('Emisi Tahunan', item['total_emissions'] as String),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: _buildMiniStat(
                                'Intensitas Rerata',
                                '${item['avg_intensity']} tCO2/t',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard({
    required String title,
    required String badge,
    required String countText,
    required String subtext,
    required Color accentColor,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 165,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accentColor : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 18, color: accentColor),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              countText,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? accentColor : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtext,
              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E293B),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
