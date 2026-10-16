import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'register_page.dart';
import 'main_container.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  // Pilihan Peran Login (FE): 'Perusahaan', 'UMKM / Masyarakat', 'Pemerintah'
  String _selectedRole = 'Perusahaan';

  late final StreamSubscription<AuthState> _authSubscription;

  int _getTargetIndexForRole(String role) {
    if (role == 'Perusahaan') {
      return 2; // Ke Kalkulator Audit IDRI & 4 SDGs
    } else if (role == 'UMKM / Masyarakat') {
      return 4; // Ke Green Market (Bursa Scrap UMKM & MRF)
    } else {
      return 0; // Pemerintah / Publik -> Ke Dashboard Eksekutif Nasional
    }
  }

  String _getRoleRouteDescription(String role) {
    if (role == 'Perusahaan') {
      return 'Arahan Sistem: Masuk ke Kalkulator Audit IDRI (5 Rute Tungku & 4 SDGs) serta Simulasi Pajak Ekspor CBAM.';
    } else if (role == 'UMKM / Masyarakat') {
      return 'Arahan Sistem: Masuk ke Bursa Scrap UMKM (Standar MRF 52% EAF), Kalkulator Dampak Emisi, & Data Publik.';
    } else {
      return 'Arahan Sistem: Masuk ke Dashboard Eksekutif Nasional (Lintasan Net Zero 2060, Peta Jenks 38 Provinsi & Pajak Karbon).';
    }
  }

  String _getEmailLabel(String role) {
    if (role == 'Perusahaan') return 'Email Perusahaan Industri';
    if (role == 'UMKM / Masyarakat') return 'Email UMKM Scrap / Masyarakat';
    return 'Email Instansi Pemerintah';
  }

  String _getEmailHint(String role) {
    if (role == 'Perusahaan') return 'audit@krakatausteel.co.id';
    if (role == 'UMKM / Masyarakat') return 'koperasi.scrap@umkm.id';
    return 'pengawasan@kemenperin.go.id';
  }

  @override
  void initState() {
    super.initState();
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn && data.session != null) {
        if (mounted) {
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
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _quickEnterRole(String roleName, int navIndex, String destinationLabel) {
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
          'Mode $roleName Aktif — Diarahkan langsung ke $destinationLabel',
        ),
        backgroundColor: const Color(0xFF059669),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _doLogin() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Form tidak boleh kosong!')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
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
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal: ${error.message}')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan tidak terduga')),
      );
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

  Widget _buildQuickRoleTestButton({
    required String title,
    required String targetInfo,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Text(
                    targetInfo,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 13, color: color),
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/img/logo.png',
                        height: 68,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.factory, size: 68),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Selamat Datang di SABER KARBON',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Pilih peran ekosistem Anda untuk masuk ke modul yang sesuai',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ========================================================
                      // 1. PILIHAN 3 PERAN PENGGUNA (FE) & ARAHAN MODUL
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
                              Icons.route_outlined,
                              size: 16,
                              color: Color(0xFF059669),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _getRoleRouteDescription(_selectedRole),
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
                      // 2. FORM LOGIN UTAMA (SISTEM TETAP SAMA)
                      // ========================================================
                      _buildTextField(
                        label: _getEmailLabel(_selectedRole),
                        icon: Icons.mail_outline,
                        hint: _getEmailHint(_selectedRole),
                        controller: _emailCtrl,
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
                        rightLabel: 'Lupa Kata Sandi?',
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _doLogin,
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
                                        'Masuk sebagai $_selectedRole',
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
                              'Masuk dengan Google',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // ========================================================
                      // 3. SECTION 3 TOMBOL ARAHAN AKSES CEPAT / PUBLIK (TANPA LOGIN)
                      // ========================================================
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              'AKSES CEPAT & SIMULASI TANPA LOGIN',
                              style: TextStyle(
                                color: Color(0xFF4B5563),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildQuickRoleTestButton(
                        title: '1. Masuk Mode Perusahaan Baja',
                        targetInfo: 'Ke Kalkulator IDRI (5 Tungku & 4 SDGs) + CBAM',
                        icon: Icons.factory_outlined,
                        color: const Color(0xFF059669),
                        onTap: () => _quickEnterRole(
                          'Perusahaan Industri',
                          2,
                          'Kalkulator Audit IDRI & 4 SDGs',
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildQuickRoleTestButton(
                        title: '2. Masuk Mode UMKM Scrap / Masyarakat',
                        targetInfo: 'Ke Bursa Besi Tua UMKM (MRF) & Dampak Emisi',
                        icon: Icons.recycling_rounded,
                        color: const Color(0xFF0284C7),
                        onTap: () => _quickEnterRole(
                          'UMKM Scrap / Masyarakat',
                          4,
                          'Green Market & Bursa Scrap UMKM',
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildQuickRoleTestButton(
                        title: '3. Masuk Mode Pemerintah / Publik Tamu',
                        targetInfo: 'Ke Dashboard Eksekutif, Net Zero & Peta Jenks',
                        icon: Icons.account_balance_outlined,
                        color: const Color(0xFF4F46E5),
                        onTap: () => _quickEnterRole(
                          'Pemerintah / Publik Tamu',
                          0,
                          'Dashboard Eksekutif & Open Data Nasional',
                        ),
                      ),
                      const SizedBox(height: 18),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Belum punya akun? ',
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterPage(),
                              ),
                            ),
                            child: const Text(
                              'Daftar sekarang',
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
    String? rightLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4B5563),
                  fontSize: 12.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (rightLabel != null)
              Text(
                rightLabel,
                style: const TextStyle(
                  color: Color(0xFF006D44),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
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
