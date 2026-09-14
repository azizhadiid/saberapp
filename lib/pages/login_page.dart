import 'package:flutter/material.dart';
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

  void _doLogin() {
    if (_emailCtrl.text.trim().isEmpty || _passCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Form tidak boleh kosong!')));
      return;
    }
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainContainer()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: Image.network('https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?q=80&w=2070&auto=format&fit=crop', fit: BoxFit.cover, color: Colors.grey, colorBlendMode: BlendMode.saturation),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))]),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset('assets/img/logo.png', height: 80, errorBuilder: (_,__,___) => const Icon(Icons.factory, size: 80)),
                      const SizedBox(height: 24),
                      const Text('Selamat Datang Kembali', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                      const SizedBox(height: 8),
                      const Text('Masuk untuk mengelola dekarbonisasi\nindustri Anda', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                      const SizedBox(height: 32),
                      _buildTextField(label: 'Email Perusahaan', icon: Icons.mail_outline, hint: 'nama@perusahaan.com', controller: _emailCtrl),
                      const SizedBox(height: 16),
                      _buildTextField(label: 'Kata Sandi', icon: Icons.lock_outline, hint: '........', controller: _passCtrl, isPassword: true, obscure: _obscure, onToggleObscure: () => setState(() => _obscure = !_obscure), rightLabel: 'Lupa Kata Sandi?'),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton(
                          onPressed: _doLogin,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Masuk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), SizedBox(width: 8), Icon(Icons.arrow_forward, size: 18)]),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Belum punya akun? ', style: TextStyle(color: Color(0xFF6B7280))),
                          GestureDetector(onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegisterPage())), child: const Text('Daftar sekarang', style: TextStyle(color: Color(0xFF006D44), fontWeight: FontWeight.bold))),
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

  Widget _buildTextField({required String label, required IconData icon, required String hint, required TextEditingController controller, bool isPassword = false, bool obscure = false, VoidCallback? onToggleObscure, String? rightLabel}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4B5563), fontSize: 13)),
            if (rightLabel != null) Text(rightLabel, style: const TextStyle(color: Color(0xFF006D44), fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
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
