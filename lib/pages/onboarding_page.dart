import 'package:flutter/material.dart';
import 'login_page.dart';
import 'register_page.dart';
import 'main_container.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  void _enterAsRole(
    BuildContext context, {
    required String roleName,
    required int targetIndex,
    required String targetDesc,
  }) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MainContainer(
          initialIndex: targetIndex,
          userRole: roleName,
        ),
      ),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Masuk sebagai $roleName — Diarahkan ke $targetDesc'),
        backgroundColor: const Color(0xFF059669),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showPublicRoleSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1D5DB),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'PILIH MODE AKSES PUBLIK / SIMULASI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF059669),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Masuk Tanpa Login Sesuai Peran Ekosistem',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 14),
              _buildRoleTile(
                context: ctx,
                icon: Icons.factory_outlined,
                color: const Color(0xFF059669),
                title: '1. Mode Perusahaan / Pabrik Baja',
                subtitle:
                    'Langsung diarahkan ke Kalkulator Audit IDRI (5 Tungku & 4 SDGs) serta Simulasi Pajak CBAM.',
                onTap: () {
                  Navigator.pop(ctx);
                  _enterAsRole(
                    context,
                    roleName: 'Perusahaan Industri',
                    targetIndex: 2,
                    targetDesc: 'Kalkulator IDRI & Audit 4 SDGs',
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildRoleTile(
                context: ctx,
                icon: Icons.recycling_rounded,
                color: const Color(0xFF0284C7),
                title: '2. Mode UMKM Scrap / Masyarakat',
                subtitle:
                    'Langsung diarahkan ke Green Marketplace (Bursa Besi Tua UMKM, Standar MRF & Kalkulator Emisi).',
                onTap: () {
                  Navigator.pop(ctx);
                  _enterAsRole(
                    context,
                    roleName: 'UMKM Scrap / Masyarakat',
                    targetIndex: 4,
                    targetDesc: 'Green Market & Bursa Scrap UMKM',
                  );
                },
              ),
              const SizedBox(height: 10),
              _buildRoleTile(
                context: ctx,
                icon: Icons.account_balance_outlined,
                color: const Color(0xFF4F46E5),
                title: '3. Mode Pemerintah / Regulator & Publik',
                subtitle:
                    'Langsung diarahkan ke Dashboard Nasional (Lintasan Net Zero 2060, Peta Risiko Jenks & Open Data).',
                onTap: () {
                  Navigator.pop(ctx);
                  _enterAsRole(
                    context,
                    roleName: 'Pemerintah / Publik',
                    targetIndex: 0,
                    targetDesc: 'Dashboard Eksekutif & Open Data Nasional',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRoleTile({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF4B5563),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/img/onboarding.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.58)),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 28.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    width: 150,
                    height: 150,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE5E7EB),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(28),
                    child: Image.asset(
                      'assets/img/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.factory,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 24,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 24,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Industri Baja: Hijaukan Masa\nDepan, Kurangi Emisi',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ekosistem Terpadu Perusahaan Baja, UMKM Scrap (MRF),\ndan Regulator Menuju Net Zero 2060.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 13.5),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'LOGIN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'BUAT AKUN',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Tombol Masuk sebagai Publik / Tamu (Langkah 4)
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () => _showPublicRoleSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981).withValues(alpha: 0.92),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.explore_outlined, size: 18),
                      label: const Text(
                        'MASUK SEBAGAI PUBLIK / TAMU (3 PERAN)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
