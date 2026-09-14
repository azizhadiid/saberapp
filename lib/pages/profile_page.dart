import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

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
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      'assets/img/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.factory, size: 40, color: Color(0xFF10B981)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'PT Baja Nusantara',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'ID SIINas: 8847-2991-002',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
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
            
            // Stats Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
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
                        Container(height: 20), // Placeholder to balance height
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
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
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
            Container(
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
