import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  bool _obscure = true;

  bool _isLoading = false;

  Future<void> _doRegister() async {
    if (_namaCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty || _industriCtrl.text.trim().isEmpty || _passCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua field wajib diisi!')));
      return;
    }
    
    setState(() => _isLoading = true);
    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text.trim(),
        emailRedirectTo: 'saber://login-callback/',
        data: {
          'company_name': _namaCtrl.text.trim(),
          'industry_type': _industriCtrl.text.trim(),
        }
      );
      
      if (mounted) {
        if (res.session == null) {
          // Jika Supabase "Confirm Email" dinyalakan
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi sukses! Silakan cek email Anda untuk verifikasi.')));
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
        } else {
          // Jika tidak ada konfirmasi email
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainContainer()), (route) => false);
        }
      }
    } on AuthException catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: ${error.message}')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Terjadi kesalahan tidak terduga')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/img/logo.png', height: 80, errorBuilder: (_,__,___) => const Icon(Icons.factory, size: 80)),
              const SizedBox(height: 24),
              const Text('Mulai Perjalanan Hijau\nAnda', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF111827), height: 1.2)),
              const SizedBox(height: 12),
              const Text('Daftarkan perusahaan Anda untuk\nakses intelijen karbon global.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
              const SizedBox(height: 32),
              _buildTextField(label: 'Nama Perusahaan', icon: Icons.person_outline, hint: 'Jhon Doe', controller: _namaCtrl),
              const SizedBox(height: 16),
              _buildTextField(label: 'Email Perusahaan', icon: Icons.mail_outline, hint: 'nama@perusahaan.com', controller: _emailCtrl),
              const SizedBox(height: 16),
              _buildTextField(label: 'Industri', icon: Icons.factory_outlined, hint: 'Masukkan Jenis Anda', controller: _industriCtrl),
              const SizedBox(height: 16),
              _buildTextField(label: 'Kata Sandi', icon: Icons.lock_outline, hint: '........', controller: _passCtrl, isPassword: true, obscure: _obscure, onToggleObscure: () => setState(() => _obscure = !_obscure)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity, height: 50,
                child: ElevatedButton(
                  onPressed: _doRegister,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: _isLoading 
                    ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                    : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Daftar Sekarang', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 18)]),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah punya akun? ', style: TextStyle(color: Color(0xFF6B7280))),
                  GestureDetector(onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage())), child: const Text('Masuk sekarang', style: TextStyle(color: Color(0xFF006D44), fontWeight: FontWeight.bold))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({required String label, required IconData icon, required String hint, required TextEditingController controller, bool isPassword = false, bool obscure = false, VoidCallback? onToggleObscure}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4B5563), fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            prefixIcon: Icon(icon, color: const Color(0xFF9CA3AF), size: 20),
            suffixIcon: isPassword ? IconButton(icon: Icon(obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: const Color(0xFF9CA3AF), size: 20), onPressed: onToggleObscure) : null,
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF10B981))),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}
