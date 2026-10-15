import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class IdriPage extends StatefulWidget {
  const IdriPage({super.key});

  @override
  State<IdriPage> createState() => _IdriPageState();
}

class _IdriPageState extends State<IdriPage> {
  final _coalCtrl = TextEditingController(text: '12,000');
  final _gasCtrl = TextEditingController(text: '50,000');
  final _elecCtrl = TextEditingController(text: '8,500');

  String _selectedTech = 'Blast Furnace (BF-BOF)';
  final List<String> _techs = [
    'Blast Furnace (BF-BOF)',
    'Induction Furnace (IF)',
    'Electric Arc Furnace (EAF)',
    'Submerged Arc Furnace (SAF)',
    'Direct Reduced Iron (DRI)',
  ];

  String _selectedBudget = 'Tengah (Rp 50M - 100M)';
  String _selectedEmisi = 'Min. 30%';
  String _selectedTimeline = 'Jangka Menengah (3-5 Tahun)';

  String _selectedSdg = 'SDG 13: Climate Action (Aksi Iklim)';
  final List<String> _sdgList = [
    'SDG 13: Climate Action (Aksi Iklim)',
    'SDG 9: Industry & Innovation (Infrastruktur & Mesin Hijau)',
    'SDG 3: Good Health & Well-being (Kesehatan Buruh & Emisi Debu)',
    'SDG 4: Quality Education (Green Reskilling Buruh Pabrik)',
  ];

  bool _showResult = false;
  bool _isLoading = false;
  int _score = 0;
  String _category = '';
  Color _color = Colors.grey;

  String _recTitle = '';
  String _techAssessment = '';
  String _recDesc = '';
  String _sdgImpact = '';
  List<String> _recBadges = [];

  Future<void> _calculateScore() async {
    setState(() {
      _isLoading = true;
      _showResult = false;
    });

    try {
      // 1. Ambil nilai input
      double coal = double.tryParse(_coalCtrl.text.replaceAll(',', '')) ?? 0;
      double gas = double.tryParse(_gasCtrl.text.replaceAll(',', '')) ?? 0;
      double elec = double.tryParse(_elecCtrl.text.replaceAll(',', '')) ?? 0;

      // 2. PERHITUNGAN REALISTIS (FORMULA NYATA)
      // Faktor Emisi Rata-Rata (kg CO2e per satuan):
      // Batu Bara: ~2.86 kg CO2e / kg
      // Gas Alam: ~2.02 kg CO2e / m3 (Asumsi 1 MMBtu ~ 28.26 m3) -> ~57 kg CO2e / MMBtu
      // Listrik Grid Indonesia: ~0.87 kg CO2e / kWh -> 870 kg CO2e / MWh
      double coalEmission = coal * 2860; // ton CO2e
      double gasEmission = gas * 0.057; // ton CO2e
      double elecEmission = elec * 0.87; // ton CO2e

      double totalEmission = coalEmission + gasEmission + elecEmission;

      // Base score berdasarkan Teknologi Eksisting
      double base = 35;
      if (_selectedTech.contains('Blast Furnace')) {
        base = 35;
      } else if (_selectedTech.contains('Induction Furnace')) {
        base = 45;
      } else if (_selectedTech.contains('Submerged Arc')) {
        base = 55;
      } else if (_selectedTech.contains('EAF')) {
        base = 65;
      } else if (_selectedTech.contains('DRI')) {
        base = 75;
      }

      // Logika Formula IDRI (Penalti dan Bonus Nyata)
      // Asumsi batas intensitas industri baja = 1.8 ton CO2e per ton baja.
      // Kita asumsikan produksi rata-rata pabrik adalah 500,000 ton baja/tahun.
      double assumedProduction = 500000;
      double currentIntensity = totalEmission / assumedProduction;

      // Penalti jika intensitas > 1.8
      double intensityPenalty = max(0, (currentIntensity - 1.8) * 10);

      double budgetBonus = 0;
      if (_selectedBudget.contains('100M+'))
        budgetBonus = 15;
      else if (_selectedBudget.contains('50M'))
        budgetBonus = 10;
      else
        budgetBonus = 5;

      double finalScore = base - intensityPenalty + budgetBonus;
      int scoreInt = finalScore.clamp(0, 100).round();

      // Penentuan Kategori & Warna Awal
      String cat = '';
      Color col = Colors.grey;
      if (scoreInt <= 40) {
        cat = 'Kesiapan Rendah';
        col = const Color(0xFFDC2626); // Merah
      } else if (scoreInt <= 70) {
        cat = 'Kesiapan Sedang';
        col = const Color(0xFFD97706); // Kuning
      } else {
        cat = 'Kesiapan Tinggi';
        col = const Color(0xFF10B981); // Hijau
      }

      // 3. Panggil API GEMINI untuk menghasilkan Rekomendasi Terpersonalisasi
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw Exception('GEMINI_API_KEY tidak ditemukan di file .env');
      }

      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          responseMimeType: 'application/json',
          temperature: 0.85, // Dinamis, bervariasi secara cerdas
        ),
      );

      final prompt = '''
Kamu adalah Konsultan Senior Dekarbonisasi Industri Baja & Auditor SDGs Nasional. Berikan analisis dan rekomendasi teknis yang SANGAT DETAIL, CERDAS, dan MENDALAM untuk pabrik baja ini.

PROFIL PABRIK:
- Teknologi Eksisting: $_selectedTech
- Konsumsi Energi Aktual: Batu Bara $coal Ton/Tahun, Gas Alam $gas MMBtu/Tahun, Listrik $elec MWh/Tahun.
- Total Emisi Karbon: ${totalEmission.toStringAsFixed(0)} ton CO2e/Tahun
- Target Penurunan Emisi: $_selectedEmisi dalam $_selectedTimeline
- Anggaran Transisi (CAPEX): $_selectedBudget
- Target Prioritas SDGs: $_selectedSdg
- Skor Kesiapan IDRI: $scoreInt / 100 ($cat)

INSTRUKSI WAJIB:
1. Rekomendasi HARUS mengawinkan secara erat antara teknologi eksisting ($_selectedTech) dengan fokus prioritas SDGs ($_selectedSdg) serta data energi input aktual.
2. Jelaskan evaluasi teknis spesifik inefisiensi mesin eksisting terhadap energi yang diinput.
3. Berikan kalimat yang elegan, analitis, bervariasi (tidak kaku), namun padat dan hemat token tanpa pembuka/penutup basa-basi.

Kembalikan format JSON murni:
{
  "recTitle": "Judul Aksi Rekomendasi (5-8 kata, menyebutkan teknologi dan target)",
  "techAssessment": "Evaluasi teknis 2-3 kalimat mengenai inefisiensi spesifik dari $_selectedTech berdasarkan konsumsi energi saat ini ($coal ton batu bara, $gas MMBtu gas, $elec MWh listrik).",
  "recDesc": "Rencana aksi transformasi teknis 4-6 kalimat yang sangat mendalam: teknologi pengganti/retrofit yang dipilih, alasan kecocokan dengan anggaran $_selectedBudget, strategi penurunan emisi $_selectedEmisi, dan estimasi ROI/Payback Period dalam $_selectedTimeline.",
  "recBadges": ["Badge 1 (Mis: -45% Emisi)", "Badge 2 (Mis: Payback 3.8 Thn)", "Badge 3 (Mis: K3 Standard)"],
  "sdgImpact": "Penjelasan analitis 3-4 kalimat bagaimana langkah ini secara nyata dan terukur merealisasikan $_selectedSdg di lapangan pabrik baja."
}
''';

      Map<String, dynamic> aiResult;
      try {
        final response = await model.generateContent([Content.text(prompt)]);
        final jsonText = response.text?.trim() ?? '{}';
        aiResult = jsonDecode(jsonText);
      } catch (apiError) {
        print('Gemini API Error / Offline: $apiError. Menggunakan generator matriks cerdas.');
        aiResult = _generateDynamicFallback(coal, gas, elec, totalEmission, scoreInt);
      }

      setState(() {
        _score = scoreInt;
        _category = cat;
        _color = col;
        _recTitle = aiResult['recTitle'] ?? 'Rekomendasi Optimalisasi Hijau';
        _techAssessment = aiResult['techAssessment'] ?? 'Evaluasi operasional sistem energi pabrik.';
        _recDesc = aiResult['recDesc'] ?? 'Tingkatkan efisiensi energi Anda.';
        _sdgImpact = aiResult['sdgImpact'] ?? 'Mendukung target pembangunan berkelanjutan.';
        List<dynamic> badges = aiResult['recBadges'] ?? [];
        _recBadges = badges.map((e) => e.toString()).toList();
        _showResult = true;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sistem Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Map<String, dynamic> _generateDynamicFallback(
    double coal,
    double gas,
    double elec,
    double totalEmission,
    int scoreInt,
  ) {
    final rand = Random();
    final v = rand.nextInt(3);

    String prefixAssessment = [
      "Audit neraca termal & emisi mengindikasikan bahwa ",
      "Berdasarkan tinjauan intensitas emisi operasional, ",
      "Evaluasi sistem pembakaran dan konsumsi daya menunjukkan bahwa ",
    ][v];

    String prefixAction = [
      "Sebagai langkah mitigasi terukur, ",
      "Strategi dekarbonisasi prioritas yang direkomendasikan adalah ",
      "Guna mengoptimalkan efisiensi transisi, ",
    ][v];

    String title = "";
    String assessment = "";
    String desc = "";
    List<String> badges = [];
    String sdgImpact = "";

    // 1. BLAST FURNACE (BF-BOF)
    if (_selectedTech.contains('Blast Furnace')) {
      assessment = "$prefixAssessment penggunaan Blast Furnace dengan konsumsi $coal ton batu bara menghasilkan emisi langsung Scope 1 yang masif (${totalEmission.toStringAsFixed(0)} ton CO2e/thn) serta debu partikulat tinggi.";
      if (_selectedSdg.contains('SDG 13')) {
        title = "Konversi Scrap-EAF & PLTS Atap (SDG 13)";
        desc = "$prefixAction alokasi modal $_selectedBudget difokuskan untuk mengganti rute pembakaran batu bara menjadi Electric Arc Furnace (EAF) berbasis scrap baja daur ulang yang disuplai energi surya. Langkah ini memangkas emisi hingga $_selectedEmisi dalam jangka waktu $_selectedTimeline dengan estimasi ROI 4.2 tahun.";
        badges = ["-50% Emisi Scope 1", "Payback 4.2 Thn", "Aman Sanksi CBAM"];
        sdgImpact = "Menjawab target SDG 13 (Climate Action): melenyapkan ketergantungan pada kokas batu bara fosil, menurunkan jejak karbon produk baja di bawah 0.8 ton CO2/t baja, dan menghindarkan tarif denda pajak ekspor Uni Eropa.";
      } else if (_selectedSdg.contains('SDG 9')) {
        title = "Modernisasi Rute DRI-EAF & WHR (SDG 9)";
        desc = "$prefixAction fasilitas Blast Furnace diretrofit bertahap menjadi Direct Reduced Iron (DRI) berbahan bakar gas alam ($gas MMBtu) yang terintegrasi Waste Heat Recovery. Anggaran $_selectedBudget dialokasikan untuk otomasi mesin peleburan dalam tempo $_selectedTimeline.";
        badges = ["Efisiensi Mesin +38%", "Modernisasi Industri", "Hemat Gas 25%"];
        sdgImpact = "Mewujudkan SDG 9 (Industry, Innovation & Infrastructure): mentransformasi fasilitas logam dasar nasional menjadi sentra industri ramah lingkungan berteknologi tinggi yang berdaya saing global.";
      } else if (_selectedSdg.contains('SDG 3')) {
        title = "Instalasi Wet Scrubber & Pemusnahan Debu (SDG 3)";
        desc = "$prefixAction pemasangan sistem filtrasi Wet Scrubber bertingkat dan Electrostatic Precipitator (ESP) pada cerobong Blast Furnace. Teknologi ini secara instan menyerap 95% partikulat debu halus (PM2.5) dan gas sulfur dari pembakaran batu bara dalam jangka waktu $_selectedTimeline memanfaatkan anggaran $_selectedBudget.";
        badges = ["-95% Polusi Debu", "Standar K3 Higienis", "Bebas Sanksi Lingkungan"];
        sdgImpact = "Memenuhi SDG 3 (Good Health & Well-being): menekan angka penyakit infeksi saluran pernapasan (ISPA) bagi ribuan pekerja tungku serta memulihkan kualitas udara bersih pemukiman lingkar pabrik.";
      } else {
        title = "Green Reskilling Academy Buruh Baja (SDG 4)";
        desc = "$prefixAction porsi anggaran $_selectedBudget dialokasikan untuk mendirikan pusat diklat vokasi industri. Ratusan operator tungku batubara konvensional dilatih ulang menguasai kontrol digital EAF dan panel surya dalam rentang $_selectedTimeline tanpa ada pemutusan hubungan kerja (PHK).";
        badges = ["Just Transition (0 PHK)", "Sertifikasi Hijau", "Peningkatan Skill"];
        sdgImpact = "Selaras dengan SDG 4 (Quality Education): memastikan transisi industri baja berjalan inklusif dan berkeadilan melalui peningkatan keahlian vokasi hijau bagi tenaga kerja lokal.";
      }
    }
    // 2. INDUCTION FURNACE (IF)
    else if (_selectedTech.contains('Induction Furnace')) {
      assessment = "$prefixAssessment Induction Furnace mengonsumsi daya listrik tinggi sebesar $elec MWh/tahun dengan emisi slag dan kehilangan energi termal signifikan pada lantai produksi.";
      if (_selectedSdg.contains('SDG 13')) {
        title = "Upgrade EAF Berdaya Efisien & PPA Surya (SDG 13)";
        desc = "$prefixAction mengganti unit induksi berdaya boros dengan Electric Arc Furnace generasi terbaru yang dilengkapi Power Factor Controller dan kontrak listrik hijau (REC/PLTS). Menekan emisi kelistrikan Scope 2 hingga $_selectedEmisi dalam $_selectedTimeline menggunakan anggaran $_selectedBudget.";
        badges = ["-40% Daya Listrik", "Efisiensi Termal +30%", "Scope 2 Reduced"];
        sdgImpact = "Mendorong pencapaian SDG 13 (Climate Action): mereduksi intensitas karbon tak langsung dari bauran listrik batu bara nasional pada rantai pasok industri baja sekunder.";
      } else if (_selectedSdg.contains('SDG 9')) {
        title = "Digitalisasi Daya & Otomasi Tungku (SDG 9)";
        desc = "$prefixAction modernisasi panel Thyristor dan instalasi sistem sensor prediktif berbasis IoT pada tungku induksi. Menstabilkan tegangan suplai $elec MWh dan mengoptimalkan siklus peleburan dengan plafon modal $_selectedBudget dalam rentang $_selectedTimeline.";
        badges = ["Otomasi Industri", "Monitoring IoT", "Kapasitas +25%"];
        sdgImpact = "Merealisasikan SDG 9 (Industry & Innovation): meningkatkan kapabilitas teknologi manufaktur baja lokal menuju standar industri 4.0 yang tangguh dan adaptif.";
      } else if (_selectedSdg.contains('SDG 3')) {
        title = "Fume Extraction Hood & Filtrasi Asap (SDG 3)";
        desc = "$prefixAction memasang tudung hisap asap (Fume Extraction Hood) bertekanan negatif tepat di atas bibir tungku induksi. Menghisap aerosol oksida logam beracun sebelum terhirup buruh, dibiayai anggaran $_selectedBudget dalam $_selectedTimeline.";
        badges = ["Proteksi K3 Paru", "Udara Ruang Bersih", "Zero Fume Workplace"];
        sdgImpact = "Menegakkan target SDG 3 (Kesehatan): melindungi kesehatan paru-paru buruh dari paparan asap timbal dan silika beracun, menjamin lingkungan kerja yang higienis.";
      } else {
        title = "Pelatihan Metalurgi & Efisiensi Energi (SDG 4)";
        desc = "$prefixAction menyelenggarakan pelatihan intensif pengendalian mutu scrap dan teknik peleburan presisi bagi teknisi induksi. Meningkatkan yield recovery logam dan menghemat konsumsi $elec MWh, didukung modal $_selectedBudget dalam $_selectedTimeline.";
        badges = ["Pendidikan Vokasi", "SDM Kompeten", "Efisiensi Material"];
        sdgImpact = "Mendukung SDG 4 (Pendidikan Berkualitas): memperluas akses pelatihan teknis profesional bagi teknisi lapangan agar mampu menerapkan kaidah metalurgi modern.";
      }
    }
    // 3. ELECTRIC ARC FURNACE (EAF)
    else if (_selectedTech.contains('EAF')) {
      assessment = "$prefixAssessment fasilitas EAF Anda sudah berada di jalur transisi rendah emisi, namun ketergantungan pada listrik $elec MWh masih menyisakan jejak karbon tidak langsung dari grid PLN.";
      if (_selectedSdg.contains('SDG 13')) {
        title = "Penyediaan Listrik 100% EBT & Scrap Hijau (SDG 13)";
        desc = "$prefixAction mengalihkan pasokan daya $elec MWh ke tarif energi terbarukan (PLTS Atap/PPA) dan memperketat bahan baku 100% scrap baja lokal terstandar. Target reduksi emisi $_selectedEmisi akan terlampaui dalam $_selectedTimeline dengan efisiensi biaya operasional tinggi dari modal $_selectedBudget.";
        badges = ["Green Steel Certified", "<0.6 tCO2/t Baja", "Zero CBAM Tax"];
        sdgImpact = "Puncak SDG 13 (Aksi Iklim): menghasilkan 'Baja Hijau Rendah Karbon' berstandar internasional yang siap bersaing di pasar ekspor tanpa ancaman sanksi lingkungan.";
      } else if (_selectedSdg.contains('SDG 9')) {
        title = "Retrofit Consteel & Oxy-Fuel Burner (SDG 9)";
        desc = "$prefixAction pemasangan sistem pengumpanan scrap kontinu (Consteel) yang memanfaatkan panas gas buang 1.200°C untuk memanaskan bahan baku, dipadu injeksi Oxy-Fuel presisi. Menurunkan konsumsi daya listrik dalam $_selectedTimeline memanfaatkan investasi $_selectedBudget.";
        badges = ["Sirkular Termal", "Inovasi Deep-Tech", "Yield Baja +8%"];
        sdgImpact = "Memenuhi SDG 9 (Inovasi & Infrastruktur): menghadirkan arsitektur manufaktur sirkular yang memaksimalkan daur ulang termal dan material secara berkelanjutan.";
      } else if (_selectedSdg.contains('SDG 3')) {
        title = "Acoustic Enclosure & Proteksi Bising EAF (SDG 3)";
        desc = "$prefixAction membangun Dog-house Enclosure kedap suara di sekeliling tungku EAF untuk meredam polusi kebisingan ekstrem dari 115 dB ke batas aman di bawah 80 dB. Dilengkapi penyaring partikulat emisi busur listrik dalam $_selectedTimeline dengan anggaran $_selectedBudget.";
        badges = ["Reduksi Bising -35dB", "Kesehatan Saraf Buruh", "K3 Aman"];
        sdgImpact = "Menjawab SDG 3 (Kesehatan Kerja): mencegah risiko ketulian permanen dan gangguan saraf akustik akibat ledakan busur listrik bagi pekerja ruang peleburan.";
      } else {
        title = "Sertifikasi Green Metallurgy Operator (SDG 4)";
        desc = "$prefixAction pelatihan sertifikasi internasional untuk operator EAF mengenai metalurgi sekunder ramah lingkungan dan pemanfaatan sistem kecerdasan buatan dalam optimalisasi elektroda, didanai anggaran transisi $_selectedBudget dalam $_selectedTimeline.";
        badges = ["Standar Global ISO", "Pelatihan SDM Hijau", "Keahlian AI"];
        sdgImpact = "Mendukung SDG 4: membina tenaga ahli teknik baja nasional berwawasan dekarbonisasi yang siap menjadi motor penggerak industri hijau masa depan.";
      }
    }
    // 4. SUBMERGED ARC FURNACE (SAF)
    else if (_selectedTech.contains('Submerged Arc')) {
      assessment = "$prefixAssessment Submerged Arc Furnace memiliki intensitas daya listrik ekstrem ($elec MWh) serta membakar $coal ton batubara reduktor untuk peleburan ferro-alloy dan paduan baja.";
      if (_selectedSdg.contains('SDG 13')) {
        title = "Substitusi Biochar & Captive Clean Power (SDG 13)";
        desc = "$prefixAction substitusi 30-50% batu bara reduktor menggunakan biochar biomassa limbah cangkang sawit, dipadukan pembangunan pembangkit listrik tenaga surya internal. Memangkas emisi $_selectedEmisi dalam $_selectedTimeline dengan alokasi modal $_selectedBudget.";
        badges = ["Substitusi Biomassa", "Emisi Turun 35%", "Hilirisasi Hijau"];
        sdgImpact = "Memperkuat SDG 13 (Climate Action): mendekarbonisasi sektor hilirisasi mineral dan baja paduan strategis tanpa mengorbankan output produksi nasional.";
      } else if (_selectedSdg.contains('SDG 9')) {
        title = "Waste Heat to Power (WHTP) Generator SAF (SDG 9)";
        desc = "$prefixAction pemasangan unit turbin uap siklus Rankine organik untuk menangkap panas gas buang bersuhu tinggi dari SAF, menghasilkan kembali listrik 15 MW untuk menyubsidi kebutuhan $elec MWh dengan investasi $_selectedBudget dalam tempo $_selectedTimeline.";
        badges = ["Self-Generated Power", "Infrastruktur Mandiri", "Hemat OPEX"];
        sdgImpact = "Menopang SDG 9 (Industri & Inovasi): mentransformasi limbah energi termal menjadi daya listrik mandiri (cogeneration) guna meningkatkan ketahanan pasokan pabrik.";
      } else if (_selectedSdg.contains('SDG 3')) {
        title = "Evakuasi Gas Karbon Monoksida Otomatis (SDG 3)";
        desc = "$prefixAction instalasi sistem detektor gas beracun CO/SO2 nirkabel otomatis dan tudung penyedot cerobong tertutup untuk mencegah akumulasi gas fatal di area tungku SAF, direalisasikan dalam anggaran $_selectedBudget pada tempo $_selectedTimeline.";
        badges = ["Zero Gas Poisoning", "Sensor Otomatis", "Proteksi Nyawa"];
        sdgImpact = "Mewujudkan SDG 3 (Kesehatan Kerja): meniadakan risiko keracunan gas monoksida mematikan dan menjamin keselamatan mutlak bagi buruh lantai lebur smelter.";
      } else {
        title = "Pusat Pelatihan K3 & Metalurgi Smelter (SDG 4)";
        desc = "$prefixAction program vokasi terpadu bagi pemuda lokal lingkar smelter dalam penanganan keselamatan kerja suhu ekstrem dan pengendalian komposisi ferroalloy, didanai dari porsi CSR/CAPEX $_selectedBudget dalam $_selectedTimeline.";
        badges = ["Pemberdayaan Pemuda", "Skill Smelter Unggul", "Pendidikan Merata"];
        sdgImpact = "Mengisi SDG 4: mencetak tenaga kerja lokal yang mahir dan bersertifikasi di sektor hilirisasi mineral logam dasar Indonesia.";
      }
    }
    // 5. DIRECT REDUCED IRON (DRI)
    else {
      assessment = "$prefixAssessment reaktor DRI saat ini mengonsumsi $gas MMBtu gas alam dengan efisiensi tinggi, merupakan platform paling matang untuk transisi mutlak ke hidrogen hijau.";
      if (_selectedSdg.contains('SDG 13')) {
        title = "Injeksi 100% Green Hydrogen Skala Penuh (SDG 13)";
        desc = "$prefixAction substitusi bertahap gas alam dengan Green Hydrogen murni yang diproduksi dari elektroliser air bertenaga EBT. Menghilangkan emisi reaksi kimia secara tuntas menuju target Net Zero 100% dalam rentang waktu $_selectedTimeline didanai modal $_selectedBudget.";
        badges = ["Net Zero Pioneer", "Zero Fossil Fuel", "Standar Ekspor Tertinggi"];
        sdgImpact = "Puncak SDG 13 (Climate Action): menjadikan pabrik ini pionir baja bebas emisi (Zero Carbon Steel) pertama di Asia Tenggara, melampaui seluruh regulasi batas emisi dunia.";
      } else if (_selectedSdg.contains('SDG 9')) {
        title = "Integrasi Modul DRI Hidrogen & Reaktor CCUS (SDG 9)";
        desc = "$prefixAction pemasangan unit Carbon Capture, Utilization, and Storage (CCUS) untuk menangkap sisa gas alam $gas MMBtu sekaligus persiapan modul reaktor DRI berbahan bakar multi-gas (H2 ready), diwujudkan melalui anggaran $_selectedBudget dalam $_selectedTimeline.";
        badges = ["Deep-Tech Pioneer", "Teknologi H2 Ready", "Infrastruktur Masa Depan"];
        sdgImpact = "Merealisasikan SDG 9 (Inovasi Industri): menempatkan industri manufaktur nasional sebagai pusat keunggulan rekayasa proses teknologi hidrogen dan CCUS mutakhir.";
      } else if (_selectedSdg.contains('SDG 3')) {
        title = "Deteksi Nirkabel Tekanan Tinggi & Ventilasi H2 (SDG 3)";
        desc = "$prefixAction penerapan sistem instrumentasi keselamatan tingkat tinggi (Safety Instrumented System - SIL 3) untuk memantau integritas bejana reaktor gas reduksi dan mitigasi kebocoran, dibiayai anggaran $_selectedBudget dalam tempo $_selectedTimeline.";
        badges = ["Standar SIL-3", "Keamanan Reaktor", "Lingkungan Nir-Bahaya"];
        sdgImpact = "Menjamin SDG 3: menciptakan iklim operasional nir-bahaya di fasilitas berteknologi gas tertekanan tinggi bagi seluruh teknisi dan masyarakat sekitar.";
      } else {
        title = "Beasiswa Riset & Rekayasa Hijau Nasional (SDG 4)";
        desc = "$prefixAction program kerjasama transfer teknologi dan magang riset dengan universitas riset nasional untuk mencetak peneliti dan insinyur baja hidrogen generasi mendatang, dibiayai porsi modal $_selectedBudget dalam rentang $_selectedTimeline.";
        badges = ["Kemitraan Kampus", "Riset Berkelanjutan", "SDM Unggul"];
        sdgImpact = "Mendorong SDG 4 (Pendidikan Berkualitas): memperkuat kolaborasi riset industri-kampus demi melahirkan talenta sains dan teknologi energi masa depan Indonesia.";
      }
    }

    return {
      "recTitle": title,
      "techAssessment": assessment,
      "recDesc": desc,
      "recBadges": badges,
      "sdgImpact": sdgImpact,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {},
        ),
        title: const Column(
          children: [
            Text(
              'IDRI Calculator',
              style: TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Ukur Kesiapan Dekarbonisasi Pabrik Anda',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Data Energi
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DATA ENERGI AKTUAL',
                    style: TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSimpleTextField('Coal (Ton/Thn)', '12,000', _coalCtrl),
                  const SizedBox(height: 12),
                  _buildSimpleTextField(
                    'Natural Gas (MMBtu/Thn)',
                    '50,000',
                    _gasCtrl,
                  ),
                  const SizedBox(height: 12),
                  _buildSimpleTextField(
                    'Electricity (MWh/Thn)',
                    '8,500',
                    _elecCtrl,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Teknologi Eksisting
            const Text(
              'TEKNOLOGI EKSISTING',
              style: TextStyle(
                color: Color(0xFF4B5563),
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _techs.map((tech) {
                bool isSelected = _selectedTech == tech;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedTech = tech;
                    _showResult = false;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF111827)
                          : const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF111827)
                            : const Color(0xFFE0E7FF),
                      ),
                    ),
                    child: Text(
                      tech,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF4B5563),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
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
                border: Border.all(
                  color: const Color(0xFF10B981).withOpacity(0.5),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF10B981).withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TARGET TRANSISI (ANALISIS AI)',
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              color: Color(0xFF10B981),
                              size: 14,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'AI',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    'Anggaran Transisi (CAPEX)',
                    _selectedBudget,
                    [
                      'Rendah (< Rp 50M)',
                      'Tengah (Rp 50M - 100M)',
                      'Tinggi (> Rp 100M)',
                    ],
                    (v) => setState(() => _selectedBudget = v!),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    'Target Penurunan Emisi',
                    _selectedEmisi,
                    ['Min. 15%', 'Min. 30%', 'Net Zero (100%)'],
                    (v) => setState(() => _selectedEmisi = v!),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    'Timeline Eksekusi',
                    _selectedTimeline,
                    [
                      'Jangka Pendek (1-2 Tahun)',
                      'Jangka Menengah (3-5 Tahun)',
                      'Jangka Panjang (>5 Tahun)',
                    ],
                    (v) => setState(() => _selectedTimeline = v!),
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    'Fokus Prioritas SDGs Perusahaan',
                    _selectedSdg,
                    _sdgList,
                    (v) => setState(() {
                      _selectedSdg = v!;
                      _showResult = false;
                    }),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Color(0xFF10B981),
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'AI akan mencocokkan teknologi yang sesuai dengan kemampuan finansial perusahaan Anda.',
                          style: TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 11,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Hitung Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _calculateScore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Hitung Skor & Dapatkan Solusi AI ✨',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),

            if (_showResult) ...[
              const SizedBox(height: 24),
              // Hasil Score
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'IDRI SCORE',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 180,
                      height: 120,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0, end: _score / 100),
                            duration: const Duration(seconds: 2),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return CustomPaint(
                                size: const Size(180, 90),
                                painter: SemiCircleGaugePainter(
                                  percentage: value,
                                  color: _color,
                                ),
                              );
                            },
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  TweenAnimationBuilder<int>(
                                    tween: IntTween(begin: 0, end: _score),
                                    duration: const Duration(seconds: 2),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, value, child) {
                                      return Text(
                                        '$value',
                                        style: TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.w900,
                                          color: _color,
                                        ),
                                      );
                                    },
                                  ),
                                  const Text(
                                    ' / 100',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6B7280),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _category,
                        style: TextStyle(
                          color: _color,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                    const Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: Color(0xFF047857),
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Rekomendasi IDRI AI',
                          style: TextStyle(
                            color: Color(0xFF111827),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _recTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF111827),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _recBadges
                          .map(
                            (badge) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1FAE5),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                badge,
                                style: const TextStyle(
                                  color: Color(0xFF065F46),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                    if (_techAssessment.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.analytics_outlined,
                              color: Color(0xFFD97706),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _techAssessment,
                                style: const TextStyle(
                                  color: Color(0xFF92400E),
                                  fontSize: 12,
                                  height: 1.45,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      _recDesc,
                      style: const TextStyle(
                        color: Color(0xFF4B5563),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    if (_sdgImpact.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(
                                    Icons.public,
                                    color: Color(0xFF047857),
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Penyelarasan $_selectedSdg',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Color(0xFF065F46),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _sdgImpact,
                              style: const TextStyle(
                                color: Color(0xFF374151),
                                fontSize: 12,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {}, // Idealnya lompat ke market_page
                      child: const Row(
                        children: [
                          Text(
                            'Lihat Penyedia Solusi di Green Marketplace',
                            style: TextStyle(
                              color: Color(0xFF10B981),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward,
                            color: Color(0xFF10B981),
                            size: 14,
                          ),
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
        Text(
          label,
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildSimpleTextField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF10B981)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF6B7280),
                size: 18,
              ),
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w500,
              ),
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
    Paint bgPaint = Paint()
      ..color = const Color(0xFFF3F4F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.square;
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height * 2);
    canvas.drawArc(rect, pi, pi, false, bgPaint);

    Paint fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.square;
    canvas.drawArc(rect, pi, pi * percentage, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
