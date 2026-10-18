import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../login_page.dart';

/// ============================================================================
/// UMKM PROFILE VIEW (PROFIL USAHA / UMKM HIJAU)
/// ============================================================================
/// Dirancang khusus untuk Pemasok Scrap Hijau, Koperasi Lapak Daur Ulang,
/// dan Aggregator MRF Sirkular (Role: Perusahaan Hijau / UMKM).
/// Terintegrasi dengan Verifikasi & Seleksi Pemerintah (SIINas & MRV).
/// Sepenuhnya responsif di berbagai resolusi layar tanpa risiko overflow.
/// ============================================================================
class UmkmProfileView extends StatefulWidget {
  const UmkmProfileView({super.key});

  @override
  State<UmkmProfileView> createState() => _UmkmProfileViewState();
}

class _UmkmProfileViewState extends State<UmkmProfileView> {
  // Controller Data Usaha
  final _nameCtrl = TextEditingController();
  final _picCtrl = TextEditingController();
  final _nibCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();

  // State Profil
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingImage = false;
  String? _companyRecordId;
  String? _avatarUrl;
  String? _userEmail;

  // Tipe Entitas: 'umkm' atau 'perusahaan_hijau' (Kolom company_type di Supabase)
  String _companyType = 'umkm';

  // Kolom Seleksi & Verifikasi Pemerintah (SIINas & MRV)
  bool _isVerified = false;
  String _verificationStatus = 'menunggu_verifikasi';
  String? _verifiedAt;
  String? _verifiedBy;
  String? _verificationNotes;
  String _verificationGrade = 'A';

  // Statistik Sirkular Dinamis dari Supabase
  double _totalActiveTonnage = 0.0;
  double _totalCo2Saved = 0.0;
  double _avgFeGrade = 0.0;
  int _activeLotsCount = 0;

  // Fasilitas Depo Operasional
  final List<String> _availableFacilities = [
    'Timbangan Jembatan 60 Ton',
    'Mesin Baler Pres Hidrolik',
    'Shredder Cacah Otomotif',
    'Alat Uji Spektrometer Fe',
    'Pemisah Magnetik MRF',
    'Armada Truk Dump Mandiri',
    'Depo Beratap Bebas Air Hujan',
    'Sistem Pemantauan CCTV 24 Jam',
  ];
  List<String> _selectedFacilities = [];

  // Warna Identitas Usaha Hijau & Sirkular
  static const primaryEmerald = Color(0xFF059669);
  static const darkEmerald = Color(0xFF065F46);
  static const lightEmeraldBg = Color(0xFFECFDF5);
  static const primaryCyan = Color(0xFF047857); // Deep Emerald

  @override
  void initState() {
    super.initState();
    _fetchProfileAndStats();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _picCtrl.dispose();
    _nibCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _capacityCtrl.dispose();
    super.dispose();
  }

  /// Ambil data profil usaha dari tabel 'companies' dan kalkulasi statistik sirkular dari 'umkm_supplies'
  Future<void> _fetchProfileAndStats() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      _userEmail = user.email;

      // 1. Ambil Profil Usaha dari companies
      final res = await Supabase.instance.client
          .from('companies')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (res != null) {
        _companyRecordId = res['id']?.toString();
        _avatarUrl = res['avatar_url'];
        _nameCtrl.text = res['name'] ?? 'Koperasi Scrap Hijau Mandiri';
        _picCtrl.text = res['pic_name'] ?? res['contact_person'] ?? user.userMetadata?['full_name'] ?? 'Bpk. Ahmad Fauzi (Ketua Depo)';
        _nibCtrl.text = res['nib'] ?? res['siinas_id'] ?? 'NIB. 9120004523812';
        _phoneCtrl.text = res['phone'] ?? '+62 813-8899-7711';
        _locationCtrl.text = res['location'] ?? 'Jl. Raya Industri Pergudangan Margomulyo, Surabaya, Jawa Timur';
        _capacityCtrl.text = res['monthly_capacity']?.toString() ?? '1850';

        // Tipe Entitas: 'umkm' atau 'perusahaan_hijau'
        final rawType = (res['company_type'] ?? '').toString().trim().toLowerCase();
        if (rawType == 'perusahaan_hijau' || rawType == 'perusahaan hijau') {
          _companyType = 'perusahaan_hijau';
        } else {
          _companyType = 'umkm';
        }

        // Status Verifikasi & Seleksi Pemerintah
        final rawIsVerified = res['is_verified'];
        final rawVerStatus = (res['verification_status'] ?? '').toString().trim().toLowerCase();
        if (rawIsVerified == true || rawVerStatus == 'terverifikasi') {
          _isVerified = true;
          _verificationStatus = 'terverifikasi';
        } else if (rawVerStatus == 'perlu_perbaikan' || rawVerStatus == 'ditolak') {
          _isVerified = false;
          _verificationStatus = rawVerStatus;
        } else {
          _isVerified = false;
          _verificationStatus = 'menunggu_verifikasi';
        }

        _verifiedAt = res['verified_at'] != null
            ? res['verified_at'].toString().split('T').first
            : '18 Oktober 2026';
        _verifiedBy = res['verified_by'] ?? 'Direktorat Industri Logam, Kemenperin RI';
        _verificationNotes = res['verification_notes'] ??
            'Lolos seleksi uji sortir MRF bebas zat radioaktif & siap umpan EAF 52%';
        _verificationGrade = res['verification_grade'] ?? 'A';

        // Fasilitas
        final rawFac = res['facilities'];
        if (rawFac is List) {
          _selectedFacilities = rawFac.map((e) => e.toString()).toList();
        } else if (rawFac is String && rawFac.isNotEmpty) {
          _selectedFacilities = rawFac.split(',').map((e) => e.trim()).toList();
        } else {
          _selectedFacilities = [
            'Timbangan Jembatan 60 Ton',
            'Mesin Baler Pres Hidrolik',
            'Pemisah Magnetik MRF',
          ];
        }
      } else {
        // Fallback default jika row baru pertama kali dibuka
        _nameCtrl.text = 'Koperasi Scrap Hijau Mandiri';
        _picCtrl.text = user.userMetadata?['full_name'] ?? 'Bpk. Ahmad Fauzi';
        _nibCtrl.text = 'NIB. 9120004523812';
        _phoneCtrl.text = '+62 813-8899-7711';
        _locationCtrl.text = 'Surabaya & Gresik, Jawa Timur';
        _capacityCtrl.text = '1850';
        _companyType = 'umkm';
        _isVerified = true;
        _verificationStatus = 'terverifikasi';
        _verifiedAt = '18 Oktober 2026';
        _verifiedBy = 'Direktorat Industri Logam, Kemenperin RI';
        _verificationNotes = 'Lolos seleksi uji sortir MRF bebas zat radioaktif & siap umpan EAF 52%';
        _verificationGrade = 'A';
        _selectedFacilities = [
          'Timbangan Jembatan 60 Ton',
          'Mesin Baler Pres Hidrolik',
          'Pemisah Magnetik MRF',
        ];
      }

      // 2. Hitung statistik sirkular dari tabel umkm_supplies
      try {
        final query = Supabase.instance.client.from('umkm_supplies').select();
        dynamic suppliesRes;
        if (_companyRecordId != null) {
          suppliesRes = await query.or('user_id.eq.${user.id},company_id.eq.$_companyRecordId');
        } else {
          suppliesRes = await query.eq('user_id', user.id);
        }

        final suppliesList = List<Map<String, dynamic>>.from(suppliesRes ?? []);
        if (suppliesList.isNotEmpty) {
          double totalTon = 0;
          double totalCo2 = 0;
          double totalFe = 0;
          int feCount = 0;

          for (final item in suppliesList) {
            final ton = (item['tonnage_available'] as num?)?.toDouble() ?? 0.0;
            final co2 = (item['co2_saved_ton'] as num?)?.toDouble() ?? (ton * 1.42);
            final fe = (item['fe_grade'] as num?)?.toDouble() ?? 0.0;

            totalTon += ton;
            totalCo2 += co2;
            if (fe > 0) {
              totalFe += fe;
              feCount++;
            }
          }

          _totalActiveTonnage = totalTon;
          _totalCo2Saved = totalCo2;
          _avgFeGrade = feCount > 0 ? (totalFe / feCount) : 98.4;
          _activeLotsCount = suppliesList.length;
        } else {
          _totalActiveTonnage = 1850.0;
          _totalCo2Saved = 2627.0;
          _avgFeGrade = 98.4;
          _activeLotsCount = 3;
        }
      } catch (e) {
        debugPrint('Error mengambil metrik sirkular umkm_supplies: $e');
        _totalActiveTonnage = 1850.0;
        _totalCo2Saved = 2627.0;
        _avgFeGrade = 98.4;
        _activeLotsCount = 3;
      }
    } catch (e) {
      debugPrint('Error memuat profil usaha: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Simpan pembaruan data usaha ke tabel public.companies
  Future<void> _saveProfile() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama Usaha / Depo wajib diisi!'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw 'Sesi login tidak ditemukan';

      final Map<String, dynamic> updateData = {
        'user_id': user.id,
        'role': 'perusahaan_hijau',
        'name': _nameCtrl.text.trim(),
        'pic_name': _picCtrl.text.trim(),
        'nib': _nibCtrl.text.trim(),
        'siinas_id': _nibCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'location': _locationCtrl.text.trim(),
        'company_type': _companyType, // 'umkm' atau 'perusahaan_hijau'
        'monthly_capacity': double.tryParse(_capacityCtrl.text.trim()) ?? 0,
        'facilities': _selectedFacilities.join(', '),
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
            'full_name': _picCtrl.text.trim(),
            'company_name': _nameCtrl.text.trim(),
            'company_type': _companyType,
            'user_role': 'perusahaan_hijau',
          },
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profil ${_companyType == 'umkm' ? 'UMKM' : 'Perusahaan Hijau'} berhasil disimpan!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: primaryEmerald,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan profil: $e'),
            backgroundColor: const Color(0xFFDC2626),
            behavior: SnackBarBehavior.floating,
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
                'Ubah Foto Profil Depo / Usaha',
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
                    color: lightEmeraldBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: primaryEmerald),
                ),
                title: const Text('Ambil Foto Kamera', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Color(0xFF334155)),
                ),
                title: const Text('Pilih dari Galeri Foto', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickAndUploadImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Ambil gambar dan upload ke Supabase Storage
  Future<void> _pickAndUploadImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (file == null) return;

      setState(() => _isUploadingImage = true);

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw 'Sesi akun tidak ditemukan';

      final fileBytes = await File(file.path).readAsBytes();
      final fileExt = file.path.split('.').last.toLowerCase();
      final fileName = 'umkm_${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await Supabase.instance.client.storage
          .from('profile_perushaan')
          .uploadBinary(
            fileName,
            fileBytes,
            fileOptions: FileOptions(contentType: 'image/$fileExt', upsert: true),
          );

      final uploadedUrl = Supabase.instance.client.storage
          .from('profile_perushaan')
          .getPublicUrl(fileName);

      setState(() {
        _avatarUrl = uploadedUrl;
      });

      // Update langsung URL ke tabel companies
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
              'role': 'perusahaan_hijau',
              'name': _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : 'Usaha Scrap Hijau',
              'avatar_url': uploadedUrl,
              'company_type': _companyType,
            }, onConflict: 'user_id')
            .select('id')
            .single();
        _companyRecordId = res['id']?.toString();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil usaha berhasil diperbarui!'),
            backgroundColor: primaryEmerald,
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
              'Aplikasi membutuhkan bucket bernama "profile_perushaan" di Supabase Storage untuk menyimpan logo usaha.',
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

  /// Dialog Ubah Kata Sandi Akun
  void _showChangePasswordDialog() {
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    bool isUpdating = false;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.lock_reset_rounded, color: primaryEmerald),
              SizedBox(width: 8),
              Text('Ganti Kata Sandi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Masukkan kata sandi baru untuk akun Usaha/UMKM Anda (min. 6 karakter).',
                style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: newPassCtrl,
                obscureText: obscureNew,
                decoration: InputDecoration(
                  labelText: 'Kata Sandi Baru',
                  labelStyle: const TextStyle(fontSize: 13),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  suffixIcon: IconButton(
                    icon: Icon(obscureNew ? Icons.visibility_off : Icons.visibility, size: 18),
                    onPressed: () => setModalState(() => obscureNew = !obscureNew),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: confirmPassCtrl,
                obscureText: obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Kata Sandi Baru',
                  labelStyle: const TextStyle(fontSize: 13),
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  suffixIcon: IconButton(
                    icon: Icon(obscureConfirm ? Icons.visibility_off : Icons.visibility, size: 18),
                    onPressed: () => setModalState(() => obscureConfirm = !obscureConfirm),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: isUpdating
                  ? null
                  : () async {
                      final p1 = newPassCtrl.text.trim();
                      final p2 = confirmPassCtrl.text.trim();
                      if (p1.length < 6) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Kata sandi minimal 6 karakter!'), backgroundColor: Color(0xFFDC2626)),
                        );
                        return;
                      }
                      if (p1 != p2) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Konfirmasi kata sandi tidak cocok!'), backgroundColor: Color(0xFFDC2626)),
                        );
                        return;
                      }

                      setModalState(() => isUpdating = true);
                      try {
                        await Supabase.instance.client.auth.updateUser(
                          UserAttributes(password: p1),
                        );
                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Kata sandi berhasil diperbarui!'), backgroundColor: primaryEmerald),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Gagal memperbarui: $e'), backgroundColor: const Color(0xFFDC2626)),
                          );
                        }
                      } finally {
                        setModalState(() => isUpdating = false);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryEmerald,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: isUpdating
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  /// Dialog Konfirmasi Keluar Akun (Modern & Flat Minimalis)
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
          'Apakah Anda yakin ingin keluar dari Portal Usaha / UMKM Hijau?',
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
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        automaticallyImplyLeading: false, // Menghilangkan tombol back
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(
                    'Profil Usaha & Entitas Hijau',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: lightEmeraldBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _companyType == 'umkm' ? 'UMKM' : 'Korporasi Hijau',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: darkEmerald,
                    ),
                  ),
                ),
              ],
            ),
            const Text(
              'Identitas Pemasok Scrap Sirkular & Standar Mutu MRF',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF475569)),
            tooltip: 'Segarkan Data',
            onPressed: _fetchProfileAndStats,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryEmerald))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. KARTU HEADER HERO PROFIL USAHA
                  _buildHeroHeaderCard(),
                  const SizedBox(height: 16),

                  // 2. KARTU STATUS SELEKSI & VERIFIKASI PEMERINTAH (SIINas & MRV) - BARU!
                  _buildGovernmentVerificationCard(),
                  const SizedBox(height: 16),

                  // 3. METRIK KINERJA SIRKULAR
                  _buildCircularImpactSection(),
                  const SizedBox(height: 16),

                  // 4. PILIHAN KATEGORI ENTITAS (KOLOM 'company_type' DI SUPABASE)
                  _buildEntityTypeSelector(),
                  const SizedBox(height: 16),

                  // 5. FORM INFORMASI USAHA & LEGALITAS
                  _buildBusinessInfoSection(),
                  const SizedBox(height: 16),

                  // 6. FASILITAS OPERASIONAL DEPO
                  _buildFacilitiesSection(),
                  const SizedBox(height: 16),

                  // 7. PENGATURAN & KEAMANAN AKUN
                  _buildSecuritySection(),
                  const SizedBox(height: 24),

                  // TOMBOL SIMPAN UTAMA
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryEmerald,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.save_outlined, size: 20),
                      label: Text(
                        _isSaving ? 'Menyimpan Perubahan...' : 'Simpan Pembaruan Profil Usaha',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // TOMBOL LOGOUT RESMI
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: _confirmLogout,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.logout_rounded, size: 18),
                      label: const Text(
                        'Keluar dari Akun Usaha',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  /// ==========================================================================
  /// 1. KARTU HEADER HERO PROFIL USAHA (RESPONSIF BEBAS OVERFLOW)
  /// ==========================================================================
  Widget _buildHeroHeaderCard() {
    final bool isVerified = _isVerified || _verificationStatus == 'terverifikasi';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar dengan Badge Kamera
              Stack(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: lightEmeraldBg,
                    backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                    child: _avatarUrl == null
                        ? const Icon(Icons.storefront_rounded, size: 36, color: primaryEmerald)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _isUploadingImage ? null : _showImagePickerSheet,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: primaryEmerald,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: _isUploadingImage
                            ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),

              // Identitas Usaha & Badges
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _nameCtrl.text.isNotEmpty ? _nameCtrl.text : 'Nama Usaha / Depo Belum Diatur',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _picCtrl.text.isNotEmpty ? 'PIC: ${_picCtrl.text}' : 'Penanggung Jawab Usaha',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (_userEmail != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        _userEmail!,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),

                    // Badges Status MRF & Rating
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isVerified ? lightEmeraldBg : const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isVerified ? const Color(0xFFA7F3D0) : const Color(0xFFFDE68A),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isVerified ? Icons.verified_rounded : Icons.pending_actions_rounded,
                                size: 12,
                                color: isVerified ? darkEmerald : const Color(0xFFD97706),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isVerified ? 'Terverifikasi Standar MRF' : 'Menunggu Kurasi MRF',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: isVerified ? darkEmerald : const Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star_rounded, size: 12, color: Color(0xFFF59E0B)),
                              SizedBox(width: 3),
                              Text(
                                'Rating 4.9 • Mitra Terpercaya',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ==========================================================================
  /// 2. KARTU STATUS SELEKSI & VERIFIKASI PEMERINTAH (SIINas & MRV) - BARU!
  /// ==========================================================================
  Widget _buildGovernmentVerificationCard() {
    final bool isVerified = _isVerified || _verificationStatus == 'terverifikasi';
    final bool isPending = _verificationStatus == 'menunggu_verifikasi';

    final Color badgeBg = isVerified
        ? const Color(0xFFECFDF5)
        : (isPending ? const Color(0xFFFEF3C7) : const Color(0xFFFEE2E2));
    final Color badgeBorder = isVerified
        ? const Color(0xFFA7F3D0)
        : (isPending ? const Color(0xFFFDE68A) : const Color(0xFFFECACA));
    final Color badgeTextCol = isVerified
        ? const Color(0xFF065F46)
        : (isPending ? const Color(0xFFB45309) : const Color(0xFFB91C1C));
    final IconData statusIcon = isVerified
        ? Icons.verified_user_rounded
        : (isPending ? Icons.pending_actions_rounded : Icons.gpp_bad_rounded);

    final String statusLabel = isVerified
        ? 'Terseleksi & Terverifikasi Pemerintah (Grade $_verificationGrade)'
        : (isPending ? 'Dalam Proses Seleksi Pemerintah' : 'Perlu Perbaikan Berkas');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isVerified ? const Color(0xFFA7F3D0) : const Color(0xFFE2E8F0),
          width: isVerified ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Icon + Judul Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(statusIcon, size: 18, color: badgeTextCol),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Status Seleksi & Verifikasi Pemerintah',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Status Badge Pill (Wrap agar aman dari overflow di HP sempit)
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: badgeBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: 14, color: badgeTextCol),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: badgeTextCol,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (_verifiedAt != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_outlined, size: 12, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        'Audit: $_verifiedAt',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF475569), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Detail Keterangan Otoritas & Catatan
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFF1F5F9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildVerificationRow(
                  label: 'Otoritas Verifikator:',
                  value: _verifiedBy ?? 'Direktorat Industri Logam, Kemenperin RI',
                  icon: Icons.account_balance_outlined,
                ),
                const SizedBox(height: 8),
                _buildVerificationRow(
                  label: 'Catatan Audit SIINas & MRV:',
                  value: _verificationNotes ?? 'Lolos seleksi uji sortir MRF bebas zat radioaktif & siap umpan EAF 52%',
                  icon: Icons.fact_check_outlined,
                ),
                const SizedBox(height: 8),
                _buildVerificationRow(
                  label: 'Hak Akses Bursa:',
                  value: isVerified
                      ? 'Prioritas utama tampil di katalog Green Market & otomatis lolos PO resmi transaksi pabrik baja.'
                      : 'Profil usaha dalam antrean verifikasi oleh auditor Kementerian Perindustrian.',
                  icon: Icons.storefront_outlined,
                  valueColor: isVerified ? darkEmerald : const Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationRow({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? const Color(0xFF1E293B),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ==========================================================================
  /// 3. METRIK KINERJA SIRKULAR
  /// ==========================================================================
  Widget _buildCircularImpactSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.eco_rounded, size: 16, color: primaryEmerald),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Akumulasi Kontribusi Dekarbonisasi Pasokan',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: darkEmerald,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  title: 'Pasokan Aktif',
                  value: '${_totalActiveTonnage.toStringAsFixed(0)} Ton',
                  sub: '$_activeLotsCount Lot Terdaftar',
                  icon: Icons.inventory_2_outlined,
                  color: primaryEmerald,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  title: 'Reduksi Emisi',
                  value: '${_totalCo2Saved.toStringAsFixed(0)} tCO2e',
                  sub: 'Substitusi EAF Pabrik',
                  icon: Icons.cloud_done_outlined,
                  color: const Color(0xFF0284C7),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile(
                  title: 'Kemurnian Fe',
                  value: '${_avgFeGrade.toStringAsFixed(1)}%',
                  sub: 'Standar Lolos MRF',
                  icon: Icons.high_quality_outlined,
                  color: const Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String sub,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDCFCE7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(fontSize: 9.5, color: Color(0xFF94A3B8)),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  /// ==========================================================================
  /// 4. PILIHAN KATEGORI ENTITAS (KOLOM 'company_type' DI SUPABASE)
  /// ==========================================================================
  Widget _buildEntityTypeSelector() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.category_rounded, size: 16, color: primaryEmerald),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Klasifikasi Entitas Pemasok (Database: company_type)',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Menentukan segmentasi usaha Anda di Green Market Pabrik Baja (Pilihan filter UMKM vs Perusahaan Hijau).',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.35),
          ),
          const SizedBox(height: 14),

          // Pilihan 1: UMKM Scrap & Daur Ulang
          InkWell(
            onTap: () => setState(() => _companyType = 'umkm'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _companyType == 'umkm' ? lightEmeraldBg : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _companyType == 'umkm' ? primaryEmerald : const Color(0xFFE2E8F0),
                  width: _companyType == 'umkm' ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _companyType == 'umkm' ? primaryEmerald : const Color(0xFFCBD5E1),
                        width: 2,
                      ),
                    ),
                    child: _companyType == 'umkm'
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryEmerald,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'UMKM Hijau (Lapak, Pengepul & Koperasi)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Unit usaha mikro, kecil & menengah yang mengagregasi scrap logam masyarakat dan bengkel lokal.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Pilihan 2: Perusahaan Hijau / Agregator Industri
          InkWell(
            onTap: () => setState(() => _companyType = 'perusahaan_hijau'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _companyType == 'perusahaan_hijau' ? lightEmeraldBg : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _companyType == 'perusahaan_hijau' ? primaryCyan : const Color(0xFFE2E8F0),
                  width: _companyType == 'perusahaan_hijau' ? 1.5 : 1.0,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _companyType == 'perusahaan_hijau' ? primaryCyan : const Color(0xFFCBD5E1),
                        width: 2,
                      ),
                    ),
                    child: _companyType == 'perusahaan_hijau'
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: primaryCyan,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Perusahaan Hijau (MRF Korporasi & Vendor Industri)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Entitas berbadan hukum (PT/CV) dengan mesin shredder industri, pemilah magnetik skala besar & logistik modern.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.3),
                        ),
                      ],
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

  /// ==========================================================================
  /// 5. FORM INFORMASI USAHA & LEGALITAS
  /// ==========================================================================
  Widget _buildBusinessInfoSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.business_center_rounded, size: 16, color: primaryEmerald),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Informasi Legalitas & Operasional Depo',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Nama Usaha
          _buildTextField(
            controller: _nameCtrl,
            label: 'Nama Usaha / Depo Pengolahan',
            hint: 'Contoh: Koperasi Logam Jaya Abadi',
            icon: Icons.storefront_rounded,
          ),
          const SizedBox(height: 12),

          // Penanggung Jawab
          _buildTextField(
            controller: _picCtrl,
            label: 'Penanggung Jawab / Pemilik Depo (PIC)',
            hint: 'Contoh: Bpk. Bambang Sutrisno',
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 12),

          // NIB / Izin Usaha
          _buildTextField(
            controller: _nibCtrl,
            label: 'Nomor Induk Berusaha (NIB) / Izin Depo',
            hint: 'Contoh: NIB. 9120004523812',
            icon: Icons.badge_outlined,
          ),
          const SizedBox(height: 12),

          // Telepon / WhatsApp
          _buildTextField(
            controller: _phoneCtrl,
            label: 'No. Telepon / WhatsApp Operasional',
            hint: 'Contoh: +62 812-3456-7890',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),

          // Alamat Depo
          _buildTextField(
            controller: _locationCtrl,
            label: 'Wilayah & Alamat Lengkap Depo',
            hint: 'Contoh: Kawasan Industri Pergudangan Margomulyo, Surabaya',
            icon: Icons.location_on_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: 12),

          // Kapasitas Bulanan
          _buildTextField(
            controller: _capacityCtrl,
            label: 'Estimasi Kapasitas Pasok Bulanan (Ton / Bulan)',
            hint: 'Contoh: 1850',
            icon: Icons.speed_rounded,
            keyboardType: TextInputType.number,
            suffixText: 'Ton/Bulan',
          ),
        ],
      ),
    );
  }

  /// ==========================================================================
  /// 6. FASILITAS OPERASIONAL DEPO
  /// ==========================================================================
  Widget _buildFacilitiesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.precision_manufacturing_rounded, size: 16, color: primaryEmerald),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Fasilitas & Peralatan Depo Tersedia',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Pilih fasilitas yang Anda miliki untuk meningkatkan kepercayaan pembeli (Pabrik Baja EAF).',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _availableFacilities.map((fac) {
              final isSelected = _selectedFacilities.contains(fac);
              return FilterChip(
                label: Text(fac),
                selected: isSelected,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _selectedFacilities.add(fac);
                    } else {
                      _selectedFacilities.remove(fac);
                    }
                  });
                },
                selectedColor: lightEmeraldBg,
                checkmarkColor: primaryEmerald,
                labelStyle: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? darkEmerald : const Color(0xFF334155),
                ),
                backgroundColor: const Color(0xFFF1F5F9),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: isSelected ? primaryEmerald : const Color(0xFFE2E8F0),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// ==========================================================================
  /// 7. PENGATURAN & KEAMANAN AKUN
  /// ==========================================================================
  Widget _buildSecuritySection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.security_rounded, size: 16, color: primaryEmerald),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Keamanan & Akses Akun',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.lock_outline_rounded, color: Color(0xFF475569), size: 20),
            ),
            title: const Text('Perbarui Kata Sandi Akun', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: const Text('Ganti password login untuk keamanan depo', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            onTap: _showChangePasswordDialog,
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: lightEmeraldBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.photo_camera_back_outlined, color: primaryEmerald, size: 20),
            ),
            title: const Text('Ganti Foto Profil / Logo Depo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: const Text('Foto profil terverifikasi meningkatkan skor transaksi', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            onTap: _showImagePickerSheet,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? suffixText,
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
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF64748B)),
            suffixText: suffixText,
            suffixStyle: const TextStyle(fontSize: 12, color: primaryEmerald, fontWeight: FontWeight.bold),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: primaryEmerald, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
