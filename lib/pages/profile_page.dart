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

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await Supabase.instance.client.auth.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: const Text(
          'Profile Perusahaan',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header: Foto Profil (Klik untuk Edit)
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _isSaving ? null : _pickAndUploadImage,
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            image: _avatarUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(_avatarUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _avatarUrl == null
                              ? const Icon(
                                  Icons.business,
                                  size: 40,
                                  color: Color(0xFF9CA3AF),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _companyNameCtrl.text.isEmpty
                        ? 'Profil Perusahaan Anda'
                        : _companyNameCtrl.text,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          color: Color(0xFF10B981),
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Verified Enterprise',
                          style: TextStyle(
                            color: Color(0xFF065F46),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form Edit Profil (Data Dasar)
            _buildSectionCard(
              title: 'INFORMASI DASAR',
              icon: Icons.business,
              children: [
                _buildNiceTextField(
                  label: 'Nama Perusahaan',
                  controller: _companyNameCtrl,
                  icon: Icons.domain,
                ),
                const SizedBox(height: 16),
                _buildNiceTextField(
                  label: 'ID SIINas',
                  controller: _siinasIdCtrl,
                  icon: Icons.numbers,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Form Edit Profil (Data Emisi)
            _buildSectionCard(
              title: 'DATA EMISI & EFISIENSI',
              icon: Icons.data_exploration,
              children: [
                _buildNiceTextField(
                  label: 'Emisi Pabrik Bulan Ini (tCO2)',
                  controller: _emissionCtrl,
                  icon: Icons.cloud_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildNiceTextField(
                  label: 'Intensitas Karbon (tCO2/t)',
                  controller: _intensityCtrl,
                  icon: Icons.speed,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildNiceTextField(
                        label: 'Trend Efisiensi (%)',
                        controller: _trendCtrl,
                        icon: Icons.trending_up,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildNiceTextField(
                        label: 'Peringkat Nasional',
                        controller: _rankCtrl,
                        icon: Icons.emoji_events_outlined,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Simpan Perubahan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 32),

            // Stats Card (Status IDRI Dinamis)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'STATUS IDRI',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          idriLevel,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '($idriStatus)',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 60,
                    color: const Color(0xFFF3F4F6),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'KARBON DIHEMAT',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${numberFormat.format(karbonDihemat.round())} Ton',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF006D44),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings List Card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20, top: 20, bottom: 8),
                    child: Text(
                      'PENGATURAN & INTEGRASI',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Divider(color: Color(0xFFF3F4F6)),
                  _buildListTile(
                    title: 'Integrasi Data SIINas\nKemenperin',
                    trailing: Switch(
                      value: _isSiinasIntegrated,
                      onChanged: (val) =>
                          setState(() => _isSiinasIntegrated = val),
                      activeColor: Colors.white,
                      activeTrackColor: const Color(0xFF10B981),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  _buildListTile(
                    title: 'Notifikasi Peringatan Pajak CBAM',
                    trailing: Switch(
                      value: _isCbamNotifActive,
                      onChanged: (val) =>
                          setState(() => _isCbamNotifActive = val),
                      activeColor: Colors.white,
                      activeTrackColor: const Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Help Button
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.help_outline, color: Color(0xFF6B7280), size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Pusat Bantuan SABER KARBON',
                    style: TextStyle(
                      color: Color(0xFF4B5563),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Logout Button
            InkWell(
              onTap: _logout,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Color(0xFFDC2626), size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Keluar dari Akun',
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // Widget Pembantu untuk Container Formulir
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // Widget Pembantu untuk TextField
  Widget _buildNiceTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
        prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF10B981), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildListTile({required String title, required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1F2937),
                height: 1.4,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
