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

  // 3 Role: 'perusahaan_baja', 'perusahaan_hijau', 'pemerintah'
  String _selectedRole = 'perusahaan_baja';

  late final StreamSubscription<AuthState> _authSubscription;

  int _getTargetIndexForRole(String role) {
    if (role == 'perusahaan_baja') {
      return 2; // IDRI & CBAM
    } else if (role == 'perusahaan_hijau') {
      return 4; // Green Marketplace & Scrap UMKM
    } else {
      return 0; // Dashboard Nasional & Panel Admin MRV
    }
  }

  String _getRoleDisplayName(String role) {
    if (role == 'perusahaan_baja') return 'Perusahaan Baja';
    if (role == 'perusahaan_hijau') return 'Perusahaan Hijau';
    return 'Pemerintah';
  }

  Color _getRoleColor(String role) {
    if (role == 'perusahaan_baja') return const Color(0xFF059669); // Emerald
    if (role == 'perusahaan_hijau') return const Color(0xFF0284C7); // Sky Blue
    return const Color(0xFF4F46E5); // Indigo
  }

  String _getEmailHint(String role) {
    if (role == 'perusahaan_baja') return 'audit@perusahaanbaja.co.id';
    if (role == 'perusahaan_hijau') return 'lapak.scrap@umkm.id';
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
        // Handle external sign-in (e.g., OAuth / Google)
        _syncAndNavigate(data.session!.user, _selectedRole);
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

  /// Sinkronisasi Role ke Tabel public.companies dan auth.users secara persisten
  Future<void> _syncAndNavigate(User user, String chosenRole) async {
    String finalRole = chosenRole;

    try {
      // 1. Cek apakah ada record di tabel public.companies
      final companyRes = await Supabase.instance.client
          .from('companies')
          .select('role, name')
          .eq('user_id', user.id)
          .maybeSingle();

      if (companyRes != null) {
        // Jika pengguna di layar login memilih peran non-default (UMKM / Pemerintah),
        // atau jika database masih kosong/default, UPDATE ke database
        if (chosenRole != 'perusahaan_baja' || companyRes['role'] == null) {
          finalRole = chosenRole;
          await Supabase.instance.client
              .from('companies')
              .update({'role': finalRole})
              .eq('user_id', user.id);
        } else {
          // Gunakan role yang sudah tersimpan di database
          finalRole = (companyRes['role'] as String?) ?? chosenRole;
        }
      } else {
        // Jika baris perusahaan belum ada (misal login Google pertama kali), BUAT baris baru
        finalRole = chosenRole;
        await Supabase.instance.client.from('companies').upsert({
          'user_id': user.id,
          'role': finalRole,
          'name':
              user.userMetadata?['company_name'] ??
              user.userMetadata?['full_name'] ??
              user.email?.split('@').first ??
              'Entitas Terdaftar',
          'siinas_id': user.userMetadata?['industry_type'] ?? 'Umum',
          'location': 'Indonesia',
        }, onConflict: 'user_id');
      }

      // 2. Simpan juga ke user_metadata Supabase agar sinkron dua arah
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'user_role': finalRole}),
      );
    } catch (e) {
      debugPrint('Sync role error (tetap lanjut navigasi): $e');
      finalRole = chosenRole;
    }

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MainContainer(
          initialIndex: _getTargetIndexForRole(finalRole),
          userRole: _getRoleDisplayName(finalRole),
        ),
      ),
      (route) => false,
    );
  }

  Future<void> _doLogin() async {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email dan kata sandi wajib diisi!'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
      );

      if (res.user != null) {
        await _syncAndNavigate(res.user!, _selectedRole);
      }
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal Masuk: ${error.message}'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan tidak terduga saat masuk.'),
          backgroundColor: Color(0xFFDC2626),
        ),
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

      final res = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
      );

      if (res.user != null) {
        await _syncAndNavigate(res.user!, _selectedRole);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat masuk dengan Google: $e'),
          backgroundColor: const Color(0xFFDC2626),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image seperti awal
          Positioned.fill(
            child: Image.asset('assets/img/onboarding.jpg', fit: BoxFit.cover),
          ),
          // Overlay gelap agar form terlihat jernih dan nyaman dibaca
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.62)),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Container(
                    padding: const EdgeInsets.all(26),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Logo & Brand Header
                        Center(
                          child: Container(
                            width: 52,
                            height: 52,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Image.asset(
                              'assets/img/logo.png',
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.factory,
                                    color: Color(0xFF0F172A),
                                    size: 28,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Masuk ke Akun',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Pilih peran Anda untuk melanjutkan',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // ========================================================
                        // TIGA TOMBOL ROLE: RAPI, SIMETRIS, & CENTER
                        // ========================================================
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              _buildCenteredRoleTab(
                                roleKey: 'perusahaan_baja',
                                title: 'Pabrik Baja',
                                icon: Icons.factory_outlined,
                                activeColor: const Color(0xFF059669),
                              ),
                              const SizedBox(width: 4),
                              _buildCenteredRoleTab(
                                roleKey: 'perusahaan_hijau',
                                title: 'Perusahaan Hijau',
                                icon: Icons.recycling_rounded,
                                activeColor: const Color(0xFF0284C7),
                              ),
                              const SizedBox(width: 4),
                              _buildCenteredRoleTab(
                                roleKey: 'pemerintah',
                                title: 'Pemerintah',
                                icon: Icons.account_balance_outlined,
                                activeColor: const Color(0xFF4F46E5),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Form Input Email & Password (Caption dihapus sesuai permintaan)
                        _buildInputField(
                          label: 'Email',
                          hint: _getEmailHint(_selectedRole),
                          icon: Icons.mail_outline,
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 14),

                        _buildInputField(
                          label: 'Kata Sandi',
                          hint: 'Masukkan kata sandi',
                          icon: Icons.lock_outline,
                          controller: _passCtrl,
                          isPassword: true,
                          obscure: _obscure,
                          onToggleObscure: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                        const SizedBox(height: 20),

                        // Tombol Masuk
                        SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _doLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getRoleColor(_selectedRole),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.5,
                                    ),
                                  )
                                : Text(
                                    'Masuk sebagai ${_getRoleDisplayName(_selectedRole)}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Divider "atau"
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'atau',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.grey.shade300,
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Tombol Google
                        SizedBox(
                          height: 46,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _signInWithGoogle,
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                color: Color(0xFFCBD5E1),
                                width: 1.2,
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
                                  height: 18,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.g_mobiledata, size: 22),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Masuk dengan Google',
                                  style: TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Link Daftar Akun
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Belum punya akun? ',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              ),
                              child: Text(
                                'Daftar sekarang',
                                style: TextStyle(
                                  color: _getRoleColor(_selectedRole),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
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
          ),
        ],
      ),
    );
  }

  Widget _buildCenteredRoleTab({
    required String roleKey,
    required String title,
    required IconData icon,
    required Color activeColor,
  }) {
    final bool isSelected = _selectedRole == roleKey;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedRole = roleKey),
        borderRadius: BorderRadius.circular(9),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
            border: Border.all(
              color: isSelected
                  ? activeColor.withValues(alpha: 0.4)
                  : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? activeColor : const Color(0xFF64748B),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? activeColor : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggleObscure,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF334155),
            fontSize: 12.5,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 13.5, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 18),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF94A3B8),
                      size: 18,
                    ),
                    onPressed: onToggleObscure,
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFCBD5E1),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: _getRoleColor(_selectedRole),
                width: 1.8,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 14,
            ),
          ),
        ),
      ],
    );
  }
}
