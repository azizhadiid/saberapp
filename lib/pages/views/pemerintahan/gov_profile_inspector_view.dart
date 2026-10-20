import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../login_page.dart';
import '../../app_manual_page.dart';
import '../../../widgets/first_time_walkthrough_dialog.dart';

/// ============================================================================
/// GOV PROFILE INSPECTOR VIEW (PROFIL PEMERINTAH DAN OTORITAS MRV)
/// ============================================================================
/// Dirancang khusus untuk peran Pemerintah (Regulator SIINas, KLHK, & Auditor MRV).
/// ============================================================================
class GovProfileInspectorView extends StatefulWidget {
  const GovProfileInspectorView({super.key});

  @override
  State<GovProfileInspectorView> createState() => _GovProfileInspectorViewState();
}

class _GovProfileInspectorViewState extends State<GovProfileInspectorView> {
  // Controller data pemerintah di tabel companies
  final _nameCtrl = TextEditingController();
  final _nipCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _agencyCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  String? _companyRecordId;
  String? _avatarUrl;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _fetchInspectorProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nipCtrl.dispose();
    _locationCtrl.dispose();
    _agencyCtrl.dispose();
    _positionCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  /// Ambil data profil pemerintah dari tabel public.companies
  Future<void> _fetchInspectorProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      _userEmail = user.email;

      final res = await Supabase.instance.client
          .from('companies')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (res != null) {
        _companyRecordId = res['id']?.toString();
        _avatarUrl = res['avatar_url'];
        _nameCtrl.text = res['name'] ?? user.userMetadata?['full_name'] ?? 'Dr. Ir. Hendra Wicaksono, M.Sc';
        _nipCtrl.text = res['siinas_id'] ?? res['nip'] ?? 'NIP. 19820415 200801 1 004';
        _locationCtrl.text = res['location'] ?? 'Jawa Timur, Indonesia';
        _agencyCtrl.text = res['agency_name'] ?? 'Direktorat Industri Logam, Kemenperin RI';
        _positionCtrl.text = res['position'] ?? 'Inspektur Emisi Industri Ahli Madya';
        _phoneCtrl.text = res['phone'] ?? '+62 811-9876-5432';
      } else {
        // Fallback default jika row baru dibuat
        _nameCtrl.text = user.userMetadata?['full_name'] ?? 'Dr. Ir. Hendra Wicaksono, M.Sc';
        _nipCtrl.text = 'NIP. 19820415 200801 1 004';
        _locationCtrl.text = 'Jawa Timur, Indonesia';
        _agencyCtrl.text = 'Direktorat Industri Logam, Kemenperin RI';
        _positionCtrl.text = 'Inspektur Emisi Industri Ahli Madya';
        _phoneCtrl.text = '+62 811-9876-5432';
      }
    } catch (e) {
      debugPrint('Error mengambil profil pemerintah: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Simpan pembaruan data pemerintah ke tabel public.companies
  Future<void> _saveInspectorProfile() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama Lengkap wajib diisi!'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw 'Sesi akun tidak ditemukan';

      final Map<String, dynamic> updateData = {
        'user_id': user.id,
        'role': 'pemerintah',
        'name': _nameCtrl.text.trim(),
        'siinas_id': _nipCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'agency_name': _agencyCtrl.text.trim(),
        'nip': _nipCtrl.text.trim(),
        'position': _positionCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        if (_avatarUrl != null) 'avatar_url': _avatarUrl,
      };

      if (_companyRecordId == null) {
        final res = await Supabase.instance.client
            .from('companies')
            .upsert(updateData, onConflict: 'user_id')
            .select()
            .single();
        _companyRecordId = res['id']?.toString();
      } else {
        await Supabase.instance.client
            .from('companies')
            .update(updateData)
            .eq('id', _companyRecordId!);
      }

      // Update juga user_metadata di auth Supabase
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': _nameCtrl.text.trim(),
            'agency_name': _agencyCtrl.text.trim(),
            'user_role': 'pemerintah',
          },
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil Pemerintah berhasil diperbarui!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan profil: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  /// Dialog pemilihan sumber foto profil (Kamera atau Galeri)
  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ubah Foto Profil Pemerintah',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Foto akan diunggah ke Supabase Storage (bucket: profile_perushaan)',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF059669)),
                ),
                title: const Text('Pilih dari Galeri Foto'),
                subtitle: const Text('Format JPG/PNG resolusi tinggi'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF334155)),
                ),
                title: const Text('Ambil Foto Kamera'),
                subtitle: const Text('Foto resmi atau wajah langsung'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ambil foto dan unggah ke Supabase Storage
  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
      );
      if (image == null) return;

      setState(() => _isUploadingImage = true);

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw 'Sesi akun tidak ditemukan. Silakan login kembali.';

      final file = File(image.path);
      final fileExt = image.name.split('.').last;
      final fileName = 'gov_${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      String? uploadedUrl;

      // 1. Coba upload ke bucket 'profile_perushaan'
      try {
        await Supabase.instance.client.storage
            .from('profile_perushaan')
            .upload(fileName, file);

        uploadedUrl = Supabase.instance.client.storage
            .from('profile_perushaan')
            .getPublicUrl(fileName);
      } catch (storageError) {
        debugPrint('Gagal upload ke bucket profile_perushaan: $storageError');
        // 2. Coba fallback ke bucket 'avatars'
        try {
          await Supabase.instance.client.storage
              .from('avatars')
              .upload(fileName, file);

          uploadedUrl = Supabase.instance.client.storage
              .from('avatars')
              .getPublicUrl(fileName);
        } catch (storageError2) {
          debugPrint('Gagal upload ke bucket avatars: $storageError2');
          throw Exception(
            'Bucket penyimpanan belum siap atau diblokir oleh RLS Supabase Storage.\n\n'
            'Detail: $storageError',
          );
        }
      }

      setState(() => _avatarUrl = uploadedUrl);

      // Update langsung kolom avatar_url di tabel companies
      if (_companyRecordId != null) {
        await Supabase.instance.client
            .from('companies')
            .update({'avatar_url': uploadedUrl})
            .eq('id', _companyRecordId!);
      } else {
        final res = await Supabase.instance.client
            .from('companies')
            .upsert({
              'user_id': user.id,
              'role': 'pemerintah',
              'name': _nameCtrl.text.trim().isNotEmpty
                  ? _nameCtrl.text.trim()
                  : 'Pejabat Pemerintah',
              'avatar_url': uploadedUrl,
            }, onConflict: 'user_id')
            .select('id')
            .single();
        _companyRecordId = res['id']?.toString();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil diperbarui!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showStorageHelpDialog(e.toString());
      }
    } finally {
      if (mounted) setState(() => _isUploadingImage = false);
    }
  }

  /// Tampilkan dialog bantuan jika Supabase Storage belum dikonfigurasi
  void _showStorageHelpDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.cloud_off_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Supabase Storage Belum Diatur',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aplikasi membutuhkan bucket storage bernama "profile_perushaan" di dashboard Supabase Anda.',
              style: TextStyle(fontSize: 12.5, height: 1.4),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                errorMessage,
                style: const TextStyle(fontSize: 10.5, fontFamily: 'monospace', color: Color(0xFF334155)),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  /// Dialog Konfirmasi Keluar Akun
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFDC2626)),
            SizedBox(width: 8),
            Text('Konfirmasi Keluar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari Portal Pemerintah?',
          style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
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
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryIndigo = Color(0xFF059669);
    const darkIndigo = Color(0xFF065F46);

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(color: primaryIndigo),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Profil Pemerintah dan Otoritas MRV',
          style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: darkIndigo,
        elevation: 0,
        // AppBar bersih tanpa action icons
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==============================================================
            // 1. KARTU IDENTITAS RESMI PEMERINTAH (HERO SECTION)
            // ==============================================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF065F46), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: primaryIndigo.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Avatar dengan tombol ganti foto
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
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _isUploadingImage
                                  ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : (_avatarUrl != null && _avatarUrl!.isNotEmpty
                                      ? Image.network(
                                          _avatarUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Container(
                                            color: const Color(0xFF059669),
                                            child: const Icon(Icons.person, color: Colors.white, size: 40),
                                          ),
                                        )
                                      : Container(
                                          color: const Color(0xFF059669),
                                          child: const Icon(
                                            Icons.shield_outlined,
                                            color: Colors.white,
                                            size: 38,
                                          ),
                                        )),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _isUploadingImage ? null : _showImagePickerSheet,
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
                      // Info Teks Pejabat
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_user_rounded, color: Color(0xFF34D399), size: 12),
                                  SizedBox(width: 4),
                                  Text(
                                    'AKUN PEMERINTAH AKTIF',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Pejabat Pemerintah',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15.5,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _nipCtrl.text.isNotEmpty ? _nipCtrl.text : 'NIP. 19820415 200801 1 004',
                              style: const TextStyle(color: Color(0xFFA7F3D0), fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _userEmail ?? 'pemerintah@kemenperin.go.id',
                              style: const TextStyle(color: Color(0xFF6EE7B7), fontSize: 10.5),
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

                  // Metadata disesuaikan dengan kolom tabel companies (role, siinas_id, location)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderMetaItem(
                        icon: Icons.admin_panel_settings_outlined,
                        label: 'Peran Akun',
                        value: 'Pemerintah',
                      ),
                      _buildHeaderMetaItem(
                        icon: Icons.numbers_rounded,
                        label: 'ID SIINas / NIP',
                        value: _nipCtrl.text.isNotEmpty ? _nipCtrl.text : 'SIINAS-GOV',
                      ),
                      _buildHeaderMetaItem(
                        icon: Icons.location_on_outlined,
                        label: 'Lokasi Wilayah',
                        value: _locationCtrl.text.isNotEmpty ? _locationCtrl.text : 'Indonesia',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ==============================================================
            // 2. FORMULIR PENGATURAN DATA PEMERINTAH
            // ==============================================================
            const Text(
              'Informasi Pejabat & Unit Kerja Pemerintah',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 12),

            _buildInputField(
              controller: _nameCtrl,
              label: 'Nama Lengkap & Gelar Pejabat',
              hint: 'Contoh: Dr. Ir. Hendra Wicaksono, M.Sc',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: 12),

            _buildInputField(
              controller: _nipCtrl,
              label: 'NIP / Nomor Registrasi SIINas',
              hint: 'Contoh: NIP. 19820415 200801 1 004',
              icon: Icons.numbers_rounded,
            ),
            const SizedBox(height: 12),

            _buildInputField(
              controller: _agencyCtrl,
              label: 'Instansi / Lembaga Pemerintah',
              hint: 'Contoh: Dinas Perindustrian dan Perdagangan',
              icon: Icons.account_balance_outlined,
            ),
            const SizedBox(height: 12),

            _buildInputField(
              controller: _positionCtrl,
              label: 'Jabatan Fungsional',
              hint: 'Contoh: Inspektur Emisi Industri Ahli Madya',
              icon: Icons.work_outline_rounded,
            ),
            const SizedBox(height: 12),

            _buildInputField(
              controller: _locationCtrl,
              label: 'Wilayah Tugas / Kedudukan Kantor',
              hint: 'Contoh: Surabaya, Jawa Timur, Indonesia',
              icon: Icons.location_on_outlined,
            ),
            const SizedBox(height: 12),

            _buildInputField(
              controller: _phoneCtrl,
              label: 'Nomor Kontak Dinas / Darurat',
              hint: 'Contoh: +62 811-9876-5432',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 16),

            // Tombol Simpan Perubahan Profil
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _saveInspectorProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryIndigo,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save_rounded, size: 20),
                label: Text(
                  _isSaving ? 'Menyimpan Pembaruan...' : 'Simpan Data Pemerintah ke Database',
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ==============================================================
            // 3. WEWENANG & MANDAT PEMERINTAH (AUDITOR MRV)
            // ==============================================================
            const Text(
              'Wewenang & Hak Akses Pemerintah',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 12),

            _buildPrivilegeCard(
              icon: Icons.fact_check_rounded,
              color: const Color(0xFF059669),
              title: 'Verifikasi & Validasi Laporan MRV',
              description: 'Otoritas menyetujui, meminta revisi, atau menerbitkan status audit pada entitas pabrik baja nasional.',
            ),
            const SizedBox(height: 8),

            _buildPrivilegeCard(
              icon: Icons.map_rounded,
              color: const Color(0xFF0284C7),
              title: 'Pemantauan Spasial & CEMS Cerobong',
              description: 'Menerima telemetri sensor emisi kontinu (CEMS) dan hotspot sebaran pabrik baja di seluruh Indonesia.',
            ),
            const SizedBox(height: 8),

            _buildPrivilegeCard(
              icon: Icons.gavel_rounded,
              color: const Color(0xFF0D9488),
              title: 'Rekomendasi Pajak Karbon & CBAM UE',
              description: 'Menilai kesesuaian ambang batas 0.80 tCO2/t untuk kelayakan insentif fiskal dan kepatuhan ekspor.',
            ),

            const SizedBox(height: 18),

            // KARTU PUSAT BANTUAN, PANDUAN & TUTORIAL
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  ListTile(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AppManualPage(),
                      ),
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFF059669),
                        size: 18,
                      ),
                    ),
                    title: const Text(
                      'Buku Panduan & Kebijakan Hak Akses',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    subtitle: const Text(
                      'Manual alur kerja & batasan akses regulator non-publik',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  ListTile(
                    onTap: () => FirstTimeWalkthroughDialog.show(
                      context,
                      'pemerintah',
                      force: true,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.explore_outlined,
                        color: Color(0xFF0D9488),
                        size: 18,
                      ),
                    ),
                    title: const Text(
                      'Ulangi Tutorial Alur Aplikasi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    subtitle: const Text(
                      'Tampilkan kembali panduan langkah inspeksi & verifikasi MRV',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    trailing: const Icon(
                      Icons.replay_rounded,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ==============================================================
            // 4. TOMBOL KELUAR DARI PORTAL PEMERINTAH
            // ==============================================================
            OutlinedButton.icon(
              onPressed: _confirmLogout,
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFDC2626),
                side: const BorderSide(color: Color(0xFFFCA5A5)),
                backgroundColor: const Color(0xFFFEF2F2),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text(
                'Keluar dari Portal Pemerintah',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderMetaItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF6EE7B7), size: 18),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Color(0xFFA7F3D0), fontSize: 9.5),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            prefixIcon: Icon(icon, color: const Color(0xFF059669), size: 18),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
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

  Widget _buildPrivilegeCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
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
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
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
                const SizedBox(height: 3),
                Text(
                  description,
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
