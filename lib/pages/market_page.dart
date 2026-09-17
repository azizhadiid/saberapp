import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MarketPage extends StatefulWidget {
  const MarketPage({super.key});

  @override
  State<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends State<MarketPage> {
  String _searchQuery = '';
  String _selectedCategory = 'Semua Kategori';

  List<Map<String, dynamic>> _allVendors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVendors();
  }

  Future<void> _fetchVendors() async {
    try {
      final response = await Supabase.instance.client
          .from('green_vendor_markets')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        _allVendors = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error fetching vendors: $e');
    }
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'factory':
        return Icons.factory;
      case 'precision_manufacturing':
        return Icons.precision_manufacturing;
      case 'solar_power':
        return Icons.solar_power;
      case 'groups':
        return Icons.groups;
      case 'recycling':
        return Icons.recycling;
      case 'eco':
        return Icons.eco;
      default:
        return Icons.business;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter logic
    final filteredVendors = _allVendors.where((vendor) {
      final matchesSearch =
          (vendor['name'] ?? '').toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          (vendor['description'] ?? '').toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      final matchesCategory =
          _selectedCategory == 'Semua Kategori' ||
          vendor['category'] == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();

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
              'Green Market',
              style: TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              'Hijaukan Produk, Kuasai Pasar',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shopping_basket_outlined,
              color: Color(0xFF4B5563),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF10B981)),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Green Marketplace',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'B2B Supply-Chain Matchmaking',
                      style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
                    ),
                    const SizedBox(height: 20),

                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFF9CA3AF)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val;
                                });
                              },
                              decoration: const InputDecoration(
                                hintText:
                                    'Cari mesin EAF, panel surya, atau\nbahan baku scrap...',
                                hintStyle: TextStyle(
                                  color: Color(0xFF9CA3AF),
                                  fontSize: 13,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
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
                          _buildCategoryChip('Semua Kategori'),
                          const SizedBox(width: 8),
                          _buildCategoryChip('Bahan Baku Sirkular (UMKM)'),
                          const SizedBox(width: 8),
                          _buildCategoryChip('Teknologi EAF'),
                          const SizedBox(width: 8),
                          _buildCategoryChip('Energi Terbarukan'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Vendor Cards
                    if (filteredVendors.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text(
                            'Tidak ada vendor yang sesuai dengan pencarian Anda.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Color(0xFF6B7280)),
                          ),
                        ),
                      )
                    else
                      ...filteredVendors.map((vendor) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildVendorCard(
                            icon: _getIconData(vendor['icon_name']),
                            isVerified: vendor['verification_status'] ?? false,
                            title: vendor['name'] ?? 'Vendor',
                            location:
                                vendor['location'] ?? 'Lokasi tidak diketahui',
                            desc: vendor['description'] ?? '',
                            infoLabel: vendor['info_label'] ?? 'Info',
                            infoValue: vendor['info_value'] ?? '-',
                            buttonText: (vendor['verification_status'] == true)
                                ? 'Hubungi Vendor'
                                : 'Ajukan Penawaran',
                            isPrimaryButton:
                                vendor['verification_status'] == true,
                            badgeText: vendor['badge_text'],
                            badgeIcon: _getIconData(vendor['badge_icon']),
                          ),
                        );
                      }).toList(),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCategoryChip(String label) {
    bool isSelected = _selectedCategory == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1F2937) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isVerified
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isVerified ? Icons.verified : (badgeIcon ?? Icons.info),
                      color: isVerified
                          ? const Color(0xFF10B981)
                          : const Color(0xFF6B7280),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      badgeText ?? 'Verified Vendor',
                      style: TextStyle(
                        color: isVerified
                            ? const Color(0xFF065F46)
                            : const Color(0xFF4B5563),
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Color(0xFF6B7280),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                location,
                style: const TextStyle(fontSize: 12, color: Color(0xFF4B5563)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            desc,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF4B5563),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Divider
          const Divider(color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),

          // Info Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                infoLabel,
                style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
              ),
              Text(
                infoValue,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          buttonText,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  )
                : OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4F46E5),
                      side: const BorderSide(color: Color(0xFF4F46E5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
