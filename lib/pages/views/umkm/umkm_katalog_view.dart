import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// ============================================================================
/// KATALOG PASOKAN SCRAP & BAHAN BAKU SIRKULAR (UMKM & PERUSAHAAN HIJAU)
/// ============================================================================
class UmkmKatalogView extends StatefulWidget {
  final VoidCallback onAddSupply;

  const UmkmKatalogView({super.key, required this.onAddSupply});

  @override
  State<UmkmKatalogView> createState() => _UmkmKatalogViewState();
}

class _UmkmKatalogViewState extends State<UmkmKatalogView> {
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
