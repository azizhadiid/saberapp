import 'package:flutter/material.dart';

/// ============================================================================
/// AUDIT & VALIDASI MRV NASIONAL (PEMERINTAH / REGULATOR)
/// ============================================================================
class GovMrvAuditView extends StatefulWidget {
  const GovMrvAuditView({super.key});

  @override
  State<GovMrvAuditView> createState() => _GovMrvAuditViewState();
}

class _GovMrvAuditViewState extends State<GovMrvAuditView> {
  final List<Map<String, dynamic>> _auditQueue = [
    {
      'id': 'MRV-2026-01',
      'factory_name': 'PT Krakatau Baja Terpadu',
      'siinas_id': 'SIINAS #KRK-01',
      'location': 'Cilegon, Banten',
      'route': 'Direct Reduced Iron (DRI) -> EAF',
      'intensity': 0.76, // tCO2/t
      'status': 'Menunggu Validasi MRV',
      'verified': false,
    },
    {
      'id': 'MRV-2026-02',
      'factory_name': 'PT Smelter Induksi Jaya',
      'siinas_id': 'SIINAS #SIJ-09',
      'location': 'Gresik, Jawa Timur',
      'route': 'Induction Furnace Tanpa Scrubber',
      'intensity': 1.68,
      'status': 'Peringatan K3 Polusi PM2.5',
      'verified': false,
    },
    {
      'id': 'MRV-2026-03',
      'factory_name': 'Koperasi Scrap Besi Mandiri',
      'siinas_id': 'SIINAS #KSM-03',
      'location': 'Surabaya, Jawa Timur',
      'route': 'Material Recovery Facility (MRF)',
      'intensity': 0.12,
      'status': 'Menunggu Sertifikasi Hijau',
      'verified': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFA7F3D0)),
              ),
              child: Image.asset(
                'assets/img/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.fact_check,
                  color: Color(0xFF059669),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Panel Audit & Validasi MRV',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Pengawasan Kepatuhan Emisi & Sertifikasi Hijau',
                    style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _auditQueue.length,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final item = _auditQueue[index];
          final isVerified = item['verified'] == true;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isVerified
                    ? const Color(0xFF86EFAC)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item['id'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF059669),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isVerified
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isVerified
                            ? 'Lolos Verifikasi MRV'
                            : (item['status'] as String),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isVerified
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item['factory_name'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item['siinas_id']} • ${item['location']}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rute: ${item['route']}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF334155)),
                      ),
                      Text(
                        '${item['intensity']} tCO2/t',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: (item['intensity'] as double) <= 0.80
                              ? const Color(0xFF16A34A)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isVerified) ...[
                      OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Surat Peringatan & Rekomendasi dikirim ke ${item['factory_name']}!',
                              ),
                              backgroundColor: const Color(0xFFDC2626),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFFCA5A5)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                        child: const Text('Kirim Peringatan', style: TextStyle(fontSize: 11)),
                      ),
                      const SizedBox(width: 8),
                    ],
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          item['verified'] = true;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Laporan ${item['factory_name']} berhasil diverifikasi resmi!',
                            ),
                            backgroundColor: const Color(0xFF16A34A),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isVerified
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      icon: Icon(
                        isVerified ? Icons.check : Icons.verified,
                        size: 14,
                      ),
                      label: Text(
                        isVerified ? 'Terverifikasi' : 'Verifikasi MRV',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
