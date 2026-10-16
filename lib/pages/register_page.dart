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

  // 3 Role: 'perusahaan_baja', 'perusahaan_hijau', 'pemerintah'
  String _selectedRole = 'perusahaan_baja';

  int _getTargetIndexForRole(String role) {
    // Setiap role mendarat di tab Beranda / Utama masing-masing:
    // - Perusahaan Baja   -> Dashboard Pabrik (0)
    // - Perusahaan Hijau  -> Katalog Pasokan Scrap (0)
    // - Pemerintah        -> Dashboard Nasional SIINas (0)
    return 0;
  }

  String _getRoleDisplayName(String role) {
    if (role == 'perusahaan_baja') return 'Perusahaan Baja';
    if (role == 'perusahaan_hijau') return 'Perusahaan Hijau';
    return 'Pemerintah';
  }

  Color _getRoleColor(String role) {
    if (role == 'perusahaan_baja') return const Color(0xFF059669);
    if (role == 'perusahaan_hijau') return const Color(0xFF0284C7);
    return const Color(0xFF4F46E5);
  }

  String _getNameLabel(String role) {
    if (role == 'perusahaan_baja') return 'Nama Perusahaan / Pabrik Baja';
    if (role == 'perusahaan_hijau') return 'Nama Usaha UMKM / Lapak Scrap';
    return 'Nama Instansi / Dinas Pemerintah';
  }

  String _getNameHint(String role) {
    if (role == 'perusahaan_baja') return 'PT Krakatau Steel Tbk';
    if (role == 'perusahaan_hijau') return 'Koperasi Logam Jaya Surabaya';
    return 'Ditjen ILMATE Kemenperin / DLH Provinsi';
  }

  String _getSubfieldLabel(String role) {
    if (role == 'perusahaan_baja') return 'Rute Tungku Eksisting';
    if (role == 'perusahaan_hijau') return 'Kategori Bahan Baku / Layanan';
    return 'Direktorat / Bidang Pengawasan';
  }

  String _getSubfieldHint(String role) {
    if (role == 'perusahaan_baja') {
      return 'Blast Furnace / EAF / Induction Furnace';
    }
    if (role == 'perusahaan_hijau') {
      return 'Scrap HMS 1&2 / Shredded MRF / Baler';
    }
    return 'Pengawasan Emisi & Kebijakan Industri';
  }

  String _getEmailHint(String role) {
    if (role == 'perusahaan_baja') return 'esg@perusahaanbaja.co.id';
    if (role == 'perusahaan_hijau') return 'lapak.scrap@umkm.id';
    return 'auditor@kemenperin.go.id';
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _emailCtrl.dispose();
    _industriCtrl.dispose();
    _passCtrl.dispose();
    _passConfirmCtrl.dispose();
    super.dispose();
  }

  /// Simpan langsung ke tabel public.companies dan auth.users agar 100% tersimpan di database
  Future<void> _saveCompanyRecord(User user, String chosenRole) async {
    try {
      await Supabase.instance.client.from('companies').upsert({
        'user_id': user.id,
        'role': chosenRole,
        'name': _namaCtrl.text.trim().isNotEmpty
            ? _namaCtrl.text.trim()
            : (user.userMetadata?['company_name'] ??
                  user.userMetadata?['full_name'] ??
                  'Entitas Terdaftar'),
        'siinas_id': _industriCtrl.text.trim().isNotEmpty
            ? _industriCtrl.text.trim()
            : 'Umum',
        'location': 'Indonesia',
      }, onConflict: 'user_id');

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(data: {'user_role': chosenRole}),
      );
    } catch (e) {
      debugPrint('Error direct save company record: $e');
    }
  }

  Future<void> _doRegister() async {
    if (_namaCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _industriCtrl.text.trim().isEmpty ||
        _passCtrl.text.trim().isEmpty ||
        _passConfirmCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Semua field wajib diisi!'),
          backgroundColor: Color(0xFFDC2626),
        ),
      );
      return;
    }

    if (_passCtrl.text != _passConfirmCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Konfirmasi kata sandi tidak cocok!'),
          backgroundColor: Color(0xFFDC2626),
        ),
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

      if (res.user != null) {
        // Tulis langsung ke database companies agar role tersimpan permanen
        await _saveCompanyRecord(res.user!, _selectedRole);
      }

      if (mounted) {
        if (res.session == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Registrasi sukses! Silakan periksa email untuk verifikasi.',
              ),
              backgroundColor: Color(0xFF059669),
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
                userRole: _getRoleDisplayName(_selectedRole),
              ),
            ),
            (route) => false,
          );
        }
      }
    } on AuthException catch (error) {
      String pesan = 'Terjadi kesalahan saat pendaftaran: ${error.message}';
      if (error.message.contains('User already registered')) {
        pesan = 'Email ini sudah terdaftar. Silakan langsung masuk (login).';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(pesan),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan tidak terduga: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signUpWithGoogle() async {
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
        await _saveCompanyRecord(res.user!, _selectedRole);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan saat daftar dengan Google: $e'),
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
          // Background Image
          Positioned.fill(
            child: Image.asset('assets/img/onboarding.jpg', fit: BoxFit.cover),
          ),
          // Dark Overlay
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
                          'Buat Akun Baru',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Pilih peran entitas Anda untuk mendaftar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 18),

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
                        const SizedBox(height: 18),

                        // Input Forms
                        _buildInputField(
                          label: _getNameLabel(_selectedRole),
                          hint: _getNameHint(_selectedRole),
                          icon: Icons.business_outlined,
                          controller: _namaCtrl,
                        ),
                        const SizedBox(height: 12),

                        _buildInputField(
                          label: 'Email Resmi',
                          hint: _getEmailHint(_selectedRole),
                          icon: Icons.mail_outline,
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),

                        _buildInputField(
                          label: _getSubfieldLabel(_selectedRole),
                          hint: _getSubfieldHint(_selectedRole),
                          icon: Icons.category_outlined,
                          controller: _industriCtrl,
                        ),
                        const SizedBox(height: 12),

                        _buildInputField(
                          label: 'Kata Sandi',
                          hint: 'Minimal 6 karakter',
                          icon: Icons.lock_outline,
                          controller: _passCtrl,
                          isPassword: true,
                          obscure: _obscure,
                          onToggleObscure: () =>
                              setState(() => _obscure = !_obscure),
                        ),
                        const SizedBox(height: 12),

                        _buildInputField(
                          label: 'Konfirmasi Kata Sandi',
                          hint: 'Ketik ulang kata sandi',
                          icon: Icons.lock_clock_outlined,
                          controller: _passConfirmCtrl,
                          isPassword: true,
                          obscure: _obscureConfirm,
                          onToggleObscure: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Tombol Submit Daftar
                        SizedBox(
                          height: 46,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _doRegister,
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
                                    'Daftar sebagai ${_getRoleDisplayName(_selectedRole)}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.5,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Divider
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
                        const SizedBox(height: 12),

                        // Google Sign Up
                        SizedBox(
                          height: 46,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _signUpWithGoogle,
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
                                  'Daftar dengan Google',
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
                        const SizedBox(height: 18),

                        // Link ke Login
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Sudah punya akun? ',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              ),
                              child: Text(
                                'Masuk',
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
        const SizedBox(height: 5),
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
              vertical: 11,
              horizontal: 14,
            ),
          ),
        ),
      ],
    );
  }
}
