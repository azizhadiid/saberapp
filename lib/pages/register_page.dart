import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'login_page.dart';
import 'main_container.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _industriCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _passConfirmCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  // Pilihan Peran Registrasi (FE): 'Perusahaan', 'UMKM / Masyarakat', 'Pemerintah'
  String _selectedRole = 'Perusahaan';

  int _getTargetIndexForRole(String role) {
    if (role == 'Perusahaan') return 2; // IDRI & CBAM
    if (role == 'UMKM / Masyarakat') return 4; // Green Market Scrap UMKM
    return 0; // Pemerintah -> Dashboard Eksekutif
  }

  String _getRoleBannerText(String role) {
    if (role == 'Perusahaan') {
      return 'Pendaftaran Pabrik / Korporasi Baja: Setelah daftar, akun langsung diarahkan ke Kalkulator Audit IDRI (5 Tungku & 4 SDGs) dan Simulasi Pajak CBAM.';
    } else if (role == 'UMKM / Masyarakat') {
      return 'Pendaftaran Mitra UMKM Scrap / Publik: Setelah daftar, akun langsung diarahkan ke Green Marketplace (Bursa Besi Tua MRF 52% EAF) & Kalkulator Emisi.';
    } else {
      return 'Pendaftaran Regulator / Pemerintah: Setelah daftar, akun langsung diarahkan ke Dashboard Monitoring Dekarbonisasi Nasional & Peta Kerentanan Pekerja (Jenks).';
    }
  }

  String _getNameLabel(String role) {
    if (role == 'Perusahaan') return 'Nama Perusahaan Industri';
    if (role == 'UMKM / Masyarakat') return 'Nama Lapak UMKM / Koperasi Scrap';
    return 'Nama Instansi / Direktorat Pemerintah';
  }

  String _getNameHint(String role) {
    if (role == 'Perusahaan') return 'PT Krakatau Baja Hijau Tbk';
    if (role == 'UMKM / Masyarakat') return 'Koperasi Logam Jaya Surabaya';
    return 'Ditjen ILMATE Kemenperin / DLH Provinsi';
  }

  String _getEmailLabel(String role) {
    if (role == 'Perusahaan') return 'Email Resmi Perusahaan';
    if (role == 'UMKM / Masyarakat') return 'Email UMKM / Pengelola';
    return 'Email Instansi (.go.id)';
  }

  String _getEmailHint(String role) {
    if (role == 'Perusahaan') return 'esg@perusahaanbaja.co.id';
    if (role == 'UMKM / Masyarakat') return 'lapakbesitua@umkm.id';
    return 'auditor@kemenperin.go.id';
  }

  String _getSubfieldLabel(String role) {
    if (role == 'Perusahaan') return 'Rute Tungku / Sub-Sektor Industri';
    if (role == 'UMKM / Masyarakat') return 'Spesialisasi Pasokan Besi Tua / Scrap';
    return 'Wilayah Yurisdiksi / Fokus Pengawasan';
  }

  String _getSubfieldHint(String role) {
    if (role == 'Perusahaan') return 'Blast Furnace / EAF / Induction Furnace';
    if (role == 'UMKM / Masyarakat') return 'Scrap HMS 1&2 / Shredded MRF / Baler';
    return 'Nasional / Jawa Timur (Zona Merah Jenks)';
  }

  void _quickTestRole(String roleName, int navIndex, String targetLabel) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MainContainer(
          initialIndex: navIndex,
          userRole: roleName,
        ),
      ),
      (route) => false,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Simulasi Pendaftaran $roleName — Diarahkan ke $targetLabel',
        ),
        backgroundColor: const Color(0xFF059669),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _doRegister() async {
    if (_namaCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _industriCtrl.text.trim().isEmpty ||
        _passCtrl.text.trim().isEmpty ||
        _passConfirmCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua field wajib diisi!')));
      return;
    }

    if (_passCtrl.text != _passConfirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Konfirmasi kata sandi tidak cocok!')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        emailRedirectTo: 'io.supabase.saberkarbon://login-callback/',
        data: {
          'company_name': _namaCtrl.text.trim(),
          'industry_type': _industriCtrl.text.trim(),
          'user_role': _selectedRole,
        },
      );

      if (mounted) {
        if (res.session == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Registrasi sukses! Silakan cek email Anda untuk verifikasi.',
              ),
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => MainContainer(
                initialIndex: _getTargetIndexForRole(_selectedRole),
                userRole: _selectedRole,
              ),
            ),
            (route) => false,
          );
        }
      }
    } on AuthException catch (error) {
      String pesan = 'Terjadi kesalahan saat pendaftaran.';

      if (error.message.contains('Error sending confirmation email') ||
          error.message.contains('unexpected_failure')) {
        pesan =
            'Sistem gagal mengirim email verifikasi. Harap registrasi menggunakan tombol Google atau Akses Cepat di bawah.';
      } else if (error.message.contains('User already registered')) {
        pesan =
            'Email ini sudah terdaftar sebelumnya. Silakan gunakan email lain atau langsung masuk (login).';
      } else if (error.message.contains('rate_limit')) {
        pesan =
            'Terlalu banyak percobaan. Harap tunggu beberapa saat lalu coba lagi.';
      } else if (error.message.contains('Password should be at least')) {
        pesan = 'Kata sandi terlalu pendek. Gunakan minimal 6 karakter.';
      } else {
        pesan = error.message;
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(pesan),
            backgroundColor: Colors.red.shade800,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Terjadi kesalahan sistem yang tidak terduga.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      const webClientId =
          '203444577116-nif00u6bi10seiv78jgs4bgonu0gb8bb.apps.googleusercontent.com';
      const iosClientId =
          '203444577116-6nl73gcdqiknp6mo0q0dfdeni3li5gci.apps.googleusercontent.com';

      await GoogleSignIn.instance.initialize(
        serverClientId: webClientId,
        clientId: iosClientId,
      );
      final googleUser = await GoogleSignIn.instance.authenticate();

      final googleAuth = googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) throw 'Gagal mendapatkan otorisasi dari Google.';

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MainContainer(
            initialIndex: _getTargetIndexForRole(_selectedRole),
            userRole: _selectedRole,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal Login Google: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildRoleSelectorTab({
    required String role,
    required String shortLabel,
    required IconData icon,
    required Color activeColor,
  }) {
    final bool isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = role;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? activeColor : const Color(0xFFE5E7EB),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
              const SizedBox(height: 4),
              Text(
                shortLabel,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF374151),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.asset(
                'assets/img/onboarding.jpg',
                fit: BoxFit.cover,
                color: Colors.grey,
                colorBlendMode: BlendMode.saturation,
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 26,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/img/logo.png',
                        height: 68,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.factory, size: 68),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Registrasi Ekosistem SABER KARBON',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Pilih jenis akun pendaftaran sesuai entitas Anda',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ========================================================
                      // 1. TAB PILIHAN PERAN PENDAFTARAN (FE)
                      // ========================================================
                      Row(
                        children: [
                          _buildRoleSelectorTab(
                            role: 'Perusahaan',
                            shortLabel: 'Perusahaan',
                            icon: Icons.factory_outlined,
                            activeColor: const Color(0xFF059669),
                          ),
                          const SizedBox(width: 8),
                          _buildRoleSelectorTab(
                            role: 'UMKM / Masyarakat',
                            shortLabel: 'UMKM / Publik',
                            icon: Icons.recycling_rounded,
                            activeColor: const Color(0xFF0284C7),
                          ),
                          const SizedBox(width: 8),
                          _buildRoleSelectorTab(
                            role: 'Pemerintah',
                            shortLabel: 'Pemerintah',
                            icon: Icons.account_balance_outlined,
                            activeColor: const Color(0xFF4F46E5),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 16,
                              color: Color(0xFF059669),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getRoleBannerText(_selectedRole),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF065F46),
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ========================================================
                      // 2. FORM REGISTRASI DINAMIS (BACKEND TETAP SAMA)
                      // ========================================================
                      _buildTextField(
                        label: _getNameLabel(_selectedRole),
                        icon: Icons.business_outlined,
                        hint: _getNameHint(_selectedRole),
                        controller: _namaCtrl,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        label: _getEmailLabel(_selectedRole),
                        icon: Icons.mail_outline,
                        hint: _getEmailHint(_selectedRole),
                        controller: _emailCtrl,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        label: _getSubfieldLabel(_selectedRole),
                        icon: Icons.category_outlined,
                        hint: _getSubfieldHint(_selectedRole),
                        controller: _industriCtrl,
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        label: 'Kata Sandi',
                        icon: Icons.lock_outline,
                        hint: '........',
                        controller: _passCtrl,
                        isPassword: true,
                        obscure: _obscure,
                        onToggleObscure: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                      const SizedBox(height: 14),
                      _buildTextField(
                        label: 'Konfirmasi Kata Sandi',
                        icon: Icons.lock_outline,
                        hint: '........',
                        controller: _passConfirmCtrl,
                        isPassword: true,
                        obscure: _obscureConfirm,
                        onToggleObscure: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _doRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 3,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        'Daftar Akun $_selectedRole',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.5,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward, size: 18),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton(
                        onPressed: _isLoading ? null : _signInWithGoogle,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.grey.shade300,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/120px-Google_%22G%22_logo.svg.png',
                              height: 20,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.g_mobiledata),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Daftar dengan Google',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tombol Tes Langsung Sesuai Peran yang Dipilih
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () {
                            final int idx = _getTargetIndexForRole(
                              _selectedRole,
                            );
                            final String targetName = _selectedRole == 'Perusahaan'
                                ? 'Kalkulator IDRI & CBAM'
                                : (_selectedRole == 'UMKM / Masyarakat'
                                      ? 'Green Market Scrap UMKM'
                                      : 'Dashboard Eksekutif Nasional');
                            _quickTestRole(_selectedRole, idx, targetName);
                          },
                          icon: const Icon(
                            Icons.play_circle_outline_rounded,
                            size: 18,
                            color: Color(0xFF059669),
                          ),
                          label: Text(
                            'Tes Langsung Alur $_selectedRole (Tanpa Daftar)',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Sudah punya akun? ',
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            ),
                            child: const Text(
                              'Masuk sekarang',
                              style: TextStyle(
                                color: Color(0xFF006D44),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleObscure,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF4B5563),
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
            prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF9CA3AF),
                      size: 20,
                    ),
                    onPressed: onToggleObscure,
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF10B981)),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}
