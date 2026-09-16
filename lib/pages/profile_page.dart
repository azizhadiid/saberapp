import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _companyNameCtrl = TextEditingController();
  final _siinasIdCtrl = TextEditingController();
  bool _isSaving = false;

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
              Navigator.pop(context); // Tutup dialog
              await Supabase.instance.client.auth.signOut();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (_companyNameCtrl.text.isEmpty || _siinasIdCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harap isi semua data!')));
      return;
    }
    setState(() => _isSaving = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw 'User tidak ditemukan';
      
      // 1. Simpan ke tabel companies
      final companyRes = await Supabase.instance.client.from('companies').insert({
        'name': _companyNameCtrl.text,
        'siinas_id': _siinasIdCtrl.text,
      }).select().single();
      
      // 2. Simpan relasi ke tabel authorized
      await Supabase.instance.client.from('authorized').insert({
        'user_id': user.id,
        'company_id': companyRes['id'],
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil perusahaan berhasil disimpan!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _companyNameCtrl.dispose();
    _siinasIdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
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
          style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header: Logo, Name, ID, Badge
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      'assets/img/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.factory, size: 40, color: Color(0xFF10B981)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Profil Perusahaan Anda',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Color(0xFF10B981), size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Verified Enterprise',
                          style: TextStyle(color: Color(0xFF065F46), fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Form Edit Profil
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('LENGKAPI DATA PERUSAHAAN', style: TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _companyNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nama Perusahaan',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.business),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _siinasIdCtrl,
                    decoration: const InputDecoration(
                      labelText: 'ID SIINas',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.numbers),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isSaving 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Simpan Data Perusahaan', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Stats Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('STATUS IDRI', style: TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        const Text('Level 3', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF111827))),
                        const SizedBox(height: 4),
                        const Text('(Transisi)', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 60, color: const Color(0xFFF3F4F6)),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('KARBON DIHEMAT', style: TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        const Text('12,500 Ton', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF006D44))),
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
                  BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 10, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(left: 20, top: 20, bottom: 8),
                    child: Text('PENGATURAN & INTEGRASI', style: TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                  const Divider(color: Color(0xFFF3F4F6)),
                  _buildListTile(
                    title: 'Integrasi Data SIINas\nKemenperin',
                    trailing: Switch(
                      value: true,
                      onChanged: (val) {},
                      activeColor: Colors.white,
                      activeTrackColor: const Color(0xFF10B981),
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  _buildListTile(
                    title: 'Unduh Laporan Emisi Tahunan (PDF)',
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  _buildListTile(
                    title: 'Manajemen Akses Karyawan',
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                  ),
                  const Divider(height: 1, color: Color(0xFFF3F4F6)),
                  _buildListTile(
                    title: 'Notifikasi Peringatan Pajak CBAM',
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
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
                  Text('Pusat Bantuan SABER KARBON', style: TextStyle(color: Color(0xFF4B5563), fontWeight: FontWeight.bold, fontSize: 13)),
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
                    Text('Keluar dari Akun', style: TextStyle(color: Color(0xFFDC2626), fontWeight: FontWeight.bold, fontSize: 13)),
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

  Widget _buildListTile({required String title, required Widget trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF1F2937), height: 1.4))),
          trailing,
        ],
      ),
    );
  }
}
