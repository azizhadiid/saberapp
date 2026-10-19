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


  String _getRoleDisplayName(String role) {
    if (role == 'perusahaan_baja') return 'Perusahaan Baja';
    if (role == 'perusahaan_hijau') return 'Perusahaan Hijau';
    return 'Pemerintah';
  }

  Color _getRoleColor(String role) {
    return const Color(0xFF059669); // Seragam Hijau Emerald
  }

  String _getEmailHint(String role) {
    if (role == 'perusahaan_baja') return 'audit@perusahaanbaja.co.id';
    if (role == 'perusahaan_hijau') return 'lapak.scrap@umkm.id';
    return 'pengawasan@kemenperin.go.id';
  }

  bool _isVerifyingAuth = false;

  String _normalizeRole(String? role) {
    if (role == null) return 'perusahaan_baja';
    final r = role.toLowerCase().trim();
    if (r.contains('hijau') || r.contains('umkm')) return 'perusahaan_hijau';
    if (r.contains('pemerintah') ||
        r.contains('admin') ||
        r.contains('regulator')) {
      return 'pemerintah';
    }
    return 'perusahaan_baja';
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
        _verifyRoleAndNavigate(data.session!.user, _selectedRole);
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

  /// Verifikasi Role Ketat:
  /// Jika role akun di database BERBEDA dengan tab role yang dipilih saat login,
  /// maka login DITOLAK, sesi dibatalkan (signOut), dan mental kembali ke halaman login.
  /// Verifikasi Role & Navigasi:
  /// 1. Jika akun belum terdaftar (misal login Google pertama kali), otomatis daftarkan
  ///    ke role tab yang dipilih (termasuk multi-akun untuk Pemerintah Belmawa/Kemendikbud).
  /// 2. Jika akun sudah terdaftar namun berbeda peran, sediakan opsi beralih portal atau
  ///    mengubah peran akun untuk kemudahan pengujian juri Belmawa/Kemendikbud.
  Future<void> _verifyRoleAndNavigate(User user, String chosenRole) async {
    if (_isVerifyingAuth) return;
    _isVerifyingAuth = true;

    try {
      final normalizedChosenRole = _normalizeRole(chosenRole);

      // 1. Cek apakah ada record perusahaan di tabel public.companies
      Map<String, dynamic>? companyRes;
      try {
        companyRes = await Supabase.instance.client
            .from('companies')
            .select('id, role, name, user_id, email')
            .eq('user_id', user.id)
            .maybeSingle();
      } catch (e) {
        debugPrint('Info query company by user_id: $e');
      }

      // Jika belum ditemukan dengan user_id, cari via email
      if (companyRes == null && user.email != null && user.email!.isNotEmpty) {
        try {
          companyRes = await Supabase.instance.client
              .from('companies')
              .select('id, role, name, user_id, email')
              .eq('email', user.email!)
              .maybeSingle();

          if (companyRes != null && companyRes['user_id'] == null) {
            await Supabase.instance.client
                .from('companies')
                .update({'user_id': user.id})
                .eq('id', companyRes['id']);
          }
        } catch (e) {
          debugPrint('Info query company by email: $e');
        }
      }

      String? registeredRole;
      if (companyRes != null && companyRes['role'] != null) {
        registeredRole = _normalizeRole(companyRes['role'] as String);
      } else if (user.userMetadata?['user_role'] != null) {
        registeredRole =
            _normalizeRole(user.userMetadata!['user_role'] as String);
      }

      // 2. VALIDASI ROLE & KASUS PERBEDAAN PORTAL:
      if (registeredRole != null) {
        if (registeredRole != normalizedChosenRole) {
          if (mounted) {
            final registeredName = _getRoleDisplayName(registeredRole);
            final chosenName = _getRoleDisplayName(normalizedChosenRole);

            // Dialog elegan & korporat: Sempurna rata tengah, modern, dan memudahkan pengujian Belmawa
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (ctx) => Dialog(
                backgroundColor: Colors.transparent,
                insetPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header Badge Icon
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFA7F3D0),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF059669).withValues(
                                alpha: 0.14,
                              ),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.swap_horizontal_circle_rounded,
                          color: Color(0xFF059669),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Pill Tag Korporat
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF059669),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'SINKRONISASI ROLE AKUN',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Judul Dialog
                      const Text(
                        'Perbedaan Peran Akun',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Subtitle Penjelasan
                      const Text(
                        'Terdeteksi perbedaan antara portal yang Anda tuju dengan status peran akun terdaftar.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Kartu Komparasi Peran & Akun
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            // Badge Email Akun
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.account_circle,
                                    size: 14,
                                    color: Color(0xFF059669),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      user.email ?? 'Akun Terverifikasi',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF334155),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Baris Transisi Peran
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text(
                                          'Terdaftar Sebagai',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          registeredName,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF1E293B),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFECFDF5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 14,
                                      color: Color(0xFF059669),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFECFDF5),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: const Color(0xFFA7F3D0),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        const Text(
                                          'Portal Pilihan',
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF059669),
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          chosenName,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF047857),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Keterangan Belmawa
                      const Text(
                        'Untuk evaluasi Belmawa / Kemendikbud, Anda dapat langsung beralih portal atau memperbarui peran akun ini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Tombol 1 (Primary - Rata Tengah, Full-Width, Elegan)
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            try {
                              if (companyRes != null && companyRes['id'] != null) {
                                await Supabase.instance.client
                                    .from('companies')
                                    .update({'role': normalizedChosenRole})
                                    .eq('id', companyRes['id']);
                              } else {
                                await Supabase.instance.client
                                    .from('companies')
                                    .update({'role': normalizedChosenRole})
                                    .eq('user_id', user.id);
                              }
                              await Supabase.instance.client.auth.updateUser(
                                UserAttributes(
                                  data: {'user_role': normalizedChosenRole},
                                ),
                              );
                              if (!mounted) return;
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MainContainer(
                                    initialIndex: 0,
                                    userRole: normalizedChosenRole,
                                  ),
                                ),
                                (route) => false,
                              );
                            } catch (e) {
                              debugPrint('Error switch role: $e');
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Gagal mengubah peran: $e'),
                                    backgroundColor: const Color(0xFFDC2626),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.sync_alt_rounded, size: 17),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Perbarui Akun ke $chosenName',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Tombol 2 (Secondary - Rata Tengah, Full-Width, Elegan)
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () async {
                            Navigator.pop(ctx);
                            await Supabase.instance.client.auth.signOut();
                            if (mounted) {
                              setState(() {
                                _selectedRole = registeredRole!;
                              });
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFF8FAFC),
                            foregroundColor: const Color(0xFF334155),
                            side: const BorderSide(color: Color(0xFFCBD5E1)),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(11),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.login_rounded,
                                size: 16,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Beralih ke Portal $registeredName',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5,
                                    color: Color(0xFF334155),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Tombol Batalkan Masuk
                      TextButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await Supabase.instance.client.auth.signOut();
                        },
                        child: const Text(
                          'Batalkan Masuk',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return;
        }
      } else {
        // 3. JIKA AKUN BARU PERTAMA KALI (Misal Google Sign-In belum register):
        // Otomatis daftarkan langsung ke role yang dipilih!
        String defaultCompanyName = user.userMetadata?['company_name'] ??
            user.userMetadata?['full_name'] ??
            user.userMetadata?['name'] ??
            user.email?.split('@').first ??
            'Entitas Terdaftar';

        if (normalizedChosenRole == 'pemerintah') {
          defaultCompanyName =
              'Pengawas & Regulator Pemerintah (${user.email?.split('@').first ?? 'Kementerian'})';
        }

        try {
          // INSERT langsung tanpa onConflict 'user_id' agar tidak memicu error Postgres 42P10
          await Supabase.instance.client.from('companies').insert({
            'user_id': user.id,
            'email': user.email,
            'role': normalizedChosenRole,
            'name': defaultCompanyName,
            'siinas_id': user.userMetadata?['industry_type'] ??
                (normalizedChosenRole == 'pemerintah' ? 'Regulator' : 'Umum'),
            'location': 'Indonesia',
            'verified': true,
            'mrv_verified': true,
            'umkm_verification': true,
          });
        } catch (insertError) {
          debugPrint('Info insert company on login: $insertError');
          try {
            await Supabase.instance.client
                .from('companies')
                .update({'role': normalizedChosenRole, 'user_id': user.id})
                .eq('email', user.email!);
          } catch (_) {}
        }

        try {
          await Supabase.instance.client.auth.updateUser(
            UserAttributes(data: {'user_role': normalizedChosenRole}),
          );
        } catch (_) {}
      }

      // 4. Role COCOK & VALID! Lanjut masuk ke layout yang sesuai
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => MainContainer(
            initialIndex: 0,
            userRole: normalizedChosenRole,
          ),
        ),
        (route) => false,
      );
    } catch (e) {
      debugPrint('Error verifikasi login role: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kendala saat verifikasi akses: $e'),
            backgroundColor: const Color(0xFFDC2626),
          ),
        );
      }
    } finally {
      _isVerifyingAuth = false;
    }
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
        await _verifyRoleAndNavigate(res.user!, _selectedRole);
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
        await _verifyRoleAndNavigate(res.user!, _selectedRole);
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
                                activeColor: const Color(0xFF059669),
                              ),
                              const SizedBox(width: 4),
                              _buildCenteredRoleTab(
                                roleKey: 'pemerintah',
                                title: 'Pemerintah',
                                icon: Icons.account_balance_outlined,
                                activeColor: const Color(0xFF059669),
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
