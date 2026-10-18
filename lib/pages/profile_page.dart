import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _companyNameCtrl = TextEditingController();
  final _siinasIdCtrl = TextEditingController();

  final _emissionCtrl = TextEditingController();
  final _intensityCtrl = TextEditingController();
  final _trendCtrl = TextEditingController();
  final _rankCtrl = TextEditingController();

  bool _isSaving = false;
  bool _isLoading = true;
  String? _companyRecordId;
  String? _avatarUrl;
  String _mrvStatus = 'menunggu';

  bool _isSiinasIntegrated = true;
  bool _isCbamNotifActive = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    // Tambahkan listener agar saat teks berubah, kalkulasi status otomatis terupdate di layar
    _emissionCtrl.addListener(() => setState(() {}));
    _intensityCtrl.addListener(() => setState(() {}));
    _trendCtrl.addListener(() => setState(() {}));
  }

  Future<void> _fetchProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final res = await Supabase.instance.client
          .from('companies')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (res != null) {
        _companyRecordId = res['id'];
        _avatarUrl = res['avatar_url'];
        _companyNameCtrl.text = res['name'] ?? '';
        _siinasIdCtrl.text = res['siinas_id'] ?? '';
        _emissionCtrl.text = res['current_emission']?.toString() ?? '12450';
        _intensityCtrl.text = res['carbon_intensity']?.toString() ?? '0.18';
        _trendCtrl.text = res['energy_efficiency_trend']?.toString() ?? '12';
        _rankCtrl.text = res['national_rank']?.toString() ?? '2';

        // Baca status MRV / verifikasi secara dinamis dari kolom companies
        final rawMrvStatus = res['mrv_status']?.toString().trim();
        final rawMrvVerified = res['mrv_verified'];

        if (rawMrvStatus != null && rawMrvStatus.isNotEmpty) {
          _mrvStatus = rawMrvStatus.toLowerCase();
        } else if (rawMrvVerified != null) {
          if (rawMrvVerified == true ||
              rawMrvVerified == 'true' ||
              rawMrvVerified == 1 ||
              rawMrvVerified == '1') {
            _mrvStatus = 'disetujui';
          } else {
            _mrvStatus = 'menunggu';
          }
        } else {
          // Fallback dinamis berdasarkan intensitas karbon jika belum diatur
          final intensity = num.tryParse(_intensityCtrl.text) ?? 0.18;
          if (intensity <= 0.80) {
            _mrvStatus = 'disetujui';
          } else if (intensity > 1.40) {
            _mrvStatus = 'perlu_tindakan';
          } else {
            _mrvStatus = 'menunggu';
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (image == null) return;

      setState(() => _isSaving = true);
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw 'User tidak ditemukan';

      final file = File(image.path);
      final fileExt = image.name.split('.').last;
      final fileName =
          '${user.id}-${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // 1. Upload ke Storage
      await Supabase.instance.client.storage
          .from('profile_perushaan')
          .upload(fileName, file);

      // 2. Dapatkan public URL
      final publicUrl = Supabase.instance.client.storage
          .from('profile_perushaan')
          .getPublicUrl(fileName);

      // 3. Update database jika row sudah ada
      if (_companyRecordId != null) {
        await Supabase.instance.client
            .from('companies')
            .update({'avatar_url': publicUrl})
            .eq('id', _companyRecordId!);
      }

      setState(() {
        _avatarUrl = publicUrl;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Foto profil berhasil diperbarui!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal upload foto: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Dialog Konfirmasi Keluar Akun (Modern & Selaras Portal Pemerintah)
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
        actionsPadding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Konfirmasi Keluar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari Portal Perusahaan Baja SABER KARBON? Sesi aktif Anda akan diakhiri.',
          style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              await Supabase.instance.client.auth.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.logout_rounded, size: 16),
            label: const Text(
              'Keluar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_companyNameCtrl.text.isEmpty || _siinasIdCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama & ID SIINas wajib diisi!')),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw 'User tidak ditemukan';

      final data = {
        'user_id': user.id,
        'name': _companyNameCtrl.text,
        'siinas_id': _siinasIdCtrl.text,
        'current_emission': num.tryParse(_emissionCtrl.text) ?? 0,
        'carbon_intensity': num.tryParse(_intensityCtrl.text) ?? 0,
        'energy_efficiency_trend': num.tryParse(_trendCtrl.text) ?? 0,
        'national_rank': int.tryParse(_rankCtrl.text) ?? 0,
        if (_avatarUrl != null) 'avatar_url': _avatarUrl,
        'mrv_status': _mrvStatus,
      };

      if (_companyRecordId == null) {
        final res = await Supabase.instance.client
            .from('companies')
            .insert(data)
            .select()
            .single();
        _companyRecordId = res['id'];
      } else {
        await Supabase.instance.client
            .from('companies')
            .update(data)
            .eq('id', _companyRecordId!);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil perusahaan berhasil disimpan!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _emissionCtrl.removeListener(() {});
    _intensityCtrl.removeListener(() {});
    _trendCtrl.removeListener(() {});

    _companyNameCtrl.dispose();
    _siinasIdCtrl.dispose();
    _emissionCtrl.dispose();
    _intensityCtrl.dispose();
    _trendCtrl.dispose();
    _rankCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF10B981)),
        ),
      );
    }

    // --- LOGIKA KALKULASI DINAMIS (REAL CALCULATION) ---
    // Parsing nilai teks
    final currentEmission = double.tryParse(_emissionCtrl.text) ?? 0.0;
    final carbonIntensity = double.tryParse(_intensityCtrl.text) ?? 0.0;
    final trend = double.tryParse(_trendCtrl.text) ?? 0.0;

    // 1. Kalkulasi Karbon Dihemat (Formula Avoided Emissions Benchmark)
    // Asumsi: Trend (%) menunjukkan peningkatan efisiensi dibanding baseline bulan lalu.
    // Baseline Emisi (seandainya tidak ada perbaikan) = Current Emission / (1 - Trend/100)
    // Karbon Dihemat = Baseline Emisi - Current Emission
    double karbonDihemat = 0;
    if (trend > 0 && trend < 100) {
      double baselineEmisi = currentEmission / (1 - (trend / 100));
      karbonDihemat = baselineEmisi - currentEmission;
    }

    // 2. Kalkulasi Status IDRI (Berdasarkan IEA Iron & Steel Intensity Benchmarks)
    // Level 1: > 1.8 tCO2/t (Konvensional, BF-BOF tanpa mitigasi)
    // Level 2: 1.0 - 1.8 tCO2/t (Inisiasi Efisiensi)
    // Level 3: 0.4 - 1.0 tCO2/t (Transisi, EAF berbasis scrap)
    // Level 4: 0.1 - 0.4 tCO2/t (Lanjut, DRI-EAF berbasis gas bumi)
    // Level 5: < 0.1 tCO2/t (Net Zero, DRI berbasis Hidrogen Hijau)
    String idriLevel = 'Level 1';
    String idriStatus = 'Konvensional';
    if (carbonIntensity <= 0.1) {
      idriLevel = 'Level 5';
      idriStatus = 'Net Zero';
    } else if (carbonIntensity <= 0.4) {
      idriLevel = 'Level 4';
      idriStatus = 'Lanjut';
    } else if (carbonIntensity <= 1.0) {
      idriLevel = 'Level 3';
      idriStatus = 'Transisi';
    } else if (carbonIntensity <= 1.8) {
      idriLevel = 'Level 2';
      idriStatus = 'Inisiasi';
    }

    final numberFormat = NumberFormat('#,##0', 'en_US');
    final userEmail = Supabase.instance.client.auth.currentUser?.email;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.domain_verification_rounded,
                color: Color(0xFF059669),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profil Perusahaan Baja',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontWeight: FontWeight.bold,
                    fontSize: 15.5,
                  ),
                ),
                Text(
                  'Data Entitas Pabrik & Integrasi SIINas',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==============================================================
            // 1. KARTU IDENTITAS RESMI PERUSAHAAN (HERO SECTION)
            // ==============================================================
            Container(
              width: double.infinity,
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
                    color: const Color(0xFF064E3B).withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar dengan tombol edit foto
                      Stack(
                        children: [
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.15),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                                  ? Image.network(
                                      _avatarUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        color: const Color(0xFF065F46),
                                        child: const Icon(
                                          Icons.factory_rounded,
                                          color: Colors.white,
                                          size: 38,
                                        ),
                                      ),
                                    )
                                  : Container(
                                      color: const Color(0xFF065F46),
                                      child: const Icon(
                                        Icons.factory_rounded,
                                        color: Colors.white,
                                        size: 38,
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _isSaving ? null : _pickAndUploadImage,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Info Perusahaan
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildMrvStatusBadgeHero(),
                            const SizedBox(height: 6),
                            Text(
                              _companyNameCtrl.text.isNotEmpty
                                  ? _companyNameCtrl.text
                                  : 'Profil Perusahaan Anda',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _siinasIdCtrl.text.isNotEmpty
                                  ? 'SIINas: ${_siinasIdCtrl.text}'
                                  : 'SIINas: SIINAS-8829-JKT',
                              style: const TextStyle(
                                color: Color(0xFFA7F3D0),
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              userEmail ?? 'perusahaan@baja.co.id',
                              style: const TextStyle(
                                color: Color(0xFFD1FAE5),
                                fontSize: 10.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 12),
                  // Metadata 3 Kolom
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderMetaItem(
                        icon: Icons.precision_manufacturing_outlined,
                        label: 'Sektor Usaha',
                        value: 'Industri Baja',
                      ),
                      _buildHeaderMetaItem(
                        icon: Icons.verified_outlined,
                        label: 'Status MRV',
                        value: _deriveMrvShortLabel(),
                      ),
                      _buildHeaderMetaItem(
                        icon: Icons.emoji_events_outlined,
                        label: 'Peringkat',
                        value: '#${_rankCtrl.text.isNotEmpty ? _rankCtrl.text : '2'} Nasional',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==============================================================
            // 2. METRIK KINERJA & DEKARBONISASI
            // ==============================================================
            Row(
              children: [
                _buildMetricCard(
                  title: 'STATUS IDRI (IEA)',
                  value: idriLevel,
                  subValue: '$idriStatus • ${carbonIntensity.toStringAsFixed(2)} tCO2/t',
                  icon: Icons.speed_rounded,
                  iconColor: const Color(0xFF059669),
                  iconBg: const Color(0xFFECFDF5),
                ),
                const SizedBox(width: 12),
                _buildMetricCard(
                  title: 'KARBON DIHEMAT',
                  value: '${numberFormat.format(karbonDihemat.round())} Ton',
                  subValue: '+${trend.toStringAsFixed(0)}% Efisiensi Energi',
                  icon: Icons.eco_rounded,
                  iconColor: const Color(0xFF0284C7),
                  iconBg: const Color(0xFFF0F9FF),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==============================================================
            // 3. FORMULIR INFORMASI DASAR PERUSAHAAN
            // ==============================================================
            _buildSectionCard(
              title: 'INFORMASI DASAR PERUSAHAAN',
              subtitle: 'Identitas legalitas pabrik baja dan nomor registrasi SIINas',
              icon: Icons.business_rounded,
              children: [
                _buildNiceTextField(
                  label: 'Nama Perusahaan',
                  hint: 'Contoh: PT Krakatau Steel (Persero) Tbk',
                  controller: _companyNameCtrl,
                  icon: Icons.domain_rounded,
                ),
                const SizedBox(height: 14),
                _buildNiceTextField(
                  label: 'Nomor Registrasi SIINas',
                  hint: 'Contoh: SIINAS-8829-JKT',
                  controller: _siinasIdCtrl,
                  icon: Icons.confirmation_number_outlined,
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ==============================================================
            // 4. DATA EMISI & EFISIENSI PABRIK
            // ==============================================================
            _buildSectionCard(
              title: 'DATA EMISI & EFISIENSI OPERASIONAL',
              subtitle: 'Parameter acuan kalkulator IDRI dan audit verifikasi MRV',
              icon: Icons.data_exploration_rounded,
              children: [
                _buildNiceTextField(
                  label: 'Emisi Pabrik Bulan Ini (tCO2)',
                  hint: 'Contoh: 12450',
                  controller: _emissionCtrl,
                  icon: Icons.cloud_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 14),
                _buildNiceTextField(
                  label: 'Intensitas Karbon Rata-rata (tCO2/t)',
                  hint: 'Contoh: 0.18',
                  controller: _intensityCtrl,
                  icon: Icons.speed_rounded,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: _buildNiceTextField(
                        label: 'Trend Efisiensi (%)',
                        hint: 'Contoh: 12',
                        controller: _trendCtrl,
                        icon: Icons.trending_up_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNiceTextField(
                        label: 'Peringkat Nasional',
                        hint: 'Contoh: 2',
                        controller: _rankCtrl,
                        icon: Icons.emoji_events_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ==============================================================
            // 5. TOMBOL SIMPAN PERUBAHAN
            // ==============================================================
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: _isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.save_rounded, size: 18),
                label: Text(
                  _isSaving ? 'Menyimpan Perubahan...' : 'Simpan Pembaruan Data Perusahaan',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ==============================================================
            // 6. PENGATURAN & INTEGRASI SISTEM
            // ==============================================================
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.tune_rounded, size: 16, color: Color(0xFF334155)),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'PENGATURAN & INTEGRASI SISTEM',
                          style: TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildListTile(
                    title: 'Integrasi Data SIINas Kemenperin',
                    subtitle: 'Sinkronisasi pelaporan emisi otomatis ke portal Kemenperin',
                    trailing: Switch(
                      value: _isSiinasIntegrated,
                      onChanged: (val) => setState(() => _isSiinasIntegrated = val),
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFF10B981),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  _buildListTile(
                    title: 'Notifikasi Peringatan Pajak CBAM',
                    subtitle: 'Peringatan dini ambang batas intensitas karbon ekspor',
                    trailing: Switch(
                      value: _isCbamNotifActive,
                      onChanged: (val) => setState(() => _isCbamNotifActive = val),
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==============================================================
            // 7. PUSAT BANTUAN & KELUAR AKUN
            // ==============================================================
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.help_outline_rounded, color: Color(0xFF64748B), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Pusat Bantuan & Panduan MRV SABER KARBON',
                    style: TextStyle(
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            InkWell(
              onTap: _confirmLogout,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Keluar dari Akun Perusahaan',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // Widget Metadata 3 Kolom pada Hero Section
  Widget _buildHeaderMetaItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: const Color(0xFFA7F3D0)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFFD1FAE5)),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _deriveMrvShortLabel() {
    final status = _mrvStatus.toLowerCase();
    if (status == 'disetujui' ||
        status == 'verified' ||
        status == 'terverifikasi' ||
        status == 'true') {
      return 'Disetujui (Valid)';
    } else if (status == 'perlu_tindakan' || status == 'ditolak') {
      return 'Perlu Tindakan';
    }
    return 'Menunggu';
  }

  // Badge Status MRV di dalam Hero Card
  Widget _buildMrvStatusBadgeHero() {
    final status = _mrvStatus.toLowerCase();
    final bool isVerified = status == 'disetujui' ||
        status == 'verified' ||
        status == 'terverifikasi' ||
        status == 'mrv_verified' ||
        status == 'true';
    final bool isActionNeeded = status == 'perlu_tindakan' ||
        status == 'ditolak' ||
        status == 'action_needed';

    Color bg;
    Color iconColor;
    IconData icon;
    String label;

    if (isVerified) {
      bg = Colors.white.withValues(alpha: 0.18);
      iconColor = const Color(0xFF34D399);
      icon = Icons.verified_user_rounded;
      label = 'VERIFIED ENTERPRISE';
    } else if (isActionNeeded) {
      bg = const Color(0xFFDC2626).withValues(alpha: 0.25);
      iconColor = const Color(0xFFFCA5A5);
      icon = Icons.warning_amber_rounded;
      label = 'PERLU TINDAKAN MRV';
    } else {
      bg = const Color(0xFFD97706).withValues(alpha: 0.25);
      iconColor = const Color(0xFFFDE68A);
      icon = Icons.hourglass_top_rounded;
      label = 'MENUNGGU VERIFIKASI MRV';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  // Widget Kartu Metrik Flat
  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subValue,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
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
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 15, color: iconColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.4,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subValue,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: iconColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // Widget Pembantu untuk Container Formulir Flat Modern
  Widget _buildSectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: const Color(0xFF059669)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  // Widget Pembantu untuk TextField Modern Flat
  Widget _buildNiceTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
            prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 19),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF059669), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
