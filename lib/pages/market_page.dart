import 'package:flutter/material.dart';

class MarketPage extends StatelessWidget {
  const MarketPage({super.key});

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
            Text('Green Market', style: TextStyle(color: Color(0xFF111827), fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Hijaukan Produk, Kuasai Pasar', style: TextStyle(color: Color(0xFF6B7280), fontSize: 11)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.shopping_basket_outlined, color: Color(0xFF4B5563)), onPressed: () {})
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Green Marketplace', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1F2937))),
              const SizedBox(height: 4),
              const Text('B2B Supply-Chain Matchmaking', style: TextStyle(fontSize: 14, color: Color(0xFF4B5563))),
              const SizedBox(height: 20),
              
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Row(
                  children: [
                    Icon(Icons.search, color: Color(0xFF9CA3AF)),
                    SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Cari mesin EAF, panel surya, atau\nbahan baku scrap...',
                          hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Categories
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryChip('Semua Kategori', true),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Bahan Baku Sirkular (UMKM)', false),
                    const SizedBox(width: 8),
                    _buildCategoryChip('Teknologi EAF', false),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Vendor Cards
              _buildVendorCard(
                icon: Icons.factory,
                isVerified: true,
                title: 'PT IndoEAF Technologies',
                location: 'Jakarta Barat',
                desc: 'Penyedia Mesin Electric Arc Furnace (EAF) skala menengah.',
                infoLabel: 'Efisiensi Karbon:',
                infoValue: '-45%',
                buttonText: 'Hubungi Vendor',
                isPrimaryButton: true,
              ),
              const SizedBox(height: 16),
              
              _buildVendorCard(
                icon: Icons.precision_manufacturing,
                isVerified: false,
                badgeText: 'Koperasi UMKM',
                badgeIcon: Icons.groups,
                title: 'Koperasi Scrap Baja Jatim',
                location: 'Jawa Timur',
                desc: 'Pengepul besi tua (scrap) untuk bahan baku baja daur ulang (Circular Steel).',
                infoLabel: 'Kapasitas Suplai:',
                infoValue: '5.000 Ton/Bulan',
                buttonText: 'Ajukan Penawaran',
                isPrimaryButton: false,
              ),
              const SizedBox(height: 16),
              
              _buildVendorCard(
                icon: Icons.solar_power,
                isVerified: true,
                title: 'SolarIndo EPC',
                location: 'Banten',
                desc: 'Instalasi Panel Surya Atap Pabrik (On-Grid).',
                infoLabel: 'Potensi Penghematan PLN:',
                infoValue: '30%',
                buttonText: 'Hubungi Vendor',
                isPrimaryButton: true,
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isSelected ? null : Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF6B7280),
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildVendorCard({
    required IconData icon,
    required bool isVerified,
    String? badgeText,
    IconData? badgeIcon,
    required String title,
    required String location,
    required String desc,
    required String infoLabel,
    required String infoValue,
    required String buttonText,
    required bool isPrimaryButton,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF4F46E5), size: 24),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isVerified ? const Color(0xFFECFDF5) : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVerified ? Icons.verified : (badgeIcon ?? Icons.info),
                      color: isVerified ? const Color(0xFF10B981) : const Color(0xFF6B7280),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      badgeText ?? 'Verified Vendor',
                      style: TextStyle(
                        color: isVerified ? const Color(0xFF065F46) : const Color(0xFF4B5563),
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
          
          // Title & Location
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Color(0xFF6B7280), size: 14),
              const SizedBox(width: 4),
              Text(location, style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563))),
            ],
          ),
          const SizedBox(height: 12),
          
          // Description
          Text(desc, style: const TextStyle(fontSize: 14, color: Color(0xFF4B5563), height: 1.4)),
          const SizedBox(height: 16),
          
          // Divider
          const Divider(color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          
          // Info Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(infoLabel, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              Text(infoValue, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF10B981))),
            ],
          ),
          const SizedBox(height: 20),
          
          // Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: isPrimaryButton
                ? ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  )
                : OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF9CA3AF)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text(buttonText, style: const TextStyle(color: Color(0xFF4B5563), fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
          ),
        ],
      ),
    );
  }
}
