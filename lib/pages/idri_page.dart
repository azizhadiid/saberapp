import 'package:flutter/material.dart';
import 'dart:math';

class IdriPage extends StatefulWidget {
  const IdriPage({super.key});

  @override
  State<IdriPage> createState() => _IdriPageState();
}

class _IdriPageState extends State<IdriPage> {
  final _coalCtrl = TextEditingController(text: '12,000');
  final _gasCtrl = TextEditingController(text: '50,000');
  final _elecCtrl = TextEditingController(text: '8,500');

  String _selectedTech = 'Blast Furnace';
  final List<String> _techs = ['Blast Furnace', 'EAF', 'DRI'];

  String _selectedBudget = 'Tengah (Rp 50M - 100M)';
  String _selectedEmisi = 'Min. 30%';
  String _selectedTimeline = 'Jangka Menengah (3-5 Tahun)';

  bool _showResult = false;
  int _score = 0;
  String _category = '';
  Color _color = Colors.grey;
  
  String _recTitle = '';
  String _recDesc = '';
  List<String> _recBadges = [];

  void _calculateScore() {
    // 1. Parsing input
    double coal = double.tryParse(_coalCtrl.text.replaceAll(',', '')) ?? 0;
    double gas = double.tryParse(_gasCtrl.text.replaceAll(',', '')) ?? 0;
    
    // 2. Base score dari Teknologi
    double base = 0;
    if (_selectedTech == 'Blast Furnace') base = 35;
    else if (_selectedTech == 'EAF') base = 65;
    else if (_selectedTech == 'DRI') base = 75;

    // 3. Penalti dari konsumsi kotor (simplifikasi)
    double coalPenalty = (coal / 1000) * 1.5; // Misal tiap 1000 ton ngurangi 1.5 poin
    double gasPenalty = (gas / 5000) * 1.0; 
    
    // 4. Bonus dari Budget
    double budgetBonus = 0;
    if (_selectedBudget.contains('100M+')) budgetBonus = 15;
    else if (_selectedBudget.contains('50M')) budgetBonus = 10;
    else budgetBonus = 5;

    // Hitung akhir
    double finalScore = base - coalPenalty - gasPenalty + budgetBonus;
    
    // Batasi 0 - 100
    int scoreInt = finalScore.clamp(0, 100).round();

    // 5. Penentuan Kategori & Rekomendasi (Dinamis)
    String cat;
    Color col;
    String rTitle;
    String rDesc;
    List<String> rBadges;

    if (scoreInt <= 40) {
      cat = 'Kesiapan Rendah';
      col = const Color(0xFFDC2626); // Merah
      rTitle = 'Ganti $_selectedTech ke Electric Arc Furnace (EAF)';
      rDesc = 'Kesiapan dekarbonisasi pabrik sangat rendah. Estimasi payback period: 7-10 tahun. Potensi penghematan pajak karbon hingga Rp 2.4M/tahun jika Anda beralih ke EAF secepatnya.';
      rBadges = ['+25 Poin IDRI ↑', '-40% Emisi CO2 ↓', 'Hindari Denda CBAM'];
    } else if (scoreInt <= 70) {
      cat = 'Kesiapan Sedang';
      col = const Color(0xFFD97706); // Kuning/Orange
      rTitle = 'Integrasi Energi Terbarukan & Efisiensi $_selectedTech';
      rDesc = 'Kesiapan menengah. Lakukan audit energi menyeluruh dan mulai transisi suplai listrik Anda ke panel surya (On-Grid) untuk mendongkrak skor ke zona hijau.';
      rBadges = ['+15 Poin IDRI ↑', '-25% Emisi CO2 ↓', 'Aman Pajak Sedang'];
    } else {
      cat = 'Kesiapan Tinggi';
      col = const Color(0xFF10B981); // Hijau
      rTitle = 'Optimasi Lanjut & Persiapan Hydrogen Roadmap';
      rDesc = 'Kesiapan dekarbonisasi sangat baik! Pabrik Anda sudah mendekati standar Net Zero. Pertimbangkan eksplorasi Green Hydrogen untuk menggantikan sisa gas alam.';
      rBadges = ['+5 Poin IDRI ↑', 'NZE Ready ✨', 'Premium Green Market'];
    }

    setState(() {
      _score = scoreInt;
      _category = cat;
      _color = col;
      _recTitle = rTitle;
      _recDesc = rDesc;
      _recBadges = rBadges;
      _showResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () {}),
        title: const Column(
          children: [
            Text('IDRI Calculator', style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Ukur Kesiapan Dekarbonisasi Pabrik Anda', style: TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
          ],
        ),
        actions: [IconButton(icon: const Icon(Icons.share_outlined, color: Colors.black), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Data Energi
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('DATA ENERGI AKTUAL', style: TextStyle(color: Color(0xFF4B5563), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 16),
                  _buildSimpleTextField('Coal (Ton/Thn)', '12,000', _coalCtrl),
                  const SizedBox(height: 12),
                  _buildSimpleTextField('Natural Gas (MMBtu/Thn)', '50,000', _gasCtrl),
                  const SizedBox(height: 12),
                  _buildSimpleTextField('Electricity (MWh/Thn)', '8,500', _elecCtrl),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Section 2: Teknologi Eksisting
            const Text('TEKNOLOGI EKSISTING', style: TextStyle(color: Color(0xFF4B5563), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 12),
            Row(
              children: _techs.map((tech) {
                bool isSelected = _selectedTech == tech;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: GestureDetector(
                    onTap: () => setState(() { _selectedTech = tech; _showResult = false; }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF111827) : const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(tech, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF4B5563), fontWeight: FontWeight.w600, fontSize: 13)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            
            // Section 3: Target Transisi (AI)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.circular(16), 
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.5), width: 1.5),
                boxShadow: [BoxShadow(color: const Color(0xFF10B981).withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TARGET TRANSISI (ANALISIS AI)', style: TextStyle(color: Color(0xFF4B5563), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFECFDF5), borderRadius: BorderRadius.circular(6)),
                        child: const Row(children: [Icon(Icons.auto_awesome, color: Color(0xFF10B981), size: 14), SizedBox(width: 4), Text('AI', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold))]),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField('Anggaran Transisi (CAPEX)', _selectedBudget, ['Rendah (< Rp 50M)', 'Tengah (Rp 50M - 100M)', 'Tinggi (> Rp 100M)'], (v) => setState(() => _selectedBudget = v!)),
                  const SizedBox(height: 12),
                  _buildDropdownField('Target Penurunan Emisi', _selectedEmisi, ['Min. 15%', 'Min. 30%', 'Net Zero (100%)'], (v) => setState(() => _selectedEmisi = v!)),
                  const SizedBox(height: 12),
                  _buildDropdownField('Timeline Eksekusi', _selectedTimeline, ['Jangka Pendek (1-2 Tahun)', 'Jangka Menengah (3-5 Tahun)', 'Jangka Panjang (>5 Tahun)'], (v) => setState(() => _selectedTimeline = v!)),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline, color: Color(0xFF10B981), size: 16),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('AI akan mencocokkan teknologi yang sesuai dengan kemampuan finansial perusahaan Anda.', style: TextStyle(color: Color(0xFF6B7280), fontSize: 11, height: 1.4))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Hitung Button
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: _calculateScore,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                child: const Text('Hitung Skor & Dapatkan Solusi AI ✨', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
            
            if (_showResult) ...[
              const SizedBox(height: 24),
              // Hasil Score
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
                child: Column(
                  children: [
                    const Text('IDRI SCORE', style: TextStyle(color: Color(0xFF6B7280), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 180, height: 120,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          CustomPaint(size: const Size(180, 90), painter: SemiCircleGaugePainter(percentage: _score / 100, color: _color)),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text('$_score', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: _color)),
                                  const Text(' / 100', style: TextStyle(fontSize: 14, color: Color(0xFF6B7280), fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(color: _color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: Text(_category, style: TextStyle(color: _color, fontSize: 13, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegend(const Color(0xFFDC2626), '0-40 Rendah'),
                        const SizedBox(width: 16),
                        _buildLegend(const Color(0xFFD97706), '41-70 Sedang'),
                        const SizedBox(width: 16),
                        _buildLegend(const Color(0xFF10B981), '71-100 Tinggi'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Rekomendasi AI Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F3FF), // Light purple background
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEDE9FE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFF047857), size: 18),
                        const SizedBox(width: 8),
                        const Text('Rekomendasi IDRI AI', style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.bold, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(_recTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF111827), height: 1.3)),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: _recBadges.map((badge) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(6)),
                        child: Text(badge, style: const TextStyle(color: Color(0xFF065F46), fontSize: 10, fontWeight: FontWeight.bold)),
                      )).toList(),
                    ),
                    const SizedBox(height: 16),
                    Text(_recDesc, style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13, height: 1.5)),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {}, // Idealnya lompat ke market_page
                      child: const Row(
                        children: [
                          Text('Lihat Penyedia Solusi di Green Marketplace', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, color: Color(0xFF10B981), size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 8),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
      ],
    );
  }

  Widget _buildSimpleTextField(String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFF10B981))),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String value, List<String> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFE5E7EB))),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF6B7280), size: 18),
              style: const TextStyle(fontSize: 13, color: Color(0xFF1F2937), fontWeight: FontWeight.w500),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((String val) {
                return DropdownMenuItem<String>(value: val, child: Text(val));
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class SemiCircleGaugePainter extends CustomPainter {
  final double percentage;
  final Color color;
  SemiCircleGaugePainter({required this.percentage, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    Paint bgPaint = Paint()..color = const Color(0xFFF3F4F6)..style = PaintingStyle.stroke..strokeWidth = 18..strokeCap = StrokeCap.square;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    canvas.drawArc(rect, pi, pi, false, bgPaint);

    Paint fgPaint = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 18..strokeCap = StrokeCap.square;
    canvas.drawArc(rect, pi, pi * percentage, false, fgPaint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
