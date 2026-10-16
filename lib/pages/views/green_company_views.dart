import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// ============================================================================
/// 1. KATALOG PASOKAN SCRAP & GREEN TECH (PERUSAHAAN HIJAU / UMKM)
/// ============================================================================
class GreenKatalogView extends StatefulWidget {
  final VoidCallback onAddSupply;

  const GreenKatalogView({super.key, required this.onAddSupply});

  @override
  State<GreenKatalogView> createState() => _GreenKatalogViewState();
}

class _GreenKatalogViewState extends State<GreenKatalogView> {
  String _selectedCategory = 'Semua Kategori';

  final List<String> _categories = [
    'Semua Kategori',
    'Scrap HMS 1&2',
    'Shredded Scrap MRF',
    'Prompt Industrial Scrap',
    'Bahan Baku Biomassa',
    'Teknologi EAF & Filter',
  ];

  final List<Map<String, dynamic>> _mySupplyList = [
    {
      'title': 'Heavy Melting Steel (HMS 1&2) Siap Umpan EAF',
      'category': 'Scrap HMS 1&2',
      'depo': 'Depo Utama Surabaya & Gresik, Jawa Timur',
      'tonnage_available': 1850,
      'unit': 'Ton',
      'fe_grade': 98.4,
      'price_per_ton': 6850000,
      'co2_saved_ton': 2627.0, // 1.42 tCO2e x ton
      'mrf_certified': true,
      'cu_impurity': '< 0.08%',
      'status': 'Siap Kirim',
    },
    {
      'title': 'Shredded Scrap Densitas Tinggi (Otomotif Daur Ulang)',
      'category': 'Shredded Scrap MRF',
      'depo': 'Sentra Daur Ulang Cilegon, Banten',
      'tonnage_available': 1200,
      'unit': 'Ton',
      'fe_grade': 99.1,
      'price_per_ton': 7250000,
      'co2_saved_ton': 1848.0,
      'mrf_certified': true,
      'cu_impurity': '< 0.05%',
      'status': 'Siap Kirim',
    },
    {
      'title': 'New Prompt Busheling Scrap (Stamping Pabrik Mobil)',
      'category': 'Prompt Industrial Scrap',
      'depo': 'Kawasan Industri Cikarang, Karawang - Jawa Barat',
      'tonnage_available': 950,
      'unit': 'Ton',
      'fe_grade': 99.5,
      'price_per_ton': 7450000,
      'co2_saved_ton': 1406.0,
      'mrf_certified': true,
      'cu_impurity': '< 0.02%',
      'status': 'Tersedia Terbatas',
    },
    {
      'title': 'Briket Cangkang Sawit Terkarbonisasi (Reduktor Hijau)',
      'category': 'Bahan Baku Biomassa',
      'depo': 'Sentra Pengolahan Biomassa Jambi & Riau',
      'tonnage_available': 650,
      'unit': 'Ton',
      'fe_grade': 0.0,
      'price_per_ton': 2100000,
      'co2_saved_ton': 1170.0,
      'mrf_certified': true,
      'cu_impurity': 'N/A',
      'status': 'Siap Kirim',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final filteredList = _selectedCategory == 'Semua Kategori'
        ? _mySupplyList
        : _mySupplyList
            .where((item) => item['category'] == _selectedCategory)
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.recycling, color: Color(0xFF0284C7), size: 22),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lapak Pasokan Hijau',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Ekosistem UMKM Sirkular & Pemasok EAF',
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF0284C7)),
            tooltip: 'Tambah Pasokan',
            onPressed: widget.onAddSupply,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Ringkasan Pasokan & Dampak Lingkungan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0284C7), Color(0xFF0369A1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                    blurRadius: 12,
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
                      const Row(
                        children: [
                          Icon(Icons.eco, color: Colors.white, size: 20),
                          SizedBox(width: 6),
                          Text(
                            'KONTRIBUSI EMISI SIRKULAR',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'UMKM Terverifikasi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    '7.051 tCO2e',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Total emisi karbon dihemat oleh pabrik baja melalui pasokan scrap & biomassa Anda bulan ini.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildHeaderStat('Total Stok Aktif', '4.650 Ton'),
                      Container(width: 1, height: 26, color: Colors.white24),
                      _buildHeaderStat('Mitra Pabrik', '14 Pabrik Baja'),
                      Container(width: 1, height: 26, color: Colors.white24),
                      _buildHeaderStat('Standar Lolos', 'MRF Fe > 98%'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Kategori Filter Horizontal
            const Text(
              'Filter Kategori Bahan Baku',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() => _selectedCategory = cat);
                      },
                      selectedColor: const Color(0xFF0284C7),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF475569),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF0284C7)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Daftar Kartu Pasokan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daftar Pasokan Aktif (${filteredList.length})',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                ),
                TextButton.icon(
                  onPressed: widget.onAddSupply,
                  icon: const Icon(Icons.add, size: 16, color: Color(0xFF0284C7)),
                  label: const Text(
                    'Tambah Pasokan',
                    style: TextStyle(color: Color(0xFF0284C7), fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredList.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = filteredList[index];
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item['category'],
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (item['mrf_certified'] == true)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Row(
                                          children: [
                                            Icon(
                                              Icons.verified,
                                              size: 11,
                                              color: Color(0xFF16A34A),
                                            ),
                                            SizedBox(width: 4),
                                            Text(
                                              'Lolos Sortir MRF',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF16A34A),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item['title'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
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
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item['status'],
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item['depo'],
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFFF1F5F9), height: 1),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Ketersediaan Stok',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${item['tonnage_available']} ${item['unit']}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                          if (item['fe_grade'] > 0)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kadar Fe & Cu',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF94A3B8),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Fe ${item['fe_grade']}% • Cu ${item['cu_impurity']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0284C7),
                                  ),
                                ),
                              ],
                            ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Harga Penawaran / Ton',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currency.format(item['price_per_ton']),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

/// ============================================================================
/// 2. PERMINTAAN PABRIK BAJA (RFQ INDUSTRI UNTUK PERUSAHAAN HIJAU)
/// ============================================================================
class GreenDemandView extends StatelessWidget {
  const GreenDemandView({super.key});

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

/// ============================================================================
/// 3. KEMITRAAN & STANDAR MUTU DEKARBONISASI (PERUSAHAAN HIJAU)
/// ============================================================================
class GreenPartnershipView extends StatelessWidget {
  const GreenPartnershipView({super.key});

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
              'Standar & Kemitraan Sirkular',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Pedoman Mutu Scrap SNI & Program Akselerasi UMKM',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner SNI & Sortir MRF
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.workspace_premium, color: Color(0xFF16A34A), size: 36),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Standar SNI 07-0052 Scrap Logam',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF166534),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Pabrik baja rute EAF hanya menerima scrap dengan pemilahan MRF bersertifikat untuk mencegah ledakan tungku & slag berlebih.',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF15803D)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              '3 Pilar Kualifikasi Pasokan UMKM',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),

            _buildPillarCard(
              icon: Icons.science_outlined,
              title: 'Kemurnian Fe > 98% & Cu < 0.1%',
              desc:
                  'Kadar pengotor tembaga (Cu) dan timbal (Pb) harus sangat rendah agar baja tulangan dan pelat yang dihasilkan tidak retak panas (hot shortness).',
              badge: 'Kriteria Mutu',
              badgeColor: const Color(0xFF0284C7),
            ),
            const SizedBox(height: 10),
            _buildPillarCard(
              icon: Icons.cleaning_services_outlined,
              title: 'Proses Sortir MRF (Material Recovery)',
              desc:
                  'Bebas dari kontaminan non-logam seperti oli, plastik, cat, tanah, dan serbuk basah yang berpotensi memicu emisi polusi sulfur berlebih.',
              badge: 'Standar Operasi',
              badgeColor: const Color(0xFF059669),
            ),
            const SizedBox(height: 10),
            _buildPillarCard(
              icon: Icons.account_balance_outlined,
              title: 'Fasilitas KUR Hijau & Bantuan Shredder',
              desc:
                  'Program pendanaan berbunga rendah dari pemerintah bagi koperasi besi tua untuk membeli mesin baler press & shredder hidrolik berkapasitas 50 ton/hari.',
              badge: 'Bantuan Finansial',
              badgeColor: const Color(0xFFD97706),
            ),

            const SizedBox(height: 24),

            // Direktori Pabrik Mitra
            const Text(
              'Direktori 142 Pabrik Baja Mitra Penerima Scrap',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                children: [
                  _buildFactoryRow('PT Krakatau Steel (Persero) Tbk', 'Cilegon, Banten', 'EAF & DRI', 'Aktif'),
                  const Divider(color: Color(0xFFF1F5F9), height: 16),
                  _buildFactoryRow('PT Gunung Raja Paksi Tbk', 'Cikarang, Bekasi', 'EAF High-Cap', 'Aktif'),
                  const Divider(color: Color(0xFFF1F5F9), height: 16),
                  _buildFactoryRow('PT Bhirawa Steel', 'Surabaya, Jawa Timur', 'EAF & Rolling Mill', 'Aktif'),
                  const Divider(color: Color(0xFFF1F5F9), height: 16),
                  _buildFactoryRow('PT Lautan Steel Indonesia', 'Tangerang, Banten', 'Induction & EAF', 'Aktif'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillarCard({
    required IconData icon,
    required String title,
    required String desc,
    required String badge,
    required Color badgeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: badgeColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  desc,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactoryRow(String name, String loc, String tech, String status) {
    return Row(
      children: [
        const Icon(Icons.business, size: 18, color: Color(0xFF0284C7)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                '$loc • Rute: $tech',
                style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            status,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF16A34A),
            ),
          ),
        ),
      ],
    );
  }
}

/// ============================================================================
/// 4. MODAL DIALOG: INPUT PASOKAN SCRAP / JUAL CEPAT
/// ============================================================================
class GreenAddSupplyDialog extends StatefulWidget {
  const GreenAddSupplyDialog({super.key});

  @override
  State<GreenAddSupplyDialog> createState() => _GreenAddSupplyDialogState();
}

class _GreenAddSupplyDialogState extends State<GreenAddSupplyDialog> {
  final _titleCtrl = TextEditingController();
  final _tonnageCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String _selectedCategory = 'Scrap HMS 1&2';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _tonnageCtrl.dispose();
    _priceCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.add_business,
                      color: Color(0xFF0284C7),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pasok Scrap / Bahan Baku',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Tawarkan stok ke 142 pabrik baja mitra',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Kategori Pasokan',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                items: const [
                  DropdownMenuItem(value: 'Scrap HMS 1&2', child: Text('Scrap HMS 1&2')),
                  DropdownMenuItem(
                      value: 'Shredded Scrap MRF', child: Text('Shredded Scrap MRF')),
                  DropdownMenuItem(
                      value: 'Prompt Industrial Scrap',
                      child: Text('Prompt Industrial Scrap')),
                  DropdownMenuItem(
                      value: 'Bahan Baku Biomassa', child: Text('Bahan Baku Biomassa')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Nama Pasokan / Material',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  hintText: 'Contoh: Scrap Pelat Baja 12mm Terpotong',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Volume (Ton)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _tonnageCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '500',
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Harga / Ton (Rp)',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '6.900.000',
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Lokasi Depo / Gudang',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              TextField(
                controller: _locationCtrl,
                decoration: InputDecoration(
                  hintText: 'Surabaya, Jawa Timur',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pasokan berhasil diposting ke Bursa Pabrik Baja!'),
                          backgroundColor: Color(0xFF0284C7),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Posting Pasokan',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
