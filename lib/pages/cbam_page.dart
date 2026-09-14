import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class CbamPage extends StatefulWidget {
  const CbamPage({super.key});
  @override
  State<CbamPage> createState() => _CbamPageState();
}
class _CbamPageState extends State<CbamPage> {
  final _volCtrl = TextEditingController(text: '50000');
  final _intCtrl = TextEditingController(text: '1.16');
  
  bool _showResult = false;
  
  // Logic Variables
  double _volume = 0;
  double _intensity = 0;
  final double _threshold = 0.80; // Batas wajar sesuai UU
  final double _taxRate = 45000;  // Rp 45.000 / ton denda
  
  double _excess = 0;
  double _totalTax = 0;
  double _percentage = 0;
  bool _isWarning = false;

  void _calculate() {
    setState(() {
      _volume = double.tryParse(_volCtrl.text.replaceAll(',', '').replaceAll('.', '')) ?? 0;
      _intensity = double.tryParse(_intCtrl.text.replaceAll(',', '.')) ?? 0;
      
      _excess = max(0, _intensity - _threshold);
      _isWarning = _excess > 0;
      
      // Jika melebihi batas, denda = kelebihan karbon * volume * 45000
      _totalTax = _excess * _volume * _taxRate;
      
      // Persentase Kepatuhan (100% = pas batas)
      _percentage = (_intensity / _threshold) * 100;
      _showResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp. ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () {}),
        title: const Column(
          children: [
            Text('CBAM SIMULATOR', style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.bold, fontSize: 16)),
            Text('Simulasikan Dampak CBAM pada Ekspor Anda', style: TextStyle(color: Color(0xFF6B7280), fontSize: 10)),
          ],
        ),
        actions: [IconButton(icon: const Icon(Icons.share_outlined, color: Colors.black), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('CBAM Simulator', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
            const SizedBox(height: 4),
            const Text('Export-Tax Liability Assessment', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
            const SizedBox(height: 20),
            
            // Input Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Column(
                children: [
                  _buildTextField(label: 'VOLUME EKSPOR (TON)', icon: Icons.monitor_weight_outlined, hint: '50.000', controller: _volCtrl),
                  const SizedBox(height: 16),
                  _buildTextField(label: 'INTENSITAS KARBON PABRIK (TCO2/TON)', icon: Icons.co2_outlined, hint: '1.8', controller: _intCtrl),
                  const SizedBox(height: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('NEGARA TUJUAN EKSPOR', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4B5563), fontSize: 11)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE5E7EB)), borderRadius: BorderRadius.circular(8)),
                        child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Uni Eropa (EU)', style: TextStyle(fontSize: 16, color: Color(0xFF1F2937))), Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280))]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _calculate,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('KALKULASI PAJAK', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1)), SizedBox(width: 8), Icon(Icons.calculate_outlined, size: 20)]),
              ),
            ),
            const SizedBox(height: 24),
            
            // Results Segment
            if (_showResult) ...[
              // Gauge Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Align(alignment: Alignment.centerLeft, child: Text('KEPATUHAN CBAM 2025', style: TextStyle(color: Color(0xFF4B5563), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1))),
                    const Divider(),
                    const SizedBox(height: 20),
                    // Custom Gauge
                    SizedBox(
                      width: 160, height: 160,
                      child: CustomPaint(
                        painter: GaugePainter(percentage: _percentage / 100, isWarning: _isWarning),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${_percentage.toStringAsFixed(0)}%', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _isWarning ? const Color(0xFFDC2626) : const Color(0xFF10B981))),
                              Text(_isWarning ? 'Melebihi batas UE' : 'Aman dari Pajak', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Warning/Success Box
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: _isWarning ? const Color(0xFFFEF3C7) : const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(8), border: Border.all(color: _isWarning ? const Color(0xFFFDE68A) : const Color(0xFFD1FAE5))),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(_isWarning ? Icons.warning_amber_rounded : Icons.check_circle_outline, color: _isWarning ? const Color(0xFFD97706) : const Color(0xFF10B981), size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _isWarning 
                                ? 'Peringatan: Intensitas karbon pabrik Anda melampaui ambang batas CBAM UE sebesar $_threshold tCO2/t.\nTindakan segera disarankan untuk menghindari penalti.'
                                : 'Aman! Intensitas karbon pabrik Anda berada di bawah ambang batas CBAM UE sebesar $_threshold tCO2/t. Tidak ada denda pajak ekspor.',
                              style: TextStyle(color: _isWarning ? const Color(0xFF92400E) : const Color(0xFF065F46), fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Perbandingan Intensitas Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PERBANDINGAN INTENSITAS', style: TextStyle(color: Color(0xFF4B5563), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const Divider(),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(_intensity.toStringAsFixed(2), style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                        const SizedBox(width: 8),
                        const Text('tCO2/ton', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Horizontal Bar
                    Container(
                      height: 16,
                      decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(8)),
                      clipBehavior: Clip.hardEdge,
                      child: Row(
                        children: [
                          Expanded(flex: 80, child: Container(color: const Color(0xFF111827))),
                          if (_isWarning) Expanded(flex: (_excess * 100).toInt(), child: Container(color: const Color(0xFFB91C1C))),
                          if (!_isWarning) Expanded(flex: ((_threshold - _intensity) * 100).toInt(), child: Container(color: const Color(0xFFE5E7EB))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(children: [const Icon(Icons.circle, size: 8, color: Color(0xFF111827)), const SizedBox(width: 4), Text('Batas UE ($_threshold)', style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)))]),
                        if (_isWarning) Row(children: [const Icon(Icons.circle, size: 8, color: Color(0xFFB91C1C)), const SizedBox(width: 4), Text('Kelebihan (${_excess.toStringAsFixed(2)})', style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280)))]),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Denda Pajak Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Align(alignment: Alignment.centerLeft, child: Text('DENDA PINALTI PAJAK', style: TextStyle(color: Color(0xFF4B5563), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1))),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      _isWarning ? currencyFormatter.format(_totalTax) : 'Rp. 0',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _isWarning ? const Color(0xFFB91C1C) : const Color(0xFF10B981)),
                    ),
                    const SizedBox(height: 4),
                    const Text('Proyeksi biaya tahunan sebesar\nRp. 45.000/ton CO2e', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    const SizedBox(height: 20),
                    if (_isWarning) CustomPaint(size: const Size(double.infinity, 60), painter: LineChartPainter()),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text('TINDAKAN CEPAT', style: TextStyle(color: Color(0xFF4B5563), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity, height: 60,
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFE5E7EB)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.description, color: Color(0xFF006D44), size: 20), SizedBox(height: 4), Text('Buat Laporan', style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.bold, fontSize: 12))],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Sesuaikan Variabel', style: TextStyle(color: Color(0xFF4B5563), fontWeight: FontWeight.w600, fontSize: 12)),
                  Text('Lihat Riwayat', style: TextStyle(color: Color(0xFF4B5563), fontWeight: FontWeight.w600, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 100),
            ]
          ],
        ),
      ),
    );
  }
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
        keyboardType: label.contains('TCO2') || label.contains('TON') ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
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

class GaugePainter extends CustomPainter {
  final double percentage;
  final bool isWarning;
  GaugePainter({required this.percentage, required this.isWarning});

  @override
  void paint(Canvas canvas, Size size) {
    Paint bgPaint = Paint()..color = const Color(0xFFF3F4F6)..style = PaintingStyle.stroke..strokeWidth = 16..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromLTWH(0, 0, size.width, size.height), pi * 0.75, pi * 1.5, false, bgPaint);

    final sweepAngle = (percentage > 2.0 ? 2.0 : percentage) * (pi * 1.5); // Max cap for visual
    List<Color> colors = isWarning ? [const Color(0xFF10B981), const Color(0xFFF59E0B), const Color(0xFFDC2626)] : [const Color(0xFF10B981), const Color(0xFF34D399)];
    Paint fgPaint = Paint()..shader = SweepGradient(colors: colors, startAngle: pi * 0.75, endAngle: pi * 2.25).createShader(Rect.fromLTWH(0, 0, size.width, size.height))..style = PaintingStyle.stroke..strokeWidth = 16..strokeCap = StrokeCap.round;

    canvas.drawArc(Rect.fromLTWH(0, 0, size.width, size.height), pi * 0.75, sweepAngle, false, fgPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint linePaint = Paint()..color = const Color(0xFFB91C1C)..strokeWidth = 3..style = PaintingStyle.stroke;
    Paint dotPaint = Paint()..color = const Color(0xFFB91C1C)..style = PaintingStyle.fill;
    
    Path path = Path();
    List<Offset> points = [
      Offset(0, size.height), Offset(size.width * 0.2, size.height * 0.95), Offset(size.width * 0.4, size.height * 0.7),
      Offset(size.width * 0.6, size.height * 0.5), Offset(size.width * 0.8, size.height * 0.25), Offset(size.width, 0),
    ];
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) { path.lineTo(points[i].dx, points[i].dy); }
    canvas.drawPath(path, linePaint);
    for (var point in points) { canvas.drawCircle(point, 4, dotPaint); }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
