import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// ============================================================================
/// GENERATOR DOKUMEN RESMI POLICY BRIEF (FORMAT NASKAH KEBIJAKAN STRATEGIS RI)
/// ============================================================================
class PolicyBriefPdfService {
  /// Generate bytes PDF untuk naskah kebijakan eksekutif
  static Future<Uint8List> generatePdf({
    required double budgetSplit, // Persentase Reskilling (misal 55%)
  }) async {
    final pdf = pw.Document(
      title: 'Policy Brief Dekarbonisasi Industri Baja Nasional 2026',
      author: 'Kementerian Perindustrian & KLHK RI - Saber Karbon',
      subject: 'Rekomendasi Kebijakan Dekarbonisasi Hard-to-Abate 2026-2060',
      keywords: 'Policy Brief, CBAM, Dekarbonisasi, Baja Hijau, SDGs, SIINas',
    );

    // Coba ambil logo Saber Karbon dari asset
    Uint8List? logoBytes;
    try {
      final byteData = await rootBundle.load('assets/img/logo.png');
      logoBytes = byteData.buffer.asUint8List();
    } catch (_) {
      logoBytes = null;
    }

    final double educationBudget = budgetSplit * 1.8;
    final double umkmBudget = (100 - budgetSplit) * 1.8;

    // Warna tema dokumen resmi
    final navyColor = PdfColor.fromHex('#1E1B4B'); // Deep Royal Navy
    final primaryIndigo = PdfColor.fromHex('#3730A3');
    final darkSlate = PdfColor.fromHex('#0F172A');
    final textMuted = PdfColor.fromHex('#475569');
    final bgLight = PdfColor.fromHex('#F8FAFC');
    final borderSlate = PdfColor.fromHex('#CBD5E1');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 36),
        header: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'REPUBLIK INDONESIA • KEMENTERIAN PERINDUSTRIAN & KLHK RI',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: textMuted,
                      letterSpacing: 0.5,
                    ),
                  ),
                  pw.Text(
                    'DOKUMEN KEBIJAKAN STRATEGIS #PB-01/2026',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryIndigo,
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Divider(color: borderSlate, thickness: 0.6),
              pw.SizedBox(height: 8),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Divider(color: borderSlate, thickness: 0.6),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'SABER KARBON 2026: Sistem Akselerasi Baja Rendah Karbon Terintegrasi',
                    style: pw.TextStyle(fontSize: 8, color: textMuted),
                  ),
                  pw.Text(
                    'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                    style: pw.TextStyle(
                      fontSize: 8,
                      fontWeight: pw.FontWeight.bold,
                      color: darkSlate,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        build: (pw.Context context) => [
          // ==============================================================
          // 1. KOP SURAT RESMI LEMBAGA NEGARA
          // ==============================================================
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              if (logoBytes != null)
                pw.Container(
                  width: 52,
                  height: 52,
                  margin: const pw.EdgeInsets.only(right: 14),
                  child: pw.Image(pw.MemoryImage(logoBytes), fit: pw.BoxFit.contain),
                )
              else
                pw.Container(
                  width: 50,
                  height: 50,
                  margin: const pw.EdgeInsets.only(right: 14),
                  decoration: pw.BoxDecoration(
                    color: navyColor,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  ),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'RI',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'KEMENTERIAN PERINDUSTRIAN REPUBLIK INDONESIA',
                      style: pw.TextStyle(
                        fontSize: 11,
                        fontWeight: pw.FontWeight.bold,
                        color: darkSlate,
                        letterSpacing: 0.3,
                      ),
                    ),
                    pw.Text(
                      'KEMENTERIAN LINGKUNGAN HIDUP DAN KEHUTANAN RI',
                      style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: darkSlate,
                      ),
                    ),
                    pw.Text(
                      'SATUAN TUGAS AKSELERASI DEKARBONISASI INDUSTRI LOGAM (SABER KARBON)',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryIndigo,
                      ),
                    ),
                    pw.Text(
                      'Jl. Jend. Gatot Subroto Kav. 52-53, Jakarta 12950 • Portal Terpadu: siinas.kemenperin.go.id',
                      style: pw.TextStyle(fontSize: 7.5, color: textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Divider(thickness: 1.5, color: darkSlate),
          pw.SizedBox(height: 1),
          pw.Divider(thickness: 0.5, color: darkSlate),
          pw.SizedBox(height: 12),

          // ==============================================================
          // 2. KOTAK INFORMASI NASKAH KEBIJAKAN EKSEKUTIF
          // ==============================================================
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: bgLight,
              border: pw.Border.all(color: borderSlate, width: 0.8),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'NOMOR: PB.01/MENPERIN-KLHK/DEKARB-BAJA/X/2026',
                      style: pw.TextStyle(
                        fontSize: 8.5,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryIndigo,
                      ),
                    ),
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.red900,
                        borderRadius: pw.BorderRadius.all(pw.Radius.circular(3)),
                      ),
                      child: pw.Text(
                        'DOKUMEN KEBIJAKAN STRATEGIS • EKSEKUTIF',
                        style: pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 7.5,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'BAJA HIJAU ATAU EMISI BIRU: JALAN TENGAH DEKARBONISASI INDUSTRI LOGAM NASIONAL MENUJU NZE 2060 DAN KESIAPAN PASAR CBAM',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: navyColor,
                    height: 1.25,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  children: [
                    pw.Text(
                      'Sasaran Regulasi: ',
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: darkSlate,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        'Menko Perekonomian, Menteri Perindustrian, Menteri LHK, BPDLH, dan Dewan Pengurus IISIA',
                        style: pw.TextStyle(fontSize: 8, color: textMuted),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 14),

          // ==============================================================
          // 3. RINGKASAN EKSEKUTIF (EXECUTIVE SUMMARY)
          // ==============================================================
          _buildSectionHeader('I. RINGKASAN EKSEKUTIF & URGENSI CBAM 2026'),
          pw.Paragraph(
            text:
                '1. Industri besi dan baja merupakan tulang punggung pembangunan infrastruktur dan manufaktur nasional. Namun, sektor ini menyumbang intensitas emisi gas rumah kaca (GRK) terbesar dalam klaster hard-to-abate di Indonesia dengan total emisi terdaftar mencapai 2.86 MtCO2e.',
            style: pw.TextStyle(fontSize: 9, color: darkSlate, height: 1.35),
          ),
          pw.Paragraph(
            text:
                '2. Mulai 2026, pemberlakuan penuh mekanisme penyesuaian batas karbon Uni Eropa (Carbon Border Adjustment Mechanism / CBAM) dengan ambang batas acuan 0.80 tCO2/t baja mentah mengharuskan produsen baja nasional mempercepat penurunan intensitas emisi. Keterlambatan adaptasi berpotensi menimbulkan beban sertifikasi dan disinsentif tarif ekspor hingga Rp 180 Miliar per tahun bagi produsen nasional.',
            style: pw.TextStyle(fontSize: 9, color: darkSlate, height: 1.35),
          ),
          pw.Paragraph(
            text:
                '3. Policy brief ini menyajikan rekomendasi jalan tengah: percepatan transisi dari rute energi fosil (Blast Furnace & Induction Furnace konvensional) ke rute sirkular Electric Arc Furnace (EAF) berbasis bahan baku scrap lokal, didukung standardisasi mutu bahan baku UMKM serta audit MRV digital terintegrasi SIINas.',
            style: pw.TextStyle(fontSize: 9, color: darkSlate, height: 1.35),
          ),
          pw.SizedBox(height: 10),

          // ==============================================================
          // 4. ANALISIS DIAGNOSTIK & KONDISI EKSISTING (DATA SIINAS)
          // ==============================================================
          _buildSectionHeader('II. ANALISIS DIAGNOSTIK EMISI & FAKTA LAPANGAN (DATA SIINAS)'),
          pw.Paragraph(
            text:
                'Berdasarkan data audit sistem SIINas Nasional terhadap 142 fasilitas pabrik baja terdaftar, ditemukan 3 anomali kritis yang memerlukan intervensi kebijakan afirmatif:',
            style: pw.TextStyle(fontSize: 9, color: darkSlate, height: 1.35),
          ),
          pw.SizedBox(height: 4),

          // Tabel Diagnostik
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: borderSlate, width: 0.5),
            headerStyle: pw.TextStyle(
              fontSize: 8.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(color: navyColor),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignment: pw.Alignment.centerLeft,
            headerAlignment: pw.Alignment.centerLeft,
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            headers: [
              'Klaster Wilayah',
              'Dominasi Rute Teknologi',
              'Intensitas Rata-rata',
              'Status Kepatuhan CBAM',
            ],
            data: [
              [
                'Jawa Timur (48 Pabrik)',
                'Induction Furnace & Scrap Murahan',
                '1.48 tCO2/t baja',
                'ZONA MERAH (Perlu Audit Ketat)',
              ],
              [
                'Jawa Barat & Banten (70 Pabrik)',
                'Terpadu: Blast Furnace, DRI & EAF',
                '0.95 tCO2/t baja',
                'ZONA KUNING (Masa Transisi)',
              ],
              [
                'Jawa Tengah & DIY (14 Pabrik)',
                'Rolling Mill & Reheating Furnace',
                '0.82 tCO2/t baja',
                'ZONA AMAN TERKENDALI',
              ],
              [
                'Luar Pulau Jawa (10 Smelter)',
                'Smelter Primer & EBT Hidro',
                '0.74 tCO2/t baja',
                'LOLOS AMBANG BATAS (<0.80)',
              ],
            ],
          ),
          pw.SizedBox(height: 14),

          // ==============================================================
          // 5. INTEGRASI DENGAN 4 PILAR SDGS
          // ==============================================================
          _buildSectionHeader('III. PENYELARASAN DENGAN 4 PILAR SDGS INDONESIA'),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _buildSdgBox(
                  code: 'SDG 13',
                  title: 'Aksi Iklim (Climate Action)',
                  detail:
                      'Penurunan intensitas emisi nasional menuju batas toleransi 0.80 tCO2/t untuk mendukung target NDC 2030 penurunan emisi 35%.',
                  colorHex: '#3F7E44',
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: _buildSdgBox(
                  code: 'SDG 9',
                  title: 'Industri & Inovasi',
                  detail:
                      'Peningkatan adopsi teknologi tungku busur listrik (EAF) dan integrasi sensor cerobong CEMS real-time ke sistem SIINas.',
                  colorHex: '#FD6925',
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: _buildSdgBox(
                  code: 'SDG 3',
                  title: 'Kesehatan Masyarakat',
                  detail:
                      'Pemasangan wet scrubber pada seluruh cerobong peleburan baja Jawa Timur guna menekan polusi PM2.5 & kejadian ISPA.',
                  colorHex: '#4C9F38',
                ),
              ),
              pw.SizedBox(width: 8),
              pw.Expanded(
                child: _buildSdgBox(
                  code: 'SDG 4',
                  title: 'Pendidikan & Pelatihan',
                  detail:
                      'Program Green Reskilling bagi 12.400 pekerja baja serta asosiasi UMKM scrap agar cakap dalam pemilahan material sirkular.',
                  colorHex: '#C5192D',
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 14),

          // ==============================================================
          // 6. MATRIKS 3 REKOMENDASI KEBIJAKAN KONKRET
          // ==============================================================
          _buildSectionHeader('IV. TIGA PILAR REKOMENDASI KEBIJAKAN STRATEGIS'),
          _buildRecommendationItem(
            no: '1',
            title: 'Standarisasi Mutu Scrap Nasional & Kemitraan Sirkular UMKM',
            sub:
                'Menerbitkan Peraturan Bersama Kemenperin-KLHK tentang Standar Baku Mutu Scrap Logam Sirkular (bebas kontaminan radioaktif dan tramp elements) serta pemberian insentif pembebasan PPh Pasal 22 bagi pabrik yang bermitra resmi dengan koperasi UMKM scrap binaan.',
          ),
          pw.SizedBox(height: 6),
          _buildRecommendationItem(
            no: '2',
            title: 'Mandatori CEMS Digital & Akreditasi MRV Melalui SIINas',
            sub:
                'Mewajibkan pabrik berkapasitas di atas 50.000 ton/tahun memasang CEMS terhubung langsung ke dashboard SIINas. Pabrik yang memperoleh status "MRV Disetujui" diberikan diskon tarif listrik hijau (Green Tariff PLN) dan percepatan izin ekspor.',
          ),
          pw.SizedBox(height: 6),
          _buildRecommendationItem(
            no: '3',
            title: 'Alokasi Dana Transisi Hijau APBN / Nilai Ekonomi Karbon (NEK)',
            sub:
                'Memanfaatkan penerimaan pajak karbon sektor industri untuk mendanai modernisasi mesin scrap UMKM serta program reskilling tenaga kerja industri baja lokal.',
          ),
          pw.SizedBox(height: 12),

          // Simulasi Anggaran Sesuai State Aplikasi
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: bgLight,
              border: pw.Border.all(color: borderSlate, width: 0.8),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'SIMULASI ALOKASI ANGGARAN TRANSISI HIJAU (DANA KARBON / APBN):',
                  style: pw.TextStyle(
                    fontSize: 8.5,
                    fontWeight: pw.FontWeight.bold,
                    color: navyColor,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      '• Porsi Pendidikan & Reskilling Tenaga Kerja (${budgetSplit.toInt()}%)',
                      style: const pw.TextStyle(fontSize: 8.5),
                    ),
                    pw.Text(
                      'Rp ${educationBudget.toStringAsFixed(1)} Miliar',
                      style: pw.TextStyle(
                        fontSize: 8.5,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryIndigo,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 3),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      '• Porsi Bantuan Mesin & Gudang Scrap UMKM (${(100 - budgetSplit).toInt()}%)',
                      style: const pw.TextStyle(fontSize: 8.5),
                    ),
                    pw.Text(
                      'Rp ${umkmBudget.toStringAsFixed(1)} Miliar',
                      style: pw.TextStyle(
                        fontSize: 8.5,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#059669'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 16),

          // ==============================================================
          // 7. ROADMAP IMPLEMENTASI & LEMBAR PENGESAHAN
          // ==============================================================
          _buildSectionHeader('V. ROADMAP TAHAPAN AKSELERASI (2026 - 2030)'),
          pw.TableHelper.fromTextArray(
            border: pw.TableBorder.all(color: borderSlate, width: 0.5),
            headerStyle: pw.TextStyle(
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(color: navyColor),
            cellStyle: const pw.TextStyle(fontSize: 7.5),
            cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
            headers: ['Tahun', 'Fokus Kebijakan Utama', 'Target Emisi Rata-rata', 'Indikator Output'],
            data: [
              [
                '2026',
                'Mandatori MRV & Standardisasi Scrap UMKM',
                '1.10 tCO2/t',
                '100% Pabrik Baja Terkoneksi SIINas & CEMS',
              ],
              [
                '2027',
                'Insentif Green Tariff PLN & Pajak Karbon Efektif',
                '0.95 tCO2/t',
                '40% Rute Induksi Beralih ke EAF Bersih',
              ],
              [
                '2028-2029',
                'Penyediaan Hidrogen Hijau Skala Industri',
                '0.82 tCO2/t',
                'Pasokan Scrap Sirkular Lokal Capai 75%',
              ],
              [
                '2030',
                'Kepatuhan Penuh Standar Internasional CBAM',
                '<= 0.78 tCO2/t',
                'Target Penurunan Emisi Sektor Baja -35% Tercapai',
              ],
            ],
          ),
          pw.SizedBox(height: 24),

          // Lembar Pengesahan Pejabat
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('Mengetahui,', style: const pw.TextStyle(fontSize: 8.5)),
                  pw.Text(
                    'Direktur Industri Logam\nKementerian Perindustrian RI',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Text('( __________________________ )', style: const pw.TextStyle(fontSize: 8.5)),
                  pw.Text('NIP. 19740512 199903 1 002', style: pw.TextStyle(fontSize: 7.5, color: textMuted)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('Ditetapkan di Jakarta, 17 Oktober 2026', style: const pw.TextStyle(fontSize: 8.5)),
                  pw.Text(
                    'Koordinator Tim Peneliti & Analis\nInisiatif Saber Karbon 2026',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 40),
                  pw.Text('( Dr. Ir. Aditia Rahmad, M.Sc. )', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
                  pw.Text('NIDN. 0724088901 • Tim Ahli Kebijakan', style: pw.TextStyle(fontSize: 7.5, color: textMuted)),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildSectionHeader(String title) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6),
      padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 6),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromHex('#EEF2FF'),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 9.5,
          fontWeight: pw.FontWeight.bold,
          color: PdfColor.fromHex('#312E81'),
        ),
      ),
    );
  }

  static pw.Widget _buildSdgBox({
    required String code,
    required String title,
    required String detail,
    required String colorHex,
  }) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(7),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColor.fromHex('#E2E8F0'), width: 0.8),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      ),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 3),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex(colorHex),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
            ),
            child: pw.Text(
              code,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          pw.SizedBox(width: 6),
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 2),
                pw.Text(
                  detail,
                  style: pw.TextStyle(fontSize: 7.5, color: PdfColor.fromHex('#475569')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildRecommendationItem({
    required String no,
    required String title,
    required String sub,
  }) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 16,
          height: 16,
          decoration: pw.BoxDecoration(
            color: PdfColor.fromHex('#312E81'),
            shape: pw.BoxShape.circle,
          ),
          alignment: pw.Alignment.center,
          child: pw.Text(
            no,
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 8,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                title,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromHex('#0F172A'),
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                sub,
                style: pw.TextStyle(
                  fontSize: 8,
                  color: PdfColor.fromHex('#475569'),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
