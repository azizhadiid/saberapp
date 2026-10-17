import 'package:flutter/material.dart';

/// ============================================================================
/// PERMINTAAN PABRIK BAJA (RFQ INDUSTRI UNTUK UMKM / PERUSAHAAN HIJAU)
/// ============================================================================
class UmkmDemandView extends StatelessWidget {
  const UmkmDemandView({super.key});

  final List<Map<String, dynamic>> _industryRfqs = const [
    {
      'factory_name': 'PT Krakatau Steel (Persero) Tbk',
      'location': 'Cilegon, Banten',
      'need_material': 'Scrap Baja Heavy Melting Steel (HMS 1)',
      'target_volume': '1.500 Ton / Bulan',
      'max_price': 'Rp 7.100.000 / Ton',
      'spec': 'Fe > 98.2%, Bebas Oli & Cat, Cu < 0.08%',
      'urgency': 'Tinggi • Kontrak EAF 6 Bulan',
      'delivery_deadline': '28 Oktober 2026',
    },
    {
      'factory_name': 'PT Gunung Raja Paksi Tbk',
      'location': 'Cikarang, Bekasi - Jawa Barat',
      'need_material': 'Shredded Scrap Kerapatan Tinggi (MRF)',
      'target_volume': '900 Ton / Bulan',
      'max_price': 'Rp 7.300.000 / Ton',
      'spec': 'Bodi Otomotif Cacah, Densitas > 0.9 t/m3',
      'urgency': 'Reguler • Penerimaan Mingguan',
      'delivery_deadline': '02 November 2026',
    },
    {
      'factory_name': 'PT Bhirawa Steel Surabaya',
      'location': 'Margomulyo, Surabaya - Jawa Timur',
      'need_material': 'Prompt Industrial Busheling & Pelat Bersih',
      'target_volume': '600 Ton / Bulan',
      'max_price': 'Rp 7.450.000 / Ton',
      'spec': 'Sisa Stamping Pabrik Logam, Siap Umpan Induction',
      'urgency': 'Tinggi • Pasokan Mendesak',
      'delivery_deadline': '25 Oktober 2026',
    },
    {
      'factory_name': 'PT Ispat Indo',
      'location': 'Sepanjang, Sidoarjo - Jawa Timur',
      'need_material': 'Briket Biomassa Cangkang Sawit Terkarbonisasi',
      'target_volume': '400 Ton / Bulan',
      'max_price': 'Rp 2.250.000 / Ton',
      'spec': 'Kadar Air < 8%, Nilai Kalor > 4.500 kkal/kg',
      'urgency': 'R&D Transisi Kokas Hijau',
      'delivery_deadline': '10 November 2026',
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Permintaan Pabrik Baja',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Permintaan Resmi (RFQ) Pabrik Baja Mitra',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _industryRfqs.length,
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final rfq = _industryRfqs[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.factory_outlined,
                        color: Color(0xFF0284C7),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rfq['factory_name']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: Color(0xFF94A3B8),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rfq['location']!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        rfq['urgency']!,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kebutuhan: ${rfq['need_material']}',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Spesifikasi: ${rfq['spec']}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Volume: ${rfq['target_volume']}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                          Text(
                            'Batas Harga: ${rfq['max_price']}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Batas Penawaran: ${rfq['delivery_deadline']}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Form penawaran ke ${rfq['factory_name']} siap dikirim!',
                            ),
                            backgroundColor: const Color(0xFF0284C7),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0284C7),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.send, size: 14),
                      label: const Text(
                        'Kirim Penawaran',
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
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
